local CFormationMutexBox = class("CFormationMutexBox", CBox)

function CFormationMutexBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Table = self:NewUI(1, CTable)
	self.m_CloneBuffL = self:NewUI(2, CLabel)
	self.m_CloneFmtL = self:NewUI(3, CLabel)
	self:InitContent()
end

function CFormationMutexBox.InitContent(self)
	self.m_CloneFmtL:SetActive(false)
	self.m_CloneBuffL:SetActive(false)
end

function CFormationMutexBox.SetFormationInfo(self, dInfo, iGrade)
	self.m_FormationInfo = dInfo
	self.m_FmtId = dInfo.fmt_id
	self.m_Grade = iGrade
	self.m_MutexInfo = self:GetFmtMutexInfo()
end

function CFormationMutexBox.GetFmtMutexInfo(self)
	local dData = self.m_FormationInfo.cData
	return g_FormationCtrl:GetFmtMutexInfo(dData)
end 

function CFormationMutexBox.RefreshUI(self)
	self.m_Table:Clear()
	self:AddPositiveFmt()
	self:AddPassiveFmt()
end

function CFormationMutexBox.AddPositiveFmt(self)
	if not self.m_MutexInfo then
		return
	end
	local dData = self.m_FormationInfo.cData

	local iPositiveValue = 0
	if self.m_Grade ~= 0 then
		local sFormula = string.replace(dData.positive, "lv", self.m_Grade)
		local func = loadstring("return "..sFormula)
		iPositiveValue = func()
	end

	for _,dMutex in ipairs(self.m_MutexInfo) do
		if tonumber(dMutex.value) > 0 then
			local oBuffL = self.m_CloneBuffL:Clone()
			local sBuff = string.format("#G克制以下阵法（伤害结果+%d%%）", dMutex.value + iPositiveValue)
			oBuffL:SetActive(true)
			oBuffL:SetText(sBuff)
			self.m_Table:AddChild(oBuffL)

			local oFmtL = self.m_CloneFmtL:Clone()
			local sFmt = ""
			local iCnt = 0
			for _,fmtId in pairs(dMutex.list) do
				if fmtId ~= 1 then
					local dFmtData = data.formationdata.BASEINFO[fmtId]
					sFmt = sFmt..dFmtData.name.."   "
					iCnt = iCnt + 1
					if iCnt%3 == 0 and self.m_FmtId == 1 then
						sFmt = sFmt.."\n"
					end 
				end
			end
			oFmtL:SetText(sFmt)
			oFmtL:SetActive(true)
			self.m_Table:AddChild(oFmtL)
		end
	end
end

function CFormationMutexBox.AddPassiveFmt(self)
	if not self.m_MutexInfo then
		return
	end
	local dData = self.m_FormationInfo.cData

	local iPassiveValue = 0
	if self.m_Grade ~= 0 then
		local sFormula = string.replace(dData.passive, "lv", self.m_Grade)
		local func = loadstring("return "..sFormula)
		iPassiveValue = func()
	end


	for _,dMutex in ipairs(self.m_MutexInfo) do
		if tonumber(dMutex.value) < 0 then
			local oBuffL = self.m_CloneBuffL:Clone()
			local sBuff = string.format("[c][ff7633]被以下阵法克制(伤害结果-%d%%)", - dMutex.value - iPassiveValue)
			oBuffL:SetActive(true)
			oBuffL:SetText(sBuff)
			self.m_Table:AddChild(oBuffL)

			local oFmtL = self.m_CloneFmtL:Clone()
			local sFmt = ""
			local iCnt = 0
			for _,fmtId in pairs(dMutex.list) do
				if fmtId ~= 1 then
					local dFmtData = data.formationdata.BASEINFO[fmtId]
					sFmt = sFmt..dFmtData.name.."   "
					iCnt = iCnt + 1
					if iCnt%3 == 0 and self.m_FmtId == 1 then
						sFmt = sFmt.."\n"
					end 
				end
			end
			oFmtL:SetText(sFmt)
			oFmtL:SetActive(true)
			self.m_Table:AddChild(oFmtL)
		end
	end
end
return CFormationMutexBox