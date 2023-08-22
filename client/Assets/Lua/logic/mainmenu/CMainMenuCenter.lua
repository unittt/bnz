local CMainMenuCenter = class("CMainMenuCenter", CBox)

function CMainMenuCenter.ctor(self, obj)
	CBox.ctor(self, obj)
	
	self.m_AvatarBox = self:NewUI(1, CBox)
	self.m_ThreeBiwuInfoBtn = self:NewUI(2, CButton)
	self.m_DancingBtn = self:NewUI(3, CTexture)
	self.m_DungeonConfirmBtn = self:NewUI(4, CButton)
	self.m_PkCountTimeLabel = self:NewUI(5, CLabel)
	self.m_OrgMatchBox = self:NewUI(6, COrgMatchBox)
	self.m_SingleBiwuInfoBtn = self:NewUI(7, CButton)
	self.m_ReturnJieBaiYiShi = self:NewUI(8, CSprite)
	self.matchTimer = nil

	self:InitContent()
end

function CMainMenuCenter.InitContent(self)
	self:HidePlayerAvatar()
	self:RefreshDancingBtn()
	self:ShowDungeonConfirm(false)
	self.m_PkCountTimeLabel:SetActive(false)
	-- if g_PKCtrl.m_PKMatchLeftTime > 0 then
	--     self:ShowPKMathcingTime(true)
	-- else
		self:ShowPKMathcingTime(false)
	-- end
	self:CheckThreeBiwuIcon()
	self:CheckSingleBiwuIcon()

	self.m_AvatarBox:AddUIEvent("click", callback(self, "OnAvatar"))
	self.m_DancingBtn:AddUIEvent("click", callback(self, "OnDancing")) 
	self.m_DungeonConfirmBtn:AddUIEvent("click", callback(self, "OnDungeon"))
	self.m_ThreeBiwuInfoBtn:AddUIEvent("click", callback(self, "OnClickThreeBiwuBtn"))
	self.m_SingleBiwuInfoBtn:AddUIEvent("click", callback(self, "OnClickSingleBiwuBtn"))
	self.m_ReturnJieBaiYiShi:AddUIEvent("click",  callback(self, "OnClickJieBaiBtn"))

	g_UITouchCtrl:TouchOutDetect(self.m_AvatarBox, callback(self, "HidePlayerAvatar"))	
	g_DancingCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnDancingEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemEvent"))
	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMapEvent"))
	g_DungeonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnDungeonEvent"))
	g_PKCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPkEvent"))
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWarEvent"))
	g_JieBaiCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnJieBaiEvent"))

	self:BindMenuArea()
	self:CheckJieBaiReturnBtn()

end

function CMainMenuCenter.BindMenuArea(self)
	local tweenAlpha_1 = self.m_OrgMatchBox:GetComponent(classtype.TweenAlpha)

	g_MainMenuCtrl:AddPopArea(define.MainMenu.AREA.OrgMatchBox, tweenAlpha_1)
end

--------------------------Event处理---------------------------------------
function CMainMenuCenter.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
        self:RefreshDancingBtn()
	end
end

function CMainMenuCenter.OnItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem then
        self:RefreshDancingBtn()
	end
end

function CMainMenuCenter.OnDancingEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Dancing.Event.DanceStateUpdate then
	   self:RefreshDancingBtn()
	end
end

function CMainMenuCenter.OnMapEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Map.Event.EnterScene then
		self:RefreshDancingBtn(false)
		
	elseif oCtrl.m_EventID == define.Map.Event.ShowScene then
		if g_PKCtrl.m_pkMapId ~= g_MapCtrl:GetMapID() then
		   self:ShowPKMathcingTime(false)
		end
		self:CheckThreeBiwuIcon()
		self:CheckSingleBiwuIcon()
		self:CheckJieBaiReturnBtn()
	elseif oCtrl.m_EventID == define.Map.Event.CheckHeroInDance then
        local isShow = g_DancingCtrl:IsShowDanceIcon(oCtrl.m_EventData)
        self:RefreshDancingBtn(isShow)
	end
end

function CMainMenuCenter.OnDungeonEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Dungeon.Event.RefreshComfirm then
        if not g_WarCtrl:IsWar() then
            self:ShowDungeonConfirm(true)
        end
	elseif oCtrl.m_EventID == define.Dungeon.Event.FinishComfirm then
		self:ShowDungeonConfirm(false)
	end
end

function CMainMenuCenter.OnPkEvent(self, oCtrl)
    if oCtrl.m_EventID == define.PkAction.Event.PKMatchCountTime then
    	-- if g_PKCtrl.m_PKMatchLeftTime > 0 then
    	-- 	self:ShowPKMathcingTime(true)
    	-- else
    		self:ShowPKMathcingTime(false)
    	-- end
    end
    if oCtrl.m_EventID == define.PkAction.Event.MatchEnd then
       self:ShowPKMathcingTime(false)
    end
end

function CMainMenuCenter.OnWarEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.WarStart or oCtrl.m_EventID == define.War.Event.WarEnd then
		if g_WarCtrl:IsWar() then
			self:RefreshDancingBtn(false)
            self:ShowDungeonConfirm(false)
		else
			if g_MapCtrl:GetHero() then
				local isShow = g_DancingCtrl:IsShowDanceIcon(g_MapCtrl:CheckInDanceArea(g_MapCtrl:GetHero()))
	       		self:RefreshDancingBtn(isShow)
                -- local bShowFb = g_DungeonCtrl:GeConfirmFinishTime() > g_TimeCtrl:GetTimeS()
                -- self:ShowDungeonConfirm(bShowFb)
	       	end
		end
		self:CheckThreeBiwuIcon()
		self:CheckSingleBiwuIcon()
	end
end

function CMainMenuCenter.OnJieBaiEvent(self, oCtrl)
	
	if oCtrl.m_EventID == define.JieBai.Event.ViewOnClose or oCtrl.m_EventID == define.JieBai.Event.JieBaiInfoChange then
	    self:CheckJieBaiReturnBtn()
	end

end

------------------------UI刷新--------------------------------------

function CMainMenuCenter.CheckThreeBiwuIcon(self)
	if data.biwutextdata.THREEBIWUSCENE[1001].map_id == g_MapCtrl.m_MapID then
		if g_WarCtrl:IsWar() then
			self.m_ThreeBiwuInfoBtn:SetActive(false)
		else
			self.m_ThreeBiwuInfoBtn:SetActive(true)
		end
	else
		self.m_ThreeBiwuInfoBtn:SetActive(false)
	end
end

function CMainMenuCenter.CheckSingleBiwuIcon(self)
	local bShow = g_MapCtrl:IsInSingleBiwuMap() and not g_WarCtrl:IsWar()
	self.m_SingleBiwuInfoBtn:SetActive(bShow)
end

function CMainMenuCenter.ShowDungeonConfirm(self, bIsShow)
	self.m_DungeonConfirmBtn:SetActive(bIsShow)
end

function CMainMenuCenter.ShowPlayerAvatar(self, pid)
	local heroSpr = self.m_AvatarBox:NewUI(1, CSprite)
	local player = g_MapCtrl:GetPlayer(pid)
	heroSpr:SpriteAvatar(player.m_Icon)
	self.m_AvatarBox:SetActive(true)
	self.m_AvatarBox.m_Pid = pid
	if  g_GuessRiddleCtrl.m_IsInHfdmMap then
		self.m_AvatarBox:SetAnchor("bottomAnchor", 66, 0)
		self.m_AvatarBox:SetAnchor("topAnchor", 140, 0)
	else
		self.m_AvatarBox:SetAnchor("bottomAnchor",  116, 0)
		self.m_AvatarBox:SetAnchor("topAnchor", 190, 0)
	end
end

function CMainMenuCenter.HidePlayerAvatar(self)
	self.m_AvatarBox:SetActive(false)
	self.m_AvatarBox.m_Pid = nil
end

--舞会活动按钮刷新
function CMainMenuCenter.RefreshDancingBtn(self, bIsInArena)
	if bIsInArena == nil then
		bIsInArena = false
		local oHero = g_MapCtrl:GetHero()
		if oHero then
		   bIsInArena = g_DancingCtrl:IsShowDanceIcon(oHero.m_IsInDance)
		end
	end
	if g_DancingCtrl.m_StateInfo then
	   bIsInArena = false
	end
	self.m_DancingBtn:SetActive(bIsInArena)
end

--开启匹配倒计时
function CMainMenuCenter.ShowPKMathcingTime(self, isMatch, matchnigTime)
    local isMatching = isMatch
    self:DelMatchTimer()
    if not isMatching or g_WarCtrl:IsWar() then
       self.m_PkCountTimeLabel:SetActive(false)
       return
    end
    self.m_PkCountTimeLabel:SetActive(isMatching)
    self.m_PkCountTimeLabel:SetText("对手匹配中......("..g_PKCtrl.m_PKMatchLeftTime..")")
  --   local update = function()
  --   	if Utils.IsNil(self) then
  --   		return
  --   	end
		-- self.m_PkCountTimeLabel:SetText("对手匹配中......("..matchnigTime..")")
		-- if matchnigTime <= 0 then
		-- 	self:DelMatchTimer()
		-- 	return false
		-- end
		-- matchnigTime = matchnigTime - 1
		-- return true
  --   end
  --   self.matchTimer = Utils.AddTimer(update,1,0)
end

--删除匹配倒计时计时器
function CMainMenuCenter.DelMatchTimer(self)
    if self.matchTimer then
        Utils.DelTimer(self.matchTimer)
        self.matchTimer = nil
    end
end

-------------------------点击事件------------------------
function CMainMenuCenter.OnAvatar(self)
	local pid = self.m_AvatarBox.m_Pid
	if pid then
		netplayer.C2GSGetPlayerInfo(pid)
	end
	self:HidePlayerAvatar()
end

function CMainMenuCenter.OnDancing(self)
	CDanceWindowView:ShowView()
end

function CMainMenuCenter.OnDungeon(self)
	CDungeonConfirmView:ShowView(function(oView)
		oView:RefreshAll()
	end)
end

function CMainMenuCenter.OnClickThreeBiwuBtn(self)
	nethuodong.C2GSThreeBWGetRankInfo()
end

function CMainMenuCenter.OnClickSingleBiwuBtn(self)
	CSingleBiwuInfoView:ShowView()
end

function CMainMenuCenter.OnClickJieBaiBtn(self)
	
	g_JieBaiCtrl:RetrunYiShi()
	self:CheckJieBaiReturnBtn()

end

function CMainMenuCenter.CheckJieBaiReturnBtn(self)
	
	self.m_ReturnJieBaiYiShi:SetActive(g_JieBaiCtrl:IsShowReturnBtn())

end

return CMainMenuCenter