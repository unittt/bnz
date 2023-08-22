local CArenaPlayerListBox = class("CArenaPlayerListBox", CBox)

function CArenaPlayerListBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_BoxClone = self:NewUI(3, CBox)
	self.m_ChooseBox = self:NewUI(4, CChooseBox)
	self.m_EmptyObj = self:NewUI(5, CObject)

	self.m_PlayerBoxs = {}
	self.m_SearchName = ""
	self.m_CachePlayer = {}
	self.m_PidList = {}
	self.m_FiterSchool = 0

	self:InitContent()
end

function CArenaPlayerListBox.InitContent(self)
	self.m_BoxClone:SetActive(false)
	self:InitChooseBox()
end

function CArenaPlayerListBox.InitChooseBox(self)
	local tChooseData = {}
	for i,dSchool in ipairs(data.schooldata.DATA) do
		local dInfo = {icon = dSchool.icon, index = i, name = dSchool.name}
		table.insert(tChooseData, dInfo)
	end
	local dInfo = {icon = nil, index = #data.schooldata.DATA + 1, name = "全部门派"}
	table.insert(tChooseData, dInfo)
	self.m_ChooseBox:SetChooseData(tChooseData, dInfo.index)
	self.m_ChooseBox:SetCallback(function(index)
		self.m_FiterSchool = index
		self:RefreshGrid()
	end)
end

function CArenaPlayerListBox.InitData(self, iExtral )
	self.m_PidList = g_MapCtrl:GetArenaPlayerList()
	nethuodong.C2GSArenaFightList(self.m_PidList, 2)
	self.m_ChooseBox:HideChooseListBox()
end

function CArenaPlayerListBox.SetPlayerList(self, list)
	self.m_PlayerList = list
	self:RefreshGrid()
end

function CArenaPlayerListBox.DeletePlayer(self, pid)
	if not self.m_PlayerList then
		return
	end
	for i,dInfo in pairs(self.m_PlayerList) do
		if dInfo.pid == pid then
			table.remove(self.m_PlayerList, i)
			break
		end
	end
	self:RefreshGrid()
end

function CArenaPlayerListBox.SearchPlayer(self, sName)
	self.m_SearchName = sName
	self:RefreshGrid()
end

function CArenaPlayerListBox.SetTargetSchool(self, iSchool)
	self.m_TargetSchool = iSchool
end

function CArenaPlayerListBox.RefreshGrid(self)
	self.m_ScrollView:ResetPosition()
	for k,oBox in pairs(self.m_PlayerBoxs) do
		oBox:SetActive(false)
	end
	local tSourceList = self.m_PlayerList
	if not tSourceList then
		return
	end
	local iSchoolCount = #data.schooldata.DATA
	for i,dInfo in ipairs(tSourceList) do
		if (i > 20 and self.m_SearchName == "" and self.m_TargetSchool == 0) then
			break
		end
		local oBox = self.m_PlayerBoxs[i]
		if not oBox then
			oBox = self:CreatePlayerBox()
			self.m_PlayerBoxs[i] = oBox
			self.m_Grid:AddChild(oBox)
		end
		if self.m_SearchName ~= "" then
			if string.find(dInfo.name, self.m_SearchName) then
				oBox:SetActive(true)
			end
		else
			oBox:SetActive(true)
		end
		if self.m_FiterSchool > 0 and self.m_FiterSchool <= iSchoolCount then
			if self.m_FiterSchool ~= dInfo.school then
				oBox:SetActive(false)
			end
		end
		self:UpdateBox(oBox, dInfo, i)
	end
	self.m_Grid:Reposition()
	self.m_EmptyObj:SetActive(#self.m_PlayerList == 0)
end

function CArenaPlayerListBox.CreatePlayerBox(self)
	local oBox = self.m_BoxClone:Clone()
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_NameL = oBox:NewUI(2, CLabel)
	oBox.m_ScoreL = oBox:NewUI(3, CLabel)
	oBox.m_FightBtn = oBox:NewUI(4, CButton)
	oBox.m_SchoolSpr = oBox:NewUI(5, CSprite)
	oBox.m_SchoolL = oBox:NewUI(6, CLabel)
	oBox.m_GradeL = oBox:NewUI(7, CLabel)
	return oBox
end

function CArenaPlayerListBox.UpdateBox(self, oBox, dInfo, iRank)
	local dData = data.schooldata.DATA[dInfo.school]
	oBox.m_SchoolL:SetText(dData.name)
	oBox.m_NameL:SetText(dInfo.name)
	oBox.m_ScoreL:SetText(dInfo.score)
	oBox.m_IconSpr:SpriteAvatar(dInfo.icon)
	oBox.m_SchoolSpr:SpriteSchool(dInfo.school)
	oBox.m_GradeL:SetText(dInfo.grade.."级")
	oBox.m_FightBtn:AddUIEvent("click", function()
		nethuodong.C2GSArenaFight(g_AttrCtrl.pid, dInfo.pid)
	end)
end


function CArenaPlayerListBox.JumpToTargetSchool(self, iSchoolId)

end

function CArenaPlayerListBox.ChangeChoose(self, iChangeValue)
	
end

return CArenaPlayerListBox