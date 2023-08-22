local CHorseExpUpgradeView = class("CHorseExpUpgradeView", CViewBase)

function CHorseExpUpgradeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Horse/HorseExpUpgradeView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"
end

function CHorseExpUpgradeView.OnCreateView(self)

	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_LeftLv = self:NewUI(2, CLabel)
	self.m_RightLv = self:NewUI(3, CLabel)
	self.m_ExpPoint = self:NewUI(4, CLabel)
	self.m_CurLv = self:NewUI(5, CLabel)
	self.m_CurExp = self:NewUI(6, CLabel)
	self.m_Slider = self:NewUI(7, CSlider)
	self.m_OneKeyExp = self:NewUI(8, CSprite)
	self.m_OneKeyUpgrade = self:NewUI(9, CSprite)
	self.m_ItemBox = self:NewUI(10, CBox)
	self.m_LeftIcon = self:NewUI(11, CObject)
	self.m_RightIcon = self:NewUI(12, CObject)
	self.m_Arrow = self:NewUI(13, CObject)

	self.itemId = nil

	self:InitContent()

end

function CHorseExpUpgradeView.InitContent(self)

	self.m_ItemData = {}
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	g_HorseCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self.m_OneKeyExp:AddUIEvent("click", callback(self, "OnClickExpBtn"))
	self.m_OneKeyUpgrade:AddUIEvent("click", callback(self, "OnClickUpgradeBtn"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))

	self:InitItemBox()

end

function CHorseExpUpgradeView.OnAttrEvent(self, oCtrl)
	
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshAll()
	end

end

function CHorseExpUpgradeView.SetData(self, data)
	
	self.m_HorseData = data
	self:RefreshAll()

end

function CHorseExpUpgradeView.RefreshAll(self)

	if g_HorseCtrl:IsFullGrade() then 
		self:OnClose()
	else
		self:RefreshExpSlider()

		self:RefreshLvIcon()

		self:RefreshExpPoint()

		self:RefreshCurLv()

		self:RefreshItem()

		self:RefreshOneKeyBtn()
	end 
	
end

function CHorseExpUpgradeView.InitItemBox(self)
	
	self.m_ItemBox.icon = self.m_ItemBox:NewUI(1, CSprite)
	self.m_ItemBox.name = self.m_ItemBox:NewUI(2, CLabel)
	self.m_ItemBox.count = self.m_ItemBox:NewUI(3, CLabel)
	self.m_ItemBox.icon:AddUIEvent("click", callback(self, "OnClickItem"))

end

function CHorseExpUpgradeView.OnClickItem(self)

	if not self.itemId then
		return
	end
	
	local config = DataTools.GetItemData(self.itemId, "OTHER")

	g_WindowTipCtrl:SetWindowGainItemTip(self.itemId)


end

function CHorseExpUpgradeView.RefreshItem(self, icon, name, hadCount, needCount)
	
	self.m_ItemBox.icon:SetSpriteName(icon)
	self.m_ItemBox.name:SetText(name)
	if not needCount then 
		if hadCount == 0 then 
			self.m_ItemBox.count:SetText("[af302a]".. tostring(hadCount) .. "[-]")
		else
			self.m_ItemBox.count:SetText("[1d8e00]" .. tostring(hadCount) .. "[-]")
		end 
	else
		if hadCount == 0 or (hadCount < needCount) then 
			self.m_ItemBox.count:SetText("[af302a]".. tostring(hadCount) .. "[-]" .. "[1d8e00]/" .. tostring(needCount) .. "[-]")
		else
			self.m_ItemBox.count:SetText("[1d8e00]" .. tostring(hadCount) .. "/" .. tostring(needCount) .. "[-]")
		end 
	end 
	
end

function CHorseExpUpgradeView.RefreshExpItem(self)
	
	local itemId =11099
	self.itemId = itemId
	local itemData = DataTools.GetItemData(itemId)
	local icon = itemData.icon
	local name = itemData.name
	local hadCount = g_ItemCtrl:GetBagItemAmountBySid(itemId)
	self:RefreshItem(icon, name, hadCount)
	self.m_ItemData.Exp = {id = itemId, hadCount = hadCount, name = name}

end

function CHorseExpUpgradeView.RefreshLvItem(self)

    local config = data.ridedata.UPGRADE[g_HorseCtrl.grade + 1]
    if config then 
        if next(config.break_cost) then 
        	local itemId = config.break_cost[1].itemid
        	self.itemId = itemId
        	local itemData = DataTools.GetItemData(itemId, "OTHER")
        	local icon = itemData.icon
        	local name = itemData.name
        	local hadCount = g_ItemCtrl:GetBagItemAmountBySid(itemId)
            local needCount = config.break_cost[1].cnt
            self:RefreshItem(icon, name, hadCount, needCount)
            self.m_ItemData.Lv = {id = itemId, hadCount = hadCount, needCount = needCount, name = name}
        end 
    end    

end

function CHorseExpUpgradeView.RefreshExpPoint(self)
	
	local nextExp = g_HorseCtrl:GetExpByGrade(g_HorseCtrl.grade + 1)
	if nextExp then 
		self.m_ExpPoint:SetText("[244b4e]升级成功后获得[-][63432c]1[-][244b4e]技能点[-]")
	else
		self.m_ExpPoint:SetText("[244b4e]坐骑已满级[-]")
	end 
	

end

function CHorseExpUpgradeView.RefreshCurLv(self)

	self.m_CurLv:SetText("当前等级:".. g_HorseCtrl.grade)

end


function CHorseExpUpgradeView.RefreshExpSlider(self)
	
	local nextExp = g_HorseCtrl:GetExpByGrade(g_HorseCtrl.grade + 1)
    local needExp = 0
	if nextExp then
        local curGradeExp = g_HorseCtrl:GetExpByGrade(g_HorseCtrl.grade)
        local curExp = g_HorseCtrl.exp
        needExp = nextExp
		self.m_Slider:SetValue(curExp/needExp)
    	self.m_CurExp:SetText(curExp .."/"..needExp)
	else
		local exp = g_HorseCtrl:GetExpByGrade(g_HorseCtrl.grade)
		self.m_Slider:SetValue(1)
		if exp then 
			self.m_CurExp:SetText(exp .. "/" .. exp)
		end 
	end
	
end

function CHorseExpUpgradeView.RefreshLvIcon(self)

	local nextExp = g_HorseCtrl:GetExpByGrade(g_HorseCtrl.grade + 1)
	if nextExp then 
		self.m_LeftLv:SetText(g_HorseCtrl.grade .. "级")	
		self.m_RightLv:SetText(tostring(g_HorseCtrl.grade + 1) .. "级")	
		if self.m_HorseData then
			local icon = self.m_HorseData.shape
			--self.m_LeftIcon:SetSpriteName(icon)
			--self.m_RightIcon:SetSpriteName(icon)
		end 	
	end 

end

function CHorseExpUpgradeView.RefreshOneKeyBtn(self)

	if g_HorseCtrl:IsFullGrade() then 
		self.m_OneKeyUpgrade:SetActive(false)
		self.m_OneKeyExp:SetActive(false)
		self:RefreshLvIcon()
		return
	end 
	
	local isTupo = g_HorseCtrl:IsCanTupo()
	if isTupo then 
		self.m_OneKeyUpgrade:SetActive(true)
		self.m_OneKeyExp:SetActive(false)
		self:RefreshLvItem()
	else
		self.m_OneKeyExp:SetActive(true)	
		self.m_OneKeyUpgrade:SetActive(false)
		self:RefreshExpItem()
	end 
	
end

function CHorseExpUpgradeView.OnCtrlEvent(self, oCtrl)

	if oCtrl.m_EventID == define.Horse.Event.HorseAttrChange then
		self:RefreshAll()
	end

	if oCtrl.m_EventID == define.Horse.Event.Upgrade then 
		CHorseStudySkillView:ShowView()
	end 

end

function CHorseExpUpgradeView.OnClickExpBtn(self)
	
		local itemData = self.m_ItemData.Exp
		local hadCount = itemData.hadCount
		local needCount = itemData.needCount
		local name = itemData.name
	    if hadCount <= 0 then
	        -- g_NotifyCtrl:FloatMsg(name.."不足！")
	        g_QuickGetCtrl:CheckLackItemInfo({
	        	itemlist = {{sid = itemData.id, count = itemData.hadCount, amount = needCount or 1}},
	        	exchangeCb = function()
	    			netride.C2GSUpGradeRide(1)
	        	end
	        })
	        return
	    end
	    g_HorseCtrl:C2GSUpGradeRide()

end

function CHorseExpUpgradeView.OnClickUpgradeBtn(self)

	local itemData = self.m_ItemData.Lv
	local hadCount = itemData.hadCount
	local needCount = itemData.needCount
	local name = itemData.name
	if hadCount < needCount then 
	    -- g_NotifyCtrl:FloatMsg(name .. "不足")
        g_QuickGetCtrl:CheckLackItemInfo({
        	itemlist = {{sid = itemData.id, count = itemData.hadCount, amount = needCount or 1}},
        	exchangeCb = function()
    			netride.C2GSBreakRideGrade(1)
        	end
        })
	    return
	end 
	g_HorseCtrl:C2GSBreakRideGrade()

end



return CHorseExpUpgradeView