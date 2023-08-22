local CWarriorTipHud = class("CWarriorTipHud", CAsynHud)

CWarriorTipHud.g_BgName = {"h7_zhandoudi_1", "h7_zhandoudi_2", "h7_zhandoudi_3"}
CWarriorTipHud.g_Effect = {"09b534", "f53218", "1ca0ff"}
function CWarriorTipHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/WarriorTipHud.prefab", cb)
end

function CWarriorTipHud.OnCreateHud(self)
	self.m_FloatBox = self:NewUI(1, CFloatBox)
	self:SetLocalScale(Vector3.one*1.2)
	self.m_FloatBox.m_FloatLabel:SetLocalScale(Vector3.one*1.2)
end

function CWarriorTipHud.SetTipHud(self, info)
	local spriteName = CWarriorTipHud.g_BgName[info.style]
	self.m_FloatBox.m_BgSprite:SetSpriteName(spriteName)
	local textColor = CWarriorTipHud.g_Effect[info.style]
	self.m_FloatBox.m_FloatLabel:SetEffectColor(Color.RGBAToColor(textColor))

	self.m_FloatBox:SetText(info.content)
	self.m_FloatBox:SetTimer(1.4 * 0.75, function ()
		self:SetActive(false)
		self.m_FloatBox:SetAlpha(1)
	end)
	self:AddBoxWithAnim(self.m_FloatBox)
end

function CWarriorTipHud.AddBoxWithAnim(self, oBox)
	oBox:SetActive(true)
	oBox:SetParent(self.m_Transform)
	oBox:SetLocalPos(Vector3.zero)
	DOTween.DOKill(self.m_Transform, true)
	local time = 0.75
	
	local tween1 = DOTween.DOLocalMoveY(oBox.m_Transform, oBox.m_BgSprite:GetHeight()*3, time)
	DOTween.OnComplete(tween1, function()
		if Utils.IsExist(oBox) then
			DOTween.DOKill(oBox.m_Transform, true)
			oBox:SetAsFirstSibling()
		end
	end)

	oBox:SetLocalScale(Vector3.one * 0.9)
	local tween2 = DOTween.DOScale(oBox.m_Transform, Vector3.one, time*1.4)
	DOTween.SetEase(tween2, enum.DOTween.Ease.OutElastic)
end

return CWarriorTipHud