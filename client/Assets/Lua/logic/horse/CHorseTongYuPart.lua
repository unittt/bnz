local CHorseTongYuPart = class("CHorseTongYuPart", CPageBase)

function CHorseTongYuPart.ctor(self, obj)

	CPageBase.ctor(self, obj)
	self.m_SelId = nil

end

function CHorseTongYuPart.OnInitPage(self)

	self.m_HorseItem = self:NewUI(1, CBox)
	self.m_ItemGrid = self:NewUI(2, CGrid)
	self.m_HorseTexture = self:NewUI(3, CActorTexture)
	self.m_Name = self:NewUI(4, CLabel)
	self.m_Time = self:NewUI(5, CLabel)
	--self.m_TongYuPetTip = self:NewUI(6, CSprite)
	self.m_PetItemL = self:NewUI(7, CBox)
	self.m_PetItemR = self:NewUI(8, CBox)
	self.m_WenShi1 = self:NewUI(9, CBox)
	self.m_WenShi2 = self:NewUI(10, CBox)
	self.m_WenShi3 = self:NewUI(11, CBox)
	self.m_AttrGrid = self:NewUI(12, CGrid)
	self.m_Attr = self:NewUI(13, CBox)
	self.m_WenShiSkill = self:NewUI(14, CBox)
	self.m_SkillCheckBtn = self:NewUI(15, CSprite)
	self.m_AddTimeBtn = self:NewUI(16, CButton)
	self.m_AttrTipText = self:NewUI(17, CLabel)
	self.m_ScrollView = self:NewUI(18, CScrollView)

	self:InitContent()

end

function CHorseTongYuPart.InitContent(self)

	-- g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnRefreshItem"))
	g_HorseCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnHorseEvent"))
	
	self.m_SkillCheckBtn:AddUIEvent("click", callback(self, "OnClickSkillCheckBtn"))

	self.m_AddTimeBtn:AddUIEvent("click", callback(self, "OnClickAddTimeBtn"))

	--self.m_TongYuPetTip:AddUIEvent("click", callback(self, "OnClickTipBtn"))

	self:InitAllTongYuItem()
	self:InitAllWenShiItem()

	--刷新坐骑选择栏
	self:RefreshRideItem()


end

function CHorseTongYuPart.OnShowPage(self)

	local rideId = g_HorseCtrl:GetCurSelHorseId()
	if rideId then 
		local itemList = self.m_ItemGrid:GetChildList()
		for k, item in ipairs(itemList) do 
			if item.horseData.id == rideId then 
				item.boxCollider:ForceSelected(true)
				self:OnClickHorseItem(item.horseData)
				g_HorseCtrl:SetCurSelHorseId(rideId)
				self:RefreshRideItem()
				self.m_ItemGrid:Reposition()
				self.m_ScrollView:ResetPosition()
				UITools.MoveToTarget(self.m_ScrollView, item)
				self.m_ScrollView:RestrictWithinBounds(true)
				break
			end 
		end 
	else
		local firstHorseItem = self.m_ItemGrid:GetChild(1)
		if firstHorseItem then 
			firstHorseItem.boxCollider:ForceSelected(true)
			self:OnClickHorseItem(firstHorseItem.horseData)
		end 
	end 
end

--初始所有统御宠物项
function CHorseTongYuPart.InitAllTongYuItem(self)
	
	self.m_PetItemL = self:InitTongYuItem(self.m_PetItemL)
	self.m_PetItemR = self:InitTongYuItem(self.m_PetItemR)

end

--初始所有纹饰项
function CHorseTongYuPart.InitAllWenShiItem(self)
	
	self.m_WenShi1 = self:InitWenShiItem(self.m_WenShi1)
	self.m_WenShi2 = self:InitWenShiItem(self.m_WenShi2)
	self.m_WenShi3 = self:InitWenShiItem(self.m_WenShi3)
	self.m_WenShi1.pos = 1
	self.m_WenShi2.pos = 2
	self.m_WenShi3.pos = 3
	self.m_WenShiItemList = {}
	table.insert(self.m_WenShiItemList, self.m_WenShi1)
	table.insert(self.m_WenShiItemList, self.m_WenShi2)
	table.insert(self.m_WenShiItemList, self.m_WenShi3)

end

function CHorseTongYuPart.InitRideItem(self, oItem)

	oItem.icon = oItem:NewUI(1, CSprite)
	oItem.boxCollider = oItem:NewUI(2, CWidget)
	oItem.flag = oItem:NewUI(3, CWidget)
	oItem.lv = oItem:NewUI(4, CLabel)
	return oItem

end

function CHorseTongYuPart.InitWenShiItem(self, oItem)
	
	oItem.icon = oItem:NewUI(1, CSprite)
	oItem.lv = oItem:NewUI(2, CLabel)
	oItem.boxCollider = oItem:NewUI(3, CWidget)
	oItem.addIcon = oItem:NewUI(4, CSprite)
	oItem.flag = oItem:NewUI(5, CSprite)
	oItem.boxCollider:AddUIEvent("click", callback(self, "OnClickWenShiItem", oItem))
	return oItem

end

function CHorseTongYuPart.InitTongYuItem(self, oItem)
	
	oItem.icon = oItem:NewUI(1, CSprite)
	oItem.lv = oItem:NewUI(2, CLabel)
	oItem.boxCollider = oItem:NewUI(3, CWidget)
	oItem.flag = oItem:NewUI(4, CSprite)
	oItem.boxCollider:AddUIEvent("click", callback(self, "OnClickTongYuItem", oItem))
	return oItem

end

function CHorseTongYuPart.ShowPage(self)
	
	CPageBase.ShowPage(self)
	self:ClearSelectEffect()

end

function CHorseTongYuPart.ClearSelectEffect(self)
	
	if not self.m_SelData then 
		return
	end 

	for k, v in ipairs(self.m_WenShiItemList) do 
		v.boxCollider:ForceSelected(false)
	end 

	self.m_PetItemL.boxCollider:ForceSelected(false)
	self.m_PetItemR.boxCollider:ForceSelected(false)

end

--刷新所有
function CHorseTongYuPart.RefreshAll(self)
	
	if self.m_SelData then 
		self:RefreshRideItem()
		self:RefreshModel()
		self:RefreshName()
		self:RefreshTime()
		self:RefreshTongYuSummons()
		self:RefreshWenShi()
		self:RefreshAttr()
		self:RefreshWenShiSkillItem()
	end 

end

function CHorseTongYuPart.RefreshModel(self)

	if not self.m_SelData then 
		return
	end 
	
	local model_info =  table.copy(g_AttrCtrl.model_info)
 	model_info.rendertexSize = 1.8
 	model_info.horse = self.m_SelData.id
 	if g_HorseCtrl.use_ride ~= self.m_SelData.id then 
 		model_info.shape = nil
 		model_info.show_wing = nil
 		model_info.follow_spirit = nil
 	end  
 	self.m_HorseTexture:ChangeShape(model_info)

end

function CHorseTongYuPart.RefreshRideItem(self)
	
	local horseIdList = g_HorseCtrl:GetHorseSortId()
	 self.m_ItemGrid:HideAllChilds()
	for k, horseId in ipairs(horseIdList) do
		local item = self.m_ItemGrid:GetChild(k)
		if item == nil then
			item = self.m_HorseItem:Clone()	
			item:SetActive(true)
			item = self:InitRideItem(item)
			self.m_ItemGrid:AddChild(item)	
			item.boxCollider:SetGroup(self.m_ItemGrid:GetInstanceID())
		end
		local horseData = data.ridedata.RIDEINFO[horseId]
		item.icon:SetSpriteName(horseData.shape)
		item.boxCollider:AddUIEvent("click", callback(self, "OnClickHorseItem", horseData))
		item.flag:SetActive(g_HorseCtrl.use_ride == horseId)
		item.lv:SetText(g_HorseCtrl.grade.."级")
		item.horseData = horseData
		item:SetActive(true)
	end

end

function CHorseTongYuPart.OnClickHorseItem(self, data)
	
	self.m_SelData = data
	g_HorseCtrl:SetCurSelHorseId(data.id)
	self:RefreshAll()

end

function CHorseTongYuPart.RefreshTime(self)
	
	local horseId = self.m_SelData.id
 
	self.m_Time:SetActive(true)

	local horse = g_HorseCtrl:GetHorseById(horseId)

	if not horse then 
		return
	end

	if  horse.left_time == -1 then 
	    g_TimeCtrl:DelTimer(self)
	    self.m_Time:SetText("[244B4EFF]剩余时间:[-][a64e00]永久[-]")
	    self.m_AddTimeBtn:SetActive(false)
	else
		 self.m_AddTimeBtn:SetActive(true)
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

function CHorseTongYuPart.RefreshName(self)
	
	local name = self.m_SelData.name
	self.m_Name:SetText(name)

end

--刷新纹饰
function CHorseTongYuPart.RefreshWenShi(self)

	for k, wenshiItem in pairs(self.m_WenShiItemList) do 
		wenshiItem.icon:SetActive(false)
		wenshiItem.lv:SetActive(false)
		wenshiItem.addIcon:SetActive(false)
		wenshiItem.addIcon:SetActive(true)
		wenshiItem.flag:SetActive(false) 
		wenshiItem.info = nil
	end 
	
	local id = self.m_SelData.id
	local wenshiList = g_WenShiCtrl:GetHorseWenShi(id)
	for k, wenshi in pairs(wenshiList) do 
		local wenshiItem = self.m_WenShiItemList[wenshi.pos]
		wenshiItem.info = wenshi
		wenshiItem.icon:SpriteItemShape(wenshi.icon)
		wenshiItem.icon:SetActive(true)
		wenshiItem.lv:SetText(wenshi.lv .. "级")
		wenshiItem.lv:SetActive(true)
		wenshiItem.addIcon:SetActive(false)
		wenshiItem.flag:SetActive(wenshi.last == 0)
		wenshiItem.icon:SetGrey(wenshi.last == 0)
	end

end

--刷新统御
function CHorseTongYuPart.RefreshTongYuSummons(self)
	
	self.m_PetItemL.icon:SetActive(false)
	self.m_PetItemL.lv:SetActive(false)
	self.m_PetItemL.flag:SetActive(false)
	self.m_PetItemR.icon:SetActive(false)
	self.m_PetItemR.lv:SetActive(false)
	self.m_PetItemR.flag:SetActive(false)
	self.m_PetItemL.info = nil
	self.m_PetItemR.info = nil

	local id = self.m_SelData.id
	local summonList = g_HorseCtrl:GetRideTongYuPetList(id)
	for k, summon in pairs(summonList) do 
		if summon.pos == 1 then 
			--刷左边
			self.m_PetItemL.icon:SetSpriteName(summon.icon)
			self.m_PetItemL.lv:SetText(summon.lv .. "级")
			self.m_PetItemL.flag:SetActive(summon.id == g_SummonCtrl.m_FightId)
			self.m_PetItemL.icon:SetActive(true)
			self.m_PetItemL.lv:SetActive(true)
			self.m_PetItemL.info = summon
		elseif summon.pos == 2 then 
			--刷右边
			self.m_PetItemR.icon:SetSpriteName(summon.icon)
			self.m_PetItemR.lv:SetText(summon.lv .. "级")
			self.m_PetItemR.flag:SetActive(summon.id == g_SummonCtrl.m_FightId)
			self.m_PetItemR.icon:SetActive(true)
			self.m_PetItemR.lv:SetActive(true)
			self.m_PetItemR.info = summon

		end 
	end 

end


--刷新属性
function CHorseTongYuPart.RefreshAttr(self)
        
    self.m_AttrGrid:HideAllChilds()

    local attrList = {}
    for k, item in pairs(self.m_WenShiItemList) do 
        local data = item.info
        if data then 
            table.insert(attrList, data.attr)
        end 
    end 

    local meshAttr = g_WenShiCtrl:GetWenShiMeshAttr(attrList)

    self.m_AttrTipText:SetActive(not next(meshAttr))

    local index = 1
    for k, v  in pairs(meshAttr) do 
        local attrItem = self.m_AttrGrid:GetChild(index)
        index = index + 1
        if not attrItem then 
            attrItem = self.m_Attr:Clone()
            attrItem:SetActive(true)
            self.m_AttrGrid:AddChild(attrItem)
        end 

        attrItem.name = attrItem:NewUI(1, CLabel)
        attrItem.attr = attrItem:NewUI(2, CLabel)
        local attrNameConfig = data.attrnamedata.DATA
        local configData = attrNameConfig[k]
        if configData then
        	if g_AttrCtrl:IsRatioAttr(k) then 
        		v = v .. "%"
        	end 
        	attrItem.name:AlignmentWidth(configData.name)

            attrItem.name:SetText("[244b4e]" .. configData.name .. "[-]")
            attrItem.attr:SetText("[63432c]" .. v .. "[-]")
            attrItem:SetActive(true)
        end 
    end 

end

function CHorseTongYuPart.OnClickWenShiSkill(self)
	
	local wenshiSkill = self.m_WenShiSkill.info
	if wenshiSkill then
		CWenShiSkillTipView:ShowView(function ( oView )
			oView:SetInfo(wenshiSkill)
		end)
	end 
	
end

--刷技能
function CHorseTongYuPart.RefreshWenShiSkillItem(self)
	
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
		local valid = wenshiSkill.valid
		local count = g_WenShiCtrl:GetHorseWenShiCount(id)
		if count == 3 then 
			if not valid then 
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

function CHorseTongYuPart.OnClickTongYuItem(self, item)

	if not self.m_SelData then 
		return
	end 
	
	local info = item.info
	if info then
		local id = info.id 
		local pos = info.pos
		CTongYuSummonTipView:ShowView(function ( oView )
			oView:SetInfo(id, self.m_SelData, pos)
		end)
	else
		local id = self.m_SelData.id
		CHorseTongYuMainView:ShowView(function (oView)
			oView:OpenTongYuOpPart(id)
		end)
	end 

end

function CHorseTongYuPart.OnClickWenShiItem(self, oItem)
		
	local info = oItem.info
	local pos = oItem.pos
	if info then
		CWenShiTipView:ShowView(function(oView)
			oView:SetInfo(info, pos)
		end)
	else
		local id = self.m_SelData.id
		CHorseTongYuMainView:ShowView(function ( oView )
			oView:OpenWenShiWearPart(id, pos)
		end)
	end 

end

function CHorseTongYuPart.OnClickAddTimeBtn(self)

	local view = CHorseMainView:GetView()
	if view then 
		view:ShowSpecificPart(3)
		view:ChooseDetailPartHorse(self.m_SelData.id)
	end 

end


function CHorseTongYuPart.OnClickSkillCheckBtn(self)
	
	CHorseWenShiSkillView:ShowView()

end

function CHorseTongYuPart.OnHorseEvent(self, oCtrl)
	
    if oCtrl.m_EventID == define.Horse.Event.UpdateRideInfo or oCtrl.m_EventID == define.Horse.Event.AddHorse 
    	or oCtrl.m_EventID == define.Horse.Event.UseRide then
		self:RefreshAll()
	end	

end


return CHorseTongYuPart