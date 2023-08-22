local CSummonRStudySkillPageBox = class("CSummonRStudySkillPageBox", CBox)

-- 废弃脚本
function CSummonRStudySkillPageBox.ctor(self, obj, part)
	CBox.ctor(self, obj)
	self.m_Part = part
	self.m_SkillUpToolItemId = 10032 --技能升级物品ID
	self.m_StudyToolDesId = 2004
	self.m_StudyDesId = 2005
	self.m_SkillUpHintId = 1041
	self.m_CurUpSkill = {}	
	self:InitContent()	
end

function CSummonRStudySkillPageBox.InitContent(self)
    self.m_StudyAddSkillBtn = self:NewUI(1, CButton)
	self.m_StudyDesBtn = self:NewUI(2, CButton)
	self.m_StudySkillBtn = self:NewUI(3, CButton)
	self.m_SkillItemGird = self:NewUI(4, CGrid)
	self.m_SkillItem = self:NewUI(5, CBox)
	self.m_StudyToolPic = self:NewUI(6, CSprite)
    self.m_StudyToolName = self:NewUI(7, CLabel)
    self.m_StudyToolCount = self:NewUI(8, CLabel)
    self.m_StudyToolDesBtn = self:NewUI(9, CButton) 
    self.m_StudySkillUpgrade = self:NewUI(10, CButton)
    self.m_StudySkillIcon = self:NewUI(11, CSprite)
    self.m_StudySkillDown = self:NewUI(12, CBox)
    self.m_StudySkillName = self:NewUI(13, CLabel)
	self.m_SkillBookPage = self:NewUI(14, CBox)	
	self.m_StudySkillDownOldName = self.m_StudySkillDown:NewUI(1, CLabel)
    self.m_StudySkillDownOldDes = self.m_StudySkillDown:NewUI(2, CLabel)
    self.m_StudySkillDownNewName = self.m_StudySkillDown:NewUI(3, CLabel)
    self.m_StudySkillDownNewDes = self.m_StudySkillDown:NewUI(4, CLabel)
	self.m_StudyToolDesBtn:AddUIEvent("click",function ()
		local zContent = {title = "升级技能",desc = data.summondata.TEXT[self.m_StudyToolDesId].content}
    	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
	end)
	self.m_StudyDesBtn:AddUIEvent("click",function ()
		local zContent = {title = "技能学习",desc = data.summondata.TEXT[self.m_StudyDesId].content}
    	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
	end)
	self:InitSkillBookContent()
	self.m_StudyAddSkillBtn:AddUIEvent("click", callback(self, "OnAddSkill"))
	self.m_StudySkillBtn:AddUIEvent("click", callback(self, "OnStudySkillBtn"))
	self.m_StudySkillUpgrade:AddUIEvent("click", callback(self, "OnStudySkillUpGrade"))
	g_SummonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CSummonRStudySkillPageBox.InitSkillBookContent(self)
	self.m_StudyAddSkillGrid = self.m_SkillBookPage:NewUI(1, CGrid)
	self.m_StudyAddSkillItem = self.m_SkillBookPage:NewUI(2, CBox)
	self.m_StudyAddSkillHint = self.m_SkillBookPage:NewUI(3, CLabel)	
	self.m_StudyAddSkillCloseBtn = self.m_SkillBookPage:NewUI(4, CButton)
    self.m_StudyAddSkillCloseBtn:AddUIEvent("click", callback(self, "OnCloseStudySkillPage"))
	self:InitSkillBook()
	self.m_SkillBookPage:SetActive(false)
end

--初始化技能书
function CSummonRStudySkillPageBox.InitSkillBook(self)
	self.m_Count = 0
	self.m_StudyAddSkillHint:SetActive(true)
	for k,c in pairs(data.itemsummskilldata.SUMMSKILL) do	
		for j,v in pairs(g_ItemCtrl:GetBagItemListBySid(k)) do
			self.m_StudyAddSkillHint:SetActive(false)
			self.m_Count = self.m_Count + 1
			local item = self.m_StudyAddSkillGrid:GetChild(self.m_Count)
			if item then
				self:UpdateBookItem(item, v)
			else
				self:AddBookItem(v)
			end	
		end
	end
	for i = self.m_Count + 1, self.m_StudyAddSkillGrid:GetCount() do
		self.m_StudyAddSkillGrid:RemoveChild(self.m_StudyAddSkillGrid:GetChild(i))
	end
end

function CSummonRStudySkillPageBox.AddBookItem(self, v)
	local item = self.m_StudyAddSkillItem:Clone("Item")
	item:SetActive(true)
	item.pic = item:NewUI(1, CSprite)
	item.pic:SpriteItemShape(v:GetCValueByKey("icon"))
	item.name = item:NewUI(2, CLabel)
	item.name:SetText(v:GetItemName())
	item:AddUIEvent("click",callback(self,"OnSelectSkill",v))
	item:SetGroup(self.m_StudyAddSkillGrid:GetInstanceID())
	self.m_StudyAddSkillGrid:AddChild(item)
end

function CSummonRStudySkillPageBox.UpdateBookItem(self, item, v)
	item:SetActive(true)
	item.pic:SpriteItemShape(v:GetCValueByKey("icon"))
	item.name:SetText(v:GetItemName())
	item:AddUIEvent("click",callback(self,"OnSelectSkill",v))
end

function CSummonRStudySkillPageBox.OnSelectSkill(self, info)
	self.m_CurSkillData = info
	self.m_StudySkillBtn:SetEnabled(true)
	self.m_StudySkillBtn:SetSpriteName("h7_an_3")
	self.m_StudySkillBtn:SetText("[bd5733]学习[-]")
	self.m_StudySkillName:SetText(info:GetItemName())
	self.m_StudySkillIcon:SetActive(true)
	self.m_StudySkillIcon:SpriteItemShape(info:GetCValueByKey("icon"))
end

--关闭技能书列表
function CSummonRStudySkillPageBox.OnCloseStudySkillPage(self)
	self.m_SkillBookPage:SetActive(false)
    local summid = g_SummonCtrl:GetCurSelSummon()
	self.m_Part.m_LAttPage:SetActive(true)
	self.m_Part.m_LAttPage:SetInfo(summid)
end

function CSummonRStudySkillPageBox.ShowPageChange(self)
	self.m_SkillBookPage:SetActive(not self.m_Part.m_LAttPage:GetActive())
	self.m_StudySkillIcon:SetActive(false)
	self.m_StudySkillBtn:SetSpriteName("h7_an_1")
	self.m_StudySkillBtn:SetText("[eefffb]学习[-]")
	self.m_CurSkillData = nil
end

function CSummonRStudySkillPageBox.SetInfo(self, summonId)
	self:ShowPageChange()	
	if summonId == self.m_CurSummonId then
		self:InitSkillGrid(summonId)	
		return
	end
	self.m_CurUpidx = nil
	self.m_CurSummonId = summonId
	self.m_Part.m_LAttPage:SetInfo(summonId)
	local item = DataTools.GetItemData(self.m_SkillUpToolItemId)
	self.m_StudyToolName:SetText(item.name)
	self.m_StudyToolPic:SpriteItemShape(item.icon)
    self.m_StudyToolPic:AddUIEvent("click", function ()
		-- local config = {widget = self.m_StudyToolPic}
		-- g_WindowTipCtrl:SetWindowItemTip(self.m_SkillUpToolItemId, config)
		g_WindowTipCtrl:SetWindowGainItemTip(self.m_SkillUpToolItemId)
	end)		
	self.m_StudySkillName:SetText("请选择\n技能书")
	self.m_CurSkillData = nil
	--self.m_StudySkillBtn:SetEnabled(false)
	self.m_StudySkillBtn:SetSpriteName("h7_an_1")
	self.m_StudySkillBtn:SetText("[eefffb]学习[-]")
	self.m_StudySkillIcon:SetActive(false)
	self:InitSkillGrid(summonId) 
end

function CSummonRStudySkillPageBox.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Summon.Event.BagItemUpdate and self.m_CurSummonId then
		self:UpdateSkillTools()
		self:InitSkillBook()
    end 	
end

--初始化技能列表
function CSummonRStudySkillPageBox.InitSkillGrid(self, summonId)
	local i = 1
	local child = nil
	local sum = g_SummonCtrl:GetSummon(summonId)
	local  dp = sum.skill
	local sumid = sum.typeid

	local function UpdateItem(item, v, k)			
		item.icon:SpriteAdvancedSkill(data.summondata.SKILL[v.sk].iconlv, v.level)
		item.icon:SetActive(true)
		item.level:SetText(v["level"].."级")
		item.level:SetActive(true)
		item.frame:SetSpriteName(g_SummonCtrl.m_FrameList[v["level"]])
		item.frame:SetActive(true)
		local sure = g_SummonCtrl:IsSureSkill(sumid, v.sk)
		item.sureSpr:SetActive(sure or false)
		item:AddUIEvent("click",callback(self, "OnSkillItem", k))
		item:SetGroup(self.m_SkillItemGird:GetInstanceID())
		item:SetActive(true)
	end
	for k,v in pairs(dp) do
		child = self.m_SkillItemGird:GetChild(i)
		if child ~= nil then 
			UpdateItem(child, v, k)
		else	
			local item = self.m_SkillItem:Clone("Item")
			item.icon = item:NewUI(1, CSprite)	
			item.level = item:NewUI(2, CLabel)
			item.frame = item:NewUI(3, CSprite)
			item.sureSpr = item:NewUI(4, CSprite)
			UpdateItem(item, v, k)
			self.m_SkillItemGird:AddChild(item) 		
		end
		i = i + 1
	end
	if self.m_SkillItemGird:GetChild(i) ~= nil then 
		for k,v in pairs(self.m_SkillItemGird:GetChildList()) do
			if k >= i then 
				v.icon:SetActive(false)
				v.frame:SetActive(false)
				v.level:SetActive(false)
				v.sureSpr:SetActive(false)
				v:AddUIEvent("click",function ()	
					self.m_CurUpSkillSk = nil
				end)
			end
		end
	end
	local function AddEmptyItem()
		local item = self.m_SkillItem:Clone("Item")
		item.icon = item:NewUI(1,CSprite)
		item.level = item:NewUI(2,CLabel)
		item.frame = item:NewUI(3,CSprite)
		item.sureSpr = item:NewUI(4, CSprite)
		item.frame:SetActive(false)
		item.level:SetActive(false)		
		item.icon:SetActive(false)
		item.sureSpr:SetActive(false)
		item:AddUIEvent("click",function ()	
			self.m_CurUpSkillSk = nil
		end)
		item:SetGroup(self.m_SkillItemGird:GetInstanceID())
		item:SetActive(true)
		self.m_SkillItemGird:AddChild(item) 
	end
	for j=self.m_SkillItemGird:GetCount()+1, g_SummonCtrl.m_SummonSkillMax do
		 AddEmptyItem()
	end 
	if self.m_CurUpidx == nil then		
 		self.m_CurUpidx = 1	 
 	end
 	self.m_SkillItemGird:GetChild(self.m_CurUpidx):SetSelected(true)
 	self:OnSkillItem(self.m_CurUpidx)
end

function CSummonRStudySkillPageBox.UpdateSkillTools(self, cost)
	local count = g_ItemCtrl:GetBagItemAmountBySid(self.m_SkillUpToolItemId)
	local text = count >=self.m_StudySkillConsume and 
	string.format("[1D8E00]%s/%s[-]",count, self.m_StudySkillConsume) or 
	string.format("[D71420]%s/%s[-]", count, self.m_StudySkillConsume)
    self.m_StudyToolCount:SetText(text)
end

function CSummonRStudySkillPageBox.OnSkillItem(self, idx)
	local  summon = g_SummonCtrl:GetSummon(self.m_CurSummonId)	
	local dp = summon.skill[idx]
	if dp == nil then
		self:SkillEmptyShow()
		return
	end
	self.m_CurUpSkillSk = dp.sk
	self.m_CurUpidx = idx
	self.m_StudySkillConsume = dp.cost
	self:UpdateSkillTools()
    self.m_StudySkillDownOldName:SetActive(true)
    self.m_StudySkillDownOldDes:SetActive(true)
    self.m_StudySkillDownNewName:SetActive(true)
    self.m_StudySkillDownNewDes:SetActive(true)
    self:ShowDes(dp)
end

function CSummonRStudySkillPageBox.ShowDes(self, dp)
	local skillData = data.summondata.SKILL[dp.sk]
    local des = skillData.des
	local oldDes = self:FormulaCaculate(des, dp, dp.level)
	self.m_StudySkillDownOldName:SetText(skillData.name.." 等级: "..dp.level)
    self.m_StudySkillDownOldDes:SetText(oldDes)
    if data.summondata.SKILLCOST[dp.level+1] ~= nil then
		local newDes = self:FormulaCaculate(des, dp, dp.level+1)
		self.m_StudySkillDownNewDes:SetText(newDes)
		self.m_StudySkillDownNewName:SetText(skillData.name.." 等级: "..dp.level+1)
	else
		self.m_StudySkillDownNewName:SetActive(false)
		self.m_StudySkillDownNewDes:SetText("当前技能已经满级啦")
	end
end

function CSummonRStudySkillPageBox.FormulaCaculate(self, des, dp, level)
	local formula1 = string.gsub(data.summondata.SKILL[dp.sk].formula1, "level", level)
	local formula2 = string.gsub(data.summondata.SKILL[dp.sk].formula2, "level", level) 
    local f1 = loadstring("return "..formula1)
	local f2 = loadstring("return "..formula2) 
	local newDes = des
    if f1 then
		newDes = string.gsub(newDes, "#1", math.floor(f1())) 
    end
	if f2 then 
		newDes = string.gsub(newDes, "#2", math.floor(f2())) 
    end
	return newDes
end

function CSummonRStudySkillPageBox.SkillEmptyShow(self)
	self.m_StudySkillDownNewName:SetActive(false)
    self.m_StudySkillDownNewDes:SetActive(false)
	self.m_StudySkillDownOldName:SetActive(false)
	self.m_StudySkillDownOldDes:SetActive(true)
	self.m_StudySkillDownOldDes:SetText("当前还没有技能哦！")
	self.m_StudySkillConsume = 0
	self:UpdateSkillTools()
end

--学习技能
function CSummonRStudySkillPageBox.OnStudySkillBtn(self)
	if self.m_CurSkillData then
		-- 废弃脚本
		g_SummonCtrl:StudySkill(self.m_CurSummonId, self.m_CurSkillData.m_SData.id)
	else
		g_NotifyCtrl:FloatMsg("请选择技能！")	
	end 
	--self.m_StudySkillBtn:SetEnabled(false)
	self.m_StudySkillBtn:SetSpriteName("h7_an_1")
	self.m_StudySkillBtn:SetText("[eefffb]学习[-]")
	self.m_StudySkillName:SetText("请选择\n技能书")
	self.m_StudySkillIcon:SetActive(false)
	self.m_CurSkillData = nil
end

--添加学习技能
function CSummonRStudySkillPageBox.OnAddSkill(self)
	if self.m_CurSkillData ~= nil then 	
		local config = {widget = self.m_StudySkillIcon}
		g_WindowTipCtrl:SetWindowItemTip(self.m_CurSkillData:GetCValueByKey("id"), config)
		return
	end
	self.m_SkillBookPage:SetActive(true)
	self.m_Part.m_LAttPage:SetActive(false)
	self:InitSkillBook()
end

--升级技能
function CSummonRStudySkillPageBox.OnStudySkillUpGrade(self)
	if self.m_CurUpSkillSk == nil then 
		g_NotifyCtrl:FloatSummonMsg(self.m_SkillUpHintId)
		return
	end
	self:JudgeItemList()
	g_SummonCtrl:StudySkillUpGrade(self.m_CurSummonId, self.m_CurUpSkillSk)
end

function CSummonRStudySkillPageBox.JudgeItemList(self)
	local iSum = g_ItemCtrl:GetBagItemAmountBySid(self.m_SkillUpToolItemId)
	local itemlist = {}
	if iSum < self.m_StudySkillConsume then
		local t = {sid = self.m_SkillUpToolItemId, count = iSum,amount = self.m_StudySkillConsume  }
		table.insert(itemlist, t)
	end
	g_QuickGetCtrl:CurrLackItemInfo(itemlist, {})
end

return CSummonRStudySkillPageBox