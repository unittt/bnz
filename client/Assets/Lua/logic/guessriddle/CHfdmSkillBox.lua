local CHfdmSkillBox = class("CHfdmSkillBox", CBox)

function CHfdmSkillBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_SkillData = nil
	self:InitContent()
end

function CHfdmSkillBox.InitContent(self)
	self.m_SkillIcon = self:NewUI(1, CSprite)
	self.m_TimerLabel = self:NewUI(2, CLabel)
	self.m_MarkSpr = self:NewUI(3, CSprite)
	self.m_TimerLabel:SetActive(false)
	self.m_MarkSpr:SetActive(false)
	self:InitEvent()
end

function CHfdmSkillBox.InitEvent(self)
	self.m_SkillIcon:AddUIEvent("click", callback(self, "OnUseSkill"))
	self.m_SkillIcon:AddUIEvent("longpress", callback(self, "OnDetailInfo"))
	g_GuessRiddleCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "RefreshTime"))
end

function CHfdmSkillBox.RefreshTime(self, oCtrl)
	-- body
	if oCtrl.m_EventID ==  define.GuessRiddle.Event.KickTimer then
		if self.m_SkillData.id ==1002 then
			self:SetMask(oCtrl.m_EventData)
		end
		
	elseif  oCtrl.m_EventID ==  define.GuessRiddle.Event.AnchorTimer then
		if self.m_SkillData.id ~=1001 then
			return
		end	
		self:SetMask(oCtrl.m_EventData)
	elseif oCtrl.m_EventID ==  define.GuessRiddle.Event.RefreshSkillState then
		self:AddState(oCtrl.m_EventData) --给主角加状态并开始计时
	end
end

function CHfdmSkillBox.SetMask(self, time)
	-- body
	if time > 1 then
		self.m_MarkSpr:SetFillAmount(time/100)
		self.m_TimerLabel:SetText(time)
	else
		self.m_MarkSpr:SetActive(false)
		self.m_TimerLabel:SetActive(false)
	end
end

function CHfdmSkillBox.AddState(self, skill)
	for i,v in ipairs(skill) do
		if self.m_SkillData.id == v.id and self.m_SkillData.id == 1001 and v.cd == 100 then
			self.m_TimerLabel:SetActive(true)
			self.m_MarkSpr:SetActive(true)
			-- g_NotifyCtrl:FloatMsg("你使用了金钟罩，5秒之内不能被无影脚攻击")
			local path = "Effect/Buff/buff_eff_10003_foot/Prefabs/buff_eff_10003_foot.prefab"
			local function effectDone ()
				local oHero = g_MapCtrl:GetHero()
				self.m_FootCloudEffect:SetParent(oHero.m_Transform)
				self.m_FootCloudEffect:SetLocalEulerAngles(Vector3.New(0, 135, 0))
				local  function Destroy()
					if self.m_FootCloudEffect then 
						self.m_FootCloudEffect:Destroy()
						self.m_FootCloudEffect = nil
					end
					return false
				end
				Utils.AddTimer(Destroy, 0, 5)
			end
			self.m_FootCloudEffect = CEffect.New(path, UnityEngine.LayerMask.NameToLayer("Default"), true, effectDone)
		elseif self.m_SkillData.id == v.id and self.m_SkillData.id == 1002 and v.cd == 100 then
			self.m_TimerLabel:SetActive(true)
			self.m_MarkSpr:SetActive(true)
		end
	end
end

function CHfdmSkillBox.SetData(self, data)
	self.m_SkillData = data
end

function CHfdmSkillBox.OnUseSkill(self)

	if self.m_SkillData.id == 1001 then
		g_GuessRiddleCtrl:C2GSHfdmUseSkill(self.m_SkillData.id, g_AttrCtrl.pid)
	elseif self.m_SkillData.id == 1002 then
		g_NotifyCtrl:FloatMsg(data.hfdmdata.HFDMTEXT[9008].content)
		local path = "Effect/Scene/scene_eff_0044/Prefabs/scene_eff_0044.prefab"
		local function effectDone ()
			local oHero = g_MapCtrl:GetHero()
			self.m_FootCloudEffect:SetParent(oHero.m_Transform)
		end
		self.m_FootCloudEffect = CEffect.New(path, UnityEngine.LayerMask.NameToLayer("Default"), true, effectDone)
		self:KickPlayer()
		g_GuessRiddleCtrl.m_CanKickPlayer = true
	end
end

function CHfdmSkillBox.DestroyKickEffect(self)
	-- body
	if self.m_FootCloudEffect then 
		self.m_FootCloudEffect:Destroy()
		self.m_FootCloudEffect = nil
	end
end
function CHfdmSkillBox.OnDetailInfo(self)
	g_GuessRiddleCtrl:SetSkillBoxInfo(self.m_SkillData)
end

function CHfdmSkillBox.KickPlayer(self)
	-- body
	local oView = CGuessRiddleView:GetView()
	if oView then
		oView.m_TopPart:SetActive(false)
		oView.m_Bottom.m_UnfoldRank:SetActive(false)
		oView.m_Bottom.m_FoldRank:SetActive(false)
		oView.m_Bottom.m_SkillBox:SetActive(false)
		oView.m_Bottom.m_PopBtn:SetActive(false)
		oView.m_Bottom.m_ReBtn:SetActive(true)
	end
	--ctrl会判断踢人  TouchPlayer
end

return CHfdmSkillBox