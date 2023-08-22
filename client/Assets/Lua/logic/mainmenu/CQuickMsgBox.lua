local CQuickMsgBox = class("CQuickMsgBox", CBox)

function CQuickMsgBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Grid = self:NewUI(1, CGrid)
	self.m_FriendMsgBtn = self:NewUI(2, CSprite)
	self.m_MailBtn = self:NewUI(3, CButton) 
	self.m_ArenaBtn = self:NewUI(4, CButton) 
	self.m_TeamInviteBtn = self:NewUI(5, CButton)
	self.m_TeamApplyBtn = self:NewUI(6, CButton)
	self.m_MailUnopenFullSpr = self:NewUI(7, CLabel)
	--self.m_TempBagBtn = self:NewUI(8,CButton)
	self.m_OrgInviteBtn = self:NewUI(8, CButton)
	self:InitContent()
	
end

function CQuickMsgBox.InitContent(self)
	self.m_FriendMsgBtn:AddUIEvent("click", callback(self, "OnFriendMsg"))
	self.m_MailBtn:AddUIEvent("click", callback(self, "OnMailBtn"))
	self.m_ArenaBtn:AddUIEvent("click", callback(self, "OnArena"))
	self.m_TeamApplyBtn:AddUIEvent("click", callback(self, "OnTeamApply"))
	self.m_TeamInviteBtn:AddUIEvent("click", callback(self, "OnTeamInvite"))
	self.m_OrgInviteBtn:AddUIEvent("click", callback(self, "OnOrgInvite"))
	

	self:RefreshMailBtn()
	self:RefreshArenaBtn()
	self:RefrehTeamNotifyTip()
	self:RefreshOrgInviteBtn(false)
	--self:CheckTempItemBtn()
end

-----------------------------按钮刷新----------------------------------
--刷新入帮邀请按钮
function CQuickMsgBox.RefreshOrgInviteBtn(self, bIsActive)
	self.m_OrgInviteBtn:SetActive(bIsActive)
	self:RefreshGrid()
end


--刷新好友或陌生人消息通知按钮
function CQuickMsgBox.RefreshFriendMsgBtn(self,bIsActive)
	self.m_FriendMsgBtn:SetActive(bIsActive)
	self:RefreshGrid()
end

-- 刷新邮件按钮
function CQuickMsgBox.RefreshMailBtn(self)
	--暂时屏蔽主界面邮件小图标
	if true then
		self.m_MailBtn:SetActive(false)
		self.m_MailUnopenFullSpr:SetActive(false)
		return
	end
	local oView = CFriendInfoView:GetView()
	if oView then
		self.m_MailBtn:SetActive(false)
		self.m_MailUnopenFullSpr:SetActive(false)
	else
		local numUnopen = g_MailCtrl:GetUnOpenedMailsNum()
		if numUnopen <= 0 then
			self.m_MailBtn:SetActive(false)
			self.m_MailUnopenFullSpr:SetActive(false)
		elseif 0 < numUnopen and numUnopen < 10 then
			self.m_MailBtn:SetActive(true)
			self.m_MailUnopenFullSpr:SetActive(false)
		elseif numUnopen >= 10 then
			self.m_MailBtn:SetActive(true)
			self.m_MailUnopenFullSpr:SetActive(true)
		end
	end
	self:RefreshGrid()
end

function CQuickMsgBox.RefreshArenaBtn(self, bIsInArena)
	if bIsInArena == nil then
		bIsInArena = false
		local oHero = g_MapCtrl:GetHero()
		if oHero then
			bIsInArena = oHero.m_IsInArena
		end
	end
	self.m_ArenaBtn:SetActive(bIsInArena)
	self:RefreshGrid()
end

function CQuickMsgBox.RefrehTeamNotifyTip(self)
	local bIsApply = g_TeamCtrl:IsJoinTeam() and table.count(g_TeamCtrl.m_UnreadApply) > 0 and g_TeamCtrl:IsLeader(g_AttrCtrl.pid)
	local bIsInvite = false--not g_TeamCtrl:IsJoinTeam() and table.count(g_TeamCtrl.m_UnreadInvite) > 0
	self.m_TeamInviteBtn:SetActive(bIsInvite)
	self.m_TeamApplyBtn:SetActive(bIsApply)
	self:RefreshGrid()
end

function CQuickMsgBox.RefreshGrid(self)
	self.m_Grid:Reposition()
end
-----------------------------按钮响应----------------------------------
function CQuickMsgBox.OnClickBtn(self)
	CItemTempBagView:ShowView()
end
function CQuickMsgBox.OnFriendMsg(self)	
	--暂时屏蔽一条消息打开聊天界面
	-- if g_TalkCtrl:GetRecentTalkRoleCount() == 1 then
 --        local pid = g_TalkCtrl:GetRecentTalk()
 --        if g_TalkCtrl:GetTotalNotify() and pid then
 --            CFriendInfoView:ShowView(function (oView)
 --            oView:ShowTalk(pid)
 --            oView.m_Brief.m_RecentTabBtn:SetSelected(true)
 --            end)
 --        end
 --    else
 --    	CFriendInfoView:ShowView(function (oView)
	-- 		oView.m_Brief:ShowRecent()
	-- 		oView.m_Brief.m_RecentTabBtn:SetSelected(true)
	-- 	end)
 --    end
    CFriendInfoView:ShowView(function (oView)
		oView.m_Brief:ShowRecent()
		oView.m_Brief.m_RecentTabBtn:SetSelected(true)
	end)
	CChatMainView:CloseView()
	self.m_FriendMsgBtn:SetActive(false)
	self:RefreshGrid()
end

function CQuickMsgBox.OnMailBtn(self)
	CFriendInfoView:ShowView(
		function (oView)
			oView:ShowMail()
		end
	)
	CChatMainView:CloseView()
	self.m_MailBtn:SetActive(false)
	self:RefreshGrid()
end

function CQuickMsgBox.OnTeamApply(self)
	self.m_TeamApplyBtn:SetActive(false)
	if next(g_TeamCtrl.m_Applys) then
		-- CTeamApplyView:ShowView()
		netteam.C2GSTeamApplyInfo()
		g_TeamCtrl:ReadApply()
	else
		g_NotifyCtrl:FloatMsg("暂时还没有人申请入队哦")
	end
	self:RefreshGrid()
end

function CQuickMsgBox.OnTeamInvite(self)
	self.m_TeamInviteBtn:SetActive(false)
	if next(g_TeamCtrl.m_Invites) then
		-- CTeamInviteView:ShowView()
		netteam.C2GSTeamInviteInfo()
		g_TeamCtrl:ReadInvite()
	else
		g_NotifyCtrl:FloatMsg("暂时还没有人邀请你入队哦")
	end
	self:RefreshGrid()
end

function CQuickMsgBox.OnArena(self)
	CArenaMainView:ShowView()
end

function CQuickMsgBox.OnOrgInvite(self)
	self.m_OrgInviteBtn:SetActive(false)
	if next(g_OrgCtrl.m_InviteOrgInfo) then
		local pbdata = g_OrgCtrl.m_InviteOrgInfo
		local windowConfirmInfo = {
	        msg             = pbdata.pname.."\n邀请您加入\n"..pbdata.org_level.."级["..pbdata.org_name.."]帮派",
	        title           = "入帮邀请",
	        okStr           = "同意",
	        cancelStr       = "拒绝",
	        --0拒绝邀请 1接受邀请
	        okCallback = function() netorg.C2GSDealInvited2Org(pbdata.pid, 1) end,
	        cancelCallback = function() netorg.C2GSDealInvited2Org(pbdata.pid, 0) end,
	        alignmemt = 2,
	    }
	    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)
	        self.m_WinTipViwe = oView
	    end)
	end
end 
return CQuickMsgBox