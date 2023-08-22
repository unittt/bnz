local CHorseWenShiPart = class("CHorseWenShiPart", CPageBase)

function CHorseWenShiPart.ctor(self, obj)

	CPageBase.ctor(self, obj)
	self.m_SelId = nil

end

function CHorseWenShiPart.OnInitPage(self)

	self.m_HorseItem = self:NewUI(1, CBox)
	self.m_ItemGrid = self:NewUI(2, CGrid)
	self.m_WenShiItem = self:NewUI(3, CHorseWenShiItemBox)
	self.m_WenShiTable = self:NewUI(4, CTable)
	self.m_Name = self:NewUI(5, CLabel)
	self.m_Time = self:NewUI(6, CLabel)
	self.m_HorseWenShiItem = self:NewUI(7, CBox)
	self.m_HorseWenShiItemGrid = self:NewUI(8, CGrid)
	self.m_ComposeBtn = self:NewUI(9, CSprite)
	self.m_WearBtn = self:NewUI(10, CSprite)
	self.m_SkillCheckBtn = self:NewUI(11, CSprite)
	self.m_Attr = self:NewUI(12, CBox)
	self.m_AttrGrid = self:NewUI(13, CGrid)
	self.m_WenShiSkill = self:NewUI(14, CBox)
	self.m_Tip = self:NewUI(15, CSprite)
	self.m_ScrollView = self:NewUI(16, CScrollView)

	self.m_HorseWenShitemList = {}

	self:InitContent()

end

function CHorseWenShiPart.InitContent(self)

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemEvent"))
	g_HorseCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))

	self.m_ComposeBtn:AddUIEvent("click", callback(self, "OnClickComposeBtn"))
	self.m_WearBtn:AddUIEvent("click", callback(self, "OnClickWearBtn"))
	self.m_SkillCheckBtn:AddUIEvent("click", callback(self, "OnClickSkillCheckBtn"))
	self.m_Tip:AddUIEvent("click", callback(self, "OnClickTipBtn"))

	self:InitHorseWenShiItemList()
	self:RefreshRideItem()
	self:RefreshWenShiItems()

end


function CHorseWenShiPart.OnShowPage(self)

	self:RefreshRideItemSel()

end


function CHorseWenShiPart.OnClickComposeBtn(self)
	
	CHorseWenShiMainView:ShowView()

end


function CHorseWenShiPart.OnClickWearBtn(self)
	
	local rideId = self.m_SelData.id
	local itemId = self.m_CurSelWenShiId
	local pos = self.m_SelWenShiPos

	local wenshiItem = self.m_HorseWenShitemList[pos]

	if not itemId then 
		g_NotifyCtrl:FloatMsg("请选择右侧纹饰")
		return
	end 

	local tipText = g_HorseCtrl:GetTextTip(1040)

	if rideId and pos then 
		if wenshiItem.data then 
			local windowTipInfo = {
			                    msg             = tipText,
			                    okCallback      = function () 
			                    					g_WenShiCtrl:C2GSWieldWenShi(rideId, itemId, pos) 
			                                     end,
			                    okStr           =  "确定",
			                    cancelStr       =  "取消",
			                }   
			g_WindowTipCtrl:SetWindowConfirm(windowTipInfo)
		else
			g_WenShiCtrl:C2GSWieldWenShi(rideId, itemId, pos) 
		end 
	end 

end

function CHorseWenShiPart.SetData(self, rideId)

	local data = data.ridedata.RIDEINFO[rideId]

	if not data then 
		return
	end 
	
	g_WenShiCtrl:SetCurRideId(rideId) 
	self.m_SelData = data 
	self:RefreshRideItemSel()
	self:RefreshAll()

end

function CHorseWenShiPart.RefreshRideItemSel(self)
	
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
		local firstItem = self.m_ItemGrid:GetChild(1)
		if firstItem then 
			firstItem.boxCollider:ForceSelected(true)
			self:SetData(firstItem.horseData.id)
		end 
		
		local firstWenShiItem = self.m_HorseWenShitemList[1] 
		if firstWenShiItem then 
			firstWenShiItem.boxCollider:ForceSelected(true)
			self.m_SelWenShiPos = 1
		end 
	end  

end


function CHorseWenShiPart.InitHorseWenShiItem(self, oItem)

	oItem.icon = oItem:NewUI(1, CSprite)
	oItem.resetBtn = oItem:NewUI(2, CSprite)
	oItem.lv = oItem:NewUI(3, CLabel)
	oItem.boxCollider = oItem:NewUI(4, CWidget)
	oItem.resetBtn:AddUIEvent("click", callback(self, "OnResetHorseWenShiItem", oItem))
	oItem.boxCollider:AddUIEvent("click", callback(self, "OnClickHorseWenShiItem", oItem))
	oItem.boxCollider:SetGroup(self.m_HorseWenShiItemGrid:GetInstanceID())
	return oItem

end

function CHorseWenShiPart.OnResetHorseWenShiItem(self, oItem)
	
	local pos = oItem.pos
	local rideId = self.m_SelData.id
	local tipText = g_HorseCtrl:GetTextTip(1039)
	local windowTipInfo = {
	                    msg             = tipText,
	                    okCallback      = function () 
	                    					g_WenShiCtrl:C2GSUnWieldWenShi(rideId, pos)
	                                     end,
	                    okStr           =  "确定",
	                    cancelStr       =  "取消",
	                }   
	g_WindowTipCtrl:SetWindowConfirm(windowTipInfo)

end

function CHorseWenShiPart.OnClickHorseWenShiItem(self, oItem)
	
	self.m_SelWenShiPos = oItem.pos
	local info = oItem.data
	if info then
		CWenShiTipView:ShowView(function ( oView )
			oView:SetInfo(info)
			oView:HideBtn()
			oView:SetNodePos(Vector3.New(-380, 28, 0))
		end)
	end 

end

function CHorseWenShiPart.InitHorseWenShiItemList(self)
	
	for i = 1, 3 do 
		local item = self.m_HorseWenShiItem:Clone()
		item:SetActive(true)
		self.m_HorseWenShiItemGrid:AddChild(item)
		item = self:InitHorseWenShiItem(item)
		item.pos = i
		self.m_HorseWenShitemList[i] = item
	end

end

--刷新佩戴纹饰列表
function CHorseWenShiPart.RefreshHorseWenShiItemList(self)
	
	if not self.m_SelData then 
		return
	end 

	local wenshiList = g_WenShiCtrl:GetHorseWenShi(self.m_SelData.id)

	for pos, item in ipairs(self.m_HorseWenShitemList) do 
		local data = wenshiList[pos]
		self:RefreshHorseWenShiItem(item, data)
	end 

end

function CHorseWenShiPart.RefreshHorseWenShiItem(self, oItem, data)
	
	if data then 
		oItem.icon:SetActive(true)
		oItem.resetBtn:SetActive(true)
		oItem.lv:SetActive(true)
		oItem.id = data.id
		oItem.lv:SetText(data.lv .. "级")
		oItem.icon:SpriteItemShape(data.icon)
		oItem.data = data
	else
		oItem.icon:SetActive(false)
		oItem.resetBtn:SetActive(false)
		oItem.lv:SetActive(false)
		oItem.id = nil
		oItem.data = nil
	end 

end

function CHorseWenShiPart.InitRideItem(self, oItem)

	oItem.icon = oItem:NewUI(1, CSprite)
	oItem.boxCollider = oItem:NewUI(2, CWidget)
	oItem.time = oItem:NewUI(3, CLabel)
	oItem.name = oItem:NewUI(4, CLabel)
	oItem.flag = oItem:NewUI(5, CSprite)
	oItem.cname = oItem:NewUI(7, CLabel)
	oItem.boxCollider:SetGroup(self.m_ItemGrid:GetInstanceID())
	return oItem

end


function CHorseWenShiPart.RefreshAll(self)

	if self.m_SelData then
		self:RefreshRideItem() 
		self:RefreshName()
		self:RefreshTime()
		self:RefreshHorseWenShiItemList()
		self:RefreshWenShiItems()
		self:RefreshAttr()
		self:RefreshWenShiSkillItem()
		self:FindSummonEmptyBox()
	end 

end

--强制选中装配的纹饰
function CHorseWenShiPart.ForceSelectWenShi(self, pos)

	local item = self.m_HorseWenShitemList[pos]
	if item then 
		item.boxCollider:ForceSelected(true)
		self.m_SelWenShiPos = pos
	end 
end

function CHorseWenShiPart.FindSummonEmptyBox(self)
	
	local wenshiItem = self.m_HorseWenShitemList[self.m_SelWenShiPos]

	if not wenshiItem then 
		return
	end 

	if not wenshiItem.data then 
		return
	end 

	for k, item in ipairs(self.m_HorseWenShitemList) do 
		if k ~= self.m_SelWenShiPos then 
			if not item.data then 
				self:ForceSelectWenShi(k)
				break
			end 
		end 
	end 

end

--刷新纹饰列表
function CHorseWenShiPart.RefreshWenShiItems(self)
	
	local wenshiList = g_WenShiCtrl:GetBagWenShiData()

	for index, wenshiInfo in ipairs(wenshiList) do
		local item = self.m_WenShiTable:GetChild(index)
		if not item then 
			item = self.m_WenShiItem:Clone()
			item:SetActive(true)
			self.m_WenShiTable:AddChild(item)
		end 

		item:SetInfo(wenshiInfo, callback(self, "OnClickWenShiItem"))
		item:SetActive(true)

	end 

	self.m_CurSelWenShiId = nil

end


function CHorseWenShiPart.OnClickWenShiItem(self, colorType, id)

	if colorType then 
		local id = g_WenShiCtrl:GetWenShiIdByType(colorType)
		CEcononmyMainView:ShowView(function ( oView )
			oView:ShowSubPageByIndex(oView:GetPageIndex("Guild"))
			oView:JumpToTargetItem(id)
		end)
	else
		self.m_CurSelWenShiId = id
		local wenshiData = g_WenShiCtrl:GetBagWenShiDataById(id)
		if wenshiData then
			CWenShiTipView:ShowView(function ( oView )
				oView:SetInfo(wenshiData)
				oView:HideBtn()
				oView:SetNodePos(Vector3.New(-26, 46, 0))
			end)
		end 

	end

end

function CHorseWenShiPart.RefreshRideItem(self)
	
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
		item.horseData = horseData
		self:RefreshRideItemTime(item)
		item.flag:SetActive(horseId == g_HorseCtrl.use_ride)
		item:SetActive(true)
	end

end

function CHorseWenShiPart.RefreshRideItemTime(self, oItem)

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


function CHorseWenShiPart.OnClickPetItem(self, oItem)
	
	local id = oItem.id
	self.m_SelPetId = id
	

end

function CHorseWenShiPart.OnClickHorseItem(self, data)

	self.m_SelData = data
	self:RefreshAll()
	g_WenShiCtrl:SetCurRideId(data.id)

end


function CHorseWenShiPart.OnClickTongYuItemReset(self, oItem)
	
	local pos = oItem.pos
	local rideid = self.m_SelData.id
	g_HorseCtrl:C2GSUnControlSummon(rideid, pos)

end

function CHorseWenShiPart.OnClickTongYuItem(self, oItem)
	
	local pos = oItem.pos
	local id = oItem.id
	self.m_SelTongYuPos = pos
 	
end

function CHorseWenShiPart.OnClicTongYuBtn(self)
	
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

function CHorseWenShiPart.OnClickWenShiSkill(self)
	
	local wenshiSkill = self.m_WenShiSkill.info
	if wenshiSkill then
		CWenShiSkillTipView:ShowView(function ( oView )
			oView:SetInfo(wenshiSkill)
		end)
	end

end

--刷技能
function CHorseWenShiPart.RefreshWenShiSkillItem(self)
	
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

function CHorseWenShiPart.RefreshTime(self)
	
	local horseId = self.m_SelData.id
 
	self.m_Time:SetActive(true)

	local horse = g_HorseCtrl:GetHorseById(horseId)

	if not horse then 
		return
	end

	if  horse.left_time == -1 then 
	    g_TimeCtrl:DelTimer(self)
	    self.m_Time:SetText("[244B4EFF]剩余时间:[-][A64E00FF]永久[-]")
	else
	    local cb = function (time)
	        if not time then 
	            self.m_Time:SetText("[244B4EFF]剩余时间:[-][A64E00FF]过期[-]")
	        else
	            self.m_Time:SetText("[244B4EFF]剩余时间:[-][A64E00FF]" .. time .. "[-]")
	        end 
	    end
	    g_TimeCtrl:StartCountDown(self, horse.left_time, 1, cb)

	end

end

function CHorseWenShiPart.RefreshName(self)
	
	local name = self.m_SelData.name
	self.m_Name:SetText(name)

end

function CHorseWenShiPart.RefreshHorseIcon(self)
	
	local shape = self.m_SelData.shape
	self.m_HorseIcon:SetSpriteName(shape)

end

function CHorseWenShiPart.OnCtrlEvent(self, oCtrl)
	
	if oCtrl.m_EventID == define.Horse.Event.UpdateRideInfo then
		self:RefreshAll()
	end
 
end

function CHorseWenShiPart.OnItemEvent(self, oCtrl)
	
	if oCtrl.m_EventID == define.Item.Event.AddItem or  oCtrl.m_EventID == define.Item.Event.DelItem then 
		self:RefreshWenShiItems()
	end 

end

--刷新属性
function CHorseWenShiPart.RefreshAttr(self)
        
    self.m_AttrGrid:HideAllChilds()

    local attrList = {}
    for k, item in pairs(self.m_HorseWenShitemList) do 
        local data = item.data
        if data then 
            table.insert(attrList, data.attr)
        end 
    end 

    local meshAttr = g_WenShiCtrl:GetWenShiMeshAttr(attrList)

    local index = 1
    for k, v  in pairs(meshAttr) do 
        local attrItem = self.m_AttrGrid:GetChild(index)
        index = index + 1
        if not attrItem then 
            attrItem = self.m_Attr:Clone()
            attrItem:SetActive(true)
            self.m_AttrGrid:AddChild(attrItem)
        end 

        attrItem:SetActive(true)
        local attrNameConfig = data.attrnamedata.DATA
        local configData = attrNameConfig[k]
        if configData then
        	attrItem.name = attrItem:NewUI(1, CLabel)
        	attrItem.attr = attrItem:NewUI(2, CLabel)

        	if g_AttrCtrl:IsRatioAttr(k) then 
        		v = v .. "%"
        	end 
        	attrItem.name:AlignmentWidth(configData.name)

            attrItem.name:SetText("[244b4e]" .. configData.name .. "[-]")
            attrItem.attr:SetText("[63432c]" .. v .. "[-]")
        end 
    end 

    self.m_AttrGrid:Reposition()

end

function CHorseWenShiPart.OnClickSkillCheckBtn(self)
	
	CHorseWenShiSkillView:ShowView()

end

function CHorseWenShiPart.OnClickTipBtn(self)
	
	local desInfo = data.instructiondata.DESC[10064]
	if desInfo then 
		local zContent = {title = desInfo.title, desc = desInfo.desc}
		g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
	end 

end

return CHorseWenShiPart