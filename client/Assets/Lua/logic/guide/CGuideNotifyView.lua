local CGuideNotifyView = class("CGuideNotifyView", CViewBase)

function CGuideNotifyView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Guide/GuideNotifyView.prefab", cb)
end

function CGuideNotifyView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_IconSprite = self:NewUI(2, CSprite)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_FunctionBtn = self:NewUI(4, CButton)
	self.m_NameBtn = self:NewUI(5, CLabel)
	self.m_ItemBorderSpr = self:NewUI(6, CSprite)
	self.m_ClickWidget = self:NewUI(7, CWidget)
	self.m_WindowWidget	= self:NewUI(8, CWidget)

	UITools.ResizeToRootSize(self.m_ClickWidget)
	self.m_WindowWidget:SetAnchorTarget(self.m_ClickWidget.m_GameObject, 0, 0, 0, 0)
	self.m_WindowWidget:SetAnchor("leftAnchor", -354, 1)
	self.m_WindowWidget:SetAnchor("rightAnchor", -254, 1)
	self.m_WindowWidget:SetAnchor("topAnchor", -535, 1)
    self.m_WindowWidget:SetAnchor("bottomAnchor", 133, 0)   
	self.m_WindowWidget:ResetAndUpdateAnchors()
	-- self.m_ClickWidget:SetActive(false)

	g_GuideCtrl:AddGuideUI("lead_getride_btn", self.m_FunctionBtn)

	self.m_CloseBtn:SetActive(true)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_FunctionBtn:AddUIEvent("click", callback(self, "OnClickFunction"))
	-- self.m_ClickWidget:AddUIEvent("click", callback(self, "OnClose"))
end

function CGuideNotifyView.RefreshUI(self, iType)
	self.m_CurType = iType
	local oIcon, oAtlas, oDesc = self:GetShowConfig(iType)
	self.m_IconSprite:SetStaticSprite(oAtlas, oIcon)
	self.m_IconSprite:MakePixelPerfect()
	self.m_NameLabel:SetText(oDesc)

	-- if iType == define.GuideNotify.Type.Ride then
	-- 	g_GuideHelpCtrl.m_IsOnlineShowLeadRideGet = true
	-- 	g_GuideCtrl:OnTriggerAll()
	-- end

	--10级礼包不显示关闭按钮
	if iType == define.GuideNotify.Type.GradeGift10 then
		self.m_CloseBtn:SetActive(false)
	end
end

function CGuideNotifyView.OnClickFunction(self)
	if not self.m_CurType then
		return
	end
	if self.m_CurType == define.GuideNotify.Type.GradeGift10 then
		CWelfareView:ShowView(function (oView)
			oView:ForceSelPage(define.WelFare.Tab.UpgradePack)
		end)
	elseif self.m_CurType == define.GuideNotify.Type.GradeGift20 then
		CWelfareView:ShowView(function (oView)
			oView:ForceSelPage(define.WelFare.Tab.UpgradePack)
		end)
	elseif self.m_CurType == define.GuideNotify.Type.GradeGift30 then
		CWelfareView:ShowView(function (oView)
			oView:ForceSelPage(define.WelFare.Tab.UpgradePack)
		end)
	elseif self.m_CurType == define.GuideNotify.Type.GradeGift40 then
		CWelfareView:ShowView(function (oView)
			oView:ForceSelPage(define.WelFare.Tab.UpgradePack)
		end)
	elseif self.m_CurType == define.GuideNotify.Type.XiuLian then
		CSkillMainView:ShowView(function (oView)
            oView:ShowSubPageByIndex(oView:GetPageIndex("Cultivation"))
        end)
	elseif self.m_CurType == define.GuideNotify.Type.GetPartner then
		CPartnerMainView:ShowView(function(oView)
			oView:ResetCloseBtn()
			oView:ShowSubPageByIndex(oView:GetPageIndex("Recruit"))
			oView:SetSpecificPartnerIDNode(g_GuideHelpCtrl:GetPartner1())
			local oTarget = oView.m_PartnerBoxNode.m_PartnerBoxGrid:GetChild(oView.m_PartnerBoxNode.m_GetPartnerIndex)
			if oTarget then
				UITools.MoveToTarget(oView.m_PartnerBoxNode.m_PartnerBoxScroll, oTarget)
			end
		end)
	elseif self.m_CurType == define.GuideNotify.Type.OrgSkill then
		CSkillMainView:ShowView(function (oView)
            oView:ShowSubPageByIndex(oView:GetPageIndex("Org"))
        end)
    elseif self.m_CurType == define.GuideNotify.Type.Ride then
    	CFuncNotifyMainView:ShowView(function (oView)
    		oView:RefreshUI(g_GuideHelpCtrl.m_RideGuideIndex)
    	end)
	else
		
	end
	self:OnClose()

	-- if self.m_CurType == define.GuideNotify.Type.Ride then
	-- 	g_GuideHelpCtrl.m_IsOnlineShowLeadRideGet = true
	-- 	g_GuideCtrl:OnTriggerAll()
	-- end
end

--以后要根据需求修改
function CGuideNotifyView.GetShowConfig(self, iType)
	if iType == define.GuideNotify.Type.GradeGift10 then
		return "pic_missing", "CommonAtlas", "升级了！快来领升级礼包吧！"
	elseif iType == define.GuideNotify.Type.GradeGift20 then
		return "pic_missing", "CommonAtlas", "升级了！快来领升级礼包吧！"
	elseif iType == define.GuideNotify.Type.GradeGift30 then
		return "pic_missing", "CommonAtlas", "升级了！快来领升级礼包吧！"
	elseif iType == define.GuideNotify.Type.GradeGift40 then
		return "pic_missing", "CommonAtlas", "升级了！快来领升级礼包吧！"
	elseif iType == define.GuideNotify.Type.XiuLian then
		return "h7_xiulian_4", "MainMenuAtlas", "修炼系统开启啦！"
	elseif iType == define.GuideNotify.Type.GetPartner then
		return "h7_huoban", "MainMenuAtlas", "可以招募伙伴啦！"
	elseif iType == define.GuideNotify.Type.OrgSkill then
		return "h7_fuzhujineng", "MainMenuAtlas", "辅助技能系统开启啦！"
	elseif iType == define.GuideNotify.Type.Ride then
		return "h7_zuoqi", "MainMenuAtlas", "有坐骑大礼可以领取哦!"
	else
		return "pic_missing", "CommonAtlas", "没有该引导描述"
	end
end

function CGuideNotifyView.OnClose(self)
	-- if self.m_CurType == define.GuideNotify.Type.Ride then
	-- 	g_GuideHelpCtrl.m_IsOnlineShowLeadRideGet = false
	-- 	g_GuideCtrl:OnTriggerAll()
	-- end
	self:CloseView()
end

return CGuideNotifyView