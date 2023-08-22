local CMapWalker = class("CMapWalker", CWalker, CBindObjBase)

define.MapWalker = {
	Patrol_Idle_Time = 1,
	AutoPatrol_Idle_Time = 1,
	BindObjs = {
		team_leader = {hud = "CTeamHud", body="head", type="hud"},
		auto_find = {hud = "CAutoFindHud", body="head", type="hud"},
		fight = {hud = "CFightHud", body="head", type="hud"},
		taskmark = {hud = "CTaskHud", body="head", type="hud"},
		autopatrol = {hud = "CAutoPatrolHud", body="head", type="hud"},
		npctitle = {hud = "CNameHud", body="foot", type="hud"},
		npcName = {hud = "CNameHud", body="foot", type="hud"},
		npcspecialtitle = {hud = "CNpcSpecialHud", body="head", type="hud"},
        dancer = {hud = "CDanceHud", body="head", type="hud"},
        warrior_damage = {hud = "CWarriorDamageHud", body="head", type="hud"},
        wenhaomark = {hud = "CWenHaoHud", body="head", type="hud"},
        convoyTag = {hud = "CConvoyHud", body="head", type="hud"},
		footring = {path = "Effect/Scene/scene_eff_0003/Prefabs/scene_eff_0003.prefab", body = "foot", type = "effect", offset = Vector3.New(0, 0, 0), cached = true},
		warrior_cloud = {path = "Effect/Scene/scene_eff_0030/Prefabs/scene_eff_0030.prefab", body = "foot", type = "effect", offset = Vector3.New(0, 0, 0), rotate = Vector3.New(0, 120, 0), cached = true},
		water = {path = "Effect/Scene/scene_eff_0029/Prefabs/scene_eff_0029.prefab", body = "foot", type = "effect", offset = Vector3.New(0, 0, 0), rotate = Vector3.New(0, 120, 0), cached = true},
	}
}

function CMapWalker.ctor(self)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/MapWalker.prefab")
	CWalker.ctor(self, obj)
	CBindObjBase.ctor(self, obj)
	self:SetCheckInScreen(true)
	
	self.m_Name = nil
	-- 场景巡逻
	self.m_WalkerPatrolRadius = nil
	self.m_WalkerPatrolTime = 0
	self.m_WalkerPatrolTimer = nil

	--头顶间隔冒泡对话
	self.m_WalkerHeadTalk = nil
	self.m_WalkerHeadTalkTime = 4
	
	self:Init2DWalker()
	self:SetMoveSpeed()
	self:SetParent(g_MapCtrl:GetWalkerRoot().m_Transform)
	self:SetBindData(define.MapWalker.BindObjs)
	
	self.tConfigObjs = {
		collider = self:GetComponent(classtype.CapsuleCollider),
		head_trans = self.m_HeadTrans,
		waist_trans = self.m_WaistTrans,
		foot_trans = self.m_FootOrgTrans,
	}

	self.m_Actor:SetConfigObjs(self.tConfigObjs)

	self.m_TeamID = nil
	self.m_SpecailState = 0 --二进制，地图玩家部分特殊状态，参考excel/buff/state如帮派竞赛保护为01

	--hud
	self:AddInitHud("team_leader")
	self:AddInitHud("auto_find")
	self:AddInitHud("fight")
	self:AddInitHud("taskmark")
	self:AddInitHud("npctitle")
	self:AddInitHud("npcspecialtitle")
	self:AddInitHud("normal_title")
	self:AddInitHud("special_title")
	self:AddInitHud("treasure")
	self:AddInitHud("footring")
	self:AddInitHud("npcName")
    self:AddInitHud("dancer")
    self:AddInitHud("warrior_cloud")
    self:AddInitHud("water")
    self:AddInitHud("warrior_damage")
    self:AddInitHud("title")
    self:AddInitHud("convoyTag")
end

function CMapWalker.Reset(self)
	self:DelBindObj("auto_find", true)
	self:DelBindObj("water", true)
	self:DelBindObj("footring", true)
	self:DelBindObj("warrior_cloud", true)
	self:DelBindObj("taskmark", true)
	self:DelBindObj("fight", true)
	
	-- self:ClearBindObjs()

	self:DelHud("team_leader", true)
	self:DelHud("auto_find", true)
	self:DelHud("fight", true)
	self:DelHud("taskmark", true)
	self:DelHud("npctitle", true)
	self:DelHud("npcspecialtitle", true)
	self:DelHud("normal_title", true)
	self:DelHud("special_title", true)
	self:DelHud("treasure", true)
	self:DelHud("footring", true)
	self:DelHud("npcName", true)
	self:DelHud("dancer", true)
	self:DelHud("warrior_cloud", true)
	self:DelHud("water", true)
	self:DelHud("warrior_damage", true)
	self:DelHud("title", true)
	self:DelHud("chat", true)
	self:DelHud("name", true)
	self:DelHud("warname", true)
	self:DelHud("blood", true)
	self:DelHud("float_tip", true)
	self:DelHud("convoyTag", true)
	-- 停止巡逻，放在reset前，否者不能停止计时器
	self:StopWalkerPatrol()

	CWalker.Reset(self)
	self.m_Name = nil
	-- 场景巡逻
	self.m_WalkerPatrolRadius = nil
	self.m_WalkerPatrolTime = 0
	self.m_WalkerPatrolTimer = nil

	--头顶间隔冒泡对话
	self.m_WalkerHeadTalk = nil
	self:StopWalkerHeadTalk()
	self.m_WalkerHeadTalkTime = 4
	self.m_IsFight = false

	self.m_TeamID = nil
	self.m_SpecailState = 0 --二进制，地图玩家部分特殊状态，参考excel/buff/state如帮派竞赛保护为01

	self.tConfigObjs.head_trans.localPosition = Vector3.New(0,1.35,0)

	self.m_FootshadowObj:SetActive(true)

end

function CMapWalker.Destroy(self)
	self:ClearBindObjs()
	self:ResetShadowPos()
	CWalker.Destroy(self)
end

function CMapWalker.SetHeart(self, idx, bShow)
	self:SetNameHeart(idx, bShow)
end

function CMapWalker.SetName(self, name, color, namecolorindex) -- self, name, style, outlineColor, blod
	self.m_Name = name
	self:SetNameHud(name, color, namecolorindex) -- name, style, outlineColor, blod
end

function CMapWalker.SetNpcName(self, name, color, namecolorindex) -- self, name, style, outlineColor, blod
	self.m_Name = name
	self:SetNpcNameHud(name, color, namecolorindex)
	-- name, style, outlineColor, blod
end

function CMapWalker.IsCanWalk(self)
	return g_MapCtrl.m_CurMapObj and not self.m_IsFollowing
end

function CMapWalker.StopWalk(self)
	if self.m_IsFlyWaterProgress then
		return
	end
	CWalker.StopWalk(self)
	self:DelBindObj("auto_find")
end

function CMapWalker.OnStopPath(self)
	CWalker.OnStopPath(self)
	self:DelBindObj("auto_find")
end

function CMapWalker.Trigger(self)
	self:FaceToHero()
end

function CMapWalker.FaceToHero(self)
	local hero = g_MapCtrl:GetHero()
	if hero then
		if self.m_GameObject == hero.m_GameObject then
			return
		end
		local function lookat(walker, form, to)
			local dir = form:GetPos() - to:GetPos()
			if dir.x == dir.y and dir.x == 0 then
				return
			end
			local rotation = Quaternion.LookRotation(Vector3.New(dir.x, 0.0001, dir.y))
			-- walker.m_Actor:SetLocalRotation(rotation)
			DOTween.DOLocalRotate(walker.m_Actor.m_Transform, rotation.eulerAngles, 0.2)
			-- walker.m_Actor:LookAt(form, to)
			-- local worldDir = walker:GetUp().normalized
			-- local localDir = to.normalized
			-- local angle = Vector3.Angle(worldDir, localDir)
			-- if localDir.x < 0 then
			-- 	angle = angle * -1
			-- end
			-- walker.m_Actor:SetLocalEulerAngles(Vector3.New(0, walker.m_Actor:GetLocalEulerAngles().y, walker.m_Actor:GetLocalEulerAngles().z))
		end
		-- lookat(self, hero.m_Actor:GetPos(), self.m_Actor:GetUp())
		-- lookat(hero, self.m_Actor:GetPos(), hero.m_Actor:GetUp())
		local turnface = self.classname ~= "CDynamicNpc" or (self.m_ClientNpc and (self.m_ClientNpc.no_turnface == 0 or self.m_ClientNpc.no_turnface == nil))
		if turnface then
			if not g_MapCtrl:IsFuyuanNpc(self) and not g_MapCtrl:IsLuanShiMoYingNpc(self) then 
				lookat(self, hero, self)
			end 
		end
		lookat(hero, self, hero)
	end
end

function CMapWalker.ResetHudNode(self)
	--	默认是和脚底是一致的
	-- 如果有坐骑，按坐骑的
	-- 没有坐骑，按主模型的
	local infoidx = nil
	if self.m_Actor.m_HasHorse then
		infoidx = self.m_Actor.m_RideShape
	else
		infoidx = self.m_Actor.m_Shape
	end
	if infoidx then
		local hudinfo = ModelTools.GetModelHudInfo(infoidx)
		self.m_FootTrans.localPosition = Vector3.New(self.m_FootTrans.localPosition.x, hudinfo.foot_node_offset, self.m_FootTrans.localPosition.z)
	end
	self.m_FootshadowObj:SetActive(true)
end

function CMapWalker.GetFootNodeOffset(self)

	local infoidx = nil
	if self.m_Actor.m_HasHorse then
		infoidx = self.m_Actor.m_RideShape
	else
		infoidx = self.m_Actor.m_Shape
	end
	if infoidx then
		local hudinfo = ModelTools.GetModelHudInfo(infoidx)
		return hudinfo.foot_node_offset
	end

end

function CMapWalker.SetWarTag(self, iWarTag)
	self.m_IsFight = iWarTag == 1
	if self.m_IsFight then
		self:AddBindObj("fight")
	else
		self:DelBindObj("fight")
	end
end

function CMapWalker.SetTaskMark(self, spriteName)
	if spriteName then
		self:AddHud("taskmark", CTaskHud, self.m_HudNode.m_HeadHudTable, function(oHud)
			oHud:SetTaskMark(spriteName)
		end, false)
	else
		self:DelBindObj("taskmark")
	end
end

function CMapWalker.SetWenHaoMark(self, mark)
	
	if mark then 
		self:AddHud("wenhaomark", CWenHaoHud, self.m_HudNode.m_HeadHudTable, function(oHud)
			oHud:SetWenHaoMark()
		end, false)
	else
		self:DelBindObj("wenhaomark")
	end 

end

function CMapWalker.SetWearingTitle(self, pid, titleInfo)
    -- printc("CMapWalker.SetWearingTitleHud, pid = " .. tostring(pid) .. ", titleInfo = ")
    local tid = nil
    local name = nil
    local type = nil

    -- 参数的四种情况：
    --     pid == nil  我的称谓
    --         titleInfo == nil  正常，逻辑判断显示/不显示
    --         titleInfo         异常，传参不会有这种情况
    --     pid         其他人的称谓
    --         titleInfo == nil  显示当前佩戴的（GS2CSyncAoi 没有新的 title_info 数据，所以为 titleInfo == nil）
    --         titleInfo 有元素  显示
    --         titleInfo 无元素  不显示

    if pid == nil then
        -- 我的称谓
        if titleInfo then
           -- 异常，传参不会有这种情况
            self:ClearAllTitleHuds(true)
            return
        end
        if g_TitleCtrl:IsWearingATitle() then
            -- 我显示称谓
            tid = g_TitleCtrl.m_WearingTitleId
            local title = g_TitleCtrl:GetTitle(tid)
            name = title and title.name
            type = g_TitleCtrl:GetTitleType(tid)
        else
            -- 我不显示称谓
            self:ClearAllTitleHuds(true)
            return
        end
    else
        -- 其他人的称谓
        if titleInfo then
            if next(titleInfo) then
                -- table 有元素，其他人显示称谓
                tid = titleInfo.tid
                name = titleInfo.name
                type = g_TitleCtrl:GetTitleType(tid)
            else
                -- table 无元素，其他人不显示称谓
                self:ClearAllTitleHuds(true)
                return
            end
        else
            -- 其他人称谓状态不变（GS2CSyncAoi 没有新的称谓数据，就会传 nil 进来）
            return
        end
    end

    if tid == nil or name == nil or type == nil then
        return
    end

    -- 显示称谓
    self:ClearAllTitleHuds(true)
    if type == g_TitleCtrl.TYPE_NORMAL then
        self:SetNormalTitleHud(tid, name)
    elseif type == g_TitleCtrl.TYPE_SPECIAL then
        self:SetSpecialTitleHud(tid)
    end
end

function CMapWalker.ClearAllTitleHuds(self, bNoRepos)
    self:DelHud("normal_title", bNoRepos)
    self:DelHud("special_title", bNoRepos)
end

-- 普通称谓 HUD
function CMapWalker.SetNormalTitleHud(self, tid, name)
    self:AddHud("normal_title", CNormalTitleHud, self.m_HudNode.m_FootHudTable, function(oHud)
    	oHud:SetName(tid, name)
    end, false)
end

-- 特殊称谓 HUD
function CMapWalker.SetSpecialTitleHud(self, tid)
    self:AddHud("special_title", CSpecialTitleHud, self.m_HudNode.m_HeadHudTable, function(oHud)
        oHud:SetSpriteName(tid)
    end, false)
end

-- NPC 普通称号 HUD
function CMapWalker.SetNpcNormalHUD(self, name)
	local dData = data.namecolordata.TITLEDATA[define.RoleTitle.NPCNomTitle]
	self:AddHud("npctitle", CNameHud, self.m_HudNode.m_FootHudTable, function(oHud)
		oHud:SetName(name, nil, dData)
		-- oHud.m_NameLabel:SetEffectColor(Color.RGBAToColor(dData.style_color))
	end, false)
end

-- NPC 特殊称号 HUD
function CMapWalker.SetNpcSpecialHud(self, title, spriteName)
    if (title and string.len(title) > 0) or (spriteName and string.len(spriteName)) then
        self:AddHud("npcspecialtitle", CNpcSpecialHud, self.m_HudNode.m_HeadHudTable, function(oHud)
            oHud:SetNpcSpecialHud(title, spriteName)
        end, false)
    else
        self:DelHud("npcspecialtitle")
    end 
end

-- 宝图罗盘 HUD
function CMapWalker.ShowTreasureHud(self)
	self:DelHud("treasure")
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil			
	end

	self:AddHud("treasure", CTreasureHud, self.m_HudNode.m_HeadHudTable, function(oHud)
		self.m_HudNode.m_HeadHudTable:RepositionLater()
	end, false)
	local function progress()
		self:DelHud("treasure")
		if self.m_Timer then
			Utils.DelTimer(self.m_Timer)
			self.m_Timer = nil			
		end
		return false
	end
	self.m_Timer = Utils.AddTimer(progress, 0, 2)	
end

-- 点击mapwalker特效
function CMapWalker.ShowFootRing(self, show)
	if show then
		self:AddBindObj("footring", function (effect)
			effect:SetLocalRotation(Quaternion.Euler(30,0,0))
		end)
	else
		self:DelBindObj("footring")
	end
end

--是否显示脚底云的特效
function CMapWalker.ShowCloudEffect(self, show)
	if show then
		self:AddBindObjInActorNode("warrior_cloud", function (effect)
			local sublist = effect.m_GameObject:GetComponentsInChildren(classtype.ParticleSystem)
			for i = 0, sublist.Length-1 do
				sublist[i].gameObject:GetComponent(classtype.Renderer).sortingOrder = 1
			end
			effect:SetLocalRotation(Quaternion.Euler(0,0,0))
		end, self.m_Actor.m_Transform)
	else
		self:DelBindObj("warrior_cloud")
	end
end

--是否显示脚底踩水的特效
function CMapWalker.ShowWaterEffect(self, show)
	if show then
		self:AddBindObjInActorNode("water", function (effect)
			effect:SetLocalRotation(Quaternion.Euler(0,0,0))
		end, self.m_Actor.m_Transform)
	else
		self:DelBindObj("water")
	end
end

function CMapWalker.ShowDamage(self, damage, iscrit, isDance)
	self:AddHud("warrior_damage", CWarriorDamageHud, self.m_HudNode.m_HeadHudTable, function(oHud) oHud:ShowDamage(damage, iscrit, isDance) end, true)
end

function CMapWalker.MapFadeEffect(self, show, cb)
	if show then
		self.m_HudNode:SetPosHide(true)
		self:SetActive(false)
		local path = "Effect/Scene/scene_eff_0004/Prefabs/scene_eff_0004.prefab"
		local oEffect = CEffect.New(path, UnityEngine.LayerMask.NameToLayer("MapTerrain"), true)
		oEffect:SetPos(self:GetPos())
		local function timeup()
			self.m_MapSwitchEffect = nil
			if cb then cb() end
			if Utils.IsNil(oEffect) then
				return false
			end
			oEffect:Destroy()
		end
		Utils.AddTimer(timeup, 0, 0.8)
		self.m_MapSwitchEffect = oEffect
	elseif self.m_MapSwitchEffect and self.m_MapSwitchEffect:GetActive() then
		oEffect:Destroy()
		self.m_MapSwitchEffect = nil
	end
end

-- 地图Walker自动巡逻
function CMapWalker.IsWalkerPatroling(self)
	return (self.m_WalkerPatrolRadius and self.m_WalkerPatrolRadius > 0) or self.m_HasShowClip
end

function CMapWalker.GetRandomPatrolRadius(self)
	if self.m_WalkerPatrolRadius and self.m_WalkerPatrolRadius > 0 then
		return Mathf.Random(-self.m_WalkerPatrolRadius, self.m_WalkerPatrolRadius)
	end
	return 0
end

function CMapWalker.StartWalkerPatrol(self)
	-- printerror("---------CMapWalker.StartWalkerPatrol")
	if not self.m_IsUsing then
		return
	end
	if self:IsWalkerPatroling() then
		self:StopWalk()
		self.m_WalkerPatrolTime = nil
		if not self.m_WalkerPatrolTimer then
			self.m_WalkerPatrolTimer = Utils.AddTimer(callback(self, "CheckWalkerPatrol"), 0.2, 0.2)
		end
	end
end

function CMapWalker.StopWalkerPatrol(self)
	if self:IsWalkerPatroling() then
		if self.m_WalkerPatrolTimer then
			Utils.DelTimer(self.m_WalkerPatrolTimer)
			self.m_WalkerPatrolTimer = nil
		end
	end
end

function CMapWalker.CheckWalkerPatrol(self, dt)
	-- printerror("--------------------CMapWalker.CheckWalkerPatrol")
	if not self:IsWalkerPatroling() then
		self:StopWalkerPatrol()
		return false
	end
	if self.m_WalkerPatrolTime then
		self.m_WalkerPatrolTime = self.m_WalkerPatrolTime - dt
		if self.m_WalkerPatrolTime <= 0 then
			self:WalkerPatrolNext()
		end
	else
		self:WalkerPatrolNext()
	end
	return true
end

function CMapWalker.WalkerPatrolNext(self)
	-- printc("====== CWalker.WalkerPatrolNext -->> self:StopWalkerPatrol() ======", self:GetName())
	self:StopWalkerPatrol()
end

--头顶冒泡对话相关

function CMapWalker.StartWalkerHeadTalk(self)
	if self.m_WalkerHeadTalk then
		if not self.m_WalkerHeadTalkTimer then
			self.m_WalkerHeadTalkTimer = Utils.AddTimer(callback(self, "CheckWalkerHeadTalk"), self.m_WalkerHeadTalkTime, Mathf.Random(1, self.m_WalkerHeadTalkTime))
		end
	end
end

function CMapWalker.StopWalkerHeadTalk(self)
	if self.m_WalkerHeadTalk then
		if self.m_WalkerHeadTalkTimer then
			Utils.DelTimer(self.m_WalkerHeadTalkTimer)
			self.m_WalkerHeadTalkTimer = nil
		end
	end
end

function CMapWalker.CheckWalkerHeadTalk(self)
	if not self.m_WalkerHeadTalk then
		self:StopWalkerHeadTalk()
		return false
	end
	self:WalkerHeadTalkNext()
	return true
end

function CMapWalker.WalkerHeadTalkNext(self)
	self:StopWalkerHeadTalk()
end


--修改影子位置
function CMapWalker.ChangeShadowPos(self, shape)
    local changePos = function ()
    	if Utils.IsNil(self) then
    		return false
    	end
        self.m_FootshadowObj:SetParent(self.m_Actor.m_Transform:Find("model"..shape.."(Clone)/Bip001/Bip001 Footsteps"))
    	self.m_FootshadowObj:SetLocalPos(Vector3.zero)
    	return false
    end
    Utils.AddTimer(changePos, 0.1, 1)
end

--重置影子位置
function CMapWalker.ResetShadowPos(self)
    self.m_FootshadowObj:SetParent(self.m_Transform)
    self.m_FootshadowObj:SetLocalRotation(Quaternion.identity)
    self.m_FootshadowObj:SetLocalPos(Vector3.New(0,-0.6,1))
    return false
end

--需位运算
function CMapWalker.SetSpecailState(self, state)
	self.m_SpecailState = state ~= nil and state or 0
end

function CMapWalker.GetSpecailState(self, state)
	if not self.m_SpecailState then
		return false
	end
	return MathBit.andOp(MathBit.rShiftOp(self.m_SpecailState, state),1) == 1
end

function CMapWalker.SetUsing(self, isUsing)
	CWalker.SetUsing(self, isUsing)
    CBindObjBase.SetUsing(self, isUsing)
	if isUsing then
		self:SetCheckInScreen(true)
	end
end

function CMapWalker.ChangeInScreenCb(self, bInScreen)
    CWalker.ChangeInScreenCb(self, bInScreen)
    self.m_HudNode:SetPosHide(not bInScreen)
    self.m_IsCacheHudData = not bInScreen
    if bInScreen then
        self.CheckCacheHuds(self)
    end
end

return CMapWalker