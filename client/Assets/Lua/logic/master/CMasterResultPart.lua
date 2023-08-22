local CMasterResultPart = class("CMasterResultPart", CPageBase)

function CMasterResultPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_IconSp = self:NewUI(1, CSprite)
	self.m_NameLbl = self:NewUI(2, CLabel)
	self.m_LevelLbl = self:NewUI(3, CLabel)
	self.m_SchoolLbl = self:NewUI(4, CLabel)
	self.m_ScoreLbl = self:NewUI(5, CLabel)
	self.m_TalkBtn = self:NewUI(6, CButton)
	self.m_TaskScrollView = self:NewUI(7, CScrollView)
	self.m_TaskGrid = self:NewUI(8, CGrid)
	self.m_TaskBoxClone = self:NewUI(9, CBox)
	self.m_MarkSp = self:NewUI(10, CSprite)

	self:InitContent()
end

function CMasterResultPart.InitContent(self)
	self.m_TaskBoxClone:SetActive(false)
	self.m_IconSp:AddUIEvent("click", callback(self, "OnClickIconSp"))
	self.m_TalkBtn:AddUIEvent("click", callback(self, "OnClickTalkBtn"))
	g_MasterCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlMasterEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
end

function CMasterResultPart.OnCtrlMasterEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Master.Event.MentoringTask then
		self:RefreshUI()
		self:RefreshCheckRedPoint()
	end
end

function CMasterResultPart.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshUI()
		self:RefreshCheckRedPoint()
	end
end

function CMasterResultPart.OnShowPage(self)
    self.m_ParentView.m_BgSp:SetHeight(605)
    self.m_ParentView.m_BgSp:SetLocalPos(Vector3.New(0, -15, 0))
    self.m_ParentView.m_TabGrid:SetLocalPos(Vector3.New(340, 132, 0))
    self.m_ParentView.m_CloseBtn:SetLocalPos(Vector3.New(305.6, 270, 0))
end

function CMasterResultPart.RefreshUI(self)
	if not self.m_RoleInfo then
		return
	end
	local oShowData = g_MasterCtrl.m_ShowPidDataList[self.m_RoleInfo.pid]
	if not oShowData then
		return
	end
	self:SetTaskList()
	self.m_ScoreLbl:SetText("综合实力："..oShowData.m_TargetScore)
	self.m_LevelLbl:SetText(oShowData.m_TargetGrade.."级")
end

function CMasterResultPart.RefreshCheckRedPoint(self)
	if not self.m_RoleInfo then
		return
	end
	self.m_ParentView.m_ResultRedPoint:SetActive(g_MasterCtrl:GetResultPartPrize(self.m_RoleInfo.pid, self.m_MasterType))
end

function CMasterResultPart.RefreshRoleInfo(self, oType, oRoleInfo)
	self.m_MasterType = oType
	self.m_RoleInfo = oRoleInfo
	self.m_IconSp:SpriteAvatar(oRoleInfo.icon)
	self.m_NameLbl:SetText(oRoleInfo.name)
	self.m_SchoolLbl:SetText(data.schooldata.DATA[oRoleInfo.school].name)
	if oType == 1 then
		self.m_MarkSp:SetSpriteName("h7_tu")
	elseif oType == 2 then
		self.m_MarkSp:SetSpriteName("h7_shi")
	end

	self:RefreshUI()
	self:RefreshCheckRedPoint()
end

function CMasterResultPart.SetTaskList(self)
	local optionCount = #data.masterdata.STEPRESULT
	local GridList = self.m_TaskGrid:GetChildList() or {}
	local oTaskBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oTaskBox = self.m_TaskBoxClone:Clone(false)
				-- self.m_TaskGrid:AddChild(oOptionBtn)
			else
				oTaskBox = GridList[i]
			end
			self:SetTaskBox(oTaskBox, data.masterdata.STEPRESULT[i])
		end

		if #GridList > optionCount then
			for i=optionCount+1,#GridList do
				GridList[i]:SetActive(false)
			end
		end
	else
		if GridList and #GridList > 0 then
			for _,v in ipairs(GridList) do
				v:SetActive(false)
			end
		end
	end

	self.m_TaskGrid:Reposition()
	-- self.m_TaskScrollView:ResetPosition()
end

function CMasterResultPart.SetTaskBox(self, oTaskBox, oData)
	oTaskBox:SetActive(true)
	oTaskBox.m_NameLbl = oTaskBox:NewUI(1, CLabel)
	oTaskBox.m_BgWidget = oTaskBox:NewUI(2, CWidget)
	oTaskBox.m_TimeLbl = oTaskBox:NewUI(3, CLabel)
	oTaskBox.m_DoneSp = oTaskBox:NewUI(4, CSprite)
	oTaskBox.m_HasOutLbl = oTaskBox:NewUI(5, CLabel)
	oTaskBox.m_GetBtn = oTaskBox:NewUI(6, CButton)
	oTaskBox.m_RewardLbl = oTaskBox:NewUI(7, CLabel)

	local oShowData = g_MasterCtrl.m_ShowPidDataList[self.m_RoleInfo.pid]

	oTaskBox.m_NameLbl:SetText(oData.content)
	local oServerData = oShowData.m_ResultTaskHashList[oData.id]
	if oData.grade ~= 0 then
		if self.m_MasterType == 1 then
			oTaskBox.m_TimeLbl:SetText(oShowData.m_TargetGrade.."/"..oData.grade)
		else
			oTaskBox.m_TimeLbl:SetText(g_AttrCtrl.grade.."/"..oData.grade)
		end
	else
		oTaskBox.m_TimeLbl:SetText(oServerData.step_cnt.."/"..oData.cnt)
	end
	-- -1:过期，0未领取，1已领取
	if oServerData.status == -1 then
		oTaskBox.m_DoneSp:SetActive(false)
		oTaskBox.m_HasOutLbl:SetActive(true)
		oTaskBox.m_GetBtn:SetActive(false)
		oTaskBox.m_RewardLbl:SetActive(false)
	elseif oServerData.status == 0 then
		if oData.grade ~= 0 then
			local oGrade
			if self.m_MasterType == 1 then
				oGrade = oShowData.m_TargetGrade
			else
				oGrade = g_AttrCtrl.grade
			end
			if oGrade >= oData.grade then
				oTaskBox.m_DoneSp:SetActive(false)
				oTaskBox.m_HasOutLbl:SetActive(false)
				oTaskBox.m_GetBtn:SetActive(true)
				oTaskBox.m_RewardLbl:SetActive(false)
			else
				oTaskBox.m_DoneSp:SetActive(false)
				oTaskBox.m_HasOutLbl:SetActive(false)
				oTaskBox.m_GetBtn:SetActive(false)
				oTaskBox.m_RewardLbl:SetActive(true)
				if self.m_MasterType == 1 then
					oTaskBox.m_RewardLbl:SetText("奖励："..oData.mentor_xiayi_point)
				else
					oTaskBox.m_RewardLbl:SetText("奖励："..oData.apprentice_xiayi_point)
				end
			end
		else
			if oServerData.step_cnt >= oData.cnt then
				oTaskBox.m_DoneSp:SetActive(false)
				oTaskBox.m_HasOutLbl:SetActive(false)
				oTaskBox.m_GetBtn:SetActive(true)
				oTaskBox.m_RewardLbl:SetActive(false)
			else
				oTaskBox.m_DoneSp:SetActive(false)
				oTaskBox.m_HasOutLbl:SetActive(false)
				oTaskBox.m_GetBtn:SetActive(false)
				oTaskBox.m_RewardLbl:SetActive(true)
				if self.m_MasterType == 1 then
					oTaskBox.m_RewardLbl:SetText("奖励："..oData.mentor_xiayi_point)
				else
					oTaskBox.m_RewardLbl:SetText("奖励："..oData.apprentice_xiayi_point)
				end
			end
		end
	elseif oServerData.status == 1 then
		oTaskBox.m_DoneSp:SetActive(true)
		oTaskBox.m_HasOutLbl:SetActive(false)
		oTaskBox.m_GetBtn:SetActive(false)
		oTaskBox.m_RewardLbl:SetActive(false)
	end

	oTaskBox.m_GetBtn:AddUIEvent("click", callback(self, "OnClickTaskGetBtn", oData))

	self.m_TaskGrid:AddChild(oTaskBox)
	self.m_TaskGrid:Reposition()
end

function CMasterResultPart.OnClickIconSp(self)
	if not self.m_RoleInfo then
		return
	end
	netplayer.C2GSGetPlayerInfo(self.m_RoleInfo.pid)
end

function CMasterResultPart.OnClickTalkBtn(self)
	if not self.m_RoleInfo then
		return
	end
	if g_FriendCtrl:IsBlackFriend(self.m_RoleInfo.pid) then
		g_NotifyCtrl:FloatMsg(data.frienddata.FRIENDTEXT[define.Friend.Text.ChatToBlackTips].content)
	else
		CFriendInfoView:ShowView(function (oView)
			oView.m_Brief.m_FriendTabBtn:SetSelected(true)
			oView:ShowTalk(self.m_RoleInfo.pid) 
		end)
	end
	self.m_ParentView:OnClose()
end

function CMasterResultPart.OnClickTaskGetBtn(self, oData)
	if not self.m_RoleInfo then
		return
	end
	netmentoring.C2GSMentoringStepResultReward(self.m_MasterType, self.m_RoleInfo.pid, oData.id)
end

return CMasterResultPart