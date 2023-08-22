local CArenaMainView = class("CArenaMainView", CViewBase)

function CArenaMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Arena/ArenaMainView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CArenaMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TabGrid = self:NewUI(2, CGrid) 
	self.m_PlayerListBox = self:NewUI(3, CArenaPlayerListBox)
	self.m_TeamListBox = self:NewUI(4, CArenaTeamListBox)
	self.m_WitnessListBox = self:NewUI(5, CArenaWitnessListBox)
	self.m_SearchInput = self:NewUI(6, CInput)
	self.m_SearchBtn  = self:NewUI(7, CButton)
	self.m_ClearBtn = self:NewUI(8, CButton)
	self.m_RefreshBtn = self:NewUI(9, CButton)

	self.m_TabGrid:InitChild(function (obj, idx) return CButton.New(obj) end)

	self.m_Boxs = {
		[1] = self.m_PlayerListBox,
		[2] = self.m_TeamListBox,
		[3] = self.m_WitnessListBox
	}
	self.m_SearchName = ""
	self:InitContent()
end

function CArenaMainView.InitContent(self)
	self.m_SearchInput:SetCharLimit(12)
	self.m_ClearBtn:SetActive(false)
	local tabList = self.m_TabGrid:GetChildList()
	for i,oTab in ipairs(tabList) do
		oTab:AddUIEvent("click", callback(self, "ChangeTab", i))
	end
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_SearchBtn:AddUIEvent("click", callback(self, "OnSearchPlayer"))
	self.m_ClearBtn:AddUIEvent("click", callback(self, "OnClearInput"))
	self.m_RefreshBtn:AddUIEvent("click", callback(self, "OnRefresh"))

	self:ChangeTab(1)
end

function CArenaMainView.ChangeTab(self, iTab)
	for i,oBox in ipairs(self.m_Boxs) do
		oBox:SetActive(iTab == i)
		if oBox:GetActive() then
			oBox:InitData()
		end
	end
	if self.m_SearchInput:GetText() ~= "" then
		self:OnClearInput()
	end
	self.m_CurTab = iTab
	local oTab = self.m_TabGrid:GetChild(iTab)
	oTab:SetSelected(true)
end

function CArenaMainView.SetWitnessList(self, list)
	self.m_WitnessListBox:SetWitnessList(list)
end

function CArenaMainView.SetPlayerInfos(self, playerList, teamList, bIsTeam)
	if self.m_SearchName == "" then
		if bIsTeam then
			self.m_TeamListBox:SetTeamList(teamList)
		else
			self.m_PlayerListBox:SetPlayerList(playerList)
			table.print(playerList)
		end
	end
end

function CArenaMainView.DeletePlayer(self, pid)
	self.m_PlayerListBox:DeletePlayer(pid)
	self.m_TeamListBox:DeletePlayer(pid)
end

function CArenaMainView.OnSearchPlayer(self)
	self.m_ClearBtn:SetActive(true)
	self.m_SearchName = self.m_SearchInput:GetText()
	if self.m_SearchName == "" then
		g_NotifyCtrl:FloatMsg(data.arenadata.TEXT[1017].content)
		return
	end
	local function FindPlayer(iPid, sName)
		for _,oPlayer in pairs(g_MapCtrl.m_Players) do
			if g_MapCtrl:CheckInArenaArea(oPlayer) and 
				(oPlayer.m_RealName == sName or oPlayer.m_Pid == iPid) then
				return oPlayer.m_Pid
			end
		end
		return -1
	end
	local iPid = FindPlayer(tonumber(self.m_SearchName), self.m_SearchName)
	if iPid == -1 or not iPid then
		local sMsg = string.gsub(data.arenadata.TEXT[1003].content, "#role", self.m_SearchName)
		g_NotifyCtrl:FloatMsg(sMsg)
	else
		netplayer.C2GSGetPlayerInfo(iPid)
		self:CloseView()
	end
end

function CArenaMainView.OnClearInput(self)
	self.m_SearchName = ""
	self.m_SearchInput:SetText("")
	self.m_ClearBtn:SetActive(false)
	self.m_Boxs[self.m_CurTab]:SearchPlayer(self.m_SearchName)
end

function CArenaMainView.OnRefresh(self)
	self.m_Boxs[self.m_CurTab]:InitData()
end
return CArenaMainView