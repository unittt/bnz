-- local CPartnerUpperSuccessSubPart = class("CPartnerUpperSuccessSubPart", CPageBase)

-- function CPartnerUpperSuccessSubPart.ctor(self, obj)
-- 	CBox.ctor(self, obj)

-- 	self.m_Name = self:NewUI(1, CLabel)
-- 	self.m_DetailsProp = self:NewUI(2, CBox)
-- 	-- PartnerProp
-- 	for i,v in ipairs(CPartnerMainView.PropNameList) do
-- 		self.m_DetailsProp[v[2]] = self.m_DetailsProp:NewUI(i, CLabel)
-- 		if i == 8 then
-- 			break
-- 		end
-- 	end
-- end

-- function CPartnerUpperSuccessSubPart.SetCultureSubPartInfo(self, cultureInfo)
-- 	local upperInfo = DataTools.GetPartnerUpperInfo(cultureInfo.partnerData.upper)
-- 	self.m_Name:SetText("[c][ADE6D8]等级上限 #O" .. upperInfo.level)
-- 	for i,v in ipairs(CPartnerMainView.PropNameList) do
-- 		local textStr = v[1] .. " " .. (cultureInfo.offsetData[v[2]] or 0)
-- 		self.m_DetailsProp[v[2]]:SetText(textStr)
-- 		if i == 8 then
-- 			break
-- 		end
-- 	end
-- end

-- return CPartnerUpperSuccessSubPart