local CWarTargetDetailView = class("CWarTargetDetailView", CViewBase)

function CWarTargetDetailView.ctor(self, cb)
	CViewBase.ctor(self, "UI/War/WarTargetDetailView.prefab", cb)
	-- self.m_ExtendClose = "ClickOut"
end

function CWarTargetDetailView.OnCreateView(self)
	self.m_BuffTable = self:NewUI(1, CTable)
	self.m_BuffBox = self:NewUI(2, CBox)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_WarCmdBtn = self:NewUI(4, CButton)
	self.m_StatusInfo = self:NewUI(5, CBox)

	self.m_StatusInfo.m_StatusLabel = self.m_StatusInfo:NewUI(1, CLabel)
	-- self.m_StatusInfo.MPLabel = self.m_StatusInfo:NewUI(2, CLabel)
	-- self.m_StatusInfo.SPLabel = self.m_StatusInfo:NewUI(3, CLabel)

	self.m_BuffBox:SetActive(false)
	self.m_WarCmdBtn:AddUIEvent("click", callback(self, "OpenWarCmdView"))
	g_UITouchCtrl:TouchOutDetect(self, callback(self, "CheckClose"))
end

function CWarTargetDetailView.SetWarrior(self, oWarrior)
	self.m_WarriorRef = weakref(oWarrior)
	local sText = string.format("#G%s#n", oWarrior:GetName())
	-- if oWarrior.m_OwnerWid then
	-- 	local oOwner = g_WarCtrl:GetWarrior(oWarrior.m_OwnerWid)
	-- 	sText = sText..string.format("(%s)", oOwner:GetName())
	-- end
	self.m_NameLabel:SetRichText(sText, nil, nil, true)
	self:RefreshBuffTable()
	self:RefreshStatusTable()
	self.m_WarCmdBtn:SetActive(g_TeamCtrl:IsCommander(g_AttrCtrl.pid))
end

function CWarTargetDetailView.GetWarrior(self)
	return getrefobj(self.m_WarriorRef)
end

function CWarTargetDetailView.RefreshBuffTable(self)
	self.m_BuffTable:Clear()
	local oWarrior = self:GetWarrior()
	if not oWarrior then
		return
	end
	
	local lBuffs = oWarrior:GetBuffList()
	for i, dBuffInfo in ipairs(lBuffs) do
		local oBox = self:GetWarBuffBox(dBuffInfo.buff_id, dBuffInfo.bout, dBuffInfo.attrlist)
		self.m_BuffTable:AddChild(oBox)
	end
end

function CWarTargetDetailView.RefreshStatusTable(self)
	local oWarrior = self:GetWarrior()
	if not oWarrior then
		return
	end

	-- 是否需要显示状态信息
	local showStatusInfo = oWarrior:IsHeroOwn() or (oWarrior:IsAlly() and oWarrior.m_Type == define.Warrior.Type.Partner)
	-- self.m_StatusInfo:SetActive(showStatusInfo)
	if showStatusInfo then
		local dStatus = oWarrior.m_Status
		local sStatus = string.format("#G气血：#n%s/%s\n#G法力：#n%s/%s", dStatus.hp, dStatus.max_hp, dStatus.mp, dStatus.max_mp)
		if oWarrior.m_Type == define.Warrior.Type.Player then
			sStatus = sStatus..string.format("\n#G怒气：#n%s/%s", dStatus.sp, dStatus.max_sp)
		end
		self.m_StatusInfo.m_StatusLabel:SetRichText(sStatus, nil, nil, true)
	end
	self.m_StatusInfo:SetActive(false)
	self.m_StatusInfo:SetActive(showStatusInfo)
	self.m_BuffTable:Reposition()
end

function CWarTargetDetailView.GetWarBuffBox(self, buffid, bout, attrlist)
	local oBox = self.m_BuffBox:Clone()
	oBox:SetActive(true)
	oBox.m_Icon = oBox:NewUI(1, CSprite)
	oBox.m_NameLabel = oBox:NewUI(2, CLabel)
	oBox.m_DescLabel = oBox:NewUI(3, CLabel)
	local dBuff = data.buffdata.DATA[buffid]
	oBox.m_Icon:SpriteSkill(dBuff.icon)
	-- local dFloorBuff = {171, 176, 177}
	local dAttr = self:GetAttrDict(attrlist)
	local iFloor = dAttr.level or dAttr.point
	if iFloor then
		oBox.m_NameLabel:SetText("[CCEBDB]" .. dBuff.name .. iFloor .. "层")
	else
		oBox.m_NameLabel:SetText("[CCEBDB]" .. dBuff.name .. bout .. "回合")
	end
	local t = {"[0fff32]", "[fb3636]", "[ffde00]"}
	oBox.m_DescLabel:SetText(t[math.max(dBuff.color, 1)] .. dBuff.desc)
	return oBox
end

function CWarTargetDetailView.GetAttrDict(self, attrlist)
	local dict = {}
	for _, v in ipairs(attrlist) do
		dict[v.key] = v.value
	end
	return dict
end

function CWarTargetDetailView.OpenWarCmdView(self)
	CWarCmdSelView:ShowView(function(oView)
		local oWarrior = self:GetWarrior()
		oView:SetTarget(oWarrior)
	end)
	self:CloseView()
end

function CWarTargetDetailView.CheckClose(self)
	if not g_WarTouchCtrl:IsPressing() then
		self:OnClose()
	end
end
return CWarTargetDetailView