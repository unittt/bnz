local CArenaWitnessListBox = class("CArenaWitnessListBox", CBox)

function CArenaWitnessListBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_BoxClone = self:NewUI(3, CBox)
	self.m_ChooseBox = self:NewUI(4, CChooseBox)
	self.m_EmptyObj = self:NewUI(5, CObject)

	self.m_WitnessBoxs = {}
	self.m_SearchName = ""
	self.m_CurFiterMode = 0
	self.m_FiterMode = {
		["SINGLE"] = 1,
		["TEAM"] = 2,
		["ALL"] = 3,
	}

	self:InitContent()
end

function CArenaWitnessListBox.InitContent(self)
	self.m_BoxClone:SetActive(false)
	self:InitChooseBox()
end

function CArenaWitnessListBox.InitChooseBox(self)
	local tChooseData = {
		[1] = {icon = nil, index = 1, name = "  单人"},
		[2] = {icon = nil, index = 2, name = "  队伍"},
		[3] = {icon = nil, index = 3, name = "  全部"}
	}
	self.m_ChooseBox:SetChooseData(tChooseData, 3)
	self.m_ChooseBox:SetCallback(function(index)
		self.m_CurFiterMode = index
		self:RefreshGrid()
	end)
end

function CArenaWitnessListBox.InitData(self)
	nethuodong.C2GSArenaViewList()
	self.m_ChooseBox:HideChooseListBox()
end

function CArenaWitnessListBox.SetWitnessList(self, list)
	self.m_WitnessList = list
	self:RefreshGrid()
end

function CArenaWitnessListBox.SearchPlayer(self, sName)
	self.m_SearchName = sName
	self:RefreshGrid()
end

function CArenaWitnessListBox.RefreshGrid(self)
	self.m_ScrollView:ResetPosition()
	for k,oBox in pairs(self.m_WitnessBoxs) do
		oBox:SetActive(false)
	end
	local function GetFiterMode(memberCount1, memberCount2)
		if memberCount1 == 0 and memberCount2 == 0 then
			return self.m_FiterMode.SINGLE
		elseif memberCount1 > 0 and memberCount2 > 0 then
			return self.m_FiterMode.TEAM
		end
		return self.m_FiterMode.ALL
	end
	for i,dInfo in ipairs(self.m_WitnessList) do
		if i > 20 and self.m_SearchName == "" then
			break
		end
		local oBox = self.m_WitnessBoxs[i]
		if not oBox then
			oBox = self:CreateBox()
			self.m_WitnessBoxs[i] = oBox
			self.m_Grid:AddChild(oBox)
		end
		self:UpdateBox(oBox, dInfo.fight, dInfo.enemy)
		if self.m_CurFiterMode ~= 0 and self.m_CurFiterMode ~= self.m_FiterMode.ALL then
			local iMode = GetFiterMode(dInfo.fight.count, dInfo.enemy.count)
			if iMode ~= self.m_CurFiterMode and iMode ~= self.m_FiterMode.ALL then
				oBox:SetActive(false)
			end 
		end
	end
	self.m_Grid:Reposition()
	self.m_EmptyObj:SetActive(#self.m_WitnessList == 0)
end

function CArenaWitnessListBox.CreateBox(self)
	local oBox = self.m_BoxClone:Clone()
	oBox.m_LPlayerBox = oBox:NewUI(1, CBox)
	oBox.m_RPlayerBox = oBox:NewUI(2, CBox)
	self:InitPlayerBox(oBox.m_LPlayerBox)
	self:InitPlayerBox(oBox.m_RPlayerBox)
	return oBox 
end

function CArenaWitnessListBox.InitPlayerBox(self, oBox)
	oBox.m_NameL = oBox:NewUI(1, CLabel)
	oBox.m_SchoolSpr = oBox:NewUI(2, CSprite)
	oBox.m_SchoolL = oBox:NewUI(3, CLabel)
	oBox.m_IconSpr = oBox:NewUI(4, CSprite)
	oBox.m_GradeL = oBox:NewUI(5, CLabel)
	oBox.m_TeamCountL = oBox:NewUI(6, CLabel)
	oBox.m_WatchBtn = oBox:NewUI(7, CButton)
end

function CArenaWitnessListBox.UpdateBox(self, oBox, dFighter, dEnemy)
	if self.m_SearchName ~= "" then
		if string.find(dFighter.name, self.m_SearchName) or string.find(dEnemy.name, self.m_SearchName) then
			oBox:SetActive(true)
		end
	else
		oBox:SetActive(true)
	end
	self:UpdatePlayerBox(oBox.m_LPlayerBox, dFighter)
	self:UpdatePlayerBox(oBox.m_RPlayerBox, dEnemy)
end

function CArenaWitnessListBox.UpdatePlayerBox(self, oBox, dPlayer)
	oBox.m_NameL:SetText(dPlayer.name)
	oBox.m_SchoolSpr:SpriteSchool(dPlayer.school)
	oBox.m_SchoolL:SetText(data.schooldata.DATA[dPlayer.school].name)
	oBox.m_IconSpr:SpriteAvatar(dPlayer.icon)
	oBox.m_GradeL:SetText(dPlayer.grade.."级")
	if dPlayer.count == 0 then
		oBox.m_TeamCountL:SetText("单人")
	else
		oBox.m_TeamCountL:SetText(dPlayer.count.."/5")
	end
	oBox.m_WatchBtn:AddUIEvent("click", function()
		g_NotifyCtrl:FloatMsg("请求观战，视角" .. dPlayer.name)
		netplayer.C2GSObserverWar(1, 0, dPlayer.pid)
	end)
end

return CArenaWitnessListBox