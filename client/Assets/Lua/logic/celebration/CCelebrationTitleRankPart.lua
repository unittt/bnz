CCelebrationTitleRankPart = class("CCelebrationTitleRankPart", CPageBase)

function CCelebrationTitleRankPart.ctor(self, cb)
    CPageBase.ctor(self,cb)

    self.m_DescLbl = self:NewUI(1, CLabel)
    self.m_TimeLbl = self:NewUI(2, CLabel)
    self.m_RankBtn = self:NewUI(3, CWidget)
    self.m_PrizeScrollView = self:NewUI(4, CScrollView)
    self.m_PrizeGrid = self:NewUI(5, CGrid)
    self.m_BoxClone = self:NewUI(6, CBox)
    self.m_RankBtn:SetActive(false)
    self.m_BoxClone:SetActive(false)

    self.m_ContentObj = self:NewUI(7, CObject)
    self.m_Hint = self:NewUI(8, CLabel)

    self.m_RankBtn:AddUIEvent("click", callback(self, "OnClickCheckRank"))
    g_CelebrationCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnUpdateCelebrationEvent"))
    g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CCelebrationTitleRankPart.OnUpdateCelebrationEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Celebration.Event.UpdateTouXianRank then
        self:RefreshUI()
    end
end

function CCelebrationTitleRankPart.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.WelFare.Event.UpdateServerTime then
        if not g_CelebrationCtrl.m_KaifuRankRewardData then
            return
        end
        --暂时屏蔽
        -- if (g_TimeCtrl:GetTimeS() - g_CelebrationCtrl.m_KaifuRankRewardData.txendtime) > 0 then
        --     self.m_ContentObj:SetActive(false)
        --     self.m_Hint:SetActive(true)
        --     self.m_Hint:SetText("活动已经结束了哦")
        --     return
        -- end
        self:CheckLeftTime()
    end
end

function CCelebrationTitleRankPart.OnInitPage(self)
    
end

function CCelebrationTitleRankPart.OnShowPage(self)
    nethuodong.C2GSKFGetTXRank()
end

function CCelebrationTitleRankPart.RefreshUI(self)
    self.m_DescLbl:SetText(data.huodongdata.KAIFUTEXT[define.Celebration.Text.TitleIns].content)
    self:SetRankPrizeList()
    if not g_CelebrationCtrl.m_KaifuRankRewardData then
        return
    end
    local oAll = os.date("%m/%d-", g_CelebrationCtrl.m_KaifuRankRewardData.txendtime)
    local oMonth = string.gsub(oAll, "/", "月")
    local oDay = string.gsub(oMonth, "-", "日")
    local oHour = tonumber(os.date("%H", g_CelebrationCtrl.m_KaifuRankRewardData.txendtime))
    oDay = oDay..oHour.."点"
    local oDescStr = string.gsub(data.huodongdata.KAIFUTEXT[define.Celebration.Text.TitleIns].content, "#time", oDay)
    self.m_DescLbl:SetText(oDescStr)
    --暂时屏蔽
    -- self.m_ContentObj:SetActive(true)
    -- self.m_Hint:SetActive(false)
    -- if (g_TimeCtrl:GetTimeS() - g_CelebrationCtrl.m_KaifuRankRewardData.txendtime) > 0 then
    --     self.m_ContentObj:SetActive(false)
    --     self.m_Hint:SetActive(true)
    --     self.m_Hint:SetText("活动已经结束了哦")
    --     return
    -- end
    self:CheckLeftTime()
end

function CCelebrationTitleRankPart.CheckLeftTime(self)
    if not g_CelebrationCtrl.m_KaifuRankRewardData then
        return
    end
    local oLeftTime = g_CelebrationCtrl.m_KaifuRankRewardData.txendtime - g_TimeCtrl:GetTimeS()
    if oLeftTime > 0 then
        self.m_TimeLbl:SetActive(true)
        local oTime = g_CelebrationCtrl:GetLeftTime(oLeftTime)
        self.m_TimeLbl:SetText("剩余时间："..oTime)
    else
        self.m_TimeLbl:SetActive(false)
        self.m_TimeLbl:SetText("已过期")
    end
end

function CCelebrationTitleRankPart.OnClickCheckRank(self)
    
end

function CCelebrationTitleRankPart.SetRankPrizeList(self)
    --只显示10个头衔
    local optionCount = g_CelebrationCtrl.m_TouXianRankLen
    local GridList = self.m_PrizeGrid:GetChildList() or {}
    local oPrizeBox
    if optionCount > 0 then
        for i=1,optionCount do
            if i > #GridList then
                oPrizeBox = self.m_BoxClone:Clone(false)
                -- self.m_PrizeGrid:AddChild(oOptionBtn)
            else
                oPrizeBox = GridList[i]
                oPrizeBox.m_Grid:Clear()
            end
            self:SetRankPrizeBox(oPrizeBox, g_CelebrationCtrl.m_TouXianRankList[i], i)
        end

        if #GridList > optionCount then
            for i=optionCount+1,#GridList do
                GridList[i]:SetActive(false)
            end
        end
    else
        if GridList and #GridList > 0 then
            for _,v in ipairs(GridList) do
                v:SetActive(false)
            end
        end
    end
    self.m_PrizeGrid:Reposition()
    self.m_PrizeScrollView:ResetPosition()
end


function CCelebrationTitleRankPart.SetRankPrizeBox(self, oPrizeBox, oData, oIndex)
    oPrizeBox:SetActive(true)

    oPrizeBox.m_RankLbl = oPrizeBox:NewUI(1, CLabel)
    oPrizeBox.m_ScrollView = oPrizeBox:NewUI(2, CScrollView)
    oPrizeBox.m_Grid = oPrizeBox:NewUI(3, CGrid)
    oPrizeBox.m_BoxClone = oPrizeBox:NewUI(4, CBox)
    oPrizeBox.m_NameLbl = oPrizeBox:NewUI(5, CLabel)
    oPrizeBox.m_BoxClone:SetActive(false)
    oPrizeBox.m_RankBg = oPrizeBox:NewUI(6, CSprite)
    oPrizeBox.m_Rank123Sp = oPrizeBox:NewUI(7, CSprite)

    oPrizeBox.m_RankLbl:SetActive(true)
    oPrizeBox.m_RankBg:SetActive(false)
    oPrizeBox.m_Rank123Sp:SetActive(false)
    oPrizeBox.m_NameLbl:SetActive(true)

    oPrizeBox.m_RankLbl:SetText("第"..oData.rank.."名")
    self:CheckRank123(oPrizeBox, oData.rank)
    if oData.pid then       
        oPrizeBox.m_NameLbl:SetText(oData.name)
    else
        oPrizeBox.m_NameLbl:SetText("虚位以待")
    end

    local oRewardConfig = data.huodongdata.KAIFUCONFIG.kaifu_touxian.client_rewardlist[oIndex]
    self:SetPrizeList(g_GuideHelpCtrl:GetRewardList("KAIFUDIANLI", (oRewardConfig and {oRewardConfig.reward} or {nil})[1]), oPrizeBox)

    oPrizeBox:AddUIEvent("click", callback(self,"OnClickShowInfo", oData))

    self.m_PrizeGrid:AddChild(oPrizeBox)
    self.m_PrizeGrid:Reposition()
end

function CCelebrationTitleRankPart.CheckRank123(self, oPrizeBox, oRank)
    if oRank == 1 then
        oPrizeBox.m_RankLbl:SetActive(false)
        oPrizeBox.m_RankBg:SetActive(true)
        oPrizeBox.m_Rank123Sp:SetActive(true)
        oPrizeBox.m_Rank123Sp:SetSpriteName("h7_diyi")
    elseif oRank == 2 then
        oPrizeBox.m_RankLbl:SetActive(false)
        oPrizeBox.m_RankBg:SetActive(true)
        oPrizeBox.m_Rank123Sp:SetActive(true)
        oPrizeBox.m_Rank123Sp:SetSpriteName("h7_dier")
    elseif oRank == 3 then
        oPrizeBox.m_RankLbl:SetActive(false)
        oPrizeBox.m_RankBg:SetActive(true)
        oPrizeBox.m_Rank123Sp:SetActive(true)
        oPrizeBox.m_Rank123Sp:SetSpriteName("h7_disan")
    end
end

function CCelebrationTitleRankPart.SetPrizeList(self, list, oBox)
    oBox.m_Grid:Clear()
    local optionCount = #list
    local GridList = oBox.m_Grid:GetChildList() or {}
    local oPrizeItemBox
    if optionCount > 0 then
        for i=1,optionCount do
            if i > #GridList then
                oPrizeItemBox = oBox.m_BoxClone:Clone(false)
                -- oBox.m_Grid:AddChild(oOptionBtn)
            else
                oPrizeItemBox = GridList[i]
            end
            self:SetPrizeBox(oPrizeItemBox, list[i], oBox)
        end

        if #GridList > optionCount then
            for i=optionCount+1,#GridList do
                GridList[i]:SetActive(false)
            end
        end
    else
        if GridList and #GridList > 0 then
            for _,v in ipairs(GridList) do
                v:SetActive(false)
            end
        end
    end

    oBox.m_Grid:Reposition()
    oBox.m_ScrollView:ResetPosition()
end

function CCelebrationTitleRankPart.SetPrizeBox(self, oPrizeItemBox, oData, oBox)
    oPrizeItemBox:SetActive(true)
    oPrizeItemBox.m_IconSp = oPrizeItemBox:NewUI(1, CSprite)
    oPrizeItemBox.m_CountLbl = oPrizeItemBox:NewUI(2, CLabel)
    oPrizeItemBox.m_QualitySp = oPrizeItemBox:NewUI(3, CSprite)
    oPrizeItemBox.m_QualitySp:SetItemQuality(g_ItemCtrl:GetQualityVal( oData.item.id, oData.item.quality or 0 ))
    oPrizeItemBox.m_IconSp:SpriteItemShape(oData.item.icon)
    oPrizeItemBox.m_Data = oData
    if oData.amount > 0 then
        oPrizeItemBox.m_CountLbl:SetActive(true)
        oPrizeItemBox.m_CountLbl:SetText(oData.amount)
    else
        oPrizeItemBox.m_CountLbl:SetActive(false)
    end
    
    oPrizeItemBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickPrizeBox", oData.item, oPrizeItemBox, oData))

    oBox.m_Grid:AddChild(oPrizeItemBox)
    oBox.m_Grid:Reposition()
end

function CCelebrationTitleRankPart.OnClickPrizeBox(self, oPrize, oPrizeItemBox, oData)
    local args = {
        widget = oPrizeItemBox,
        side = enum.UIAnchor.Side.Top,
        offset = Vector2.New(0, 0)
    }
    g_WindowTipCtrl:SetWindowItemTip(oPrize.id, args)
end

function CCelebrationTitleRankPart.OnClickShowInfo(self, oData)
    if not oData.pid then
        return
    end
    netplayer.C2GSGetPlayerInfo(oData.pid)
end

return CCelebrationTitleRankPart