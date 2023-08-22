local CWarFormationInfoView = class("", CViewBase)

function CWarFormationInfoView.ctor(self, cb)
	CViewBase.ctor(self, "UI/War/WarFormationInfoView.prefab", cb)
	self.m_ExtendClose = "ClickOut"
end

function CWarFormationInfoView.OnCreateView(self)
	self.m_CampL = self:NewUI(1, CLabel)
	self.m_FormationL = self:NewUI(2, CLabel)
	self.m_Tabel = self:NewUI(3, CTable)
	self.m_PosEffBoxClone = self:NewUI(4, CBox)
	self.m_BgSpr = self:NewUI(5, CSprite)

	self.m_CampL:SetActive(false)
	self.m_FormationL:SetLocalPos(Vector3.New(-140, 106, 0))

	self:InitContent()
end

function CWarFormationInfoView.InitContent(self)
	self.m_PosEffBoxClone:SetActive(false)
end

function CWarFormationInfoView.SetFormationInfo(self, iFmtId, iFmtGrade, bIsSelf, iFmtId2, iFmtGrade2)
	self.m_FmtId = iFmtId or 1
	self.m_FmtGrade = iFmtGrade or 1
	self.m_FmtId2 = iFmtId2
	self.m_FmtGrade2 = iFmtGrade2
	self:RefreshFormation(bIsSelf)
	self:RefreshEffectTable()
end

function CWarFormationInfoView.RefreshFormation(self, bIsSelf)
	local dFmtInfo = data.formationdata.BASEINFO[self.m_FmtId]
	local dMutexInfo = g_FormationCtrl:GetFmtMutexInfo(dFmtInfo)
	-- 克制点数
	local restraint = nil
	if dMutexInfo then
		for _,v in ipairs(dMutexInfo) do
			if table.index(v.list, self.m_FmtId2) then
				restraint = v.value
				break
			end
		end
	end

	-- 克制与被克制
	if restraint then
		if restraint > 0 then
			-- 克制
			local positiveFormula = string.replace(dFmtInfo.positive, "lv", self.m_FmtGrade)
			local funcPositive = loadstring("return " .. positiveFormula)
			local iPositiveValue = funcPositive()

			local passiveFormula = string.replace(dFmtInfo.passive, "lv", self.m_FmtGrade2)
			local funcPassive = loadstring("return " .. passiveFormula)
			local iPassiveValue = funcPassive()
			restraint = string.format("(#G伤害结果+%d%%)", restraint+iPositiveValue-iPassiveValue)
		else
			-- 被克制
			local positiveFormula = string.replace(dFmtInfo.positive, "lv", self.m_FmtGrade2)
			local funcPositive = loadstring("return " .. positiveFormula)
			local iPositiveValue = funcPositive()

			local passiveFormula = string.replace(dFmtInfo.passive, "lv", self.m_FmtGrade)
			local funcPassive = loadstring("return " .. passiveFormula)
			local iPassiveValue = funcPassive()
			restraint = string.format("(#R伤害结果%d%%)", restraint-iPositiveValue+iPassiveValue)
		end
	end

	self.m_CampL:SetText(bIsSelf and "[fdd755]我方" or "[25ffe1]敌方")
	local sInfo = self.m_FmtGrade .. "级" .. dFmtInfo.name .. (restraint and restraint or "")
	self.m_FormationL:SetRichText(sInfo, nil, nil, true)
end

function CWarFormationInfoView.RefreshEffectTable(self)
	self.m_Tabel:Clear()
	for i=1,5 do
		local dEffectInfo = DataTools.GetFormationEffect(self.m_FmtId, 
			i, self.m_FmtGrade)
		if dEffectInfo then
			local oBox = self:CreateEffectBox(i, dEffectInfo)
			self.m_Tabel:AddChild(oBox)
		end
	end
	self.m_Tabel:Reposition()
end

function CWarFormationInfoView.CreateEffectBox(self, iPos, dEffectInfo)
	local oBox = self.m_PosEffBoxClone:Clone()
	oBox.m_PosL = oBox:NewUI(1, CLabel)
	oBox.m_EffectL = {	
		[1] = oBox:NewUI(2, CLabel),
		[2] = oBox:NewUI(3, CLabel)
	}

	oBox.m_PosL:SetText(iPos.."号位")
	for i,oLabel in ipairs(oBox.m_EffectL) do
		local dInfo = dEffectInfo[i]
		oLabel:SetActive(false)
		if dInfo then
			oLabel:SetActive(true)
			if dInfo.value > 0 then
				oLabel:SetText("[0fff32ff]"..dInfo.name.."+"..dInfo.value .. "%")
			else
				oLabel:SetText("[fb3636ff]"..dInfo.name..dInfo.value .. "%")
			end
		end
	end
	oBox:SetActive(true)
	return oBox
end

return CWarFormationInfoView