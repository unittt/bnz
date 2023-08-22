CAttrCtrl = class("CAttrCtrl", CCtrlBase)

function CAttrCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetAll()
	self.m_IsMoneyInit = false
	self.m_IsOrgSkillInit = false
	self.m_IsGM = 0
	self.m_PlanInfolist = nil
end

--所有属性都有默认值
function CAttrCtrl.ResetAll(self)
	self.pid = 0
	self.grade = 0
	self.name = ""
	self.title_list = {}
	self.goldcoin = 0			--元宝
	self.gold = 0				--金币
	self.silver = 0				--银币
	self.rplgoldcoin = 0       -- 绑定元宝
	self.exp = 0
	self.chubeiexp = 0
	self.max_hp = 0
	self.max_mp = 0
	self.hp = 0
	self.mp = 0
	self.energy = 0
	self.physique = 0
	self.strength = 0
	self.magic = 0
	self.endurance = 0
	self.agility = 0
	self.phy_attack = 0
	self.phy_defense = 0
	self.mag_attack = 0
	self.mag_defense = 0
	self.cure_power = 0
	self.score = 0        --玩家评分
	self.speed = 0
	self.seal_ratio = 0
	self.res_seal_ratio = 0
	self.phy_critical_ratio = 0
	self.res_phy_critical_ratio = 0
	self.mag_critical_ratio = 0
	self.res_mag_critical_ratio = 0
	self.model_info = {}
	self.school = 0
	self.point = 0
	self.activepoint = 0
	self.sex = 0
	self.server_grade = 0
	self.days = 0
	self.followers = {} --跟随宠物列表
	self.g_SelectedPlan = 1 --默认选择的方案
	self.race = 0
	self.upvoteInfo = {} 
	self.org_id = 0
	self.org_status = 0
	self.org_offer = 0  -- 当前帮贡
	self.skill_point = 0 --技能点数
	self.orgname = ""
	self.icon = 1110
	self.show_id = nil
	self.org_skill = {}
	self.m_BadgeInfo = nil
	self.org_pos = 0 --帮派职位
	self.color = Color.New(1, 1, 1, 1) --全身颜色
	self.roletype = 0
	self.sp = 0
	self.max_sp = 0
	self.orgmatch_state = 0 --帮派竞赛状态 1005保护
	self.vigor = 0
	self.storypoint = 0
	self.title_info_changed = {} -- 画舫灯谜临时称谓
	self.engageInfo = nil
	self.makeDragAuto = true

	self.m_AssistExp = 0
	self.m_MaxAssistExp = 0
end

function CAttrCtrl.InitEngageInfo(self, info)
	self.engageInfo = info
end

function CAttrCtrl.GetShowID(self)
	if self.show_id and self.show_id > 0 then
		return self.show_id
	end
	return self.pid
end

function CAttrCtrl.UpdateGM(self, isgm)
	if self.m_IsGM ~= isgm then
		self.m_IsGM = isgm
		self:OnEvent(define.Attr.Event.Gm)
	end
end

function CAttrCtrl.UpdateAttr(self, dict)
	local dPreAttr = {} --保存下修改前的数据方便
	local dChange = {}
	for k , v in pairs(dict) do
		if self[k] ~= v then
			dPreAttr[k] = self[k]
			self[k] = v
			dChange[k] = v
		end
	end
	if dChange.pid then
		self.m_LastLoginPid = self.pid
		g_WarCtrl.m_WarPid = self.pid
	end

	g_ItemCtrl:SetUpgradsPackConfigByGrade()

	-- 这一部分是用于处理画舫灯谜称谓改变的代码 
	if next(self.title_info_changed) then -- 画舫灯谜场景内称谓变化
		if self.title_info_changed.tid ~= 0 then
	 		g_TitleCtrl:ExternalUpdateTitle(self.title_info_changed, true)
	 	elseif self.title_info_changed.tid == 0 and self.title_info then
	 		g_TitleCtrl:UpdateWearingTitle(self.title_info.tid)
	 	elseif self.title_info_changed.tid == 0 and not self.title_info then
			g_TitleCtrl:UpdateWearingTitle(nil)
	 	end
	else   -- 离开画舫之后的称谓变化
		if self.title_info then
			g_TitleCtrl:UpdateWearingTitle(self.title_info.tid)
		else
			g_TitleCtrl:UpdateWearingTitle(nil)
		end
	end

	if dChange.fly_height and dChange.model_info_changed then 
		--状态同时变化的处理
		local walker = g_MapCtrl:GetHero()
		if walker then 
			walker.m_FlyHeight = dChange.fly_height
			walker:ChangeShape( dChange.model_info_changed, function ()
				g_FlyRideAniCtrl:RespondFly(walker, false)
			end)
		end 
	else
		if dChange.fly_height then 
			local walker = g_MapCtrl:GetHero()
			if walker then 
				walker.m_FlyHeight = self.fly_height
				if self.model_info_changed.isbianshen == 1 then 
					g_FlyRideAniCtrl:RespondFly(walker, false)
				else
					g_FlyRideAniCtrl:RespondFly(walker, true)
				end 
			end
		end 

		if dChange.model_info_changed or dChange.model_info then
			g_MapCtrl:ChangeHeroShape()
		end
	end 

	if dChange.followers then
		if next(dChange.followers) == nil then
			g_MapCtrl:DelAllSummonWalker()
		else
			g_MapCtrl:DelAllSummonWalker()
			for j,c in pairs(dChange.followers) do
				g_MapCtrl:AddSummon(c)
			end		
		end
		local walker = g_MapCtrl:GetHero()
		if walker then 
			g_FlyRideAniCtrl:UpdateLeaderFollowerDis(walker.m_Pid)
		end
	end
	if dChange.grade then
		--注意，只能同pid才需要升级音效
		if dPreAttr.grade ~= 0 and not dChange.pid then
			-- 升级音效
			g_AudioCtrl:PlaySound(define.Audio.SoundPath.Upgrade)
			g_PartnerCtrl:ResetRedPointStatus()
			g_SuperRebateCtrl:OnEvent(define.SuperRebate.Event.SuperRebateStart)
		end		
		g_GuideCtrl:OnTriggerAll()
		g_ScheduleCtrl:ResetLocalRedPoint()
		g_ChatCtrl:ResetHelpTips()
		g_GuideHelpCtrl:SendPreOpenEvent()
		g_GuideHelpCtrl:CheckAllNotifyGuide()
		if not dChange.pid then
			g_SdkCtrl:SubmitRoleData(CSdkCtrl.SubmitType.Upgrade)
		end
		g_TaskCtrl:UpdateCurChapter()
		g_WelfareCtrl:OnEvent(define.WelFare.Event.UpdataColorLamp)
		g_PromoteCtrl:UpdatePromoteData(1)
		g_PromoteCtrl:UpdatePromoteData(2)
		g_PromoteCtrl:UpdatePromoteData(3)
		g_PromoteCtrl:UpdatePromoteData(6)
		g_PromoteCtrl:UpdatePromoteData(7)
		g_PromoteCtrl:UpdatePromoteData(8)
	end
	if dChange.name then
		g_MapCtrl:UpdateHero()
		if Utils.IsEditor() then
			local account = g_LoginPhoneCtrl:GetLoginInfo("account")
			local server = g_ServerPhoneCtrl:GetCurServerName()
			Utils.SetWindowTitle(string.format("账号:%s | 名称:%s | 服务器:%s | PID:%d", account, self.name, server, self.pid))
		end
	end
	if dChange.org_id == 0 then
  		g_OrgCtrl:Clear()
		local view = COrgInfoView:GetView()
		if view then
			view:OnClose()
		end
		g_GuideCtrl:OnTriggerAll()
	elseif dChange.org_id and dChange.org_id >= 0 then
		g_OrgCtrl:UpdateOrgRedPoint()
		g_GuideCtrl:OnTriggerAll()
	end
	if dChange.goldcoin then
		local offset = dChange.goldcoin - dPreAttr.goldcoin
		g_SdkCtrl:SubmitGoldInfo(offset)
		if offset > 0 and self.m_IsMoneyInit then
			local item = DataTools.GetItemData(1003, "VIRTUAL")
			if item then
				g_NotifyCtrl:FloatItemBox(item.icon,nil)
			end
		end
	end
	if dChange.gold then
		if dChange.gold - dPreAttr.gold > 0 and self.m_IsMoneyInit then
			if not g_TreasureCtrl.m_IsTreasureMoney then
				local item = DataTools.GetItemData(1001, "VIRTUAL")
				g_NotifyCtrl:FloatItemBox(item.icon)
			end
			-- 金币掉落音效
			g_AudioCtrl:PlaySound(define.Audio.SoundPath.Gold)
		end
	end
	if dChange.silver then
		if dChange.silver - dPreAttr.silver > 0 and self.m_IsMoneyInit then
			if not g_TreasureCtrl.m_IsTreasureMoney and not g_EcononmyCtrl.m_StallFloatSilver then
				local item = DataTools.GetItemData(1002, "VIRTUAL")
				g_NotifyCtrl:FloatItemBox(item.icon)
			end
			-- 银币掉落音效
			g_AudioCtrl:PlaySound(define.Audio.SoundPath.Gold)
		end

		g_PromoteCtrl:UpdatePromoteData(2)
		g_PromoteCtrl:UpdatePromoteData(7)
		g_PartnerCtrl:ResetAllEquipRedPointBySilver()
	end
	if dChange.skill_point then
		g_PromoteCtrl:UpdatePromoteData(1)
	end
	if dChange.energy then
		g_PromoteCtrl:UpdatePromoteData(6)
	end
	if dChange.prop_info then
		for i, v in ipairs(dChange.prop_info) do
			self[v.name.."_ratio"] = v.ratio
			self[v.name.."_extra"] = v.extra
			self[v.name.."_base"] = v.base
		end
		self:OnEvent(define.Attr.Event.GetSecondProp)
	end

	if dChange.engage_info then
		self.engageInfo = dChange.engage_info
	end

	-- 注意：事件放到最后（原因是防止上面的操作改变某些属性的值）
	if next(dChange) then
		self:OnEvent(define.Attr.Event.Change, {dAttr = dChange, dPreAttr = dPreAttr})	
	end

	self.race = DataTools.GetRaceBySchool(self.school)
	self.roletype = DataTools.GetRoletype(self.sex, self.race)
	self.m_IsMoneyInit = true
end

function CAttrCtrl.RefreshWashPoint(self, data)
	-- printc("-------RefreshWashPoint-------")
	self:OnEvent(define.Attr.Event.AddPoint, {"WashPoint", data})
end

function CAttrCtrl.RefreshAttrPoint(self, data)
	-- printc("-------RefreshAttrPoint----")
	self.g_SelectedPlan = data.plan_id
	self:OnEvent(define.Attr.Event.AddPoint, {"OnePlan", data})
end

function CAttrCtrl.UpdateAddpoint(self, infolist, planid)
	--printc("-----UpdateAddpoint-----")
	self.m_PlanInfolist = infolist
	self.g_SelectedPlan = planid
	self:OnEvent(define.Attr.Event.AddPoint, {"All", infolist, planid})
end

function CAttrCtrl.GetUpgradeExp(self)
	local expinfo = data.upgradedata.DATA[self.grade + 1]
	if expinfo then
		return expinfo.player_exp
	else
		return 0
	end
end

function CAttrCtrl.GetHeroFlyState(self)
	
	return self.fly_height 

end

function CAttrCtrl.GetCurGradeExp(self)
	return self.exp
end

function CAttrCtrl.EnergyCalculate(self, skill)
    local energy = 0
    -- if skill.sk == 4101 then
    --     --min（60,int(技能等级/10)*10+10）
    --     energy = math.min(60, math.floor(skill.level/10)*10+10)
    -- elseif skill.sk == 4102 then
    --     energy = math.min(40, skill.level+10)
    -- elseif skill.sk == 4103 then
    --     --max((int（技能等级/10）-3)*8,30)
    --     energy = math.max(30, (math.floor(skill.level/10)-3)*8)
    -- elseif skill.sk == 4104 then
    --     --max((int（技能等级/10）-3)*8,30)
    --     energy = math.max(30, (math.floor(skill.level/10)-3)*8)    
    -- end
    local dConfig = DataTools.GetOrgSkillData(skill.sk)
    if dConfig then
    	energy = string.eval(dConfig.cost_energy, {level = skill.level, math = math})
    end
    return energy
end

function CAttrCtrl.C2GSGetSecondProp(self)
	netplayer.C2GSGetSecondProp()
end

function CAttrCtrl.C2GSGetRankInfo(self, subid, page)
	netrank.C2GSGetRankInfo(subid,page)
end

--请求提升徽章等級
function CAttrCtrl.C2GSUpgradeTouxian(self)
    nettouxian:C2GSUpgradeTouxian()
end

function CAttrCtrl.C2GSGetScore(self, markType)
	netplayer.C2GSGetScore(markType)
end

function CAttrCtrl.GS2CGetSecondProp(self, info)
	local init = data.rolepointdata.INIT[1]
	for k,v in pairs(info) do
		local sum = init[v.name]
		if v.name == "max_mp" then 
			sum = sum + self.grade * 10 + 30
		else
			for j,c in pairs(data.rolepointdata.ROLEPOINT) do
				sum = sum + g_AttrCtrl[j] * c[v.name] + 0.001
			end
			if v.name == "max_hp" then
				-- http://oa.cilugame.com/redmine/issues/23175
				-- 人物面板的气血计算，需要删掉等级*5的计算部分
				sum = sum-- + g_AttrCtrl.grade*5
			end
		end 	
		self[v.name] = (sum * (100 + v.ratio/1000) / 100 + v.extra/1000)
		self[v.name.."_ratio"] = v.ratio
		self[v.name.."_extra"] = v.extra
	end
	self:OnEvent(define.Attr.Event.GetSecondProp)
end

function CAttrCtrl.GS2CGetRankInfo(self, info)
	self.upvoteInfo[info.page] = info
	if info.page > 1 then
		self:OnEvent(define.Attr.Event.UpdateRankInfo, info)
	end
end

function CAttrCtrl.GS2CUpvoteReward(self, info, isAll)
	if isAll then 
		self.upvoteRewardInfo = info
		self:OnEvent(define.Attr.Event.UpdateReward,nil)
		return
	end	
	self:OnEvent(define.Attr.Event.UpdateReward,info)
end

function CAttrCtrl.GS2COrgSkills(self, pbdata)
	for k,v in pairs(pbdata) do
		self.org_skill[v.sk] = {}
		self.org_skill[v.sk] = v
	end
	self:OnEvent(define.Attr.Event.UpdateOrgSkills)

	if self.m_IsOrgSkillInit then
		if g_WarCtrl:IsWar() then
			g_NotifyCtrl:FloatMsg("战斗结束后生效")
		end
	end
	if not self.m_IsOrgSkillInit then
		self.m_IsOrgSkillInit = true
	end
end

function CAttrCtrl.GS2CUseOrgSkill(self, info)
	self:OnEvent(define.Attr.Event.GetUseOrgSkill, info)
end 
--返回徽章信息
function CAttrCtrl.GS2CUpgradeTouxianInfo(self, infos)
	if infos.tid == 0 then
       infos.tid = 1001
	end
    self.m_BadgeInfo = {tid = infos.tid,score = infos.score}
    g_MapCtrl:UpdateHero()
    g_PromoteCtrl:UpdatePromoteData(11)
    self:OnEvent(define.Attr.Event.UpgradeTouxianInfo)
end

function CAttrCtrl.OpenBadgeView(self)
	local openSta = g_OpenSysCtrl:GetOpenSysState(define.System.Badge, true)
	if openSta then
		CBadgeView:ShowView()
	end
end

function CAttrCtrl.GetRemainPoint(self)
	if self.m_PlanInfolist then
	   local remain = self.m_PlanInfolist[self.g_SelectedPlan].remain_point
	   if remain then
	   	  return remain
	   end
	end
end

function CAttrCtrl.GS2CGetScore(self, markType, mark)
	local mark_type = markType
	--self.score = mark 人物评分向服务器请求，不做保存
	self:OnEvent(define.Attr.Event.UpDateScore, mark)
end

function CAttrCtrl.Clear(self)
	--切换账号需要清除的数据
	self.title_info = nil
	self.m_IsMoneyInit = false
	self.m_BadgeInfo = nil
	self.m_IsOrgSkillInit = false
end

function CAttrCtrl.GetGoldCoin(self)
	return self.goldcoin + self.rplgoldcoin
end

function CAttrCtrl.GetTrueGoldCoin(self)
	return self.goldcoin
end


function CAttrCtrl.SetOrgMatchState(self, state)
	self.orgmatch_state = state
end

function CAttrCtrl.GetMaxEnergy(self)
	return (220 + math.min(g_AttrCtrl.grade*18, 2000))
end

function CAttrCtrl.GetDragItem(self, sid)
	local item = {}
    local data = DataTools.GetItemData(sid)
    item.id = data.id
    item.icon = data.icon
    return item
end

--是否显示百分比
function CAttrCtrl.IsRatioAttr(self, attrName)
	
	if string.find(attrName, "ratio") then 
		if (attrName == "seal_ratio") or (attrName == "res_seal_ratio")  then 
			return false
		else
			return true
		end 
	else
	    return false
	end 
end

function CAttrCtrl.Getpid(self)
	return self.pid
end

function CAttrCtrl.GS2CAssistExp(self, assistExp, maxAssistExp)
	self.m_AssistExp = assistExp
	self.m_MaxAssistExp = maxAssistExp
	self:OnEvent(define.Attr.Event.RefreshAssistExp)
end

return CAttrCtrl