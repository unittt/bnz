CCelebrationStrengthRankPart = class("CCelebrationStrengthRankPart", CPageBase)

function CCelebrationStrengthRankPart.ctor(self, cb)
    CPageBase.ctor(self,cb)

    self.m_DescLbl = self:NewUI(1, CLabel)
    self.m_TimeLbl = self:NewUI(2, CLabel)
    self.m_RankBtn = self:NewUI(3, CWidget)
    self.m_PrizeScrollView = self:NewUI(4, CScrollView)
    self.m_PrizeGrid = self:NewUI(5, CGrid)
    self.m_BoxClone = self:NewUI(6, CBox)
    self.m_BoxClone:SetActive(false)
    self.m_PrizeGradeBox = self:NewUI(7, CBox)
    self.m_PrizeGradeBox.m_NameLbl = self.m_PrizeGradeBox:NewUI(1, CLabel)
    self.m_PrizeGradeBox.m_FinishBtn = self.m_PrizeGradeBox:NewUI(2, CButton)
    self.m_PrizeGradeBox.m_FinishMark = self.m_PrizeGradeBox:NewUI(3, CSprite)
    self.m_PrizeGradeBox.m_ScrollView = self.m_PrizeGradeBox:NewUI(4, CScrollView)
    self.m_PrizeGradeBox.m_Grid = self.m_PrizeGradeBox:NewUI(5, CGrid)
    self.m_PrizeGradeBox.m_BoxClone = self.m_PrizeGradeBox:NewUI(6, CBox)
    self.m_PrizeGradeBox.m_FinishMark:SetActive(false)
    self.m_PrizeGradeBox.m_BoxClone:SetActive(false)

    self.m_ContentObj = self:NewUI(8, CObject)
    self.m_Hint = self:NewUI(9, CLabel)
    self.m_LineSp = self:NewUI(10, CSprite)

    self.m_RankInfoData = nil
    self.m_RankInfoList = {}
    self.m_RankIdx = g_RankCtrl.m_CelebrationRankType[2]

    self.m_ScrollViewHeight = {320, 410}
    self.m_ScrollViewVet = {Vector3.New(66, -33, 0), Vector3.New(66, -33, 0)}

    self.m_IsUpdatePos = true

    self.m_RankBtn:AddUIEvent("click", callback(self, "OnClickCheckRank"))
    self.m_PrizeGradeBox.m_FinishBtn:AddUIEvent("click", callback(self, "OnClickGetScoreReward"))
    g_CelebrationCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnUpdateCelebrationEvent"))
    g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
    g_RankCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlRankEvent"))
end

function CCelebrationStrengthRankPart.OnUpdateCelebrationEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Celebration.Event.UpdateRankReward then
        self:CheckGradePrizeBox()
    end
end

function CCelebrationStrengthRankPart.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.WelFare.Event.UpdateServerTime then
        if not g_CelebrationCtrl.m_KaifuRankRewardData then
            return
        end
        --暂时屏蔽
        -- if (g_TimeCtrl:GetTimeS() - g_CelebrationCtrl.m_KaifuRankRewardData.playerscore.endtime) > 0 then
        --     self.m_ContentObj:SetActive(false)
        --     self.m_Hint:SetActive(true)
        --     self.m_Hint:SetText("活动已经结束了哦")
        --     return
        -- end
        self:CheckLeftTime()
        self:CheckGradePrizeBox()
    end
end

function CCelebrationStrengthRankPart.OnCtrlRankEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Rank.Event.UpdateRankInfo then
        local oEventData = oCtrl.m_EventData
        if not oEventData or oEventData.idx ~= self.m_RankIdx or oEventData.page ~= 1 then
            return
        end
        self.m_RankInfoData = oEventData
        self.m_RankInfoList = {}
        for i=1, 10 do
            if self.m_RankInfoData.kaifu_score_rank[i] then
                self.m_RankInfoList[i] = self.m_RankInfoData.kaifu_score_rank[i]
            end
        end
        self:SetRankPrizeList()
    end
end

function CCelebrationStrengthRankPart.OnInitPage(self)
    
end

function CCelebrationStrengthRankPart.OnShowPage(self)
    self:RefreshUI()
    if (g_TimeCtrl:GetTimeS() - g_CelebrationCtrl.m_KaifuRankRewardData.playerscore.endtime) > 0 then
        if not self.m_RankInfoData then
            netrank.C2GSGetRankInfo(self.m_RankIdx, 1)
        end
    end
end

function CCelebrationStrengthRankPart.RefreshUI(self)
    self.m_DescLbl:SetText(data.huodongdata.KAIFUTEXT[define.Celebration.Text.StrengthIns].content)
    self:SetRankPrizeList()
    if not g_CelebrationCtrl.m_KaifuRankRewardData then
        return
    end
    local oAll = os.date("%m/%d-", g_CelebrationCtrl.m_KaifuRankRewardData.playerscore.endtime)
    local oMonth = string.gsub(oAll, "/", "月")
    local oDay = string.gsub(oMonth, "-", "日")
    local oHour = tonumber(os.date("%H", g_CelebrationCtrl.m_KaifuRankRewardData.playerscore.endtime))
    oDay = oDay..oHour.."点"
    local oDescStr = string.gsub(data.huodongdata.KAIFUTEXT[define.Celebration.Text.StrengthIns].content, "#time", oDay)
    self.m_DescLbl:SetText(oDescStr)
    --暂时屏蔽
    -- self.m_ContentObj:SetActive(true)
    -- self.m_Hint:SetActive(false)
    -- if (g_TimeCtrl:GetTimeS() - g_CelebrationCtrl.m_KaifuRankRewardData.playerscore.endtime) > 0 then
    --     self.m_ContentObj:SetActive(false)
    --     self.m_Hint:SetActive(true)
    --     self.m_Hint:SetText("活动已经结束了哦")
    --     return
    -- end

    self:CheckLeftTime()
    self:CheckGradePrizeBox()
end

function CCelebrationStrengthRankPart.CheckGradePrizeBox(self)
    if not g_CelebrationCtrl.m_KaifuRankRewardData then
        return
    end
    self.m_PrizeGradeBox.m_FinishBtn:DelEffect("RedDot")
    local oGrdaeConfig
    local oServerData
    for k,v in ipairs(g_CelebrationCtrl.m_ScoreRewardConfig) do
        local oRewardData = g_CelebrationCtrl:GetIsRankRewardExist(g_CelebrationCtrl.m_KaifuRankRewardData.playerscore.rewarddata, v.score)
        if oRewardData and (oRewardData.reward == 0 or oRewardData.reward == 1) then --and v.openday >= g_CelebrationCtrl:GetStrengthHasOpenDay()
            oGrdaeConfig = v
            oServerData = oRewardData
            break
        end
    end
    if oGrdaeConfig then
        local oGradeStr = string.gsub(data.huodongdata.KAIFUTEXT[define.Celebration.Text.StrengthReward].content, "#amount", oGrdaeConfig.openday)
        oGradeStr = string.gsub(oGradeStr, "#score", oGrdaeConfig.score)
        self.m_PrizeGradeBox.m_NameLbl:SetText("[896055]"..oGradeStr)
        if oServerData.reward == 0 then
            -- self.m_PrizeGradeBox.m_NameLbl:SetText("评分不足"..oGrdaeConfig.score.."，不可领取")
            self.m_PrizeGradeBox.m_FinishBtn:GetComponent(classtype.BoxCollider).enabled = false
            self.m_PrizeGradeBox.m_FinishBtn:SetBtnGrey(true)
        elseif oServerData.reward == 1 then            
            self.m_PrizeGradeBox.m_FinishBtn:GetComponent(classtype.BoxCollider).enabled = true
            self.m_PrizeGradeBox.m_FinishBtn:SetBtnGrey(false)
            self.m_PrizeGradeBox.m_FinishBtn.m_IgnoreCheckEffect = true
            self.m_PrizeGradeBox.m_FinishBtn:AddEffect("RedDot", 22, Vector2(-15, -17))
            self.m_CouldGetConfig = oGrdaeConfig
        end

        self:SetPrizeList(g_GuideHelpCtrl:GetRewardList("KAIFUDIANLI", oGrdaeConfig.reward), self.m_PrizeGradeBox)
    else
        local oConfig = g_CelebrationCtrl.m_ScoreRewardConfig[#g_CelebrationCtrl.m_ScoreRewardConfig]
        local oGradeStr = string.gsub(data.huodongdata.KAIFUTEXT[define.Celebration.Text.StrengthReward].content, "#amount", oConfig.openday)
        oGradeStr = string.gsub(oGradeStr, "#score", oConfig.score)
        self.m_PrizeGradeBox.m_NameLbl:SetText("[896055]"..oGradeStr)
        self.m_PrizeGradeBox.m_FinishBtn:GetComponent(classtype.BoxCollider).enabled = false
        self.m_PrizeGradeBox.m_FinishBtn:SetBtnGrey(true)

        self:SetPrizeList(g_GuideHelpCtrl:GetRewardList("KAIFUDIANLI", oConfig.reward), self.m_PrizeGradeBox)
    end
end

function CCelebrationStrengthRankPart.CheckLeftTime(self)
    if not g_CelebrationCtrl.m_KaifuRankRewardData then
        return
    end
    local oLeftTime = g_CelebrationCtrl.m_KaifuRankRewardData.playerscore.endtime - g_TimeCtrl:GetTimeS()
    if oLeftTime > 0 then
        self.m_TimeLbl:SetActive(true)
        local oTime = g_CelebrationCtrl:GetLeftTime(oLeftTime)
        self.m_TimeLbl:SetText("剩余时间："..oTime)
    else
        self.m_TimeLbl:SetActive(false)
        self.m_TimeLbl:SetText("已过期")
    end
end

function CCelebrationStrengthRankPart.OnClickCheckRank(self)
    self.m_IsUpdatePos = false
    CCelebrationRankListView:ShowView(function (oView)
        oView:OnSelectIndex(2)
    end)
end

function CCelebrationStrengthRankPart.SetRankPrizeList(self)
    if (g_TimeCtrl:GetTimeS() - g_CelebrationCtrl.m_KaifuRankRewardData.playerscore.endtime) > 0 then
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
        self.m_PrizeScrollView:SetRect(5, 8, 720, self.m_ScrollViewHeight[2])
        self.m_LineSp:SetActive(false)
        self.m_PrizeGradeBox:SetActive(false)
    else
        local optionCount = #data.huodongdata.KAIFUCONFIG.kaifu_score.client_rewardlist
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
                self:SetRankPrizeBox(oPrizeBox, data.huodongdata.KAIFUCONFIG.kaifu_score.client_rewardlist[i], i)
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
        self.m_PrizeScrollView:SetRect(5, 8, 720, self.m_ScrollViewHeight[1])
        self.m_LineSp:SetActive(true)
        self.m_PrizeGradeBox:SetActive(true)
    end
    self.m_PrizeGrid:Reposition()
    self.m_PrizeScrollView:ResetPosition()
    if self.m_IsUpdatePos then
        self.m_PrizeScrollView:SetLocalPos(self.m_ScrollViewVet[1])
    end
    self.m_IsUpdatePos = true
end

function CCelebrationStrengthRankPart.SetRankPrizeRankBox(self, oPrizeBox, oData, oIndex)
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

    oPrizeBox:AddUIEvent("click", callback(self,"OnClickShowInfo", oData))

    self.m_PrizeGrid:AddChild(oPrizeBox)
    self.m_PrizeGrid:Reposition()
end

function CCelebrationStrengthRankPart.SetRankPrizeBox(self, oPrizeBox, oData, oIndex)
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
        local oLastRankAddOne = data.huodongdata.KAIFUCONFIG.kaifu_score.client_rewardlist[oLastIndex].rank + 1
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

function CCelebrationStrengthRankPart.CheckRank123(self, oPrizeBox, oRank)
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

function CCelebrationStrengthRankPart.SetPrizeList(self, list, oBox)
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

function CCelebrationStrengthRankPart.SetPrizeBox(self, oPrizeItemBox, oData, oBox)
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

function CCelebrationStrengthRankPart.OnClickPrizeBox(self, oPrize, oPrizeItemBox, oData)
    local args = {
        widget = oPrizeItemBox,
        side = enum.UIAnchor.Side.Top,
        offset = Vector2.New(0, 0)
    }
    g_WindowTipCtrl:SetWindowItemTip(oPrize.id, args)
end

function CCelebrationStrengthRankPart.OnClickGetScoreReward(self)
    if not self.m_CouldGetConfig then
        return
    end
   
    nethuodong.C2GSKFGetScoreReward(self.m_CouldGetConfig.score)
end

function CCelebrationStrengthRankPart.OnClickShowInfo(self, oData)
    if not oData or not oData.pid then
        return
    end
    netplayer.C2GSGetPlayerInfo(oData.pid)
end

return CCelebrationStrengthRankPart