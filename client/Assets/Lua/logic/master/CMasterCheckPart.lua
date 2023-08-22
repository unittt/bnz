local CMasterCheckPart = class("CMasterCheckPart", CPageBase)

function CMasterCheckPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_IconSp = self:NewUI(1, CSprite)
	self.m_NameLbl = self:NewUI(2, CLabel)
	self.m_LevelLbl = self:NewUI(3, CLabel)
	self.m_SchoolLbl = self:NewUI(4, CLabel)
	self.m_ScoreLbl = self:NewUI(5, CLabel)
	self.m_TalkBtn = self:NewUI(6, CButton)
	self.m_DescLbl = self:NewUI(7, CLabel)
	self.m_TaskScrollView = self:NewUI(8, CScrollView)
	self.m_TaskGrid = self:NewUI(9, CGrid)
	self.m_TaskBoxClone = self:NewUI(10, CBox)
	self.m_DescLbl2 = self:NewUI(11, CLabel)
	self.m_ProgressSlider = self:NewUI(12, CSlider)
	self.m_ProgressTotalLbl = self:NewUI(13, CLabel)
	self.m_ProgressGrid = self:NewUI(14, CGrid)
	self.m_ProgressBoxClone = self:NewUI(15, CBox)
	self.m_OutMarkSp = self:NewUI(16, CSprite)
	self.m_MarkSp = self:NewUI(17, CSprite)
	self.m_NoTaskLbl = self:NewUI(18, CLabel)
	self.m_GrowUpLbl = self:NewUI(19, CLabel)

	self.m_OutGrade = data.masterdata.CONFIG[1].apprentice_growup

	self:InitContent()
end

function CMasterCheckPart.InitContent(self)
	self.m_TaskBoxClone:SetActive(false)
	self.m_ProgressBoxClone:SetActive(false)
	self.m_IconSp:AddUIEvent("click", callback(self, "OnClickIconSp"))
	self.m_TalkBtn:AddUIEvent("click", callback(self, "OnClickTalkBtn"))
	g_MasterCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlMasterEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
end

function CMasterCheckPart.OnShowPage(self)
    self.m_ParentView.m_BgSp:SetHeight(712)
    self.m_ParentView.m_BgSp:SetLocalPos(Vector3.New(0, 2, 0))
    self.m_ParentView.m_TabGrid:SetLocalPos(Vector3.New(340, 202, 0))
    self.m_ParentView.m_CloseBtn:SetLocalPos(Vector3.New(305.6, 337.1, 0))
end

function CMasterCheckPart.OnCtrlMasterEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Master.Event.MentoringTask then
		self:RefreshUI()
		self:RefreshCheckRedPoint()
	end
end

function CMasterCheckPart.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshMark()
	end
end

function CMasterCheckPart.RefreshUI(self)
	if not self.m_RoleInfo then
		return
	end
	local oShowData = g_MasterCtrl.m_ShowPidDataList[self.m_RoleInfo.pid]
	if not oShowData then
		return
	end
	self:SetTaskList()
	self.m_ProgressTotalLbl:SetText(oShowData.m_CheckProgress)
	self.m_ProgressSlider:SetValue(oShowData.m_CheckProgress/data.masterdata.PROGRESS[#data.masterdata.PROGRESS].progress)
	self:SetProgressList()
	self:RefreshMark()
	if self.m_MasterType == 1 then
		self.m_GrowUpLbl:SetText("已成功出师："..(oShowData.m_GrowupNum or 0).."人")
	else
		self.m_GrowUpLbl:SetText("")
	end
	self.m_ScoreLbl:SetText("综合实力："..oShowData.m_TargetScore)
	self.m_LevelLbl:SetText(oShowData.m_TargetGrade.."级")
end

function CMasterCheckPart.RefreshCheckRedPoint(self)
	if not self.m_RoleInfo then
		return
	end
	self.m_ParentView.m_CheckRedPoint:SetActive(g_MasterCtrl:GetCheckPartPrize(self.m_RoleInfo.pid))
end

function CMasterCheckPart.RefreshRoleInfo(self, oType, oRoleInfo)
	self.m_MasterType = oType
	self.m_RoleInfo = oRoleInfo
	self.m_IconSp:SpriteAvatar(oRoleInfo.icon)
	self.m_NameLbl:SetText(oRoleInfo.name)
	self.m_SchoolLbl:SetText(data.schooldata.DATA[oRoleInfo.school].name)
	self:RefreshMark()
	if oType == 1 then
		self.m_MarkSp:SetSpriteName("h7_tu")
	elseif oType == 2 then
		self.m_MarkSp:SetSpriteName("h7_shi")
	end

	self:RefreshUI()
	self:RefreshCheckRedPoint()
end

function CMasterCheckPart.RefreshMark(self)
	self.m_OutMarkSp:SetActive(false)
	if not self.m_RoleInfo then
		return
	end
	local oShowData = g_MasterCtrl.m_ShowPidDataList[self.m_RoleInfo.pid]
	if not oShowData then
		return
	end
	if oShowData.m_CheckProgress < data.masterdata.PROGRESS[#data.masterdata.PROGRESS].progress then
		return
	end
	if self.m_MasterType == 1 and self.m_RoleInfo.grade >= self.m_OutGrade then
		self.m_OutMarkSp:SetActive(true)
	elseif self.m_MasterType == 2 and g_AttrCtrl.grade >= self.m_OutGrade then
		self.m_OutMarkSp:SetActive(true)
	end
end

function CMasterCheckPart.SetTaskList(self)
	if not self.m_RoleInfo then
		return
	end
	local oShowData = g_MasterCtrl.m_ShowPidDataList[self.m_RoleInfo.pid]
	if not oShowData then
		return
	end
	if not oShowData.m_CheckTaskList or not next(oShowData.m_CheckTaskList) then
		self.m_TaskScrollView:SetActive(false)
		self.m_NoTaskLbl:SetText("国子监每日凌晨5点给师徒重新安排任务\n未完成的任务会被重置")
	else
		self.m_TaskScrollView:SetActive(true)
		self.m_NoTaskLbl:SetText("")
		local optionCount = #oShowData.m_CheckTaskList
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
				self:SetTaskBox(oTaskBox, oShowData.m_CheckTaskList[i])
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
end

function CMasterCheckPart.SetTaskBox(self, oTaskBox, oData)
	oTaskBox:SetActive(true)
	oTaskBox.m_NameLbl = oTaskBox:NewUI(1, CLabel)
	oTaskBox.m_BgWidget = oTaskBox:NewUI(2, CWidget)
	oTaskBox.m_TimeLbl = oTaskBox:NewUI(3, CLabel)
	oTaskBox.m_DoneSp = oTaskBox:NewUI(4, CSprite)

	local oConfig = data.masterdata.TASK[oData.task_id]
	oTaskBox.m_NameLbl:SetText(oConfig.task)
	local oDoneTime = oData.task_cnt
	oTaskBox.m_TimeLbl:SetText(oDoneTime.."/"..oConfig.done_cnt)
	if oDoneTime >= oConfig.done_cnt then
		oTaskBox.m_DoneSp:SetActive(true)
	else
		oTaskBox.m_DoneSp:SetActive(false)
	end

	self.m_TaskGrid:AddChild(oTaskBox)
	self.m_TaskGrid:Reposition()
end

function CMasterCheckPart.SetProgressList(self)
	local optionCount = #data.masterdata.PROGRESS
	local GridList = self.m_ProgressGrid:GetChildList() or {}
	local oProgressBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oProgressBox = self.m_ProgressBoxClone:Clone(false)
				-- self.m_ProgressGrid:AddChild(oOptionBtn)
			else
				oProgressBox = GridList[i]
			end
			self:SetProgressBox(oProgressBox, data.masterdata.PROGRESS[i])
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

	self.m_ProgressGrid:Reposition()
	-- self.m_ScrollView:ResetPosition()
end

function CMasterCheckPart.SetProgressBox(self, oProgressBox, oData)
	oProgressBox:SetActive(true)
	oProgressBox.m_IconSp = oProgressBox:NewUI(1, CSprite)
	oProgressBox.m_BgSp = oProgressBox:NewUI(2, CSprite)
	oProgressBox.m_CountLbl = oProgressBox:NewUI(3, CLabel)
	oProgressBox.m_ProgressLbl = oProgressBox:NewUI(4, CLabel)
	oProgressBox.m_EffectWidget = oProgressBox:NewUI(5, CWidget)

	local oShowData = g_MasterCtrl.m_ShowPidDataList[self.m_RoleInfo.pid]
	oProgressBox.m_ProgressLbl:SetText(oData.progress)
	local oPrizeList = g_GuideHelpCtrl:GetRewardList("MENTORING", oData.reward_idx)
	local oSelectIndex = 1
	oProgressBox.m_IconSp:SpriteItemShape(oPrizeList[oSelectIndex].item.icon)
	oProgressBox.m_CountLbl:SetText(oPrizeList[oSelectIndex].amount)
	-- oProgressBox.m_CountLbl:SetText("")
	oProgressBox.m_EffectWidget:SetActive(false)
	oProgressBox.m_EffectWidget:DelEffect("Rect")
	if oShowData.m_CheckRewardHashList[oData.id] and oShowData.m_CheckRewardHashList[oData.id].reward_cnt == 1 then
		oProgressBox.m_IconSp:SetGrey(true)
		oProgressBox:EnableTouch(false)
	elseif (not oShowData.m_CheckRewardHashList[oData.id] or oShowData.m_CheckRewardHashList[oData.id].reward_cnt == 0) and oShowData.m_CheckProgress >= oData.progress then
		oProgressBox.m_IconSp:SetGrey(false)
		oProgressBox:EnableTouch(true)
		oProgressBox.m_EffectWidget:SetActive(true)
		oProgressBox.m_EffectWidget:AddEffect("Rect")
	elseif (not oShowData.m_CheckRewardHashList[oData.id] or oShowData.m_CheckRewardHashList[oData.id].reward_cnt == 0) and oShowData.m_CheckProgress < oData.progress then
		oProgressBox.m_IconSp:SetGrey(false)
		oProgressBox:EnableTouch(true)
	end

	oProgressBox:AddUIEvent("click", callback(self, "OnClickProgressBox", oProgressBox.m_IconSp, oPrizeList[oSelectIndex], oData))

	self.m_ProgressGrid:AddChild(oProgressBox)
	self.m_ProgressGrid:Reposition()
end

function CMasterCheckPart.OnClickIconSp(self)
	if not self.m_RoleInfo then
		return
	end
	netplayer.C2GSGetPlayerInfo(self.m_RoleInfo.pid)
end

function CMasterCheckPart.OnClickTalkBtn(self)
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

function CMasterCheckPart.OnClickProgressBox(self, oPrizeItemBox, oPrize, oData)
	if not self.m_RoleInfo then
		return
	end
	local oShowData = g_MasterCtrl.m_ShowPidDataList[self.m_RoleInfo.pid]
	if not oShowData then
		return
	end
	if oShowData.m_CheckRewardHashList[oData.id] and oShowData.m_CheckRewardHashList[oData.id].reward_cnt == 1 then
	elseif (not oShowData.m_CheckRewardHashList[oData.id] or oShowData.m_CheckRewardHashList[oData.id].reward_cnt == 0) and oShowData.m_CheckProgress >= oData.progress then
		if not self.m_RoleInfo then
			return
		end
		netmentoring.C2GSMentoringTaskReward(self.m_MasterType, self.m_RoleInfo.pid, oData.id)
	elseif (not oShowData.m_CheckRewardHashList[oData.id] or oShowData.m_CheckRewardHashList[oData.id].reward_cnt == 0) and oShowData.m_CheckProgress < oData.progress then
		local args = {
	        widget = oPrizeItemBox,
	        side = enum.UIAnchor.Side.Top,
	        offset = Vector2.New(0, 0)
	    }
	    g_WindowTipCtrl:SetWindowItemTip(oPrize.sid, args)
	end
end

return CMasterCheckPart