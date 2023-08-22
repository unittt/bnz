local CWarriorPassiveHud = class("CWarriorPassiveHud", CAsynHud)

function CWarriorPassiveHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/WarriorPassiveHud.prefab", cb)
end

function CWarriorPassiveHud.OnCreateHud(self)
	self.m_PassiveBox = self:NewUI(1, CBox)
	self.m_PassiveBox:SetActive(false)
	self.m_PassivesCache = {}
	self:SetLocalScale(Vector3.one*1.5)
end

function CWarriorPassiveHud.RefreshPassive(self, magicID)
	local passiveData = DataTools.GetMaigcPassiveData(magicID)
	if not passiveData and string.len(passiveData.passiveIcon) <= 0 then
		return
	end

	local passiveBox = self.m_PassivesCache[1]
	if passiveBox then
		table.remove(self.m_PassivesCache, 1)
	else
		passiveBox = self.m_PassiveBox:Clone()
		passiveBox:SetParent(self.m_Transform)

		passiveBox.sprite = passiveBox:NewUI(1, CSprite)
		-- passiveBox.label = passiveBox:NewUI(2, CLabel)

		passiveBox.tweenAlpha = passiveBox.sprite:GetComponent(classtype.TweenAlpha)
		passiveBox.tweenScale = passiveBox.sprite:GetComponent(classtype.TweenScale)
	end
	passiveBox:SetActive(true)
	passiveBox.sprite:SetSpriteName(passiveData.passiveIcon)
	-- passiveBox.label:SetText(passiveData.name)

	passiveBox.tweenAlpha:ResetToBeginning()
	passiveBox.tweenScale:ResetToBeginning()
	passiveBox.tweenAlpha:Play(true)
	passiveBox.tweenScale:Play(true)
	local function delay()
		if Utils.IsNil(self) then
			return false
		end

		table.insert(self.m_PassivesCache, passiveBox)
		return false
	end
	Utils.AddTimer(delay, 0.5, 1.2)
end

return CWarriorPassiveHud