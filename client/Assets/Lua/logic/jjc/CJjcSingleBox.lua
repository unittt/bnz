local CJjcSingleBox = class("CJjcSingleBox", CBox)

--竞技场竞技界面或挑战详情界面的Box
function CJjcSingleBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_SingleId = -1
	self.m_SingleType = 1

	self.m_GroupIdx = 1
	self.m_GroupId = -1
	self.m_GroupType = 1
	self.m_Tag = "single"

	self.m_TopId = 0
	self.m_TopType = 1

	self.m_RankLbl = self:NewUI(1, CLabel)
	self.m_ActorTexture = self:NewUI(2, CActorTexture)
	self.m_OtherGo = self:NewUI(3, CObject)
	self.m_SelfGo = self:NewUI(4, CObject)
	self.m_NameLbl = self:NewUI(5, CLabel)
	self.m_LevelLbl = self:NewUI(6, CLabel)
	self.m_FightValueLbl = self:NewUI(7, CLabel)
	self.m_ChallengeBtn = self:NewUI(8, CButton)
	self.m_LeftTimeValueLbl = self:NewUI(9, CLabel)
	self.m_LeftCountValueLbl = self:NewUI(10, CLabel)
	self.m_AddCountBtn = self:NewUI(11, CButton)
	self.m_SpeedTimeBtn = self:NewUI(12, CButton)
	self.m_DeadSp = self:NewUI(13, CSprite)

	self.m_ChallengeBtn:GetComponent(classtype.BoxCollider).enabled = true

	self.m_ActorTexture:AddUIEvent("click", callback(self, "OnClickActorTexture"))
	self.m_ChallengeBtn:AddUIEvent("click", callback(self, "OnClickChallenge"))
	self.m_AddCountBtn:AddUIEvent("click", callback(self, "OnClickAddCount"))
	self.m_SpeedTimeBtn:AddUIEvent("click", callback(self, "OnClickSpeedTime"))
end

--设置CJjcSinglePart界面下CJjcSingleBox的内容
function CJjcSingleBox.SetSingleHeroInfo(self, fighttimes, fightcd)
	self:SetActive(false)
	self.m_DeadSp:SetActive(false)
	self.m_OtherGo:SetActive(false)
	self.m_SelfGo:SetActive(true)
	self.m_LeftTimeValueLbl:SetActive(false)
	self.m_SpeedTimeBtn:SetActive(false)

	self.m_SingleId = g_AttrCtrl.pid
	self.m_SingleType = 1
	self.m_Tag = "single"

	if g_JjcCtrl.m_Rank == 0 then
		self.m_RankLbl:SetText(g_JjcCtrl.m_JjcOutSideRankStr)
	else
		self.m_RankLbl:SetText("第"..g_JjcCtrl.m_Rank.."名")
	end
	self.m_NameLbl:SetText(g_AttrCtrl.name)
	-- self.m_LevelLbl:SetText("Lv."..g_AttrCtrl.grade)
	self.m_FightValueLbl:SetText(g_AttrCtrl.score)

	local modelInfo = table.copy(g_AttrCtrl.model_info)
	modelInfo.horse = nil
	self.m_ActorTexture:ChangeShape(modelInfo)
	-- if fighttimes then
	-- 	self.m_LeftCountValueLbl:SetText("剩余挑战次数:"..fighttimes.."/"..data.jjcdata.JJCGLOBAL[1].fight_max.."次")
	-- end
	-- if fightcd then
	-- 	self:ResetTimer()
	-- 	local time = fightcd
	-- 	g_JjcCtrl.m_LeftTime = fightcd
	-- 	if time > 0 then
	-- 		local function progress()
	-- 			time = time - 1
	-- 			g_JjcCtrl.m_LeftTime = g_JjcCtrl.m_LeftTime - 1
	-- 			if not self.m_LeftTimeValueLbl:IsDestroy() then
	-- 				self.m_LeftTimeValueLbl:SetActive(true)
	-- 				self.m_SpeedTimeBtn:SetActive(true)
	-- 				self.m_LeftTimeValueLbl:SetText("挑战冷却:"..os.date("#R%M:%S#n", time))
	-- 			end
				
	-- 			if time <= 0 then
	-- 				g_JjcCtrl.m_LeftTime = 0
	-- 				if not self.m_LeftTimeValueLbl:IsDestroy() then
	-- 					self.m_LeftTimeValueLbl:SetActive(false)
	-- 					self.m_SpeedTimeBtn:SetActive(false)
	-- 				end
	-- 				self:ResetTimer()
	-- 				return false
	-- 			end
	-- 			return true
	-- 		end
	-- 		self.m_Timer = Utils.AddTimer(progress, 1, 1)
	-- 	else
	-- 		self.m_LeftTimeValueLbl:SetActive(false)
	-- 		self.m_SpeedTimeBtn:SetActive(false)
	-- 	end
	-- end
end

function CJjcSingleBox.ResetTimer(self)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil			
	end
end

function CJjcSingleBox.SetSingleTargetInfo(self, oInfo, isBtnDisabled)
	self.m_DeadSp:SetActive(false)
	self.m_OtherGo:SetActive(true)
	self.m_SelfGo:SetActive(false)
	self.m_LevelLbl:SetActive(false)
	self.m_ChallengeBtn:SetActive(true)

	if isBtnDisabled then
		self.m_ChallengeBtn:GetComponent(classtype.BoxCollider).enabled = false
	else
		self.m_ChallengeBtn:GetComponent(classtype.BoxCollider).enabled = true
	end

	self.m_SingleId = oInfo.id
	self.m_SingleType = oInfo.type
	self.m_Tag = "single"

	self.m_RankLbl:SetText("第"..oInfo.rank.."名")
	self.m_NameLbl:SetText(oInfo.name)
	-- self.m_LevelLbl:SetText("Lv."..oInfo.grade)
	self.m_FightValueLbl:SetText("评分 "..oInfo.score)

	local modelInfo = table.copy(oInfo.model)
	modelInfo.horse = nil
	self.m_ActorTexture:ChangeShape(modelInfo)

end

function CJjcSingleBox.SetTopTargetInfo(self, oInfo)
	self.m_DeadSp:SetActive(true)
	self.m_OtherGo:SetActive(true)
	self.m_SelfGo:SetActive(false)
	self.m_FightValueLbl:SetActive(false)
	self.m_ChallengeBtn:SetActive(false)
	self.m_LevelLbl:SetActive(false)
	self.m_RankLbl:SetActive(false)

	self.m_TopId = oInfo.id
	self.m_TopType = oInfo.type
	self.m_Tag = "top"

	-- self.m_RankLbl:SetText("第"..oInfo.rank.."名")
	self.m_DeadSp:SetSpriteName("h7_no"..oInfo.rank)
	self.m_NameLbl:SetText(oInfo.name)
	-- self.m_LevelLbl:SetText("Lv."..oInfo.grade)
	local modelInfo = table.copy(oInfo.model)
	modelInfo.horse = nil
	self.m_ActorTexture:ChangeShape(modelInfo)
end

--设置CJjcGroupDetailView界面下CJjcSingleBox的内容
function CJjcSingleBox.SetGroupTargetInfo(self, oInfo, idx)
	self.m_OtherGo:SetActive(true)
	self.m_SelfGo:SetActive(false)
	self.m_RankLbl:SetActive(false)
	self.m_LevelLbl:SetActive(false)

	self.m_GroupIdx = idx
	self.m_GroupId = oInfo.id
	self.m_GroupType = oInfo.type
	self.m_Tag = "group"

	self.m_NameLbl:SetText(oInfo.name)
	-- self.m_LevelLbl:SetText("Lv."..oInfo.grade)
	self.m_FightValueLbl:SetText("评分 "..oInfo.score)
	local modelInfo = table.copy(oInfo.model)
	modelInfo.horse = nil
	self.m_ActorTexture:ChangeShape(modelInfo)
	local list = {id = oInfo.id, type = oInfo.type}
	if g_JjcCtrl:GetIsJjcChallengeTargetKilled(list) then
		self.m_DeadSp:SetActive(true)
		self.m_ChallengeBtn:SetActive(false)
	else
		self.m_DeadSp:SetActive(false)
		self.m_ChallengeBtn:SetActive(true)
		self.m_ChallengeBtn:GetComponent(classtype.BoxCollider).enabled = true
	end
end

-----------------以下是点击事件------------------

function CJjcSingleBox.OnClickActorTexture(self)
	if self.m_Tag == "single" then
		if not self.m_SingleId or self.m_SingleId == -1 then
			return
		end
		if self.m_SingleId ~= g_AttrCtrl.pid then
			netjjc.C2GSQueryJJCTargetLineup({id = self.m_SingleId, type = self.m_SingleType})
		end
	elseif self.m_Tag == "group" then
		if not self.m_GroupId or self.m_GroupId == -1 then
			return
		end
		netjjc.C2GSChallengeTargetLineup({id = self.m_GroupId, type = self.m_GroupType})
	elseif self.m_Tag == "top" then
		if self.m_TopId ~= g_AttrCtrl.pid then
			netjjc.C2GSQueryJJCTargetLineup({id = self.m_TopId, type = self.m_TopType})
		end
	end
end

function CJjcSingleBox.OnClickChallenge(self)
	if g_WarCtrl:IsWar() then
		g_NotifyCtrl:FloatMsg("您已经在战斗中了哦")
		return
	end
	if g_LimitCtrl:CheckIsLimit(true, true) then
    	return
    end
	if self.m_Tag == "single" then
		if g_JjcCtrl.m_LeftCount <= 0 then
			if g_JjcCtrl.m_JjcMainHasBuy >= data.jjcdata.BUYJJCTIME[#data.jjcdata.BUYJJCTIME].hasbuy[2] then
				g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.MainMaxTime].content)
			else
				local windowConfirmInfo = {
					msg				= string.gsub(data.jjcdata.TEXT[define.Jjc.Text.AddCountBtn].content, "#num", self:GetJJCBuyTimeMoney(g_JjcCtrl.m_JjcMainHasBuy + 1).."元宝"),
					title			= "提示",
					okCallback = function ()
						netjjc.C2GSJJCBuyFightTimes()
					end,
				}
				g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)
					self.m_WinTipViwe = oView
				end)
			end
			return
		end
		local ValueStr = string.gsub(data.jjcdata.JJCGLOBAL[1].cd_cost, "minute", tostring(math.ceil(tonumber(g_JjcCtrl.m_JjcMainCountTime/60))))
		local Value = load(string.format([[return (%s)]], ValueStr))()
		if g_JjcCtrl.m_JjcMainCountTime and g_JjcCtrl.m_JjcMainCountTime > 0 then
			local windowConfirmInfo = {
				msg				= string.gsub(data.jjcdata.TEXT[define.Jjc.Text.SpeedTimeBtn].content, "#num", math.ceil(tonumber(Value)).."元宝"),
				title			= "提示",
				okCallback = function ()
					netjjc.C2GSJJCClearCD()
				end,
			}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)
				self.m_WinTipViwe = oView
			end)
			return
		end
		if not self.m_SingleId or self.m_SingleId == -1 then
			return
		end
		netjjc.C2GSJJCStartFight({id = self.m_SingleId, type = self.m_SingleType})
	elseif self.m_Tag == "group" then
		if not self.m_GroupId or self.m_GroupId == -1 then
			return
		end
		netjjc.C2GSStartChallenge({id = self.m_GroupId, type = self.m_GroupType})
	end
end

function CJjcSingleBox.OnClickAddCount(self)
	if g_JjcCtrl.m_JjcMainHasBuy >= data.jjcdata.BUYJJCTIME[#data.jjcdata.BUYJJCTIME].hasbuy[2] then
		g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.MainMaxTime].content)
	else
		local windowConfirmInfo = {
			msg				= string.gsub(data.jjcdata.TEXT[define.Jjc.Text.AddCount].content, "#num", self:GetJJCBuyTimeMoney(g_JjcCtrl.m_JjcMainHasBuy + 1).."元宝"),
			title			= "提示",
			okCallback = function ()
				netjjc.C2GSJJCBuyFightTimes()
			end,
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)
			self.m_WinTipViwe = oView
		end)
	end
end

--传的参数需要加1，如g_JjcCtrl.m_JjcMainHasBuy + 1
function CJjcSingleBox.GetJJCBuyTimeMoney(self, hasbuy)
	for k,v in ipairs(data.jjcdata.BUYJJCTIME) do
		if v.hasbuy[1] <= hasbuy and (v.hasbuy[2] and v.hasbuy[2] or v.hasbuy[1]) >= hasbuy then
			return v.gold
		end
	end
	return data.jjcdata.BUYJJCTIME[#data.jjcdata.BUYJJCTIME].gold
end

function CJjcSingleBox.OnClickSpeedTime(self)
	if g_JjcCtrl.m_JjcMainCountTime > 0 then
		local ValueStr = string.gsub(data.jjcdata.JJCGLOBAL[1].cd_cost, "minute", tostring(math.ceil(tonumber(g_JjcCtrl.m_JjcMainCountTime/60))))
		local Value = load(string.format([[return (%s)]], ValueStr))()
		local windowConfirmInfo = {
			msg				= string.gsub(data.jjcdata.TEXT[define.Jjc.Text.SpeedTime].content, "#num", math.ceil(tonumber(Value)).."元宝"),
			title			= "提示",
			okCallback = function ()
				netjjc.C2GSJJCClearCD()
			end,
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)
			self.m_WinTipViwe = oView
		end)
	else
		g_NotifyCtrl:FloatMsg("当前没有冷却时间,无需加速哦")
	end
end

return CJjcSingleBox