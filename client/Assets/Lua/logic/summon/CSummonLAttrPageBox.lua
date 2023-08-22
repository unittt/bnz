local CSummonLAttrPageBox = class("CSummonLAttrPageBox", CBox)

function CSummonLAttrPageBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_SummonItems = {}
	self.m_ChangeNameHint_1 = 1034
	self.m_ChangeNameHint_2 = 1035
	self.m_ChangeNameHint_3 = 1036
	self:InitContent()	
end

function CSummonLAttrPageBox.InitContent(self)			
	self.m_SummonName = self:NewUI(1, CLabel)
	self.m_SummonGrade = self:NewUI(2, CLabel)
	self.m_SummonNameBtn = self:NewUI(3, CSprite)
	self.m_SummonTypeBtn = self:NewUI(4, CSprite)
	self.m_SummonModelTexture = self:NewUI(5, CActorTexture)
	self.m_SummonElementBtn = self:NewUI(6, CButton)
	self.m_SummonPower = self:NewUI(7, CLabel)
	self.m_SummonIsCombat = self:NewUI(8, CSprite, false)
	self.m_SummonNation = self:NewUI(9, CSprite, false)
	self.m_SummonGrid = self:NewUI(10, CGrid, false)
	self.m_SummonScore = self:NewUI(12, CSprite)
	self.m_SummonItemCell = self:NewUI(11, CBox, false)
	self.m_SummonSumScore = self:NewUI(13, CLabel)
	self:CreateSummonItem()
end

function CSummonLAttrPageBox.SetInfo(self, summonId)
    local g_SummonCtrl = g_SummonCtrl
	local dp = g_SummonCtrl:GetSummon(summonId)
	if dp == nil then
		return
	end
	self.m_CurSummonId = summonId
 	self.m_SummonName:SetText(dp["name"])
	self.m_SummonGrade:SetText("等级"..dp["grade"])	
	self.m_SummonPower:SetText(dp["score"])
	self.m_SummonSumScore:SetText("评分："..dp["summon_score"])
	self.m_SummonNameBtn:AddUIEvent("click",callback(self,"OpenRenameWindow"))
	if self.m_SummonModelTexture ~= nil then
	    -- if dp.name == "熊猫剑侠" then
	    --    self.m_SummonModelTexture:SetSize(336,252)
	    --    self.m_SummonModelTexture:SetLocalPos(Vector3.New(29,145,0))
	    -- else
	    --    self.m_SummonModelTexture:SetSize(400,300)
	    --    self.m_SummonModelTexture:SetLocalPos(Vector3.New(29,166,0))
	    -- end 

	    local model_info =  table.copy(dp.model_info)
	    model_info.rendertexSize = 0.8
		self.m_SummonModelTexture:ChangeShape(model_info)
	end
	self.m_SummonNation:SetSpriteName(data.summondata.RACE[dp["race"]].icon)
	local element = data.summondata.ELEMENT[dp["element"]]
	self.m_SummonElementBtn:SetSpriteName(element.icon)
	self.m_SummonElementBtn:AddUIEvent("click",function ()
		local zContent = {title = element.name,desc = element.tips}
    	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
	end)
	if summonId == g_SummonCtrl.m_FightId then 
		self.m_SummonIsCombat:SetActive(true)
	 else
	 	self.m_SummonIsCombat:SetActive(false)	
	end	
	if data.summondata.SUMMTYPE[dp["type"]] ~= nil then 
		self.m_SummonTypeBtn:SetSpriteName(data.summondata.SUMMTYPE[dp["type"]].icon)
	end
	for k,v in pairs(data.summondata.SCORE) do --设置评分等级
		if v.rank == dp["rank"] then 
			self.m_SummonScore:SetSpriteName(data.summondata.SCORE[k].icon)
			break	
		end
	end	
end

function CSummonLAttrPageBox.CreateSummonItem(self, summonId)
	self.m_EffRecord = g_SummonCtrl:GetSummonEffRecord()
	if summonId then
		self.m_CurSummonId = summonId
	else
		self.m_CurSummonId = g_SummonCtrl:GetSummonIdByIndex(1)
	end
	self.m_SummonGrid:Clear()
	for i = 1, g_SummonCtrl.m_SummonMax do
		self:AddEmptyItem()
	end
	for k,v in pairs(g_SummonCtrl.m_SummonsSort) do
		self:UpdateSummonItem(self.m_SummonGrid:GetChild(k), v)
	end	
end

function CSummonLAttrPageBox.UpdateAllItem(self, summonId)
	self.m_EffRecord = g_SummonCtrl:GetSummonEffRecord()
	self.m_CurSummonId = summonId
	self.m_SummonItems = {}
	for k,v in pairs(g_SummonCtrl.m_SummonsSort) do
		local item = self.m_SummonGrid:GetChild(k)
		self.m_SummonItems[v.id] = item
		self:UpdateSummonItem(item, v)
		if v.typeid == g_GuideHelpCtrl:GetSummon2() then
			g_GuideCtrl:AddGuideUI("summon_1002_box_btn", item)
		end
	end
	for i = #g_SummonCtrl.m_SummonsSort + 1, g_SummonCtrl.m_SummonMax do
		local item = self.m_SummonGrid:GetChild(i)
		item["pic"]:SetActive(false)
		item["bind"]:SetActive(false)
		item["grade"]:SetActive(false)
		item["fight"]:SetActive(false)
		item:SetSelected(false)
		item:AddUIEvent("click",callback(self,"SetEmptyItem"))
		item:SetActive(true)
	end	
end

function CSummonLAttrPageBox.AddEmptyItem(self)
	local item  = self.m_SummonItemCell:Clone("SummonItemCell")
	item["pic"] = item:NewUI(1, CSprite)
	item["bind"] = item:NewUI(2, CSprite)
	item["fight"] = item:NewUI(3, CSprite)
	item["grade"] = item:NewUI(4, CLabel)
	item["pic"]:SetActive(false)
	item["bind"]:SetActive(false)
	item["grade"]:SetActive(false)
	item["fight"]:SetActive(false)		
	item:SetActive(true)
	item:AddUIEvent("click",callback(self,"SetEmptyItem"))				
	item:SetGroup(self.m_SummonGrid:GetInstanceID())
	self.m_SummonGrid:AddChild(item)
end

function CSummonLAttrPageBox.UpdateSummonItem(self, item, v)
	if not item then
		return
	end
	item["pic"]:SpriteAvatar(v.model_info.shape) --头像	
	item["grade"]:SetText(v["grade"].."级")
	item["pic"]:SetActive(true)	
	item["grade"]:SetActive(true)
	item.traceno = v.traceno
	item.id = v.id
	if v.id == g_SummonCtrl.m_FightId then
		self.m_CurFightId = v.id
		item["fight"]:SetActive(true)
	else
		item["fight"]:SetActive(false)
	end

	if v.key == 1 then 
		item["bind"]:SetActive(true)
	else
		item["bind"]:SetActive(false)
	end
	if v.id == self.m_CurSummonId then
		item:SetSelected(true)
	end	
	item:SetGroup(self.m_SummonGrid:GetInstanceID())
	item:SetActive(true)
	if self.m_EffRecord[tostring(v.traceno)] == nil or self.m_EffRecord[tostring(v.traceno)].isShow == true then				
		self:SetRed(item, true)
	else
		self:SetRed(item, false)
	end
	item:AddUIEvent("click", callback(self, "SetPropertyInfo", item, v.id))
end

function CSummonLAttrPageBox.DelSummonItem(self, traceno)
	if self.m_EffRecord[tostring(traceno)] == nil then
		self.m_EffRecord[tostring(traceno)] = {}
	end 
	self.m_EffRecord[tostring(traceno)].isShow = true
	self.m_EffRecord[tostring(traceno)].id = -1
	g_SummonCtrl:SaveSummonEffRecord(self.m_EffRecord, true)
	g_SummonCtrl:OnEvent(define.Summon.Event.UpdateRedPoint)
end

function CSummonLAttrPageBox.SetPropertyInfo(self, item, summonId)
	self:SetRed(item, false)
	g_SummonCtrl:OnEvent(define.Summon.Event.UpdateRedPoint)
    g_SummonCtrl:OnEvent(define.Summon.Event.ChangeSummonShow, summonId) 
end

function CSummonLAttrPageBox.SetEmptyItem(self)
	g_SummonCtrl:OnEvent(define.Summon.Event.ChangeSummonShow, nil) 
end

function CSummonLAttrPageBox.OpenRenameWindow(self)
	local des = "[63432c]"..data.summondata.TEXT[self.m_ChangeNameHint_1].content.."[-]"
	local windowInputInfo = {
		des				= des,
		title			= "宠物改名",
		inputLimit		= 12,
		cancelCallback	= function ()
			
		end,
		defaultCallback = nil,
		okCallback		= function (input)
		 		local name = input:GetText()
				if input:GetInputLength() < 1 or input:GetInputLength() > 12 then 
					g_NotifyCtrl:FloatSummonMsg(self.m_ChangeNameHint_2)
					return
				end 
				if g_MaskWordCtrl:IsContainMaskWord(name) or string.isIllegal(name) == false then 
					g_NotifyCtrl:FloatSummonMsg(self.m_ChangeNameHint_3)
					return
				end
				g_SummonCtrl:ChangeName(self.m_CurSummonId, name)
				self.m_RenameView:OnClose()	
		end,
		isclose         = false,
		defaultText		= "请输入新的宠物名",
	}
	
	g_WindowTipCtrl:SetWindowInput(windowInputInfo, function (oView)
   		 self.m_RenameView = oView
	end)
	self:SetItemRedPoint(self.m_CurSummonId, false)
end

function CSummonLAttrPageBox.SetRed(self, item, show)
	if item == nil then
		return
	end
	if show then
		item.pic:AddEffect("RedDot", 20, Vector2(-15, -17))
	else
		item.pic:DelEffect("RedDot")
	end	
	if self.m_EffRecord[tostring(item.traceno)] == nil then
		self.m_EffRecord[tostring(item.traceno)] = {}
	end
	if self.m_EffRecord[tostring(item.traceno)].isShow == show then
		return
	end
	self.m_EffRecord[tostring(item.traceno)].isShow = show
	self.m_EffRecord[tostring(item.traceno)].id = item.id
	g_SummonCtrl:SaveSummonEffRecord(self.m_EffRecord, true)
end

function CSummonLAttrPageBox.SetFight(self, info, summonId)
	if info == 0 then
		self.m_SummonItems[summonId]["fight"]:SetActive(false)
		self.m_SummonIsCombat:SetActive(false)
	else
		for k,v in pairs(self.m_SummonItems) do
			v.fight:SetActive(false)
		end	
		self.m_SummonItems[summonId]["fight"]:SetActive(true)
		self.m_SummonIsCombat:SetActive(true)
		self:SetRed(self.m_SummonItems[summonId], false)
		g_SummonCtrl:OnEvent(define.Summon.Event.UpdateRedPoint)
	end 		
end

function CSummonLAttrPageBox.SetItemRedPoint(self, summonId, isShow)
	self:SetRed(self.m_SummonItems[summonId], isShow)
	g_SummonCtrl:OnEvent(define.Summon.Event.UpdateRedPoint)
end

return CSummonLAttrPageBox