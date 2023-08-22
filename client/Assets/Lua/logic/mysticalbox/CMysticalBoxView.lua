local CMysticalBoxView = class("CMysticalBoxView", CViewBase)

function CMysticalBoxView.ctor(self, cb)
	CViewBase.ctor(self, "UI/MysticalBox/MysticalBoxMainView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CMysticalBoxView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_OpenNormalBtn = self:NewUI(2, CButton)
	self.m_OpenDisableBtn = self:NewUI(3, CButton)
	self.m_TimeLbl = self:NewUI(4, CLabel)
	self.m_WingTexture = self:NewUI(5, CActorTexture)

	self:InitContent()
end

function CMysticalBoxView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_OpenNormalBtn:AddUIEvent("click", callback(self, "OnOpenMysticalBox"))
	self.m_OpenDisableBtn:AddUIEvent("click", callback(self, "OnHintMysticalBox"))

	g_MysticalBoxCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))

	self.m_OpenNormalBtn:SetActive(false)
	self.m_OpenDisableBtn:SetActive(true)

	self:InitWingTexture()
end

function CMysticalBoxView.InitWingTexture(self)
	local wingInfo = {
		figureid = 60200,
		icon = 27006,
		name = "远古之翼",
	}
    self.m_WingTexture:ChangeShape({
        figure = wingInfo.figureid,
        pos = Vector3(0, -0.1, 3),
        ignoreClick = true,
    })
    local oCam = self.m_WingTexture.m_ActorCamera
    if oCam and oCam.m_Actor then
        oCam.m_Actor:SetLocalRotation(Quaternion.identity)
    end
end

--事件
function CMysticalBoxView.OnCtrlEvent(self, oCtrl)
	--printc("666666 ", oCtrl.m_EventID, "CMysticalBoxView.OnCtrlEvent ")
	if oCtrl.m_EventID == define.MysticalBox.Event.MysticalBoxStart then 
		self:RefreshEventStart()
	elseif oCtrl.m_EventID == define.MysticalBox.Event.MysticalBoxRefreshTime then
		self:RefreshTime(oCtrl)	
	elseif oCtrl.m_EventID == define.MysticalBox.Event.MysticalBoxTimeOut then
		self:RefreshTimeOut()		
	elseif oCtrl.m_EventID == define.MysticalBox.Event.MysticalBoxRefreshEnd then
		self:RefreshEventEnd()	
	end
end

function CMysticalBoxView.OnOpenMysticalBox(self)
	--printc("!!!!!!!! CMysticalBoxView.OnOpenMysticalBox  m_open_state:", g_MysticalBoxCtrl.m_open_state, " m_curLeftTime:", g_MysticalBoxCtrl.m_curLeftTime)
	if g_MysticalBoxCtrl.m_open_state == 2 and g_MysticalBoxCtrl.m_curLeftTime <= 0 then
		nethuodong.C2GSMysticalboxOperateBox(2)
	end
end

function CMysticalBoxView.OnHintMysticalBox(self)
	--printc("!!!!!!!! CMysticalBoxView.OnHintMysticalBox  m_open_state:", g_MysticalBoxCtrl.m_open_state, " m_curLeftTime:", g_MysticalBoxCtrl.m_curLeftTime)
	if g_MysticalBoxCtrl.m_open_state == 2 and g_MysticalBoxCtrl.m_curLeftTime > 0 then
		local timeText = g_TimeCtrl:GetLeftTimeString(g_MysticalBoxCtrl.m_curLeftTime)
		local totalTimeText = "请等待#G" .. timeText .. "[-]后进行操作!"
		g_NotifyCtrl:FloatMsg(totalTimeText)
	end
end

function CMysticalBoxView.RefreshUI(self)
	self:RefreshTime()
	self:RefreshTimeOut()
end

function CMysticalBoxView.RefreshEventStart(self, oCtrl)
end

function CMysticalBoxView.RefreshEventEnd(self, oCtrl)
	self:OnClose()
end

function CMysticalBoxView.RefreshTime(self, oCtrl)
	--printc("~~~~~~~~~~~~~~~~ CMysticalBoxView.RefreshTime:" , g_MysticalBoxCtrl.m_time)
	self.m_TimeLbl:SetText(g_MysticalBoxCtrl.m_time)
end

function CMysticalBoxView.RefreshTimeOut(self, oCtrl)
	--printc("~~~~~~~~~~~~~~~~ CMysticalBoxView.RefreshTimeOut:" , g_MysticalBoxCtrl.m_leftTime)
	if g_MysticalBoxCtrl.m_leftTime <= 0 then
		self.m_OpenNormalBtn:SetActive(true)
		self.m_OpenDisableBtn:SetActive(false)
	else
		self.m_OpenNormalBtn:SetActive(false)
		self.m_OpenDisableBtn:SetActive(true)	
	end
end

return CMysticalBoxView