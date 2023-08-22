local CActor = class("CActor", CObject)
CActor.g_DefalutHeightInfo = {
	fly_height = 0,
	head_height=1.5, 
	waist_height= 0.7,
	foot_height= -0.15,
	collider_height=0.6, 
	collider_rad = 0.2,
}

function CActor.ctor(self)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/ActorNode.prefab")
	CObject.ctor(self, obj)
	self.m_Shape = nil
	self.m_OriShape = nil
	self.m_RideShape = nil
	self.m_Speed = 1
	self.m_ActID = 0
	self.m_MainModel = nil
	self.m_ParentModel = nil
	self.m_DefaultState = "idleCity"
	self.m_CurState = nil
	self.m_LoadingShape = nil
	self.m_ParentLoadingShape = nil
	self.m_CurDesc = {}
	self.m_MainModelFuncList = {}
	self.m_HeightInfo = {}
	self.m_HasHorse = nil
	self.m_WeaponFuhun = nil
	self.m_ConfigObjs = {
	--  size_obj
	-- 	collider
	-- 	head_trans
	-- 	waist_trans
	-- 	foot_trans 
	}
	self.m_MaterialColor = nil
	
	--组合动作
	self.m_ComboHitEvent = {}
	self.m_ComboActList = nil
	self.m_IsShow = true
	--动作映射
	self.m_StateMaps = {} --key: main
	--模型信息
	self.m_DefaultSpeed = 2.7
	self.m_ModelInfos = {} --key: main
	self.m_BodyMatColor = Color.white
	self.m_IsOwnHorse = false
	self.m_MoveSpeed = self.m_DefaultSpeed

	self.m_PlayerStateToHorseMaps = {  --玩家动作到坐骑动作映射
		idleCity = "idleRide",
		run = "runRide",
	}

	self.m_FixedPos = Vector3.zero
	self.m_DefaultAngles = Vector3.zero

	self.m_FunCallLater = {}


	--模型加载状态列表
	self.m_LoadDoneList = {}

	--模型列表
	self.m_ModelList = {}

	--加载状态
	self.m_IsLoading = false

	self.m_WeaponModel = nil
	self.m_RideModel = nil
	self.m_WeaponModel = nil

	self.m_IsUiModel = nil
	-- 是否马上加载回调
	self.m_IsPrior = nil
	-- 加载优先级
	self.m_Priority = nil

	self.m_WaitLoadConfig = nil
	self.m_IsAutoClear = false

	self.m_ValidLoadID = {}

	self.m_ModelInfoList = {}

	self.m_LoadDoneModelList = {}

	self.m_IsLoadDoneShape = false

	self.m_WaitQueue = {}

	self.m_IsWingAlphaLoop = false

end

function CActor.MainModelCall(self, funcname, ...)
	local args = {...}
	local len = select("#", ...)
	local function func()
		local func = CModel[funcname]
		if func then
			if self.m_MainModel then
				func(self.m_MainModel, unpack(args, 1, len))
			end
		end
	end
	if self.m_MainModel then
		func(self.m_MainModel, ...)
	else
		table.insert(self.m_MainModelFuncList, func)
	end
end

function CActor.IsFly(self)
	return self.m_HeightInfo.fly_height and self.m_HeightInfo.fly_height > 0 or false
end


function CActor.SetConfigObjs(self, tObjs)
	self.m_ConfigObjs = tObjs
end

function CActor.SetColliderEnbled(self, b)
	local collider = self.m_ConfigObjs.collider
	if collider then
		collider.enabled = b
	end
end

function CActor.GetAnimMap(self)
	local t1 = {}
	local maps = self.m_StateMaps["main"]
	if maps then
		t1 = table.copy(maps) or {}
	end
	return t1
end



function CActor.SetBodyTexture(self, fileName, imageName)
	if self.m_MainModel then
		local sPath = string.format("Model/Character/%s/Textures/%s.png", fileName, imageName)
		g_ResCtrl:LoadAsync(sPath, callback(self, "OnTextureDone", "body"))
	end
end

function CActor.SetMountTexture(self, fileName, imageName)
	if self.m_MainModel then
		local sPath = string.format("Model/Weapon/%s/Textures/%s.png", fileName, imageName)
		g_ResCtrl:LoadAsync(sPath, callback(self, "OnTextureDone", "mount"))		
	end
end

function CActor.OnTextureDone(self, type, prefab, errcode)
	if prefab then
		if type == "body" then
			self.m_MainModel:SetBodyMatTexture(prefab)
		elseif type == "mount" then
			self.m_MainModel:SetMountMatTexture(prefab)
		end
	elseif errcode then
		printc("CActor.OnTextureDone: ", errcode)
	end
end

function CActor.SetBodyShader(self, rgb)
	if self.m_MainModel then
		local sPath = "Model/Baoyu-Unlit-ModelHue.shader"
		g_ResCtrl:LoadAsync(sPath, callback(self, "OnShaderDone", rgb))
	end
end

function CActor.OnShaderDone(self, rgb, prefab, errcode)
	if prefab then
		self.m_MainModel:UpdateShaderInfo(prefab, rgb)	
	elseif errcode then
		printc(errcode)
	end
end

function CActor.UpdateShaderInfo(self)
	if self.m_MainModel then
		self.m_MainModel:UpdateShaderInfo()	
	end
end


function CActor.DelMaterial(self, sMatPath)
	if self.m_MainModel then
		self.m_MainModel:DelMaterial(sMatPath)
	end
end

function CActor.GetMatColor(self)
	return self.m_BodyMatColor
end

function CActor.IsShow(self)
	return self.m_IsShow
end

function CActor.SetDefaultState(self, sState)
	self.m_DefaultState = sState
end

function CActor.Destroy(self)
	self:DestoryAllModel()
	CObject.Destroy(self)
end

function CActor.GetState(self)
	return self.m_CurState or self.m_DefaultState
end


---创建角色需要用到的
function CActor.WrapRole(self, oClone)
	
	local mainModel = CMainModel.New(oClone)
	local modelInfo = {}
	modelInfo.shape = string.gsub(oClone.name, "model", "")
	mainModel:SetInfo(modelInfo)
	mainModel:SetParent(self.m_Transform)
	mainModel:InitSkinMeshRender()
	self.m_LoadDoneModelList["main"] = mainModel

end

function CActor.WrapWeapon(self, oClone)

	local weaponModel = CWeaponModel.New(oClone)
	local modelInfo = {}
	modelInfo.shape = string.gsub(oClone.name, "weapon", "")
	weaponModel:SetInfo(modelInfo)
	weaponModel:InitSkinMeshRender()
	self.m_LoadDoneModelList["weapon"] = weaponModel

end


--设置模型的魔法效果
function CActor.SetMagicEffect(self, sMatPath, effectInfo)

	for k, v in pairs(self.m_LoadDoneModelList) do 

		if v.SetMatEffect then 

			v:SetMagicEffect(sMatPath, effectInfo)

		end 

	end 

end

--加载一个新的材质
function CActor.LoadMaterial(self, sMatPath, dInfo)

	if self.m_LoadDoneModelList["main"] then 

		self.m_LoadDoneModelList["main"]:LoadMaterial(sMatPath)

	end 

end

--调整hud位置
function CActor.AdjustHudPos(self)

	local model = nil
	if self.m_LoadDoneModelList["main"] then 
		model = self.m_LoadDoneModelList["main"]
	end 

	if self.m_LoadDoneModelList["ride"] then 
		model = self.m_LoadDoneModelList["ride"]	
	end

	if not model then 
		return
	end 

	if not next(self.m_ConfigObjs) then 
		return
	end 
	
	if self.m_ConfigObjs["head_trans"] and model.m_TopMount then
		self.m_ConfigObjs["head_trans"].position = model.m_TopMount.position
	else
		local pos = self:GetPos()
		self.m_ConfigObjs["head_trans"].position = Vector3.New(pos.x, pos.y + 1.35, pos.z)

		-- 特殊处理
		if g_WarCtrl:IsWar() and self:GetOriShape() == 6106 then
			self.m_ConfigObjs["head_trans"].position = Vector3.New(pos.x, 1.8, pos.z)
		end
	end 

	if self.m_ConfigObjs["waist_trans"] and model.m_MidMount then
		self.m_ConfigObjs["waist_trans"].position =  model.m_MidMount.position
	end

	if not g_WarCtrl:IsWar() then
		if self.m_ConfigObjs["foot_trans"] and model.m_BottomMount then
			self.m_ConfigObjs["foot_trans"].position = model.m_BottomMount.position
		end
	end

end


--调整boxcollider
function CActor.AdjustCollider(self, r)
	local dColliderCfg = data.modeldata.COLLIDER[self.m_Shape]
	local radius = (dColliderCfg and dColliderCfg.collider_radius) or r or 0.4
	--暂时这样写
	-- if self.m_Shape == 6104  or self.m_Shape == 6101  then 
	-- 	radius = 0.7
	-- end


	local collider = self.m_ConfigObjs.collider
	if collider then 
		local y = (self.m_ConfigObjs["head_trans"].localPosition.y + self.m_ConfigObjs["foot_trans"].localPosition.y)/2
		if collider then 
			collider.center = Vector3.New(0, y, 0)
			collider.radius = radius
			collider.height = self.m_ConfigObjs["head_trans"].localPosition.y - self.m_ConfigObjs["foot_trans"].localPosition.y
		end 
	end

end


function CActor.SetBodyMatColor(self, color)
	if self.m_LoadDoneModelList["main"] then
		self.m_LoadDoneModelList["main"]:SetModelColor(color)
	end
	if self.m_LoadDoneModelList["wing"] then
		self.m_LoadDoneModelList["wing"]:SetModelColor(color)
	end

end

--设置武器颜色
function CActor.SetWeaponMatColor(self, color)
	local weaponModel = self.m_LoadDoneModelList["weapon"]
	if weaponModel and Utils.IsExist(weaponModel) then
		weaponModel:SetModelColor(color)
	end
end

function CActor.Ranse(self, ranseInfo, cb)
	
	if self.m_LoadDoneModelList["main"] then
		local mainModel = self.m_LoadDoneModelList["main"]
		local sPath  = string.format("Model/Character/%s/Materials/model%s_mask.mat", mainModel:GetShape(), mainModel:GetShape())
		mainModel:Ranse(sPath, ranseInfo, cb)
	end

end

--延时调用
function CActor.FunCallLater(self, fun)
	
	table.insert(self.m_FunCallLater, fun)

end

function CActor.CallFunList(self)
	
	for k, v in pairs(self.m_FunCallLater) do 
		if v then 
			v()
		end 
	end 

	self.m_FunCallLater = {}

end

function CActor.ChangeShape(self, dModelInfo, cb, isUiModel, isPrior, priority)
	-- printerror("------------------------------ChangeShape")
	-- table.print(dModelInfo)
	--TODO:直接修改dModelInfo会引起数据污染

	self.m_IsUiModel = isUiModel
	self.m_IsPrior = isPrior
	self.m_Priority = priority
	local dCopyInfo = table.copy(dModelInfo)
	self.m_FinishCallback = cb

	if self.m_ModelInfo == nil then
		self:HandleChangeShape(dCopyInfo)
	else
		if not table.equal(self.m_ModelInfo, dCopyInfo) then
			self:HandleChangeShape(dCopyInfo)
		else
			if self.m_FinishCallback then 
				self.m_FinishCallback()
			end 
		end   
	end

end

--MainModel主模型，（RideModel骑行模型，weaponModel武器模型）
function CActor.HandleChangeShape(self, dModelInfo)

	--清除
	for k, v in pairs(self.m_LoadDoneModelList) do
		v:Recycle()
	end

	self.m_ModelInfo = dModelInfo
	self.m_LoadDoneModelList = {}
	self.m_ModelInfoList = {}
	self.m_ValidLoadID = {}
	self.m_IsLoadDoneShape = false

	--主模型
	if dModelInfo.shape and  dModelInfo.shape > 0 then 

		local modelInfo = {}
		modelInfo.type = "main"
		if dModelInfo.shizhuang and dModelInfo.shizhuang > 0 then 
			local config =  data.ransedata.SHIZHUANG[dModelInfo.shizhuang]
			if config then
				modelInfo.shape = config.model
				modelInfo.mPath =  self:GetPath(modelInfo.shape)
				modelInfo.ranseList = self:GetRanseColorList(dModelInfo.shape, dModelInfo)
			else
				printc("不存在时装 ----------- ", dModelInfo.shizhuang)
			end
		end
		if not modelInfo.shape then
			modelInfo.shape = dModelInfo.shape
			if dModelInfo.Shenqi then 
				modelInfo.mPath =  self:GetShenQiPath(modelInfo.shape)
			else
				modelInfo.mPath =  self:GetPath(modelInfo.shape)
			end 
			modelInfo.ranseList = self:GetRanseColorList(dModelInfo.shape, dModelInfo)
			modelInfo.ranseListEx = self:GetExRanseColorList(dModelInfo.shape, dModelInfo)
		end 

		local modelData = data.modeldata.CONFIG[modelInfo.shape]
		if modelData then 
			modelInfo.SpriteOffset = modelData.sprite 
		end 

		if dModelInfo.scale and  dModelInfo.scale > 0 then 
			modelInfo.scale = dModelInfo.scale * 0.001
		end  

		self.m_Shape = dModelInfo.shape

		self.m_ModelInfoList[modelInfo.type] = modelInfo

	elseif dModelInfo.figure and  dModelInfo.figure > 0 then 

		local modelInfo = {}
		modelInfo.type = "main"

		local modelData = data.modeldata.CONFIG[dModelInfo.figure]
		local shape = modelData.model
		if dModelInfo.Shenqi then 
			modelInfo.mPath =  self:GetShenQiPath(shape)
		else
			modelInfo.mPath =  self:GetPath(shape)
		end 
		modelInfo.ranseList = self:GetFigureColorList(dModelInfo.figure)
		modelInfo.shape = shape
		if dModelInfo.talkState then
			modelInfo.scale = modelData.talkscale * 0.001
		else
			modelInfo.scale = modelData.scale * 0.001
		end

		modelInfo.SpriteOffset = modelData.sprite 
				
		self.m_Shape = shape

		self.m_ModelInfoList[modelInfo.type] = modelInfo

	end 

	--坐骑加载
	if dModelInfo.horse and dModelInfo.horse > 0 and not g_GmCtrl.m_HideRide then
		self.m_HasHorse = true
		
		local isLoadHorse = false
		if self.m_Shape then 
			local clipInfo = ModelTools.GetAnimClipData(self.m_Shape)
			if clipInfo and clipInfo.idleRide then
				isLoadHorse = true
			else
				isLoadHorse = false
			end 
		else 
			isLoadHorse = true
		end 

		if isLoadHorse then 
			local rideInfo =  data.ridedata.RIDEINFO[dModelInfo.horse]
			if rideInfo then
				self.m_RideShape = rideInfo.shape
				local modelInfo = {}
				modelInfo.mPath =  self:GetPath(rideInfo.shape)
				modelInfo.meshPath = string.format("Model/Character/%d/Meshes/LODMeshes/model%d_LOD3.asset", rideInfo.shape, rideInfo.shape)
				modelInfo.type = "ride"
				modelInfo.ranseList = {}
				modelInfo.shape = rideInfo.shape
				local figureInfo = data.modeldata.CONFIG[rideInfo.shape]
				modelInfo.scale = figureInfo.scale * 0.001
				self.m_ModelInfoList[modelInfo.type] = modelInfo	

			end
		end 

	end 

	--武器加载
	local weaponInfo = define.Model.WEAPON[dModelInfo.shape]
	if weaponInfo and dModelInfo.shape > 0 then

		if dModelInfo.weapon and  dModelInfo.weapon > 0 then
			local equipModelId = 1
			if dModelInfo.weapon > 10 then
				local item = DataTools.GetItemData(dModelInfo.weapon, "EQUIP")
				equipModelId = item.weapon_level
				if dModelInfo.fuhun == 1 then
					equipModelId = item.soul_equip
				end 
			end
			local sType = tostring(dModelInfo.shape).."_".. tostring(equipModelId)
			local modelInfo = {}
			modelInfo.mPath =  string.format("Model/Weapon/%s/Prefabs/weapon%s.prefab", sType, sType)
			modelInfo.type = "weapon"
			modelInfo.ranseList = nil
			modelInfo.shape = sType
			modelInfo.fuhun = dModelInfo.fuhun
			self.m_ModelInfoList[modelInfo.type] = modelInfo

		end 
	end

	--figure关联武器加载
	if dModelInfo.figure and dModelInfo.figure > 0 and (not dModelInfo.shape or dModelInfo.shape == 0) and (not dModelInfo.weapon or dModelInfo.weapon == 0) then 

		local modelData = data.modeldata.CONFIG[dModelInfo.figure]
		local shape = modelData.model
		local oriShape = nil
		--假如该模型是一个时装模型，就找出原模型
		for k, v in pairs(data.ransedata.SZMAP) do 
			for _, modelId in  pairs(v.szModelList) do 
				if modelId == shape then 
					oriShape = v.shape
					break
				end 
			end 
		end 

		local wpmodel = modelData.wpmodel
		if wpmodel > 0 then 
			if oriShape then 
				shape = oriShape
			end 
			local sType = tostring(shape).."_".. tostring(wpmodel)
			local modelInfo = {}
			modelInfo.mPath = string.format("Model/Weapon/%s/Prefabs/weapon%s.prefab", sType, sType)
			modelInfo.type = "weapon"
			modelInfo.ranseList = nil
			modelInfo.shape = sType
			self.m_ModelInfoList[modelInfo.type] = modelInfo
		end
	end

	--精灵
	if dModelInfo.follow_spirit then 
		local id = dModelInfo.follow_spirit
		local config = data.artifactdata.SPIRITINFO
		local spriteInfo = config[id]
		if spriteInfo then 
			local fId = spriteInfo.figureid
			local modelData = data.modeldata.CONFIG[fId]
			if modelData then
				local modelInfo = {}
				modelInfo.type = "sprite"
				modelInfo.scale = modelData.scale * 0.001
				local shape = modelData.model
				modelInfo.mPath =  self:GetPath(shape)
				modelInfo.shape = shape
				self.m_ModelInfoList[modelInfo.type] = modelInfo
			end 
		end 
	end 

	--翅膀
	if dModelInfo.show_wing and not g_GmCtrl.m_HideSwing then 
		local fId = g_WingCtrl:GetWingFigureId(dModelInfo.show_wing)
		if fId then
			local modelData = data.modeldata.CONFIG[fId]
			if modelData then
				local modelInfo = {}
				modelInfo.type = "wing"
				modelInfo.scale = modelData.scale * 0.001
				local shape = modelData.model
				modelInfo.mPath =  self:GetPath(shape)
				modelInfo.shape = shape
				self.m_ModelInfoList[modelInfo.type] = modelInfo
			end 
		end 
	end 

	if dModelInfo.weapon_shape then
		local modelInfo = {
			type = "weapon",
			scale = 1,
			shape = dModelInfo.weapon_shape,
			mPath = self:GetWeaponPath(dModelInfo.weapon_shape),
			fuhun = 1,
		}
		self.m_ModelInfoList[modelInfo.type] = modelInfo
	end

	self:BuildShapes()

end

--modelInfoList(模型信息： mPath(路径), type（类型）, ranseList（染色列表） ) 
function CActor.BuildShapes(self)

	self.m_IsLoading = true
	for k, v in pairs(self.m_ModelInfoList) do 
		self:CreateModel(v)
	end 

end


function CActor.CreateModel(self, modelInfo)
	local uniqueID = Utils.GetUniqueID()
	self.m_ValidLoadID[modelInfo.type] = uniqueID
	g_ResCtrl:LoadCloneAsync(modelInfo.mPath, callback(self, "LoadDoneModel", modelInfo, uniqueID), self.m_IsPrior, true, self.m_Priority)
end

function CActor.LoadDoneModel(self, modelInfo, iUniqueID, oClone, sPath) 

	if oClone then 
		if self.m_ValidLoadID[modelInfo.type] == iUniqueID then
			if modelInfo.type == "weapon" then
				local WeaponModel = CWeaponModel.New(oClone)
				WeaponModel:SetParent(self.m_Transform)
				WeaponModel:SetCacheKey(sPath)
				WeaponModel:SetInfo(modelInfo)
				WeaponModel:SetLayer(UnityEngine.LayerMask.NameToLayer("Hide"), true)
				WeaponModel:InitSkinMeshRender()
				WeaponModel.m_IsModelLoadone = true
				self.m_LoadDoneModelList[modelInfo.type] = WeaponModel
				self.m_WeaponFuhun = modelInfo.fuhun	
			elseif modelInfo.type == "ride" then 
				local RideModel = CRideModel.New(oClone)
				RideModel:SetParent(self.m_Transform)
				RideModel:SetCacheKey(sPath)
				RideModel:SetInfo(modelInfo)
				RideModel:SetLayer(UnityEngine.LayerMask.NameToLayer("Hide"), true)
				RideModel:InitSkinMeshRender()
				RideModel:SetLocalScale(Vector3.New(modelInfo.scale, modelInfo.scale, modelInfo.scale))
				RideModel.m_IsModelLoadone = true
				self.m_LoadDoneModelList[modelInfo.type] = RideModel
				--TEST
				-- local mesh = g_ResCtrl.m_CacheMesh[modelInfo.meshPath]
				-- if not g_ResCtrl.m_CacheMesh[modelInfo.meshPath] then
				-- 	mesh = g_ResCtrl:Load(modelInfo.meshPath)
				-- end
				-- RideModel.m_SkinnedMeshRenderer.sharedMesh = mesh
			elseif modelInfo.type == "main" then 
				local MainModel = CMainModel.New(oClone)
				MainModel:SetParent(self.m_Transform)
				MainModel:SetCacheKey(sPath)
				MainModel:SetInfo(modelInfo)
				MainModel:SetLayer(UnityEngine.LayerMask.NameToLayer("Hide"), true)
				MainModel:InitSkinMeshRender()
				MainModel.m_IsModelLoadone = true
				self.m_LoadDoneModelList[modelInfo.type] = MainModel
				MainModel:ShowMask(g_WarCtrl:IsWar())
			elseif modelInfo.type == "sprite" then 
				local SpriteModel = CSpriteModel.New(oClone)
				SpriteModel:SetParent(self.m_Transform)
				local oStartPosList = {}
				local oStartRotateList = {}
				local oChildList = SpriteModel.m_GameObject:GetComponentsInChildren(typeof(UnityEngine.Transform))
				for i = 0, oChildList.Length-1 do
					table.insert(oStartPosList, oChildList[i].localPosition)
					table.insert(oStartRotateList, oChildList[i].localEulerAngles)
				end
				SpriteModel.m_StartPosList = oStartPosList
				SpriteModel.m_StartRotateList = oStartRotateList
				SpriteModel.m_IsResetChild = true
				SpriteModel:SetCacheKey(sPath)
				SpriteModel:SetInfo(modelInfo)
				SpriteModel:SetLayer(UnityEngine.LayerMask.NameToLayer("Hide"), true)
				SpriteModel:InitSkinMeshRender()
				SpriteModel.m_IsModelLoadone = true
				self.m_LoadDoneModelList[modelInfo.type] = SpriteModel
			elseif modelInfo.type == "wing" then 
				local WingModel = CWingModel.New(oClone)
				WingModel:SetParent(self.m_Transform)
				WingModel:SetCacheKey(sPath)
				WingModel:SetInfo(modelInfo)
				WingModel:SetLayer(UnityEngine.LayerMask.NameToLayer("Hide"), true)
				WingModel:InitSkinMeshRender()
				WingModel.m_IsModelLoadone = true
				WingModel:SetLocalScale(Vector3.one*modelInfo.scale)
				self.m_LoadDoneModelList[modelInfo.type] = WingModel
				if self.m_IsWingAlphaLoop then
					WingModel:AddAlphaTimer()
				end
			end
			self:CheckLoadDoneModel()
		else
			local animator = oClone:GetComponent(classtype.Animator)
			if animator then 
				animator.enabled = false
			end
			g_ResCtrl:PutModelInCache(sPath, oClone)	
		end   
	end 

end

function CActor.CheckLoadDoneModel(self)

	if Utils.IsNil(self) then
		return 
	end

	if not next(self.m_ModelInfoList) then 
		return
	end
 
	for k, v in pairs(self.m_ModelInfoList) do 
		local info = self.m_LoadDoneModelList[k]
		if not info then 
			return
		end 
	end 

	for k, v in pairs(self.m_LoadDoneModelList) do
		local animator = v.m_Animator 
		if animator and not animator.enabled then
			animator.enabled = true
		end
	end 

	self.m_OriActorScale = nil

	local ranseFinish = false
	local animatorFinish = false

	self:RecoverColor()

	local checkLoadDone = function ()

		if Utils.IsNil(self) then
			return 
		end
		
		if not (ranseFinish and animatorFinish) then
			return
		end 

		self:SetActive(true)

		self:AssembleModel()

		--获取缩放大小
		local scale = 1

		--处理模型大小
		local mainModel =  self.m_LoadDoneModelList["main"] 

		if mainModel then 
			local modelInfo = mainModel:GetModelInfo()
			scale = modelInfo.scale
			if scale and scale ~= 0 then 
				mainModel:SetLocalScale(Vector3.New(scale, scale, scale))
			end 
		end 

		--器灵大小  位置
		local spriteModel = self.m_LoadDoneModelList["sprite"]
		if spriteModel then 
			local modelInfo = spriteModel:GetModelInfo()
			scale = modelInfo.scale
			if scale and scale ~= 0 then 
				spriteModel:SetLocalScale(Vector3.New(scale, scale, scale))
			end 

			local rideModel = self.m_LoadDoneModelList["ride"]
			if mainModel then
				local mainModelInfo = mainModel:GetModelInfo()
				local offset = 0
				if rideModel then 
					offset = mainModelInfo.SpriteOffset
				end  
				spriteModel:SetLocalPos(Vector3.New(0, offset, 0))
			end 
		end 

		self:SetModelOriScale(Vector3.New(scale, scale, scale))
	 
		self:AdjustHudPos()

		self:AdjustCollider()

		self:CallFunList()

		self:SetLayer(self:GetLayer(), true)

		if self.m_FinishCallback then		
			self.m_FinishCallback()
			self.m_FinishCallback = nil
		end

		self.m_IsLoading = false

		self.m_IsLoadDoneShape = true

		self:RecoverModelAlpha()

	end

	local ranseDone = function ()

		ranseFinish = true
		checkLoadDone()

	end

	local reLoadAnimatorDone = function ()

		animatorFinish = true
		checkLoadDone()

	end

	-- 临时处理
	if self.m_Shape == 8237 then
		animatorFinish = true
	else
		self:ReloadAnimator(reLoadAnimatorDone)		
	end

	self:RanseMainModel(ranseDone)

end


function CActor.AssembleModel(self)

	if not next(self.m_LoadDoneModelList) then 
		return
	end 
	
	local mainModel = self.m_LoadDoneModelList["main"]
	local weaponModel = self.m_LoadDoneModelList["weapon"]
	local rideModel = self.m_LoadDoneModelList["ride"]
	local spriteModel = self.m_LoadDoneModelList["sprite"]
	local wingModel = self.m_LoadDoneModelList["wing"]

	if mainModel then 	
		if rideModel then 
			rideModel:SetOnRide(mainModel)
			local anim = "idleRide"
			if self.m_RideShape == 4008 then
				anim = "idleCity"
			end
			mainModel:CrossFade(anim)
			rideModel:CrossFade("idleCity")
			if weaponModel then 
				weaponModel:CrossFade("idleRide")
				mainModel:EquipWeapon(weaponModel)
			end
			if spriteModel then 
				mainModel:AddSprite(spriteModel)
				spriteModel:CrossFade("idleCity")
			end 
			if wingModel then 
				mainModel:AddWing(wingModel)
				wingModel:CrossFade("idleCity")
			end
		else
			if weaponModel then 
				weaponModel:CrossFade("idleCity")
				mainModel:EquipWeapon(weaponModel)
			end
			if spriteModel then 
				mainModel:AddSprite(spriteModel)
				spriteModel:CrossFade("idleCity")
			end 
			if wingModel then 
				wingModel:CrossFade("idleCity")
				mainModel:AddWing(wingModel)
			end 
			if mainModel then 
				mainModel:CrossFade("idleCity")
			end
		end 
	else 
		if rideModel then 
			rideModel:CrossFade("idleCity")
		end
	end

end

function CActor.ReloadAnimator(self, cb)
	
	local mainModel = self.m_LoadDoneModelList["main"]

	if mainModel then 
		local shape = mainModel:GetShape()
		--特殊处理
		if shape == 2201 then 
			mainModel:SetAnimatorCullModel()
		end
		local animType = self.loadAnimType or (((g_WarCtrl:IsWar() or g_PlotCtrl:IsPlaying()) and (not self.m_IsUiModel)) and 2 or 1)
		self.loadAnimType = nil
		mainModel:ReloadAnimator(shape, animType, cb)
	else
		if cb then 
			cb()
		end 
	end  
	
end

function CActor.RanseMainModel(self, cb)

	local mainModel = self.m_LoadDoneModelList["main"]

	if not mainModel then 
		if cb then 
			cb()
		end  
		return
	end 

	--处理扩展染色
	local MainRanseDone = function ( ... )
		
		local sPath  = string.format("Model/Character/%s/Materials/model%s_ex_mask.mat", mainModel:GetShape(), mainModel:GetShape())

		local ranseInfo = mainModel:GetRanseExInfo()

		if ranseInfo ~= nil and  next(ranseInfo) then 
			mainModel:RanseExModel(sPath, ranseInfo, cb)	
		else
			if cb then 
				cb()
			end 
			return
		end  
	end

    --处理主染色
	local sPath  = string.format("Model/Character/%s/Materials/model%s_mask.mat", mainModel:GetShape(), mainModel:GetShape())
	local ranseInfo = mainModel:GetRanseInfo()

	if not next(ranseInfo) then 
		if cb then 
			cb()
		end  
		return
	end 

	mainModel:Ranse(sPath, ranseInfo, MainRanseDone)

end

function CActor.IsAllModelLoadDone(self)

	for k, v in pairs(self.m_ModelInfoList) do 
		local info = self.m_LoadDoneModelList[k]
		if not info then 
			return false
		end 
	end 
	return true

end

function CActor.GetFigureColorList(self, figure)

	local colorList = {}
	local config =  data.modeldata.CONFIG[figure]

	if not config then 
		return colorList
	end 

	if not next(config.color) then 
		return colorList
	end 

	for k, v in ipairs(config.color) do 

		colorList[k] = g_RanseCtrl:ParseStrToColor(v)

	end 

	if colorList[define.Ranse.PartType.pant] then 
		colorList[define.Ranse.PartType.pant] = nil
	end 

	return colorList

end


function CActor.GetRanseColorList(self, shape, modelInfo)

	local colorList = {}

	if modelInfo.shizhuang and modelInfo.shizhuang > 0 then 

		if modelInfo.ranse_shizhuang and modelInfo.ranse_shizhuang > 0 then 
			local config =  data.ransedata.SHIZHUANG[modelInfo.shizhuang]

			-- if modelInfo.ranse_hair and  modelInfo.ranse_hair  > 0 then 
			-- 	colorList[define.Ranse.PartType.hair] =  g_RanseCtrl:GetColorValue(define.Ranse.PartType.hair, modelInfo.ranse_hair, shape)
			-- end 
			colorList[define.Ranse.PartType.hair] = Color.white
			colorList[define.Ranse.PartType.clothes] = g_RanseCtrl:ParseStrToColor(config.colorlist[modelInfo.ranse_shizhuang].value1)
			colorList[define.Ranse.PartType.other] =  g_RanseCtrl:ParseStrToColor(config.colorlist[modelInfo.ranse_shizhuang].value2)
			colorList[define.Ranse.PartType.pant] =  g_RanseCtrl:ParseStrToColor(config.colorlist[modelInfo.ranse_shizhuang].value3)
		else
			-- if modelInfo.ranse_hair and  modelInfo.ranse_hair  > 0 then 
			-- 	colorList[define.Ranse.PartType.hair] =  g_RanseCtrl:GetColorValue(define.Ranse.PartType.hair, modelInfo.ranse_hair, shape)
			-- end 
			colorList[define.Ranse.PartType.hair] = Color.white
			colorList[define.Ranse.PartType.clothes] = Color.white
			colorList[define.Ranse.PartType.other] = Color.white
			colorList[define.Ranse.PartType.pant] = Color.white
		end 

	else

		if modelInfo.ranse_hair and  modelInfo.ranse_hair  > 0 then 
			colorList[define.Ranse.PartType.hair] =  g_RanseCtrl:GetColorValue(define.Ranse.PartType.hair, modelInfo.ranse_hair, shape)
		end 

		if modelInfo.ranse_clothes and modelInfo.ranse_clothes > 0 then 
			colorList[define.Ranse.PartType.clothes] =  g_RanseCtrl:GetColorValue(define.Ranse.PartType.clothes, modelInfo.ranse_clothes, shape)
			colorList[define.Ranse.PartType.other] =  g_RanseCtrl:GetColorValue(define.Ranse.PartType.other, modelInfo.ranse_clothes, shape)
		end 

		if modelInfo.ranse_pant and modelInfo.ranse_pant > 0 then 

			colorList[define.Ranse.PartType.pant] =  g_RanseCtrl:GetColorValue(define.Ranse.PartType.pant, modelInfo.ranse_pant, shape)

		end

		if modelInfo.ranse_summon and modelInfo.ranse_summon > 0 then 

			colorList = g_RanseCtrl:GetSummonColorList(shape, modelInfo.ranse_summon)

		end

	end 

    return colorList

end

function CActor.GetExRanseColorList(self, shape, modelInfo)

	local colorList = {}

	if modelInfo.ranse_summon and modelInfo.ranse_summon > 0 then 

		colorList = g_RanseCtrl:GetSummonExColorList(shape, modelInfo.ranse_summon)

	end

    return colorList

end

function CActor.ShowModel(self, isShow)
	
	for k, v in pairs(self.m_LoadDoneModelList) do
		v:ShowModel(isShow)
	end 

end

function  CActor.ShowWeapon(self, isShow)
	local weaponModel = self.m_LoadDoneModelList["weapon"]
	if weaponModel and Utils.IsExist(weaponModel) then 
		weaponModel:SetActive(isShow)
	end 

end

function CActor.ShowRideEffect(self, lv)
	
	if self.m_LoadDoneModelList["ride"] then
		local hideEffect = g_HorseCtrl:IsHideEffect(self.m_ModelInfo.horse)
		lv = hideEffect and 0 or lv
		self.m_LoadDoneModelList["ride"]:ShowRideEffect(lv)
	end 	

end

function CActor.ShowWingEffect(self, lv)
	
	if self.m_LoadDoneModelList["wing"] then
		self.m_LoadDoneModelList["wing"]:ShowWingEffect(lv)
	end 

end

function CActor.ShowWeaponEffect(self, lv)
	local weaponModel = self.m_LoadDoneModelList["weapon"]
	if weaponModel then
		local bEffect = self.m_WeaponFuhun
		weaponModel:SetWeaponEffectLevel(bEffect, lv)
	end

end

function CActor.NormalWalk(self)
	self.m_MainModel:SetParent(self.m_Transform)
	self.m_MainModel:CrossFade("idleCity")
end

function CActor.RecoverModelAlpha(self)
	
	for k, v in pairs(self.m_LoadDoneModelList) do 
		v:RecoverModelAlpha()
	end 

end

function CActor.RecoverColor(self)
	
	for k, v in pairs(self.m_LoadDoneModelList) do 
		v:RecoverColor()
	end 

end

--保存原缩放
function CActor.SetModelOriScale(self, scale)
	
	self.m_OriActorScale = scale

end

function CActor.GetModelOriScaleFactor(self)

	if self.m_OriActorScale then 
		return self.m_OriActorScale.x
	else
		return 1
	end 

end

function CActor.IsWeaponFuHun(self)
	
	if self.m_WeaponFuhun or self.m_WeaponFuhun > 0 then 
		return true
	else
		return false
	end 

end

function CActor.IsLoadDoneShape(self)
	return self.m_IsLoadDoneShape
end

function CActor.ResizeTitle(self, dInfo)
	local figure = dInfo and dInfo.figure or self.m_Shape
	if figure then
		local dConfig = ModelTools.GetModelConfig(figure)
		local scale = dConfig.scale * 0.001

		if self.m_ConfigObjs["head_trans"] then
			-- printc("哈哈哈哈哈哈哈 head_trans存在", self:GetName(), ", scale", scale, ", y:", self.m_ConfigObjs["head_trans"].localPosition.y)
			self.m_ConfigObjs["head_trans"].localPosition = self.m_ConfigObjs["head_trans"].localPosition* scale
		end
		if self.m_ConfigObjs["waist_trans"] then
			self.m_ConfigObjs["waist_trans"].localPosition = self.m_ConfigObjs["waist_trans"].localPosition* scale
		end
		if self.m_ConfigObjs["foot_trans"] then
			self.m_ConfigObjs["foot_trans"].localPosition = self.m_ConfigObjs["foot_trans"].localPosition* scale
		end		
	end
end

function CActor.SetFixedPos(self, pos)
	self.m_FixedPos = pos
end

function CActor.SetDefaultAnlge(self, angles)
	self.m_DefaultAngles = angles
end

--主角有换时装等等东西，如果要获取玩家模型，外部不要调用这个方法，得到的数据是不对的
function CActor.GetShape(self)
	return self.m_Shape
end

function CActor.GetOriShape(self)
	-- 必须加载完成之后才生效的
	if not self.m_OriShape then
		local shape = self:GetShape()
		self.m_OriShape = ModelTools.GetOriShape(shape)
	end
	return self.m_OriShape
end

function CActor.GetPath(self, iShape)
	local path = string.format("Model/Character/%d/Prefabs/model%d.prefab", iShape, iShape)
	return path
end

function CActor.GetShenQiPath(self, iShape)
	local path = string.format("Model/Shenqi/%d/Prefabs/model%d.prefab", iShape, iShape)
	return path
end

function CActor.GetWeaponPath(self, sShape)
	return string.format("Model/Weapon/%s/Prefabs/weapon%s.prefab", sShape, sShape)
end

function CActor.GetModelInfo(self, sType)
	sType = sType or "main"
	return self.m_ModelInfos[sType]
end

--showScene的时候会调用这里
function CActor.DestoryAllModel(self)

	self:Clear()

end

function CActor.Clear(self)
	if not Utils.IsNil(self) then
		self:SetLocalScale(Vector3.one)
	end
	self.m_OriActorScale = nil
	self.m_Shape = nil
	self.m_ValidLoadID = {}
	self.m_ModelInfoList = {}
	-- self.m_LoadDoneModelList = {}
	self.m_IsUiModel = nil
	self.m_IsPrior = nil
	self.m_ModelInfo = nil
	self.m_IsLoading = false
	self.m_FinishCallback = nil
	self.m_IsLoadDoneShape = false
	self.m_WaitQueue = {}
	self.m_CurState = nil
	self.m_IsWingAlphaLoop = false

	for k, v in pairs(self.m_LoadDoneModelList) do 
		v:Recycle()
	end
	self.m_LoadDoneModelList = {}

end

function CActor.GetMainModel(self)
	return self.m_LoadDoneModelList["main"]
end

--comob act,连续动画的播放
function CActor.PlayCombo(self, actname)
	local shape =self.m_Shape
	if not datauser.comboactdata.DATA[shape] then
		return false
	end
	local list = datauser.comboactdata.DATA[shape][actname]
	if not list then
		return false
	end
	self.m_ComboActList = list
	self.m_ComboIdx = 1
	self:ComboStep()
	return true
end

function CActor.IsComboing(self)
	return self.m_ComboActList ~= nil
end

function CActor.NormalSpeed(self)
	self:SetSpeed(1)
end

function CActor.SetSpeed(self, iSpeed)
	if self.m_Speed ~= iSpeed then
		self.m_Speed = iSpeed
		if self.m_MainModel then
			--self.m_MainModel:SetSpeed(iSpeed)
		end
	end
end

function CActor.ComboStep(self)
	if not self.m_ComboActList then
		return
	end
	local act = self.m_ComboActList[self.m_ComboIdx]
	if not act then
		self.m_ComboHitEvent = {}
		self.m_ComboActList = nil
		return
	end
	local speed = act.speed
	self.m_ComboIdx = self.m_ComboIdx + 1
	if act.action == "pause" then
		self:Pause(act.hit_frame-act.start_frame, callback(self, "ComboStep"))
	else
		self:PlayInFrame(act.action, act.start_frame/speed, act.end_frame/speed, callback(self, "ComboStep"))
		act.hit_frame = tonumber(act.hit_frame)
		self:SetSpeed(speed)
		if act.hit_frame then
			self:FrameEvent(act.action, (act.hit_frame-act.start_frame)/speed, callback(self, "NotifyComboHit"))
		end
	end
end

function CActor.SetComboHitEvent(self, cb)
	table.insert(self.m_ComboHitEvent, cb)
end

function CActor.NotifyComboHit(self)
	for i, cb in ipairs(self.m_ComboHitEvent) do
		cb()
	end
end

function CActor.GetFinalState(self, sState)
	local map = self:GetAnimMap()
	local sState = map[sState] or sState
	--跳舞不显示武器
	if sState == "dance" then
		self:ShowWeapon(false)
	else
		self:ShowWeapon(true)
	end
	return sState
end



--animator，改变所有模型的动画
function CActor.AllModelAnim(self, animfunc, ...)


	if self.m_LoadDoneModelList["main"] == nil then
		return
	end 

	-- 这种写法args只被赋第一个值
	local args = ...

	if self.m_LoadDoneModelList["ride"] then

		local act = nil
		if type(args) == "table" then
			act = args[1]
		else
			act = args
		end

		local anim = self.m_PlayerStateToHorseMaps[act]
		if anim then
			local rideModel = self.m_LoadDoneModelList["ride"]
			if self.m_RideShape == 4008 and (anim == "idleRide" or anim == "runRide") then
				anim = "idleCity"
			end
			animfunc(self.m_LoadDoneModelList["main"], anim)
		end

		local weaponAni = self.m_PlayerStateToHorseMaps[act]
		if weaponAni then
			if self.m_LoadDoneModelList["weapon"] then 
				animfunc(self.m_LoadDoneModelList["weapon"], weaponAni)
			end
		end 

		animfunc(self.m_LoadDoneModelList["ride"], ...)

		if self.m_LoadDoneModelList["sprite"] then 
			animfunc(self.m_LoadDoneModelList["sprite"], ...)
		end

		local wingModel = self.m_LoadDoneModelList["wing"]
		if wingModel then
			animfunc(wingModel, ...)
		end

	else 
		animfunc(self.m_LoadDoneModelList["main"], ...)

		if self.m_LoadDoneModelList["weapon"] then 
			animfunc(self.m_LoadDoneModelList["weapon"], ...)
		end

		if self.m_LoadDoneModelList["sprite"] then 
			animfunc(self.m_LoadDoneModelList["sprite"], ...)
		end  
		
		local wingModel = self.m_LoadDoneModelList["wing"]
		if wingModel then
			local act = nil
			if type(args) == "table" then
				act = args[1]
			else
				act = args
			end
			if act == "die" then
				wingModel:SetAnimationSpeed(0)
			else
				wingModel:SetAnimationSpeed(1)
			end
			animfunc(wingModel, ...)
		end
	end 

end

function CActor.GetAnimatorIdx(self)
	if self.m_LoadDoneModelList["main"] then
		return self.m_LoadDoneModelList["main"].m_AnimatorIdx
	else
		return 1
	end
end

function CActor.AdjustSpeedPlay(self, sState, iAdjustTime)
	self:PlayInFixedTime(sState)
	sState = self:GetFinalState(sState)
	local dClipInfo = ModelTools.GetAnimClipInfo(self.m_Shape, sState, self:GetAnimatorIdx())
	self:SetSpeed(dClipInfo.length / iAdjustTime)
end

function CActor.AdjustSpeedPlayInFrame(self, sState, iAdjustTime, iStartFrame, iEndFrame)
	sState = self:GetFinalState(sState)
	if not iEndFrame then
		local dClipInfo = ModelTools.GetAnimClipInfo(self.m_Shape, sState, self:GetAnimatorIdx())
		iEndFrame = dClipInfo.frame
	end
	local iTime = ModelTools.FrameToTime(iEndFrame-iStartFrame)
	local iSpeed = iTime / iAdjustTime
	self:PlayInFrame(sState, iStartFrame, iStartFrame+(iEndFrame-iStartFrame)/iSpeed, function(o) o:SetSpeed(0) end)
	self:SetSpeed(iSpeed)
end

function CActor.Play(self, sState, startNormalized, endNormalized, func)
	self:ResetState()
	sState = self:GetFinalState(sState)
	self.m_CurState = sState
	self.m_ActID = self.m_ActID + 1
	self:AllModelAnim(CModelBase.Play, sState, startNormalized)
	if endNormalized then
		local fixedTime = ModelTools.NormalizedToFixed(self.m_Shape, self:GetAnimatorIdx(),sState, endNormalized-startNormalized)
		self:FixedEvent(sState, fixedTime, func)
	end
end

function CActor.PlayInFixedTime(self, sState, startFixed, endFixed, func)
	self:ResetState()
	sState = self:GetFinalState(sState)
	self.m_CurState = sState
	self.m_ActID = self.m_ActID + 1
	self:AllModelAnim(CModelBase.PlayInFixedTime, sState, startFixed)
	if endFixed then
		self:FixedEvent(sState, startFixed-endFixed, func)
	end
end


--动作合成
function CActor.CrossFade(self, sState, duration, startNormalized, endNormalized, func)
	
	self:ResetState()
	sState = self:GetFinalState(sState)
	self.m_CurState = sState
	self.m_ActID = self.m_ActID + 1
	self:AllModelAnim(CModelBase.CrossFade, sState, duration, startNormalized)
	if endNormalized then
		local fixedTime = ModelTools.NormalizedToFixed(self.m_Shape, self:GetAnimatorIdx(), sState, endNormalized-startNormalized)
		self:FixedEvent(sState, fixedTime, func)
	end
end

function CActor.CrossFadeInFixedTime(self, sState, duration, startFixed, endFixed, func)
	self:ResetState()
	sState = self:GetFinalState(sState)
	self.m_CurState = sState
	self.m_ActID = self.m_ActID + 1
	self:AllModelAnim(CModelBase.CrossFadeInFixedTime, sState, duration, startFixed)
	if endFixed then
		self:FixedEvent(sState, endFixed-startFixed, func)
	end
end

function CActor.PlayInFrame(self, sState, startFrame, endFrame, func)
	local dClipInfo = ModelTools.GetAnimClipInfo(self.m_Shape, sState, self:GetAnimatorIdx())
	local startNormalized = startFrame / dClipInfo.frame
	self:Play(sState, startNormalized)
	if endFrame then
		local fixedTime = ModelTools.FrameToTime(endFrame-startFrame)
		self:FixedEvent(sState, fixedTime, func)
	end
end

function CActor.CrossFadeInFrame(self, sState, duration, startFrame, endFrame, func)
	local dClipInfo = ModelTools.GetAnimClipInfo(self.m_Shape, sState, self:GetAnimatorIdx())
	local startNormalized = startFrame / dClipInfo.frame
	self:CrossFade(sState, duration, startNormalized)
	if endFrame then
		local fixedTime = ModelTools.FrameToTime(endFrame-startFrame)
		self:FixedEvent(sState, fixedTime, func)
	end
end

function CActor.Pause(self, frame, cb)
	self:ResetState()
	self.m_ActID = self.m_ActID + 1
	self:SetSpeed(0)
	self:FrameEvent("pause", frame, cb)
end

function CActor.ResetState(self)
	if self.m_EventTimer then
		Utils.DelTimer(self.m_EventTimer)
		self.m_EventTimer = nil
	end
	if not self:IsComboing() then
		self:NormalSpeed()
	end
end

function CActor.FixedEvent(self, sState, fixedTime, func)
	fixedTime = math.max((fixedTime or 1) - 0.01, 0)
	local iActID = self.m_ActID
	self.m_EventTimer = Utils.AddTimer(callback(self, "OnEvent", iActID, func, fixedTime), 0, fixedTime)
end

function CActor.NomallizedEvent(self, sState, normalizedTime, func)
	local dClipInfo = ModelTools.GetAnimClipInfo(self.m_Shape, sState, self:GetAnimatorIdx())
	local fixedTime = dClipInfo.length * normalizedTime
	self:FixedEvent(sState, fixedTime, func)
end

function CActor.FrameEvent(self, sState, frame, func)
	local fixedTime = ModelTools.FrameToTime(frame)
	self:FixedEvent(sState, fixedTime, func)
end

function CActor.OnEvent(self, actid, func, fixedTime)
	if self.m_ActID == actid and func then
		func(self)
	end
	self.m_EventTimer = nil
end

function CActor.DebugPrint(self, ...)
	if self:GetInstanceID() == CWarrior.g_TestActorID then
		printc(...)
	end
end

function CActor.GetHitKeyFrame(self)
	local idx = 1
	if self.m_MainModel then
		idx = self.m_MainModel.m_AnimatorIdx
	end
	local d = ModelTools.GetAnimClipInfo(self.m_Shape, "hit1", idx)
	return d.frame
end

function CActor.CrossFadeLoop(self, sState, duration, startNormalized, endNormalized, isLoop, func)
	self:ResetState()
	
	sState = self:GetFinalState(sState)
	self.m_CurState = sState
	self.m_ActID = self.m_ActID + 1
	self:AllModelAnim(CModelBase.CrossFade, sState, duration, startNormalized)

	if endNormalized then
		self:StopCrossFadeLoop()
		local iShape = self.m_HasHorse and self.m_RideShape or self.m_Shape
		local fixedTime = ModelTools.NormalizedToFixed(iShape, self:GetAnimatorIdx(), sState, endNormalized-startNormalized)
		local function OnLoopEvent()	
			if func then
				func()
			end
			self:AllModelAnim(CModelBase.CrossFade, sState, duration, startNormalized)
			if isLoop then
				return true
			else
				return false	
			end		
		end
		self.m_EventLoopTimer = Utils.AddTimer(OnLoopEvent, fixedTime , 0)
	end
end

function CActor.StopCrossFadeLoop(self)
	if self.m_EventLoopTimer then
		Utils.DelTimer(self.m_EventLoopTimer)
		self.m_EventLoopTimer = nil
	end
end

function CActor.IsExistShape(self, iShape)
	local sPath = self:GetPath(iShape)
	return g_ResCtrl:IsExist(sPath)
end

function CActor.SetQiLingWalkeState(self, isWalking)
	
	local spriteModel = self.m_LoadDoneModelList["sprite"]
	if spriteModel then
		spriteModel:SetWalkingState(isWalking)
	end 

end

function CActor.SetWingAlphaLoop(self, bLoop)
	self.m_IsWingAlphaLoop = bLoop
	local oWing = self.m_LoadDoneModelList["wing"]
	if oWing then
		if bLoop then
			oWing:AddAlphaTimer()
		else
			oWing:DelAlphaTimer()
		end
	end
end

function CActor.SetAllAnimSpeed(self, speed)
	for _, oModel in pairs(self.m_LoadDoneModelList) do
		oModel:SetAnimationSpeed(speed)
	end
end

return CActor