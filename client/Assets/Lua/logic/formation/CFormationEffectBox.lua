local CFormationEffectBox = class("CFormationEffectBox", CBox)

function CFormationEffectBox.ctor(self, obj)
	CBox.ctor(self, obj)

	-- self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_LevelSpr = self:NewUI(1, CSprite)
	self.m_FormationIconSpr = self:NewUI(2, CSprite)
	self.m_UpArrowBtn = self:NewUI(3, CButton)
	self.m_DownArrowBtn = self:NewUI(4, CButton)
	self.m_LevelL = self:NewUI(5, CLabel)
	self.m_LevelObj = self:NewUI(6, CObject)
	self.m_EffectObj = self:NewUI(7, CObject)
	self.m_EmptyObj = self:NewUI(8, CObject)
	self.m_EffectTables = {}
	for i=1,5 do
		self.m_EffectTables[i] = self:NewUI(i + 8, CTable)
	end
	self.m_CloneBox = self:NewUI(14, CBox)
	self.m_ExtendEffL = self:NewUI(15, CLabel)

	--需要负值显示绿色的特殊属性
	self.m_SpecialAttr = {
		-- ["受伤害"] = true,
		-- ["受物伤"] = true,
		-- ["受法伤"] = true,
	}
	self.m_SelColor = Color.RGBAToColor("BD5733") 
	self.m_DefColor = Color.RGBAToColor("244B4E") 
	self:InitContent()
end

function CFormationEffectBox.InitContent(self)
	self.m_CloneBox:SetActive(false)
	self.m_UpArrowBtn:AddUIEvent("click", callback(self, "OnChangeLevel", 1))
	self.m_DownArrowBtn:AddUIEvent("click", callback(self, "OnChangeLevel", -1))
end

function CFormationEffectBox.SetFormationInfo(self, dInfo, tPlayerList, tPartnerList)
	self.m_FmtId = dInfo.fmt_id
	self.m_FmtInfo = dInfo
	self.m_FmtName = dInfo.cData.name
	self.m_Grade = math.max(dInfo.grade, 1)
	self.m_PlayerList = tPlayerList
	self.m_PartnerList = tPartnerList
end

function CFormationEffectBox.GetFormationGrade(self)
	return self.m_Grade
end

function CFormationEffectBox.RefreshUI(self, bNotRefreshIcon)
	if not bNotRefreshIcon then
		self:RefreshFomationIcon()
	end
	self:RefreshEffectList()
	self:UpdateArrowStatus()
	self:RefreshExtendEffLabel()
end

function CFormationEffectBox.RefreshFomationIcon(self)
	local sIcon = self.m_FmtInfo.cData.icon
	self.m_FormationIconSpr:SetSpriteName(sIcon)
end

function CFormationEffectBox.RefreshEffectList(self)
	local bIsEmptyFmt = self.m_FmtId == 1
	self.m_EmptyObj:SetActive(bIsEmptyFmt)
	self.m_EffectObj:SetActive(not bIsEmptyFmt)
	self.m_LevelObj:SetActive(not bIsEmptyFmt)
	if bIsEmptyFmt then
		return
	end
	local list = DataTools.GetFormationAttrList(self.m_FmtId)
	local iPlayerCnt = #self.m_PlayerList
	for i,dInfo in ipairs(list) do
		local oTable = self.m_EffectTables[i]
		self:RefreshEffectTable(oTable, dInfo)
	end
end

function CFormationEffectBox.RefreshEffectTable(self, oTable, dEffInfo)
	local tEffectInfo = DataTools.GetFormationEffect(self.m_FmtId, dEffInfo.pos, self.m_Grade)
	oTable:Clear()
	if not tEffectInfo then
		return 
	end

	for _,dInfo in ipairs(tEffectInfo) do
		local oBuffBox = self.m_CloneBox:Clone()
		oBuffBox.m_BuffL = oBuffBox:NewUI(1, CLabel)
		oBuffBox.m_CompareSpr = oBuffBox:NewUI(2, CSprite)
		oBuffBox.m_BuffValueL = oBuffBox:NewUI(3, CLabel)
		local sDesc = dInfo.name
		local sValue = ""
		--特殊属性负值为增益效果
		if self.m_SpecialAttr[dInfo.name] and dInfo.value <= 0 then
			-- oBuffBox.m_CompareSpr:SetSpriteName("h7_sheng")
			sDesc = string.format("[c]#I%s#n", sDesc)
			sValue = string.format("[c]#I%d%%#n", dInfo.value)
		elseif self.m_SpecialAttr[dInfo.name] and dInfo.value > 0 then
			sDesc = string.format("[c][FF7633]%s", sDesc)
			sValue = string.format("[c][FF7633]+%d%%", dInfo.value)
			-- oBuffBox.m_CompareSpr:SetSpriteName("h7_jiang")
		elseif dInfo.value > 0 then
			-- oBuffBox.m_CompareSpr:SetSpriteName("h7_sheng")
			sDesc = string.format("[c]#I%s#n", sDesc)
			sValue = string.format("[c]#I+%d%%#n", dInfo.value)
		else
			sDesc = string.format("[c][FF7633]%s", sDesc)
			sValue = string.format("[c][FF7633]%d%%", dInfo.value)
			-- oBuffBox.m_CompareSpr:SetSpriteName("h7_jiang")
		end	
		if string.utfStrlen(dInfo.name) > 2 then 
			oBuffBox.m_BuffL:SetSpacingX(0)
		end
		oBuffBox.m_BuffL:SetText(sDesc)
		oBuffBox.m_BuffValueL:SetText(sValue)
		oBuffBox:SetActive(true)
		oTable:AddChild(oBuffBox)
	end
end

function CFormationEffectBox.RefreshExtendEffLabel(self)
	-- self.m_ExtendEffL:SetActive(self.m_SelectedFmtId ~= 1 and self.m_FmtInfo.grade > 0)
	-- if not self.m_ExtendEffL:GetActive() then
	-- 	return
	-- end
	local dData = self.m_FmtInfo.cData
	local sFormula = string.replace(dData.positive, "lv", self.m_Grade)
	local func = loadstring("return "..sFormula)
	local iPositiveValue = func()
	sFormula = string.replace(dData.passive, "lv", self.m_Grade)
	func = loadstring("return "..sFormula)
	local iPassiveValue = func()
	local sDesc = string.format("[CA2512]克制效果+%d%% [1B6D95]克制抵抗+%d%%", iPositiveValue, iPassiveValue)
	self.m_ExtendEffL:SetText(sDesc)
end

function CFormationEffectBox.UpdateArrowStatus(self)
	local iMinLv = 1
	local iCurLv = self.m_Grade

	if self.m_FmtInfo.grade == self.m_Grade then
		self.m_LevelSpr:SetSpriteName("h7_di_15")
		self.m_LevelL:SetColor(self.m_SelColor)
	else		
		self.m_LevelSpr:SetSpriteName("h7_di_1")
		self.m_LevelL:SetColor(self.m_DefColor)
	end
	self.m_LevelL:SetText(self.m_FmtName..iCurLv.."级")
end

function CFormationEffectBox.OnChangeLevel(self, iChangeValue)
	-- self.m_Grade = self.m_Grade + iChangeValue
	if not self.m_FmtInfo then
		return
	end
	local iMaxLv = #self.m_FmtInfo.cData.exp
	self.m_Grade = (self.m_Grade + iChangeValue)%(iMaxLv + 1)
	self.m_Grade = (self.m_Grade == 0 and iChangeValue < 0 ) and iMaxLv or math.max(1, self.m_Grade)
	self:RefreshUI(true)
end

return CFormationEffectBox