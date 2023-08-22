local CBloodHud = class("CBloodHud", CAsynHud)
local min = math.min
local abs = math.abs

function CBloodHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/BloodHud.prefab", cb)
	self.m_BloodList = {}
	self.m_UpdateTimer = nil
end

function CBloodHud.OnCreateHud(self)
	self.m_HPSlider = self:NewUI(1, CSlider)
	self.m_LinGrid = self:NewUI(2, CGrid)
	self.m_BgSpr = self:NewUI(3, CSprite)
	self.m_Widget = self:NewUI(4, CWidget)
	self.m_Arge = self:NewUI(5, CObject)
	local Init = function (obj, idx)
		self["m_Linqi"..idx] =  CBox.New(obj)
		self["m_Linqi"..idx].fg = self["m_Linqi"..idx]:NewUI(1, CObject)
		self["m_Linqi"..idx].bg = self["m_Linqi"..idx]:NewUI(2, CSprite)
		self["m_Linqi"..idx].fg:SetActive(false)
	end
	self.m_LinGrid:InitChild(Init)
	self.m_Arge:SetActive(false)

	self:SetLocalScale(Vector3.one*1.5)
end

function CBloodHud.Recycle(self)
	self:StopUpdateTimer()
	self.m_BloodList = {}
	self.m_HPSlider:SetValue(0)
end

function CBloodHud.SetHP(self, percent, bIsRelive)
	if bIsRelive then
		self.m_HPSlider:SetValue(0)
	end
	self:AddBlood(percent)
end

function CBloodHud.SetLinqi(self, value)
	self.m_BgSpr:SetActive(value > 0)
	self.m_LinGrid:SetActive(value > 0)
	local height = value > 0 and 48 or 18
	self.m_Widget:SetHeight(height)
	if value > 0 then
		local gridList = self.m_LinGrid:GetChildList()
		for i=1,3 do
			local linqi = self["m_Linqi"..i]
			linqi.fg:SetActive(i <= value)
			linqi.bg:SetActive(not(i <= value))
		end
	end
end

function CBloodHud.SetRage(self, value)
	self.m_Arge:SetActive(value > 0)
end

function CBloodHud.AddBlood(self, percent)
	table.insert(self.m_BloodList, percent)
	self:StartUpdateTimer()
end

function CBloodHud.StartUpdateTimer(self)
	if self.m_UpdateTimer then
		return
	end
	local update = function ()
		if Utils.IsNil(self) then
			return false
		end
		if #self.m_BloodList == 0 then
			self:StopUpdateTimer()
			return false
		end
		local iPercent = self.m_BloodList[1]
		local iCurPercent = self.m_HPSlider:GetValue()
		local bIsRemove = false
		if self.m_HPSlider:GetValue() == 0 then
			self.m_HPSlider:SetValue(iPercent)
			bIsRemove = true
		else
			local iDValue = iPercent - iCurPercent
			local iTemp = min(abs(iDValue), 0.1)
			if iDValue ~= 0 then
				iDValue = iTemp*iDValue/abs(iDValue)
			end
			iCurPercent = iCurPercent + iDValue
			bIsRemove = abs(iCurPercent - iPercent) < 0.01
			self.m_HPSlider:SetValue(bIsRemove and iPercent or iCurPercent)
		end	
		if bIsRemove then
			table.remove(self.m_BloodList, 1)
		end
		return true
	end
	Utils.AddTimer(update, 0.03, 0)
end

function CBloodHud.StopUpdateTimer(self)
	if self.m_UpdateTimer then
		Utils.DelTimer(self.m_UpdateTimer)
		self.m_UpdateTimer = nil
	end
end

return CBloodHud