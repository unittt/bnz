CCelebrationSummonRankPart = class("CCelebrationSummonRankPart", CPageBase)

function CCelebrationSummonRankPart.ctor(self, cb)
    CPageBase.ctor(self,cb)

    self.m_DescLbl = self:NewUI(1, CLabel)
    self.m_TimeLbl = self:NewUI(2, CLabel)
    self.m_RankBtn = self:NewUI(3, CWidget)
    self.m_PrizeScrollView = self:NewUI(4, CScrollView)
    self.m_PrizeGrid = self:NewUI(5, CGrid)
    self.m_BoxClone = self:NewUI(6, CBox)
    self.m_BoxClone:SetActive(false)

    self.m_ContentObj = self:NewUI(7, CObject)
    self.m_Hint = self:NewUI(8, CLabel)

    self.m_RankInfoData = nil
    self.m_RankInfoList = {}
    self.m_RankIdx = g_RankCtrl.m_CelebrationRankType[3]

    self.m_RankBtn:AddUIEvent("click", callback(self, "OnClickCheckRank"))
    g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
    g_RankCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlRankEvent"))
end

function CCelebrationSummonRankPart.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.WelFare.Event.UpdateServerTime then
        if not g_CelebrationCtrl.m_KaifuRankRewardData then
            return
        end
        --暂时屏蔽
        -- if (g_TimeCtrl:GetTimeS() - g_CelebrationCtrl.m_KaifuRankRewardData.sumendtime) > 0 then
        --     self.m_ContentObj:SetActive(false)
        --     self.m_Hint:SetActive(true)
        --     self.m_Hint:SetText("活动已经结束了哦")
        --     return
        -- end
        self:CheckLeftTime()
    end
end

function CCelebrationSummonRankPart.OnCtrlRankEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Rank.Event.UpdateRankInfo then
        local oEventData = oCtrl.m_EventData
        if not oEventData or oEventData.idx ~= self.m_RankIdx or oEventData.page ~= 1 then
            return
        end
        self.m_RankInfoData = oEventData
        self.m_RankInfoList = {}
        for i=1, 10 do
            if self.m_RankInfoData.kaifu_summon_rank[i] then
                self.m_RankInfoList[i] = self.m_RankInfoData.kaifu_summon_rank[i]
            end
        end
        self:SetRankPrizeList()
    end
end

function CCelebrationSummonRankPart.OnInitPage(self)
    
end

function CCelebrationSummonRankPart.OnShowPage(self)
    self:RefreshUI()
    if (g_TimeCtrl:GetTimeS() - g_CelebrationCtrl.m_KaifuRankRewardData.sumendtime) > 0 then
        if not self.m_RankInfoData then
            netrank.C2GSGetRankInfo(self.m_RankIdx, 1)
        end
    end
end

function CCelebrationSummonRankPart.RefreshUI(self)
    self.m_DescLbl:SetText(data.huodongdata.KAIFUTEXT[define.Celebration.Text.SummonIns].content)
    self:SetRankPrizeList()
    if not g_CelebrationCtrl.m_KaifuRankRewardData then
        return
    end
    local oAll = os.date("%m/%d-", g_CelebrationCtrl.m_KaifuRankRewardData.sumendtime)
    local oMonth = string.gsub(oAll, "/", "月")
    local oDay = string.gsub(oMonth, "-", "日")
    local oHour = tonumber(os.date("%H", g_CelebrationCtrl.m_KaifuRankRewardData.sumendtime))
    oDay = oDay..oHour.."点"
    local oDescStr = string.gsub(data.huodongdata.KAIFUTEXT[define.Celebration.Text.SummonIns].content, "#time", oDay)
    self.m_DescLbl:SetText(oDescStr)
    --暂时屏蔽
    -- self.m_ContentObj:SetActive(true)
    -- self.m_Hint:SetActive(false)
    -- if (g_TimeCtrl:GetTimeS() - g_CelebrationCtrl.m_KaifuRankRewardData.sumendtime) > 0 then
    --     self.m_ContentObj:SetActive(false)
    --     self.m_Hint:SetActive(true)
    --     self.m_Hint:SetText("活动已经结束了哦")
    --     return
    -- end
    self:CheckLeftTime()
end

function CCelebrationSummonRankPart.CheckLeftTime(self)
    if not g_CelebrationCtrl.m_KaifuRankRewardData then
        return
    end
    local oLeftTime = g_CelebrationCtrl.m_KaifuRankRewardData.sumendtime - g_TimeCtrl:GetTimeS()
    if oLeftTime > 0 then
        self.m_TimeLbl:SetActive(true)
        local oTime = g_CelebrationCtrl:GetLeftTime(oLeftTime)
        self.m_TimeLbl:SetText("剩余时间："..oTime)
    else
        self.m_TimeLbl:SetActive(false)
        self.m_TimeLbl:SetText("已过期")
    end
end

function CCelebrationSummonRankPart.OnClickCheckRank(self)
    CCelebrationRankListView:ShowView(function (oView)
        oView:OnSelectIndex(3)
    end)
end

function CCelebrationSummonRankPart.SetRankPrizeList(self)
    if (g_TimeCtrl:GetTimeS() - g_CelebrationCtrl.m_KaifuRankRewardData.sumendtime) > 0 then
        local optionCount = #self.m_RankInfoList
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
                self:SetRankPrizeRankBox(oPrizeBox, self.m_RankInfoList[i], i)
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
    else
        local optionCount = #data.huodongdata.KAIFUCONFIG.kaifu_summon.client_rewardlist
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
                self:SetRankPrizeBox(oPrizeBox, data.huodongdata.KAIFUCONFIG.kaifu_summon.client_rewardlist[i], i)
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
    end
    self.m_PrizeGrid:Reposition()
    self.m_PrizeScrollView:ResetPosition()
end

function CCelebrationSummonRankPart.SetRankPrizeRankBox(self, oPrizeBox, oData, oIndex)
    oPrizeBox:SetActive(true)

    oPrizeBox.m_RankLbl = oPrizeBox:NewUI(1, CLabel)
    oPrizeBox.m_ScrollView = oPrizeBox:NewUI(2, CScrollView)
    oPrizeBox.m_Grid = oPrizeBox:NewUI(3, CGrid)
    oPrizeBox.m_BoxClone = oPrizeBox:NewUI(4, CBox)
    oPrizeBox.m_BoxClone:SetActive(false)
    oPrizeBox.m_RankBg = oPrizeBox:NewUI(5, CSprite)
    oPrizeBox.m_Rank123Sp = oPrizeBox:NewUI(6, CSprite)
    oPrizeBox.m_NameLbl = oPrizeBox:NewUI(7, CLabel)

    oPrizeBox.m_RankLbl:SetActive(true)
    oPrizeBox.m_RankBg:SetActive(false)
    oPrizeBox.m_Rank123Sp:SetActive(false)

    if oIndex <= 3 then
        self:CheckRank123(oPrizeBox, oIndex)
    else
        oPrizeBox.m_RankLbl:SetText("第"..oIndex.."名")
    end

    oPrizeBox.m_ScrollView:SetActive(false)
    oPrizeBox.m_NameLbl:SetActive(true)
    oPrizeBox.m_NameLbl:SetText(oData.name)

    oPrizeBox:AddUIEvent("click", callback(self,"OnClickShowInfo", oIndex))

    self.m_PrizeGrid:AddChild(oPrizeBox)
    self.m_PrizeGrid:Reposition()
end

function CCelebrationSummonRankPart.SetRankPrizeBox(self, oPrizeBox, oData, oIndex)
    oPrizeBox:SetActive(true)

    oPrizeBox.m_RankLbl = oPrizeBox:NewUI(1, CLabel)
    oPrizeBox.m_ScrollView = oPrizeBox:NewUI(2, CScrollView)
    oPrizeBox.m_Grid = oPrizeBox:NewUI(3, CGrid)
    oPrizeBox.m_BoxClone = oPrizeBox:NewUI(4, CBox)
    oPrizeBox.m_BoxClone:SetActive(false)
    oPrizeBox.m_RankBg = oPrizeBox:NewUI(5, CSprite)
    oPrizeBox.m_Rank123Sp = oPrizeBox:NewUI(6, CSprite)
    oPrizeBox.m_NameLbl = oPrizeBox:NewUI(7, CLabel)

    oPrizeBox.m_RankLbl:SetActive(true)
    oPrizeBox.m_RankBg:SetActive(false)
    oPrizeBox.m_Rank123Sp:SetActive(false)

    if oIndex == 1 then
        if oData.rank ~= 1 then
            oPrizeBox.m_RankLbl:SetText("第1-"..oData.rank.."名")
        else
            oPrizeBox.m_RankLbl:SetText("第"..oData.rank.."名")
            self:CheckRank123(oPrizeBox, oData.rank)
        end
    else
        local oLastIndex = oIndex - 1
        local oLastRankAddOne = data.huodongdata.KAIFUCONFIG.kaifu_summon.client_rewardlist[oLastIndex].rank + 1
        if oLastRankAddOne == oData.rank then
            oPrizeBox.m_RankLbl:SetText("第"..oData.rank.."名")
            self:CheckRank123(oPrizeBox, oData.rank)
        else
            oPrizeBox.m_RankLbl:SetText("第"..oLastRankAddOne.."-"..oData.rank.."名")
        end
    end

    self:SetPrizeList(g_GuideHelpCtrl:GetRewardList("KAIFUDIANLI", oData.reward), oPrizeBox)

    oPrizeBox:AddUIEvent("click", callback(self,"OnClickShowInfo"))

    self.m_PrizeGrid:AddChild(oPrizeBox)
    self.m_PrizeGrid:Reposition()
end

function CCelebrationSummonRankPart.CheckRank123(self, oPrizeBox, oRank)
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

function CCelebrationSummonRankPart.SetPrizeList(self, list, oBox)
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

function CCelebrationSummonRankPart.SetPrizeBox(self, oPrizeItemBox, oData, oBox)
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

function CCelebrationSummonRankPart.OnClickPrizeBox(self, oPrize, oPrizeItemBox, oData)
    local args = {
        widget = oPrizeItemBox,
        side = enum.UIAnchor.Side.Top,
        offset = Vector2.New(0, 0)
    }
    g_WindowTipCtrl:SetWindowItemTip(oPrize.id, args)
end

function CCelebrationSummonRankPart.OnClickShowInfo(self, oData)
    if not oData or not tonumber(oData) then
        return
    end
    netrank.C2GSGetRankSumInfo(oData, self.m_RankIdx)
end

return CCelebrationSummonRankPart