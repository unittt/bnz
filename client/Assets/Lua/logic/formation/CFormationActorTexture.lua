local CFormationActorTexture = class("CFormationActorTexture", CTexture)

CFormationActorTexture.Type = {
	Player = 1,
	Partner = 2,
}

function CFormationActorTexture.ctor(self, obj)
	CTexture.ctor(self, obj)
	self.m_DragEnabled = true
	self.m_ActorCamera = nil
	self.m_Type = self.Type.Player
	self:AddUIEvent("click", callback(self, "OnClick"))
	self:AddUIEvent("dragstart", callback(self, "OnDragStart"))
	self:AddUIEvent("drag", callback(self, "OnDrag"))
	self:AddUIEvent("dragend", callback(self, "OnDragEnd"))
end

function CFormationActorTexture.SetDragEnable(self, b)
	self.m_DragEnabled = b
end

function CFormationActorTexture.SetFormationPos(self, iPos)
	self.m_FmtPos = iPos
end

function CFormationActorTexture.SetTablePos(self, iPos)
	self.m_TablePos = iPos
end

function CFormationActorTexture.SetClickListener(self, cb)
	self.m_ClickListner = cb
end

function CFormationActorTexture.SetDragStartListener(self, cb)
	self.m_DragStartListner = cb
end

function CFormationActorTexture.SetDragEndListener(self, cb)
	self.m_DragEndListner = cb
end

function CFormationActorTexture.SetType(self, iType)
	self.m_Type = iType
end

function CFormationActorTexture.GetType(self)
	return self.m_Type
end

function CFormationActorTexture.IsTeamLeader(self)
	return self.m_TablePos == 1 and self.m_Type == self.Type.Player
end

function CFormationActorTexture.OnDragStart(self, obj, moveDelta)
	if self:IsTeamLeader() or not self.m_DragEnabled then
		return
	end
	local oActor = self.m_ActorCamera and self.m_ActorCamera:GetActor()
	if not oActor then
		return
	end
	if self.m_DragStartListner then
		self.m_DragStartListner(self)
	end
end

function CFormationActorTexture.OnDrag(self, obj, moveDelta)
	if self:IsTeamLeader() or not self.m_DragEnabled then
		return
	end
	local oActor = self.m_ActorCamera and self.m_ActorCamera:GetActor()
	if not oActor then
		return
	end
	local pos = self:GetLocalPos()
	local adjust = UITools.GetPixelSizeAdjustment()
	pos.x = pos.x + moveDelta.x*adjust
	pos.y = pos.y + moveDelta.y*adjust
	self:SetLocalPos(pos)
end

function CFormationActorTexture.OnDragEnd(self, obj, moveDelta)
	if self:IsTeamLeader() or not self.m_DragEnabled then
		return
	end
	if self.m_DragEndListner then
		self.m_DragEndListner(self)
	end
end

function CFormationActorTexture.OnClick(self)
	if self:IsTeamLeader() then
		return
	end
	if self.m_ClickListner then
		self.m_ClickListner(self)
	end
end

function CFormationActorTexture.ChangeShape(self, modelInfo, cb)
	-- if not self.m_ActorCamera then
	-- 	self.m_ActorCamera = g_CameraCtrl:GetActorCamra(modelInfo.shape)
	-- 	self.m_ActorCamera:SetOwner(self)
	-- end
	-- local o = self:GetMainTexture()
	-- self.m_ActorCamera:SetRenderTexture(o)
	-- self.m_ActorCamera:ChangeShape(modelInfo)
	-- self.m_ActorCamera:GetActor():SetLocalRotation(Quaternion.Euler(25, 0, 0))
	-- self.m_ActorCamera:GetActor():Rotate(Vector3.New(0, 100, 0))

	if not self.m_ActorCamera then
		self.m_ActorCamera = g_CameraCtrl:GetActorCamra(modelInfo.shape)
		self.m_ActorCamera:SetOwner(self)
	end

	local o = self:GetMainTexture(self.m_ActorCamera.m_Camera.aspect)	
	
	self.m_ActorCamera:SetRenderTexture(o)

	if modelInfo.rendertexSize then 
		self.m_ActorCamera:SetOrthographicSize(modelInfo.rendertexSize)
	else
		self.m_ActorCamera:SetOrthographicSize(0.8)
	end 

	self.m_ActorCamera:ChangeShape(modelInfo,  callback(self, "OnChangeDone", cb))
	local oActor = self.m_ActorCamera:GetActor()
	if oActor then
		oActor:SetLocalRotation(Quaternion.Euler(25, 0, 0))
		oActor:Rotate(Vector3.New(0, 100, 0))
	end
end

function CFormationActorTexture.OnChangeDone(self, cb)
	if cb then 
		cb()
	end 
	self.m_ActorCamera:ShowAllParticle(define.Performance.Level.high)
end

function CFormationActorTexture.CheckReallyShow(self)
	local bShow = self:GetActive(true)
	if bShow then
		if not self.m_ConstrainPanel then
			local panel = NGUI.UIPanel.Find(self.m_Transform)
			if panel then
				self.m_ConstrainPanel = CPanel.New(panel.gameObject)
			end
		end
		if self.m_ConstrainPanel then
			bShow = not self.m_ConstrainPanel:IsFullOut(self)
		end
	end
	if self.m_ActorCamera then
		if self.m_LastShow ~= bShow then
			self.m_LastShow = bShow
			self.m_ActorCamera:SetActive(bShow)
		end
	end
	return true
end

function CFormationActorTexture.GetMainTexture(self)
	if not self.m_UIWidget.mainTexture then
		local w, h = self:GetSize()
		local o =  UnityEngine.RenderTexture.GetTemporary(w, h, 16)
		self.m_UIWidget.mainTexture = o
	end
	return self.m_UIWidget.mainTexture
end

function CFormationActorTexture.PlayerAnimator(self, animaName)
	local oActor = self.m_ActorCamera and self.m_ActorCamera:GetModel()
	if not oActor then
		return
	end
	
	if self.m_AnimaTimer then
		return
	else
		animaName = animaName or "show"
		local function delay()
			local function f()
				oActor:CrossFade("idleCity", 0.1)
			end
			oActor:CrossFade(animaName, 0.2, 0, 1, f)
			return true
		end
		self.m_AnimaTimer = Utils.AddTimer(delay, 3, 0)
	end
end

function CFormationActorTexture.StopAnimaTimer(self)
	if self.m_AnimaTimer then
		Utils.DelTimer(self.m_AnimaTimer)
		self.m_AnimaTimer = nil
	end
end


function CFormationActorTexture.Destroy(self)
	local model = self.m_ActorCamera:GetModel()
	if model then
		model:Destroy()
	end
	self.m_ActorCamera:Destroy()
	CObject.Destroy(self)
end
return CFormationActorTexture
