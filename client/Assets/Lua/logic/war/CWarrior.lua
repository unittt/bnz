local CWarrior = class("CWarrior", CObject, CBindObjBase)
define.Warrior = {
	Event_BeginHit = 1,
	Event_Hurt = 2,
	Event_EndHit = 3,
	Run_Speed = 20,
	BindObjs = {
		warrior_replace = {hud = "CWarriorReplaceHud", body = "head", type = "hud"},
		warrior_order = {hud = "CWarriorOrderHud", body = "head_sub", type = "hud"},
		warrior_select = {hud = "CWarriorSelectHud", body = "waist_sub", type = "hud"},
		warrior_longpress = {path = "Effect/UI/ui_eff_0054/Prefabs/ui_eff_0054.prefab", body = "head", type = "effect", offset = Vector3.New(0, 0.5, 0), cached = true},
		warrior_cloud = {path = "Effect/Scene/scene_eff_0023/Prefabs/scene_eff_0023.prefab", body = "foot", type = "effect", offset = Vector3.New(0, 0.25, 0), cached = true},
		warrior_addHp = {path = "Effect/Magic/skill_eff_157_hit/Prefabs/skill_eff_157_hit.prefab", body = "foot", type = "effect", offset = Vector3.New(0, 0.25, 0), cached = true},
		warrior_addMp = {path = "Effect/Magic/skill_eff_158_hit/Prefabs/skill_eff_158_hit.prefab", body = "foot", type = "effect", offset = Vector3.New(0, 0.25, 0), cached = true},
		warrior_relive = {path = "Effect/Magic/skill_eff_159_hit/Prefabs/skill_eff_159_hit.prefab", body = "foot", type = "effect", offset = Vector3.New(0, 0.25, 0), cached = true},
		warrior_statu_5703 = {path = "Effect/Buff/buff_eff_10038_waist/Prefabs/buff_eff_10038_waist.prefab", body = "foot", type = "effect", offset = Vector3.New(0, 0.3, 0), cached = true},
	},
	Type = {
		Player = 1,
		Npc = 2,
		Summon = 3,
		Partner = 4,
		RoPlayer = 5, --机器人重新定义类型
		RoPartner = 6,
		RoSummon = 7,
	},
	MagicType = {
		NPC = "npc",
		Partner = "partner",
		School = "school",
		Se = "se",
		Summon = "summon",
	},
	--特殊buff，非buff文件控制，手动实现
	SpecialBuff = {
		[130] = true,	--遁法 buff
		[132] = true,	--剑遁 buff
		[166] = true,	--隐身 buff
		[240] = true,	--超级隐身 buff
	},
	SnakeBuff = {
	--TODO:晃动效果待优化，屏蔽
		-- [117] = true, --眩晕抖动
		-- [213] = true,
	},
	UseItemEffectDic = {
		-- 加血
		["1001"] = "Skill_eff_157_hit",
		-- 加蓝
		["1002"] = "Skill_eff_158_hit",
		-- 抓宠
		["1003"] = "Skill_eff_157_hit",
		-- 怒气
		["1004"] = "Skill_eff_156_hit",
		-- 复活，加血
		["1005"] = "Skill_eff_159_hit",
		-- 加怒，降防
		["1006"] = "Skill_eff_156_hit",
	},
}
CWarrior.g_TestActorID = nil

function CWarrior.ctor(self, wid)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/Warrior.prefab")
	CObject.ctor(self, obj)
	CDelayCallBase.ctor(self, obj)
	CBindObjBase.ctor(self, obj)
	self:SetBindData(define.Warrior.BindObjs)
	self.m_RotateObj = CObject.New(self:Find("rotate_node").gameObject)
	self.m_ID = wid --战士ID
	self.m_Pid = nil
	self.m_CampID = nil
	self.m_CampPos = nil
	self.m_OwnerWid = nil
	self.m_Type = nil --战士类型
	self.m_IsAlly = nil
	self.m_SummonID = nil
	self.m_EventState = {}
	self.m_BusyFlags = {}
	self.m_BoutVary = {} -- 当前回合状态的改变
	self.m_OriginPos = Vector3.zero
	self.m_Status = {}
	self.m_arge_5703 = 0
	self.m_arge_5704 = 0
	self.m_Buffs = {}
	self.m_StatuBuffs = {}
	self.m_MagicCD = {}
	self.m_IsAlive = true
	self.m_IsOrderTarget = false
	self.m_MagicList = {}
	self.m_IsOrderDone = false
	self.m_FloatAtkID = nil
	self.m_IsJiHuo = false
	self.m_CheckErrBout = nil
	self.m_IsCanTouch = true
	self.m_TeamCmd = nil  --队伍战斗指挥
	self.m_PlayingDelAni = false
	self.m_ModelInfo = nil
	self.m_SpecialId = nil
	self.m_HitInfo = {timer=nil, stand=0, step=0, goback = false, begin_pos=nil}
	self.m_Actor = CActor.New()
	self.m_Actor:SetParent(self.m_RotateObj.m_Transform, false)
	self.m_Actor:SetLayer(self:GetLayer(), true)
	self.m_Actor:SetDefaultState("idleWar")
	self.m_ModelDone = false    --模型是否已经创建完毕
	self.m_PfCd = {}	--技能cd信息
	self.m_BuffAttr = {} --记录buff导致的属性改变
	self.m_BuffEffList = {}
	self.m_AttrBuffList = CWarriorAttrBuffList.New(self)
	local tConfigObjs = {
		size_obj = self,
		collider = self:GetComponent(classtype.CapsuleCollider),
		head_trans = self.m_HeadTrans,
		waist_trans = self.m_WaistTrans,
		foot_trans = self.m_FootOrgTrans,
	}
	self.m_Actor:SetConfigObjs(tConfigObjs)
	self.m_PlayMagicID = nil
	self.m_DieDelay = nil
	-- self:AddInitHud("warrior_replace")
	-- self:AddInitHud("warrior_order")
	-- self:AddInitHud("warrior_select")
	-- self:AddInitHud("warrior_damage")
	-- self:AddInitHud("warrior_buff")
	-- self:AddInitHud("warrior_passive")
	-- self:AddInitHud("warrior_cloud")
	-- self:AddInitHud("warrior_teamCmd")
	-- self:AddInitHud("warrior_magicPoint")
	-- self:AddInitHud("warrior_longpress")
	-- if wid == 1 then
	-- 	CWarrior.g_TestActorID = self.m_Actor:GetInstanceID()
	-- end

	-- if not self:IsAlly() then
		self:AddInitHud("lv_school")
		self.m_NeedLvSchHud = true
	-- end

	if g_WarCtrl:IsWarSky() then
		self:AddBindObj("warrior_cloud", function (effect)
			effect:SetLocalRotation(Quaternion.Euler(0,90,0))

			-- 敌方单位云层下降-0.35
			if self.m_CampID ~= g_WarCtrl:GetAllyCamp() then
				effect:SetLocalPos(Vector3.New(0, -0.35, 0))
			end
		end)
	end

	self.m_FloatHitInfo = {down_timer=nil, restore_timer=nil,first_atkid = nil,atkids ={},record = false, last_atk_id=nil}
end

function CWarrior.SetBodyMatColor(self, color)
	self.m_Actor:SetBodyMatColor(color)
	if color.a == 0 then
		Utils.HideObject(self)
	else
		Utils.ShowObject(self)
	end
end

function CWarrior.ShowWingEffect(self, isShow)
	
	self.m_Actor:ShowWingEffect(isShow)

end

function CWarrior.ShowWeaponEffect(self, isShow)
	
	local lv = isShow and define.Performance.Level.high or 0
	self.m_Actor:ShowWeaponEffect(lv)

end

function CWarrior.SetWeaponMatColor(self, color)
	self.m_Actor:SetWeaponMatColor(color)
end

function CWarrior.GetMatColor(self)
	return self.m_Actor.m_BodyMatColor
end

function CWarrior.ShowReplaceActor(self)
	local function black()
		if Utils.IsNil(self) then
			return
		end
		g_WarCtrl:WarriorStatusChange(self.m_ID)
		self:SetLayer(self.m_GameObject.layer, true)
		self:CrossFade(self:GetState())
		self:SetBodyMatColor(Color.black*0.9)
	end
	self.m_Actor:ChangeShape({shape=1110})
end

function CWarrior.SetFirstFloatAtkID(self, id)
	self.m_FloatHitInfo.first_atkid = id
end

function CWarrior.SetTouchEnabled(self, b)
	self.m_IsCanTouch = b
end

function CWarrior.GetTouchEnabled(self)
	return self.m_IsCanTouch
end

function CWarrior.AddFloatAtkId(self, atkid, cnt)
	self.m_FloatHitInfo.record  = true
	self.m_FloatHitInfo.atkids[atkid] = cnt
	self.m_FloatHitInfo.last_atk_id = atkid
end

function CWarrior.SetLastFloatAtkId(self, atkid, vicids)
	if table.index(vicids, self.m_ID) ~= nil then
		self.m_FloatHitInfo.last_atk_id = atkid
	end
end

function CWarrior.SubFloatAtkId(self, atkid)
	local iCnt = self.m_FloatHitInfo.atkids[atkid]
	if iCnt and iCnt > 0 then 
		self.m_FloatHitInfo.atkids[atkid] = iCnt - 1
	else
		self.m_FloatHitInfo.atkids[atkid] = nil
	end
end

function CWarrior.IsFloatAtkID(self, id)
	return (self.m_FloatHitInfo.record and
	self.m_FloatHitInfo.atkids[id] ~= nil and 
	self.m_FloatHitInfo.atkids[id] > 0)
end

function CWarrior.SetPlayMagicID(self, i)
	self.m_PlayMagicID = i
end

function CWarrior.GetModelBindTrans(self, idx)
	local oModel = self.m_Actor:GetMainModel()
	if oModel then
		return oModel:GetContainTransform(idx)
	end
end

function CWarrior.SetOrderDone(self, bDone)
	if g_WarCtrl:IsPlayRecord() then
		return
	end
	if bDone or self.m_Type == define.Warrior.Type.Partner or self.m_Type == define.Warrior.Type.Npc or self.m_Type == define.Warrior.Type.RoPartner then
		self:DelBindObj("warrior_order")
	else
		self:AddBindObj("warrior_order")
	end
	self.m_IsOrderDone = bDone
end

function CWarrior.IsOrderDone(self)
	return self.m_IsOrderDone
end

function CWarrior.ShowDamage(self, damage, iscrit, hitTrick)
	-- printc("========= 开始显示掉血", self:GetName())
	--[[
	if g_WarCtrl:GetWarType() == define.War.Type.Boss then
		if not self:IsAlly() and self.m_CampPos == 1 then
			local dInfo = g_ActivityCtrl:GetWolrdBossInfo()
			if dInfo and dInfo.hp_max ~= 0 then
				g_ActivityCtrl:RefreshBossHP(dInfo.hp+damage, dInfo.hp_max)
			end
		end
	end
	]]--
	if damage > 0 then
		self:AddBindObj("warrior_addHp")
		self:DelBindObjLater(1, "warrior_addHp")
	elseif hitTrick ~= false then
		local config = ModelTools.GetModelConfig(self.m_Actor.m_Shape)
		if config and config.hit_trick and config.hit_trick ~= "" then
			local path = DataTools.GetAudioSound(config.hit_trick)
			g_AudioCtrl:PlayEffect(path, true, true)
		end
	end
	self:AddHud("warrior_damage", CWarriorDamageHud, self.m_HudNode.m_HeadHudTable, function(oHud) oHud:ShowDamage(damage, iscrit) end, true)
end

function CWarrior.ShowMpChange(self, mp)
	if mp > 0 then
		self:AddBindObj("warrior_addMp")
		self:DelBindObjLater(1.2, "warrior_addMp")
	end
	self:AddHud("warrior_magicPoint", CWarriorMagicPointHud, self.m_HudNode.m_HeadHudTable, function(oHud) oHud:ShowMagicPoint(mp) end, true)
end

function CWarrior.GetLocalForward(self)
	return g_WarCtrl:GetRoot():InverseTransformDirection(self.m_RotateObj:GetForward())
end

function CWarrior.GetLocalUp(self)
	return g_WarCtrl:GetRoot():InverseTransformDirection(self.m_RotateObj:GetUp())
end

function CWarrior.RefreshBuff(self, buffid, bout, level, bTips, attrlist)
	local dBuffInfo = self.m_Buffs[buffid]
	local bDeleteBuff = bout <= 0 or (level or 0) <= 0
	-- printc("RefreshBuff")
	-- table.print(dBuffInfo)
	if dBuffInfo then
		if bDeleteBuff then
			if dBuffInfo.obj then
				dBuffInfo.obj:Clear()
			end
			dBuffInfo = nil
			self:ProcessSpecailBuff(buffid, false)
		else
			dBuffInfo.bout = bout
			dBuffInfo.level = level
			dBuffInfo.attrlist = attrlist
		end
	elseif not bDeleteBuff then
		local obj = CWarBuff.New(buffid, self)
		dBuffInfo = {
			obj = obj,
			bout = bout,
			level = level,
			buff_id = buffid,
			attrlist = attrlist or {}
		}
		self:ProcessSpecailBuff(buffid, true)
	end
	if dBuffInfo and dBuffInfo.obj then
		dBuffInfo.obj:SetLevel(level)
	end
	self.m_Buffs[buffid] = dBuffInfo
	self:AddHud("warrior_buff", CWarriorBuffHud, self.m_HudNode.m_HeadHudTable, function(oHud) 
		oHud:RefreshBuff(buffid, bout, level, bTips)
	end, true)
	local oView = CWarTargetDetailView:GetView()
	if oView and oView:GetWarrior() == self then
		oView:RefreshBuffTable()
	end
	self:UpdateAttrBuff()
end

function CWarrior.SetJihuoTag(self, b)
	self.m_IsJiHuo = b
	self:AddHud("warrior_buff", CWarriorBuffHud, self.m_HeadTrans, function(oHud)
		oHud:SetJiHuo(b)
	end, true)
end

function CWarrior.IsJiHuo(self)
	return self.m_IsJiHuo
end

function CWarrior.ProcessSpecailBuff(self, buffid, bAdd)
	if define.Warrior.SpecialBuff[buffid] then
		-- 隐身
		if bAdd then
			local color = self:GetMatColor()
			color.a = 0.5
			if self.m_ModelDone then 
				self:SetBodyMatColor(color)
				self:SetWeaponMatColor(color)
			else
				self.m_Actor:FunCallLater(callback(self, "SetBodyMatColor", color))
				self.m_Actor:FunCallLater(callback(self, "SetWeaponMatColor", color))
			end 
		
	  	else
	  		local color = self:GetMatColor()
			color.a = 1
			if self.m_ModelDone then 
				self:SetBodyMatColor(color)
				self:SetWeaponMatColor(color)
			else
				self.m_Actor:FunCallLater(callback(self, "SetBodyMatColor", color))
				self.m_Actor:FunCallLater(callback(self, "SetWeaponMatColor", color))
			end 
	  	end
	end
	if define.Warrior.SnakeBuff[buffid] and bAdd then
		local oAction = CShakePosition.New(self, 0.5, 0.05, 0.03, 0.05)
		g_ActionCtrl:AddAction(oAction)
	end
end

function CWarrior.ProcessBuffBeforeHit(self, dVary)
	if dVary.buff_list and next(dVary.buff_list) then
		for i, oCmd in ipairs(dVary.buff_list) do
			oCmd:Excute()
		end
		dVary.buff_list = {}
	end
end

function CWarrior.Bout(self)
	self:RefreshArge()
	self:BuffBout()
	self:MagicCDBout()
	self.m_FloatHitInfo.first_atkid = nil
	self.m_FloatHitInfo.atkids = {}
	self.m_FloatHitInfo.record = false
	self.m_FloatHitInfo.last_atk_id = nil

	self:CheckError()
	-- self:CheckPerformCDs()
end

function CWarrior.RefreshArge(self)
	self:RefreshBlood()
end

function CWarrior.CheckError(self) -- 防止没归位或死亡没倒地
	local iBout = g_WarCtrl:GetBout()
	if self.m_CheckErrBout ~= iBout then
		self.m_CheckErrBout = iBout
		-- self:SetLocalPos(self.m_OriginPos)
		if Utils.IsExist(self) and Utils.IsExist(self.m_RotateObj) then
			local dis = WarTools.GetHorizontalDis(self:GetPos(), self.m_OriginPos)
			if dis > 0.2 then
				print("CheckError 归位,", dis)
				local c = self.m_Actor:GetMatColor()
				local function show()
					if Utils.IsExist(self) then
						if self:IsAlive() then
							self:SetLocalPos(self.m_OriginPos)
						end
						local oShowAction = CActionColor.New(self.m_Actor, 0.25,  "SetMatColor", Color.New(c.r, c.g, c.b, 0), c)
						g_ActionCtrl:AddAction(oShowAction)
					end
				end
				local oHideAction = CActionColor.New(self.m_Actor, 0.25,  "SetMatColor", Color.New(c.r, c.g, c.b, c.a * 0.5), Color.New(c.r, c.g, c.b, 0))
				oHideAction:SetEndCallback(show)
				g_ActionCtrl:AddAction(oHideAction)
			end
			self.m_RotateObj:SetLocalPos(Vector3.zero)
			self:FaceDefault()
		else
			printc("警告：异常 -> CWarrior.CheckError")
		end
	end
end

function CWarrior.BuffBout(self)
	for id, dBuffInfo in pairs(self.m_Buffs) do
		local dData = data.buffdata.DATA[id]
		if dData then
		-- 判断回合末减buff还是攻击后减buff
		-- and dData.sub_type == define.War.Buff_Sub.BoutEnd then
			self:RefreshBuff(id, dBuffInfo.bout - 1, dBuffInfo.level, false, dBuffInfo.attrlist)
		end
	end
end

function CWarrior.MagicCDBout(self)
	for id, bout in pairs(self.m_MagicCD) do
		local newbout = self.m_MagicCD[id] - 1
		self.m_MagicCD[id] = newbout<=0 and nil or newbout
	end
end

function CWarrior.SetMagicCD(self, magid, bout)
	self.m_MagicCD[magid] = bout
end

function CWarrior.GetMagicCD(self, magid)
	local cd = self.m_MagicCD[magid] or 0
	return cd
end

function CWarrior.ClearBuff(self)
	for id, dBuffInfo in pairs(self.m_Buffs) do
		self:RefreshBuff(id, 0, dBuffInfo.level)
	end
	self.m_Buffs = {}
	self:UpdateAttrBuff()
end

function CWarrior.GetBuffList(self)
	return table.dict2list(self.m_Buffs, "buff_id")
end

function CWarrior.SetAlive(self, bAlive)
	if self:IsAlive() ~= bAlive then
		self.m_IsAlive = bAlive
		if Utils.IsNil(self) then
			return
		end
		if bAlive then
			self:Relive()
		else
			self:Die()
		end
	end
end

function CWarrior.IsNearOriPos(self, pos)
	return WarTools.GetHorizontalDis(pos, self.m_OriginPos) < 0.05
end

function CWarrior.Relive(self)
	self:AddBindObj("warrior_relive")
	self:DelBindObjLater(1.2, "warrior_relive")
	self:CrossFade("idleWar", 0.3)
	self:FaceDefault()
	self.m_BloodPercent = nil
	self:RefreshBlood(nil, true)
	if not self:IsNearOriPos(self:GetPos()) then
		self:GoBack()
		g_WarCtrl:InsertAction(CWarCmd.WaitOne, self, "IsBusy", false)
	end
end

function CWarrior.SetBlood(self, percent, aura, rage, bIsRelive, bIsDie)
	-- printc("SetBlood", self:GetName())
	-- if self.m_BloodPercent == percent then
	-- 	return
	-- end
	-- self.m_BloodPercent = percent
	if self:IsAlive() or bIsDie then
		local trans = self:GetBindTable("head")
		self:AddHud("blood", CBloodHud, trans, function(oHud)
			oHud:SetHP(percent, bIsRelive)
			oHud:SetLinqi(aura)
			oHud:SetRage(rage)
		end, false)
	end
end

function CWarrior.Die(self, iNormaized)
	local sState = self:GetState()
	if sState ~= "die" then
		-- self:SetLocalPos(self.m_OriginPos)
		iNormaized = iNormaized or 0
		self:Play("die", iNormaized)
		-- 死亡后移除hit\defend状态
		local status = {"hit", "defend"}
		for _,v in ipairs(status) do
			self:SetBusy(false, v)
		end
	end
	self:DelBindObj("blood")
	local angle = self:GetDefalutRotateAngle()
	self.m_RotateObj:SetLocalEulerAngles(angle)
end

function CWarrior.UpdateOriginPos(self)
	local pos = g_WarCtrl:GetLinupPos(self:IsAlly(), self.m_CampPos)
	if g_WarCtrl:IsBossWarType() and not self:IsAlly() then
		pos = g_WarCtrl:GetBossLinupPos(self.m_CampPos)
	end
	self.m_OriginPos = pos
	self:SetLocalPos(pos)
	self.m_Actor:SetLocalPos(Vector3.zero)
	self:FaceDefault()

	self.m_Actor:SetFixedPos(pos)
	local angle = self:GetDefalutRotateAngle()
	g_MagicCtrl.m_CalcPosObject:SetParent(self.m_Transform, false)
	g_MagicCtrl.m_CalcPosObject:SetLocalPos(Vector3.zero)
	g_MagicCtrl.m_CalcPosObject:SetLocalEulerAngles(angle)
	self.m_Actor:SetDefaultAnlge(g_MagicCtrl.m_CalcPosObject:GetEulerAngles())
	-- self.m_Actor:UpdateSubModels()
	g_MagicCtrl:ResetCalcPosObject()
end

function CWarrior.SetStatus(self, dStatus)
	self.m_Status = dStatus
	-- self:UpdateAutoMagic()
	self:RefreshBlood()
	self:RefreshTitle(dStatus.title)
	g_WarCtrl:WarriorStatusChange(self.m_ID)
end

function CWarrior.SetStatusBuff(self, dStatusBuff)
	self.m_StatusBuff = dStatusBuff
	g_WarCtrl:WarriorStatusBuffChange(self.m_ID)
end

function CWarrior.UpdateAutoMagic(self)
	if self.m_ID == g_WarCtrl.m_HeroWid or self.m_ID == g_WarCtrl.m_SummonWid then
		g_WarCtrl:SetAutoMagic(self.m_Status.auto_perform, self.m_ID == g_WarCtrl.m_HeroWid)
	end
end

function CWarrior.UpdateStatus(self, dVary)
	local bChange = false
	for k, v in pairs(self.m_Status) do
		local new = dVary[k]
		if new and v ~= new then
			self.m_Status[k] = new
			if k == "auto_perform" then
				self:UpdateAutoMagic()
			elseif k == "cmd" and new == 1 then
				self:SetOrderDone(true)
			else
				bChange = true
			end
			if k == "zhenqi" then
				g_WarCtrl:OnEvent(define.War.Event.UpdateZhenQi)
			end
		end
	end
	local bIsChangeHp = self:RefreshBlood(dVary)
	if bChange or bIsChangeHp then
		g_WarCtrl:WarriorStatusChange(self.m_ID)
	end
end

function CWarrior.Destroy(self)
	self:ClearBindObjs()
	-- self:ClearBuff()
	self:CloseDetailView()
	self.m_Actor:Destroy()
	CObject.Destroy(self)
end

function CWarrior.IsAlly(self)
	--printerror("是否友方", self.m_IsAlly, g_WarCtrl:GetViewSide(), self.m_CampID, g_WarCtrl:GetHeroPid(), self.m_Pid, g_WarCtrl:GetAllyCamp())
	if self.m_IsAlly == nil then
		if g_WarCtrl:GetViewSide() and g_WarCtrl:GetViewSide() == self.m_CampID then
			self.m_IsAlly = true
		elseif g_WarCtrl:GetHeroPid() and g_WarCtrl:GetHeroPid() == self.m_Pid then
			self.m_IsAlly = true
		elseif self.m_CampID == g_WarCtrl:GetAllyCamp() then
			self.m_IsAlly = true
		else
			self.m_IsAlly = false
		end
	end
	return self.m_IsAlly
end

function CWarrior.SetOriginPos(self, pos)
	self.m_OriginPos = pos
end

function CWarrior.GetOriginPos(self)
	return self.m_OriginPos
end

function CWarrior.ChangeShape(self, tDesc)
	-- printc("############### 单位修正", g_TimeCtrl:GetTimeMS(), g_TimeCtrl:GetTimeS())
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
	self.m_Actor:ChangeShape(dInfo, callback(self, "OnChangeDone"), false, false, 81)
	self:SetBusy(true, "changeshape")
	self.m_ChangeShapeTimer = Utils.AddTimer(function()
		if Utils.IsNil(self) then
			return
		end
		self:SetBusy(false, "changeshape")	
	end, 1, 1)
end

function CWarrior.GetSpecailId(self)

	return self.m_SpecialId

end

function CWarrior.GetCurDesc(self)
	return self.m_Actor:GetModelInfo()
end

function CWarrior.OnChangeDone(self)
	self.m_ModelDone = true
	g_WarCtrl:WarriorStatusChange(self.m_ID)
	self:SetLayer(self.m_GameObject.layer, true)
	self:CrossFade(self:GetState())

	if self.ResetHudNode and type(self.ResetHudNode) == "function" then
		self:ResetHudNode()
	end
	if self.m_ChangeShapeTimer then
		Utils.DelTimer(self.m_ChangeShapeTimer)
		self.m_ChangeShapeTimer = nil
	end
	self:SetBusy(false, "changeshape")
	self:ShowWingEffect(false)
	self:ShowWeaponEffect(true)
	self.m_Actor:SetWingAlphaLoop(true)
end

function CWarrior.ResetHudNode(self)
	--	默认是和脚底是一致的
	local hudinfo = ModelTools.GetModelHudInfo(self.m_Actor.m_Shape)
		self.m_FootTrans.localPosition = Vector3.New(self.m_FootTrans.localPosition.x, hudinfo.foot_node_offset, self.m_FootTrans.localPosition.z)
end

function CWarrior.Play(self, state, normalizedTime)
	self.m_Actor:Play(state, normalizedTime)
end

function CWarrior.CrossFade(self, state, duration, normalizedTime)
	self.m_Actor:CrossFade(state, duration, normalizedTime)
end

function CWarrior.PlayInFixedTime(self, state, fixedTime)
	self.m_Actor:PlayInFixedTime(state,fixedTime)
end

function CWarrior.CrossFadeInFixedTime(self, state, duration, fixedTime)
	self.m_Actor:CrossFadeInFixedTime(state, duration, fixedTime)
end

function CWarrior.SetBusy(self, b, sType)
	if g_WarCtrl.g_Print then
		print(string.format("<color=#00FFFF> >>> .%s | %s </color>", "SetBusy", "===== 设置繁忙 | "), self:GetName(), sType, b)
	end
	sType = sType or "main"
	self.m_BusyFlags[sType] = b
end

function CWarrior.IsBusy(self, sType)
	if not Utils.IsExist(self) then
		return false
	end
	if sType then
		return self.m_BusyFlags[sType]
	end
	for k, v in pairs(self.m_BusyFlags) do
		if v == true then
			if g_WarCtrl.g_Print then
				-- printc("???????????????? IsBusy", self:GetName(), k)
			end
			return true
		end
	end
	return false
end

function CWarrior.WaitTime(self, time, cb)
	self:SetBusy(true, "WaitTime")
	local func = function ()
		if cb then
			cb()
		end
		self:SetBusy(false, "WaitTime")
	end
	Utils.AddTimer(func, time, time)
end

function CWarrior.WaitHit(self)
	self:SetBusy(true, "waitHit")
end

function CWarrior.BeginHit(self, atkObj, dVary, bFaceAtk, bAnim, bShot)
	if g_WarCtrl.g_Print then
		printc("===== 开始受击 CWarrior.BeginHit", self:GetName() .. " | " .. self.m_ID)
	end
	if Utils.IsNil(self) then
		return
	end
	local oDamageCmd, idx = self:GetDamageCmd(dVary)
	if not oDamageCmd then
		return
	end
	if not self:IsAlive() then
		if g_WarCtrl.g_Print then
			printc("已死亡目标 CWarrior.BeginHit", self:GetName() .. " | " .. self.m_ID)
		end
		return
	end
	self.m_EventState = {}

	if oDamageCmd.damage > 0 then
		-- 加血
	else
		-- type 1:miss 2:defend 3:crit 4:miss(but not tip)
		if oDamageCmd.type == 1 or oDamageCmd.type == 4 then
			local showTip = oDamageCmd.type == 1
			self:Dodge(showTip)
		elseif oDamageCmd.type == 2 then
			if dVary.status and dVary.status ~= define.War.Status.Alive then
				if g_WarCtrl.g_Print then
					printc("========== 直接死亡", self:GetName() .. " | " .. self.m_ID)
				end
				return
			end
			if g_WarCtrl.g_Print then
				printc("========== 进入防御", self:GetName() .. " | " .. self.m_ID)
			end
			self.m_Actor:CrossFade("defend", 0.1)
			self:SetBusy(true, "defend")
			self:WaitTime(0.5, function ()
				-- 有可能0.3s间死亡
				if self:IsAlive() then
					self.m_Actor:CrossFade("idleWar", 0.1)
					self:SetBusy(false, "defend")
				end
			end)

			if oDamageCmd then
				oDamageCmd:Excute()
				if dVary.damage_list then
					table.remove(dVary.damage_list, idx)
				end
			end
			self:UpdateStatus(dVary)
			-- self:SetBusy(true, "defend")
			-- self.m_Actor:Play("defend", 0, 1, callback(self, "SetBusy", false, "defend"))

			-- self:SetBusy(true, "defend")
			-- local requiredata = {
			-- 	refAtkObj = weakref(atkObj),
			-- 	refVicObjs = {weakref(self)},
			-- }
			-- local oMagicUnit = g_MagicCtrl:NewMagicUnit(define.Magic.Defend_ID, 1, requiredata)
			-- oMagicUnit:SetLayer(UnityEngine.LayerMask.NameToLayer("War"))
			-- oMagicUnit:SetEndCallback(function() self:SetBusy(false, "defend") end)
		else
			if self:IsFloatAtkID(atkObj.m_ID) then
				if bAnim then
					self:FloatHit()
				end
				self:SubFloatAtkId(atkObj.m_ID)
			else
				if bFaceAtk and atkObj then
					self:LookAtPos(atkObj:GetLocalPos())
				end
				if bAnim then
					self:Hit(dVary, bShot)
				end
			end
		end
	end
end

function CWarrior.Attack(self)
	if Utils.IsNil(self) then
		return
	end
	local config = ModelTools.GetModelConfig(self.m_Actor.m_Shape)
	if config and config.atk_trick and config.atk_trick ~= "" then
		local path = DataTools.GetAudioSound(config.atk_trick)
		g_AudioCtrl:PlayEffect(path, true)
	end
	self.m_EventState = {}
	self.m_Actor:AdjustSpeedPlay("attack1", 0.7)
	self.m_Actor:NomallizedEvent("attack1", 0, callback(self, "InsertEventState", define.Warrior.Event_BeginHit))
	self.m_Actor:NomallizedEvent("attack1", 0.3, callback(self, "InsertEventState", define.Warrior.Event_Hurt))
	self.m_Actor:NomallizedEvent("attack1", 0.7, callback(self, "InsertEventState", define.Warrior.Event_EndHit))
end

--浮空测试参数
CWarrior.up_speed = 4.5
CWarrior.up_time = 0.35
CWarrior.hit_speed = 3.5
CWarrior.hit_time = 0.35
CWarrior.down_time = 0.7
CWarrior.rise_time = 0.8

function CWarrior.FloatHit(self)
	if table.count(self.m_DontHitBuffs) > 0 then
		return
	end
	DOTween.DOKill(self.m_RotateObj.m_Transform, false)
	local sState = self.m_Actor:GetState()
	local iTime
	if sState == "idleWar" then
		iTime = CWarrior.up_time
		local pos = self.m_RotateObj:GetLocalPos()
		pos.y = pos.y + CWarrior.up_speed * iTime
		local tween = DOTween.DOLocalMove(self.m_RotateObj.m_Transform, pos, iTime)
		self.m_Actor:AdjustSpeedPlay("upFloat", iTime)
		self:WaitTime(iTime)
	else
		iTime = CWarrior.hit_time
		local pos = self.m_RotateObj:GetLocalPos()
		local iMax = 2.5
		pos.y = pos.y + Mathf.Lerp(0, CWarrior.hit_speed*iTime, 1-(pos.y/iMax))
		DOTween.DOLocalMove(self.m_RotateObj.m_Transform, pos, iTime)
		self.m_Actor:AdjustSpeedPlay("hitFloat", iTime)
		self:WaitTime(iTime)
	end
	local function restore()
		if Utils.IsExist(self) then
			self:FaceDefault()
			if self.m_Status.hp > 0 then
				self.m_Actor:CrossFade("idleWar", 0.2)
			end
			self.m_FootshadowObj:SetActive(true)
			self.m_FloatHitInfo.restore_timer = nil
			self:SetBusy(false, "floating")
		end
	end
	local function down()
		if Utils.IsExist(self) then
			local pos = self.m_RotateObj:GetLocalPos()
			pos.y = 0
			self.m_Actor:AdjustSpeedPlay("downFloat", CWarrior.down_time)
			local tween = DOTween.DOLocalMove(self.m_RotateObj.m_Transform, pos, CWarrior.down_time)
			DOTween.SetEase(tween, enum.DOTween.Ease.InCirc)
			self.m_FloatHitInfo.rise_timer = Utils.AddTimer(function()
				if Utils.IsExist(self) then
					self.m_RotateObj:SetLocalPos(pos)
					local time = 0
					if self.m_Status.hp > 0 then
						self.m_Actor:AdjustSpeedPlay("rise", CWarrior.rise_time)
						time =  CWarrior.rise_time
					end
					self.m_FloatHitInfo.restore_timer = Utils.AddTimer(restore, 0, time)
				end
			end, 0, CWarrior.down_time)

			self.m_FloatHitInfo.down_timer = nil
		end
	end
	if self.m_FloatHitInfo.down_timer then
		Utils.DelTimer(self.m_FloatHitInfo.down_timer)
	end
	if self.m_FloatHitInfo.restore_timer then
		Utils.DelTimer(self.m_FloatHitInfo.restore_timer)
		self.m_FloatHitInfo.restore_timer = nil
	end
	if self.m_FloatHitInfo.rise_timer then
		Utils.DelTimer(self.m_FloatHitInfo.rise_timer)
		self.m_FloatHitInfo.rise_timer = nil
	end
	self:SetBusy(true, "floating")
	self.m_FootshadowObj:SetActive(false)
	self.m_FloatHitInfo.down_timer = Utils.AddTimer(down, iTime, iTime)
end

function CWarrior.StopHit(self)
	if self.m_HitInfo.timer then
		Utils.DelTimer(self.m_HitInfo.timer)
	end
	if self.m_HitInfo.begin_pos then
		self:SetLocalPos(self.m_HitInfo.begin_pos)
	end
	self:EndHit(true)
	self.m_HitInfo = {timer=nil, stand=0, step=0, goback=false, begin_pos=nil}
end

function CWarrior.Hit(self, dVary, bShot)
	local iKeyFrame = self.m_Actor:GetHitKeyFrame()
	local iBackTime = ModelTools.FrameToTime(iKeyFrame)
	local iSpeed = 0.1 / iBackTime
	local dir = self:InverseTransformDirection(self.m_RotateObj:GetForward())

	if self.m_HitInfo.goback then
		self.m_HitInfo.goback = false
	end

	local iMax = iBackTime*1.5
	self.m_HitInfo.stand = self.m_HitInfo.stand + Mathf.Lerp(0, iBackTime*0.7, (iMax-self.m_HitInfo.stand)/iMax)
	local hurted = false
	if g_WarCtrl.g_Print then
		printc("============= CWarrior.Hit -> iKeyFrame | iBackTime", iKeyFrame, iBackTime)
	end

	local function step(dt)
		if Utils.IsNil(self) then
			return false
		end
		if not self:IsAlive() then
			if g_WarCtrl.g_Print then
				printc("已死亡目标 CWarrior.Hit", self:GetName() .. self.m_ID)
			end
			self:StopHit()
			self.m_HitInfo.timer = nil
			return false
		end
		if self.m_HitInfo.goback then
			if self.m_HitInfo.step < 0 then
				local sState = self.m_Actor:GetState()
				if self.m_HitInfo.begin_pos and self:IsNearOriPos(self.m_HitInfo.begin_pos) then
					self:SetLocalPos(self.m_HitInfo.begin_pos)
				end

				-- 填写有误时有bug
				-- if sState == "hit2" or sState == "hit1" then
					self:StopHit(true)
				-- end
				self.m_HitInfo.timer = nil
				self.m_HitInfo.step = 0
				return false
			else
				self:Translate(dir * iSpeed * dt)
				self.m_HitInfo.step = self.m_HitInfo.step - dt
			end
		else
			if self.m_HitInfo.step >= iBackTime then
				if self.m_HitInfo.stand > 0 then
					self.m_HitInfo.stand = self.m_HitInfo.stand - dt
					if not hurted then
						-- self:Hurt(dVary)
						hurted = true
					end
				else
					self.m_HitInfo.stand = 0
					self.m_Actor:CrossFade("hit2", 0.05)
					self.m_HitInfo.goback = true
				end
			else
				self:Translate(dir * -iSpeed * dt)
				self.m_HitInfo.step = self.m_HitInfo.step + dt
			end
		end
		return true
	end

	if not self.m_HitInfo.timer then
		self.m_HitInfo.begin_pos = self:GetLocalPos()
		self.m_HitInfo.timer = Utils.AddTimer(step, 0, 0)
	end

	if bShot then
		local config = ModelTools.GetModelConfig(self.m_Actor.m_Shape)
		if config and config.hit_trick and config.hit_trick ~= "" then
			local path = DataTools.GetAudioSound(config.hit_trick)
			g_AudioCtrl:PlayEffect(path, true, true)
		end
	end

	if self:GetState() == "hit2" then
		local iNor = math.min(0.5, self.m_HitInfo.step / iBackTime)
		self.m_Actor:CrossFade("hit1", 0.05, iNor)
	else
		self.m_Actor:CrossFade("hit1", 0.05)
	end

	-- 临时解决方案
	self:Hurt(dVary)
	self:SetBusy(true, "hit")
end

function CWarrior.ItemUser(self, itemid, dVary)
	self:SetBusy(true, "itemuse")
	self.m_Actor:Play("magic")
	self.m_Actor:NomallizedEvent("magic", 1, callback(self, "SetBusy", false, "itemuse"))
end

function CWarrior.ItemUsed(self, itemid, dVary)
	local oDamageCmd, idx = self:GetDamageCmd(dVary)
	if oDamageCmd then
		oDamageCmd:Excute(false)
		if dVary.damage_list then
			table.remove(dVary.damage_list, idx)
		end
	end
	self:UpdateStatus(dVary)

	-- if itemid ~= 1001 or itemid ~= 1002 or itemid ~= 1003 or itemid ~= 1005 then
	-- 	local name = define.Warrior.UseItemEffectDic[itemid]
	-- 	if name then
	-- 		local path = string.format("Effect/Magic/%s/Prefabs/%s.prefab", name, name)
	-- 		local oEff = CMagicEffect.New(path, UnityEngine.LayerMask.NameToLayer("War"), true)
	-- 		oEff:SetLocalPos(self:GetBindTrans("foot").position)
	-- 		Utils.AddTimer(function ()
	-- 			oEff:Destroy()
	-- 		end, 3, 3)
	-- 	end

	-- 	self:CrossFade("idleWar")
	-- 	self:FaceDefault()
	-- 	self:SetBusy(true, "itemused")
	-- 	Utils.AddTimer(function ()
	-- 		self:SetBusy(false, "itemused")
	-- 	end, 1.6, 1.6)
	-- end
end

function CWarrior.Hurt(self, dVary)
	if Utils.IsNil(self) then
		return
	end
	local oDamageCmd, idx = self:GetDamageCmd(dVary)
	if oDamageCmd then
		oDamageCmd:Excute(false)
		if dVary.damage_list then
			table.remove(dVary.damage_list, idx)
		end
	end
	self:UpdateStatus(dVary)
end

function CWarrior.GetDamageCmd(self, dVary)
	if dVary.damage_list and next(dVary.damage_list) then
		return dVary.damage_list[1], 1
	end
end

function CWarrior.RefreshBlood(self, dVary, bIsRelive)
	--[==[
	if g_WarCtrl:GetWarType() == define.War.Type.Boss then
		if not self:IsAlly() and self.m_CampPos == 1 then
			return
		end
	end
	]==]
	local bIsNoChange = true
	local hp = self.m_Status.hp or 0
	local max_hp = self.m_Status.max_hp or 0
	local aura = self.m_Status.aura or 0
	if dVary and dVary.hp_list and next(dVary.hp_list) then
		local t = dVary.hp_list[1]
		if t.hp then
			hp = t.hp
			bIsNoChange = self.m_Status["hp"] == hp and bIsNoChange
			self.m_Status["hp"] = hp
		end
		if t.max_hp then
			max_hp = t.max_hp
			self.m_Status["max_hp"] = max_hp
			bIsNoChange = self.m_Status["max_hp"] == max_hp and bIsNoChange
		end
		table.remove(dVary.hp_list, 1)
	end
	--[=[
	if self.m_NpcWarriorType == define.Warrior.NpcWarriorType.Boss then
		--print("Boss怪不显示HUDblood")
		return
	end
	]=]

	-- 血条显示条件
	-- 1、敌方（a、PVE_TYPE b、其他不显示）
	-- 2、友方（all）
	if self:IsAlly() then
		if self.m_Type ~= define.Warrior.Type.Player then
			aura = 0
		end
		self:SetBlood(hp/max_hp, aura, self.m_arge_5704, bIsRelive)
		self:SetBlood(hp/max_hp, aura, self.m_arge_5704, bIsRelive)
	else
		aura = 0
		if g_WarCtrl.m_WarType == define.War.War_Type.PVE_TYPE then
			self:SetBlood(hp/max_hp, aura, self.m_arge_5704, bIsRelive)
			self:SetBlood(hp/max_hp, aura, self.m_arge_5704, bIsRelive)
		end
	end
	if not bIsNoChange then
		local oView = CWarTargetDetailView:GetView()
		if oView and oView:GetWarrior() == self then
			oView:RefreshStatusTable()
		end
	end
	return not bIsNoChange
end

function CWarrior.RefreshTitle(self, sTitle)
	if not sTitle or string.len(sTitle) < 1 then return end
    self:AddHud("normal_title", CNormalTitleHud, self.m_HudNode.m_FootHudTable, function(oHud)
    	oHud:SetNameByStr(sTitle)
    end, false)
end

function CWarrior.AddMp(self, dVary)
	if Utils.IsNil(self) then
		return
	end
	local function doMP()
		local oAddMpCmd, idx = self:GetAddMpCmd(dVary)
		if oAddMpCmd then
			oAddMpCmd:Excute()
			if dVary.addMp_list then
				table.remove(dVary.addMp_list, idx)
				return true
			end
		end
	end
	Utils.AddTimer(doMP, 0.1, 0)
end

function CWarrior.GetAddMpCmd(self, dVary)
	if dVary.addMp_list and next(dVary.addMp_list) then
		return dVary.addMp_list[1], 1
	end
end

function CWarrior.TriggerPassiveSkill(self, pfid, keylist)
	local needTip = true

	if pfid == 5703 then
		-- 狂暴
		needTip = self.m_arge_5703 == 0
		self.m_arge_5703 = needTip and 1 or 0
		if needTip then
			self:AddBindObj("warrior_statu_5703")
		else
			self:DelBindObj("warrior_statu_5703")
		end
	elseif pfid == 5704 then
		-- 好战（血条添加特效）
		needTip = self.m_arge_5704 == 0
		self.m_arge_5704 = needTip and 1 or 0
		self:RefreshBlood()
	end

	if needTip then
		local passiveData = DataTools.GetMaigcPassiveData(pfid)
		if passiveData then
			local function delay()
				if Utils.IsNil(self) then
					return false
				end
				self:AddHud("warrior_passive", CWarriorPassiveHud, self.m_HudNode.m_HeadHudTable, function(oHud) 
					oHud:RefreshPassive(pfid)
				end, true)
				return false
			end
			Utils.AddTimer(delay, 1, passiveData.passiveDelay * 0.001)
		end
	end

	if keylist then
		for _,v in ipairs(keylist) do
			if v.key == "ghost" then
				self:RefeshStatusGohst(pfid, v.key, v.value)
			end
		end
	end
end

function CWarrior.GetStatus(self)
	return self.m_Status
end

function CWarrior.IsAlive(self)
	return self.m_IsAlive
end

function CWarrior.EndHit(self, bFaceDefalut)
	if self:IsAlive() then
		if not self.m_FloatAtkID then
			self:CrossFade("idleWar")
			if bFaceDefalut then
				self:FaceDefault()
			end
		end
	end
	self:SetBusy(false, "hit")
	if self.m_BusyFlags["waitHit"] then
		self:SetBusy(false, "waitHit")
	end
	if g_WarCtrl.g_Print then
		printc("========= 受击结束", self:GetName() .. " | " .. self.m_ID)
	end
end

function CWarrior.GetDefalutRotateAngle(self)
	if self:IsAlly() then
		return Vector3.New(0, -50, 0)
	else
		return Vector3.New(0, 130, 0)
	end
end

function CWarrior.ShowSelSpr(self, bShow, showSprite)
	if g_WarCtrl:IsChallengeType() then
		bShow = false
	end
	-- printerror("========== CWarrior.ShowSelSpr", bShow, showSprite)
	if bShow then
		self:AddBindObj("warrior_select", function(oHud) 
			oHud:SetWarrior(self, showSprite)
		end)
	else
		self:DelBindObj("warrior_select")
	end
	self.m_IsOrderTarget = bShow
end

function CWarrior.IsOrderTarget(self)
	return self.m_IsOrderTarget
end

function CWarrior.GetState(self)
	return self.m_Actor:GetState()
end

function CWarrior.GetShape(self)
	return self.m_Actor:GetShape()
end

function CWarrior.GetBasicShape(self)
	return self.m_Actor:GetOriShape()
end

--hud
function CWarrior.GetHudCamera(self)
	return g_CameraCtrl:GetWarCamera()
end


function CWarrior.SetName(self, name)
	self.m_Name = name
	if Utils.IsEditor() then
		name = name or ""
		CObject.SetName(self, string.format("wid:%s-%s", self.m_ID, name))
		if gameconfig.Debug.Warriordetail then
			name = string.format("wid:%s|pos:%s\n%s", self.m_ID, self.m_CampPos, name)
			if self.m_SummonID then
				name = name.."_"..tostring(self.m_SummonID)
			end
		end
	end

	-- Default NPC
	local typeNum = self:IsAlly() and 4 or 5
	local colorinfo = data.namecolordata.DATA[typeNum]
	local color = "["..colorinfo.color.."]"
	self:SetWarNameHud(color .. name, colorinfo.style, Color.RGBAToColor(colorinfo.style_color), colorinfo.blod)
end

function CWarrior.GetName(self)
	return self.m_Name
end

function CWarrior.SetTeamCmd(self, sCmd)
	self.m_TeamCmd = sCmd
	if sCmd ~= nil and sCmd ~= "" then
		local cb = function(oHud)
			oHud:SetCmd(sCmd)
		end
		self:AddHud("warrior_teamCmd", CTeamCmdHud, self.m_HudNode.m_WaistHudTable, cb, true)
	else
		self:DelHud("warrior_teamCmd")
	end
end

--行为
function CWarrior.GoBack(self, iSpeed)
	local angle = self:GetDefalutRotateAngle()
	local cb
	-- if not self:IsAlive() then
	-- 	cb = function ()
	-- 		self:Die()
	-- 		return 0.5
	-- 	end
	-- end
	self:RunTo(self.m_OriginPos, iSpeed, angle, cb, true)
end

function CWarrior.RunTo(self, endPos, iSpeed, endAngle, cb, runback)
	if Utils.IsNil(self) then
		return
	end

	if not self:IsAlive() then
		if g_WarCtrl.g_Print then
			printc("已死亡目标 CWarrior.RunTo", self:GetName() .. self.m_ID)
		end
		return
	end

	local curpos = self:GetLocalPos()
	local dis = WarTools.GetHorizontalDis(curpos, endPos)
	if g_WarCtrl.g_Print then
		print(string.format("<color=#00FFFF> >>> .%s | %s </color>", "RunTo", "开始移动位置"), self:GetName() .. self.m_ID, endPos, iSpeed, endAngle, cb, runback, dis)
	end

	if dis > 0.01 then
		local function notbusy()
			self:SetBusy(false, "RunTo")
			if g_WarCtrl.g_Print then
				print(string.format("<color=#00FFFF> >>> .%s | %s </color>", "RunTo", "移动位置结束"), self:GetName() .. self.m_ID)
			end
		end
		local function onEnd()
			if Utils.IsNil(self) then
				notbusy()
				return
			end
			if endAngle then
				self.m_RotateObj:SetLocalEulerAngles(endAngle)
			else
				self:FaceDefault()
			end
			local iTime = 0.2
			self:CrossFade("idleWar")
			if cb then
				iTime = cb()
			end

			Utils.AddTimer(notbusy, 0, iTime)
			if runback then
				self:SetLocalPos(self.m_OriginPos)
			end
		end
		iSpeed = iSpeed or define.Warrior.Run_Speed
		local t = dis / iSpeed
		self:LookAtPos(endPos)

		local animName = "run"
		-- local animaInfo = ModelTools.GetAnimClipData(self.m_Actor.m_Shape)
		-- if animaInfo then
		-- 	if runback and animaInfo.runBack then
		-- 		animName = "runBack"
		-- 	elseif animaInfo.runWar then
		-- 		animName = "runWar"
		-- 	end
		-- end
		self.m_Actor:AdjustSpeedPlay(animName, 0.4)
		DOTween.OnComplete(DOTween.DOLocalMove(self.m_Transform, endPos, t), onEnd)
		self:SetBusy(true, "RunTo")
	else
		if cb then
			cb()
		end
		if endAngle then
			self.m_RotateObj:SetLocalEulerAngles(endAngle)
		end
	end
end

function CWarrior.FaceDefault(self)
	local angle = self:GetDefalutRotateAngle()
	if self.m_RotateObj:GetLocalEulerAngles() ~= angle then
		DOTween.DOLocalRotate(self.m_RotateObj.m_Transform, angle, 0.1)
	end
end

function CWarrior.LookAtPos(self, localPos, time)
	if Utils.IsNil(self) then
		return
	end

	local pos = self:GetLocalPos()
	local dir = WarTools.GetWorldDir(pos, localPos)
	if dir.x == 0 and dir.z == 0 then
		return
	end

	local time = time or 0
	local dirForward = self:InverseTransformDirection(dir)
	local dirUp = self:InverseTransformDirection(self.m_Transform.up)
	local r = Quaternion.LookRotation(dirForward, dirUp)
	DOTween.DOKill(self.m_RotateObj.m_Transform, false)
	if time == 0 then
		self.m_RotateObj:SetLocalRotation(r)
	else
		DOTween.DOLocalRotateQuaternion(self.m_RotateObj.m_Transform, r, time)
	end
end

function CWarrior.Escape(self, success)
	local dir = self:GetLocalForward() * -1
	local iRotateTime = 0.3
	self:LookAtPos(self:GetLocalPos() + dir, iRotateTime)
	self:Play("run")
	self:SetBusy(true, "Escape")
	local function delay()
		if Utils.IsNil(self) then
			return
		end
		if success then
			local iTime = 0.8
			local function onEnd()
				self:SetBusy(false, "Escape")
				g_WarCtrl:DelWarrior(self.m_ID)
			end
			local pos = self:GetPos()
			local endPos = WarTools.OutViewPortPos(pos, dir*0.1, 0.8)
			DOTween.OnComplete(DOTween.DOMove(self.m_Transform, endPos, 0.8), onEnd)
		else
			self:CrossFade("die")
			local function idle()
				self:CrossFade("idleWar", 0.2)
				self:FaceDefault()
				self:SetBusy(false, "Escape")
			end
			Utils.AddTimer(idle, 0, 1.5)
		end
	end
	Utils.AddTimer(delay, 0, iRotateTime + 0.8)
end

function CWarrior.FlyOut(self)
	if Utils.IsNil(self) or self.m_PlayingDelAni then
		return
	end
	
	self:SetBlood(0, 0, 0, false, true)

	self.m_PlayingDelAni = true
	local function delay()
		if Utils.IsNil(self) then
			return
		end
		self:DelHud("warrior_damage")
		local dir = self:GetLocalForward() * -1
		-- self:SetBusy(true, "FlyOut")
		local function onEnd()
			self:SetBusy(false, "FlyOut")
			self.m_PlayingDelAni = false
			g_WarCtrl:DelWarrior(self.m_ID)
		end
		local iTime = 0.8
		local iStartY = self.m_RotateObj:GetLocalEulerAngles().y
		local endRotate = Vector3.New(0, iStartY+1080, 0)
		DOTween.DOLocalRotate(self.m_RotateObj.m_Transform, endRotate, iTime, enum.DOTween.RotateMode.LocalAxisAdd)
		local pos = self:GetPos()
		local endPos = WarTools.OutViewPortPos(pos, dir*0.1, iTime)
		DOTween.OnComplete(DOTween.DOMove(self.m_Transform, endPos, iTime), onEnd)
		return false
	end
	local clipInfo = ModelTools.GetAnimClipData(self.m_Actor.m_Shape)
	local delayTime = (clipInfo and clipInfo.hit1) and clipInfo.hit1.length or 0.2
	--预留时间显示伤害
	delayTime = self.m_DieDelay or math.max(delayTime, 0.6)
	Utils.AddTimer(delay, 0.1, delayTime)
end

function CWarrior.Blink(self)
	if Utils.IsNil(self) or self.m_PlayingDelAni then
		return
	end
	-- self:SetBusy(true, "Blink")
	local iStep = 0
	local iMaxStep = 0
	local dir = self:GetLocalForward()
	self.m_PlayingDelAni = true
	self:SetBlood(0, 0, 0, false, true)
	local function step()
		if Utils.IsNil(self) then
			return
		end
		if iStep >= iMaxStep then
			-- self:SetBusy(false, "Blink")
			self.m_PlayingDelAni = false
			g_WarCtrl:DelWarrior(self.m_ID)
			return false
		end

		if iStep % 2 == 0 then
			Utils.HideObject(self)
		else
			Utils.ShowObject(self)
		end
		iStep = iStep + 1
		return true
	end
	Utils.AddTimer(step, 0.1, 0)
end

function CWarrior.FadeDel(self)
	local function del()
		if Utils.IsExist(self) then
			self:SetBusy(false, "FadeDel")
		end
		g_WarCtrl:DelWarrior(self.m_ID)
	end
	local c = self.m_Actor:GetMatColor()
	local action = CActionColor.New(self.m_Actor, 0.5,  "SetMatColor", Color.New(c.r, c.g, c.b, c.a * 0.5), Color.New(c.r, c.g, c.b, 0))
	action:SetEndCallback(del)
	g_ActionCtrl:AddAction(action)
	self:SetBusy(true, "FadeDel")
end

function CWarrior.DelAndDie(self)
	if Utils.IsNil(self) then
		return
	end
	self:StopHit()
	self:SetBusy(true, "FadeDel")
	if self:GetState() == "die" then
		self:FadeDel()
	else
		self.m_Actor:CrossFade("die", 0.1, 0, 1, callback(self, "FadeDel"))
	end
end

function CWarrior.Dodge(self, showTip)
	if showTip then
		self:AddHud("warrior_tip", CWarriorTipHud, self.m_HudNode.m_WaistSubHud, function(oHud) 
			oHud:SetTipHud({style = 3, content = "闪避"})
		end, true)
	end

	self:SetBusy(true, "Dodge")
	local iStep = 0
	local bGoBack = false
	local iSpeed = 0.1
	local iMaxStep = 0.75 / iSpeed
	local dir = self:InverseTransformDirection(self.m_RotateObj:GetForward())
	local function step()
		if Utils.IsNil(self) then
			return
		end
		if bGoBack then
			self:Translate(dir * iSpeed)
			iStep = iStep - 1
			if iStep < 0 then
				self:SetLocalPos(self.m_OriginPos)
				self:SetBusy(false, "Dodge")
				Utils.AddTimer(function ()
					if Utils.IsNil(self) then
						return false
					end
					self:DelHud("warrior_tip")
					return false
				end, 1, 3)
				return false
			end
		else
			self:Translate(dir * -iSpeed)
			iStep = iStep + 1
			if iStep >= iMaxStep then
				bGoBack = true
			end
		end
		return true
	end
	Utils.AddTimer(step, 0, 0)
end

function CWarrior.StartCheckEvent(self, state)
	self.m_EventState = {}
	local t = DataTools.GetAnimEventData(self:GetBasicShape(), state)
	if t then
		for i, time in ipairs(t) do
			self.m_Actor:FixedEvent(state, time, callback(self, "InsertEventState", i))
		end
	end
end

function CWarrior.InsertEventState(self, iEvent, time)
	table.insert(self.m_EventState, iEvent)
end

function CWarrior.IsHeroOwn(self)
	if self.m_ID == g_WarCtrl.m_HeroWid then
		return true
	elseif self.m_OwnerWid and self.m_OwnerWid == g_WarCtrl.m_HeroWid then
		return true
	else
		return false
	end
end

function CWarrior.IsPlayer(self)
	return self.m_Type == define.Warrior.Type.Player
end

function CWarrior.HasTeamCmd(self)
	return self.m_TeamCmd ~= nil and self.m_TeamCmd ~= ""
end

function CWarrior.GetSpecialSkillList(self)
	local list = {}
	for _,iMagicId in ipairs(self.m_MagicList) do
		local dData = DataTools.GetMagicData(iMagicId)
		if dData.magic_type == define.Warrior.MagicType.Se then
			table.insert(list, iMagicId)
		end
	end
	return list
end

function CWarrior.GetHeroMagicList(self)
	local list = {}
	for _,iMagicId in ipairs(self.m_MagicList) do
		local dData = DataTools.GetMagicData(iMagicId)
		if dData.magic_type ~= define.Warrior.MagicType.Se and dData.magic_type ~= "fabao" then--== define.Warrior.MagicType.School then
			table.insert(list, iMagicId)
		end
	end
	return list
end

function CWarrior.GetFaBaoMagicList(self)
	local list = {}
	for _, iMagicId in ipairs(self.m_MagicList) do
		local dData = DataTools.GetMagicData(iMagicId)
		if dData.magic_type == "fabao" then
			table.insert(list, iMagicId)
		end
	end
	return list
end

function CWarrior.GetSummonMagicList(self)
	local list = {}
	for _,iMagicId in ipairs(self.m_MagicList) do
		local dData = DataTools.GetMagicData(iMagicId)
		if dData.magic_type == define.Warrior.MagicType.Summon then
			table.insert(list, iMagicId)
		end
	end
	return list
end

function CWarrior.IsExistSkill(self, iTarget)
	for i,iSkill in ipairs(self.m_MagicList) do
		if iTarget == iSkill then
			return true
		end
	end
	return false
end

function CWarrior.ShowSummonEffect(self)
	self:SetBusy(true, "create")
	self:SetActive(false)
	local path = "Effect/Scene/scene_eff_0004/Prefabs/scene_eff_0004.prefab"
	local oEffect = CEffect.New(path, UnityEngine.LayerMask.NameToLayer("War"), true)
	oEffect:SetPos(self:GetPos())
	g_EffectCtrl:SetRootActive(true)
	local function timeup()
		if Utils.IsNil(oEffect) or Utils.IsNil(self) then
			return false
		end
		--printc("ShowSummonEffect end")
		self:SetActive(true)
		self:ShowWarAnim()
		self:SetBusy(false, "create")
		g_EffectCtrl:SetRootActive(false)
		oEffect:Destroy()
	end
	Utils.AddTimer(timeup, 0, 1)
end

function CWarrior.DelBindObjLater(self, iDelay, sType)
	self:SetBusy(true, "itemused")
	local function timeup()
		if Utils.IsNil(self) then
			return false
		end
		self:SetBusy(false, "itemused")
		self:DelBindObj(sType)
	end
	Utils.AddTimer(timeup, 0, iDelay)
end

-- 展示出场动作
function CWarrior.ShowWarAnim(self)
	if g_WarCtrl:IsNeedShowAnim() then
		local animaInfo = ModelTools.GetAnimClipData(self.m_Actor.m_Shape)
		if animaInfo and animaInfo.show2 then
			self:CrossFade("show2")
		end
	end
end

-- 控制显示敌人单位门派等级hud
function CWarrior.ShowLvSchHudSwitch(self, bShow)
	if not self.m_Status.grade then --没有等级
		return
	end
	if self.m_NeedLvSchHud and bShow then
		self:AddLvSchHud()
		self.m_NeedLvSchHud = false
	else
		self:ShowHudSwitch("lv_school", bShow)
	end
end

function CWarrior.AddLvSchHud(self)
	local sLabel
	local iGrade = self.m_Status.grade or 0
	-- printc(self.m_Status.school or "nil", self.m_Status.grade or "nil")
	if self.m_Status.school then
		local sSch
		local dSch = DataTools.GetSchoolInfo(self.m_Status.school)
		sSch = dSch and dSch.short_name or ""
		sLabel = string.format("%d %s", iGrade, string.upper(sSch))
	else
		sLabel = iGrade
	end
	self:AddHud("lv_school", CLvSchoolHud, self.m_HudNode.m_FootSubHud, function(oHud)
		local name = string.format("[ffffd9][b]%s[-][-]", sLabel)
		oHud:SetName(name)
		self:SetHudRootName(name)
		oHud.m_NameLabel:SetEffectColor(Color.RGBAToColor("00a6d9"))
		oHud.m_NameLabel:SetEffectStyle(2)
	end, false)
end

function CWarrior.GetAutoQuickSkills(self)
	local iAuto, iQuick
	if self.m_ID == g_WarCtrl.m_HeroWid then
		iAuto = g_WarCtrl:GetHeroAutoMagic()
		iQuick = g_WarCtrl.m_QuickMagicIDHero
	elseif self.m_ID == g_WarCtrl.m_SummonWid then
		iAuto = g_WarCtrl:GetSummonAutoMagic()
		iQuick = g_WarCtrl:GetSummonQuickSkill()
	else
		return
	end
	return iAuto, iQuick
	
end

function CWarrior.RefreshPerformCD(self, pflist)
	local iAuto, iQuick = self:GetAutoQuickSkills()
	for i, pf in ipairs(pflist) do
		local iMagicId = pf.pf_id
		self.m_PfCd[iMagicId] = pf.cd
		if iMagicId == iAuto or iMagicId == iQuick then
			g_WarCtrl:RefreshMagicBtnCd(self.m_ID == g_WarCtrl.m_HeroWid)
		end
	end
end

function CWarrior.CheckPerformCDs(self)
	local iAuto, iQuick = self:GetAutoQuickSkills()
	local iCurBout = g_WarCtrl:GetBout()
	if iAuto and iCurBout==self.m_PfCd[iAuto] then
		g_WarCtrl:RefreshMagicBtnCd(self.m_ID == g_WarCtrl.m_HeroWid)
	elseif iQuick and iCurBout==self.m_PfCd[iQuick] then 
		g_WarCtrl:RefreshMagicBtnCd(self.m_ID == g_WarCtrl.m_HeroWid)
	end
end

function CWarrior.UpdateAttrBuff(self)
	local iAttack = 0
	local iDefense = 0
	local iSpeed = 0
	for id, dBuffInfo in pairs(self.m_Buffs) do
		for i,dAttr in ipairs(dBuffInfo.attrlist) do
			local iValue = dAttr.value or 0
			if dAttr.key == "phy_attack" or dAttr.key == "mag_attack" then
				iAttack = iAttack + iValue
			elseif dAttr.key == "phy_defense" or dAttr.key == "mag_defense" then
				iDefense = iDefense + iValue
			elseif dAttr.key == "speed" then
				iSpeed = iSpeed + iValue
			end
		end
	end

	self.m_AttrBuffList:UpdateAllAttr(iAttack, iDefense, iSpeed)
end

function CWarrior.CloseDetailView(self)
	local oView = CWarTargetDetailView:GetView()
	if oView then
		local oWarrior = oView:GetWarrior()
		if self == oWarrior then
			CWarTargetDetailView:CloseView()
		end
	end
end

function CWarrior.IsSameCamp(self, oWarrior)
	return self.m_CampID == oWarrior.m_CampID
end

function CWarrior.IsNeighbor(self, oWarrior)
	if not self:IsSameCamp(oWarrior) then
		return
	end
	local iCampPos = oWarrior.m_CampPos
	local dNeighborData = data.lineupdata.NEIGHBOR_POS[self.m_CampPos]
	if dNeighborData then
		return dNeighborData[iCampPos]
	end
end

function CWarrior.GetNormalAttackPos(self, oWarrior)
	if gameconfig.Issue.Releases then
		return nil
	end
	local bIsNearOriPos = oWarrior:IsNearOriPos(oWarrior:GetPos())
	local bIsBossCamp = g_WarCtrl:IsBossWarType() and not oWarrior:IsAlly()
	local bIsNeighbor = self:IsNeighbor(oWarrior)
	if not bIsBossCamp and not bIsNeighbor and bIsNearOriPos then
		return oWarrior:GetOriginPos()
	end
end

-- 被动技能复活
function CWarrior.PassiveReborn(self, excuteCb, endCb)
	local dieTime, reliveTime = 0.9, 0.3
	self:SetBusy(true, "PassiveReborn")
	g_WarCtrl:InsertAction(CWarCmd.WaitOne, self, "IsBusy", false)
	self:Die()
	Utils.AddTimer(function()
		if Utils.IsNil(self) then return end
		self:Relive()
		if excuteCb then
			excuteCb()
		end
	end, 0, dieTime)
	Utils.AddTimer(function()
		if Utils.IsNil(self) then return end
		self:SetBusy(false, "PassiveReborn")
		if endCb then
			endCb()
		end
	end, 0, dieTime + reliveTime)
end


-- 魄实现
function CWarrior.RefeshStatusGohst(self, buffid, statukey, statulevel)
	local dBuffInfo = self.m_StatuBuffs[buffid]
	local bDeleteStatuBuff = (statulevel or 0) <= 0
	-- printc("RefeshStatusGohst")
	-- table.print(dBuffInfo)
	if dBuffInfo then
		if bDeleteStatuBuff then
			if dBuffInfo.obj then
				dBuffInfo.obj:Clear()
			end
			dBuffInfo = nil
			self:ProcessSpecailBuff(buffid, false)
		else
			dBuffInfo.statukey = statukey
			dBuffInfo.statulevel = statulevel
		end
	elseif not bDeleteStatuBuff then
		local obj = CWarBuff.New(buffid, self)
		dBuffInfo = {
			obj = obj,
			statukey = statukey,
			statulevel = statulevel,
			buff_id = buffid,
		}
		self:ProcessSpecailBuff(buffid, true)
	end
	if dBuffInfo and dBuffInfo.obj then
		dBuffInfo.obj:SetLevel(statulevel)
	end
	self.m_StatuBuffs[buffid] = dBuffInfo
	self:AddHud("warrior_buff", CWarriorBuffHud, self.m_HudNode.m_HeadHudTable, function(oHud) 
		oHud:RefreshBuff(buffid, 1, statulevel)
	end, true)
end

function CWarrior.ClearStatuBuffs(self)
	for id, dBuffInfo in pairs(self.m_StatuBuffs) do
		self:RefeshStatusGohst(id, 0, dBuffInfo.level)
	end
	self.m_StatuBuffs = {}
end

return CWarrior