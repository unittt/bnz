local CRoleCreatePlayer = class("CRoleCreatePlayer", CObject, CBindObjBase)

function CRoleCreatePlayer.ctor(self, oRoleconfigid)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/Warrior.prefab")
	CObject.ctor(self, obj)
	self:SetActive(false)
	self:SetLayer(UnityEngine.LayerMask.NameToLayer("RoleCreate"), true)
	CBindObjBase.ctor(self, obj)
	self.m_RotateObj = CObject.New(self:Find("rotate_node").gameObject)
	
	self.m_Roleconfigid = oRoleconfigid
	self.m_ModelInfo = nil
	self.m_IsCanTouch = true
	self.m_WeaponIdxHashList = {1, 1, 7, 7, 8, 9}
	self.m_WeaponAnimHashList = {1, 1, nil, nil, 2, 9}
	self.m_WeaponModel = nil

	self:SetLocalScale(Vector3.one)
	self.m_Actor = CActor.New()
	self.m_Actor:SetParent(self.m_RotateObj.m_Transform, false)
	self.m_Actor:SetLayer(self:GetLayer(), true)
	if table.index({4, 6}, self.m_Roleconfigid) then
		self.m_Actor:SetLocalPos(Vector3.zero)
	else
		self.m_Actor:SetLocalPos(Vector3.New(0, 0.05, 0))
	end
	self.m_Actor:SetDefaultState("rolecreate1")
	self.m_ModelDone = false    --模型是否已经创建完毕
	local tConfigObjs = {
		size_obj = self,
		collider = self:GetComponent(classtype.CapsuleCollider),
		head_trans = self.m_HeadTrans,
		waist_trans = self.m_WaistTrans,
		foot_trans = self.m_FootOrgTrans,
	}
	self.m_Actor:SetConfigObjs(tConfigObjs)

	-----------------------审核特殊处理----------------------------
	if g_LoginPhoneCtrl:IsShenhePack() then
		self:SetLayer(UnityEngine.LayerMask.NameToLayer("UI"), true)
		self.m_Actor:Rotate(Vector3.New(0, 180, 0))
		self.m_Actor:SetLocalPos(Vector3.New(0, -0.6, 0))
	end
end

function CRoleCreatePlayer.SetBodyMatColor(self, color)
	self.m_Actor:SetBodyMatColor(color)
	if color.a == 0 then
		Utils.HideObject(self)
	else
		Utils.ShowObject(self)
	end
end

function CRoleCreatePlayer.SetWeaponMatColor(self, color)
	self.m_Actor:SetWeaponMatColor(color)
end

function CRoleCreatePlayer.GetMatColor(self)
	return self.m_Actor.m_BodyMatColor
end

function CRoleCreatePlayer.ShowReplaceActor(self)
	local function black()
		if Utils.IsNil(self) then
			return
		end
		self:SetLayer(self.m_GameObject.layer, true)
		self:CrossFade(self:GetState())
		self:SetBodyMatColor(Color.black*0.9)
	end
	self.m_Actor:ChangeShape({shape=1110})
end

function CRoleCreatePlayer.SetTouchEnabled(self, b)
	self.m_IsCanTouch = b
end

function CRoleCreatePlayer.GetTouchEnabled(self)
	return self.m_IsCanTouch
end

function CRoleCreatePlayer.GetModelBindTrans(self, idx)
	local oModel = self.m_Actor:GetMainModel()
	if oModel then
		return oModel:GetContainTransform(idx)
	end
end

function CRoleCreatePlayer.Destroy(self)
	if not Utils.IsNil(self) then
		self:SetActive(false)
	end
	self.m_OnEndCb = nil
	if self.m_RoleCreateEffect then
		self.m_RoleCreateEffect:Destroy()
		self.m_RoleCreateEffect = nil
	end
	g_RoleCreateScene.m_CurRoleCreatePlayer = nil
	self:StopAnimTimer()
	self:ClearBindObjs()
	if self.m_WeaponModel then
		CObject.Destroy(self.m_WeaponModel)
		self.m_WeaponModel = nil
	end
	self.m_Actor:Destroy()	
	CObject.Destroy(self)
end

function CRoleCreatePlayer.GetState(self)
	return self.m_Actor:GetState()
end

function CRoleCreatePlayer.GetShape(self)
	return self.m_Actor:GetShape()
end

function CRoleCreatePlayer.GetBasicShape(self)
	return self.m_Actor:GetOriShape()
end

function CRoleCreatePlayer.ChangeShape(self, tDesc, onEndCb)
	-- printc("############### 单位修正", g_TimeCtrl:GetTimeMS(), g_TimeCtrl:GetTimeS())
	self:SetActive(false)
	self.m_ModelDone = false
	local dInfo = table.copy(tDesc)
	dInfo.horse = nil

	local iShape = dInfo.shape
	if not iShape then
		local dModelData = data.modeldata.CONFIG[dInfo.figure]
		iShape = dModelData and dModelData.model
	end
	if iShape and self.m_Actor:IsExistShape(iShape) then
	else
		--容错处理，如无模型以蜀山1110形象代替
		-- if not Utils.IsEditor() then
			dInfo = {shape = 1110}
		-- end
	end	
	self.m_ModelInfo = dInfo
	self.m_Actor:ChangeShape(dInfo, callback(self, "OnChangeDone", onEndCb, dInfo))
end

function CRoleCreatePlayer.OnChangeDone(self, onEndCb, dInfo)
	self.m_ModelDone = true
	-- self:SetLayer(self.m_GameObject.layer, true)
	self:CrossFade(self:GetState())
	self.m_OnEndCb = onEndCb
	local sType = tostring(dInfo.shape).."_".. tostring(self.m_WeaponIdxHashList[self.m_Roleconfigid])
	local oPath = string.format("Model/Weapon/%s/Prefabs/weapon%s.prefab", sType, sType)
	g_ResCtrl:LoadCloneAsync(oPath, callback(self, "LoadWeaponDoneModel", dInfo), nil, true, nil)

	local oModel = self.m_Actor:GetMainModel()
	if oModel then
		return oModel:ReloadAnimator(dInfo.shape, 3, callback(self, "OnAnimatorLoadDone"))
	end
end

--加载武器模型
function CRoleCreatePlayer.LoadWeaponDoneModel(self, dInfo, oClone, sPath)
	if oClone then
		local WeaponModel = CWeaponModel.New(oClone)
		local mainModel = self.m_Actor.m_LoadDoneModelList["main"]
		mainModel:EquipWeapon(WeaponModel)
		WeaponModel.m_RoleInfo = dInfo
		WeaponModel.m_Shape = dInfo.shape
		WeaponModel:SetLayer(UnityEngine.LayerMask.NameToLayer("RoleCreate"), true)
		self.m_WeaponModel = WeaponModel
		--这个是有武器动画控制器走这个逻辑
		local oIdsStr = self.m_WeaponAnimHashList[self.m_Roleconfigid]
		if oIdsStr then
			local path =  string.format("Model/Weapon/%d_%s/RoleCreate/RolrCreate%d_%s.overrideController", dInfo.shape, tostring(oIdsStr), dInfo.shape, tostring(oIdsStr))
			g_ResCtrl:LoadAsync(path, callback(self, "OnWeaponAnimatorLoadDone"))
		end
	end
end

--加载人物动画控制器
function CRoleCreatePlayer.OnAnimatorLoadDone(self, asset, path)
	-- if asset then		
	-- 	self.m_Actor.m_LoadDoneModelList["main"].m_Animator.runtimeAnimatorController = asset
	-- 	self.m_Actor.m_LoadDoneModelList["main"].m_Animator.cullingMode = 0		
	-- end
	--这个是没有武器动画控制器走这个逻辑
	local oIdsStr = self.m_WeaponAnimHashList[self.m_Roleconfigid]
	if not oIdsStr then
		if self.m_OnEndCb then
			self.m_OnEndCb()
		end

		if self.m_RoleCreateEffect then
			self.m_RoleCreateEffect:Destroy()
			self.m_RoleCreateEffect = nil
		end
		g_EffectCtrl:SetRootActive(true)
		local path = "Effect/Character/"..data.roletypedata.DATA[self.m_Roleconfigid].shape.."_rolecreate1_effect/Prefabs/"..data.roletypedata.DATA[self.m_Roleconfigid].shape.."_rolecreate1_effect.prefab"
		local oEffect = CEffect.New(path, UnityEngine.LayerMask.NameToLayer("RoleCreate"), true)
		self.m_RoleCreateEffect = oEffect

		local function f()
			self.m_Actor:CrossFade("rolecreate2", 0.2)
			self:PlayerAnimator()
			g_RoleCreateScene.m_CurRoleCreatePlayer = self
		end
		self.m_Actor:CrossFade("rolecreate1", 0.2, 0, 1, f)
		self:SetLayer(self.m_GameObject.layer, true)
		self:SetActive(true)
	end
end

--加载武器动画控制器
function CRoleCreatePlayer.OnWeaponAnimatorLoadDone(self, asset, path)
	if asset then
		if self.m_OnEndCb then
			self.m_OnEndCb()
		end

		if self.m_RoleCreateEffect then
			self.m_RoleCreateEffect:Destroy()
			self.m_RoleCreateEffect = nil
		end
		g_EffectCtrl:SetRootActive(true)
		local path = "Effect/Character/"..data.roletypedata.DATA[self.m_Roleconfigid].shape.."_rolecreate1_effect/Prefabs/"..data.roletypedata.DATA[self.m_Roleconfigid].shape.."_rolecreate1_effect.prefab"
		local oEffect = CEffect.New(path, UnityEngine.LayerMask.NameToLayer("RoleCreate"), true)
		self.m_RoleCreateEffect = oEffect

		local function f()
			self.m_Actor:CrossFade("rolecreate2", 0.2)
			self:PlayerAnimator()
			g_RoleCreateScene.m_CurRoleCreatePlayer = self
		end
		self.m_Actor:CrossFade("rolecreate1", 0.2, 0, 1, f)
		self:SetLayer(self.m_GameObject.layer, true)
		self:SetActive(true)

		self.m_WeaponModel.m_Animator.runtimeAnimatorController = asset
		self.m_WeaponModel.m_Animator.cullingMode = 0
		local function f()
			self.m_WeaponModel:CrossFade("rolecreate2", 0.2)
		end
		self.m_WeaponModel:CrossFade("rolecreate1", 0.2, 0, 1, f)
	end
end

function CRoleCreatePlayer.Play(self, state, normalizedTime)
	self.m_Actor:Play(state, normalizedTime)
end

function CRoleCreatePlayer.CrossFade(self, state, duration, normalizedTime)
	self.m_Actor:CrossFade(state, duration, normalizedTime)
end

function CRoleCreatePlayer.PlayInFixedTime(self, state, fixedTime)
	self.m_Actor:PlayInFixedTime(state,fixedTime)
end

function CRoleCreatePlayer.CrossFadeInFixedTime(self, state, duration, fixedTime)
	self.m_Actor:CrossFadeInFixedTime(state, duration, fixedTime)
end

function CRoleCreatePlayer.OnTrigger(self)
	if self.m_RoleCreateEffect then
		self.m_RoleCreateEffect:Destroy()
		self.m_RoleCreateEffect = nil
	end
	g_EffectCtrl:SetRootActive(true)
	local path = "Effect/Character/"..data.roletypedata.DATA[self.m_Roleconfigid].shape.."_rolecreate3_effect/Prefabs/"..data.roletypedata.DATA[self.m_Roleconfigid].shape.."_rolecreate3_effect.prefab"
	local oEffect = CEffect.New(path, UnityEngine.LayerMask.NameToLayer("RoleCreate"), true)
	self.m_RoleCreateEffect = oEffect

	local function f()
		self.m_Actor:CrossFade("rolecreate2", 0.2)
	end
	self.m_Actor:CrossFade("rolecreate3", 0.2, 0, 1, f)

	if self.m_WeaponModel then
		local function f2()
			self.m_WeaponModel:CrossFade("rolecreate2", 0.2)
		end
		self.m_WeaponModel:CrossFade("rolecreate3", 0.2, 0, 1, f2)
	end
end


function CRoleCreatePlayer.PlayerAnimator(self)
	self:StopAnimTimer()
	local function delay()
		self:OnTrigger()
		return true
	end
	local iTime = ModelTools.GetAnimClipInfo(self.m_Actor.m_Shape, "rolecreate3", nil).length + 3
	-- local iTime = 2.333 + 3
	self.m_AnimTimer = Utils.AddTimer(delay, iTime, 3)
end

function CRoleCreatePlayer.StopAnimTimer(self)
	if self.m_AnimTimer then
		Utils.DelTimer(self.m_AnimTimer)
		self.m_AnimTimer = nil
	end
end

return CRoleCreatePlayer