local CPartnerFormationMemberBox = class("CPartnerFormationMemberBox", CBox)

function CPartnerFormationMemberBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_IconSpr = self:NewUI(1, CSprite)
	self.m_QualitySpr = self:NewUI(2, CSprite) 
	self.m_AddBtn  = self:NewUI(3, CSprite)
	self.m_DelBtn = self:NewUI(4, CSprite)
	self.m_SwapBtn = self:NewUI(5, CSprite)
	self.m_GradeL = self:NewUI(6, CLabel)
	self.m_FactionSpr = self:NewUI(7, CSprite)
	self.m_StartClone = self:NewUI(8, CSprite)
	self.m_StartGrid = self:NewUI(9, CGrid)

	self.m_MainView = nil 
	self:InitContent()
end

function CPartnerFormationMemberBox.InitContent(self)
	self.m_StartClone:SetActive(false)
	self:AddUIEvent("click", callback(self, "OnClickPartner"))
	self.m_AddBtn:AddUIEvent("click", callback(self, "OnClickAddPartner"))
	self.m_DelBtn:AddUIEvent("click", callback(self, "OnClickDelPartner"))
	self.m_SwapBtn:AddUIEvent("click", callback(self, "OnClickSwapPartner"))
end

function CPartnerFormationMemberBox.SetCallback(self, cb)
	self.m_callback = cb
end

function CPartnerFormationMemberBox.SetPartnerInfo(self, iLineup, pid, bIsAdd)
	self.m_lineup = iLineup
	self.m_Pid = pid
	self.m_IsAdd = bIsAdd
	self:RefreshUI()
end

function CPartnerFormationMemberBox.GetMianView(self)
	if not self.m_MainView then
		self.m_MainView = CPartnerMainView:GetView()
	end
	return self.m_MainView
end

function CPartnerFormationMemberBox.RefreshUI(self)
	self:ResetUIStatus()
	self:RefreshIcon()
end

function CPartnerFormationMemberBox.ResetUIStatus(self)
	local bIsEmpty = self.m_Pid == nil

	self.m_AddBtn:SetActive(self.m_IsAdd)
	self.m_SwapBtn:SetActive(false)
	self.m_DelBtn:SetActive(false)
	self.m_IconSpr:SetActive(not bIsEmpty)
	self.m_QualitySpr:SetActive(not bIsEmpty)
end

function CPartnerFormationMemberBox.RefreshIcon(self)
	if not self.m_Pid then
		return
	end
	local partnerData = g_PartnerCtrl:GetRecruitPartnerDataBySID(self.m_Pid)
	local partnerInfo = DataTools.GetPartnerInfo(partnerData.sid)
	self.m_IconSpr:SpriteAvatar(partnerInfo.shape)
	local quality = (partnerData and partnerData.quality or partnerInfo.quality) - 1
	self.m_QualitySpr:SetItemQuality(quality)
	-- self:SetStart(partnerData and partnerData.upper or 0)
	local schoolInfo = data.schooldata.DATA[partnerInfo.school]
	self.m_FactionSpr:SpriteSchool(schoolInfo.icon)
	local gradeStr = partnerData and partnerData.grade or ""
	self.m_GradeL:SetText(gradeStr.."级")
end

function CPartnerFormationMemberBox.ShowSwapButton(self)
	self:ResetUIStatus()
	self.m_SwapBtn:SetActive(true)
end

function CPartnerFormationMemberBox.SetStart(self, count)
	--TODO:勾玉待删除
	-- local startBoxList = self.m_StartGrid:GetChildList()
	-- local startBox = nil
	-- for i=1,5 do
	-- 	if i > #startBoxList then
	-- 		startBox = self.m_StartClone:Clone()
	-- 		self.m_StartGrid:AddChild(startBox)
	-- 		startBox:SetActive(true)
	-- 	else
	-- 		startBox = startBoxList[i]
	-- 	end
	-- 	startBox:SetGrey(i > count)
	-- end
end

function CPartnerFormationMemberBox.OnClickPartner(self)
	if not self.m_Pid then
		return
	end
	g_PartnerCtrl:SetLocalSelectedPartner(self.m_Pid)
	local oView = self:GetMianView()
	oView:RefreshFormationPart()
	oView.m_FormationPart:SetSelectedLineup(self.m_lineup)
	oView:ShowLineupFlag(true, self.m_lineup)
	self.m_DelBtn:SetActive(true)
	self.m_callback()
end

function CPartnerFormationMemberBox.OnClickAddPartner(self)
	local oView = self:GetMianView()
	oView:OnResetFormationPart()
	oView.m_FormationPart:SetSelectedLineup(self.m_lineup)
	oView:ShowLineupFlag(true, self.m_lineup)
	oView:FiterLineupPartner(true, self.m_lineup)
end

function CPartnerFormationMemberBox.OnClickDelPartner(self)
	local iSelectedId = g_PartnerCtrl:GetLocalSelectedPartner()
	g_PartnerCtrl:ChangetLineupPos(self.m_lineup, self.m_Pid, nil)
	local oView = self:GetMianView()
	oView:ResetPartnerBoxNode()
	g_PartnerCtrl:SetLocalSelectedPartner(-1)
	g_NotifyCtrl:FloatMsg(DataTools.GetPartnerTextInfo(2001).content)--"伙伴下阵成功")
	if g_WarCtrl:IsWar() then
		g_NotifyCtrl:FloatMsg("战斗结束后生效")
	end
end

function CPartnerFormationMemberBox.OnClickSwapPartner(self)
	local iSelectedId = g_PartnerCtrl:GetLocalSelectedPartner()
	g_PartnerCtrl:ChangetLineupPos(self.m_lineup, iSelectedId, self.m_Pid)
	local oView = self:GetMianView()
	oView:ResetPartnerBoxNode()
	g_PartnerCtrl:SetLocalSelectedPartner(-1)
	g_NotifyCtrl:FloatMsg(DataTools.GetPartnerTextInfo(2005).content)--"伙伴替换成功")
	if g_WarCtrl:IsWar() then
		g_NotifyCtrl:FloatMsg("战斗结束后生效")
	end
end
return CPartnerFormationMemberBox
