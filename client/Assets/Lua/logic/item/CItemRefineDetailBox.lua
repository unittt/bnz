local CItemRefineDetailBox = class("CItemRefineDetailBox", CBox)

function CItemRefineDetailBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_RewardSpr = self:NewUI(1, CSprite)
	self.m_TypeL = self:NewUI(2, CLabel)
	self.m_RefineCheckBox = self:NewUI(3, CWidget)	
	self.m_StateGrid = self:NewUI(4, CGrid)

	self:InitContent()
end

function CItemRefineDetailBox.InitContent(self)
	local function initbox(obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_RewardSpr = oBox:NewUI(1, CSprite)
		oBox.m_AddBtn = oBox:NewUI(2, CButton)
		oBox.m_UnlockBtn = oBox:NewUI(3, CButton)
		oBox.m_StateL = oBox:NewUI(4, CLabel)

		oBox.m_AddBtn:AddUIEvent("click", callback(self, "OnClickAddRefine", oBox))
		oBox.m_UnlockBtn:AddUIEvent("click", callback(self, "OnClickUnlock", oBox))
		oBox.m_RewardSpr:AddUIEvent("click", callback(self, "OnClickGainReward", oBox))
		return oBox
	end
	self.m_StateGrid:InitChild(initbox)
	self.m_RefineCheckBox:SetSelected(false)

	self.m_RefineCheckBox:AddUIEvent("click", callback(self, "OnClickCheckBox"))

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
end

function CItemRefineDetailBox.SetRefineType(self, iType)
	self.m_CRefineData = data.vigodata.DATA[iType]
	self.m_SRefineData = g_ItemCtrl:GetRefineInfo(iType)
	self:RefreshAll()
end

function CItemRefineDetailBox.OnCtrlItemEvent(self, oCtrl)
	if not self:GetActive() then
		return
	end
	if oCtrl.m_EventID == define.Item.Event.RefreshRefineInfo then
		local iType = oCtrl.m_EventData
		if not iType or (self.m_CRefineData and iType == self.m_CRefineData.id) then
			self:SetRefineType(self.m_CRefineData.id)
		end
	end
end

------------------------ui refresh---------------------------------
function CItemRefineDetailBox.RefreshAll(self)
	self:RefreshBaseInfo()
	self:RefreshStateGrid()
end

function CItemRefineDetailBox.RefreshStateGrid(self)
	if not self.m_SRefineData then
		return
	end
	self.m_IsFirstRefine = true
	local lBox = self.m_StateGrid:GetChildList()
	for i,oBox in ipairs(lBox) do
		local dInfo = self.m_SRefineData.grid_info[i]
		self:UpdateRefineStateBox(oBox, dInfo, i)
	end
end

function CItemRefineDetailBox.UpdateRefineStateBox(self, oBox, dInfo, iIndex)
	local iGridSize = self.m_SRefineData.grid_size
	if iIndex > iGridSize + 1 then
		oBox:SetActive(false)
		return
	end

	local bIsLock = iIndex == iGridSize + 1 
	local bIsEmpty =  dInfo and dInfo.timeout == 0
	local bIsCanGain = dInfo and dInfo.timeout <= g_TimeCtrl:GetTimeS()  
	local bIsWaiting = dInfo and dInfo.timeout > g_TimeCtrl:GetTimeS()
	local bIsRefine = false
	if self.m_IsFirstRefine and bIsWaiting then
		bIsRefine = true
		bIsWaiting = false
		self.m_IsFirstRefine = false
	end 
	oBox.m_UnlockCost = self.m_CRefineData.grid_cost[iIndex]
	oBox.m_Index = iIndex

	oBox:SetActive(true)
	oBox.m_RewardSpr:SpriteItemShape(self.m_CRefineData.sub_icon)
	oBox.m_RewardSpr:SetActive(not bIsEmpty and not bIsLock)
	oBox.m_AddBtn:SetActive(bIsEmpty and not bIsLock)
	oBox.m_UnlockBtn:SetActive(bIsLock)

	if oBox.m_Timer then
		Utils.DelTimer(oBox.m_Timer)
		oBox.m_Timer = nil
	end
	if bIsLock then
		oBox.m_StateL:SetText("#cur_2"..oBox.m_UnlockCost)
	elseif bIsWaiting then
		oBox.m_StateL:SetText("等待中")
		oBox.m_NotifyMsg = "等待中"
	elseif bIsEmpty then
		oBox.m_StateL:SetText("")
	elseif bIsCanGain then
		oBox.m_StateL:SetText("可领取")
		oBox.m_NotifyMsg = nil
	else 	
		oBox.m_Timer = Utils.AddTimer(callback(self, "RefreshTimeLabel", oBox, dInfo.timeout), 0.5, 0)
		oBox.m_NotifyMsg = "炼制尚未完成"
	end
end

function CItemRefineDetailBox.RefreshTimeLabel(self, oBox, iRefineTime)
	if Utils.IsNil(self) then
		return false
	end
	local iDiffTime = os.difftime(iRefineTime, g_TimeCtrl:GetTimeS())
	if iDiffTime > 0 then
		oBox.m_StateL:SetText(g_TimeCtrl:GetLeftTime(iDiffTime))
	else
		self:RefreshAll()
		return false
	end
	return true	
end

function CItemRefineDetailBox.RefreshBaseInfo(self)
	if not self.m_SRefineData then
		return
	end 
	self.m_TypeL:SetText(self.m_CRefineData.name)
	self.m_RewardSpr:SetSpriteName(self.m_CRefineData.icon)

	local gradeLimit = self.m_CRefineData.grade_limit
	if g_AttrCtrl.grade >= gradeLimit then
		self.m_RefineCheckBox:SetSelected(self.m_SRefineData.is_change_all == 1)
	end
			
end

------------------------click event---------------------------------
function CItemRefineDetailBox.OnClickCheckBox(self)
	if self:CheckRefineLock() then
		self.m_RefineCheckBox:SetSelected(false)
	else
		local bIsAuto = self.m_RefineCheckBox:GetSelected() and 1 or 0
		--TODO:协议设置一键炼制
		netvigor.C2GSVigorChangeItemStatus(bIsAuto, self.m_CRefineData.id)
	end

	
end

function CItemRefineDetailBox.OnClickAddRefine(self, oBox)
	if self:CheckRefineLock() then
		return
	end
	if g_AttrCtrl.vigor < self.m_CRefineData.cost then
		g_NotifyCtrl:FloatMsg("精气不足150点, 请先补充")
		return
	end
	netvigor.C2GSVigorChangeStart(self.m_CRefineData.id)
end

function CItemRefineDetailBox.OnClickUnlock(self, oBox)
	if self:CheckRefineLock() then
		return
	end
	local windowConfirmInfo = {
		msg = string.format("确定消耗%d#cur_2解锁", oBox.m_UnlockCost),
		okCallback = function() netvigor.C2GSBuyGrid(self.m_CRefineData.id) end,	
		pivot = enum.UIWidget.Pivot.Center,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CItemRefineDetailBox.OnClickGainReward(self, oBox)
	if self:CheckRefineLock() then
		return
	end
	if oBox.m_NotifyMsg then
		g_NotifyCtrl:FloatMsg(oBox.m_NotifyMsg)
		return
	end
	netvigor.C2GSVigorChangeProduct(self.m_CRefineData.id)
end

----------------------data helper------------------------------
function CItemRefineDetailBox.CheckRefineLock(self)
	if g_AttrCtrl.grade < self.m_CRefineData.grade_limit then
		g_NotifyCtrl:FloatMsg("开启等级"..self.m_CRefineData.grade_limit)
		return true
	end
	return false
end

return CItemRefineDetailBox