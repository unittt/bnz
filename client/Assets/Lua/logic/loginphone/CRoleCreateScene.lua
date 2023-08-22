local CRoleCreateScene = class("CRoleCreateScene", CCtrlBase)

function CRoleCreateScene.ctor(self)
	CCtrlBase.ctor(self)
	self:Clear()
end

function CRoleCreateScene.Clear(self)
	-- if self.m_RoleCreateScene then
	-- 	self.m_RoleCreateScene:Destroy()
	-- 	self.m_RoleCreateScene = nil
	-- end
	self.m_IsShowingRoleCreateScene = false
	self.m_IsShowingActor = false
	self.m_LastShowActorId = nil
	self.m_CurRoleCreatePlayer = nil
	self.m_CurActorRoleconfigid = 1
	self.m_HasAskCreateScene = false
	-- if self.m_LastShowActorModel then
	-- 	self.m_LastShowActorModel:Destroy()
	-- 	self.m_LastShowActorModel = nil
	-- end
end

--通过self.m_HasAskCreateScene变量控制只生成一个场景
function CRoleCreateScene.OnCreateScene(self)
	if not self.m_HasAskCreateScene then
		self:OnDestroyScene()
		g_ResCtrl:LoadCloneAsync("UI/Login/RoleCreateMainScene.prefab", callback(self, "OnRoleCreateCameraDone"), false)
		self.m_HasAskCreateScene = true
	end
end

function CRoleCreateScene.OnRoleCreateCameraDone(self, obj, path)
	if not g_LoginPhoneCtrl.m_IsRoleCreateEffectCache then
		for k,v in pairs(data.roletypedata.DATA) do
			local path = "Effect/Character/"..data.roletypedata.DATA[k].shape.."_rolecreate3_effect/Prefabs/"..data.roletypedata.DATA[k].shape.."_rolecreate3_effect.prefab"
			CEffect.New(path, UnityEngine.LayerMask.NameToLayer("RoleCreate"), true, function (oEff)
				oEff:Destroy()
			end)

			local path2 = "Effect/Character/"..data.roletypedata.DATA[k].shape.."_rolecreate1_effect/Prefabs/"..data.roletypedata.DATA[k].shape.."_rolecreate1_effect.prefab"
			CEffect.New(path2, UnityEngine.LayerMask.NameToLayer("RoleCreate"), true, function (oEff)
				oEff:Destroy()
			end)
		end
		g_LoginPhoneCtrl.m_IsRoleCreateEffectCache = true
	end	
	
	if obj then
		g_AudioCtrl:PlayMusic(define.Audio.MusicPath.login)
		g_ViewCtrl:CloseAll(g_ViewCtrl.m_LoginCloseAllNeedList)

		self.m_RoleCreateScene = CBox.New(obj)
		self.m_Camera = self.m_RoleCreateScene:NewUI(1, CCamera)
		--审核换皮包不显示创角场景
		self.m_RoleCreateScene:SetActive(not g_LoginPhoneCtrl:IsShenhePack())

		C_api.EasyTouchHandler.AddCamera(self.m_Camera.m_Camera, false)
		if self.m_RoleCreateScene then
			self:StartShowingRoleCreateScene()
		end
	end
end

function CRoleCreateScene.StartShowingRoleCreateScene(self)
	g_UploadDataCtrl:SetDotUpload("19")
	self.m_IsShowingRoleCreateScene = true
	self.m_IsShowingRoleCreateScene = false
	CRoleCreateView:ShowView(function (oView)
		oView:RefreshUI()

		local roleList = {}
		for k,v in ipairs(data.roletypedata.DATA) do
			if v.isactive == 0 then
				table.insert(roleList, v.roletype)
			end
		end
		self:ShowOneActor(table.randomvalue(roleList))
	end)
end

function CRoleCreateScene.OnDestroyScene(self)
	g_AudioCtrl:StopSolo()
	if self.m_RoleCreateScene then
		self.m_RoleCreateScene:Destroy()
		self.m_RoleCreateScene = nil
	end
	if self.m_LastShowActorModel then
		self.m_LastShowActorModel:Destroy()
		self.m_LastShowActorModel = nil
	end
	self:Clear()
	g_EffectCtrl:SetRootActive(false)
	CRoleCreateView:CloseView()
end

function CRoleCreateScene.ShowOneActor(self, roleconfigid)
	if self.m_IsShowingRoleCreateScene or self.m_IsShowingActor then
		return
	end
	if self.m_LastShowActorId and self.m_LastShowActorId == roleconfigid then
		return
	end
	g_UploadDataCtrl:SetDotUpload("20")
	printc("CRoleCreateSceneNew.ShowActorMove"..roleconfigid)
	self:OnEvent(define.Login.Event.ShowActor, -1)
	self.m_IsShowingActor = true
	self:OnEvent(define.Login.Event.ShowRoleCreateName)

	if self.m_LastShowActorId then
		printc("删除上一个角色:"..self.m_LastShowActorId)
		self:OnEvent(define.Login.Event.SelectActor, -1)
	end
	if self.m_LastShowActorModel then
		self.m_LastShowActorModel:Destroy()
		self.m_LastShowActorModel = nil
	end

	g_AudioCtrl:SoloPath("Audio/Sound/Model/"..data.roletypedata.DATA[roleconfigid].audio, nil, nil, true)
	printc("表现这个角色:"..roleconfigid)
	local oRoleCreatePlayer = CRoleCreatePlayer.New(roleconfigid)
	local model_info = {}
	model_info.shape = data.roletypedata.DATA[roleconfigid].shape
	oRoleCreatePlayer:ChangeShape(model_info, function ()
		self.m_IsShowingActor = false
		self:OnEvent(define.Login.Event.ShowRoleCreateName)
	end)
	self.m_LastShowActorModel = oRoleCreatePlayer
	self.m_LastShowActorId = roleconfigid
	-- self.m_CurRoleCreatePlayer = oRoleCreatePlayer
	self.m_CurActorRoleconfigid = roleconfigid
	
	self:OnEvent(define.Login.Event.ShowActor, 1)
	self:OnEvent(define.Login.Event.SelectActor, roleconfigid)
end

return CRoleCreateScene