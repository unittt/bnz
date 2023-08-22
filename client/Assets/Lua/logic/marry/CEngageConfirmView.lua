local CEngageConfirmView = class("CEngageConfirmView", CViewBase)

function CEngageConfirmView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Marry/EngageConfirmView.prefab", cb)

	self.m_GroupName = "main"
	self.m_DepthType = "Middle"
    --self.m_ExtendClose = "Shelter"
    self.m_IsReadyEngage = false
end

function CEngageConfirmView.OnCreateView(self)
	-- body
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_ConditionItemClone = self:NewUI(3, CBox)
	self.m_NpcTexture = self:NewUI(4, CActorTexture)
	self.m_ConfirmBtn = self:NewUI(5, CButton)
	self.m_Title = self:NewUI(7, CLabel)
	self.m_CancelBtn = self:NewUI(6, CButton)
	self.m_RingSp = self:NewUI(8, CSprite)
	self.m_RingLbl = self:NewUI(9, CLabel)
	self.m_WaitSp = self:NewUI(10, CSprite)
	self.m_WaitLabel = self:NewUI(11, CLabel)
	self.m_EngageLbl = self:NewUI(12, CLabel)
	self.m_BtnTip = self:NewUI(13, CLabel)

	self:InitContent()
end

function CEngageConfirmView.LoadDone(self)
	CViewBase.LoadDone(self)
	g_ViewCtrl:ShowByGroup(self.m_GroupName)
end

function CEngageConfirmView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnCloseView"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirmClick"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnCancelClick"))

	g_EngageCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEngageEvent"))

	self:InitNpcTexture()
end

function CEngageConfirmView.InitNpcTexture(self)
	local model_info = g_EngageCtrl:GetNpcModelInfo()
	self.m_NpcTexture:ChangeShape(model_info)
end

function CEngageConfirmView.ShowConfirmUI(self, condition, status)

	if g_TeamCtrl.m_LeaderID == g_AttrCtrl.pid then
		self:ShowConditionBox(condition)
	else
		self:ShowOtherUI()
	end

	local partner = g_EngageCtrl:GetPartnerInfo()
	if partner then
		local dText = data.engagedata.TEXT[1032].content
		local title = string.FormatString(dText, {role = partner.name}, true)
		self.m_Title:SetText("[63432C]"..title) --todo
	end
	self:ShowEngageRing()
	self:ShowWaitStatus(status)
end

function CEngageConfirmView.ShowConditionBox(self, condition)
	-- initCondition --
	local condition = condition
	for i, v in ipairs(condition) do
		local oBox = self.m_Grid:GetChild(i)
		if oBox == nil then
			oBox = self.m_ConditionItemClone:Clone()
			oBox:SetActive(true)
			self.m_Grid:AddChild(oBox)
		end
		
		local configText = DataTools.GetEngageData("TEXT", v.descID)
		local desc = tostring(i).."、"..configText.content

		if i == 2 then
			local dConfig = DataTools.GetViewOpenData(define.System.Engage)
			local pLevel = dConfig.p_level
			desc = desc:gsub("#level", pLevel)
		elseif i == 3 then
			local degree = data.engagedata.CONFIG.re_marry_friend_piont
			desc = desc:gsub("#amount", degree)
		end

		oBox.m_Sp = oBox:NewUI(1, CSprite)
		oBox.m_Label = oBox:NewUI(2, CLabel)

		oBox.m_Sp:SetActive(v.bCondition)
		oBox.m_Label:SetText(desc)
	end
	self.m_Grid:Reposition()
end

function CEngageConfirmView.ShowOtherUI(self)
	
	local partner = g_EngageCtrl:GetPartnerInfo()
	local dText = data.engagedata.TEXT[1026].content
	local label = string.FormatString(dText, {role = partner.name}, true)
	self.m_EngageLbl:SetActive(true)
	self.m_EngageLbl:SetText("[63432C]"..label) --todo

	self.m_Grid:SetActive(false)
	self.m_BtnTip:SetActive(false)
	self.m_ConfirmBtn:SetText("我愿意")
	self.m_CancelBtn:SetText("不愿意")

end

function CEngageConfirmView.ShowEngageRing(self)
	-- initRing --
	local dConfig = g_EngageCtrl:GetRingConfig()
	local atlas, icon = dConfig.atlas, dConfig.icon
	self.m_RingSp:SetStaticSprite(atlas, icon)
	self.m_RingSp:AddEffect(dConfig.ringEffect, nil, 1)

	local t = {"银", "金", "钻石"}
	local desc = t[dConfig.type].."戒指礼包"
	self.m_RingLbl:SetText(desc)
	self.m_RingLbl:SetGradientTop(Color.RGBAToColor(dConfig.color.top))
	self.m_RingLbl:SetGradientBottom(Color.RGBAToColor(dConfig.color.bottom))
	self.m_RingLbl:SetEffectColor(Color.RGBAToColor(dConfig.color.shadow))
end

function CEngageConfirmView.OnConfirmClick(self)
	if self.m_IsReadyEngage then
		return
	end

	--发出订婚请求, 等待对方响应
	if g_AttrCtrl.pid == g_TeamCtrl.m_LeaderID then
		netengage.C2GSStartEngage(g_EngageCtrl.m_Type)
	else
		netengage.C2GSConfirmEngage(1)
	end
end

function CEngageConfirmView.OnCancelClick(self)
	if g_AttrCtrl.pid ~= g_TeamCtrl.m_LeaderID then
		netengage.C2GSCancelEngage()
	end

	if self.m_IsReadyEngage then
		return
	else
		self:CloseView()
	end
end

function CEngageConfirmView.ShowWaitLabel(self)
	if g_AttrCtrl.pid ~= g_TeamCtrl.m_LeaderID then
		return
	end
	self.m_WaitSp:SetActive(true)
	local sWait = "等待对方同意"
	local list = {".", "..", "..."}
	local i = 1
	local update = function()
		self.m_WaitLabel:SetText(sWait..list[i])
		i = i + 1
		if i > 3 then
			i = 1
		end
		return self.m_WaitLabel:GetActive()
	end
	self.m_Timer = Utils.AddTimer(update, 0.5, 0)
end

function CEngageConfirmView.SetButtonGrey(self, bGrey)
	self.m_ConfirmBtn:SetBtnGrey(bGrey)
	self.m_CancelBtn:SetBtnGrey(bGrey)
end

function CEngageConfirmView.OnCancelEngage(self)
	-- 取消订婚 --
	if g_AttrCtrl.pid ~= g_TeamCtrl.m_LeaderID or self.m_IsReadyEngage then
		netengage.C2GSCancelEngage()
		return
	end
	self:CloseView()
end

function CEngageConfirmView.OnEngageEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Engage.Event.EngageSuccess then
		self:CloseView()
	elseif oCtrl.m_EventID == define.Engage.Event.EngageFail then
		self.m_IsReadyEngage = false
		self:CloseView()
	elseif oCtrl.m_EventID == define.Engage.Event.EngageStart then
		self:ShowWaitStatus(2)
	end
end

function CEngageConfirmView.ShowWaitStatus(self, status)
	if status ~= 0 and g_AttrCtrl.pid == g_TeamCtrl.m_LeaderID then
		self:ShowWaitLabel()
		self:SetButtonGrey(true)
		self.m_IsReadyEngage = true
	end
end

function CEngageConfirmView.OnCloseView(self)
	local teamInfo = g_EngageCtrl:GetTeamInfo()
	if table.count(teamInfo) > 2 then
		self:CloseView()
		return
	end

	--partner 准备订婚的伙伴
	local partner = g_EngageCtrl:GetPartnerInfo()

	if not partner or g_AttrCtrl.sex == partner.sex then
		self:CloseView()
		return
	end

	local name = partner.name
	local dText = data.engagedata.TEXT[1027].content
	local text = string.FormatString(dText, {role = name}, true)
	local msg = "[63432C]"..text
	local args = {
		msg = msg,
		okCallback = function()
			self:OnCancelEngage()
		end,
		color = Color.white,
	}
	g_WindowTipCtrl:SetWindowConfirm(args)
end

function CEngageConfirmView.Destroy(self)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
	end
	g_EngageCtrl.m_IsCannotMove = false
	CViewBase.Destroy(self)
end

return CEngageConfirmView