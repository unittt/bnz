local CTeamWarCmdView = class("CTeamWarCmdView", CViewBase)

function CTeamWarCmdView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Team/TeamWarCmdView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CTeamWarCmdView.OnCreateView(self)
	self.m_EnemyTab = self:NewUI(1, CButton)
	self.m_MemberTab = self:NewUI(2, CButton)
	self.m_CmdGrid = self:NewUI(3, CGrid)
	self.m_CmdBox = self:NewUI(4, CBox)
	self.m_CloseBtn = self:NewUI(5, CButton)

	self.m_Type = {
		Member = 1,
		Enemy = 2,
	}
	self.m_CurType = self.m_Type.Member
	self.m_DefaultCmdSize = 5
	self.m_CmdUpper = 9
	self.m_Input = nil
	self:InitContent()
end

function CTeamWarCmdView.InitContent(self)
	self.m_CmdBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_EnemyTab:AddUIEvent("click", callback(self, "ChangeTab", self.m_EnemyTab))
	self.m_MemberTab:AddUIEvent("click", callback(self, "ChangeTab", self.m_MemberTab))

	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self:ChangeTab(self.m_EnemyTab)
end

function CTeamWarCmdView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.RefreshWarCmd then
		self:RefreshCmdGrid()
	end
end

function CTeamWarCmdView.RefreshCmdGrid(self)
	-- printc("refresh")
	self.m_CmdGrid:Clear()
	g_TeamCtrl:InitLocalWarCmdList()
	local list = g_TeamCtrl:GetWarCmdList(self.m_CurType)
	if not list then
		printerror("not found")
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
end

function CTeamWarCmdView.AddCmdBox(self, iPos, sCmd)
	local oBox = self.m_CmdBox:Clone()
	oBox.m_CmdLabel = oBox:NewUI(1, CLabel)
	oBox.m_EditSpr = oBox:NewUI(2, CSprite)
	oBox.m_AddSpr = oBox:NewUI(3, CSprite)

	oBox.m_Pos = iPos
	oBox.m_Cmd = sCmd
	oBox.m_IsCanEdit = iPos > self.m_DefaultCmdSize
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

function CTeamWarCmdView.ChangeTab(self, oTab)
	if self.m_CurTab == oTab then
		return
	end
	oTab:SetSelected(true)
	self.m_CurTab = oTab
	self.m_CurType = self.m_CurType%2 + 1
	self:RefreshCmdGrid()
end

function CTeamWarCmdView.OnClickCmdBox(self, oBox)
	local cb = nil
	if not oBox.m_IsCanEdit and not oBox.m_IsEmpty then
		g_NotifyCtrl:FloatMsg("该指令不可编辑")
		return
	end
	if oBox.m_IsEmpty then
		cb = function(input)
			local inputStr = input:GetText()
			if string.len(inputStr) > 0 then
				netteam.C2GSAddTeamWarCmd(self.m_CurType, inputStr)
			end
		end
	elseif oBox.m_IsCanEdit then
		cb = function(input)
			local inputStr = input:GetText()
			netteam.C2GSSetTeamWarCmd(inputStr, oBox.m_Pos, self.m_CurType)
		end
	end
	local defaultText = oBox.m_Cmd
	if oBox.m_Cmd == nil or oBox.m_Cmd == "" then
		defaultText = nil
	end
	self:OpenInputWindow(cb, defaultText)
end

function CTeamWarCmdView.OpenInputWindow(self, cb, defaultText)
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

return CTeamWarCmdView