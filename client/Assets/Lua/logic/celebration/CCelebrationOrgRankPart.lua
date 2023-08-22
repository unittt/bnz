CCelebrationOrgRankPart = class("CCelebrationOrgRankPart", CPageBase)

function CCelebrationOrgRankPart.ctor(self, cb)
    CPageBase.ctor(self,cb)

    self.m_PrizeBtn = self:NewUI(1, CButton)
    self.m_TargetBtn = self:NewUI(2, CButton)
    self.m_PrizeBox = self:NewUI(3, CBox)
    self.m_TargetBox = self:NewUI(4, CBox)

    self.m_PrizeBtn:SetGroup(self:GetInstanceID())
    self.m_TargetBtn:SetGroup(self:GetInstanceID())

    self.m_PrizeBox.m_DescLbl = self.m_PrizeBox:NewUI(1, CLabel)
    self.m_PrizeBox.m_TimeLbl = self.m_PrizeBox:NewUI(2, CLabel)
    self.m_PrizeBox.m_RankBtn = self.m_PrizeBox:NewUI(3, CWidget)
    self.m_PrizeBox.m_PrizeScrollView = self.m_PrizeBox:NewUI(4, CScrollView)
    self.m_PrizeBox.m_PrizeGrid = self.m_PrizeBox:NewUI(5, CGrid)
    self.m_PrizeBox.m_BoxClone = self.m_PrizeBox:NewUI(6, CBox)
    self.m_PrizeBox.m_BoxClone:SetActive(false)

    self.m_TargetBox.m_PrizeScrollView = self.m_TargetBox:NewUI(1, CScrollView)
    self.m_TargetBox.m_PrizeGrid = self.m_TargetBox:NewUI(2, CGrid)
    self.m_TargetBox.m_BoxClone = self.m_TargetBox:NewUI(3, CBox)
    self.m_TargetBox.m_BoxClone:SetActive(false)

    self.m_ContentObj = self:NewUI(5, CObject)
    self.m_Hint = self:NewUI(6, CLabel)

    self.m_PrizeBox.m_RankBtn:AddUIEvent("click", callback(self, "OnClickCheckRank"))
    self.m_PrizeBtn:AddUIEvent("click", callback(self, "OnClickShowPart", 1))
    self.m_TargetBtn:AddUIEvent("click", callback(self, "OnClickShowPart", 2))
    g_CelebrationCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnUpdateCelebrationEvent"))
    g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CCelebrationOrgRankPart.OnUpdateCelebrationEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Celebration.Event.UpdateRankReward then
        self:SetTargetPrizeList()
        self:SetTargetRedPoint()
    end
end

function CCelebrationOrgRankPart.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.WelFare.Event.UpdateServerTime then
        if not g_CelebrationCtrl.m_KaifuRankRewardData then
            return
        end
        if (g_TimeCtrl:GetTimeS() - g_CelebrationCtrl.m_KaifuRankRewardData.orgcnt.endtime) > 0 then
            self.m_ContentObj:SetActive(false)
            self.m_Hint:SetActive(true)
            self.m_Hint:SetText("活动已经结束了哦")
            return
        end
        self:CheckLeftTime()
    end
end

function CCelebrationOrgRankPart.OnInitPage(self)
    
end

function CCelebrationOrgRankPart.OnShowPage(self)
    self:RefreshUI()
end

function CCelebrationOrgRankPart.RefreshUI(self)
    self.m_PrizeBtn:SetSelected(true)
    self.m_PrizeBox:SetActive(true)
    self.m_TargetBox:SetActive(false)
    self.m_PrizeBox.m_DescLbl:SetText(data.huodongdata.KAIFUTEXT[define.Celebration.Text.OrgIns].content)
    self:SetRankPrizeList()
    if not g_CelebrationCtrl.m_KaifuRankRewardData then
        return
    end
    local oAll = os.date("%m/%d-", g_CelebrationCtrl.m_KaifuRankRewardData.orgcnt.endtime)
    local oMonth = string.gsub(oAll, "/", "月")
    local oDay = string.gsub(oMonth, "-", "日")
    local oHour = tonumber(os.date("%H", g_CelebrationCtrl.m_KaifuRankRewardData.orgcnt.endtime))
    oDay = oDay..oHour.."点"
    local oDescStr = string.gsub(data.huodongdata.KAIFUTEXT[define.Celebration.Text.OrgIns].content, "#time", oDay)
    self.m_PrizeBox.m_DescLbl:SetText(oDescStr)
    self.m_ContentObj:SetActive(true)
    self.m_Hint:SetActive(false)
    if (g_TimeCtrl:GetTimeS() - g_CelebrationCtrl.m_KaifuRankRewardData.orgcnt.endtime) > 0 then
        self.m_ContentObj:SetActive(false)
        self.m_Hint:SetActive(true)
        self.m_Hint:SetText("活动已经结束了哦")
        return
    end
    self:CheckLeftTime()
    self:SetTargetRedPoint()
end

function CCelebrationOrgRankPart.CheckLeftTime(self)
    if not g_CelebrationCtrl.m_KaifuRankRewardData then
        return
    end
    local oLeftTime = g_CelebrationCtrl.m_KaifuRankRewardData.orgcnt.endtime - g_TimeCtrl:GetTimeS()
    if oLeftTime > 0 then
        local oTime = g_CelebrationCtrl:GetLeftTime(oLeftTime)
        self.m_PrizeBox.m_TimeLbl:SetText("剩余时间："..oTime)
    else
        self.m_PrizeBox.m_TimeLbl:SetText("已过期")
    end
end

function CCelebrationOrgRankPart.SetTargetRedPoint(self)
    if g_CelebrationCtrl:GetIsHasOrgCntRedPoint() or g_CelebrationCtrl:GetIsHasOrgLevelRedPoint() then
        self.m_TargetBtn.m_IgnoreCheckEffect = true
        self.m_TargetBtn:AddEffect("RedDot", 22, Vector2(-13, -17))
    else
        self.m_TargetBtn:DelEffect("RedDot")
    end
end

function CCelebrationOrgRankPart.OnClickCheckRank(self)
    CCelebrationRankListView:ShowView(function (oView)
        oView:OnSelectIndex(4)
    end)
end

function CCelebrationOrgRankPart.SetRankPrizeList(self)
    local optionCount = #data.huodongdata.KAIFUCONFIG.kaifu_org.client_rewardlist
    local GridList = self.m_PrizeBox.m_PrizeGrid:GetChildList() or {}
    local oPrizeBox
    if optionCount > 0 then
        for i=1,optionCount do
            if i > #GridList then
                oPrizeBox = self.m_PrizeBox.m_BoxClone:Clone(false)
                -- self.m_PrizeBox.m_PrizeGrid:AddChild(oOptionBtn)
            else
                oPrizeBox = GridList[i]
                oPrizeBox.m_Grid:Clear()
            end
            self:SetRankPrizeBox(oPrizeBox, data.huodongdata.KAIFUCONFIG.kaifu_org.client_rewardlist[i], i)
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
    self.m_PrizeBox.m_PrizeGrid:Reposition()
    self.m_PrizeBox.m_PrizeScrollView:ResetPosition()
end


function CCelebrationOrgRankPart.SetRankPrizeBox(self, oPrizeBox, oData, oIndex)
    oPrizeBox:SetActive(true)

    oPrizeBox.m_RankLbl = oPrizeBox:NewUI(1, CLabel)
    oPrizeBox.m_ScrollView = oPrizeBox:NewUI(2, CScrollView)
    oPrizeBox.m_Grid = oPrizeBox:NewUI(3, CGrid)
    oPrizeBox.m_BoxClone = oPrizeBox:NewUI(4, CBox)
    oPrizeBox.m_BoxClone:SetActive(false)
    oPrizeBox.m_RankBg = oPrizeBox:NewUI(5, CSprite)
    oPrizeBox.m_Rank123Sp = oPrizeBox:NewUI(6, CSprite)

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
        local oLastRankAddOne = data.huodongdata.KAIFUCONFIG.kaifu_org.client_rewardlist[oLastIndex].rank + 1
        if oLastRankAddOne == oData.rank then
            oPrizeBox.m_RankLbl:SetText("第"..oData.rank.."名")
            self:CheckRank123(oPrizeBox, oData.rank)
        else
            oPrizeBox.m_RankLbl:SetText("第"..oLastRankAddOne.."-"..oData.rank.."名")
        end
    end

    self:SetPrizeList(g_GuideHelpCtrl:GetRewardList("KAIFUDIANLI", oData.reward), oPrizeBox)

    self.m_PrizeBox.m_PrizeGrid:AddChild(oPrizeBox)
    self.m_PrizeBox.m_PrizeGrid:Reposition()
end

function CCelebrationOrgRankPart.CheckRank123(self, oPrizeBox, oRank)
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

function CCelebrationOrgRankPart.SetTargetPrizeList(self)
    if not g_CelebrationCtrl.m_KaifuRankRewardData then
        return
    end
    local optionCount = #g_CelebrationCtrl.m_OrgTargetConfigList
    local GridList = self.m_TargetBox.m_PrizeGrid:GetChildList() or {}
    local oTargetBox
    if optionCount > 0 then
        for i=1,optionCount do
            if i > #GridList then
                oTargetBox = self.m_TargetBox.m_BoxClone:Clone(false)
                -- self.m_TargetBox.m_PrizeGrid:AddChild(oOptionBtn)
            else
                oTargetBox = GridList[i]
                oTargetBox.m_Grid:Clear()
            end
            self:SetTargetPrizeBox(oTargetBox, g_CelebrationCtrl.m_OrgTargetConfigList[i])
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
    self.m_TargetBox.m_PrizeGrid:Reposition()
    self.m_TargetBox.m_PrizeScrollView:ResetPosition()
end


function CCelebrationOrgRankPart.SetTargetPrizeBox(self, oTargetBox, oData)
    oTargetBox:SetActive(true)

    oTargetBox.m_RankLbl = oTargetBox:NewUI(1, CLabel)
    oTargetBox.m_FinishBtn = oTargetBox:NewUI(2, CButton)
    oTargetBox.m_FinishMark = oTargetBox:NewUI(3, CSprite)
    oTargetBox.m_ScrollView = oTargetBox:NewUI(4, CScrollView)
    oTargetBox.m_Grid = oTargetBox:NewUI(5, CGrid)
    oTargetBox.m_BoxClone = oTargetBox:NewUI(6, CBox)
    oTargetBox.m_BoxClone:SetActive(false)

    oTargetBox.m_FinishBtn:DelEffect("RedDot")
    oTargetBox.m_FinishBtn.m_IgnoreCheckEffect = true

    if oData.type == 1 then
        local oGradeStr = string.gsub(data.huodongdata.KAIFUTEXT[define.Celebration.Text.OrgCntReward].content, "#amount", oData.config.openday)
        oGradeStr = string.gsub(oGradeStr, "#grade", g_CelebrationCtrl.m_KaifuRankRewardData.orgcnt.orgcnt.."/"..oData.config.count)
        oTargetBox.m_RankLbl:SetText(oGradeStr)
        local oRewardData = g_CelebrationCtrl:GetIsRankRewardExist(g_CelebrationCtrl.m_KaifuRankRewardData.orgcnt.rewarddata, oData.config.count)
        if not oRewardData or (oRewardData and (oRewardData.reward == 0 or oRewardData.reward == 3)) then
            oTargetBox.m_FinishBtn:SetActive(true)
            oTargetBox.m_FinishMark:SetActive(false)
            oTargetBox.m_FinishBtn:GetComponent(classtype.BoxCollider).enabled = false
            oTargetBox.m_FinishBtn:SetBtnGrey(true) 
        elseif oRewardData and  oRewardData.reward == 1 then
            oTargetBox.m_FinishBtn:SetActive(true)
            oTargetBox.m_FinishMark:SetActive(false)
            oTargetBox.m_FinishBtn:GetComponent(classtype.BoxCollider).enabled = true
            oTargetBox.m_FinishBtn:SetBtnGrey(false)
            oTargetBox.m_FinishBtn:AddEffect("RedDot", 22, Vector2(-15, -17))
        elseif oRewardData and oRewardData.reward == 2 then
            oTargetBox.m_FinishBtn:SetActive(false)
            oTargetBox.m_FinishMark:SetActive(true)
        end
    elseif oData.type == 2 then
        local oGradeStr = string.gsub(data.huodongdata.KAIFUTEXT[define.Celebration.Text.OrgLevelReward].content, "#amount", oData.config.openday)
        oGradeStr = string.gsub(oGradeStr, "#grade", oData.config.count)
        oTargetBox.m_RankLbl:SetText(oGradeStr)
        local oRewardData = g_CelebrationCtrl:GetIsRankRewardExist(g_CelebrationCtrl.m_KaifuRankRewardData.orglevel.rewarddata, oData.config.count)
        if not oRewardData or (oRewardData and (oRewardData.reward == 0 or oRewardData.reward == 3)) then
            oTargetBox.m_FinishBtn:SetActive(true)
            oTargetBox.m_FinishMark:SetActive(false)
            oTargetBox.m_FinishBtn:GetComponent(classtype.BoxCollider).enabled = false
            oTargetBox.m_FinishBtn:SetBtnGrey(true) 
        elseif oRewardData and  oRewardData.reward == 1 then
            oTargetBox.m_FinishBtn:SetActive(true)
            oTargetBox.m_FinishMark:SetActive(false)
            oTargetBox.m_FinishBtn:GetComponent(classtype.BoxCollider).enabled = true
            oTargetBox.m_FinishBtn:SetBtnGrey(false)
            oTargetBox.m_FinishBtn:AddEffect("RedDot", 22, Vector2(-15, -17))
        elseif oRewardData and oRewardData.reward == 2 then
            oTargetBox.m_FinishBtn:SetActive(false)
            oTargetBox.m_FinishMark:SetActive(true)
        end
    end

    self:SetPrizeList(g_GuideHelpCtrl:GetRewardList("KAIFUDIANLI", oData.config.reward), oTargetBox)
    oTargetBox.m_FinishBtn:AddUIEvent("click", callback(self, "OnClickGetTargetBoxPrize", oData))

    self.m_TargetBox.m_PrizeGrid:AddChild(oTargetBox)
    self.m_TargetBox.m_PrizeGrid:Reposition()
end

function CCelebrationOrgRankPart.SetPrizeList(self, list, oBox)
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

function CCelebrationOrgRankPart.SetPrizeBox(self, oPrizeItemBox, oData, oBox)
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

function CCelebrationOrgRankPart.OnClickPrizeBox(self, oPrize, oPrizeItemBox, oData)
    local args = {
        widget = oPrizeItemBox,
        side = enum.UIAnchor.Side.Top,
        offset = Vector2.New(0, 0)
    }
    g_WindowTipCtrl:SetWindowItemTip(oPrize.id, args)
end

function CCelebrationOrgRankPart.OnClickShowPart(self, oIndex)
    if oIndex == 1 then
        self.m_PrizeBtn:SetSelected(true)
        self.m_PrizeBox:SetActive(true)
        self.m_TargetBox:SetActive(false)
        self:SetRankPrizeList()
        self:CheckLeftTime()
    elseif oIndex == 2 then
        self.m_TargetBtn:SetSelected(true)
        self.m_PrizeBox:SetActive(false)
        self.m_TargetBox:SetActive(true)
        self:SetTargetPrizeList()
    end
end

function CCelebrationOrgRankPart.OnClickGetTargetBoxPrize(self, oData)
    if oData.type == 1 then
        nethuodong.C2GSKFGetOrgCntReward(oData.config.count)
    elseif oData.type == 2 then
        nethuodong.C2GSKFGetOrgLevelReward(oData.config.count)
    end
end

return CCelebrationOrgRankPart