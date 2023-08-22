local CWarFloatView = class("CWarFloatView", CViewBase)

function CWarFloatView.ctor(self, cb)
	CViewBase.ctor(self, "UI/War/WarFloatView.prefab", cb)

	-- self.m_GroupName = "WarMain"
	self.m_DepthType = "Base"
end

function CWarFloatView.OnCreateView(self)
	self.m_AllySelSpr = self:NewUI(1, CSprite)
	self.m_EnemySelSpr = self:NewUI(2, CSprite)
	self.m_BoutTimeBox = self:NewUI(3, CWarBoutTimeBox)
	self.m_BoutTimeTip = self:NewUI(4, CLabel)
	self.m_OrderTipBox = self:NewUI(5, CWarOrderTipBox)
	self.m_MagicNameBox = self:NewUI(6, CWarMagicNameBox)
	self.m_MagicDescBox = self:NewUI(7, CBox)
	self.m_AutoFightWidget = self:NewUI(8, CWidget)
	self.m_BossShotBox = self:NewUI(9, CBox)
	self.m_AlphaAction = nil
	self.m_NumberPos = {}
	self.m_Cached = {}
	self.m_ShowOrderTip = false
	self:InitContent()
end

function CWarFloatView.InitContent(self)
	self.m_AutoFightWidget:SetActive(false)
	self.m_MagicDescBox.m_NameLabel = self.m_MagicDescBox:NewUI(1, CLabel)
	self.m_MagicDescBox.m_DescLabel = self.m_MagicDescBox:NewUI(2, CLabel)
	self.m_BossShotBox.m_Icon = self.m_BossShotBox:NewUI(1, CSprite)
	self.m_BossShotBox.m_Content = self.m_BossShotBox:NewUI(2, CLabel)
	self.m_BossShotBox:SetActive(false)
	local size = Utils.IsWideScreen() and 24 or 20
	self.m_BossShotBox.m_Content:SetFontSize(size)

	self:ResetBoutTimeTip()
	self.m_OrderTipBox:SetActive(false)
	self.m_MagicNameBox:SetActive(false)
	self.m_MagicDescBox:SetAlpha(0)
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CWarFloatView.SetAutoFightSp(self, bActive)
	self.m_AutoFightWidget:SetActive(bActive)
	if bActive then
		self.m_AutoFightWidget:DelEffect("Screen")
		self.m_AutoFightWidget:AddEffect("Screen", "ui_eff_0057")
	else
		self.m_AutoFightWidget:DelEffect("Screen")
	end
end

function CWarFloatView.ShowOrderTip(self)
	local oView = CWarMainView:GetView()
	if oView then
		oView.m_RB:SetActive(false)
	end
	self.m_ShowOrderTip = true
	self.m_OrderTipBox:SetActive(true)
	self.m_OrderTipBox:RefreshTip()
end

function CWarFloatView.HideOrderTip(self)
	if g_WarCtrl.m_IsFirstSpecityWar and g_WarCtrl.m_FirstSpecityWarStep == 1 and g_WarCtrl:GetBout() == 1 then
		return
	end
	self.m_ShowOrderTip = false
	if not g_WarCtrl:IsChallengeType() then
		local oView = CWarMainView:GetView()
		if oView then
			oView.m_RB:SetActive(true)
		end
	end
	self.m_OrderTipBox:SetActive(false)
end

function CWarFloatView.ShowTipBeforeOrder(self)
	if g_WarCtrl:IsChallengeType() or g_WarCtrl:HasChatMsg() or g_WarCtrl.m_IsFirstSpecityWar then
		self.m_OrderTipBox:SetActive(false)
		return
	end
	self.m_OrderTipBox:SetActive(true)
	self.m_OrderTipBox:RefreshTipBefore()
end

function CWarFloatView.ResetBoutTimeTip(self)
	self.m_BoutTimeTip:SetActive(g_WarCtrl.m_WarBoutTips)
	g_WarCtrl.m_WarBoutTips = false
end

function CWarFloatView.MagicName(self, name, duration, warrior)
	self.m_MagicNameBox:Display(name, duration, warrior)
end

function CWarFloatView.ShowMagicDesc(self, magicid)
	if self.m_AlphaAction then
		g_ActionCtrl:DelAction(self.m_AlphaAction)
	end
	local dData = DataTools.GetMagicData(magicid)
	self.m_MagicDescBox.m_NameLabel:SetText(dData.name)
	self.m_MagicDescBox.m_DescLabel:SetText(dData.desc)
	self.m_MagicDescBox:SimulateOnEnable()
	self.m_MagicDescBox:SetAlpha(1)
	self.m_AlphaAction = CActionFloat.New(self.m_MagicDescBox, 2.5, "SetAlpha", 1, 0)
	g_ActionCtrl:AddAction(self.m_AlphaAction, 2.5)
end

function CWarFloatView.HideMagicDesc(self)
	if self.m_AlphaAction then
		g_ActionCtrl:DelAction(self.m_AlphaAction)
	end
	self.m_MagicDescBox:SetAlpha(0)
end

function CWarFloatView.FinishOrder(self)
	self.m_BoutTimeBox:CheckShowWait()
	self:HideOrderTip()
	self:HideMagicDesc()
end

function CWarFloatView.AddMsg(self, sIcon, sMsg, time)
	self.m_BossShotBox:SetActive(true)
	self.m_BossShotBox.m_Icon:SpriteAvatar(sIcon)
	self.m_BossShotBox.m_Content:SetText(sMsg)

	self.m_ContentTimer = Utils.AddTimer(callback(self, "OnTimerUp"), 0, time)
end

function CWarFloatView.OnTimerUp(self)
	if self.m_ContentTimer then
		Utils.DelTimer(self.m_ContentTimer)
		self.m_ContentTimer = nil
	end

	self.m_BossShotBox:SetActive(false)
	return false
end

function CWarFloatView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.AutoWar then
		if g_WarOrderCtrl:IsCanOrder() and not oCtrl:IsAutoWar() then
			self:ShowTipBeforeOrder()
		end
	end
end

return CWarFloatView