local CPartnerMainView = class("CPartnerMainView", CViewBase)

CPartnerMainView.PropNameList = {
	{"气血",	"max_hp",},					{"法力",	"max_mp",},
	{"物攻",	"phy_attack",},				{"法攻",	"mag_attack",},
	{"物防",	"phy_defense",},			{"法防",	"mag_defense",},
	{"治疗",    "cure_power",},				{"速度",	"speed",},
	{"物理暴击","phy_critical_ratio",},		{"法术暴击","mag_critical_ratio",},
	{"物理抗暴","res_phy_critical_ratio",}, {"法术抗暴","res_mag_critical_ratio",},
	{"封印命中","seal_ratio",},				{"封印抗性","res_seal_ratio",},
}

function CPartnerMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/PartnerMainView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CPartnerMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CSprite)
	self.m_TitleSpr = self:NewUI(2, CSprite)
	self.m_PartTabGrid = self:NewUI(3, CTabGrid)
	self.m_Content = self:NewUI(4, CObject)
	self.m_PartnerBoxNode = self:NewUI(5, CPartnerListNodeBox, true, function ()
		self:ResetPartnerInfo()
	end)
	self.m_RecruitPart = self:NewPage(6, CPartnerAttributePart)
	self.m_PartnerEquipmentBox = self:NewUI(7, CPartnerEquipBox)
	self.m_PartnerCultureSuccessBox = self:NewUI(8, CPartnerCultureSuccessBox)
	self.m_PartnerSkillInfoBox = self:NewUI(9, CPartnerSkillInfoBox, true, self)
	self.m_FormationPart = self:NewPage(10, CPartnerFormationPart)
	self.m_ExtendWidget = self:NewUI(11, CWidget)
	self.m_PartnerAddExpBox = self:NewUI(12, CPartnerAddExpBox)
	self.m_PartnerProtectSkillBox = self:NewUI(13, CPartnerProtectSkillBox)
	self.m_PartnerUpgradeBox = self:NewUI(14, CPartnerUpgradeBox, true, self)

	self.m_PartnerGuideWidget1 = self:NewUI(15, CWidget)
	self.m_PartnerGuideWidget2 = self:NewUI(16, CWidget)
	self.m_PartnerGuideWidget3 = self:NewUI(17, CWidget)

	g_GuideCtrl:AddGuideUI("partner_guide_widget1", self.m_PartnerGuideWidget1)
	g_GuideCtrl:AddGuideUI("partner_guide_widget2", self.m_PartnerGuideWidget2)
	g_GuideCtrl:AddGuideUI("partner_guide_widget3", self.m_PartnerGuideWidget3)

	self.m_CloseBtn:SetLocalScale(Vector3.New(1, 1, 1))
	self.m_CloseBtn:MakePixelPerfect()
	self.m_CloseBtn:SetLocalPos(Vector3.New(442, 296, 0))


	g_GuideCtrl:AddGuideUI("partnerview_close_btn", self.m_CloseBtn)

	self:InitContent()
	self.m_PartnerBoxNode:ReinitPartnerList()
	self:ShowSpecificPart()

	self.m_SkillInfo = nil
end

function CPartnerMainView.ResetCloseBtn(self)
	self.m_CloseBtn:SetLocalScale(Vector3.New(1, 1, 1))
	self.m_CloseBtn:MakePixelPerfect()
	self.m_CloseBtn:SetLocalPos(Vector3.New(442, 296, 0))
end

function CPartnerMainView.InitContent(self)
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPartnerCtrlEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrCtrlEvent"))
	g_PromoteCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPromoteEvent"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ExtendWidget:AddUIEvent("click", callback(self, "OnResetFormationPart"))
	-- 分页按钮
	local function init(obj, idx)
		local oBtn = CButton.New(obj, false, false)
		oBtn:SetGroup(self.m_PartTabGrid:GetInstanceID())
		return oBtn
	end
	self.m_PartTabGrid:InitChild(init)

	self.m_PartInfoList = {
		{title = "h7_shuxing_2", part = self.m_RecruitPart},
		{title = "h7_buzhen", part = self.m_FormationPart},
	}
	for i,v in ipairs(self.m_PartInfoList) do
		v.btn = self.m_PartTabGrid:GetChild(i)
		v.btn:AddUIEvent("click", callback(self, "ShowSubPageByIndex", i, v))
		--TOTO:Guide新手需要重新制作
		-- if i == 2 then
		-- 	g_GuideCtrl:AddGuideUI("partnerview_upgrade_tab", v.btn)
		-- end
	end
	self.m_PartnerBoxNode:AddCallback(callback(self, "OnClickPartner"))
	self:InitOtherBox()
	self:CheckPartnerRedPoint()
	self:RegisterSysEffs()
	self:CheckFormationGuide()
end

function CPartnerMainView.InitOtherBox(self)
	self.m_PartnerEquipmentBox:SetActive(false)
	self.m_PartnerCultureSuccessBox:SetActive(false)
	self.m_PartnerSkillInfoBox:SetActive(false)
	self.m_PartnerAddExpBox:SetActive(false)
	self.m_PartnerProtectSkillBox:SetActive(false)
	self.m_PartnerUpgradeBox:SetActive(false)
end

function CPartnerMainView.OnPromoteEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Promote.Event.UpdatePromoteData then
        self:CheckPartnerRedPoint()
	end
end

function CPartnerMainView.OnPartnerCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Partner.Event.AddPartner then
		-- self.m_PartnerBoxNode:RefreshSpecialBox(oCtrl.m_EventData)
		self:ResetPartnerInfo()
		-- 刷新列表
		self.m_PartnerBoxNode:ReinitPartnerList()
		self:SetSpecificPartnerIDNode(oCtrl.m_EventData)
	elseif oCtrl.m_EventID == define.Partner.Event.PropChange then
		self:ResetPartnerInfo()
		self:ShowPartnerCultureBox(oCtrl.m_EventData)
		-- if oCtrl.m_EventData.refListBox then
			self.m_PartnerBoxNode:RefreshSpecialBox(oCtrl.m_EventData.partnerData.sid)
		-- end
		if oCtrl.m_EventData.refEquip then
			-- if self.m_PartnerEquipmentBox:GetActive() then
			-- 	self:ShowPartnerEquipBoxInfo(oCtrl.m_EventData.partnerData)
			-- end
			self.m_RecruitPart:RefreshEquipGrid()
		end
		if self.m_PartnerSkillInfoBox:GetActive() then
			-- local t = {info = skill, partnerid = self.m_PartnerInfo.id, data = skillData}
			local skillID = self.m_SkillInfo.info.id
			local skillData = g_PartnerCtrl:GetPartnerSkillData(self.m_SkillInfo.partnerid, skillID)
			self.m_SkillInfo.data = skillData
			self:ShowPartnerSkillInfoBox(self.m_SkillInfo)
		end
		if self.m_PartnerProtectSkillBox:GetActive() then
			self.m_PartnerProtectSkillBox:RefreshAll()
		end
		if self.m_PartnerUpgradeBox:GetActive() then
			self.m_PartnerUpgradeBox:RefreshAll()
		end
		-- 刷新列表
		-- self.m_PartnerBoxNode:ReinitPartnerList(nil, false)
		-- self:SetSpecificPartnerIDNode(oCtrl.m_EventData.partnerData.sid, false)
	elseif oCtrl.m_EventID == define.Partner.Event.UpdateAllLineup then
		g_PartnerCtrl:SetLocalSelectedPartner(-1)
		self:RefreshFormationPart()
		-- self:RefreshFormationPart()
		-- 刷新列表
		local partnerID = self.m_PartnerBoxNode:GetCurPartnerInfo().id
		self.m_PartnerBoxNode:ReinitPartnerList(nil, false)
		self:SetSpecificPartnerIDNode(partnerID, false)
	elseif oCtrl.m_EventID == define.Partner.Event.UpdateLineup then
		self.m_FormationPart:UpdateLineup(oCtrl.m_EventData)
		-- 刷新列表
		local partnerID = self.m_PartnerBoxNode:GetCurPartnerInfo().id
		self.m_PartnerBoxNode:ReinitPartnerList(nil, false)
		self:SetSpecificPartnerIDNode(partnerID, false)
	elseif oCtrl.m_EventID == define.Partner.Event.RefreshRedPoint then
		local partnerID = self.m_PartnerBoxNode:GetCurPartnerInfo().id
		self.m_PartnerBoxNode:ReinitPartnerList(nil, false)
		self:SetSpecificPartnerIDNode(partnerID, false)
		self.m_RecruitPart:RefreshRedPoint()
	elseif oCtrl.m_EventID == define.Partner.Event.RefreshEquipRedPoint then
		self.m_RecruitPart:RefreshEquipRedPoint()
	end
end

function CPartnerMainView.OnItemCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem or oCtrl.m_EventID == define.Item.Event.RefreshBagItem then
		local curPart = self.m_PageList[g_PartnerCtrl.m_PartnerRecord.View.TabIndex]
		if curPart and curPart.ResetItemGrid then
			curPart:ResetItemGrid()
		end
		if curPart and curPart.RefreshUpgradeOrRecruit then
			curPart:RefreshUpgradeOrRecruit()
		end
		if self.m_PartnerAddExpBox:GetActive() then
			self.m_PartnerAddExpBox:RefreshAll()
		end
		if self.m_PartnerUpgradeBox:GetActive() then
			self.m_PartnerUpgradeBox:RefreshAll()
		end
		if self.m_PartnerSkillInfoBox:GetActive() then
			local skillID = self.m_SkillInfo.info.id
			local skillData = g_PartnerCtrl:GetPartnerSkillData(self.m_SkillInfo.partnerid, skillID)
			self.m_SkillInfo.data = skillData
			self:ShowPartnerSkillInfoBox(self.m_SkillInfo)
		end
	end
end

function CPartnerMainView.OnAttrCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change and oCtrl.m_EventData then
		if oCtrl.m_EventData.dAttr.grade ~= oCtrl.m_EventData.dPreAttr.grade then
			self:ResetPartnerInfo()
		end
	end
end

function CPartnerMainView.SetSpecificPartnerIDNode(self, partnerID, bIsExcute)
	self.m_PartnerBoxNode:SelectSpecialPartnerBox(partnerID, bIsExcute)
end

function CPartnerMainView.ShowSpecificPart(self, tabIndex)
	tabIndex = tabIndex or 1
	g_PartnerCtrl.m_PartnerRecord.View.TabIndex = 0
	self:ShowSubPageByIndex(tabIndex, self.m_PartInfoList[tabIndex])
end

function CPartnerMainView.ShowSubPageByIndex(self, tabIndex, args)
	if g_PartnerCtrl.m_PartnerRecord.View.TabIndex == tabIndex then
		return
	end

	if tabIndex == 2 then
		self.m_PartnerBoxNode:SetUIStatus(CPartnerListNodeBox.UIStatus.Formation)
		if g_FormationCtrl:GetCurrentFmt() == 0 then
   			netformation.C2GSAllFormationInfo()
   		end
		netpartner.C2GSGetAllLineupInfo()
	else
		self.m_PartnerBoxNode:SetUIStatus(CPartnerListNodeBox.UIStatus.Common)
		self:ResetPartnerBoxNode()
	end

	local args = self.m_PartInfoList[tabIndex]
	g_PartnerCtrl.m_PartnerRecord.View.TabIndex = tabIndex
	self.m_TitleSpr:SetSpriteName(args.title)
	self.m_TitleSpr:MakePixelPerfect()
	self.m_PartTabGrid:SetTabSelect(args.btn)
	-- self.m_PartnerBoxNode:ReinitPartnerList()
	self:ShowSubPage(args.part)
	if not g_PartnerCtrl.m_PartnerNotSelectFirst then
		self:ResetPartnerInfo()
	end
	g_PartnerCtrl.m_PartnerNotSelectFirst = false
end

function CPartnerMainView.ResetPartnerInfo(self)
	local curPart = self.m_PageList[g_PartnerCtrl.m_PartnerRecord.View.TabIndex]
	if curPart and curPart.ResetPartnerInfo then
		curPart:ResetPartnerInfo()
	end
end

function CPartnerMainView.GetPartnerBoxNodeInfo(self)
	return self.m_PartnerBoxNode:GetCurPartnerInfo()
end

function CPartnerMainView.ShowPartnerEquipBoxInfo(self, partnerData)
	self.m_PartnerEquipmentBox:SetPartnerEquipBoxInfo(partnerData)
end

function CPartnerMainView.ShowPartnerCultureBox(self, cultureInfo)
	self.m_PartnerCultureSuccessBox:SetPartnerCultureSuccessBoxInfo(cultureInfo)
end

function CPartnerMainView.ShowPartnerSkillInfoBox(self, skillInfo, oSkillBox)
	self.m_SkillInfo = skillInfo
	self.m_PartnerSkillInfoBox:SetPartnerSkillInfoBoxInfo(skillInfo, oSkillBox)
end

function CPartnerMainView.ShowPartnerAddExpBox(self)
	self.m_PartnerAddExpBox:SetActive(true)
	self.m_PartnerAddExpBox:RefreshAll()
end

function CPartnerMainView.ShowPartnerProtectSkillBox(self)
	self.m_PartnerProtectSkillBox:SetActive(true)
	self.m_PartnerProtectSkillBox:RefreshAll()
end

function CPartnerMainView.ShowPartnerUpgradeBox(self)
	self.m_PartnerUpgradeBox:SetActive(true)
	self.m_PartnerUpgradeBox:RefreshAll()
end

function CPartnerMainView.ResetPartnerBoxNode(self)
	self:ShowLineupFlag(false, -1)
	self:FiterLineupPartner(false, -1)
end

function CPartnerMainView.ShowLineupFlag(self, bIsShow, iLineup)
	self.m_PartnerBoxNode:ShowLineupFlag(bIsShow, iLineup)
	self.m_IsShowLineupFlag = bIsShow
	self.m_ExtendWidget:SetActive(bIsShow)
end

function CPartnerMainView.FiterLineupPartner(self, bIsFiter, iLineup)
	self.m_PartnerBoxNode:FiterLineupPartner(bIsFiter, iLineup)
	self.m_ExtendWidget:SetActive(bIsFiter)
end

function CPartnerMainView.RefreshFormationPart(self)
	self.m_FormationPart:RefreshAll()
	self:ResetPartnerBoxNode()
end

function CPartnerMainView.OnResetFormationPart(self)
	g_PartnerCtrl:SetLocalSelectedPartner(-1)
	self:RefreshFormationPart()
end

function CPartnerMainView.OnClickPartner(self, iIndex)
	if self.m_PartnerBoxNode.m_UIStatus == CPartnerListNodeBox.UIStatus.Common then
		return
	end
	local cInfo = self:GetPartnerBoxNodeInfo()
	local sData = g_PartnerCtrl:GetRecruitPartnerDataByID(cInfo.id)
	local bIsWar = g_WarCtrl:IsWar()
	if sData then
		local iLineup = g_PartnerCtrl:GetLocalLineup()
		local iSelectedId = g_PartnerCtrl:GetLocalSelectedPartner()
		if iSelectedId == -1 and g_PartnerCtrl:IsInLineup(sData.id, g_PartnerCtrl:GetLocalLineup()) then
			--屏蔽左边的列表的出战选中，策划说的
			-- g_PartnerCtrl:SetLocalSelectedPartner(sData.id)
			-- self.m_FormationPart:SetSelectedPartner(iLineup, sData.id)
			return
		else
			if iSelectedId == sData.id or not self.m_IsShowLineupFlag then
				return
			end
			if iSelectedId ~= -1 then
				g_PartnerCtrl:ChangetLineupPos(iLineup, iSelectedId, sData.id)
				--TODO:临时处理活动的伙伴操作限制，如有相似的需求直接要求服务器飘字。
				if not g_MapCtrl:IsInSingleBiwuMap() then
					g_NotifyCtrl:FloatMsg(DataTools.GetPartnerTextInfo(2002).content)--"伙伴替换成功")
				end
			else
				g_PartnerCtrl:ChangetLineupPos(iLineup, nil, sData.id)
				if not g_MapCtrl:IsInSingleBiwuMap() then
					g_NotifyCtrl:FloatMsg(DataTools.GetPartnerTextInfo(2003).content)--"伙伴上阵成功")
				end
				self:ResetPartnerBoxNode()
			end
			if g_WarCtrl:IsWar() then
				g_NotifyCtrl:FloatMsg("战斗结束后生效")
			end
			g_PartnerCtrl:SetLocalSelectedPartner(-1)
			self:ShowLineupFlag(false, -1)
		end
	end
	self:ResetPartnerBoxNode()
end

function CPartnerMainView.CloseView(self)
	if g_WarCtrl:IsWar() and g_PartnerCtrl.m_IsPosChanged then
		g_NotifyCtrl:FloatMsg(DataTools.GetPartnerTextInfo(2006).content)
	end
	CViewBase.CloseView(self)
end

function CPartnerMainView.CheckPartnerRedPoint(self)
    if g_PromoteCtrl.m_IsHasNewPartnerCouldUnLock or g_PromoteCtrl.m_IsHasNewPartnerCouldUpgrade then
        self.m_PartTabGrid:GetChild(1).m_IgnoreCheckEffect = true
        self.m_PartTabGrid:GetChild(1):AddEffect("RedDot", 20, Vector2(-13, -17))
    else
        self.m_PartTabGrid:GetChild(1):DelEffect("RedDot")
    end
end

function CPartnerMainView.CheckFormationGuide(self)
	if g_FormationCtrl.m_NeedGuideLearn then
		self.m_PartTabGrid:GetChild(2):AddEffect("FingerInterval", nil, nil, Vector2.New(15, 0))
	else
		self.m_PartTabGrid:GetChild(2):DelEffect("FingerInterval")
	end
end

function CPartnerMainView.RegisterSysEffs(self)
	local bzBtn = self.m_PartInfoList[2].btn
	g_SysUIEffCtrl:TryAddEff("PARTNER_BZ", bzBtn)
	g_SysUIEffCtrl:DelSysEff("PARTNER_SYS")
end

return CPartnerMainView