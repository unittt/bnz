local CHfdmInfoBox = class("CHfdmInfoBox", CBox)

function CHfdmInfoBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Data = nil
	self.m_EffectTimer = nil
	self.m_IsExitEffect = false
	self:InitConent()
end

function CHfdmInfoBox.InitConent(self)
	self.m_TipSpr   = self:NewUI(1, CSprite) 
	self.m_RightSpr = self:NewUI(2, CSprite)
	self.m_InfoLab  = self:NewUI(3, CLabel)
	self.m_TipSpr:AddUIEvent("click", callback(self, "ChooseSide"))
end

function CHfdmInfoBox.IsAnswer(self, info, choose)
	self:SetActive(true)
	self.m_Data = info
	self.m_InfoLab:SetActive(true)
	self.m_InfoLab:SetText(choose)
	self.m_TipSpr:SetSpriteName("h7_huafang_5")
	self.m_RightSpr:SetActive(false)
	
end

function CHfdmInfoBox.NotifyResult(self, rightinfo, myChoose)
	if g_GuessRiddleCtrl.m_MyChoose == 0 then
		return 
	end
	self.m_InfoLab:SetActive(true)
	if self.m_Data ==  rightinfo and self.m_Data == myChoose then
		self.m_TipSpr:SetSpriteName("h7_huafang_3")
		self.m_RightSpr:SetActive(true)
		self.m_RightSpr:SetSpriteName("h7_gougou_1")
	elseif self.m_Data ~=  rightinfo and self.m_Data == myChoose then
		self.m_TipSpr:SetSpriteName("h7_huafang_4")
		self.m_RightSpr:SetActive(true)
		self.m_RightSpr:SetSpriteName("h7_chacha_1")
	end
end

function CHfdmInfoBox.ChooseSide(self)
    local oEffect = nil
    local path = "Effect/UI/ui_eff_zhiyin_001/Prefabs/ui_eff_zhiyin_001.prefab"
    local function effectDone ()
    	if self.m_EffectTimer then
    		Utils.DelTimer(self.m_EffectTimer)
    	end
    	local function endfunc()
    		oEffect:SetActive(false)
    		self.m_IsExitEffect = false
    		return false
    	end
    	self.m_EffectTimer = Utils.AddTimer(endfunc, 0, 3)
	end
	if self.m_IsExitEffect == false then
		oEffect = CEffect.New(path, self:GetLayer(), false, effectDone)
		oEffect:SetParent(self.m_TipSpr.m_Transform)
		oEffect:SetLocalEulerAngles(Vector3.New(0,0,-45))
		self.m_IsExitEffect = true
	end

	local pos = nil
	if self.m_Data == 1 then
		pos = {x= 5.37, y= 6.4, z = 0}
	elseif self.m_Data == 2 then
		pos = {x= 23.1, y= 6.4, z = 0}
	end
	local oHero = g_MapCtrl:GetHero()
	local nowpos = oHero:GetLocalPos()  

	if nowpos and math.floor(nowpos.x) == 5 and  math.floor(nowpos.y) == 6  and self.m_Data == 1 then
		g_NotifyCtrl:FloatMsg("已经到达选定位置")
	elseif nowpos and math.floor(nowpos.x) == 23 and  math.floor(nowpos.y) == 6 and self.m_Data == 2 then
		g_NotifyCtrl:FloatMsg("已经到达选定位置")
	else
		g_MapTouchCtrl:WalkToPos(pos)
	end
end

function CHfdmInfoBox.RefreshSelectInfo(self, selectinfo)
	-- body
	if self.m_Data == selectinfo then
		self.m_TipSpr:SetSpriteName("h7_huafang_3")
		self.m_TipSpr:AddEffect("Rect")
	else
		self.m_TipSpr:SetSpriteName("h7_huafang_5")
		self.m_TipSpr:DelEffect("Rect")
	end

end

return CHfdmInfoBox