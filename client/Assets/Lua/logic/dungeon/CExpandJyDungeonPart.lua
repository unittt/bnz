local CExpandJyDungeonPart = class("CExpandJyDungeonPart", CPageBase)

function CExpandJyDungeonPart.ctor(self, obj)
    CPageBase.ctor(self, obj)
end

function CExpandJyDungeonPart.OnInitPage(self)
    self.m_TitleL = self:NewUI(1, CLabel)
    self.m_GoalL = self:NewUI(2, CLabel)
    self.m_DescL = self:NewUI(3, CLabel)
    self.m_FightDescL = self:NewUI(4, CLabel)
    self.m_BossDescL = self:NewUI(5, CLabel)
    self.m_BossSpr = self:NewUI(6, CSprite)
    self.m_RewardBox = self:NewUI(7, CBox)
    self.m_RewardGrid = self:NewUI(8, CGrid)
    self.m_ScrollView = self:NewUI(9, CScrollView)
    self.m_InfoObj = self:NewObjContainer(10, CObject)
    self.m_BgWdt = self:NewUI(11, CWidget)
    self.m_RewardL = self:NewUI(12, CLabel)
    self.m_RewardBox:SetActive(false)
    self.m_HasReward = false
    self.m_GoalL:SetActive(false)
    self.m_ScrollView:SetParent(self.m_BossDescL.m_Transform, true)
    self:RefreshTask()
    g_DungeonTaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnDungeonTaskEvent"))
    self.m_BgWdt:AddUIEvent("click", callback(self, "OnClickTask"))
end

function CExpandJyDungeonPart.RefreshTask(self)
    local oCtrl = g_DungeonTaskCtrl
    local bShow = oCtrl:IsInJyFuben()
    if bShow then
        self.m_TitleL:SetRichText(oCtrl:GetJyFubenFloorName(), nil, nil, true)
        -- self.m_GoalL:SetText(oCtrl:GetJyFubenGoalDesc())
        local bFight = oCtrl:IsFightTask(oCtrl.m_CurJyFubenTask)
        if bFight then
            self.m_FightDescL:SetRichText(oCtrl:GetJyFubenDesc(), nil, nil, true)
            self.m_BossDescL:SetRichText("#G"..oCtrl:GetJyFubenBossDesc(), nil, nil, true)
            self:SetBossSpr(oCtrl:GetJyFubenBossFigureId())
            self:RefreshRewards(oCtrl:GetJyFubenRewards())
        else
            self.m_DescL:SetRichText(oCtrl:GetJyFubenDesc(), nil, nil, true)
        end
        self.m_ScrollView:SetActive(bFight)
        self.m_BossDescL:SetActive(bFight)
        self.m_FightDescL:SetActive(bFight)
        self.m_DescL:SetActive(not bFight)
        Utils.AddTimer(function()
            self.m_ScrollView:ResetPosition()
            self:ResetBgSize(bFight)
        end,0,0)
    end
    self.m_InfoObj:SetActive(bShow)
end

function CExpandJyDungeonPart.SetBossSpr(self, iFigure)
    local oSpr = self.m_BossSpr.m_UIWidget
    self.m_BossSpr:SetSpriteName(iFigure)
    if not oSpr.isValid then
        local iOri = math.floor(iFigure/10)
        if iOri then
            self.m_BossSpr:SetSpriteName(iOri)
        end
        if not oSpr.isValid then
            local dConfig = ModelTools.GetModelConfig(iFigure)
            if dConfig then
                self.m_BossSpr:SetSpriteName(dConfig.model)
            end
        end
    end
end

function CExpandJyDungeonPart.RefreshRewards(self, rewards)
    self.m_RewardGrid:HideAllChilds()
    self.m_HasReward = rewards and #rewards > 0 
    self.m_RewardL:SetActive(self.m_HasReward)
    self.m_RewardGrid:SetActive(self.m_HasReward)
    if not self.m_HasReward then return end
    for i, v in ipairs(rewards) do
        local iAmount = v.amount
        if tonumber(iAmount) == nil then
            iAmount = string.eval(iAmount, {lv = g_AttrCtrl.grade,})
        end
        local oReward = self:GetRewardBox(i)
        local dItem = DataTools.GetItemData(v.sid)
        oReward.iconSpr:SpriteItemShape(dItem.icon)
        oReward.qualitySpr:SetItemQuality(g_ItemCtrl:GetQualityVal(v.sid, dItem.quality or 0))
        -- oReward.cntL:SetText(iAmount)
        oReward.cntL:SetActive(true)
        oReward.itemId = v.sid
        oReward:SetActive(true)
    end
    self.m_RewardGrid:Reposition()
end

function CExpandJyDungeonPart.ResetBgSize(self, bFight)
    local iGoalBot = self:GetWidgetBot(self.m_TitleL)--(self.m_GoalL)
    if bFight then
        local descPos = self.m_FightDescL:GetLocalPos()
        descPos.y = iGoalBot - 10
        self.m_FightDescL:SetLocalPos(descPos)

        local iDescBot = self:GetWidgetBot(self.m_FightDescL)
        local bossDescPos = self.m_BossDescL:GetLocalPos()
        bossDescPos.y = iDescBot - 10
        self.m_BossDescL:SetLocalPos(bossDescPos)
        local iRewardH = self.m_HasReward and 95 or 0
        self.m_BgWdt.m_UIWidget.height = self:GetBgTop() - iDescBot + iRewardH + 75
    else
        local descPos = self.m_FightDescL:GetLocalPos()
        descPos.y = iGoalBot - 15
        self.m_DescL:SetLocalPos(descPos)

        local iBot = self:GetWidgetBot(self.m_DescL)
        self.m_BgWdt.m_UIWidget.height = self:GetBgTop() - iBot + 30
    end
end

function CExpandJyDungeonPart.GetWidgetBot(self, oWidget)
    local pos = oWidget:GetLocalPos()
    local iHeight = oWidget.m_UIWidget.height
    return pos.y - iHeight
end

function CExpandJyDungeonPart.GetBgTop(self)
    local bgPos = self.m_BgWdt:GetLocalPos()
    return bgPos.y
end

function CExpandJyDungeonPart.GetRewardBox(self, idx)
    local oReward = self.m_RewardGrid:GetChild(idx)
    if not oReward then
        oReward = self.m_RewardBox:Clone()
        oReward.iconSpr = oReward:NewUI(1, CSprite)
        oReward.cntL = oReward:NewUI(2, CLabel)
        oReward.qualitySpr = oReward:NewUI(3, CSprite)
        oReward:AddUIEvent("click", callback(self, "OnClickItemBox"))
        self.m_RewardGrid:AddChild(oReward)
    end
    oReward:SetActive(true)
    return oReward
end

function CExpandJyDungeonPart.OnClickItemBox(self, oBox)
    if oBox.itemId then
        g_WindowTipCtrl:SetWindowItemTip(oBox.itemId, {widget=oBox})
    end
end

function CExpandJyDungeonPart.OnClickTask(self)
    if g_WarCtrl:IsWar() then return end
    if g_DungeonTaskCtrl:IsInJyFuben() then
        CTaskHelp.ClickTaskLogic(g_DungeonTaskCtrl.m_CurJyFubenTask)
    end
end

function CExpandJyDungeonPart.OnDungeonTaskEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Dungeon.Event.ReceiveJyFubenTask then
        self:RefreshTask()
    end
end

return CExpandJyDungeonPart