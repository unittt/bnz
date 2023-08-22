local CHorseTongYuOpPart = class("CHorseTongYuOpPart", CPageBase)

function CHorseTongYuOpPart.ctor(self, obj)

	CPageBase.ctor(self, obj)
	self.m_SelId = nil

end

function CHorseTongYuOpPart.OnInitPage(self)

	self.m_HorseItem = self:NewUI(1, CBox)
	self.m_ItemGrid = self:NewUI(2, CGrid)
	self.m_PetItem = self:NewUI(3, CBox)
	self.m_PetItemGrid = self:NewUI(4, CGrid)
	self.m_Name = self:NewUI(5, CLabel)
	self.m_Time = self:NewUI(6, CLabel)
	self.m_HorseIcon = self:NewUI(7, CSprite)
	self.m_TongYuItem = self:NewUI(8, CBox)
	self.m_TongYuItemGrid = self:NewUI(9, CGrid)
	self.m_TongYuBtn = self:NewUI(10, CSprite)
	self.m_WenShiSkill = self:NewUI(11, CBox)
	self.m_Tip = self:NewUI(12, CSprite)
	self.m_ScrollView = self:NewUI(13, CScrollView)

	self.m_TongYuItemList = {}

	self:InitContent()

end

function CHorseTongYuOpPart.InitContent(self)

	-- g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnRefreshItem"))
	g_HorseCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_SummonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnSummonEvent"))
	
	self.m_TongYuBtn:AddUIEvent("click", callback(self, "OnClicTongYuBtn"))
	self.m_Tip:AddUIEvent("click", callback(self, "OnClickTipBtn"))

	self:InitTongYuItemList()

	self:RefreshRideItems()

	self:RefreshPetItems()

end


function CHorseTongYuOpPart.OnShowPage(self)

	self:RefreshRideItemSel()

end

function CHorseTongYuOpPart.SetData(self, rideId)
	
	local data = data.ridedata.RIDEINFO[rideId]
	if data then
		g_WenShiCtrl:SetCurRideId(rideId) 
		self.m_SelData = data 
		self:RefreshRideItemSel()
		self:RefreshPetItemSel()
		self:RefreshTongYuSel()
		self:RefreshAll()
	end 

end

function CHorseTongYuOpPart.RefreshRideItemSel(self)
	
	local rideId = g_WenShiCtrl:GetCurRideId()
	if rideId then 
		local itemList = self.m_ItemGrid:GetChildList()
		for k, item in ipairs(itemList) do 
			if item.horseData.id == rideId then 
				item.boxCollider:ForceSelected(true)
				self:OnClickHorseItem(item.horseData)
				self.m_ItemGrid:Reposition()
				self.m_ScrollView:ResetPosition()
				UITools.MoveToTarget(self.m_ScrollView, item)
				g_WenShiCtrl:SetCurRideId(rideId)
				self.m_ScrollView:RestrictWithinBounds(true)
				break
			end  
		end 
	else
		local firstHorseItem = self.m_ItemGrid:GetChild(1)
		if firstHorseItem then 
			firstHorseItem.boxCollider:ForceSelected(true)
			self:SetData(firstHorseItem.horseData.id)
		end 
	end 

end

--刷新宠物选择
function CHorseTongYuOpPart.RefreshPetItemSel(self)
	
	if not self.m_SelData then
		return
	end 

	local list =  self.m_PetItemGrid:GetChildList()
	for k, item in ipairs(list) do 
		item.boxCollider:ForceSelected(true)
		self.m_SelPetId = item.id
		break
	end 

end

--刷新统御宠物选择
function CHorseTongYuOpPart.RefreshTongYuSel(self)
	
	if not self.m_SelData then
		return
	end 

	local list =  self.m_TongYuItemList
	local lItem = list[1]
	local rItem = list[2]
	local lid = lItem.id
	local rid = rItem.id
	if (lid and rid) or ((not lid) and (not rid)) then 
		lItem.boxCollider:ForceSelected(true)
		self.m_SelTongYuPos = lItem.pos
	else
		if not lid then 
			lItem.boxCollider:ForceSelected(true)
			self.m_SelTongYuPos = lItem.pos
		elseif not rid then 
			rItem.boxCollider:ForceSelected(true)
			self.m_SelTongYuPos = rItem.pos
		end 
	end  

end


function CHorseTongYuOpPart.ForceSelectTongYuSummon(self, pos)
	
	local tongyuItem =  self.m_TongYuItemList[pos]
	if tongyuItem then 
		tongyuItem.boxCollider:ForceSelected(true)
		self.m_SelTongYuPos = pos
	end 
	
end

function CHorseTongYuOpPart.InitRideItem(self, oItem)

	oItem.icon = oItem:NewUI(1, CSprite)
	oItem.boxCollider = oItem:NewUI(2, CWidget)
	oItem.time = oItem:NewUI(3, CLabel)
	oItem.name = oItem:NewUI(4, CLabel)
	oItem.flag = oItem:NewUI(5, CSprite)
	oItem.lv = oItem:NewUI(6, CLabel)
	oItem.cname = oItem:NewUI(7, CLabel)
	return oItem

end

function CHorseTongYuOpPart.InitPetItem(self, oItem)
	
	oItem.icon = oItem:NewUI(1, CSprite)
	oItem.boxCollider = oItem:NewUI(2, CWidget)
	oItem.tongyu = oItem:NewUI(3, CLabel)
	oItem.name = oItem:NewUI(4, CLabel)
	oItem.grade = oItem:NewUI(5, CLabel)
	oItem.cname = oItem:NewUI(6, CLabel)
	return oItem

end

function CHorseTongYuOpPart.InitTongYuItemList(self)
	
	for i = 1, 2 do 
		local item = self.m_TongYuItem:Clone()
		item:SetActive(true)
		self.m_TongYuItemGrid:AddChild(item)
		item = self:InitTongYuItem(item)
		item.pos = i
		self.m_TongYuItemList[i] = item
	end

end

function CHorseTongYuOpPart.InitTongYuItem(self, oItem)
	
	oItem.icon = oItem:NewUI(1, CSprite)
	oItem.resetBtn = oItem:NewUI(2, CSprite)
	oItem.name = oItem:NewUI(3, CLabel)
	oItem.boxCollider = oItem:NewUI(4, CWidget)
	oItem.lv = oItem:NewUI(5, CLabel)
	oItem.resetBtn:AddUIEvent("click", callback(self, "OnClickTongYuItemReset", oItem))
	oItem.boxCollider:AddUIEvent("click", callback(self, "OnClickTongYuItem", oItem))
	return oItem

end


function CHorseTongYuOpPart.RefreshAll(self)

	self:RefreshRideItems()
	self:RefreshPetItems()
	if self.m_SelData then 
		self:RefreshName()
		self:RefreshTime()
		self:RefreshHorseIcon()
		self:RefreshTongYuItems()
		self:RefreshTongYuSel()
		self:RefreshWenShiSkillItem()
	end 

end

--刷新统御项
function CHorseTongYuOpPart.RefreshTongYuItems(self)
	
	if not self.m_SelData then 
		return
	end 

	local petList = g_HorseCtrl:GetRideTongYuPetList(self.m_SelData.id)

	for pos, item in ipairs(self.m_TongYuItemList) do 
		local data = petList[pos]
		self:RefreshTongYuItem(item, data)
	end 

end

function CHorseTongYuOpPart.RefreshTongYuItem(self, oItem, data)
	
	if data then 
		oItem.icon:SetActive(true)
		oItem.resetBtn:SetActive(true)
		oItem.name:SetActive(true)
		oItem.lv:SetActive(true)
		oItem.id = data.id
		oItem.name:SetText(data.name)
		oItem.icon:SetSpriteName(data.icon)
		oItem.lv:SetText(data.lv .. "级")
	else
		oItem.icon:SetActive(false)
		oItem.resetBtn:SetActive(false)
		oItem.name:SetActive(false)
		oItem.lv:SetActive(false)
		oItem.id = nil
	end 

end

function CHorseTongYuOpPart.RefreshModel(self)

	if not self.m_SelData then 
		return
	end 
	
	local model_info =  table.copy(g_AttrCtrl.model_info)
 	model_info.rendertexSize = 1.8
 	model_info.horse = self.m_SelData.id
 	self.m_HorseTexture:ChangeShape(model_info)

end


function CHorseTongYuOpPart.OnClickWenShiSkill(self)
	
	local wenshiSkill = self.m_WenShiSkill.info
	if wenshiSkill then
		CWenShiSkillTipView:ShowView(function ( oView )
			oView:SetInfo(wenshiSkill)
		end)
	end

end

--刷技能
function CHorseTongYuOpPart.RefreshWenShiSkillItem(self)
	
	if not self.m_SelData then 
		return
	end 

	self.m_WenShiSkill.icon = self.m_WenShiSkill:NewUI(1, CSprite)
	self.m_WenShiSkill.flag = self.m_WenShiSkill:NewUI(2, CSprite)
	self.m_WenShiSkill.collider = self.m_WenShiSkill:NewUI(3, CWidget)
	self.m_WenShiSkill.collider:AddUIEvent("click", callback(self, "OnClickWenShiSkill", self.m_WenShiSkill))
	self.m_WenShiSkill.info = nil

	local id = self.m_SelData.id
	local wenshiSkill = g_WenShiCtrl:GetWenShiSkill(id)
	if wenshiSkill then
		self.m_WenShiSkill.info = wenshiSkill
		local icon = wenshiSkill.icon
		self.m_WenShiSkill.icon:SpriteSkill(icon) 
		self.m_WenShiSkill.icon:SetActive(true)
		local invalid = wenshiSkill.invalid
		local count = g_WenShiCtrl:GetHorseWenShiCount(id)
		if count == 3 then 
			if invalid then 
				self.m_WenShiSkill.flag:SetActive(true)
				self.m_WenShiSkill.icon:SetGrey(true)
			else
				self.m_WenShiSkill.flag:SetActive(false)
				self.m_WenShiSkill.icon:SetGrey(false)
			end 
		else
			self.m_WenShiSkill.flag:SetActive(true)
			self.m_WenShiSkill.icon:SetGrey(true)
		end 
	else
		self.m_WenShiSkill.icon:SetActive(false)
		self.m_WenShiSkill.flag:SetActive(false)
	end 

end

function CHorseTongYuOpPart.RefreshRideItems(self)
	
	local horseIdList = g_HorseCtrl:GetHorseSortId()
	for k, horseId in ipairs(horseIdList) do
		local item = self.m_ItemGrid:GetChild(k)
		if item == nil then
			item = self.m_HorseItem:Clone()	
			item:SetActive(true)
			item = self:InitRideItem(item)
			self.m_ItemGrid:AddChild(item)	
		end
		local horseData = data.ridedata.RIDEINFO[horseId]
		item.id = horseId
		item.icon:SetSpriteName(horseData.shape)
		item.boxCollider:AddUIEvent("click", callback(self, "OnClickHorseItem", horseData))
		item.name:SetText(horseData.name)
		item.cname:SetText(horseData.name)
		self:RefreshRideItemTime(item)
		item.horseData = horseData
		item.flag:SetActive(horseId == g_HorseCtrl.use_ride)
		item:SetActive(true)
	end

end

function CHorseTongYuOpPart.RefreshRideItemTime(self, oItem)

	local id = oItem.id
	local horseData = g_HorseCtrl:GetHorseById(id)

	local leftTime = horseData.left_time

	if leftTime == -1 then 
	    g_TimeCtrl:DelTimer(oItem)
	    oItem.time:SetText("剩余时间:永久")
	else
	    local cb = function (time)
	        if not time then 
	            oItem.time:SetText("剩余时间:过期")
	        else
	            oItem.time:SetText("剩余时间:" .. time)
	        end 
	    end
	    g_TimeCtrl:StartCountDown(oItem, leftTime, 3, cb)

	end

end


--刷新宠物列表
function CHorseTongYuOpPart.RefreshPetItems(self)
	
	 local summonList = g_SummonCtrl.m_SummonsSort

	for k, info in ipairs(summonList) do
		local item = self.m_PetItemGrid:GetChild(k)
		if item == nil then
			item = self.m_PetItem:Clone()	
			item:SetActive(true)
			item = self:InitPetItem(item)
			self.m_PetItemGrid:AddChild(item)	
		end
		--local horseData = data.ridedata.RIDEINFO[horseId]
		item.id = info.id
		item.icon:SetSpriteName(info.model_info.shape)
		item.boxCollider:AddUIEvent("click", callback(self, "OnClickPetItem", item))
		item.name:SetText(info.name)
		item.cname:SetText(info.name)
		item.grade:SetText(info.grade .. "级")

		local rideId = g_SummonCtrl:GetSummonBindRideId(info.id)
		if rideId and rideId ~= 0 then 
			local horseData = data.ridedata.RIDEINFO[rideId]
			if horseData then 
				item.tongyu:SetText(horseData.name)
				item.tongyu:SetActive(true)
			end 
		else
			item.tongyu:SetText("未统御")
			item.tongyu:SetActive(true)
		end 

		item:SetActive(true)
	end

end

function CHorseTongYuOpPart.OnClickPetItem(self, oItem)
	
	local id = oItem.id
	self.m_SelPetId = id
	
end

function CHorseTongYuOpPart.OnClickHorseItem(self, data)
	
	self.m_SelData = data
	self:RefreshAll()
	g_WenShiCtrl:SetCurRideId(data.id)

end


function CHorseTongYuOpPart.OnClickTongYuItemReset(self, oItem)
	
	local pos = oItem.pos
	local rideid = self.m_SelData.id
	g_HorseCtrl:C2GSUnControlSummon(rideid, pos)

end

function CHorseTongYuOpPart.OnClickTongYuItem(self, oItem)
	
	local pos = oItem.pos
	local id = oItem.id
	self.m_SelTongYuPos = pos

	
end

function CHorseTongYuOpPart.OnClicTongYuBtn(self)
	
	if not self.m_SelPetId then 
		return
	end 

	if not self.m_SelTongYuPos then 
		return
	end 

	local rideid = self.m_SelData.id
	local petId = self.m_SelPetId
	local pos = self.m_SelTongYuPos

	g_HorseCtrl:C2GSControlSummon(rideid, petId, pos)

end

function CHorseTongYuOpPart.RefreshTime(self)
	
	local horseId = self.m_SelData.id
 
	self.m_Time:SetActive(true)

	local horse = g_HorseCtrl:GetHorseById(horseId)

	if not horse then 
		return
	end

	if  horse.left_time == -1 then 
	    g_TimeCtrl:DelTimer(self)
	    self.m_Time:SetText("[244B4EFF]剩余时间:[-][a64e00]永久[-]")
	else
	    local cb = function (time)
	        if not time then 
	            self.m_Time:SetText("[244B4EFF]剩余时间:[-][a64e00]过期[-]")
	        else
	            self.m_Time:SetText("[244B4EFF]剩余时间:[-][a64e00]" .. time .. "[-]")
	        end 
	    end
	    g_TimeCtrl:StartCountDown(self, horse.left_time, 1, cb)

	end

end

function CHorseTongYuOpPart.RefreshName(self)
	
	local name = self.m_SelData.name
	self.m_Name:SetText(name)

end

function CHorseTongYuOpPart.RefreshHorseIcon(self)
	
	local shape = self.m_SelData.shape
	self.m_HorseIcon:SetSpriteName(shape)

end

function CHorseTongYuOpPart.OnCtrlEvent(self, oCtrl)
	
	if oCtrl.m_EventID == define.Horse.Event.UpdateRideInfo then
		self:RefreshAll()
	end
 
end

function CHorseTongYuOpPart.OnSummonEvent(self, oCtrl)
	
	if oCtrl.m_EventID == define.Summon.Event.UpdateSummonInfo then
		self:RefreshAll()
	end

end

function CHorseTongYuOpPart.OnClickTipBtn(self)
	
	local desInfo = data.instructiondata.DESC[10061]
	if desInfo then 
		local zContent = {title = desInfo.title, desc = desInfo.desc}
		g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
	end 

end

return CHorseTongYuOpPart