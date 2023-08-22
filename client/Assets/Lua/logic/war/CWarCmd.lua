local CWarCmd = class("CWarCmd")

function CWarCmd.ctor(self, NameorFunc)
	self.m_ID = g_WarCtrl:GetCmdID()
	self.m_Func = NameorFunc
	self.m_IsUsed = false
	self.m_VaryInfo = {} --这回合状态的改变，只有部分cmd才能记录
end

function CWarCmd.Excute(self, ...)
	if not self:IsUsed() then
		self:SetUsed(true)
		if type(self.m_Func) == "function" then
			-- printc("Excute: m_Func")
			self.m_Func()
		else
			-- printc("Excute: " .. self.m_Func)
			local f = self[self.m_Func]
			if f then
				return f(self, ...)
			else
				error("CWarCmd not funndFunc:" .. self.m_Func)
			end
		end
	end
end

function CWarCmd.ClearVary(self)
	for wid, dVary in pairs(self.m_VaryInfo) do
		self:ClearWarriorVary(wid, dVary)
	end
end

function CWarCmd.ClearWarriorVary(self, wid)
	local dVary = self.m_VaryInfo[wid]
	if dVary then 
		local oWarrior = g_WarCtrl:GetWarrior(wid)
		if oWarrior and oWarrior:IsBusy("PassiveReborn") then
			self:CheckPassiveRebornVary(dVary, wid)
			return
		end
		local lKeys = {"damage_list", "addMp_list", "buff_list"}
		for _, key in ipairs(lKeys) do
			local list = dVary[key]
			if list and next(list) then
				for i, oCmd in ipairs(list) do
					oCmd:Excute()
				end
			end
			dVary[key] = nil
		end
		if oWarrior then
			local lHP = dVary.hp_list
			if lHP and next(lHP) then
				lHP[1] = lHP[#lHP] --用最后的血量去刷新
				oWarrior:RefreshBlood(dVary)
				g_WarCtrl:WarriorStatusChange(wid)
			end
			if dVary.status then
				local bAlive = dVary.status == define.War.Status.Alive
				if not bAlive then
					self:CheckDelVary(dVary)
				end
				oWarrior:SetAlive(bAlive)
			end
			oWarrior:UpdateStatus(dVary)
		else
			local oAddCmd = dVary["add_warriorcmd"]
			if oAddCmd then
				oAddCmd:Excute()
			end
			dVary["add_warriorcmd"] = nil
		end
		dVary["hp_list"] = nil
	end
end

function CWarCmd.CheckDelVary(self, dVary)
	local oCmd = dVary.del_cmd
	if not oCmd then return end
	local insertfunc = WarTools.GetMainInsertActionFunc()
	local delObj = g_WarCtrl:GetWarrior(oCmd.wid)
	if not delObj then
		return
	end
	if oCmd.type == 1 then
		insertfunc(CWarrior.FlyOut, delObj)
	else
		insertfunc(CWarrior.Blink, delObj)
	end
	dVary.del_cmd = nil
end

function CWarCmd.LockVary(self, dVary, bLock)
	dVary.lock = dVary
end

function CWarCmd.IsUsed(self)
	return self.m_IsUsed
end

function CWarCmd.SetUsed(self, b)
	self.m_IsUsed = b
end

function CWarCmd.SetVary(self, wid, k, v)
	local d = self.m_VaryInfo[wid]
	if not d then
		d = {}
	end
	d[k] = v
	self.m_VaryInfo[wid] = d
end

function CWarCmd.GetVary(self, wid, k)
	local d = self.m_VaryInfo[wid]
	if d then
		return d[k]
	end
end

function CWarCmd.GetWarriorVary(self, wid)
	return self.m_VaryInfo[wid] or {}
end

--help func
function CWarCmd.WaitOne(tOne, k, v, ...)
	if Utils.IsNil(tOne) then
		return true
	end
	local vv = tOne[k]
	if type(vv) == "function" then
		vv = vv(tOne, ...)
	end
	return table.equal(vv, v)
end

function CWarCmd.WaitAll(tAll, k, v)
	for _, tOne in pairs(tAll) do
		if not CWarCmd.WaitOne(tOne, k, v) then
			return false
		end
	end
	return true
end

function CWarCmd.InsertDelOrAlive(dVary, oWarrior, insertfunc)
	if g_WarCtrl.g_Print then
		-- printerror("========= CWarCmd.InsertDelOrAlive 是否死亡", oWarrior:GetName() .. " | " .. oWarrior.m_ID)
		-- table.print(dVary)
	end

	if dVary.del_cmd then
		local oCmd = dVary.del_cmd
		local delObj = g_WarCtrl:GetWarrior(oCmd.wid)
		if not delObj then
			return
		end
		if oCmd.type == 1 then
			insertfunc(CWarrior.FlyOut, delObj)
		else
			insertfunc(CWarrior.Blink, delObj)
		end
		-- insertfunc(CWarCmd.WaitOne, delObj, "IsBusy", false)
		dVary.del_cmd = nil
	elseif dVary.status then
		local bAlive = dVary.status == define.War.Status.Alive
		insertfunc(CWarrior.SetAlive, oWarrior, bAlive)
		dVary.status = nil
	end
end

--cmd func
function CWarCmd.WarResult(oCmd)
	if not g_WarCtrl:IsWar() then
		return
	end
	if g_WarCtrl.m_IsInResult then
		return
	end
	CWarMainView:CloseView()
	--CWarWorldBossView:CloseView()
	--CWarOrgBossView:CloseView()
	--local warType = g_WarCtrl:GetWarType()
	--printc("WarResult", warType, oCmd.win)
	if oCmd.win then
		for i, oWarrior in pairs(g_WarCtrl:GetWarriors()) do
			oWarrior:CrossFade("show", 0.1)
		end
		g_CameraCtrl:PlayAction("war_win")
		local function winview()
			-- 根据不同的战斗类型，打开不同的战斗结算界面
			CWarWinView:ShowView(function(oView)
				oView:SetWarID(oCmd.war_id)
			end)
		end
		Utils.AddTimer(winview, 1, 2)
	else
		--根据不同的战斗类型，打开不同的战斗结算界面
		CWarFailView:ShowView()
	end
	g_WarCtrl:SetInResult(true)
	g_WarCtrl:InsertAction(CWarCmd.WaitOne, g_WarCtrl, "m_IsInResult", false)
end

function CWarCmd.End(oCmd)
	if g_WarCtrl.g_Print then
		printc("CWarCmd.End")
	end
	if g_WarCtrl.m_IsFirstSpecityWar then
		g_WarCtrl:End()
		return
	end
	g_WarCtrl:InsertAction(CWarCmd.WaitOne, g_WarCtrl, "IsAllExcuteFinish", true)
	g_WarCtrl:InsertAction(g_WarCtrl.End, g_WarCtrl)
end

function CWarCmd.ShowSceneEndWar( oCmd )
	g_WarCtrl:ShowSceneEndWar()
end

function CWarCmd.ShowMaskView(oCmd)
	if g_WarCtrl.m_IsFirstSpecityWar then
		g_WarCtrl:SetShowMaskView(true)
		g_WarCtrl:InsertAction(CWarCmd.WaitOne, g_WarCtrl, "IsShowMaskView", false)
		CPlotMaskView:ShowView(function(oView)
			if g_WarCtrl.m_WarSessionidx then
				netother.C2GSCallback(g_WarCtrl.m_WarSessionidx, 1, nil, nil, 1)
			end
			local oMaskAction = {
				active = true,
				content = "许仙的七魄被打散，流落四方。",
				duration = 3,
				endColor = {
					a = 1,
					b = 0.0039215688593686,
					g = 0.0039215688593686,
					r = 0.0039215688593686,
				},
				fade = true,
				fadeInTime = 0,
				fadeOutTime = 3,
				fadeTweenTime = 0.40000000596046,
				fontSize = 22,
				msgEndTime = 2.5,
				msgStartTime = 0.5,
				startColor = {
					a = 0,
					b = 0.0039215688593686,
					g = 0.0039215688593686,
					r = 0.0039215688593686,
				},
				startTime = 0,
			}

			Utils.AddTimer(function ()
				g_WarCtrl:SetShowMaskView(false)
				return false
			end, 0, 2.5)

			oView:ExcuteMaskAction(oMaskAction, function ()
				local oView = CWarMainView:GetView()
				if oView then
					oView.m_Content:EnableTouch(false)
				end
				g_WarCtrl.m_IsFirstSpecityWar = false
				oView:CloseView()
			end)
		end)
		return
	end
end

function CWarCmd.BoutStart(oCmd)
	-- http://oa.cilugame.com/redmine/issues/22849
	-- 竞技场连续战斗的问题，延迟一下
	if g_WarCtrl:IsChallengeType() and oCmd.bout_id == 1 then
		local time = Utils.IsEditor() and 3 or 1
		g_WarCtrl.m_WaitTime = true
		g_WarCtrl:InsertAction(CWarCmd.WaitOne, g_WarCtrl, "m_WaitTime", false)
		Utils.AddTimer(function ()
			g_WarCtrl:BoutStart(oCmd.bout_id, oCmd.left_time)
			g_WarCtrl.m_WaitTime = false
			return false
		end, 1, time)
	else
		g_WarCtrl:InsertAction(CWarCmd.WaitOne, g_WarCtrl, "IsAllExcuteFinish", true)
		g_WarCtrl:InsertAction(CWarCmd.WaitOne, g_WarCtrl, "WaitBoutStart", true, oCmd.bout_id, oCmd.left_time)

		-- g_WarCtrl:BoutStart(oCmd.bout_id, oCmd.left_time)
	end

	-- g_WarCtrl:InsertAction(CWarCmd.WaitOne, g_WarCtrl, "WaitBoutStart", true, oCmd.bout_id, oCmd.left_time)
	
	-- g_WarTouchCtrl:SetLock(false)
	-- g_WarCtrl:InsertAction(CWarCmd.WaitOne, g_WarCtrl, "IsAllExcuteFinish", true)
	-- g_WarCtrl:InsertAction(CWarCmd.WaitOne, g_WarCtrl, "WaitBoutStart", true, oCmd.bout_id, oCmd.left_time)
end

function CWarCmd.BoutEnd(oCmd)
	g_WarCtrl:BoutEnd()
end

function CWarCmd.AddWarrior(oCmd)
	if oCmd.type == define.Warrior.Type.Summon or  oCmd.type == define.Warrior.Type.Npc or 
		oCmd.type == define.Warrior.Type.RoSummon then
		local oWarrior = g_WarCtrl:GetWarriorByPos(oCmd.camp_id, oCmd.info.pos)
		if oWarrior then
			g_WarCtrl:DelWarrior(oWarrior.m_ID)
		end
	end
	local oWarrior = WarTools.CreateWarrior(oCmd.type, oCmd.camp_id, oCmd.info)
	g_WarCtrl:AddWarrior(oWarrior.m_ID, oWarrior)
	if oCmd.type == define.Warrior.Type.Player or oCmd.type == define.Warrior.Type.Summon then
		oWarrior:UpdateAutoMagic()
	end
	if oWarrior.m_ID == g_WarCtrl.m_HeroWid and #oWarrior:GetSpecialSkillList() > 0 then
		g_WarCtrl:OnEvent(define.War.Event.RefreshSpecialSkill)
	end
	--召唤宠物需特效
	if oCmd.is_summon == 1 then
		oWarrior:ShowSummonEffect()
		g_WarCtrl:InsertAction(CWarCmd.WaitOne, oWarrior, "IsBusy", false)
	else
		oWarrior:ShowWarAnim()
	end
	return oWarrior
end

function CWarCmd.DelWarrior(oCmd)
	local delObj = g_WarCtrl:GetWarrior(oCmd.wid)
	if oCmd.type == 1 then
		g_WarCtrl:InsertAction(CWarrior.FlyOut, delObj)
	else
		g_WarCtrl:InsertAction(CWarrior.Blink, delObj)
	end
	g_WarCtrl:InsertAction(CWarCmd.WaitOne, delObj, "IsBusy", false)
end

function CWarCmd.Wave(oCmd)
	g_WarCtrl:InsertAction(CWarCmd.WaitOne, g_MagicCtrl, "IsExcuteMagic", false)
	g_WarCtrl:InsertAction(CWarCtrl.SetWave, g_WarCtrl, oCmd.cur_wave, oCmd.sum_wave)
end

function CWarCmd.GoBack(oCmd)
	WarTools.TimeStart("GoBack")
	local objs = {}
	local bMainAction = oCmd.wait and not g_WarCtrl.m_WaitBoutStart
	for i, wid in ipairs(oCmd.wid_list) do
		local oWarrior = g_WarCtrl:GetWarrior(wid)
		if g_WarCtrl.g_Print then
			printc(" === CWarCmd.GoBack ===", oWarrior and oWarrior:GetName())
		end
		if oWarrior then
			local insert
			local list = {}
			if bMainAction then
				insert = function(...) g_WarCtrl:InsertAction(...) end
			else
				insert = WarTools.GetQuickInsertActionFunc(list)
			end
			insert(CWarCmd.WaitOne, oWarrior, "m_PlayMagicID", nil)
			insert(CWarCmd.WaitOne, oWarrior, "IsBusy", false)
			if not oWarrior:IsNearOriPos(oWarrior:GetLocalPos()) and g_MagicCtrl:TryGetFile(define.Magic.SpcicalID.GoBack, oWarrior:GetBasicShape()) then
				local requiredata = {
					refAtkObj = weakref(oWarrior), refVicObjs = {},
				}
				
				local oBackUnit = g_MagicCtrl:NewMagicUnit(define.Magic.SpcicalID.GoBack, oWarrior:GetBasicShape(), oWarrior:GetBasicShape(), requiredata)
				
				local function onEnd()
					if Utils.IsExist(oWarrior) then
						if not oWarrior:IsAlive() then
							oWarrior:Die()
						end
						oWarrior:SetBusy(false, "goback")
					end
				end
				oBackUnit:SetEndCallback(onEnd)
				insert(CMagicUnit.Start, oBackUnit)
				insert(CWarrior.SetBusy, oWarrior, true, "goback")
			else
				insert(CWarrior.GoBack, oWarrior)
			end
			if bMainAction then
				table.insert(objs, oWarrior)
			else
				g_WarCtrl:AddSubActionList(list)
			end
		end
	end
	if bMainAction then
		g_WarCtrl:InsertAction(CWarCmd.WaitAll, objs, "IsBusy", false)
	end
	WarTools.TimeEnd("GoBack")
end

function CWarCmd.Buff(oCmd)
	local oWarrior = g_WarCtrl:GetWarrior(oCmd.wid)
	if oWarrior then
		oWarrior:RefreshBuff(oCmd.buff_id, oCmd.bout, oCmd.level, oCmd.need_tips, oCmd.attrlist)
	end
end

function CWarCmd.WarriorStatus(oCmd)
	local oWarrior = g_WarCtrl:GetWarrior(oCmd.wid)
	if oWarrior then
		if oCmd.status.status then
			local bAlive = oCmd.status.status == define.War.Status.Alive
			oWarrior:SetAlive(bAlive)
		end
		oWarrior:UpdateStatus(oCmd.status)
	end
end

function CWarCmd.Magic(oCmd)
	local atkid = oCmd.atkid_list[1]
	local atkObj= g_WarCtrl:GetWarrior(atkid)
	if not atkObj then
		printc("Magic err atkObj", atkid)
		return
	end

	local dAtkVary = oCmd:GetWarriorVary(atkid)
	if dAtkVary.trigger_passive and next(dAtkVary.trigger_passive) then
		for i=#dAtkVary.trigger_passive, 1, -1 do
			local oCmd = dAtkVary.trigger_passive[i]
			local passiveData = DataTools.GetMaigcPassiveData(oCmd.pfid)
			if passiveData and passiveData.timing == 1 then
				oCmd:Excute()
				table.remove(dAtkVary.trigger_passive, i)
			end
		end
	end
	oCmd:CheckNotifyCmds(dAtkVary, 0)

	if dAtkVary.infoBulletBarrage_cmd then
		local oCmd = dAtkVary.infoBulletBarrage_cmd
		oCmd:Excute()
	end

	if not next(oCmd.vicid_list) then
		local list = {}
		local insert = WarTools.GetQuickInsertActionFunc(list)
		CWarCmd.InsertDelOrAlive(dAtkVary, atkObj, insert)
		g_WarCtrl:AddSubActionList(list)
	end

	local oWarriors = g_WarCtrl:GetWarriors()
	for k,v in pairs(oWarriors) do
		local oVary = oCmd:GetWarriorVary(k)
		if oVary.speek_cmd then
			local oCmd = oVary.speek_cmd
			if oCmd.flag == 0 then
				-- 0：技能开即时生效
				oCmd:Excute()
			end
		end
	end

	local refAtkObj = weakref(atkObj)
	local refVicObjs = {}
	local objs = {atkObj}
	--table.print(oCmd, "Magic")
	for i, id in ipairs(oCmd.vicid_list) do
		local oWarrior = g_WarCtrl:GetWarrior(id)
		if oWarrior then
			table.insert(objs, oWarrior)
			table.insert(refVicObjs, weakref(oWarrior))
		end
	end
	local requiredata = {
		refAtkObj = refAtkObj,
		refVicObjs = refVicObjs,
	}

	local oMagicUnit = g_MagicCtrl:NewMagicUnit(oCmd.magic_id, atkObj:GetBasicShape(), oCmd.magic_index, requiredata, oCmd.isPursued)
	printc("CWarCmd.Magic", oMagicUnit:GetDesc())
	WarTools.TimeStart(oMagicUnit:GetDesc())
	oMagicUnit:SetLayer(UnityEngine.LayerMask.NameToLayer("War"))
	oMagicUnit:SetHitCallback(callback(oCmd, "MagicHitCallback"))
	oMagicUnit:SetEndCallback(callback(g_WarCtrl, "OnEvent", define.War.Event.CommandDone, atkid))
	local oVic = oMagicUnit:GetVicObjFirst()
	local bWaitGoback = true
	local time
	local lNextVics = g_WarCtrl:GetNextCmdVics(oCmd.m_ID)
	local lIntersect = table.intersect(oCmd.vicid_list, lNextVics)
	if g_WarCtrl.g_Print then
		table.print(lNextVics, "下一指令受击者:")
		table.print(lIntersect, "受击者交集:")
	end
	 -- 如果当前受击者不在下一次法术受击者列表中
	 -- 则表示这一次法术是这次浮空的结束
	if #lIntersect > 0 then
		for i, wid in ipairs(lIntersect) do
			local oWarrior = g_WarCtrl:GetWarrior(wid)
			if oWarrior then
				local bIsFloat = oWarrior:IsFloatAtkID(atkObj.m_ID)
				if g_WarCtrl.g_Print then
					print("检测是否浮空", oMagicUnit:GetDesc(), wid, bIsFloat)
					table.print(oWarrior.m_FloatHitInfo, "受击者浮空信息")
				end
				if bIsFloat then
					time = g_WarCtrl:GetNexCmdRunTime(wid, oCmd.m_ID)
					if time then 
						bWaitGoback = false
						if g_WarCtrl.g_Print then
							print(oCmd.magic_id, "浮空移到子行动列表时间:", time, "攻击者:", atkid)
						end
						oMagicUnit:SetSubActionListTime(time)
						break
					end
				end
			end
		end
	end
	if oMagicUnit.m_AtkStopHit then
		g_WarCtrl:InsertAction(CWarrior.StopHit, atkObj)
	end
	local dMagicInfo = g_WarCtrl:GetBoutMagicInfo(oCmd.m_ID, 0)
	if dMagicInfo then
		dMagicInfo.magic_unit_id = oMagicUnit.m_ID
		dMagicInfo.sub_time = time
		oMagicUnit:SetIsEndIdx(dMagicInfo.is_end_idx)
	end

	local waitAllSta = false
	-- 等特效结束
	local dPreMagicInfo = g_WarCtrl:GetBoutMagicInfo(oCmd.m_ID, -1)
	if dPreMagicInfo then
		if g_WarCtrl.g_Print then
			print(string.format("<<< 上一法术信息 | magic:%s | atkid:%s | sub_time:%s", dPreMagicInfo.magic, dPreMagicInfo.atkid, dPreMagicInfo.sub_time))
		end
		if not dPreMagicInfo.sub_time then
			if oMagicUnit.m_WaitGoback then
				if not (dPreMagicInfo.magic == 1608 and oMagicUnit.m_MagicID == dPreMagicInfo.magic) then
					if g_WarCtrl.g_Print then
						print("等待归位", dPreMagicInfo.magic)
					end
					g_WarCtrl:InsertAction(CWarCmd.WaitAll, objs, "IsBusy", false)
					waitAllSta = true
				end
			end
			local oPreUnit = g_MagicCtrl:GetMagicUnit(dPreMagicInfo.magic_unit_id)
			if dPreMagicInfo.is_end_idx and not dPreMagicInfo.is_first_idx and oPreUnit then
				local oWarrior = g_WarCtrl:GetWarrior(dPreMagicInfo.atkid)
				if oWarrior then
					local dMagicTimeInfo = DataTools.GetMagicTimeInfo(dPreMagicInfo.magic, oWarrior:GetBasicShape(), dPreMagicInfo.idx)
					local maigcIdxSta = dMagicTimeInfo and dPreMagicInfo.idx > 1 and dPreMagicInfo.idx == #dMagicTimeInfo

					local dFile = g_MagicCtrl:GetFileData(dPreMagicInfo.magic, oWarrior:GetBasicShape(), dPreMagicInfo.idx)
					local hitSta = true
					if dFile and dFile.cmds and #dFile.cmds > 0 then
						for _,v in ipairs(dFile.cmds) do
							if v.func_name == "VicHitInfo" then
								if v.args.play_anim == false then
									hitSta = false
								end
							end
						end
					end
					local atkIdSta = dMagicInfo and table.index(dPreMagicInfo.vicids, dMagicInfo.atkid)
					if maigcIdxSta or (hitSta and atkIdSta) then
						if g_WarCtrl.g_Print then
							print(oCmd.magic_id, "等待前一法术播放完毕", oPreUnit:GetDesc(), oPreUnit:IsGarbage())
						end
						g_WarCtrl:InsertAction(CWarCmd.WaitOne, oPreUnit, "IsGarbage", true)
					end
				end
			end
		end
	end
			
	-- 当有等待全部时不需要等待受击
	if not waitAllSta and dMagicInfo then
		-- 等受击结束
		local dMagicTimeInfo = DataTools.GetMagicTimeInfo(dMagicInfo.magic, atkObj:GetBasicShape(), dMagicInfo.idx)
		if dMagicTimeInfo and dMagicTimeInfo[1] < dMagicTimeInfo[3] then
			local dNextMagicInfo = g_WarCtrl:GetBoutMagicInfo(oCmd.m_ID, 1)
			if dNextMagicInfo then
				if g_WarCtrl.g_Print then
					print(string.format(">>> 下一法术信息 | magic:%s | atkid:%s | sub_time:%s", dNextMagicInfo.magic, dNextMagicInfo.atkid, dNextMagicInfo.sub_time))
				end

				for _,v in ipairs(dNextMagicInfo.vicids) do
					if table.index(dMagicInfo.vicids, v) then
						local vObj = g_WarCtrl:GetWarrior(v)
						vObj:WaitHit()
					end
				end
			end
		end
	end

	g_WarCtrl:InsertAction(CMagicUnit.Start, oMagicUnit, oCmd)
	g_WarCtrl:InsertAction(CWarCmd.WaitOne, oMagicUnit, "m_IsEnd", true)
	if not oMagicUnit.m_LastHitInfoIndex then
		g_WarCtrl:InsertAction(CMagicUnit.CheckClearVary, oMagicUnit, oCmd)
	end
	WarTools.TimeEnd(oMagicUnit:GetDesc())
	local oGobackCmd = oCmd:GetVary(atkid, "go_back")
	if oGobackCmd then
		oCmd:SetVary(atkid, "go_back", nil)
		if oMagicUnit.m_IsEndIdx then
			oGobackCmd.wait = bWaitGoback
			g_WarCtrl:InsertAction(CWarCmd.Excute, oGobackCmd)
			if g_WarCtrl.g_Print then
				printc("增加归位指令", oMagicUnit:GetDesc(), bWaitGoback)
			end
		else
			if g_WarCtrl.g_Print then
				printc("不处理归位指令", oMagicUnit:GetDesc())
			end
		end
	end

	-- 保护先跑过去
	for i, id in ipairs(oCmd.vicid_list) do
		local oWarrior = g_WarCtrl:GetWarrior(id)
		if oWarrior then
			local dVicVary = oCmd:GetWarriorVary(oWarrior.m_ID)
			if dVicVary.protect_id then
				local list = {}
				local insert = WarTools.GetQuickInsertActionFunc(list)
				local protectObj = g_WarCtrl:GetWarrior(dVicVary.protect_id)
				local pos = Vector3.Lerp(oWarrior:GetLocalPos(), atkObj:GetLocalPos(), 0.1)
				insert(CWarrior.RunTo, protectObj, pos, 10)
				-- oMagicUnit:Wait(CWarCmd.WaitOne, protectObj, "IsBusy", false)
				insert(CWarCmd.WaitOne, protectObj, "IsBusy", false)
				g_WarCtrl:AddSubActionList(list)

				local protectVicVary = oCmd:GetWarriorVary(dVicVary.protect_id)
				if protectVicVary.trigger_passive and next(protectVicVary.trigger_passive) then
					for i=#protectVicVary.trigger_passive, 1, -1 do
						local oCmd = protectVicVary.trigger_passive[i]
						local passiveData = DataTools.GetMaigcPassiveData(oCmd.pfid)
						oCmd:Excute()
						table.remove(protectVicVary.trigger_passive, i)
					end
				end
			end
		end
	end
end

function CWarCmd.MagicHitCallback(oCmd, oMagicUnit, hitInfo, bLastHit)
	if g_WarCtrl.g_Print then
		-- printc(" ====== MagicHitCallback 受击啦。。。。", bLastHit)
	end
	local atkObj = hitInfo.atkObj
	local dAtkVary = oCmd:GetWarriorVary(atkObj.m_ID)
	-- Alottodo 攻击方，也需要受击信息，改变血条、灵气等数据显示内容
	if dAtkVary then
		local list = {}
		local insert = WarTools.GetQuickInsertActionFunc(list)
		insert(CWarrior.Hurt, atkObj, dAtkVary)
		insert(CWarrior.AddMp, atkObj, dAtkVary)
		g_WarCtrl:AddSubActionList(list)
		CWarCmd.InsertDelOrAlive(dAtkVary, atkObj, insert)
	end

	local oWarriors = g_WarCtrl:GetWarriors()
	for k,v in pairs(oWarriors) do
		local oVary = oCmd:GetWarriorVary(k)
		if oVary.speek_cmd then
			local oCmd = oVary.speek_cmd
			if oCmd.flag == 1 then
				-- 1：受击时生效
				oCmd:Excute()
			end
		end
		oCmd:CheckNotifyCmds(dAtkVary, 1)

		-- 非攻击者、受击者 会加蓝
		local list = {}
		local insert = WarTools.GetQuickInsertActionFunc(list)
		g_WarCtrl:AddSubActionList(list)
		insert(CWarrior.AddMp, v, oVary)

		-- 被动技能
		-- 排除受击的id
		local dopassive = true
		for _,vobj in pairs(hitInfo.vicObjs) do
			if vobj.m_ID == k then
				dopassive = false
				break
			end
		end
		if dopassive then
			if oVary.trigger_passive and next(oVary.trigger_passive) then
				for i=#oVary.trigger_passive, 1, -1 do
					local oCmd = oVary.trigger_passive[i]
					if oCmd.key_list then
						oCmd:TriggerPassiveSkill(insert)
					else
						local passiveData = DataTools.GetMaigcPassiveData(oCmd.pfid)
						if passiveData and passiveData.timing == 2 then
							oCmd:Excute()
							table.remove(oVary.trigger_passive, i)
						end
					end
				end
			end
		end
	end

	--添加额外的受击对象，以处理因被动技能导致的死亡状态
	oCmd:AddExtraObj(atkObj.m_ID, hitInfo.vicObjs)
	oCmd:ExcuteProtectAction(atkObj, oMagicUnit, hitInfo)
	for i, vicObj in ipairs(hitInfo.vicObjs) do
		local list = {}
		local insert = WarTools.GetQuickInsertActionFunc(list)
		local dVicVary = oCmd:GetWarriorVary(vicObj.m_ID)
		local bPassiveReborn = false
		if dVicVary.trigger_passive then
			for i,v in ipairs(dVicVary.trigger_passive) do
				if v.key_list then
					v:TriggerPassiveSkill(insert)
				else
					local passiveData = DataTools.GetMaigcPassiveData(v.pfid)
					if passiveData and passiveData.timing == 2 then
						if oCmd:IsPassiveReborn(v.pfid) then
							local excuteCb = callback(v, "Excute")
							local endCb = callback(oCmd, "ClearWarriorVary", vicObj.m_ID)
							vicObj:PassiveReborn(excuteCb, endCb)
							bPassiveReborn = true
						else
							v:Excute()
						end
					end
				end
			end
			dVicVary.trigger_passive = nil
		end
		insert(CWarrior.ProcessBuffBeforeHit, vicObj, dVicVary)
		if not bPassiveReborn then
			oCmd:ExcuteDamage(atkObj, insert, false, vicObj, dVicVary, hitInfo.face_atk, hitInfo.play_anim, hitInfo.hit_shot)
		end

		if hitInfo.iHurtDelta > 0 then
			insert(CWarrior.WaitTime, vicObj, hitInfo.iHurtDelta)
			insert(CWarCmd.WaitOne, vicObj, "IsBusy", false)
		end

		--跳过一次mainaction处理，确保subaction执行让下方isbusy状态有效
		g_WarCtrl:InsertAction(CWarCtrl.SkipActionProcess, g_WarCtrl)

		local dMagicInfo = g_WarCtrl:GetBoutMagicInfo(oCmd.m_ID, 0)
		local dNextMagicInfo = g_WarCtrl:GetBoutMagicInfo(oCmd.m_ID, 1)
		local specityList = {8102, 1608}
		if dMagicInfo and table.index(specityList, dMagicInfo.magic) then
			g_WarCtrl.m_SpecityMaigcIndex = (g_WarCtrl.m_SpecityMaigcIndex or 0) + 1
			if g_WarCtrl.m_SpecityMaigcIndex > 2 and dMagicInfo.idx == 2 then
				if not dNextMagicInfo or dMagicInfo.magic ~= dNextMagicInfo.magic then
					g_WarCtrl:InsertAction(CWarCmd.WaitOne, vicObj, "IsBusy", false)
				end
			end
		else
			g_WarCtrl.m_SpecityMaigcIndex = 0
			g_WarCtrl:InsertAction(CWarCmd.WaitOne, vicObj, "IsBusy", false)
		end
		g_WarCtrl:InsertAction(CWarrior.UpdateStatus, vicObj, dVicVary)
		-- if dProtectVary then
		-- 	CWarCmd.InsertDelOrAlive(dProtectVary, protectObj, insert)
		-- end
		--确保死亡检查有效
		CWarCmd.InsertDelOrAlive(dVicVary, vicObj, insert)
		if bLastHit and i == #hitInfo.vicObjs then
			insert(CWarCmd.ClearVary, oCmd)
		end
		g_WarCtrl:AddSubActionList(list)
	end
end

function CWarCmd.ExcuteDamage(oCmd, atkObj, insert, bIsForce, oWarrior, dVary, faceAtk, playAnim, shot)
	if dVary.damage_list or bIsForce then
		insert(CWarrior.BeginHit, oWarrior, atkObj, dVary, faceAtk, playAnim, shot)
		CWarCmd.InsertDelOrAlive(dVary, oWarrior, insert)
		insert(CWarCmd.WaitOne, oWarrior, "IsBusy", false)
	end
	if dVary.addMp_list then
		insert(CWarrior.AddMp, oWarrior, dVary)
		insert(CWarCmd.WaitOne, oWarrior, "IsBusy", false)
	end
end

function CWarCmd.ExcuteProtectAction(oCmd, atkObj, oMagicUnit, hitInfo)
	for i, vicObj in ipairs(hitInfo.vicObjs) do
		local list = {}
		local insert = WarTools.GetQuickInsertActionFunc(list)
		local dVicVary = oCmd:GetWarriorVary(vicObj.m_ID)
		
		local protectObj, dProtectVary
		if dVicVary.protect_id then
			protectObj = g_WarCtrl:GetWarrior(dVicVary.protect_id)
			dProtectVary = oCmd:GetWarriorVary(dVicVary.protect_id)
			local pos = Vector3.Lerp(vicObj:GetLocalPos(), atkObj:GetLocalPos(), 0.2)
			-- insert(CWarrior.RunTo, protectObj, pos)
			-- oMagicUnit:Wait(CWarCmd.WaitOne, protectObj, "IsBusy", false)
			insert(CWarCmd.WaitOne, protectObj, "IsBusy", false)
		end
		if protectObj then
			oCmd:ExcuteDamage(atkObj, insert, true, protectObj, dProtectVary, hitInfo.face_atk, hitInfo.play_anim, hitInfo.hit_shot)
		end

		if dProtectVary then
			CWarCmd.InsertDelOrAlive(dProtectVary, protectObj, insert)
		end
		g_WarCtrl:AddSubActionList(list)
	end
end

function CWarCmd.AddExtraObj(self, iAtkid, lVicObjs)
	local dVicObjs = {}
	for i,obj in ipairs(lVicObjs) do
		dVicObjs[obj.m_ID] = true
		local dVicVary = self:GetWarriorVary(obj.m_ID)
		if dVicVary.protect_id then
			dVicObjs[dVicVary.protect_id] = true
		end
	end
	for wid, dVary in pairs(self.m_VaryInfo) do
		local oWarrior = g_WarCtrl:GetWarrior(wid)
		if wid ~= iAtkid and not dVicObjs[wid] and oWarrior then
			if dVary.del_cmd then
				table.insert(lVicObjs, oWarrior)
			elseif dVary.status then
				table.insert(lVicObjs, oWarrior)
			end
		end
	end
end

function CWarCmd.Escape(oCmd)
	WarTools.TimeStart("Escape")
	for i,v in ipairs(oCmd.action_wid) do
		local oWarrior = g_WarCtrl:GetWarrior(v)
		if oWarrior then
			g_WarCtrl:InsertAction(CWarrior.Escape, oWarrior, oCmd.success)
			if i == #oCmd.action_wid then
				g_WarCtrl:InsertAction(CWarCmd.WaitOne, oWarrior, "IsBusy", false)
			end
		end
	end
	WarTools.TimeEnd("Escape")
end

function CWarCmd.CommandStart(oCmd)
	-- WarTools.Print("CWarCmd.CommandStart")
	g_WarCtrl:CommandStart(oCmd.wid)
end

-- hitTrick参数从 CWarrior.Hurt（oDamageCmd:Excute(false)）
function CWarCmd.WarDamage(oCmd, hitTrick)
	-- 1 miss 2 defense
	if oCmd.type == 1 then
		return
	end
	if oCmd.damage == 0 then
		return
	end

	local oWarrior = g_WarCtrl:GetWarrior(oCmd.wid)
	if oWarrior then
		oWarrior:ShowDamage(oCmd.damage, oCmd.iscrit, hitTrick)
	end
end

function CWarCmd.WarAddMp(oCmd)
	local oWarrior = g_WarCtrl:GetWarrior(oCmd.wid)
	if oWarrior then
		oWarrior:ShowMpChange(oCmd.add_mp)
	end
end

function CWarCmd.WarriorSpeek(oCmd)
	-- print(string.format("<color=#00FFFF> >>> .%s | %s </color>", "WarriorSpeek", "战斗说话啊"), oCmd.content)
	local oWarrior = g_WarCtrl:GetWarrior(oCmd.wid)
	if oWarrior then
		if oCmd.showType == 0 then
			-- 气泡
			if g_WarCtrl:IsBossWarType() and oWarrior.m_CampPos == 1 and oWarrior.m_CampID ~= g_WarCtrl:GetAllyCamp() then
				local oView = CWarFloatView:GetView()
				if oView then
					oView:AddMsg(oWarrior.m_Actor.m_Shape, oCmd.content, 2)
				end
			else
				oWarrior:ChatMsg(oCmd.content)
			end
		elseif oCmd.showType == 1 then
			-- 弹窗
			local oView = CWarFloatView:GetView()
			if oView then
				oView:AddMsg(oWarrior.m_Actor.m_Shape, oCmd.content, 2)
			end
		end
	end
end

function CWarCmd.WarriorSeqSpeek(oCmd)
	WarTools.TimeStart("WarriorSeqSpeek")
	for _,v in pairs(oCmd.speeks) do
		local oWarrior = g_WarCtrl:GetWarrior(v.wid)
		if oWarrior then
			if g_WarCtrl:IsBossWarType() and oWarrior.m_CampPos == 1 and oWarrior.m_CampID ~= g_WarCtrl:GetAllyCamp() then
				local oView = CWarFloatView:GetView()
				if oView then
					oView:AddMsg(oWarrior.m_Actor.m_Shape, v.content, 2)
				end
			else
				oWarrior:ChatMsg(v.content)
				oWarrior:SetBusy(true, "paopao")
				Utils.AddTimer(function ()
					if Utils.IsNil(oWarrior) then
						return false
					end
					oWarrior:SetBusy(false, "paopao")
					return false
				end, 2, oCmd.block_ms or 0)
				g_WarCtrl:InsertAction(CWarCmd.WaitOne, oWarrior, "IsBusy", false)
			end
		end
	end
	g_WarCtrl:InsertAction(CWarCmd.ClearVary, oCmd)
	WarTools.TimeEnd("WarriorSeqSpeek")
	local oVaryCmd = g_WarCtrl:GetVaryCmd()
	if oVaryCmd and oVaryCmd.m_ID  == oCmd.m_ID then
		g_WarCtrl:SetVaryCmd(nil)
	end
end

function CWarCmd.WarPaopao(oCmd)
	WarTools.TimeStart("WarPaopao")
	local oWarrior = g_WarCtrl:GetWarrior(oCmd.wid)
	if oWarrior then
		if g_WarCtrl:IsBossWarType() and oWarrior.m_CampPos == 1 and oWarrior.m_CampID ~= g_WarCtrl:GetAllyCamp() then
			local oView = CWarFloatView:GetView()
			if oView then
				oView:AddMsg(oWarrior.m_Actor.m_Shape, oCmd.content, 2)
			end
		else
			oWarrior:ChatMsg(oCmd.content)
		end
		oWarrior:SetBusy(true, "paopao")
		Utils.AddTimer(function ()
			if Utils.IsNil(oWarrior) then
				return false
			end
			oWarrior:SetBusy(false, "paopao")
			return false
		end, 2, 2)
		g_WarCtrl:InsertAction(CWarCmd.WaitOne, oWarrior, "IsBusy", false)
	end
	WarTools.TimeEnd("WarPaopao")
end

function CWarCmd.WarNotify(oCmd)
	-- 提示类型:
	-- 0x0001 表示弹窗
	-- 0x0010表示聊天提示
	-- 0x0100 不跟随技能，独立提示
	local typeValue = {}
    for i= 1,3 do
        local temp = MathBit.andOp(MathBit.rShiftOp(oCmd.type,i-1),1)
        typeValue[i] = temp == 1
    end
    if typeValue[1] then
		g_NotifyCtrl:FloatMsg(oCmd.content)
    end
    if typeValue[2] then
		local dMsg = {
			channel = define.Channel.Message,
			text = oCmd.content,
		}
		g_ChatCtrl:AddMsg(dMsg)
    end
    if typeValue[3] then
		g_NotifyCtrl:FloatMsg(oCmd.content)
    end
end

function CWarCmd.WarChat(oCmd)

	g_NotifyCtrl:FloatMsg(oCmd.content)
end

function CWarCmd.WarInfoBulletBarrage(oCmd)
	local list = {name = "", msg = oCmd.content, isShowName = false}
	g_BarrageCtrl:InsertInfoData(list)
end

function CWarCmd.TriggerPassiveSkill(oCmd, insert)
	-- 触发被动技能
	if g_WarCtrl.g_Print then
		printc("CWarCmd.TriggerPassiveSkill 指令触发被动技能", oCmd.pfid)
	end
	local oWarrior = g_WarCtrl:GetWarrior(oCmd.wid)
	if oWarrior then
		oWarrior:TriggerPassiveSkill(oCmd.pfid, oCmd.key_list)
	end

	oCmd:ExcutePassiveSkill(oWarrior, insert)
end

function CWarCmd.ExcutePassiveSkill(oCmd, oAtkObj, insert)
	if oCmd.key_list == nil or table.count(oCmd.key_list) == 0 then
		return
	end
	local sMainKey = oCmd.key_list[1].key
	if sMainKey == "magic_id" then
		local iMagicId = oCmd.key_list[1].value
		local refAtkObj = weakref(oAtkObj)
		local refVicObjs = {}
		for i,v in ipairs(oCmd.key_list) do
			if v.key == "select_id" then
				local oWarrior = g_WarCtrl:GetWarrior(v.value)
				table.insert(refVicObjs, weakref(oWarrior))
			end
		end
		local requiredata = {
			refAtkObj = refAtkObj,
			refVicObjs = refVicObjs,
		}
		local oMagicUnit = g_MagicCtrl:NewMagicUnit(iMagicId, oAtkObj:GetBasicShape(), oCmd.magic_index, requiredata, oCmd.isPursued)
		--延长死亡退场时间，确保技能播放完成
		if iMagicId == 5706 then
			local dMagicTimeInfo = DataTools.GetMagicTimeInfo(iMagicId, 1, 1)
			if dMagicTimeInfo then
				oAtkObj.m_DieDelay = dMagicTimeInfo[1]/1000
				local function resume()
					if not Utils.IsNil(oAtkObj) then
						oAtkObj.m_DieDelay = nil
					end
				end
				Utils.AddTimer(resume, 0, oAtkObj.m_DieDelay + 0.1)
			end
		end
		oMagicUnit:SetLayer(UnityEngine.LayerMask.NameToLayer("War"))
		insert(CMagicUnit.Start, oMagicUnit, oCmd)
	end 
end

--处理显示和屏蔽队伍指挥相关
function CWarCmd.ShowWarCommond(oCmd)
	--TODO:待删除打印
	if g_WarCtrl.g_Print then
		printc("CWarCmd.ShowWarCommond")
		table.print(oCmd)
	end
	--观战屏蔽所有战斗指挥显示
	if g_WarCtrl:GetViewSide() then
		return
	end
	local oPlayer = g_WarCtrl:GetWarrior(oCmd.wid)
	if oPlayer then
		local sCmd = nil
		if oCmd.op == 1 or oCmd.op == 2 then
			sCmd = oCmd.content
			local oAppointee = g_WarCtrl:GetWarriorByID(g_TeamCtrl:GetTeamAppoint())
			if oAppointee and not g_WarCtrl.m_MaskTeamCmd then
				oAppointee:ChatMsg(string.format("%s:#R%s#n", sCmd, oPlayer:GetName()))
			end
		end
		oPlayer:SetTeamCmd(sCmd)
	end
end

function CWarCmd.MaskWarCommond(oCmd)
	--观战屏蔽所有战斗指挥显示
	if g_WarCtrl:GetViewSide() then
		return
	end
	local list = g_WarCtrl:GetWarriors()
	for i, oWarrior in pairs(list) do
		if Utils.IsExist(oWarrior) and oWarrior:HasTeamCmd() then
			oWarrior:SetTeamCmd(oWarrior.m_TeamCmd)
		end
	end
end

function CWarCmd.WarUseItem(oCmd)
	WarTools.TimeStart("WarUseItem")
	local dAtkVary = oCmd:GetWarriorVary(oCmd.action_wid)
	oCmd:CheckNotifyCmds(dAtkVary, 0)

	if dAtkVary.infoBulletBarrage_cmd then
		local oCmd = dAtkVary.infoBulletBarrage_cmd
		oCmd:Excute()
	end

	if dAtkVary.speek_cmd then
		local oCmd = dAtkVary.speek_cmd
		oCmd:Excute()
	end
	
	local oUserAtk = g_WarCtrl:GetWarrior(oCmd.action_wid)
	if oUserAtk then
		-- 使用道具
		local dVary = oCmd:GetWarriorVary(oCmd.action_wid)
		g_WarCtrl:InsertAction(CWarrior.ItemUser, oUserAtk, oCmd.item_id, dVary)
		g_WarCtrl:InsertAction(CWarCmd.WaitOne, oUserAtk, "IsBusy", false)
	end
	local dAtkVary = oCmd:GetWarriorVary(oCmd.action_wid)
	if dAtkVary then
		g_WarCtrl:InsertAction(CWarrior.Hurt, oUserAtk, dAtkVary)

		g_WarCtrl:InsertAction(CWarrior.AddMp, oUserAtk, dAtkVary)
		g_WarCtrl:InsertAction(CWarCmd.WaitOne, oUserAtk, "IsBusy", false)
	end

	local oTarget = g_WarCtrl:GetWarrior(oCmd.select_wid)
	local lVicObjs = {}
	if oTarget then
		table.insert(lVicObjs, oTarget)
	end
	oCmd:AddExtraObj(oCmd.action_wid, lVicObjs)
	for i,vidObj in ipairs(lVicObjs) do
		local dUsedVary = oCmd:GetWarriorVary(vidObj.m_ID)
		-- 被使用道具
		local dVary = oCmd:GetWarriorVary(oCmd.select_wid)
		if dUsedVary then
			g_WarCtrl:InsertAction(CWarrior.UpdateStatus, vidObj, dUsedVary)
			if dUsedVary.status then
				local bAlive = dUsedVary.status == define.War.Status.Alive
				g_WarCtrl:InsertAction(CWarrior.SetAlive, vidObj, bAlive)
				g_WarCtrl:InsertAction(CWarCmd.WaitOne, vidObj, "IsBusy", false)
			end
			
			if dUsedVary.damage_list then
				g_WarCtrl:InsertAction(CWarrior.Hurt, vidObj, dUsedVary)
			end
			if dUsedVary.addMp_list then
				g_WarCtrl:InsertAction(CWarrior.AddMp, vidObj, dUsedVary)
			end
			g_WarCtrl:InsertAction(CWarCmd.WaitOne, vidObj, "IsBusy", false)
		end
		g_WarCtrl:InsertAction(CWarrior.ItemUsed, vidObj, oCmd.item_id, dVary)
		g_WarCtrl:InsertAction(CWarCmd.WaitOne, vidObj, "IsBusy", false)
	end
	g_WarCtrl:InsertAction(CWarCmd.ClearVary, oCmd)
	WarTools.TimeEnd("WarUseItem")
end

function CWarCmd.RefreshAllTeamCmd(oCmd)
	--观战屏蔽所有战斗指挥显示
	if g_WarCtrl:GetViewSide() then
		return
	end
	g_WarCtrl:RefreshAllTeamCommand(oCmd.op, oCmd.lcmd)
end

function CWarCmd.RefreshPerformCD(oCmd)
	local oWarrior = g_WarCtrl:GetWarrior(oCmd.wid)
	if oWarrior then
		oWarrior:RefreshPerformCD(oCmd.pflist)
	end
end

--更新受击对象列表 部分buff和被动技能导致的溅射伤害表现
function CWarCmd.UpdateVictimList(oCmd, iWid)
	if oCmd.vicid_list then
		local bIsExist = false
		for i,wid in ipairs(oCmd.vicid_list) do
			if wid == iWid then
				bIsExist = true
				break
			end
		end
		if not bIsExist then
			table.insert(oCmd.vicid_list, iWid)
		end
	end
end

function CWarCmd.CheckNotifyCmds(self, dVary, iFlag)
	local cmdLefts = nil
	if dVary.notify_cmds then
		iFlag = iFlag or 0
		for i, oCmd in ipairs(dVary.notify_cmds) do
			if iFlag == oCmd.flag then
				oCmd:Excute()
			else
				cmdLefts = cmdLefts or {}
				table.insert(cmdLefts, oCmd)
			end
		end
		dVary.notify_cmds = nil
	end
	if cmdLefts and #cmdLefts > 0 then
		dVary.notify_cmds = cmdLefts
	end
end

-- 是否是被动技能复活
function CWarCmd.IsPassiveReborn(oCmd, iPfId)
	return iPfId == 5117 or iPfId == 9529
end

-- 被动技能复活表现，特殊写
function CWarCmd.CheckPassiveRebornVary(self, dVary, wid)
	local oWarrior = g_WarCtrl:GetWarrior(wid)
	for i, oCmd in ipairs(dVary.buff_list or {}) do
		oCmd:Excute()
	end
	dVary.buff_list = nil
	local damageLeft = {}
	for i, oCmd in ipairs(dVary.damage_list or {}) do
		if oCmd.damage < 0 then
			oCmd:Excute()
		else
			table.insert(damageLeft, oCmd)
		end
	end
	dVary.damage_list = next(damageLeft) and damageLeft or nil
	if oWarrior then
		local lHP = dVary.hp_list
		--被动技能复活死亡表现，手动设置hp为0
		dVary.hp_list = {{hp = 0}}
		oWarrior:RefreshBlood(dVary)
		g_WarCtrl:WarriorStatusChange(wid)
		oWarrior:UpdateStatus(dVary)
		dVary.hp_list = lHP
	else
		local oAddCmd = dVary["add_warriorcmd"]
		if oAddCmd then
			oAddCmd:Excute()
		end
		dVary["add_warriorcmd"] = nil
	end
end

return CWarCmd