local CModel = class("CModel", CObject, CGameObjContainer)

function CModel.ctor(self, obj)
	CObject.ctor(self, obj)
	CGameObjContainer.ctor(self, obj)
	self.m_Animator = self:GetComponent(classtype.Animator)
	if not self.m_Animator.runtimeAnimatorController then
		error("没有设置动作Animator"..self:GetName())
		return
	end
	self.m_MainMeshRenderer = nil
	self.m_AnimEffectInfos = {}
	self.m_CurEffectAnim = nil
	self.m_AnimEffects = {}
	self.m_WeaponAnimator = nil
	self.m_MountTrans = {
		["left_hand"] = self:GetContainTransform(1),
		["right_hand"] = self:GetContainTransform(2),
		["rider"] = self:GetContainTransform(11),
	}
	self.m_Shape = nil
	self.m_m_ModelMountType = nil
	self.m_Layer = 0
	self.m_AnimStateMap = nil --动作映射
	
	self.m_Info = {}
	self.m_MountObjs = {}
	self.m_Type2IDs = {}
	self.m_BodyMatColor = nil
	self.m_Materials = {}
	self.m_BodyMaterials = {}
	self.m_MountMaterials = {}
	self.m_State = ""
	self.m_MatInfo = {}
	self.m_MaterialAddFunc = nil
	local list = string.split(self.m_Animator.runtimeAnimatorController.name, "_") 
	self.m_AnimatorIdx = next(list) and tonumber(list[2]) or 1
	-- self:UpdateMaterials()
	self:InitAnimEffectInfo()
	self.m_OldBodyMatTexture = {}
	self.m_OldMountMatTexture = {}
end

function CModel.InitMeshRenderer(self)
	if not self.m_MainMeshRenderer then
		self.m_MainMeshRenderer = self.m_GameObject:GetComponentInChildren(classtype.SkinnedMeshRenderer, true)
	end
end

function CModel.InitAnimEffectInfo(self)
	local comps = self:GetComponents(classtype.AnimEffect)
	local data = {}
	if comps then
		for i=0, comps.Length-1 do
			local comp = comps[i]
			local effectList = {}
			for j=0, comp.EffectLength-1 do
				local info = comp.effectArray[j]
				if info.gameObject and info.path then 
					table.insert(effectList, {transform=info.gameObject.transform,path=info.path})
				end
			end

			local soundList = {}
			for j=0,comp.SoundLength-1 do
				local info = comp.soundArray[j]
				if info.path then
					table.insert(soundList, {path = info.path})
				end
			end

			data[comp.animName].effectList = effectList
			data[comp.animName].soundList = soundList
		end
	end
	self.m_AnimEffectInfos = data
end



function CModel.GetEffectMountType(self, sState)
	return sState.."_effects"
end

function CModel.CheckAnimEffect(self, sState)
	if self.m_CurEffectAnim == sState then
		return
	end
	local sType = self:GetEffectMountType(sState)
	if self.m_CurEffectAnim then
		self:DelObjType(self:GetEffectMountType(self.m_CurEffectAnim))
	end
	local list = self.m_AnimEffectInfos[sState]
	if list and #list > 0 then
		self.m_CurEffectAnim = sState
		for i, info in ipairs(list) do
			g_ResCtrl:LoadCloneAsync(info.path, callback(self, "OnEffectLoadDone", sState, sType, info.transform))
		end
	else
		self.m_CurEffectAnim = nil
	end
end

function CModel.OnEffectLoadDone(self, sState, sType, transform, oClone, sPath)
	if self.m_CurEffectAnim ~= sState then
		g_ResCtrl:PutCloneInCache(sPath, oClone)
		return
	end
	local obj = CObject.New(oClone)
	obj:SetActive(false)
	obj:SetActive(true)
	obj:SetCacheKey(sPath)
	self:MountObj(obj, transform, sType)
end

function CModel.SetMaterialAddFunc(self, func)
	-- printerror("== CModel.SetMaterialAddFunc ==", func)
	self.m_MaterialAddFunc = func
end

function CModel.SetBodyMatColor(self, color)
	-- printerror("=== CModel.SetBodyMatColor", self:GetName(), color)
	self.m_BodyMatColor = color
	self:DelayCall(0, "UpdateBodyMaterials")
end

function CModel.LoadMaterial(self, sPath, dInfo)
	dInfo = dInfo or {}
	local oOldInfo = self.m_MatInfo[sPath]
	if oOldInfo then
		if oOldInfo.loading then -- 正在加载
			-- printc("--正在加载", sPath)
			dInfo.loading = true
			self.m_MatInfo[sPath] = dInfo
			return
		else
			if oOldInfo.mat then -- 已经加载
				-- printc("--已经加载", sPath)
				DOTween.DOKill(oOldInfo.mat, false)
				if oOldInfo.timer then
					-- printc("--已经加载, 删除原来Timer")
					Utils.DelTimer(oOldInfo.timer)
				end
				if dInfo.show_time and dInfo.show_time > 0 then
					-- printc("--重新渐变Alpha", sPath)
					oOldInfo.mat:SetFloat("_Alpha", 0)
					local tweener = DOTween.DOFloat(oOldInfo.mat, 1, "_Alpha", dInfo.show_time)
					DOTween.SetEase(tweener, enum.DOTween.Ease.Linear)
				else
					-- printc("--重新设置Alpha", sPath)
					oOldInfo.mat:SetFloat("_Alpha", 1)
				end
				if dInfo.alive_time then
					dInfo.timer = Utils.AddTimer(callback(self, "DelMaterial", sPath), 0, dInfo.alive_time)
				end
				self.m_MatInfo[sPath] = dInfo
				return
			end
		end
	end
	--没有load过的
	-- printc("--没有load过的", sPath)
	dInfo.loading = true
	self.m_MatInfo[sPath] = dInfo
	g_ResCtrl:LoadAsync(sPath, callback(self, "OnMatLoadDone"))
end

function CModel.OnMatLoadDone(self, oMat, sPath)
	local dInfo = self.m_MatInfo[sPath]
	if oMat and dInfo and dInfo.loading then
		if dInfo.show_time and dInfo.show_time > 0 then
			oMat:SetFloat("_Alpha", 0)
			local tweener = DOTween.DOFloat(oMat, 1, "_Alpha", dInfo.show_time)
			DOTween.SetEase(tweener, enum.DOTween.Ease.Linear)
		end
		if dInfo.alive_time then
			self.m_MatInfo[sPath].timer = Utils.AddTimer(callback(self, "DelMaterial", sPath), 0, dInfo.alive_time)
		end
		dInfo.loading = false
		dInfo.mat = oMat
		self.m_MatInfo[sPath] = dInfo
		self:AddMaterial(oMat)
	end
end

function CModel.AddMaterial(self, oMat)
	self:InitMeshRenderer()
	local arr = self.m_MainMeshRenderer.materials
	local newArr = System.Array.CreateInstance(classtype.Material, arr.Length+1)
	System.Array.Copy(arr, 0, newArr, 0, arr.Length)
	newArr[arr.Length] = oMat
	self.m_MainMeshRenderer.materials = newArr
end

function CModel.DelMaterial(self, sPath)
	--printc("DelMaterial")
	local dInfo = self.m_MatInfo[sPath]
	if not dInfo or dInfo.loading then --还在加载之中
		self.m_MatInfo[sPath] = nil
		return
	end
	self:InitMeshRenderer()
	dInfo.timer = nil
	local sMatName = IOTools.GetFileName(sPath, true)
	local arr = self.m_MainMeshRenderer.materials
	local list = {}
	local lDel = {}
	for i=0, arr.Length-1 do
		local oMat = arr[i]
		if string.find(oMat.name, sMatName) == nil then
			table.insert(list, oMat)
		else
			table.insert(lDel, oMat)
		end
	end
	if #list == arr.Length then
		self.m_MatInfo[sPath] = nil
		return
	end
	local newArr = System.Array.CreateInstance(classtype.Material, #list)
	for i = 1, #list do
		newArr[i-1] = list[i]
	end
	local function realdel()
		if Utils.IsNil(self) then
			return
		end
		self.m_MainMeshRenderer.materials = newArr
		self.m_MatInfo[sPath] = nil
	end
	if dInfo.hide_time and dInfo.hide_time > 0 then
		for i, oMat in ipairs(lDel) do
			oMat:SetFloat("_Alpha", 1)
			local tweener = DOTween.DOFloat(oMat, 0, "_Alpha", dInfo.hide_time)
			DOTween.SetEase(tweener, enum.DOTween.Ease.Linear)
			if i==1 then
				DOTween.OnComplete(tweener, realdel)
			end
		end
		self.m_MatInfo[sPath] = dInfo
	else
		realdel()
	end
end

function CModel.SetMountMatColor(self, color)
	-- printerror("=== CModel.SetMountMatColor")
	self.m_MountMatColor = color
	self:UpdateMountMaterials()
end

function CModel.SetBodyMatTexture(self, texture)
	self.m_BodyMatTexture = texture
	self:UpdateBodyMaterials()
end

function CModel.SetMountMatTexture(self, texture)
	self.m_MountMatTexture = texture
	self:UpdateMountMaterials()
end

function CModel.UpdateBodyMaterials(self)
	if not self.m_BodyMaterials[self:GetInstanceID()] then
		local list = Utils.GetMaterials({self.m_GameObject})
		self.m_BodyMaterials[self:GetInstanceID()] = list
		-- printerror("============== CModel.UpdateBodyMaterials 111", self.m_MaterialAddFunc)
		if self.m_MaterialAddFunc then
			for k,v in pairs(list) do
				self.m_MaterialAddFunc(v)
			end
		end
	end
	if not self.m_BodyMatColor then
		return
	end
	for i, list in pairs(self.m_BodyMaterials) do
		for j, material in ipairs(list) do
			if self.m_BodyMatTexture then
				if self.m_OldBodyMatTexture[i] == nil then	
					self.m_OldBodyMatTexture[i] = {}
					self.m_OldBodyMatTexture[i][j] = material.mainTexture
				end
				material.mainTexture = self.m_BodyMatTexture			
			end
			if self.m_BodyMatColor then
				self:SetActive(self.m_BodyMatColor.a ~= 0)
				-- if self.m_BodyMatColor.a == 0 then
				-- 	Utils.HideObject(self)
				-- 	return
				-- else
				-- 	Utils.ShowObject(self)
				-- end
				-- printc("================== 设置身体颜色", self.m_BodyMatColor)
				material:SetColor("_ColorAlpha", self.m_BodyMatColor)
			end
		end
	end
end

function CModel.UpdateMountMaterials(self)
	for id, obj in pairs(self.m_MountObjs) do
		if not self.m_MountMaterials[id] then
		local list = Utils.GetMaterials({obj.m_GameObject})
			self.m_MountMaterials[id] = list
			-- printerror("============== CModel.UpdateMountMaterials 222", self.m_MaterialAddFunc)
			if self.m_MaterialAddFunc then
				for k,v in pairs(list) do
					self.m_MaterialAddFunc(v)
				end
			end
		end
	end
	for i, list in pairs(self.m_MountMaterials) do
		for j, material in ipairs(list) do
			if self.m_MountMatTexture then
				if self.m_OldMountMatTexture[i] == nil then	
					self.m_OldMountMatTexture[i] = {}
					self.m_OldMountMatTexture[i][j] = material.mainTexture
				end			
				material.mainTexture = self.m_MountMatTexture		
			end
			if self.m_MountMatColor then
				-- printc("================== 设置挂点颜色", self.m_MountMatColor)
				material:SetColor("_ColorAlpha", self.m_MountMatColor)
			end
		end
	end
end

function CModel.UpdateMaterials(self)
	self:UpdateBodyMaterials()
	self:UpdateMountMaterials()
end

function CModel.UpdateShaderInfo(self, shader, rgb)
	for i, list in pairs(self.m_BodyMaterials) do
		for j, material in ipairs(list) do
			material.shader = shader
			material:SetFloat("_blendFactorR", rgb.r)
			material:SetFloat("_blendFactorG", rgb.g)
			material:SetFloat("_blendFactorB", rgb.b)
		end
	end
end

function CModel.SetModelMountType(self, sType)
	self.m_ModelMountType = sType
end

function CModel.GetModelMountTrans(self)
	if self.m_MountTrans then
		return self.m_MountTrans[self.m_ModelMountType]
	end
end

function CModel.Resize(self)
	local figure = self.m_Info and self.m_Info.figure or self.m_Shape
	if figure then
		local dConfig = ModelTools.GetModelConfig(figure)
		local scale = dConfig.scale * 0.001
		self:SetLocalScale(Vector3.New(scale, scale, scale))
	end
end

function CModel.SetInfo(self, dInfo)
	self.m_Info = dInfo or {}
	self:RefreshInfo()
	self:Resize()
end

function CModel.RefreshInfo(self)
	if self.m_Info.weapon then
		self:MountWeapon(self.m_Shape, self.m_Info.weapon)
	else
		self:DelObjType("weapon")
	end
end

function CModel.MountWeapon(self, iShape, iWeapon)
	local dInfo = define.Model.WEAPON[iShape]
	self:DelObjType("weapon")
	if dInfo then
		local sType = tostring(iShape).."_"..iWeapon
		local path = string.format("Model/Weapon/%s/Prefabs/weapon%s.prefab", sType, sType)
		g_ResCtrl:LoadCloneAsync(path, callback(self, "OnMountObjDone", dInfo.mounts, "weapon"))
	end

	-- self:DelObjType("weapon")
	-- self:ReloadAnimator(iShape, iWeapon)
	-- local mounts = ModelTools.GetMountList(iShape, iWeapon)
	-- if mounts then
	-- 	local path = string.format("Model/Weapon/%d/Prefabs/weapon%d.prefab",iWeapon, iWeapon)
	-- 	g_ResCtrl:LoadCloneAsync(path, callback(self, "OnMountObjDone", mounts, "weapon"), true)
	-- end
end

function CModel.ReloadAnimator(self, iShape, iWeapon)
	local idx = ModelTools.GetAnimatorIdx(iShape, iWeapon)
	if self.m_AnimatorIdx ~= idx then
		local sIdx = idx == 1 and "" or "_"..tostring(idx)
		local path =  string.format("Model/Character/%d/Anim/Animator%d%s.overrideController", iShape, iShape, sIdx)
		g_ResCtrl:LoadAsync(path, callback(self, "OnAnimatorLoadDone"))
		self.m_AnimatorIdx = idx
	end
end

function CModel.OnAnimatorLoadDone(self, asset, path)
	if asset then
		self.m_Animator.runtimeAnimatorController = asset
	end
end

function CModel.OnMountObjDone(self, lMounts, sMountType, oClone, sPath)
	if oClone then
		for i, sMountIdx in pairs(lMounts) do
			local obj = CObject.New(oClone)
			obj:SetCacheKey(sPath)
			local mounTrans = self.m_MountTrans[sMountIdx]
			self:MountObj(obj, mounTrans, sMountType)
			self.m_WeaponAnimator = obj:GetComponent(classtype.Animator)
		end
		self:SetLayer(self:GetLayer(), true)
	end
end

function CModel.SetModelShape(self, iShape)
	self.m_Shape = iShape
end

function CModel.GetModelShape(self)
	return self.m_Shape
end

function CModel.Destroy(self)
	for k, v in pairs(self.m_MountObjs) do
		v:Destroy()
	end
	CObject.Destroy(self)
end

function CModel.Recycle(self)
	CObject.Recycle(self)
	if self.m_MainMeshRenderer then
		local arr = self.m_MainMeshRenderer.materials
		if arr.Length > 1 then
			local newArr = System.Array.CreateInstance(classtype.Material, 1)
			newArr[0] = arr[0]
			self.m_MainMeshRenderer.materials = newArr
		end
	end
	self.m_MatInfo = {}
	self:SetBodyMatColor(Color.white)
	self:SetLocalScale(Vector3.one)
	for _, v in pairs(self.m_MountObjs) do
		v:Recycle()
			-- v.m_Animator.enabled = false
		g_ResCtrl:PutCloneInCache(v:GetCacheKey(), v.m_GameObject)
	end
	self.m_MountObjs = {}
		-- self.m_Animator.enabled = false

	g_ResCtrl:PutCloneInCache(self:GetCacheKey(), self.m_GameObject)
end

function CModel.SetMatTexture(self)
	for i, list in pairs(self.m_BodyMaterials) do
		for j, material in ipairs(list) do
			if self.m_OldBodyMatTexture[i] ~= nil and self.m_OldBodyMatTexture[i][j] ~= nil then
				material.mainTexture = self.m_OldBodyMatTexture[i][j]
			end
		end
	end
	for i, list in pairs(self.m_MountMaterials) do
		for j, material in ipairs(list) do
			if self.m_OldMountMatTexture[i] ~= nil and self.m_OldMountMatTexture[i][j] ~= nil then
				material.mainTexture = self.m_OldMountMatTexture[i][j]
			end
		end
	end
end

function CModel.GetState(self)
	local sState = self.m_Model:GetState(self.m_Layer)
	if sState then
		return ModelTools.HashToState(sState)
	end
end

function CModel.MountObj(self, obj, trans, sType)
	if trans then
		obj:SetParent(trans, false)
		obj:SetLocalPos(Vector3.zero)
	end
	local id = obj:GetInstanceID()
	self.m_MountObjs[id] = obj
	local list = self.m_Type2IDs[sType] or {}
	table.insert(list, id)
	self.m_Type2IDs[sType] = list
	self:DelayCall(0, "SetLayer", self:GetLayer(), true)
	self:UpdateMaterials()
end

function CModel.DelObjType(self, sType)
	local list = self.m_Type2IDs[sType]
	if list then
		for i, id in pairs(list) do
			local obj = self.m_MountObjs[id]
			if obj then
				-- obj.m_Animator.enabled = false
				g_ResCtrl:PutCloneInCache(obj:GetCacheKey(), obj.m_GameObject)
				self.m_MountObjs[id] = nil
			end
		end
		self.m_Type2IDs[sType] = nil
	end
end

function CModel.SetSpeed(self, iSpeed)
	self.m_Animator.speed = iSpeed
	if self.m_WeaponAnimator then
		self.m_WeaponAnimator.speed = iSpeed
	end
end

function CModel.Play(self, sState, normalizedTime)
	self:SetState(sState)
	normalizedTime = normalizedTime or 0
	local iHash = ModelTools.StateToHash(sState)
	self.m_Animator:Play(iHash, self.m_Layer, normalizedTime)
	if self.m_WeaponAnimator then
		self.m_WeaponAnimator:Play(iHash, self.m_Layer, normalizedTime)
	end
end

function CModel.PlayInFixedTime(self, sState, fixedTime)
	self:SetState(sState)
	local iHash = ModelTools.StateToHash(sState)
	fixedTime = fixedTime or 0
	self.m_Animator:PlayInFixedTime(iHash, self.m_Layer, fixedTime)
	if self.m_WeaponAnimator then
		self.m_WeaponAnimator:PlayInFixedTime(iHash, self.m_Layer, fixedTime)
	end
end

function CModel.CrossFade(self, sState, iDuration, normalizedTime)
	-- 到这里了
	-- printerror("======= CModel.CrossFade", sState)
	self:SetState(sState)
	iDuration = iDuration or 0
	normalizedTime = normalizedTime or 0
	local iHash = ModelTools.StateToHash(sState)
	self.m_Animator:CrossFade(iHash, iDuration, self.m_Layer, normalizedTime)
	if self.m_WeaponAnimator then
		self.m_WeaponAnimator:CrossFade(iHash, iDuration, self.m_Layer, normalizedTime)
	end
end

function CModel.CrossFadeInFixedTime(self, sState, iDuration, fixedTime)
	self:SetState(sState)
	local iHash = ModelTools.StateToHash(sState)
	iDuration = iDuration or 0
	fixedTime = fixedTime or 0
	self.m_Animator:CrossFadeInFixedTime(iHash, iDuration, self.m_Layer, fixedTime)
	if self.m_WeaponAnimator then
		self.m_WeaponAnimator:CrossFadeInFixedTime(iHash, iDuration, self.m_Layer, fixedTime)
	end
end

function CModel.SetState(self, sState)
	self.m_State = sState
	self:CheckAnimEffect(sState)
end

function CModel.SetParent(self, parent, bWorldPositionStays)
	CObject.SetParent(self, parent, bWorldPositionStays)
	self:Resize()
end

return CModel