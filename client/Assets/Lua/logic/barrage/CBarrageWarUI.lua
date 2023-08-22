local CBarrageWarUI = class("CBarrageWarUI", CBox)

function CBarrageWarUI.ctor(self, obj)

	CBox.ctor(self, obj)

	self.m_SendBox = self:NewUI(1, CBarrageSendBox)
	self.m_ViewBtn = self:NewUI(2, CSprite)
	self.m_WriteBtn = self:NewUI(3, CSprite)
	self.m_Node = self:NewUI(4, CObject)
	self.m_ViewBtn:AddUIEvent("click", callback(self, "OnClickViewBtn"))
	self.m_WriteBtn:AddUIEvent("click", callback(self, "OnClickWriteBtn"))

	self.m_State = 1      -- sendbox 1,hide  2，show

	self.m_ViewState = 2   -- 1,hide  2 show

end

function CBarrageWarUI.ShowUI(self, isShow)
	
	self:SetActive(isShow)
	self.m_SendBox:SetState(define.Barrage.State.WatchWarOrWar)

end

function CBarrageWarUI.OnClickViewBtn(self)

	if self.m_ViewState == 2 then 
		g_BarrageCtrl:CloseBarrageView()
		self.m_ViewState = 1

		if self.m_State == 2 then 
			DOTween.DOLocalMoveX(self.m_Node.m_Transform, 420 , 0.5)
			self.m_State = 1
		end 

	elseif self.m_ViewState == 1 then 
		g_BarrageCtrl:OpenBarrageView()
		self.m_ViewState = 2
	end 
	
end

function CBarrageWarUI.OnClickWriteBtn(self)

	if self.m_State == 1 then 
		DOTween.DOLocalMoveX(self.m_Node.m_Transform, -11 , 0.5)
		self.m_State = 2
	elseif self.m_State == 2 then 
		DOTween.DOLocalMoveX(self.m_Node.m_Transform, 420 , 0.5)
		self.m_State = 1
	end 
	
end


return CBarrageWarUI