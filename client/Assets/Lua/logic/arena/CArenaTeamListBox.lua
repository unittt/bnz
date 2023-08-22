local CArenaTeamListBox = class("CArenaTeamListBox", CBox)

function CArenaTeamListBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_BoxClone = self:NewUI(3, CBox)
	self.m_ChooseBox = self:NewUI(4, CChooseBox)
	self.m_EmptyObj = self:NewUI(5, CObject)

	self.m_TeamBoxs = {}
	self.m_SearchName = ""
	self.m_FiterSchool = 0
	self:InitContent()
end

function CArenaTeamListBox.InitContent(self)
	self.m_BoxClone:SetActive(false)
	self:InitChooseBox()
end

function CArenaTeamListBox.InitChooseBox(self)
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

function CArenaTeamListBox.InitData(self)
	local pidList = g_MapCtrl:GetArenaTeamList()
	nethuodong.C2GSArenaFightList(pidList, 1)
	self.m_ChooseBox:HideChooseListBox()
end

function CArenaTeamListBox.SetTeamList(self, list)
	self.m_TeamList = list
	self:RefreshGrid()
end

function CArenaTeamListBox.SearchPlayer(self, sName)
	self.m_SearchName = sName
	self:RefreshGrid()
end

function CArenaTeamListBox.DeletePlayer(self, pid)
	if not self.m_TeamList then
		return
	end
	for i,dInfo in pairs(self.m_TeamList) do
		if dInfo.leader == pid then
			table.remove(self.m_TeamList, i)
			break
		end
	end
	self:RefreshGrid()
end

function CArenaTeamListBox.RefreshGrid(self)
	self.m_ScrollView:ResetPosition()
	for k,oBox in pairs(self.m_TeamBoxs) do
		oBox:SetActive(false)
	end
	local iSchoolCount = #data.schooldata.DATA
	for i,dInfo in ipairs(self.m_TeamList) do
		if i > 20 and self.m_SearchName == "" then
			break
		end
		local oBox = self.m_TeamBoxs[i]
		if not oBox then
			oBox = self:CreateTeamBox()
			self.m_TeamBoxs[i] = oBox
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
			if self.m_FiterSchool ~= dInfo.member[1].school then
				oBox:SetActive(false)
			end
		end
		self:UpdateBox(oBox, dInfo, i)
	end
	self.m_Grid:Reposition()
	self.m_EmptyObj:SetActive(#self.m_TeamList == 0)
end

function CArenaTeamListBox.CreateTeamBox(self)
	local oBox = self.m_BoxClone:Clone()
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_NameL = oBox:NewUI(2, CLabel)
	oBox.m_SchoolL = oBox:NewUI(3, CLabel)
	oBox.m_SchoolSpr = oBox:NewUI(4, CSprite)
	oBox.m_GradeL = oBox:NewUI(5, CLabel)
	oBox.m_FightBtn = oBox:NewUI(6, CButton)
	oBox.m_MemGrid = oBox:NewUI(7, CGrid)
	local function initbox(obj, idx)
		local oMemBox = CBox.New(obj)
		oMemBox.m_SchoolSpr = oMemBox:NewUI(1, CSprite)
		oMemBox.m_IconSpr = oMemBox:NewUI(2, CSprite)
		oMemBox.m_GradeL = oMemBox:NewUI(3, CLabel)
		return oMemBox
	end
	oBox.m_MemGrid:InitChild(initbox)
	return oBox
end

function CArenaTeamListBox.UpdateBox(self, oBox, dInfo)
	local dLeader = dInfo.member[1]
	oBox.m_IconSpr:SpriteAvatar(dLeader.icon)
	oBox.m_NameL:SetText(dLeader.name)
	oBox.m_SchoolSpr:SpriteSchool(dLeader.school)
	oBox.m_SchoolL:SetText(data.schooldata.DATA[dLeader.school].name)
	oBox.m_GradeL:SetText(dLeader.grade.."级")
	self:UpdateMemberGrid(oBox, dInfo.member)
	oBox.m_FightBtn:AddUIEvent("click", function()
		nethuodong.C2GSArenaFight(g_AttrCtrl.pid, dInfo.leader)
	end)
end

function CArenaTeamListBox.UpdateMemberGrid(self, oBox, dMemList)
	for i,oMemBox in ipairs(oBox.m_MemGrid:GetChildList()) do
		local dMember = dMemList[i + 1]
		oMemBox.m_SchoolSpr:SetActive(dMember ~= nil)
		oMemBox.m_IconSpr:SetActive(dMember ~= nil)
		oMemBox.m_GradeL:SetActive(dMember ~= nil)
		if dMember then
			oMemBox.m_IconSpr:SpriteAvatar(dMember.icon)
			oMemBox.m_SchoolSpr:SpriteSchool(dMember.school)
			oMemBox.m_GradeL:SetText(dMember.grade.."级")
		end
	end
end

return CArenaTeamListBox