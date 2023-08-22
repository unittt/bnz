local CWorldBossPlunderView = class("CWorldBossPlunderView", CViewBase)

function CWorldBossPlunderView.ctor(self, cb)
	CViewBase.ctor(self, "UI/WorldBoss/WorldBossPlunderView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"
end

function CWorldBossPlunderView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_LineupBtn = self:NewUI(2, CButton)
	self.m_TipL = self:NewUI(3, CLabel)
	self.m_ScrollView = self:NewUI(4, CScrollView)
	self.m_PlayerGird = self:NewUI(5, CGrid)
	self.m_PlayerBoxClone = self:NewUI(6, CBox)
	self.m_WarningL = self:NewUI(7, CLabel)

	self:InitContent()
end

function CWorldBossPlunderView.InitContent(self)
	self.m_PlayerBoxClone:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_LineupBtn:AddUIEvent("click", callback(self, "OnClickLineup"))
	g_WorldBossCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlWorldBossEvent"))
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlWarEvent"))
	nethuodong.C2GSMengzhuOpenPlunder()
end

function CWorldBossPlunderView.OnCtrlWorldBossEvent(self, oCtrl)
	if oCtrl.m_EventID == define.WorldBoss.Event.RefreshPlunderList then
		self:RefreshPlayerGrid()
	elseif oCtrl.m_EventID == define.WorldBoss.Event.RefreshPlunderStatus then
		self:RefreshPlayerBoxByPid(oCtrl.m_EventData.pid, oCtrl.m_EventData.time)
	end
end

function CWorldBossPlunderView.OnCtrlWarEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.WarStart then
		self:CloseView()
   	end
end

function CWorldBossPlunderView.RefreshPlayerGrid(self)
	self.m_PlayerGird:Clear()
	local tPlayerList = g_WorldBossCtrl:GetPlunderList()
	for i,dPlayer in ipairs(tPlayerList) do
		local oBox = self:CreatePlayerBox()
		self.m_PlayerGird:AddChild(oBox)
		self:UpdatePlyerBox(oBox, dPlayer)
	end
	self.m_PlayerGird:Reposition()
	self.m_WarningL:SetActive(#tPlayerList == 0)
end

function CWorldBossPlunderView.CreatePlayerBox(self)
	local oBox = self.m_PlayerBoxClone:Clone()
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_HonorSpr = oBox:NewUI(2, CSprite)
	oBox.m_NameL = oBox:NewUI(3, CLabel)
	oBox.m_SchoolSpr = oBox:NewUI(4, CSprite)
	oBox.m_ScoreL = oBox:NewUI(5, CLabel)
	oBox.m_PlunderBtn = oBox:NewUI(6, CButton)
	oBox.m_GradeL = oBox:NewUI(7, CLabel)
	oBox.m_OrgL = oBox:NewUI(8, CLabel)
	return oBox
end

function CWorldBossPlunderView.UpdatePlyerBox(self, oBox, dPlayer)
	oBox:SetActive(true)
	oBox.m_Pid = dPlayer.role.pid
	oBox.m_IsProtect = dPlayer.protect_time > g_TimeCtrl:GetTimeS()
	oBox.m_IconSpr:SpriteAvatar(dPlayer.role.icon)
	oBox.m_NameL:SetText(dPlayer.role.name)
	oBox.m_SchoolSpr:SpriteSchool(dPlayer.role.school)
	oBox.m_ScoreL:SetText(dPlayer.score)
	oBox.m_GradeL:SetText(dPlayer.role.grade.."级")
	oBox.m_OrgL:SetText(dPlayer.org_name or "暂无")

	if dPlayer.tx_info and dPlayer.tx_info.tid ~= 0 then
		local dData = data.touxiandata.DATA[dPlayer.tx_info.tid]
		oBox.m_HonorSpr:SetSpriteName(dData.tid)
	else
		local vPos = oBox.m_NameL:GetLocalPos()
		vPos.x = vPos.x - 40
		oBox.m_NameL:SetLocalPos(vPos)
		oBox.m_HonorSpr:SetActive(false)
	end
	oBox.m_PlunderBtn:AddUIEvent("click", callback(self, "OnClickPlunder", oBox))
	self:RefreshPlunderButton(oBox, dPlayer.protect_time)
end

function CWorldBossPlunderView.RefreshPlunderButton(self, oBox, iProtectTime)
	if oBox.m_PlunderTimer then
		Utils.DelTimer(oBox.m_PlunderTimer)
		oBox.m_PlunderTimer = nil
	end
	local function update()
		if Utils.IsNil(self) then
			return false
		end
		local iDiffTime = os.difftime(iProtectTime, g_TimeCtrl:GetTimeS())
		oBox.m_PlunderBtn:SetGrey(iDiffTime > 0)
		if iDiffTime > 0 then
			oBox.m_PlunderBtn:SetText(os.date("%M:%S", iDiffTime))
		else
			oBox.m_PlunderBtn:SetText("掠夺")
			oBox.m_IsProtect = false
			return false
		end
		return true
	end
	oBox.m_PlunderTimer = Utils.AddTimer(update, 1, 0)
end

function CWorldBossPlunderView.RefreshPlayerBoxByPid(self, iPid, iProtectTime)
	local list = self.m_PlayerGird:GetChildList()
	for i,oBox in ipairs(list) do
		if oBox.m_Pid == iPid then
			oBox.m_IsProtect = iProtectTime > g_TimeCtrl:GetTimeS()
			self:RefreshPlunderButton(oBox, iProtectTime)
		end
	end
end

function CWorldBossPlunderView.OnClickPlunder(self, oBox)
	if oBox.m_IsProtect then
		g_NotifyCtrl:FloatMsg("保护中")
		return
	end
	nethuodong.C2GSMengzhuStartPlunder(oBox.m_Pid)
	-- self:CloseView()
end

function CWorldBossPlunderView.OnClickLineup(self)
	CPartnerMainView:ShowView( function(oView)
			oView:ResetCloseBtn()
			local index = oView:GetPageIndex("Lineup")
			oView:ShowSubPageByIndex(oView:GetPageIndex("Lineup"))
		end
	)
	-- self:CloseView()
end

return CWorldBossPlunderView