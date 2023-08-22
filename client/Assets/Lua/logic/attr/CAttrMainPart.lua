local CAttrMainPart = class("CAttrMainPart", CPageBase)

function CAttrMainPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_IsShowBadge = false
end

function CAttrMainPart.OnInitPage(self)
	self.m_ActorTexture = self:NewUI(1, CActorTexture)
	self.m_NameLabel = self:NewUI(2, CLabel)
	self.m_TitleBtn = self:NewUI(3, CButton)
	self.m_CardBtn = self:NewUI(4, CButton)
	self.m_TitleLabel = self:NewUI(5, CLabel)
	self.m_LvLabel = self:NewUI(6, CLabel)
	self.m_TipBtn = self:NewUI(7, CButton)
	self.m_AttrGird = self:NewUI(8, CGrid)
	self.m_UseBtn = self:NewUI(9, CButton)
	self.m_ExpSlider = self:NewUI(10, CSlider)
	self.m_ChuBeiExpLabel = self:NewUI(11, CLabel)
	self.m_SchoolIcon = self:NewUI(12, CButton)
	self.m_EnergySlider = self:NewUI(13, CSlider)
	self.m_EnergyLabel = self:NewUI(14, CLabel)
	self.m_ExpEff = self:NewUI(15, CObject)
	self.m_EnergyEff = self:NewUI(16, CObject)
	self.m_BadgeIcon = self:NewUI(17, CSprite)
	self.m_SumSocre = self:NewUI(18, CLabel)
	self.m_AttrTipsSpr = self:NewUI(19, CSprite)
	self.m_AttrTipLabel = self:NewUI(20, CLabel)
	self.m_RingIcon = self:NewUI(21, CSprite)
	self.m_EngageLbl = self:NewUI(22, CLabel)
	self.m_DelayTimer = nil

	self.m_BadgeIcon:SetActive(false)

	--g_AttrCtrl:C2GSGetScore(1)
	self:InitContent()
end

function CAttrMainPart.InitContent(self)
	self.m_CardBtn:AddUIEvent("click", callback(self, "ShowCardView"))
	self.m_TipBtn:AddUIEvent("click", callback(self, "ShowTipView"))
	self.m_TitleBtn:AddUIEvent("click", callback(self, "ShowTitleView"))
	self.m_UseBtn:AddUIEvent("click", callback(self, "OnUserEnergy"))
	-- self.m_BadgeIcon:AddUIEvent("click", callback(self, "OnBandge"))
	self:InitEngageInfo()
	self:RefreshModel()
	self:RefreshTitleLabel()
	local tSchoolData = data.schooldata.DATA
	self.m_SchoolIcon:SetSpriteName(tostring(tSchoolData[g_AttrCtrl.school].icon))
	self.m_SchoolIcon:SetHint("门派:"..tSchoolData[g_AttrCtrl.school].name)
	-- self:RefreshBadge()
	if g_AttrCtrl.energy <= 0 then
	   self.m_EnergyEff:SetActive(false)
	end
	local maxEnergy = g_AttrCtrl:GetMaxEnergy()
	self.m_EnergySlider:SetValue(g_AttrCtrl.energy/maxEnergy)
	self.m_EnergyLabel:SetText(g_AttrCtrl.energy.."/"..maxEnergy)
	self.m_UseBtn:SetActive(g_AttrCtrl.grade >= 20)
	self:InitAttrGrid()
	self:RefreshAttr()	
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
	g_TitleCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTitleEvent"))
	-- if g_AttrCtrl.grade<data.opendata.OPEN.BADGE.p_level then
	-- 	self.m_BadgeIcon:SetActive(false)
	-- else
	-- 	self.m_BadgeIcon:SetActive(true)
	-- end
end

function CAttrMainPart.OnAttrEvent(self, oCtrl)
	if self.m_DelayTimer then
		Utils.DelTimer(self.m_DelayTimer)
	end
	-- 等一下下次再刷新数据
	self.m_DelayTimer = Utils.AddTimer(callback(self, "RefreshAttr"), 0.1, 0.1)
	if oCtrl.m_EventID == define.Attr.Event.Change and oCtrl.m_EventData.dAttr.model_info then
		self:RefreshModel()
	end
	if oCtrl.m_EventID == define.Attr.Event.Change then
		local maxEnergy = g_AttrCtrl:GetMaxEnergy()
		self.m_EnergySlider:SetValue(g_AttrCtrl.energy/maxEnergy)
		self.m_EnergyLabel:SetText(g_AttrCtrl.energy.."/"..maxEnergy)
	end
	-- if oCtrl.m_EventID == define.Attr.Event.UpgradeTouxianInfo or oCtrl.m_EventID == define.Attr.Event.Change then
	--    self:RefreshBadge()
	-- end
	if oCtrl.m_EventID == define.Attr.Event.UpDateScore then
	   self.m_SumSocre:SetText("总评分："..g_AttrCtrl.score)
	end
end

function CAttrMainPart.OnTitleEvent(self, oCtrl)
    local eventID = oCtrl.m_EventID
    if eventID == define.Title.Event.UpdateWearingTitle then
    	self:RefreshTitleLabel()
    end
end

function CAttrMainPart.RefreshModel(self)

	if g_AttrCtrl.model_info.horse and g_AttrCtrl.model_info.horse ~=0 then
		g_AttrCtrl.model_info.size = data.ridedata.RIDEINFO[g_AttrCtrl.model_info.horse].size
		local dInfo = table.copy(g_AttrCtrl.model_info)
		local model_info = table.copy(g_AttrCtrl.model_info)
	    model_info.rendertexSize = 2
		self.m_ActorTexture:ChangeShape(model_info)
		local lp = self.m_ActorTexture:GetLocalPos()
		lp.y = -97
		self.m_ActorTexture:SetLocalPos(lp)
	else
		local model_info =  table.copy(g_AttrCtrl.model_info)
	    model_info.rendertexSize = 1.2
		self.m_ActorTexture:ChangeShape(model_info)
		local lp = self.m_ActorTexture:GetLocalPos()
		lp.y = -27
		self.m_ActorTexture:SetLocalPos(lp)
	end

end

function CAttrMainPart.InitEngageInfo(self)

	local bOpen = g_OpenSysCtrl:GetOpenSysState(define.System.Engage)
	if not bOpen then
		self.m_RingIcon:SetActive(false)
		self.m_EngageLbl:SetActive(false)
		return
	end

	local equip = g_AttrCtrl.engageInfo.equip
	if equip.sid ~= 0 then
		local sid = equip.sid
		local itemdata = DataTools.GetItemData(sid)
		local shape = itemdata.icon
		self.m_RingIcon:SpriteItemShape(shape)
		local iState = g_AttrCtrl.engageInfo.status
		if iState == define.Engage.State.Engage then
			self.m_EngageLbl:SetText("[BB9F2A]".."已订婚")
		elseif iState == define.Engage.State.Marry then
			self.m_EngageLbl:SetText("[BB9F2A]已结婚")
		end

		if g_EngageCtrl.m_IsShowRingRed then
			self.m_RingIcon:AddEffect("RedDot", 20, Vector2.New(-20, -10))
		end
	else
		local shape = 10276
		self.m_RingIcon:SpriteItemShape(shape)
		self.m_RingIcon:SetGrey(true)
	end
	self.m_RingIcon:AddUIEvent("click", callback(self, "ShowRingTip"))
end

function CAttrMainPart.InitAttrGrid(self)
	local t = {
		{k = "生命", v = "max_hp"},
		{k = "法力", v = "max_mp"},
		{k = "物攻", v = "phy_attack"},
		{k = "物防", v = "phy_defense"},
		{k = "法攻", v = "mag_attack"},
		{k = "法防", v = "mag_defense"},
		{k = "治疗强度", v = "cure_power"},
		{k = "速度", v = "speed"},
		{k = "封印命中", v = "seal_ratio"},
		{k = "封印抗性", v = "res_seal_ratio"},
		{k = "物理暴击", v = "phy_critical_ratio", x = true},
		{k = "物理抗暴", v = "res_phy_critical_ratio", x = true},
		{k = "法术暴击", v = "mag_critical_ratio", x = true},
		{k = "法术抗暴", v = "res_mag_critical_ratio", x = true},
	}

	local function init(obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_NameLabel = oBox:NewUI(1, CLabel)
		oBox.m_AttrLabel = oBox:NewUI(2, CLabel)
		local info = t[idx]
		if info then
			oBox.m_NameLabel:SetText(info.k)
			oBox.m_AttrKey = info.v
			oBox.m_ShowX = info.x
		end

		oBox.m_NameLabel:AddUIEvent("press", callback(self, "OnAttrTip", idx, info.v))
		oBox.m_NameLabel:SetLongPressTime(0.3)
		return oBox
	end
	self.m_AttrGird:InitChild(init)
end

function CAttrMainPart.OnAttrTip(self, idx, attr, oBtn, bpress)
	if bpress then
		local data = data.attrnamedata.DATA
		for _,k in pairs(data) do
			if k.attr == attr then
				self.m_AttrTipLabel:SetText(k.description)
				break
			end
		end
		local oBox = self.m_AttrGird:GetChild(idx)
		self.m_AttrTipsSpr:SetParent(oBox.m_Transform)
		local x,y = self.m_AttrTipLabel:GetSize()
		self.m_AttrTipsSpr:SetSize(x+24,y+17)
		
		local localPos = oBox.m_NameLabel:GetLocalPos()
		self.m_AttrTipsSpr:SetLocalPos(Vector3.New(localPos.x-283, localPos.y+20,0))
		self.m_AttrTipsSpr:SetActive(true)
	else
		self.m_AttrTipsSpr:SetActive(false)
	end
end

function CAttrMainPart.RefreshAttr(self)
	self.m_NameLabel:SetText(g_AttrCtrl.name)
	self.m_SumSocre:SetText("总评分：" .. g_AttrCtrl.score)
	for _, oBox in ipairs(self.m_AttrGird:GetChildList()) do
		local v = g_AttrCtrl[oBox.m_AttrKey]
		-- if oBox.m_AttrKey == "seal_ratio"  or oBox.m_AttrKey == "res_seal_ratio" then -- 
		-- 	v = v * 10
		-- end
		if oBox.m_ShowX then
			oBox.m_AttrLabel:SetText(tostring(math.floor(v)).."%")
		else
			oBox.m_AttrLabel:SetText(tostring(math.floor(v)))
		end
	end

	local iExp, iNexpExp = g_AttrCtrl:GetCurGradeExp(), g_AttrCtrl:GetUpgradeExp()
	if self.m_ExpSlider:GetValue() <= 0 then
	   self.m_ExpEff:SetActive(false)
	end
	if iNexpExp ~= 0 then
		self.m_ExpSlider:SetValue(iExp/iNexpExp)
		self.m_ExpSlider:SetSliderText(string.format("%d/%d", iExp, iNexpExp))
	else
		self.m_ExpSlider:SetValue(1)
		self.m_ExpSlider:SetSliderText(string.format("%d/--", iExp))
	end
	self.m_LvLabel:SetText("等级:"..tostring(g_AttrCtrl.grade))
	self.m_ChuBeiExpLabel:SetText("当前储备经验 "..tostring(g_AttrCtrl.chubeiexp))
end

function CAttrMainPart.ShowCardView(self)
	g_LinkInfoCtrl:GetAttrCardInfo(g_AttrCtrl.pid)
end

function CAttrMainPart.ShowTipView(self)
	local zId = define.Instruction.Config.AttrMainIns
	local Descstr = string.format(data.instructiondata.DESC[zId].desc, g_AttrCtrl.server_grade)
	local str = string.gsub(data.roletypedata.LIMIT.formula.value, "lv", g_AttrCtrl.grade)
	str = string.gsub(str, "disconnect", 72*3600)
	local val = loadstring("return "..str)
	Descstr = string.gsub(Descstr, "#exp", val)
	local zContent = {title = data.instructiondata.DESC[zId].title,desc = Descstr,isAttrTip = true}
	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

function CAttrMainPart.ShowRingTip(self)
	--todo--
	if g_EngageCtrl.m_IsShowRingRed then
		g_EngageCtrl.m_IsShowRingRed = false
	end
	local itemdata = g_AttrCtrl.engageInfo
	if itemdata.equip.sid == 0 then
		-- g_NotifyCtrl:FloatMsg("订婚标示, 订婚后显示订婚戒指")
		g_MarryCtrl:MarryFloatMsg(2077)
		return
	end
	CItemTipsView:ShowView(function(oView)
		oView:SetRingItem(itemdata)
	end)
	
end

function CAttrMainPart.ShowTitleView(self)
	if g_TitleCtrl:HasTitle() then
		CTitleView:ShowView()
	else
        g_NotifyCtrl:FloatMsg(data.titledata.TEXT[1001].content)
	end
end

function CAttrMainPart.RefreshTitleLabel(self)
	if g_TitleCtrl:HasTitle() and g_TitleCtrl:IsWearingATitle() then
		self.m_TitleLabel:SetText(g_TitleCtrl:GetWearingTitle().name)
	else
		self.m_TitleLabel:SetText("无")
	end
end

function CAttrMainPart.OnUserEnergy(self)
	g_ScheduleCtrl:InitData()
	CAttrSkillQuickMakeView:ShowView(function (oView)
		--oView:SetInfo()
	end)	
end

function CAttrMainPart.OnBandge(self)
    g_AttrCtrl:OpenBadgeView()
end

function CAttrMainPart.RefreshBadge(self)
	if g_AttrCtrl.grade >= data.opendata.OPEN.BADGE.p_level then
		if g_AttrCtrl.m_BadgeInfo and g_AttrCtrl.m_BadgeInfo.tid > 1000 then
		   local touxianData = data.touxiandata.DATA[g_AttrCtrl.m_BadgeInfo.tid]
		   self.m_BadgeIcon:SetSpriteName(touxianData.tid.."icon")
		   self.m_BadgeIcon:SetActive(true)
		end
	else
		self.m_BadgeIcon:SetActive(false)
	end
end

return CAttrMainPart