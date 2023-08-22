local CFormationMainView = class("CFormationMainView", CViewBase)

CFormationMainView.UIMode = {
	Common = 1,
	TeamMember = 2,
	Partner = 3,
}

function CFormationMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Formation/FormationMainView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CFormationMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_FmtScroll = self:NewUI(2, CScrollView)
	self.m_FmtGrid = self:NewUI(3, CGrid)
	self.m_FmtBoxClone = self:NewUI(4, CBox)
	self.m_SettingBox = self:NewUI(5, CFormationSettingBox)
	-- self.m_ExtendEffL = self:NewUI(6, CLabel)
	self.m_SaveBtn = self:NewUI(7, CButton)
	self.m_TipsBtn = self:NewUI(8, CButton)
	self.m_PositiveL = self:NewUI(9, CLabel)
	self.m_PassiveL = self:NewUI(10, CLabel)
	self.m_MutexBox = self:NewUI(11, CFormationMutexBox)
	self.m_EffectBox = self:NewUI(12, CFormationEffectBox)
	self.m_MutexBtn = self:NewUI(13, CWidget)
	self.m_EmptyMutexL = self:NewUI(14, CLabel)

	g_UITouchCtrl:TouchOutDetect(self.m_MutexBox, callback(self, "OnTouchOutDetect"))

	self.m_CurrentFmtBox = nil
	self.m_SelectedBox = nil
	self.m_SelectedFmtId = -1
	self.m_PartnerLineup = nil
	self.m_OriginalPos = {}			--存储初始化阵型列表用于比较是否变化
	self.m_IsChanged = false
	self.m_UIMode = self.UIMode.Common 
	self:InitContent()
end

function CFormationMainView.OnTouchOutDetect(self, gameObj)
	if gameObj ~= self.m_MutexBtn.m_GameObject then
		self.m_MutexBox:SetActive(false)
	end
end

function CFormationMainView.CloseView(self)
	if g_WarCtrl:IsWar() and self.m_IsChanged then
		g_NotifyCtrl:FloatMsg("战斗结束后生效")
	end
	local bIsChange = false
	if table.count(self.m_OriginalPos) == 0 then
		bIsChange = false
	end
	local compare = function(table1, table2)
		local bIsDiff = false
		if table1 and next(table1) then
			for i,pid in ipairs(table1) do
				if pid ~= table2[i] then
					bIsDiff = true
					break
				end
			end
		end
		return bIsDiff
	end
	bIsChange = compare(self.m_OriginalPos["player"], self.m_PlayerList)
	if not bIsChange then
		bIsChange = compare(self.m_OriginalPos["partner"], self.m_PartnerList)
	end
	if bIsChange then
		printc("自动保存")		
		if self.m_FmtInfo.grade == 0 then
			CViewBase.CloseView(self)
			return
		end
		if self.m_UIMode == self.UIMode.Partner then
			netpartner.C2GSSetPartnerPosInfo(self.m_PartnerLineup, self.m_SelectedFmtId, self.m_PartnerList)
		else
			netformation.C2GSSetPlayerPosInfo(self.m_SelectedFmtId, self.m_PlayerList, self.m_PartnerList)
		end
	end
	CViewBase.CloseView(self)
end

-----------------------------init data--------------------------------------
function CFormationMainView.InitContent(self)
	self.m_FmtBoxClone:SetActive(false)
	self.m_MutexBox:SetActive(false)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_MutexBtn:AddUIEvent("click", callback(self, "OnClickMutex"))
	self.m_SaveBtn:AddUIEvent("click", callback(self, "RequestSaveFormation"))
	self.m_TipsBtn:AddUIEvent("click", callback(self, "OnClickTips"))

	self.m_SettingBox:SetListener(callback(self, "OnPosChange"))
	g_FormationCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlFormationEvent"))
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlPartnerEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	netpartner.C2GSGetAllLineupInfo()
end

function CFormationMainView.SetPartnerLineup(self, iLineup, iFmtId)
	self.m_PartnerLineup = iLineup
	self.m_SelectedFmtId = iFmtId
	self:SetUIMode(self.UIMode.Partner)
end

function CFormationMainView.SetUIMode(self, iMode)
	self.m_UIMode = iMode
	self.m_SettingBox:EnableTouchActor(self.m_UIMode ~= self.UIMode.TeamMember)
	self.m_SaveBtn:SetActive(self.m_UIMode ~= self.UIMode.TeamMember)
end

function CFormationMainView.InitFormationInfo(self, iFmtId)
	if self.m_UIMode ~= self.UIMode.Partner then
		self.m_SelectedFmtId = iFmtId
	end
	self:RefreshFormationGrid()
end

function CFormationMainView.InitPosList(self)
	self.m_PartnerList = g_FormationCtrl:GetPartnerListByFmtID(self.m_SelectedFmtId)
	self.m_PlayerList = g_FormationCtrl:GetPlayerListByFmtID(self.m_SelectedFmtId)
	if not self.m_PlayerList or #self.m_PlayerList == 0 then
		self.m_PlayerList = {}
		local list = g_TeamCtrl:GetMixedList()

		for i,player in ipairs(list) do
			local bIsJoinTeam= g_TeamCtrl:IsJoinTeam(player.pid)
			local bIsInTeam = g_TeamCtrl:IsInTeam(player.pid)
			if not bIsJoinTeam or (bIsJoinTeam and bIsInTeam) then
				table.insert(self.m_PlayerList, player.pid)
			end
		end
	end 
	if not self.m_PartnerList or #self.m_PartnerList == 0 then
		self.m_PartnerList = g_PartnerCtrl:GetPosListByLineupId(g_PartnerCtrl:GetCurLineup())
	end
	if self.m_UIMode == self.UIMode.Partner then
		self.m_PlayerList = {g_AttrCtrl.pid}
		self.m_PartnerList = g_PartnerCtrl:GetPosListByLineupId(self.m_PartnerLineup)
	elseif self.m_UIMode == self.UIMode.TeamMember then
		self.m_PartnerList = g_TeamCtrl:GetPartnerPosList()
	end
	self.m_OriginalPos["player"] = table.copy(self.m_PlayerList)
	self.m_OriginalPos["partner"] = table.copy(self.m_PartnerList)
end

--跳转指定阵法，并根据阵法经验值决定是否打开阵法经验提升界面
function CFormationMainView.JumpToTargetFormation(self, iFmtId, bIsCheckExp)
	--需等待partner的协议返回的一次性跳转
	self.m_JumpFmtId = iFmtId 
	self.m_IsCheckExp = bIsCheckExp
end

--------------Ctrl事件监听--------------------
function CFormationMainView.OnCtrlFormationEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Formation.Event.UpdateAllFormation then
		self:InitFormationInfo(oCtrl.m_EventData)
	elseif oCtrl.m_EventID == define.Formation.Event.UpdateFormationInfo then
		self:UpdateSelectedFormation()
	elseif oCtrl.m_EventID == define.Formation.Event.SetCurrentFormation then
		self:UpdateCurrentFormation()
		self:UpdateSelectedFormation()
	elseif oCtrl.m_EventID == define.Formation.Event.UpdatePosList then
		self:OnFormationSelect(self.m_SelectedBox)		
	end
end

function CFormationMainView.OnCtrlPartnerEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Partner.Event.UpdateAllLineup then
		if g_FormationCtrl:GetCurrentFmt() ~= 0 then
  			self:InitFormationInfo(self.m_JumpFmtId or g_FormationCtrl:GetCurrentFmt())
  			if self.m_IsCheckExp then
  				self:CheckShowUpgradeView()
  				self.m_IsCheckExp = false
  			end
  			self.m_JumpFmtId = nil
  		else
  			netformation.C2GSAllFormationInfo()
  		end
	end
end

function CFormationMainView.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem or 
		define.Item.Event.RefreshSpecificItem then
		self:RefreshFormationGrid()
		self:UpdateSelectedFormation()
	end
end

------------------------------UI refresh----------------------------------------
function CFormationMainView.RefreshFormationGrid(self)
	local list = data.formationdata.BASEINFO
	local iFmtCnt = #list
	local oSelectedBox = nil
	if g_FormationCtrl.m_NeedGuideLearn then
		local _,oItem = g_ItemCtrl:IsContainFormationItem()
		self.m_SelectedFmtId = DataTools.GetFormationIdByItem(oItem.m_SID)
	end

	for i=1, iFmtCnt do
		local iIndex = i == iFmtCnt and 1 or i + 1
		local dData = list[iIndex]
		local dInfo = g_FormationCtrl:GetFormationInfoByFmtID(dData.id)
		local oBox = self.m_FmtGrid:GetChild(i)
		if not oBox then
			oBox = self:CreateFormationBox(dInfo)	
			self.m_FmtGrid:AddChild(oBox)
		else
			self:UpdateFormationBox(oBox, dInfo)
		end
		if self.m_SelectedFmtId == iIndex or (self.m_SelectedFmtId == -1 and iIndex == 1) then
			oSelectedBox = oBox
		end
	end
	if oSelectedBox then
		oSelectedBox:SetSelected(true)
		self:OnFormationSelect(oSelectedBox)
	end
	self.m_FmtGrid:Reposition()
	if self:IsFullOut(self.m_SelectedBox) then
		UITools.MoveToTarget(self.m_FmtScroll, self.m_SelectedBox)
	end
end

function CFormationMainView.CreateFormationBox(self, dInfo)
	local oBox = self.m_FmtBoxClone:Clone()
	oBox.m_FormationSpr = oBox:NewUI(1, CSprite)
	oBox.m_NameL = oBox:NewUI(2, CLabel)
	oBox.m_SelNameL = oBox:NewUI(3, CLabel)
	oBox.m_LvL = oBox:NewUI(4, CLabel)
	oBox.m_LearnBtn = oBox:NewUI(5, CSprite)
	oBox.m_LearnBtnL = oBox:NewUI(6, CLabel) 
	oBox.m_UseFlagSpr = oBox:NewUI(7, CSprite)
	oBox.m_UpgradeFlagSpr = oBox:NewUI(8, CSprite)
	oBox.m_ItemBgSpr = oBox:NewUI(9, CSprite)

	oBox:SetActive(true)
	oBox:AddUIEvent("click", callback(self, "OnFormationSelect"))
	oBox.m_LearnBtn:AddUIEvent("click", callback(self, "OnClickUpgrade", oBox))
	oBox.m_ItemBgSpr:AddUIEvent("click", callback(self, "OpenItemGainView", oBox))
	self:UpdateFormationBox(oBox, dInfo)
	return oBox
end

function CFormationMainView.UpdateFormationBox(self, oBox, dInfo)
	--阵法状态，无阵需要特殊显示
	local dData = data.formationdata.BASEINFO[dInfo.fmt_id]
	dInfo.cData = dData

	oBox.m_ID = dInfo.fmt_id 
	oBox.m_FmtInfo = dInfo
	oBox.m_Status = g_FormationCtrl:GetFormationStatus(dInfo.fmt_id)

	local bEmptyFormation = dInfo.fmt_id == 1
	local bEmptyGrade = dInfo.grade == 0
	local bInUse = g_FormationCtrl:IsInUse(dInfo.fmt_id)
	if bInUse then
		self.m_CurrentFmtBox = oBox
	end

	oBox.m_NameL:SetText(dData.name)
	oBox.m_SelNameL:SetText(dData.name)
	oBox.m_LvL:SetActive(not bEmptyFormation)
	oBox.m_UseFlagSpr:SetActive(bInUse)
	oBox.m_LearnBtn:SetActive(not bEmptyFormation)

	oBox.m_UpgradeFlagSpr:SetActive(false)

	

	local iMaxLv = #dInfo.cData.exp
	oBox.m_LvL:SetText(string.format("等级：%d/%d", dInfo.grade, iMaxLv))

	oBox.m_LearnBtn:SetGrey(false)
	oBox.m_LearnBtn:DelEffect("RedDot")
	if not g_FormationCtrl.m_NeedGuideLearn then
		oBox.m_LearnBtn:DelEffect("FingerInterval")
	end
	if oBox.m_Status == define.Formation.Status.LearnAllow then
		oBox.m_LearnBtn:SetSpriteName("h7_an_2")
		oBox.m_LearnBtnL:SetText("学习")
		oBox.m_LvL:SetText("[c]#R未学习#n")
		oBox.m_LearnBtn:AddEffect("RedDot", 20, Vector2(-13, -17))
		if g_FormationCtrl.m_NeedGuideLearn then
			oBox.m_LearnBtn:AddEffect("FingerInterval")
		end
	elseif oBox.m_Status == define.Formation.Status.UnableLearn or 
		oBox.m_Status == define.Formation.Status.NotLearn then
		oBox.m_LearnBtnL:SetText("学习")
		oBox.m_LvL:SetText("[c]#R未学习#n")
	elseif oBox.m_Status == define.Formation.Status.None then
		oBox.m_LearnBtn:SetActive(false)
		oBox.m_UpgradeFlagSpr:SetActive(false)
	else
		oBox.m_LearnBtnL:SetText("升级")
		oBox.m_LearnBtn:SetSpriteName("h7_an_1")
		local dItemInfo = DataTools.GetFormationItemExpData(dInfo.fmt_id)
		if dItemInfo then
			local iItemCount = g_ItemCtrl:GetBagItemAmountBySid(dItemInfo.itemid)
			oBox.m_UpgradeFlagSpr:SetActive(iItemCount > 0)
		end
	end
	oBox.m_FormationSpr:SetSpriteName(dData.icon)
end

function CFormationMainView.UpdateCurrentFormation(self)
	local dInfo = g_FormationCtrl:GetFormationInfoByFmtID(self.m_CurrentFmtBox.m_ID)
	self:UpdateFormationBox(self.m_CurrentFmtBox, dInfo)
end

function CFormationMainView.UpdateSelectedFormation(self)
	local dInfo = g_FormationCtrl:GetFormationInfoByFmtID(self.m_SelectedFmtId)
	self:UpdateFormationBox(self.m_SelectedBox, dInfo)
	self:OnFormationSelect(self.m_SelectedBox)
end

function CFormationMainView.RefreshEffectBox(self)
	self.m_EffectBox:SetFormationInfo(self.m_FmtInfo, self.m_PlayerList, self.m_PartnerList)
	self.m_EffectBox:RefreshUI()
end

function CFormationMainView.RefreshMutexBox(self)
	local iGrade = self.m_EffectBox:GetFormationGrade()
	self.m_MutexBox:SetFormationInfo(self.m_FmtInfo, iGrade)
	self.m_MutexBox:RefreshUI()
end

function CFormationMainView.RefreshSettingBox(self)
	self.m_SettingBox:SetFormationInfo(self.m_FmtInfo, self.m_PlayerList, self.m_PartnerList)
	self.m_SettingBox:RefreshUI()
end

function CFormationMainView.RefreshMutexL(self)
	local dData = data.formationdata.BASEINFO[self.m_SelectedFmtId]
	local sPositive = ""
	local sPassive = ""
	local bEmptyFormation = self.m_SelectedFmtId == 1
	self.m_PassiveL:SetActive(not bEmptyFormation)
	self.m_PositiveL:SetActive(not bEmptyFormation)
	self.m_EmptyMutexL:SetActive(bEmptyFormation)

	for iFmtId, iEffect in ipairs(dData.mutex) do
		if iFmtId ~= 1 then
			if iEffect > 0 then
				local sFmtName = data.formationdata.BASEINFO[iFmtId].name
				sPositive = string.format("%s%s ",sPositive, sFmtName)
			elseif iEffect < 0 then
				local sFmtName = data.formationdata.BASEINFO[iFmtId].name
				sPassive = string.format("%s%s ",sPassive, sFmtName)
			end
		end
	end
	if bEmptyFormation then
		self.m_EmptyMutexL:SetText(sPassive)
		return
	end
	self.m_PositiveL:SetText(sPositive)
	self.m_PassiveL:SetText(sPassive)
end

function CFormationMainView.RefreshUI(self)
	self:RefreshEffectBox()
	self:RefreshMutexBox()
	self:RefreshSettingBox()
	self:RefreshMutexL()
end

--------------点击事件or操作监听--------------------
function CFormationMainView.OnFormationSelect(self, oBox)
	self.m_SelectedFmtId = oBox.m_ID
	self.m_SelectedBox = oBox
	self.m_FmtInfo = oBox.m_FmtInfo
	g_FormationCtrl:ClearLocalPosList()
	self:InitPosList()
	self:RefreshUI()
end

function CFormationMainView.OnPosChange(self)
	local playerList, partnerList = self.m_SettingBox:GetPosList()
	self.m_PlayerList = playerList
	self.m_PartnerList = partnerList
	self:RefreshEffectBox()
end


function CFormationMainView.OnClickMutex(self)
	self.m_MutexBox:SetActive(true)
	self:RefreshMutexBox()
end

function CFormationMainView.OnClickUpgrade(self, oBox)
	--TDOO:请求学习或者提升阵法等级
	oBox:SetSelected(true)
	self:OnFormationSelect(oBox)

	if not self.m_FmtInfo then
		return
	end
	if self.m_FmtInfo.grade == 0 then
		local dData = DataTools.GetFormationItemExpData(self.m_SelectedFmtId)
		local list = g_ItemCtrl:GetBagItemListBySid(dData.itemid)
		if list and #list > 0 then
			local oItem = list[1]
			netitem.C2GSItemUse(oItem.m_ID, self.m_SelectedFmtId)
		else
			-- "没有必要阵法书无法学习"
			-- local dItemData = DataTools.GetItemData(dData.itemid)
			-- local sMsg = string.gsub(data.formationdata.TEXT[1003].content, "#name", dItemData.name)
			-- g_NotifyCtrl:FloatMsg(sMsg)
			g_WindowTipCtrl:SetWindowGainItemTip(dData.itemid)
		end
	else
		CFormationUpgradeView:ShowView(function(oView)
			oView:SetFormationInfo(self.m_FmtInfo)
			oView:RefreshAll()
		end)
	end
end

function CFormationMainView.RequestSaveFormation(self)
	if not self.m_FmtInfo then
		return
	end
	local playerList, partnerList = self.m_SettingBox:GetPosList()
	if self.m_FmtInfo.grade == 0 then
		g_NotifyCtrl:FloatMsg(data.formationdata.TEXT[1005].content) --未学习该阵法
		return
	end
	if self.m_UIMode == self.UIMode.Partner then
		netpartner.C2GSSetPartnerPosInfo(self.m_PartnerLineup, self.m_SelectedFmtId, partnerList)
		g_NotifyCtrl:FloatMsg(data.formationdata.TEXT[1001].content) --阵法保存成功
	else
		netformation.C2GSSetPlayerPosInfo(self.m_SelectedFmtId, playerList, partnerList)
		self.m_IsChanged = true
	end
	self:CloseView()
end

function CFormationMainView.OnClickTips(self)
	local id = define.Instruction.Config.Formation
    local content = {
        title = data.instructiondata.DESC[id].title,
        desc  = data.instructiondata.DESC[id].desc
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(content)
end

function CFormationMainView.OpenItemGainView(self, oBox)
	if oBox.m_ID == 1 then
		return
	end
	local dData = DataTools.GetFormationItemExpData(oBox.m_ID)
	g_WindowTipCtrl:SetWindowGainItemTip(dData.itemid)
end
-----------------other control helper-------------------------------
function CFormationMainView.CheckShowUpgradeView(self)
	if self.m_SelectedBox.m_Status == define.Formation.Status.UpgradeAllow then
		CFormationUpgradeView:ShowView(function(oView)
			oView:SetFormationInfo(self.m_FmtInfo)
			oView:RefreshAll()
		end)
	end
end

return CFormationMainView