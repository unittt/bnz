local CSoccerTeamSupportBox = class("CSoccerTeamSupportBox", CBox)

function CSoccerTeamSupportBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_GroupText = self:NewUI(1, CLabel)

	self.m_oneNationalNameText = self:NewUI(2, CLabel)
	self.m_oneNationalFlagAtlas = self:NewUI(3, CSprite)
	self.m_oneSupportBtn = self:NewUI(4, CButton)
	self.m_oneSupportText = self:NewUI(5, CLabel)
	self.m_oneCancelSupportBtn = self:NewUI(6, CButton)

	self.m_twoNationalNameText = self:NewUI(7, CLabel)
	self.m_twoNationalFlagAtlas = self:NewUI(8, CSprite)
	self.m_twoSupportBtn = self:NewUI(9, CButton)
	self.m_twoSupportText = self:NewUI(10, CLabel)
	self.m_twoCancelSupportBtn = self:NewUI(11, CButton)

	self.m_threeNationalNameText = self:NewUI(12, CLabel)
	self.m_threeNationalFlagAtlas = self:NewUI(13, CSprite)
	self.m_threeSupportBtn = self:NewUI(14, CButton)
	self.m_threeSupportText = self:NewUI(15, CLabel)
	self.m_threeCancelSupportBtn = self:NewUI(16, CButton)

	self.m_fourNationalNameText = self:NewUI(17, CLabel)
	self.m_fourNationalFlagAtlas = self:NewUI(18, CSprite)
	self.m_fourSupportBtn = self:NewUI(19, CButton)
	self.m_fourSupportText = self:NewUI(20, CLabel)
	self.m_fourCancelSupportBtn = self:NewUI(21, CButton)

	--具体数据 begin
	self.m_GroupIndex = 1		--小组的下标(1==A, 2==B, 3==C, 4==D, 5==E, 6==F, 7==G, 8==H)
	self.m_GroupTeams = nil 	--小组所在的4个队伍的Id

	self.m_Group = {"A", "B", "C", "D", "E", "F", "G", "H"}
	--具体数据 end

	self:InitContent()
end

function CSoccerTeamSupportBox.Destroy(self)
	self.m_GroupIndex = 1
	self.m_GroupTeams = nil

	CBox.Destroy(self)
end

function CSoccerTeamSupportBox.InitContent(self)
	self.m_oneSupportBtn:AddUIEvent("click", callback(self, "OnClickOneSupportBtn"))
	self.m_oneCancelSupportBtn:AddUIEvent("click", callback(self, "OnClickOneCancelSupportBtn"))
	self.m_twoSupportBtn:AddUIEvent("click", callback(self, "OnClickTwoSupportBtn"))
	self.m_twoCancelSupportBtn:AddUIEvent("click", callback(self, "OnClickTwoCancelSupportBtn"))
	self.m_threeSupportBtn:AddUIEvent("click", callback(self, "OnClickThreeSupportBtn"))
	self.m_threeCancelSupportBtn:AddUIEvent("click", callback(self, "OnClickThreeCancelSupportBtn"))
	self.m_fourSupportBtn:AddUIEvent("click", callback(self, "OnClickFourSupportBtn"))
	self.m_fourCancelSupportBtn:AddUIEvent("click", callback(self, "OnClickFourCancelSupportBtn"))

	g_SoccerTeamSupportCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CSoccerTeamSupportBox.SetGroupTeams(self, groupIndex, groupTeams)
	self.m_GroupIndex = groupIndex
	self.m_GroupTeams = groupTeams

	self:RefreshTeamsUI()
end

function CSoccerTeamSupportBox.RefreshUnit(self)
	printc("CSoccerTeamSupportBox.RefreshUnit self.m_GroupIndex:", self.m_GroupIndex, " g_SoccerTeamSupportCtrl.m_SupportInfoUnit.team_id:", g_SoccerTeamSupportCtrl.m_SupportInfoUnit.team_id)
	for i, v in ipairs(self.m_GroupTeams) do
		if v == g_SoccerTeamSupportCtrl.m_SupportInfoUnit.team_id then
			if i == 1 then
				self:RefreshUnitForOne(g_SoccerTeamSupportCtrl.m_SupportInfoUnit.num)
			elseif i == 2 then
				self:RefreshUnitForTwo(g_SoccerTeamSupportCtrl.m_SupportInfoUnit.num)
			elseif i == 3 then
				self:RefreshUnitForThree(g_SoccerTeamSupportCtrl.m_SupportInfoUnit.num)
			elseif i == 4 then
				self:RefreshUnitForFour(g_SoccerTeamSupportCtrl.m_SupportInfoUnit.num)
			end
		end	
	end
end

function CSoccerTeamSupportBox.IsOneOfGroupTeam(self, teamId)
	if self.m_GroupTeams == nil then
		return false
	end

	for k, v in pairs(self.m_GroupTeams) do
		if v == teamId then
			return true
		end	
	end

	return false
end

function CSoccerTeamSupportBox.OnClickOneSupportBtn(self)
	printc("CSoccerTeamSupportBox.OnClickOneSupportBtn")
	local key = self.m_GroupTeams ~= nil and self.m_GroupTeams[1] or 1001
	local country = data.worldcupdata.CONFIG[key] ~= nil and data.worldcupdata.CONFIG[key].country or "中国"
	local windowConfirmInfo = {
		title = "提示",
		msg = string.format("[c][63432C]确定要支持[[1D8E00]%s[-]]吗？", country),
		cancelCallback = function ()
		end,
		cancelStr = "取消",
		okCallback = function()
			self:SupportOne()
		end,
		okStr = "确定",
		closeType = 3,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CSoccerTeamSupportBox.SupportOne(self)
	if self.m_GroupTeams ~= nil then
		nethuodong.C2GSWorldCupChampion(1, self.m_GroupTeams[1])
	else
		
	end
end


function CSoccerTeamSupportBox.OnClickOneCancelSupportBtn(self)
	printc("CSoccerTeamSupportBox.OnClickOneCancelSupportBtn")
	local phase = g_SoccerWorldCupGuessCtrl.m_Phase
	local cost = data.worldcupdata.COST[phase] ~= nil and data.worldcupdata.COST[phase].champion_cancel or 20
	local windowConfirmInfo = {
		title = "提示",
		msg = string.format("取消选择后，您可以重新更换支持的球队 当前比赛阶段，取消支持需要花费%d#cur_2", cost),
		cancelCallback = function ()
		end,
		cancelStr = "取消",
		okCallback = function()
			self:CancelOne()
		end,
		okStr = "确定",
		closeType = 3,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CSoccerTeamSupportBox.CancelOne(self)
	if self.m_GroupTeams ~= nil then
		nethuodong.C2GSWorldCupChampion(2, self.m_GroupTeams[1])
	else
		
	end
end

function CSoccerTeamSupportBox.OnClickTwoSupportBtn(self)
	printc("CSoccerTeamSupportBox.OnClickTwoSupportBtn")
	local key = self.m_GroupTeams ~= nil and self.m_GroupTeams[2] or 1002
	local country = data.worldcupdata.CONFIG[key] ~= nil and data.worldcupdata.CONFIG[key].country or "中国"
	local windowConfirmInfo = {
		title = "提示",
		msg = string.format("[c][63432C]确定要支持[[1D8E00]%s[-]]吗？", country),
		cancelCallback = function ()
		end,
		cancelStr = "取消",
		okCallback = function()
			self:SupportTwo()
		end,
		okStr = "确定",
		closeType = 3,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CSoccerTeamSupportBox.SupportTwo(self)
	if self.m_GroupTeams ~= nil then
		nethuodong.C2GSWorldCupChampion(1, self.m_GroupTeams[2])
	else
		
	end
end

function CSoccerTeamSupportBox.OnClickTwoCancelSupportBtn(self)
	printc("CSoccerTeamSupportBox.OnClickTwoCancelSupportBtn")
	local phase = g_SoccerWorldCupGuessCtrl.m_Phase
	local cost = data.worldcupdata.COST[phase] ~= nil and data.worldcupdata.COST[phase].champion_cancel or 20
	local windowConfirmInfo = {
		title = "提示",
		msg = string.format("取消选择后，您可以重新更换支持的球队 当前比赛阶段，取消支持需要花费%d#cur_2", cost),
		cancelCallback = function ()
		end,
		cancelStr = "取消",
		okCallback = function()
			self:CancelTwo()
		end,
		okStr = "确定",
		closeType = 3,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CSoccerTeamSupportBox.CancelTwo(self)
	if self.m_GroupTeams ~= nil then
		nethuodong.C2GSWorldCupChampion(2, self.m_GroupTeams[2])
	else
		
	end
end

function CSoccerTeamSupportBox.OnClickThreeSupportBtn(self)
	printc("CSoccerTeamSupportBox.OnClickThreeSupportBtn")
	local key = self.m_GroupTeams ~= nil and self.m_GroupTeams[3] or 1003
	local country = data.worldcupdata.CONFIG[key] ~= nil and data.worldcupdata.CONFIG[key].country or "中国"
	local windowConfirmInfo = {
		title = "提示",
		msg = string.format("[c][63432C]确定要支持[[1D8E00]%s[-]]吗？", country),
		cancelCallback = function ()
		end,
		cancelStr = "取消",
		okCallback = function()
			self:SupportThree()
		end,
		okStr = "确定",
		closeType = 3,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CSoccerTeamSupportBox.SupportThree(self)
	if self.m_GroupTeams ~= nil then
		nethuodong.C2GSWorldCupChampion(1, self.m_GroupTeams[3])
	else
		
	end
end

function CSoccerTeamSupportBox.OnClickThreeCancelSupportBtn(self)
	printc("CSoccerTeamSupportBox.OnClickThreeCancelSupportBtn")
	local phase = g_SoccerWorldCupGuessCtrl.m_Phase
	local cost = data.worldcupdata.COST[phase] ~= nil and data.worldcupdata.COST[phase].champion_cancel or 20
	local windowConfirmInfo = {
		title = "提示",
		msg = string.format("取消选择后，您可以重新更换支持的球队 当前比赛阶段，取消支持需要花费%d#cur_2", cost),
		cancelCallback = function ()
		end,
		cancelStr = "取消",
		okCallback = function()
			self:CancelThree()
		end,
		okStr = "确定",
		closeType = 3,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CSoccerTeamSupportBox.CancelThree(self)
	if self.m_GroupTeams ~= nil then
		nethuodong.C2GSWorldCupChampion(2, self.m_GroupTeams[3])
	else
		
	end
end

function CSoccerTeamSupportBox.OnClickFourSupportBtn(self)
	printc("CSoccerTeamSupportBox.OnClickFourSupportBtn")
	local key = self.m_GroupTeams ~= nil and self.m_GroupTeams[4] or 1004
	local country = data.worldcupdata.CONFIG[key] ~= nil and data.worldcupdata.CONFIG[key].country or "中国"
	local windowConfirmInfo = {
		title = "提示",
		msg = string.format("[c][63432C]确定要支持[[1D8E00]%s[-]]吗？", country),
		cancelCallback = function ()
		end,
		cancelStr = "取消",
		okCallback = function()
			self:SupportFour()
		end,
		okStr = "确定",
		closeType = 3,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CSoccerTeamSupportBox.SupportFour(self)
	if self.m_GroupTeams ~= nil then
		nethuodong.C2GSWorldCupChampion(1, self.m_GroupTeams[4])
	else
		
	end
end

function CSoccerTeamSupportBox.OnClickFourCancelSupportBtn(self)
	printc("CSoccerTeamSupportBox.OnClickFourCancelSupportBtn")
	local phase = g_SoccerWorldCupGuessCtrl.m_Phase
	local cost = data.worldcupdata.COST[phase] ~= nil and data.worldcupdata.COST[phase].champion_cancel or 20
	local windowConfirmInfo = {
		title = "提示",
		msg = string.format("取消选择后，您可以重新更换支持的球队 当前比赛阶段，取消支持需要花费%d#cur_2", cost),
		cancelCallback = function ()
		end,
		cancelStr = "取消",
		okCallback = function()
			self:CancelFour()
		end,
		okStr = "确定",
		closeType = 3,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CSoccerTeamSupportBox.CancelFour(self)
	if self.m_GroupTeams ~= nil then
		nethuodong.C2GSWorldCupChampion(2, self.m_GroupTeams[4])
	else
		
	end
end


function CSoccerTeamSupportBox.RefreshTeamsUI(self)
	--组
	local groupText = self.m_Group[self.m_GroupIndex]
	self.m_GroupText:SetText(groupText.."组")

	--1国家名 国旗
	local oneNationalId = self.m_GroupTeams[1]
	local isKnockoutForOne = g_SoccerTeamSupportCtrl:IsKnockoutTeam(oneNationalId)
	self.m_oneNationalNameText:SetText(data.worldcupdata.CONFIG[oneNationalId].country)
	self.m_oneNationalNameText:SetActive(true)
	self.m_oneNationalFlagAtlas:SetSpriteName("h7_shijiebei_guoqi_"..data.worldcupdata.CONFIG[oneNationalId].national_flag)
	self.m_oneNationalFlagAtlas:SetActive(true)
	if isKnockoutForOne then
		self.m_oneNationalFlagAtlas:SetGrey(true)
	else
		self.m_oneNationalFlagAtlas:SetGrey(false)
	end

	--2国家名 国旗
	local twoNationalId = self.m_GroupTeams[2]
	local isKnockoutForTwo = g_SoccerTeamSupportCtrl:IsKnockoutTeam(twoNationalId)
	self.m_twoNationalNameText:SetText(data.worldcupdata.CONFIG[twoNationalId].country)
	self.m_twoNationalNameText:SetActive(true)
	self.m_twoNationalFlagAtlas:SetSpriteName("h7_shijiebei_guoqi_"..data.worldcupdata.CONFIG[twoNationalId].national_flag)
	self.m_twoNationalFlagAtlas:SetActive(true)
	if isKnockoutForTwo then
		self.m_twoNationalFlagAtlas:SetGrey(true)
	else
		self.m_twoNationalFlagAtlas:SetGrey(false)
	end

	--3国家名 国旗
	local threeNationalId = self.m_GroupTeams[3]
	local isKnockoutForThree = g_SoccerTeamSupportCtrl:IsKnockoutTeam(threeNationalId)
	self.m_threeNationalNameText:SetText(data.worldcupdata.CONFIG[threeNationalId].country)
	self.m_threeNationalNameText:SetActive(true)
	self.m_threeNationalFlagAtlas:SetSpriteName("h7_shijiebei_guoqi_"..data.worldcupdata.CONFIG[threeNationalId].national_flag)
	self.m_threeNationalFlagAtlas:SetActive(true)
	if isKnockoutForThree then
		self.m_threeNationalFlagAtlas:SetGrey(true)
	else
		self.m_threeNationalFlagAtlas:SetGrey(false)
	end

	--4国家名 国旗
	local fourNationalId = self.m_GroupTeams[4]
	local isKnockoutForFour = g_SoccerTeamSupportCtrl:IsKnockoutTeam(fourNationalId)
	self.m_fourNationalNameText:SetText(data.worldcupdata.CONFIG[fourNationalId].country)
	self.m_fourNationalNameText:SetActive(true)
	self.m_fourNationalFlagAtlas:SetSpriteName("h7_shijiebei_guoqi_"..data.worldcupdata.CONFIG[fourNationalId].national_flag)
	self.m_fourNationalFlagAtlas:SetActive(true)
	if isKnockoutForFour then
		self.m_fourNationalFlagAtlas:SetGrey(true)
	else
		self.m_fourNationalFlagAtlas:SetGrey(false)
	end


	if g_SoccerTeamSupportCtrl:IsSupport() then
		printc("1 g_SoccerTeamSupportCtrl:IsSupport():", g_SoccerTeamSupportCtrl:IsSupport())
		--已支持某队
		self.m_oneSupportBtn:SetActive(false)
		local oneSupportText = "支持数:"..g_SoccerTeamSupportCtrl:GetTeamSupportCount(oneNationalId)
		self.m_oneSupportText:SetText(oneSupportText)
		self.m_oneSupportText:SetActive(true)
		self.m_oneCancelSupportBtn:SetActive(g_SoccerTeamSupportCtrl:IsSupportTeam(oneNationalId))

		self.m_twoSupportBtn:SetActive(false)
		local twoSupportText = "支持数:"..g_SoccerTeamSupportCtrl:GetTeamSupportCount(twoNationalId)
		self.m_twoSupportText:SetText(twoSupportText)
		self.m_twoSupportText:SetActive(true)
		self.m_twoCancelSupportBtn:SetActive(g_SoccerTeamSupportCtrl:IsSupportTeam(twoNationalId))

		self.m_threeSupportBtn:SetActive(false)
		local threeSupportText = "支持数:"..g_SoccerTeamSupportCtrl:GetTeamSupportCount(threeNationalId)
		self.m_threeSupportText:SetText(threeSupportText)
		self.m_threeSupportText:SetActive(true)
		self.m_threeCancelSupportBtn:SetActive(g_SoccerTeamSupportCtrl:IsSupportTeam(threeNationalId))

		self.m_fourSupportBtn:SetActive(false)
		local fourSupportText = "支持数:"..g_SoccerTeamSupportCtrl:GetTeamSupportCount(fourNationalId)
		self.m_fourSupportText:SetText(fourSupportText)
		self.m_fourSupportText:SetActive(true)
		self.m_fourCancelSupportBtn:SetActive(g_SoccerTeamSupportCtrl:IsSupportTeam(fourNationalId))
	else
		printc("2 g_SoccerTeamSupportCtrl:IsSupport():", g_SoccerTeamSupportCtrl:IsSupport())
		--还没支持某队
		
		local show_one = false
		if isKnockoutForOne == false then
			show_one = true
		end
		self.m_oneSupportBtn:SetActive(show_one)
		self.m_oneSupportText:SetActive(false)
		self.m_oneCancelSupportBtn:SetActive(false)

		local show_two = false
		if isKnockoutForTwo == false then
			show_two = true
		end
		self.m_twoSupportBtn:SetActive(show_two)
		self.m_twoSupportText:SetActive(false)
		self.m_twoCancelSupportBtn:SetActive(false)

		local show_three = false
		if isKnockoutForThree == false then
			show_three = true
		end
		self.m_threeSupportBtn:SetActive(show_three)
		self.m_threeSupportText:SetActive(false)
		self.m_threeCancelSupportBtn:SetActive(false)

		local show_four = false
		if isKnockoutForFour == false then
			show_four = true
		end
		self.m_fourSupportBtn:SetActive(show_four)
		self.m_fourSupportText:SetActive(false)
		self.m_fourCancelSupportBtn:SetActive(false)
	end
end

function CSoccerTeamSupportBox.RefreshUnitForOne(self, num)
	local oneNationalId = self.m_GroupTeams[1]
	if g_SoccerTeamSupportCtrl:IsSupport() == false then
		local isKnockoutForOne = g_SoccerTeamSupportCtrl:IsKnockoutTeam(oneNationalId)
		self.m_oneSupportBtn:SetActive(isKnockoutForOne == false and true or false)
		self.m_oneSupportText:SetActive(false)
		self.m_oneCancelSupportBtn:SetActive(false)
	else
		self.m_oneSupportBtn:SetActive(false)
		local oneSupportText = "支持数:"..num
		self.m_oneSupportText:SetText(oneSupportText)
		self.m_oneSupportText:SetActive(true)
		self.m_oneCancelSupportBtn:SetActive(g_SoccerTeamSupportCtrl:IsSupportTeam(oneNationalId))
	end
end

function CSoccerTeamSupportBox.RefreshUnitForTwo(self, num)
	local twoNationalId = self.m_GroupTeams[2]
	if g_SoccerTeamSupportCtrl:IsSupport() == false then
		local isKnockoutForTwo = g_SoccerTeamSupportCtrl:IsKnockoutTeam(twoNationalId)
		self.m_twoSupportBtn:SetActive(isKnockoutForTwo == false and true or false)
		self.m_twoSupportText:SetActive(false)
		self.m_twoCancelSupportBtn:SetActive(false)
	else
		self.m_twoSupportBtn:SetActive(false)
		local twoSupportText = "支持数:"..num
		self.m_twoSupportText:SetText(twoSupportText)
		self.m_twoSupportText:SetActive(true)
		self.m_twoCancelSupportBtn:SetActive(g_SoccerTeamSupportCtrl:IsSupportTeam(twoNationalId))
	end
end

function CSoccerTeamSupportBox.RefreshUnitForThree(self, num)
	local threeNationalId = self.m_GroupTeams[3]
	if g_SoccerTeamSupportCtrl:IsSupport() == false then
		local isKnockoutForThree = g_SoccerTeamSupportCtrl:IsKnockoutTeam(threeNationalId)
		self.m_threeSupportBtn:SetActive(isKnockoutForThree == false and true or false)
		self.m_threeSupportText:SetActive(false)
		self.m_threeCancelSupportBtn:SetActive(false)
	else
		self.m_threeSupportBtn:SetActive(false)
		local threeSupportText = "支持数:"..num
		self.m_threeSupportText:SetText(threeSupportText)
		self.m_threeSupportText:SetActive(true)
		self.m_threeCancelSupportBtn:SetActive(g_SoccerTeamSupportCtrl:IsSupportTeam(threeNationalId))
	end
end

function CSoccerTeamSupportBox.RefreshUnitForFour(self, num)
	local fourNationalId = self.m_GroupTeams[4]
	if g_SoccerTeamSupportCtrl:IsSupport() == false then
		local isKnockoutForFour = g_SoccerTeamSupportCtrl:IsKnockoutTeam(fourNationalId)
		self.m_fourSupportBtn:SetActive(isKnockoutForFour == false and true or false)
		self.m_fourSupportText:SetActive(false)
		self.m_fourCancelSupportBtn:SetActive(false)
	else
		self.m_fourSupportBtn:SetActive(false)
		local fourSupportText = "支持数:"..num
		self.m_fourSupportText:SetText(fourSupportText)
		self.m_fourSupportText:SetActive(true)
		self.m_fourCancelSupportBtn:SetActive(g_SoccerTeamSupportCtrl:IsSupportTeam(fourNationalId))
	end
end


--事件
function CSoccerTeamSupportBox.OnCtrlEvent(self, oCtrl)
	--printc("CSoccerTeamSupportBox.OnCtrlEvent oCtrl.m_EventID:", oCtrl.m_EventID)
end

return CSoccerTeamSupportBox