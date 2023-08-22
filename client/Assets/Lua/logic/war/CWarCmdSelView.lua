local CWarCmdSelView = class("", CViewBase)

function CWarCmdSelView.ctor(self, cb)
	CViewBase.ctor(self, "UI/War/WarCmdSelView.prefab", cb)
	self.m_ExtendClose = "ClickOut"
end

function CWarCmdSelView.OnCreateView(self)
	self.m_EnemyTab = self:NewUI(1, CButton)
	self.m_MemberTab = self:NewUI(2, CButton)
	self.m_CmdGrid = self:NewUI(3, CGrid)
	self.m_CmdBoxClone = self:NewUI(4, CBox)
	self.m_AutoClearCheckBox = self:NewUI(5, CWidget)
	self.m_MaskCheckBox = self:NewUI(6, CWidget)
	self.m_AppointBtn = self:NewUI(7, CButton)
	self.m_CloseBtn = self:NewUI(8, CButton)
	self.m_ClearBtnClone = self:NewUI(9, CButton)
	self.m_TitleL = self:NewUI(10, CLabel)
	
	self.m_Tabs = {
		[define.Team.WarCmdTarget.Member] = self.m_MemberTab,
		[define.Team.WarCmdTarget.Enemy] = self.m_EnemyTab	
	}
	self.m_Titles = {
		[define.Team.WarCmdTarget.Member] = "我方指令",
		[define.Team.WarCmdTarget.Enemy] = "敌方指令"
	}
	self.m_CurTab = -1
	self.m_DefaultCmdSize = 5
	self.m_CmdUpper = 9
	self.m_Input = nil
	self:InitContent()
end

function CWarCmdSelView.InitContent(self)
	self.m_AppointBtn:SetActive(g_TeamCtrl:IsLeader())
	self.m_CmdBoxClone:SetActive(false)
	self.m_ClearBtnClone:SetActive(false)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_AutoClearCheckBox:AddUIEvent("click", callback(self, "OnClickAutoClearCmd"))
	self.m_MaskCheckBox:AddUIEvent("click", callback(self, "OnClickMaskCmd"))
	self.m_AppointBtn:AddUIEvent("click", callback(self, "OnClickAppoint"))
	self.m_EnemyTab:AddUIEvent("click", callback(self, "ChangeTab", define.Team.WarCmdTarget.Enemy))
	self.m_MemberTab:AddUIEvent("click", callback(self, "ChangeTab", define.Team.WarCmdTarget.Member))

	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self:RefreshCheckBox()
	self:ChangeTab(define.Team.WarCmdTarget.Enemy)
end

function CWarCmdSelView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.RefreshWarCmd then
		self:RefreshCmdGrid()
	end
end

function CWarCmdSelView.SetTarget(self, oWarrior)
	self.m_WarriorRef = weakref(oWarrior)
	local oSelectedTab = nil
	self.m_AppointBtn:SetActive(false)
	if oWarrior:IsAlly() then
		self:SetTargetType(define.Team.WarCmdTarget.Member)
		oSelectedTab = self.m_MemberTab
		self.m_Pid = oWarrior.m_Pid
		self.m_AppointBtn:SetActive(g_TeamCtrl:IsLeader() and oWarrior:IsPlayer())
	else
		oSelectedTab = self.m_EnemyTab
		self:SetTargetType(define.Team.WarCmdTarget.Enemy)
	end
	for _,oTab in pairs(self.m_Tabs) do
		if oTab == oSelectedTab then
			oTab:SetSelected(true)
		else
			oTab:EnableTouch(false)
			oTab:SetGrey(true)
		end
	end
end

function CWarCmdSelView.SetTargetType(self, iType)
	self.m_CurTab = iType
	self.m_TitleL:SetText(self.m_Titles[iType])
	self:RefreshCmdGrid()
end

function CWarCmdSelView.RefreshCmdGrid(self)
	self.m_CmdGrid:Clear()
	g_TeamCtrl:InitLocalWarCmdList()
	local list = g_TeamCtrl:GetWarCmdList(self.m_CurTab)
	if not list then
		printerror("CWarCmdSelView.RefreshCmdGrid -->> not found cmdlist")
		return
	end
	local iCnt = 0
	for pos, cmd in ipairs(list) do
		if cmd ~= "" then
			iCnt = iCnt + 1
			self:AddCmdBox(iCnt, cmd)
		end		
	end
	if iCnt < self.m_CmdUpper then
		self:AddCmdBox(0, "")
	end
	self:AddClearButton()
end

function CWarCmdSelView.AddClearButton(self)
	local oBtn = self.m_ClearBtnClone:Clone()
	oBtn:SetActive(true)
	oBtn:AddUIEvent("click", callback(self, "OnClickClearCmd"))
	self.m_CmdGrid:AddChild(oBtn)
end

function CWarCmdSelView.AddCmdBox(self, iPos, sCmd)
	local oBox = self.m_CmdBoxClone:Clone()
	oBox.m_CmdLabel = oBox:NewUI(1, CLabel)
	oBox.m_EditSpr = oBox:NewUI(2, CSprite)
	oBox.m_AddSpr = oBox:NewUI(3, CSprite)

	oBox.m_Pos = iPos
	oBox.m_Cmd = sCmd
	oBox.m_IsCanEdit = false--iPos > self.m_DefaultCmdSize
	oBox.m_IsEmpty = sCmd == "" 

	oBox:SetActive(true)
	oBox.m_CmdLabel:SetText(sCmd)

	if oBox.m_IsCanEdit then
		-- 985F32
		oBox.m_CmdLabel:SetColor(Color.New(0x98/0xff, 0x5f/0xff, 0x32/0xff, 1))
		local pos = oBox.m_CmdLabel:GetLocalPos()
		pos.x = pos.x - 18
		oBox.m_CmdLabel:SetLocalPos(pos)
	end

	oBox.m_CmdLabel:SetActive(not oBox.m_IsEmpty)
	oBox.m_EditSpr:SetActive(oBox.m_IsCanEdit)
	oBox.m_AddSpr:SetActive(oBox.m_IsEmpty)
	oBox:AddUIEvent("click", callback(self, "OnClickCmdBox", oBox))

	self.m_CmdGrid:AddChild(oBox)
end

function CWarCmdSelView.RefreshCheckBox(self)
	self.m_AutoClearCheckBox:SetSelected(g_WarCtrl.m_ClearTeamCmd ~= nil and g_WarCtrl.m_ClearTeamCmd)
	self.m_MaskCheckBox:SetSelected(g_WarCtrl.m_MaskTeamCmd ~= nil and g_WarCtrl.m_MaskTeamCmd)
end

function CWarCmdSelView.OnClickClearCmd(self)
	if not g_TeamCtrl:IsCommander(g_AttrCtrl.pid) then
		g_NotifyCtrl:FloatMsg("只有战斗指挥才可使用")
		return
	end
	if self.m_WarriorRef then
		local oWarrior = getrefobj(self.m_WarriorRef)
		netwar.C2GSWarCommand(g_WarCtrl:GetWarID(), g_WarCtrl.m_HeroWid, oWarrior.m_ID)
	else
		g_WarOrderCtrl:SetGlobalOrder("ClearTeamCmd")
	end
	self:CloseView()
end

function CWarCmdSelView.OnClickAutoClearCmd(self)
	local iOp = self.m_AutoClearCheckBox:GetSelected() and 1 or 0
	netwar.C2GSWarCommandOP(g_WarCtrl:GetWarID(), g_WarCtrl.m_HeroWid, iOp)
	g_WarCtrl.m_ClearTeamCmd = self.m_AutoClearCheckBox:GetSelected()
end

function CWarCmdSelView.OnClickMaskCmd(self)
	local bIsMaskCmd = self.m_MaskCheckBox:GetSelected()
	g_WarCtrl.m_MaskTeamCmd = bIsMaskCmd
	--TODO:刷新战斗中角色的指挥命令
	local oCmd = CWarCmd.New("MaskWarCommond")
	-- g_WarCtrl:SetVaryCmd(oCmd)
	g_WarCtrl:InsertCmd(oCmd)
end

function CWarCmdSelView.OnClickAppoint(self)
	if self.m_WarriorRef then
		if self.m_Pid and self.m_Pid ~= g_AttrCtrl.m_Pid then
			netteam.C2GSSetAppointMem(self.m_Pid, 1)
		end
	else
		g_WarOrderCtrl:SetGlobalOrder("TeamAppoint")
	end
	self:CloseView()
end

function CWarCmdSelView.OnClickCmdBox(self, oBox)
	local cb = nil
	if not oBox.m_IsEmpty then
		-- g_NotifyCtrl:FloatMsg("该指令不可编辑")
		if not g_TeamCtrl:IsCommander(g_AttrCtrl.pid) then
			g_NotifyCtrl:FloatMsg("没有指挥权限")
			return
		end
		if self.m_WarriorRef then
			local oWarrior = getrefobj(self.m_WarriorRef)
			netwar.C2GSWarCommand(g_WarCtrl:GetWarID(), g_WarCtrl.m_HeroWid, oWarrior.m_ID, oBox.m_Cmd)
		else
			g_WarOrderCtrl:SetGlobalOrder("AddTeamCmd", self.m_CurTab, oBox.m_Cmd)
		end
		self:CloseView()
		return
	end
	if oBox.m_IsEmpty then
		cb = function(input)
			local inputStr = input:GetText()
			if string.len(inputStr) > 0 then
				netteam.C2GSAddTeamWarCmd(self.m_CurTab, inputStr)
			end
		end
	elseif oBox.m_IsCanEdit then
		cb = function(input)
			local inputStr = input:GetText()
			netteam.C2GSSetTeamWarCmd(inputStr, oBox.m_Pos, self.m_CurTab)
		end
	end
	local defaultText = oBox.m_Cmd
	if oBox.m_Cmd == nil or oBox.m_Cmd == "" then
		defaultText = nil
	end
	self:OpenInputWindow(cb, defaultText)
end

function CWarCmdSelView.OpenInputWindow(self, cb, defaultText)
	local windowInputInfo = {
		des				= "[63432c]指令输入：最多4个字[-]",
		title			= "指令编辑",
		inputLimit		= 8,
		defaultText     = defaultText,
		isclose         = false,
		cancelCallback	= function () end,
		okCallback = function (input)
			local inputStr = input:GetText()
			if inputStr and string.len(inputStr) > 0 then
				if g_MaskWordCtrl:IsContainMaskWord(inputStr) then
					g_NotifyCtrl:FloatMsg("包含屏蔽字，请重新输入")
					return true
				end
			end
			cb(input)
			if self.m_WinInputViwe then
				self.m_WinInputViwe:OnClose()
				self.m_WinInputViwe = nil
			end
		end,
	}
	g_WindowTipCtrl:SetWindowInput(windowInputInfo, function (oView)
		self.m_WinInputViwe = oView
		oView.m_NameInput:SetText(defaultText)
	end)
end

function CWarCmdSelView.ChangeTab(self, iTab)
	if self.m_CurTab == iTab then
		return
	end
	local oTab = self.m_Tabs[iTab]
	oTab:SetSelected(true)
	self.m_CurTab = iTab
	self.m_TitleL:SetText(self.m_Titles[iTab])
	self:RefreshCmdGrid()
end

return CWarCmdSelView