local CFortuneView = class("CFortuneView", CViewBase)

function CFortuneView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Welfare/FortuneView.prefab", cb)

	--界面设置
	self.m_ExtendClose = "Black"	


end

function CFortuneView.OnCreateView(self)

	
	self.m_FortuneNode = self:NewUI(1, CObject)
	self.m_ConfirmBtn = self:NewUI(2, CButton)
	self.m_Name = self:NewUI(3, CLabel)
	self.m_DesLabel = self:NewUI(4, CLabel)
	self.m_Icon = self:NewUI(5, CSprite)
	self.m_EffectLabel = self:NewUI(6,CLabel)

	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnClickConfirm"))

	self:InitContent()
		
end

function CFortuneView.OnClickConfirm(self)

        local function onEnd()

        	self:CloseView()
 
        end

        local tween = DOTween.DOLocalMoveX(self.m_FortuneNode.m_Transform, -150, 1)

        DOTween.OnComplete(tween, onEnd)	
	
end

function CFortuneView.OnClose(self)
	
	self:OnClickConfirm()

end



function CFortuneView.InitContent(self)
	
		local fortuneId = g_SignCtrl.m_fortune
		local fortuneData = data.huodongdata.fortune[fortuneId]
		self.m_Name:SetText(fortuneData.name) 
		self.m_DesLabel:SetText(fortuneData.desc)
		self.m_EffectLabel:SetText(fortuneData.effectdesc)

end

return CFortuneView