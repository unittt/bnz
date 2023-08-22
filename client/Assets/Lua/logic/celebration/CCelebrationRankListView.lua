local CCelebrationRankListView = class("CCelebrationRankListView", CViewBase)

function CCelebrationRankListView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Celebration/CelebrationRankListView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
    self.m_GroupName = "main"
    self.m_CurSubid = nil
    self.m_CurInof = nil
    self.m_RankType = { 
        [101] = "我的等级：", 
        [106] = "综合评分：",
        [107] = "人物评分：",
        [108] = "宠物评分：",
        [109] = "魅力：", 
        [115] = "积分：",
        [116] = "我的帮派：",
        [201] = "我的等级：",
        [202] = "综合评分：",
        [203] = "宠物评分：",
        [204] = "我的帮派：",
    }
    self.m_ScoreType = {[106] = 1,[107] = 2,[108] = 3,[109] = 4, [202] = 1, [203] = 3,}
    self.m_OrgRankType = {116, 204}
    self.m_CurRankTypeIdx = nil
    self.m_KaifuTotal = 4
    self.m_SendRecordList = {}
end

function CCelebrationRankListView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_RankInfo = self:NewUI(2, CRankInfoBox)
    self.m_MyInfoBox = self:NewUI(3, CBox)
    self.m_HintText = self:NewUI(4, CLabel)
    self.m_RankTypeScrollView = self:NewUI(5, CScrollView)
    self.m_RankTypeGrid = self:NewUI(6, CGrid)
    self.m_RankTypeCloneBox = self:NewUI(7, CBox)
    self.m_RankTypeCloneBox:SetActive(false)
    
    self:InitMyInfoBox()  
    self:InitEvent() 
    self:SetRankTypeList()

    self.m_HintText:SetActive(true)
    self.m_RankInfo:SetActive(false)
    self.m_MyInfoBox:SetActive(false)
end

function CCelebrationRankListView.InitMyInfoBox(self)
    self.m_MyLevel = self.m_MyInfoBox:NewUI(1, CLabel)
    self.m_MyRank = self.m_MyInfoBox:NewUI(2, CLabel)
    self.m_DesBtn = self.m_MyInfoBox:NewUI(3, CButton)
       
    self.m_DesBtn:AddUIEvent("click", callback(self, "ShowDesView"))
end

function CCelebrationRankListView.SetRankTypeList(self)
    self.m_Index = 900000
    local optionCount = #g_RankCtrl.m_CelebrationRankType
    local GridList = self.m_RankTypeGrid:GetChildList() or {}
    local oRankTypeBox
    if optionCount > 0 then
        for i=1,optionCount do
            if i > #GridList then
                oRankTypeBox = self.m_RankTypeCloneBox:Clone(false)
                -- self.m_RankTypeGrid:AddChild(oOptionBtn)
            else
                oRankTypeBox = GridList[i]
            end
            self.m_Index = self.m_Index + 1
            oRankTypeBox:SetName(tostring(self.m_Index))
            self:SetRankTypeBox(oRankTypeBox, g_RankCtrl.m_CelebrationRankType[i])
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

    self.m_RankTypeGrid:Reposition()
    self.m_RankTypeScrollView:ResetPosition()
end

function CCelebrationRankListView.SetRankTypeBox(self, oRankTypeBox, oData)
    oRankTypeBox:SetActive(true)
    oRankTypeBox.m_NameLbl = oRankTypeBox:NewUI(1, CLabel)
    oRankTypeBox.m_RedPointSp = oRankTypeBox:NewUI(2, CSprite)
    oRankTypeBox.m_ColorNameLbl = oRankTypeBox:NewUI(3, CLabel)
    oRankTypeBox:SetGroup(self.m_RankTypeGrid:GetInstanceID())
    oRankTypeBox.m_RedPointSp:SetActive(false)
    oRankTypeBox.m_NameLbl:SetText( g_CelebrationCtrl:GetViewOpenData(g_RankCtrl.m_CelebrationRankName[oData]).name )
    oRankTypeBox.m_ColorNameLbl:SetText( g_CelebrationCtrl:GetViewOpenData(g_RankCtrl.m_CelebrationRankName[oData]).name )

    oRankTypeBox:AddUIEvent("click", callback(self, "OnClickRankTypeBox", oRankTypeBox, oData))

    self.m_RankTypeGrid:AddChild(oRankTypeBox)
    self.m_RankTypeGrid:Reposition()
end

function CCelebrationRankListView.OnClickRankTypeBox(self, oRankTypeBox, oData)
    if oRankTypeBox then
        oRankTypeBox:SetSelected(true)
    end
    self:GetRankInfo(oData)
end

function CCelebrationRankListView.OnSelectIndex(self, oIndex)
    if oIndex < 1 or oIndex > self.m_KaifuTotal then
        oIndex = 1
    end
    if oIndex == self.m_CurRankTypeIdx then return end
    self.m_CurRankTypeIdx = oIndex

    self:OnClickRankTypeBox(self.m_RankTypeGrid:GetChild(oIndex), g_RankCtrl.m_CelebrationRankType[oIndex])
end

function CCelebrationRankListView.InitEvent(self)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    g_RankCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnRankCtrlEvent"))
    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrCtrlEvent"))
end

function CCelebrationRankListView.OnRankCtrlEvent(self, oCtrl)    
    if oCtrl.m_EventID == define.Rank.Event.UpdateRankInfo then
        --暂时屏蔽
        -- if oCtrl.m_EventData.page > 5 then
        --     --g_NotifyCtrl:FloatMsg("亲,已经到了最后一名了哦!") 
        --     return
        -- end
        if self.m_CurSubid ~= oCtrl.m_EventData.idx then
            return
        end
        self.m_CurInof = oCtrl.m_EventData
        self:ShowInfo(self.m_CurInof)
    end
end

function CCelebrationRankListView.OnAttrCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.UpDateScore then
        g_RankCtrl.m_MyRankValue = oCtrl.m_EventData
        self:RefrenshScore(oCtrl.m_EventData) 
    end
end

function CCelebrationRankListView.GetRankInfo(self,subid)
    if self.m_CurSubid == subid then
        return
    end
    self:ResetScrollView()
    self.m_CurSubid = subid
    self.m_SendRecordList[self.m_CurSubid] = {}
    g_RankCtrl.m_MyRankValue = -1
    if subid == 101 then
        g_RankCtrl.m_MyRankValue = g_AttrCtrl.grade
        self:RefrenshScore()
    elseif subid == 201 then
        g_RankCtrl.m_MyRankValue = g_AttrCtrl.grade
        self:RefrenshScore()
    elseif table.index(self.m_OrgRankType, self.m_CurSubid) then
        self:RefrenshScore()
    else
        g_AttrCtrl:C2GSGetScore(self.m_ScoreType[subid])
    end
    self.m_RankData = data.rankdata.INFO[self.m_CurSubid]  
    -- if self.m_RankData.mien == 1 then 
    --     g_RankCtrl:C2GSGetRankTop3(subid)
    -- end
    if not self.m_SendRecordList[self.m_CurSubid][1] then
        g_RankCtrl:C2GSGetRankInfo(self.m_CurSubid, 1)
        self.m_SendRecordList[self.m_CurSubid][1] = true
    end
end

function CCelebrationRankListView.ShowInfo(self, info)
    -- if not g_RankCtrl.m_RankList or not g_RankCtrl.m_RankList[self.m_CurSubid] or not next(g_RankCtrl.m_RankList[self.m_CurSubid]) then
    --     self.m_HintText:SetActive(true)
    --     self.m_RankInfo:SetActive(false)
    --     self.m_MyInfoBox:SetActive(false)
    -- else
    -- end

    self.m_HintText:SetActive(false)
    self.m_RankInfo:SetActive(true)
    self.m_MyInfoBox:SetActive(true)
    local rank = g_RankCtrl.m_MyRank
    if rank > data.rankdata.INFO[self.m_CurSubid].count or rank == 0 then 
        self.m_MyRank:SetText("我的名次:榜外")
    else
        self.m_MyRank:SetText("我的名次:"..rank)
    end
    if g_RankCtrl.m_MyRankValue and g_RankCtrl.m_MyRankValue >= 0 then
        self:RefrenshScore(g_RankCtrl.m_MyRankValue)
    end
    if info.page > 1 then 
        self.m_RankInfo:AddItemInfo(g_RankCtrl.m_RankList[self.m_CurSubid], info.page,info.idx)
        return
    end 
    
    -- printc("红红火火哈哈哈哈哈哈")
    -- table.print(g_RankCtrl.m_RankList, "哦哦哦哦哦哦哦")
    self.m_RankInfo:InitInfo(self.m_CurSubid, g_RankCtrl.m_RankList[self.m_CurSubid], info.my_rank, info.page,callback(self, "GetUpdateInfo"))
end

function CCelebrationRankListView.GetUpdateInfo(self)
    if self.m_CurSubid ~= self.m_CurInof.idx then
        return
    end
    local oPage = self.m_CurInof.page + 1
    if oPage <= g_RankCtrl.m_RankTotalPage then
        if not self.m_SendRecordList[self.m_CurSubid][oPage] then
            g_RankCtrl:C2GSGetRankInfo(self.m_CurSubid, oPage)
            self.m_SendRecordList[self.m_CurSubid][oPage] = true
        end
    end
end

function CCelebrationRankListView.ResetScrollView(self)
    self.m_RankInfo.m_ScrollView:ResetPosition()
end

function CCelebrationRankListView.ShowDesView(self)
    local zContent = {title = self.m_RankData.name, desc = data.instructiondata.DESC[self.m_RankData.des].desc}
    g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

function CCelebrationRankListView.RefrenshScore(self,score)
    local mark = score or g_AttrCtrl.grade
    if table.index(self.m_OrgRankType, self.m_CurSubid) then
        if g_AttrCtrl.orgname and g_AttrCtrl.orgname ~= "" then
            self.m_MyLevel:SetText(self.m_RankType[self.m_CurSubid]..g_AttrCtrl.orgname)
        else
            self.m_MyLevel:SetText(self.m_RankType[self.m_CurSubid].."无")
        end
    else
        self.m_MyLevel:SetText(self.m_RankType[self.m_CurSubid]..mark)
    end
end

return CCelebrationRankListView