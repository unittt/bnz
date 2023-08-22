local CPushSettingsView = class("CPushSettingsView", CViewBase)

function CPushSettingsView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Systemsettings/PushSettingsView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CPushSettingsView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ScrollView = self:NewUI(2, CScrollView)
	self.m_PushMsgGrid = self:NewUI(3, CGrid)
	self.m_PushMsgBoxClone = self:NewUI(4, CBox)
	self.m_TipsBtn = self:NewUI(5, CSprite)
	self.m_FriendBox = self:NewUI(6, CSprite)
	self.m_FriendSpr = self:NewUI(7, CSprite)

	self.m_SliderVluse = {
		[0] = 0.9,
		[1] = 0.1,
	}
	self.m_FriendSettingId = 2001
	self.m_IsPushFriendMsg = g_SystemSettingsCtrl:GetGamePushConfigById(self.m_FriendSettingId) --0：推送 1：不推送
	self:InitContent()
end

function CPushSettingsView.InitContent(self)
	if self.m_IsPushFriendMsg == 0 then
		self.m_FriendSpr:SetActive(true)
	end
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_TipsBtn:AddUIEvent("click", function ( ... )
		printc("click")
	end)
	self.m_FriendBox:AddUIEvent("click", callback(self, "OnFriendMsg"))
	self:InitPushMsgGrid()
end

function CPushSettingsView.InitPushMsgGrid(self)
	local dData = data.gamepushdata.DATA
	local dSortData = {}
	for k,v in pairs(dData) do
		table.insert(dSortData, v)
	end
	local sort = function(d1, d2)
		return d1.id < d2.id
	end
	table.sort(dSortData, sort)
	for i,dPush in ipairs(dSortData) do
		local oBox = self:CreatePushMsgBox()
		if i%2 == 0 then
			oBox.m_SliderSpr:SetSpriteName("h7_di_3")
		end
		self:UpdatePushMsgBox(oBox, dPush)
		self.m_PushMsgGrid:AddChild(oBox)
	end
	self.m_PushMsgBoxClone:SetActive(false)
	self.m_PushMsgGrid:Reposition()
end

function CPushSettingsView.CreatePushMsgBox(self)
	local oBox = self.m_PushMsgBoxClone:Clone()
	oBox.m_NameL = oBox:NewUI(1, CLabel)
	oBox.m_CycleL = oBox:NewUI(2, CLabel)
	oBox.m_TimeL = oBox:NewUI(3, CLabel)
	oBox.m_MemberCountL = oBox:NewUI(4, CLabel)
	oBox.m_ToggleSlider = oBox:NewUI(5, CSlider)
	oBox.m_ToggleBtn = oBox:NewUI(6, CWidget)
	oBox.m_SliderSpr = oBox:NewUI(7, CSprite)
	oBox.m_ToggleBtn:AddUIEvent("click", callback(self, "OnToggle", oBox))
	return oBox
end

function CPushSettingsView.UpdatePushMsgBox(self, oBox, dInfo)
	oBox.m_PushID = dInfo.id
	oBox.m_IsPushMsg = g_SystemSettingsCtrl:GetGamePushConfigById(dInfo.id)
	self:SetPushTag(dInfo.id, oBox.m_IsPushMsg)
	oBox.m_NameL:SetText(dInfo.name)
	oBox.m_CycleL:SetText(dInfo.cycle)
	oBox.m_TimeL:SetText(dInfo.time)
	oBox.m_MemberCountL:SetText(dInfo.member)
	oBox.m_ToggleSlider:SetValue(self.m_SliderVluse[oBox.m_IsPushMsg])
end

function CPushSettingsView.OnToggle(self, oBox)
	printc("OnToggle", oBox.m_PushID, oBox.m_IsPushMsg)
	oBox.m_IsPushMsg = (oBox.m_IsPushMsg + 1)% 2	
	oBox.m_ToggleSlider:SetValue(self.m_SliderVluse[oBox.m_IsPushMsg])
	netplayer.C2GSGamePushConfig({{id = oBox.m_PushID, value = oBox.m_IsPushMsg}})
	g_SystemSettingsCtrl:SetGamePushConfig(oBox.m_PushID, oBox.m_IsPushMsg)
	printc(oBox.m_IsPushMsg)
end

function CPushSettingsView.OnFriendMsg(self)
	--self.m_IsPushFriendMsg = (self.m_IsPushFriendMsg + 1)% 2	
	--self.m_FriendSlider:SetValue(self.m_SliderVluse[self.m_IsPushFriendMsg])
	if self.m_FriendSpr:GetActive() then
		 self.m_FriendSpr:SetActive(false)
		 self.m_IsPushFriendMsg = 1
	else
		self.m_IsPushFriendMsg = 0
		self.m_FriendSpr:SetActive(true)
	end
	netplayer.C2GSGamePushConfig({{id = self.m_FriendSettingId, value = self.m_IsPushFriendMsg}})
end

function CPushSettingsView.SetPushTag(self, iId, iFlag)
	do return end
	printc("SetPushTag",iId,iFlag) 
	if iFlag == 0 then
		C_api.XinGeSdk.SetTag("PUSH_TASK_"..iId)
	else
		C_api.XinGeSdk.DeleteTag("PUSH_TASK_"..iId)
	end
end

function CPushSettingsView.OnClose(self)
	CScheduleMainView:ShowView()
	self:CloseView()
end

return CPushSettingsView