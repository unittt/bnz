local CPartnerFormationBox = class("CPartnerFormationBox", CBox)

function CPartnerFormationBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_FormationBtn = self:NewUI(1, CButton)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_MemberBoxClone = self:NewUI(3, CPartnerFormationMemberBox)
	self.m_CheckBox = self:NewUI(4, CWidget)
	self.m_NameLabel = self:NewUI(5, CLabel)
	self.m_FormationSpr = self:NewUI(6, CSprite)

	self:InitContent()
end

function CPartnerFormationBox.InitContent(self)
	self.m_MemberBoxClone:SetActive(false)
	-- self:AddUIEvent("click", callback(self, ""))
	self.m_CheckBox:AddUIEvent("click", callback(self, "OnClickCheckBox"))
	self.m_FormationBtn:AddUIEvent("click", callback(self, "OnClickFormation"))

	g_FormationCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFormationEvent"))
end

function CPartnerFormationBox.SetLineupIndex(self, iIndex)
	self.m_LineupIndex = iIndex
	self.m_LineupInfo = g_PartnerCtrl:GetLineupInfoByIndex(iIndex)
	local str = string.format("阵容%d", iIndex)
	self.m_NameLabel:SetText(str)
	self.m_CheckBox:SetSelected(iIndex == g_PartnerCtrl:GetCurLineup())
	self:RefreshGrid()
	self:RefreshFormationButton()
end

function CPartnerFormationBox.OnFormationEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Formation.Event.RefreshGuildStatus then
		self:RefreshFormationButton()
	end
end

function CPartnerFormationBox.RefreshFormationButton(self)
	local iFmtId = 1
	if self.m_LineupInfo then
		iFmtId = self.m_LineupInfo.fmt_id
	end
	local dFmtInfo = g_FormationCtrl:GetFormationInfoByFmtID(iFmtId)
	local dData = data.formationdata.BASEINFO[dFmtInfo.fmt_id] 
	if dFmtInfo.grade < 1 then
		self.m_FormationBtn:SetText(dData.name)
	else
		self.m_FormationBtn:SetText(iFmtId == 1 and "" or dFmtInfo.grade.."级")
	end
	self.m_FormationSpr:SetSpriteName(dData.icon)
	if g_FormationCtrl.m_NeedGuideLearn and self.m_LineupIndex == 1 then
		self.m_FormationSpr.m_IgnoreCheckEffect = true
		self.m_FormationSpr:AddEffect("FingerInterval")
	else
		self.m_FormationSpr:DelEffect("FingerInterval")
	end
end

function CPartnerFormationBox.RefreshGrid(self)
	-- self.m_Grid:Clear()
	local iCount = 1--#partnerlist
	local list = {}
	if self.m_LineupInfo then
		list = self.m_LineupInfo.pos_list
	end
	local bIsAdd = false
	for i = 1, 4 do
		local pid = list[i]
		local oBox = self.m_Grid:GetChild(i)
		if not oBox then
			oBox = self:CreateMemberBox()
			self.m_Grid:AddChild(oBox)
		end
		if pid == nil then
			if not bIsAdd then
				bIsAdd = true
				self:UpdateMemberBox(oBox, nil, true)
			else
				self:UpdateMemberBox(oBox, nil, false)
			end
		else
			self:UpdateMemberBox(oBox, pid, bIsAdd)
		end
		-- self.m_Grid:AddChild(oBox)
	end
	self.m_Grid:Reposition()
end

function CPartnerFormationBox.CreateMemberBox(self)
	local oBox = self.m_MemberBoxClone:Clone()
	oBox:SetCallback(callback(self, "ShowSwapButton"))
	oBox:SetActive(true)
	return oBox
end

function CPartnerFormationBox.UpdateMemberBox(self, oBox, pid, bIsAdd)
	oBox:SetPartnerInfo(self.m_LineupIndex, pid, bIsAdd)
end

function CPartnerFormationBox.OnClickCheckBox(self)
	if self.m_LineupIndex == g_PartnerCtrl:GetCurLineup() then
		return
	end
	if self.m_LineupIndex == 0 or self.m_LineupIndex == nil then
		return
	end

	self.m_CheckBox:SetSelected(true)
	local sDesc = string.gsub(DataTools.GetPartnerTextInfo(2004).content, "#formationname", tostring(self.m_LineupIndex))
	if not g_MapCtrl:IsInSingleBiwuMap() then
		g_NotifyCtrl:FloatMsg(sDesc)--"成功切换阵容"..self.m_LineupIndex)
	end
	netpartner.C2GSSetCurrLineup(self.m_LineupIndex)
	if g_WarCtrl:IsWar() then
		g_NotifyCtrl:FloatMsg("战斗结束后生效")
		local dInfo = g_PartnerCtrl:GetLineupInfoByIndex(self.m_LineupIndex)
		if not dInfo then
			g_PartnerCtrl.m_IsPosChanged = true
			return
		end
		g_PartnerCtrl.m_IsPosChanged = false
		for i,pid in ipairs(g_PartnerCtrl.m_OriginalPos) do
			if pid ~= dInfo.pos_list[i] then
				g_PartnerCtrl.m_IsPosChanged = true
				break
			end
		end
	end
end

function CPartnerFormationBox.ShowSwapButton(self)
	local list = self.m_Grid:GetChildList()
	local iSelectedId = g_PartnerCtrl:GetLocalSelectedPartner()
	for _,oBox in ipairs(list) do
		if oBox.m_Pid and oBox.m_Pid ~= iSelectedId then
			oBox:ShowSwapButton()
		end
	end
end

function CPartnerFormationBox.SetSelectedPartner(self, iPid)
	local list = self.m_Grid:GetChildList()
	local iSelectedId = g_PartnerCtrl:GetLocalSelectedPartner()
	for _,oBox in ipairs(list) do
		if oBox.m_Pid and oBox.m_Pid == iPid then
			oBox:OnClickPartner()
			break
		end
	end
end

function CPartnerFormationBox.OnClickFormation(self)
	CFormationMainView:ShowView(function(oView)
		CPartnerMainView:GetView():OnResetFormationPart()
		local iFmtId = 1
		if self.m_LineupInfo then
			iFmtId= self.m_LineupInfo.fmt_id
		end
		oView:SetPartnerLineup(self.m_LineupIndex, iFmtId)
	end
	)
end

return CPartnerFormationBox