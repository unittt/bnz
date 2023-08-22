local CActorTexture = class("CActorTexture", CTexture)

function CActorTexture.ctor(self, obj)
	CTexture.ctor(self, obj)
	self.m_ActorCamera = nil
	self.m_ModelInfo = nil
	self:AddUIEvent("drag", callback(self, "OnDrag"))
	self:AddUIEvent("click", callback(self, "OnClick"))
end

function CActorTexture.OnDrag(self, obj, moveDelta)
	local oActor = self.m_ActorCamera and self.m_ActorCamera:GetActor()
	if not oActor then
		return
	end
	oActor:Rotate(Vector3.New(0, - moveDelta.x * 3, 0))
end

function CActorTexture.OnClick(self, obj)
	local oActor = self.m_ActorCamera and self.m_ActorCamera:GetActor()
	if not oActor then
		return
	end

	if self.m_ModelInfo.ignoreClick then 
		return
	end 

	local sCur = oActor:GetState()
	local iShape = oActor.m_Shape
	local anilist = {"idleCity", "walk", "show"}
	if oActor.m_HasHorse then
		anilist = {"idleCity", "run", "run"}
		iShape = oActor.m_RideShape
	end
	local idx = table.index(anilist, sCur)
	if idx then
		table.remove(anilist, idx)
	end

	--特殊处理
	if table.index({4003}, oActor.m_Shape) then
		anilist = {"run"}
	end

	local clipInfo = ModelTools.GetAnimClipData(iShape)
	if not clipInfo then
		anilist = {}
	end 
	for i,v in ipairs(anilist) do
		if not clipInfo[v] then
			table.remove(anilist, i)
		end
	end

	--需要不播放除idle以外的其他动画，设置model_info.notplayanim = true
	if self.m_ModelInfo and self.m_ModelInfo.notplayanim then
		anilist = {"idleCity"}
	end

	local sAniName = anilist[Utils.RandomInt(1, #anilist)]
	local function f()
		oActor:CrossFade("idleCity", 0)
	end
	local endNormalized = 1
	if sAniName == "run" or sAniName == "walk" then
		endNormalized = 3
	end
	if sAniName then
		oActor:CrossFade(sAniName, 0.2, 0, endNormalized, f)
	end

	if self.m_ClickCallback then
		self.m_ClickCallback()
	end
end

function CActorTexture.SetClickCallback(self, cb)
	self.m_ClickCallback = cb
end



-- modelInfo: {rotate(旋转)， pos(模型的局部坐标）, rendertexSize(渲染的大小)  Shenqi(是否神器) ignoreClick(忽略点击) }
function CActorTexture.ChangeShape(self, modelInfo, cb)
	self.m_ModelInfo = modelInfo
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

	self:SetActive(false)
	self.m_ActorCamera:ChangeShape(modelInfo,  callback(self, "OnChangeDone", cb))
	local oActor = self.m_ActorCamera:GetActor()
	if oActor then
		oActor:SetLocalRotation(Quaternion.Euler(15, 0, 0))
		oActor:Rotate(modelInfo.rotate or Vector3.New(0, -30, 0))

		if modelInfo.actorpos then
			oActor:SetLocalPos(modelInfo.actorpos)
		end
	end
end

function CActorTexture.OnChangeDone(self, cb)
	-- 动作变更(策划需求变更为用场景控制器)
	--[==[
	local boxCollider = self:GetComponent(classtype.BoxCollider)
	if boxCollider then
		local oActor = self.m_ActorCamera:GetActor()
		if oActor.m_LoadDoneModelList["main"] and not oActor.m_LoadDoneModelList["ride"] then
			oActor.m_LoadDoneModelList["main"]:ReloadAnimator(oActor.m_Shape, 2)
		end
	end
	]==]
	
	self:SetActive(true)

	self.m_ActorCamera:ShowAllParticle(define.Performance.Level.high)

	if cb then 
		cb()
	end 

end


function CActorTexture.Ranse(self, ranseInfo, cb)
	if self.m_ActorCamera then 
		self.m_ActorCamera:Ranse(ranseInfo, cb)
	end 
end


function CActorTexture.Clear(self)
	if self.m_UIWidget.mainTexture then
		UnityEngine.RenderTexture.ReleaseTemporary(self.m_UIWidget.mainTexture)
		self:SetMainTexture(nil)
	end
	if self.m_ActorCamera then
		g_CameraCtrl:Recycle(self.m_ActorCamera)
		self.m_ActorCamera = nil
	end
end

function CActorTexture.GetMainTexture(self, aspect)
	if not self.m_UIWidget.mainTexture then
		local factor = UITools.GetPixelSizeAdjustment()
		local w, h = self:GetSize()
		if aspect then
			local iTextureAspect = (w/h)
			if iTextureAspect ~= aspect then
				if iTextureAspect < aspect then
					w = h * aspect
				elseif iTextureAspect > aspect then
					h = w / aspect
				end
				self:SetSize(w, h)
			end
		end

		local oRenderTexture =  UnityEngine.RenderTexture.GetTemporary(w, h, 24)
		oRenderTexture.antiAliasing = 2
		self:SetMainTexture(oRenderTexture)
	end
	return self.m_UIWidget.mainTexture
end

-- function CActorTexture.CheckReallyShow(self)
-- 	local bShow = self:GetActive(true)
-- 	if bShow then
-- 		if not self.m_ConstrainPanel then
-- 			local panel = NGUI.UIPanel.Find(self.m_Transform)
-- 			if panel then
-- 				self.m_ConstrainPanel = CPanel.New(panel.gameObject)
-- 			end
-- 		end
-- 		if self.m_ConstrainPanel then
-- 			bShow = not self.m_ConstrainPanel:IsFullOut(self)
-- 		end
-- 	end
-- 	if self.m_ActorCamera then
-- 		if self.m_LastShow ~= bShow then
-- 			self.m_LastShow = bShow
-- 			self.m_ActorCamera:SetActive(bShow)
-- 		end
-- 	end
-- 	return true
-- end


function CActorTexture.SetRotate(self, rotate)
	local oActor = self.m_ActorCamera and self.m_ActorCamera:GetModel()
	if not oActor then
		return
	end
	local t = oActor:GetLocalRotation()
	oActor:SetLocalRotation(Quaternion.Euler(0, rotate, 0)) 
end

function CActorTexture.OnPlay(self, sAniName, loop)
	local oActor = self.m_ActorCamera and self.m_ActorCamera:GetModel()
	if not oActor then
		return
	end
	sAniName = sAniName or "idleCity"
	if loop == nil then
		loop = true
	end
	oActor:CrossFadeLoop(sAniName, 0.1, 0, 1, loop)
end

function CActorTexture.StopPlay(self)
	local oActor = self.m_ActorCamera and self.m_ActorCamera:GetModel()
	if not oActor then
		return
	end	
	oActor:StopCrossFadeLoop()
end

function CActorTexture.CrossFade(self, sState, duration, startNormalized, endNormalized, func)
	
	local oActorCam = self.m_ActorCamera 
	if not oActorCam then
		return
	end	
	oActorCam:CrossFade(sState, duration, startNormalized, endNormalized, func)

end

function CActorTexture.GetCamera(self)
	return self.m_ActorCamera
end

return CActorTexture
