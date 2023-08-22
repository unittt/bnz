local CRumorBox = class("CRumorBox", CBox)

function CRumorBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Label = self:NewUI(1, CLabel)
	self.m_Bg = self:NewUI(2, CSprite)
	self.m_Icon = self:NewUI(3, CSprite)
	self.m_MsgList = {}
	self.m_DisplayMsg = nil
	self.m_Bg:SetActive(false)
	self.m_Label:SetActive(false)
	self.m_Icon:SetActive(false)
end

function CRumorBox.AddMsg(self, oMsg)
	table.insert(self.m_MsgList, oMsg)
	if not self.m_DisplayMsg then
		self:PlayNext()
	end
end

function CRumorBox.DisplayOne(self)
	local oMsg = self.m_MsgList[1]
	table.remove(self.m_MsgList, 1)
	self.m_DisplayMsg = oMsg
	self.m_Bg:SetActive(true)
	-- self.m_Icon:SetActive(true)
	self.m_Label:SetActive(true)
	self.m_Label:SetRichText("#xing_1 "..oMsg:GetText(), nil, nil, true)
	local oBoxCollider = self.m_Label:GetComponent(classtype.BoxCollider)
	if oBoxCollider then
		oBoxCollider.enabled = false 
	end 

	local labelW, _ = self.m_Label:GetSize()
	local bgW, _ = self.m_Bg:GetSize()
	local screenWidth = UnityEngine.Screen.width
	local screenHeight = UnityEngine.Screen.height
	local vet = self:GetWorldPos(Vector2.New(screenWidth*8/10, screenHeight*8.35/10))
	local Width = UITools.CalculateRelativeWidgetBounds(self.m_Label.m_Transform).size.x
	-- self.m_Bg:ResetAndUpdateAnchors()
	local function delay()
		Utils.AddTimer(callback(self, "PlayNext"), 0, 0)
	end

	self.m_Label:SetPos(vet)
	local tween = DOTween.DOLocalMoveX(self.m_Label.m_Transform, vet.x-(760 + Width), 10+Width*(1/120), false)
	DOTween.OnComplete(tween, delay)
	--Linear = 1,InSine = 2,OutSine = 3,InOutSine = 4,InQuad = 5,
	DOTween.SetEase(tween, 1)
end

function CRumorBox.PlayNext(self)
	self.m_DisplayMsg = nil
	self.m_Bg:SetActive(false)
	self.m_Label:SetActive(false)
	self.m_Icon:SetActive(false)
	if next(self.m_MsgList) then
		self:DisplayOne()
	end
end

function CRumorBox.GetWorldPos(self, screenPos)
	local oUICamera = g_CameraCtrl:GetUICamera()
	local WorldPos = oUICamera:ScreenToWorldPoint(screenPos)
	return WorldPos
end

return CRumorBox