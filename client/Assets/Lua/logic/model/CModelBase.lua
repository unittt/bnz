local CModelBase = class("CModelBase", CObject)

--模型基类，负责模型的动画，材质，颜色
function CModelBase.ctor(self, obj)

	CObject.ctor(self, obj)

	--模型的Id
	self.m_Shape = nil

	--模型动画组件
	self.m_Animator = self:GetComponent(classtype.Animator)
	--模型的skinmeshrender
	self.m_SkinnedMeshRenderer = nil

	self.m_Layer = 0

	--运动状态
	self.m_AnimatorState = nil

	--模型颜色
	self.m_ModelColor = nil

	--新材质
	self.m_NewMat = nil

	--染色材质
	self.m_RanseMat = nil

	--默认材质
	self.m_DefaultMat = nil

	--是否染色
	self.m_isRanse = false

	self.m_MatList = {}

	self.m_AnimEffectInfos = {}
	self.m_CurEffectAnim = nil
	self.m_AnimEffects = {}

	self:InitAnimEffectInfo()

	self.m_IsModelLoadone = false

	-- 模型动作
	if not self.m_Animator or not self.m_Animator.runtimeAnimatorController then
		-- printerror("没有设置动作Animator：" .. self:GetName())
		return
	end

	local animName = self.m_Animator.runtimeAnimatorController.name
	local list = string.split(animName, "_")
	self.m_AnimatorIdx = next(list) and tonumber(list[2]) or 1
	if string.find(animName, "RolrCreate") then
		self.m_AnimatorIdx = 3
	end
end

function CModelBase.SetAnimatorCullModel(self, cullModel)
	
	cullModel = cullModel or 0
	if  self.m_Animator then 
		self.m_Animator.cullingMode = cullModel
	end 

end

function CModelBase.SetInfo(self, modelInfo)
	
	self.m_ModelInfo = modelInfo
	self.m_Shape = modelInfo.shape

end

function CModelBase.GetModelInfo(self)
	return self.m_ModelInfo
end


function CModelBase.GetShape(self)
	return self.m_ModelInfo.shape
end

function CModelBase.GetRanseInfo(self)
	
	if self.m_ModelInfo then 

		return self.m_ModelInfo.ranseList

	end 

end

function CModelBase.GetRanseExInfo(self)
	
	if self.m_ModelInfo then 

		return self.m_ModelInfo.ranseListEx

	end 

end


function CModelBase.InitAnimEffectInfo(self)
	local comps = self:GetComponents(classtype.AnimEffect)
	local data = {}
	if comps then
		for i=0, comps.Length-1 do
			local comp = comps[i]
			data[comp.animName] = {}

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
					table.insert(soundList, {path = info.path, offset = info.offset})
				end
			end

			data[comp.animName].effectList = effectList
			data[comp.animName].soundList = soundList
		end
	end
	self.m_AnimEffectInfos = data
end



function CModelBase.GetEffectMountType(self, sState)
	return sState.."_effects"
end

function CModelBase.CheckAnimEffect(self, sState)
	-- if not g_WarCtrl:IsWar() then
	-- 	return
	-- end
	-- if self.m_CurEffectAnim == sState then
	-- 	return
	-- end
	if not sState then
		printerror("错误：非法的动作，点击查看详细信息")
		return
	end

	local sType = self:GetEffectMountType(sState)
	for _,v in ipairs(self.m_AnimEffects) do
		if Utils.IsExist(v) then
			g_ResCtrl:PutCloneInCache(v:GetCacheKey(), v.m_GameObject)
		end
		self.m_AnimEffects = {}
	end
	local effectList = self.m_AnimEffectInfos[sState] and self.m_AnimEffectInfos[sState].effectList
	if effectList and #effectList > 0 then
		self.m_CurEffectAnim = sState
		for i, info in ipairs(effectList) do
			g_ResCtrl:LoadCloneAsync(info.path, callback(self, "OnEffectLoadDone", sState, sType, info.transform), true)
		end
	else
		self.m_CurEffectAnim = nil
	end
	local soundList = self.m_AnimEffectInfos[sState] and self.m_AnimEffectInfos[sState].soundList
	if soundList and #soundList > 0 then
		for i, info in ipairs(soundList) do
			Utils.AddTimer(function ()
				g_AudioCtrl:PlayEffect(info.path)
				return false
			end, 0, info.offset * 0.001)
		end
	end
end

function CModelBase.OnEffectLoadDone(self, sState, sType, transform, oClone, sPath)

	if self.m_CurEffectAnim ~= sState then
		g_ResCtrl:PutCloneInCache(sPath, oClone)
		return
	end
	local obj = CObject.New(oClone)
	obj:SetCacheKey(sPath)
	obj:ReActive()
	self:MountEffectObj(obj, transform, sType)
	--printc("==============", obj:GetName())
	
end

function CModelBase.MountEffectObj(self, obj, trans, sType)
	if trans then
		obj:SetParent(trans, false)
	end
	obj:SetLocalPos(Vector3.zero)
	table.insert(self.m_AnimEffects, obj)
	self:DelayCall(0, "SetLayer", self:GetLayer(), true)
end

-- 加载新的动作控制器(场景：1 战斗:2 创角 3 4: 结婚)
function CModelBase.ReloadAnimator(self, iShape, animType, cb)
	animType = animType or 1
	if self.m_AnimatorIdx == animType then
		if cb then
			cb()
			cb = nil
		end
		return
	end

	self.m_AnimatorIdx = animType
	local path
	if animType == 3 then
		path = string.format("Model/Character/%d/RoleCreate/RolrCreate%d.overrideController", iShape, iShape)
	elseif animType == 4 then
		path = string.format("Model/Character/%d/Marry/Marry%d.overrideController", iShape, iShape)
	else
		local idx = animType
		local sIdx = idx == 1 and "" or "_"..tostring(idx)
		--神器模型是放在另外的文件夹
		if g_ArtifactCtrl.m_ShenqiModelList[iShape] then
			path = string.format("Model/Shenqi/%d/Anim/Animator%d%s.overrideController", iShape, iShape, sIdx)
		else
			path = string.format("Model/Character/%d/Anim/Animator%d%s.overrideController", iShape, iShape, sIdx)
		end
	end
	g_ResCtrl:LoadAsync(path, callback(self, "OnAnimatorLoadDone", cb))
end

function CModelBase.OnAnimatorLoadDone(self, cb, asset, path)
	if not self.m_Animator then 
		return
	end 

	if asset then
		if datauser.resdata.CacheAssetModel then
			g_ResCtrl:PutAssetInCache(path, asset)
		end
		self.m_Animator.runtimeAnimatorController = asset
	end
	if cb then
		cb()
		cb = nil
	end
end

--设置材质效果
function CModelBase.SetMatEffect(self, effectInfo)
	printc("---------------设置材质效果")

	local endTweenHide = function ( ... )	
		self:RecoverMat()
	end

	local fun = function ( ... )
		if effectInfo.hide_time and effectInfo.hide_time > 0 and  self.m_NewMat  then 
			local tweener = DOTween.DOFloat(self.m_NewMat, 0, "_Alpha", effectInfo.hide_time )
			DOTween.SetEase(tweener, enum.DOTween.Ease.Linear)
			DOTween.OnComplete(tweener, endTweenHide)
		else  
			self:RecoverMat()
		end
		return false
	end

	local endTweenShow = function ( ... )
		if effectInfo.alive_time and effectInfo.alive_time > 0 then 
			self.m_MatTimer = Utils.AddTimer(fun, 0, effectInfo.alive_time)
		end 
	end


	if self.m_NewMat then
		if  effectInfo.show_time and effectInfo.show_time > 0 then 
			self.m_NewMat:SetFloat("_Alpha", 0)
			local tweener = DOTween.DOFloat(self.m_NewMat, 1, "_Alpha", effectInfo.show_time )
			DOTween.SetEase(tweener, enum.DOTween.Ease.Linear)
			DOTween.OnComplete(tweener, endTweenShow)	 
		elseif effectInfo.alive_time and effectInfo.alive_time > 0 then 
			self.m_MatTimer = Utils.AddTimer(fun, 0, effectInfo.alive_time)
		end
	end

end

--设置法术效果
function CModelBase.SetMagicEffect(self, matPath, effectInfo)
	

	--加载新材质
	local cb = function (mat)
			
		--self:SetNewMat(mat)
		self:SetMatEffect(effectInfo)
	end

	if self.m_NewMat then 
		self:SetMatEffect(effectInfo)
		return
	end 
--暂时屏蔽R
--	self:LoadMaterial(matPath, cb)  

end

--初始化meshrender组件
function CModelBase.InitSkinMeshRender(self)

	local modelTrans =  self.m_Transform:Find("model" .. tostring(self.m_ModelInfo.shape))
	if not modelTrans then
		modelTrans = self.m_Transform:Find("model_"..tostring(self.m_ModelInfo.shape))
	end
	if modelTrans then 
		self.m_SkinnedMeshRenderer = modelTrans:GetComponent(classtype.Renderer)
		self.m_DefaultMat =  self.m_SkinnedMeshRenderer.material
	else
		printc("------------------------无法找到Mesh对象，请检查名称是否一致", self.m_ModelInfo.shape)
	end  

	if self.m_Model_Ex then
		self.m_ExModelRender = self.m_Model_Ex:GetComponent(classtype.Renderer)	
	end

end


--显示或者隐藏模型
function CModelBase.ShowModel(self, isShow)
	
	if self.m_SkinnedMeshRenderer then 
		self.m_SkinnedMeshRenderer.enabled = isShow
	end 

	if self.m_ExModelRender then 
		self.m_ExModelRender.enabled = isShow
	end 

end

--加载Mat
function CModelBase.LoadMaterial(self, path, cb)
	
	g_ResCtrl:LoadAsync(path, cb)

end


-- 普通染色
function CModelBase.Ranse(self, matRansePath, ranseInfo, cb)
	local matLoadDone = function(mat)
		if datauser.resdata.CacheAssetModel then
			g_ResCtrl:PutAssetInCache(matRansePath, mat)
		end
		-- printerror("============= 加载mat结束", g_TimeCtrl:GetTimeMS(), g_TimeCtrl:GetTimeS())
		if Utils.IsNil(self) then 
			return
		end 

		if self.m_SkinnedMeshRenderer then

			 self:SetRanseMat(mat)

			 self:SetRanseColor(ranseInfo)

			if cb then 
				cb()
			end 

		end 

	end

	if self.m_RanseMat then 
		self:SetRanseColor(ranseInfo)
		if cb then 
			cb()
		end 
	else
		--加载mat
		-- printerror("============= 加载mat开始", g_TimeCtrl:GetTimeMS(), g_TimeCtrl:GetTimeS(), matRansePath)
		self:LoadMaterial(matRansePath, matLoadDone)

	end 


end

function CModelBase.SetRanseColor(self, ranseInfo)


	if self.m_SkinnedMeshRenderer and ranseInfo then

		if ranseInfo[define.Ranse.PartType.hair] then 		
			self.m_SkinnedMeshRenderer.material:SetColor("_rColor",  ranseInfo[define.Ranse.PartType.hair])
		end 

		if ranseInfo[define.Ranse.PartType.clothes] then
			self.m_SkinnedMeshRenderer.material:SetColor("_gColor",  ranseInfo[define.Ranse.PartType.clothes])
		end 

		if ranseInfo[define.Ranse.PartType.other] then 
			self.m_SkinnedMeshRenderer.material:SetColor("_bColor",  ranseInfo[define.Ranse.PartType.other])
		end 

		if ranseInfo[define.Ranse.PartType.pant] then 
			self.m_SkinnedMeshRenderer.material:SetColor("_aColor",  ranseInfo[define.Ranse.PartType.pant])
		end

	end 

end

-- 扩展染色
function CModelBase.RanseExModel(self, matRanseExPath, ranseInfo, cb)

	if not self.m_Model_Ex then
		if cb then 
			cb()
		end 
		return 
	end

	if not self.m_ExModelRender then 
		if cb then 
			cb()
		end 
		return
	end


	local matLoadDone = function(mat)
		if datauser.resdata.CacheAssetModel then
			g_ResCtrl:PutAssetInCache(matRanseExPath, mat)
		end
		if Utils.IsNil(self) then 
			return
		end 

		if self.m_ExModelRender then

			self:SetExRanseMat(mat)

			self:SetExRanseColor(ranseInfo)

			if cb then 
				cb()
			end 

		end 

	end

	if self.m_ExRanseMat then 
		self:SetExRanseColor(ranseInfo)
		if cb then 
			cb()
		end 
	else
		self:LoadMaterial(matRanseExPath, matLoadDone)
	end 


end

function CModelBase.SetExRanseColor(self, ranseInfo)


	if self.m_ExModelRender and ranseInfo then

		if ranseInfo[define.Ranse.PartType.hair] then 		
			self.m_ExModelRender.material:SetColor("_rColor",  ranseInfo[define.Ranse.PartType.hair])
		end 

		if ranseInfo[define.Ranse.PartType.clothes] then
			self.m_ExModelRender.material:SetColor("_gColor",  ranseInfo[define.Ranse.PartType.clothes])
		end 

		if ranseInfo[define.Ranse.PartType.other] then 
			self.m_ExModelRender.material:SetColor("_bColor",  ranseInfo[define.Ranse.PartType.other])
		end 

		if ranseInfo[define.Ranse.PartType.pant] then 
			self.m_ExModelRender.material:SetColor("_aColor",  ranseInfo[define.Ranse.PartType.pant])
		end

	end 

end


--设置染色材质
function CModelBase.SetRanseMat(self, mat)

	if self.m_SkinnedMeshRenderer then
		self.m_DefaultMat =  self.m_SkinnedMeshRenderer.material
		self.m_RanseMat = mat
		self.m_SkinnedMeshRenderer.material = self.m_RanseMat
	end 

end

function CModelBase.SetExRanseMat(self, mat)

	if self.m_ExModelRender then
		self.m_ExDefaultMat =  self.m_ExModelRender.material
		self.m_ExRanseMat = mat
		self.m_ExModelRender.material = self.m_ExRanseMat
	end 

end

--恢复默认材质
function CModelBase.RecoverMat(self)

	if self.m_SkinnedMeshRenderer then
		self.m_SkinnedMeshRenderer.material = self.m_DefaultMat
		if self.m_RanseMat then
			self.m_RanseMat = nil
		end
	end 

	if self.m_ExModelRender and self.m_ExDefaultMat then 
		self.m_ExModelRender.material = self.m_ExDefaultMat
		if self.m_ExRanseMat then
			self.m_ExRanseMat = nil
		end
	end 

end


--增加材质
function CModelBase.AddMat(self, mPath)
	
	-- local matLoadDone = function(mat)

	-- 	printc("--------------材质加载完毕路径：" .. mPath)

	-- 	if self.m_SkinnedMeshRenderer then

	-- 		self.m_SkinnedMeshRenderer.material = mat	

	-- 		local matInfo = {}
	-- 		matInfo.path = mPath
	-- 		matInfo.mat = mat
	-- 		matInfo.type = "default"
	-- 		matinfo.pos = #self.m_MatList + 1

	-- 	end 

	-- end


	-- self:LoadMaterial(matLoadDone)

end

--删除材质
function CModelBase.DelMat(self, mPath)
	-- body
end



--设置模型的颜色
function CModelBase.SetModelColor(self, color)

	printc("-----------SetModelColor---透明度")
	if self.m_SkinnedMeshRenderer then
		self.m_SkinnedMeshRenderer.material:SetColor("_ColorAlpha", color)
	end 

	if self.m_ExModelRender then 
		self.m_ExModelRender.material:SetColor("_ColorAlpha", color)
	end 
	
end

function CModelBase.RecoverColor(self)
	
	if self.m_SkinnedMeshRenderer then
		self.m_SkinnedMeshRenderer.material:SetColor("_ColorAlpha", Color.white)
	end

	if self.m_ExModelRender then 
		self.m_ExModelRender.material:SetColor("_ColorAlpha", Color.white)
	end 

end

--设置恢复模型透明度
function CModelBase.RecoverModelAlpha(self)
	

	if self.m_SkinnedMeshRenderer then
		self.m_SkinnedMeshRenderer.material:SetColor("_Alpha", Color.white)
	end

	if self.m_ExModelRender then 
		self.m_ExModelRender.material:SetColor("_Alpha", Color.white)
	end

end

--设置模型的大小
function CModelBase.SetSize(self, size)
	self:SetLocalScale(size)
end

function CModelBase.Destroy(self)
	for _, v in ipairs(self.m_AnimEffects) do
		v:Destroy()
	end
	self.m_AnimEffects = {}
	CObject.Destroy(self)
end

--模型引用的obj对象回收
function CModelBase.Recycle(self)
	xxpcall(CModelBase.SafeRecycle, self)
end

function CModelBase.SafeRecycle(self)
	if Utils.IsExist(self) then
		self:RecoverMat()
		self:RecoverColor()
		self:RecoverModelAlpha()
		self:SetSize(Vector3.one)	
		self.m_IsModelLoadone = false
		for _,v in ipairs(self.m_AnimEffects) do
			if Utils.IsExist(v) then
				v:Recycle()
				g_ResCtrl:PutCloneInCache(v:GetCacheKey(), v.m_GameObject)
			end
		end
		self.m_AnimEffects = {}

		if self.m_PathKey and self.m_GameObject then
			--这里是重置精灵所有子物体回到原来位置
			if self.m_IsResetChild then
				local oChildList = self.m_GameObject:GetComponentsInChildren(typeof(UnityEngine.Transform))
				for i = 0, oChildList.Length-1 do
					if self.m_StartPosList and self.m_StartPosList[i+1] then
						oChildList[i].localPosition = self.m_StartPosList[i+1]
					end
					if self.m_StartRotateList and self.m_StartRotateList[i+1] then
						oChildList[i].localEulerAngles = self.m_StartRotateList[i+1]
					end
				end
			end
			if self.m_Animator then
				self.m_Animator.enabled = false
			end
			g_ResCtrl:PutModelInCache(self.m_PathKey, self.m_GameObject)
		end
		self.m_GameObject = nil
		self.m_SkinnedMeshRenderer = nil
		self.m_Animator = nil
		if self.ClearEffect then 
			self:ClearEffect()
		end
		CObject.Recycle(self)
	end
end


--设置动画速度
function CModelBase.SetAnimationSpeed(self, speed)
	if self.m_Animator then
		self.m_Animator.speed = speed
	end
end

--播放某个状态
function CModelBase.Play(self, sState, normalizedTime)
	-- printerror("-----------------CModelBase.Play", sState, self:GetName())
	self:SetState(sState)
	normalizedTime = normalizedTime or 0
	local iHash = ModelTools.StateToHash(sState)
	if self.m_Animator then 
		self.m_Animator:Play(iHash, self.m_Layer, normalizedTime)
	end

end

function CModelBase.PlayInFixedTime(self, sState, fixedTime)
	-- printerror("-----------------CModelBase.PlayInFixedTime", sState, self:GetName())
	self:SetState(sState)
	fixedTime = fixedTime or 0
	local iHash = ModelTools.StateToHash(sState)
	if self.m_Animator then 
		self.m_Animator:PlayInFixedTime(iHash, self.m_Layer, fixedTime)
	end

end

--渐变某状态
function CModelBase.CrossFade(self, sState, iDuration, normalizedTime)
	-- printerror("======= CModelBase.CrossFade", sState, self:GetName())
	self:SetState(sState)
	iDuration = iDuration or 0
	normalizedTime = normalizedTime or 0
	local iHash = ModelTools.StateToHash(sState)
	if self.m_Animator then 
		self.m_Animator:CrossFade(iHash, iDuration, self.m_Layer, normalizedTime)
	end
end

function CModelBase.CrossFadeInFixedTime(self, sState, iDuration, fixedTime)

	self:SetState(sState)
	local iHash = ModelTools.StateToHash(sState)
	iDuration = iDuration or 0
	fixedTime = fixedTime or 0
	if self.m_Animator then 
		self.m_Animator:CrossFadeInFixedTime(iHash, iDuration, self.m_Layer, fixedTime)
	end

end

function CModelBase.SetState(self, sState)
	self.m_State = sState
	self:CheckAnimEffect(sState)
end

--设置模型的父对象
function CModelBase.SetParent(self, parent, bWorldPositionStays)
	CObject.SetParent(self, parent, bWorldPositionStays)
end

--设置缓存key值
function CModelBase.SetCacheKey(self, key)
	self.m_PathKey = key
end


return CModelBase