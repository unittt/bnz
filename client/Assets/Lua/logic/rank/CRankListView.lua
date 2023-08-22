local CRankListView = class("CRankListView", CViewBase)

function CRankListView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Rank/RankListView.prefab", cb)
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
        [117] = "我的积分：",
        [205] = "人物评分：",
        [206] = "人物评分：",
        [207] = "人物评分：",
        [208] = "人物评分：",
        [209] = "人物评分：",
        [210] = "人物评分：",
        [221] = "我的积分：",
        [222] = "我的耗时：",
        [223] = "我的耗时：",
        [225] = "竞猜胜率：",
    }
    self.m_ScoreType = {[106] = 1,[107] = 2,[108] = 3,[109] = 4}
    self.m_OrgRankType = {116, 204}
    self.m_ExaminationType = {222, 223}
    self.m_IsSwitch = false
    self.m_CurRankTypeIdx = 1
    self.m_SendRecordList = {}
    self.m_GuessType = {225}    --竞猜类型
    self.m_MyGuessLabel = { 
        [225] = "竞猜命中：",
    }
end

function CRankListView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_RankTable = self:NewUI(2, CTable)
    self.m_TypeMenuBoxClone = self:NewUI(3, CRankTypeMenuBox)
    self.m_RankInfo = self:NewUI(4, CRankInfoBox)
    self.m_RankMeinBox = self:NewUI(5, CRankMeinBox)
    self.m_MyInfoBox = self:NewUI(6, CBox)
    self.m_HintText = self:NewUI(7, CLabel) 
    self:InitMyInfoBox()  
    self:InitEvent() 
    self:InitRankTypeList()  
    g_SysUIEffCtrl:DelSysEff("RANK_SYS")
end

function CRankListView.InitMyInfoBox(self)
    self.m_MyLevel = self.m_MyInfoBox:NewUI(1, CLabel)
    self.m_MyRank = self.m_MyInfoBox:NewUI(2, CLabel)
    self.m_DesBtn = self.m_MyInfoBox:NewUI(3, CButton)
    self.m_RankBtn = self.m_MyInfoBox:NewUI(4, CButton) 
    self.m_RefreshTimeLab = self.m_MyInfoBox:NewUI(5, CLabel)
    self.m_MyGuess = self.m_MyInfoBox:NewUI(6, CLabel) 
    self.m_GuessRecordBtn = self.m_MyInfoBox:NewUI(7, CButton)

    self.m_DesBtn:AddUIEvent("click", callback(self, "ShowDesView"))
    self.m_RankBtn:AddUIEvent("click", callback(self, "ShowSwitch"))
    self.m_GuessRecordBtn:AddUIEvent("click", callback(self, "ShowGuessTipView"))
end

function CRankListView.InitRankTypeList(self)
    local dRankType = table.copy(data.rankdata.TYPE)
    --TODO:临时屏蔽活动按钮
    -- for i,v in ipairs(dRankType) do
    --     if v.name == "活动" and v.id == 5 then
    --         for i,id in ipairs(v.subid) do
    --             if id == 117 then
    --                 table.remove(v.subid, i)
    --                 break
    --             end
    --         end
    --     end
    -- end
    
    table.sort(dRankType, function(a,b)
        return a.id < b.id
    end)
    for k,v in pairs(dRankType) do
        local oBox = self.m_TypeMenuBoxClone:Clone(function (subid)
            self:GetRankInfo(subid)
        end)
        if v.is_single == 1 and #v.subid <= 1 then            
            oBox.m_MainMenuBtn:SetActive(false)
            oBox.m_SubMenuBgSpr:SetActive(true)
        end
        oBox.m_MainMenuBtn:SetGroup(self.m_RankTable:GetInstanceID() + 1)
        oBox.m_MainMenuBtn:AddUIEvent("click", callback(self, "OnClickTypeMenuBox", k))
        oBox:SetActive(true)
        oBox.subid = v.subid
        oBox:SetTypeMenu(v,self.m_RankTable:GetInstanceID())
        self.m_RankTable:AddChild(oBox)
    end
    local box = self.m_RankTable:GetChild(1)
    box.m_MainMenuBtn:SetSelected(true)
    box:SelectSubMenu(1)
    box.m_SubMenuBgSpr:SetActive(true)
	box.m_TweenHeight:Play(true)
    self:GetRankInfo(box.subid[1])
    for i=2,table.count(dRankType)  do
        local box = self.m_RankTable:GetChild(i)
        box.m_MainMenuBtn:SetSelected(false)
        box.m_SubMenuBgSpr:SetActive(false)
    end
end

function CRankListView.InitEvent(self)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    g_RankCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnRankCtrlEvent"))
    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrCtrlEvent"))
end

function CRankListView.OnRankCtrlEvent(self, oCtrl)    
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
    if oCtrl.m_EventID == define.Rank.Event.UpdateMeinInfo then
        self.m_RankMeinBox:SetInfo(oCtrl.m_EventData)
    end
end

function CRankListView.OnAttrCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.UpDateScore then
        g_RankCtrl.m_MyRankValue = oCtrl.m_EventData
        self:RefrenshScore(oCtrl.m_EventData) 
    end
end

function CRankListView.OnClickTypeMenuBox(self, idx)
    if idx == self.m_CurRankTypeIdx then return end
    local oBox = self.m_RankTable:GetChild(idx)
    if not oBox then return end
    if self.m_CurRankTypeIdx then
        local oSelBox = self.m_RankTable:GetChild(self.m_CurRankTypeIdx)
        oSelBox.m_TweenHeight:Play(false)
        oSelBox.m_TweenRotation:Play(false)
        oSelBox.m_SubMenuBgSpr:SetActive(false)
    end
    oBox:SelectSubMenu(1)
    oBox:OnClickSubMenu(1)
    self.m_CurRankTypeIdx = idx
end

function CRankListView.GetRankInfo(self,subid)
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
    else
        g_AttrCtrl:C2GSGetScore(self.m_ScoreType[subid])
    end
    self.m_RankData = data.rankdata.INFO[self.m_CurSubid]  
    if self.m_RankData.mien == 1 then 
        g_RankCtrl:C2GSGetRankTop3(subid)
    end
    if not self.m_SendRecordList[self.m_CurSubid][1] then
        g_RankCtrl:C2GSGetRankInfo(self.m_CurSubid, 1)
        self.m_SendRecordList[self.m_CurSubid][1] = true
    end
    self:RefrenshTimeDes()
end

function CRankListView.RefrenshTimeDes(self)
    -- m_CurSubid
    if self.m_CurRankTypeIdx then
        local info = data.rankdata.INFO
        self.m_RefreshTimeLab:SetText(info[self.m_CurSubid].refreshtime)
    else
        self.m_RefreshTimeLab:SetText("")
    end
end


function CRankListView.ShowInfo(self, info)
    --table.print(info,"ShowInfo榜单详情：")
    -- if next(info.grade_rank) == nil then
    --     --self.m_HintText:SetActive(true)
    --     --self.m_RankMeinBox:SetActive(false)
    --     self.m_RankInfo:SetActive(false)
    --     --self.m_RankBtn:SetSpriteName("anniu3")
    --     return
    -- end
    --self.m_RankBtn:SetSpriteName("anniu2")
    self.m_HintText:SetActive(false)
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
        self:ShowRankInfo()
        return
    end 
    
    self.m_RankInfo:InitInfo(self.m_CurSubid, g_RankCtrl.m_RankList[self.m_CurSubid], info.my_rank, info.page,callback(self, "GetUpdateInfo"))  
    if self.m_RankData.mien == 0 then
        self.m_IsSwitch = false
        self:ShowRankInfo()
    elseif self.m_RankMeinBox:GetActive() then 
        self:ShowMienInfo()
    elseif self.m_RankInfo:GetActive() then
        --self.m_RankBtn:SetActive(false)
        self:ShowRankInfo()
    end
    self.m_RankBtn:SetActive(self.m_RankData.mien ~= 0)
end

function CRankListView.GetUpdateInfo(self)
    if not self.m_IsSwitch then
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
end

function CRankListView.ResetScrollView(self)
    self.m_IsSwitch = true
    self.m_RankInfo.m_ScrollView:ResetPosition()
end

function CRankListView.ShowSwitch(self)
    --table.print(self.m_CurInof,"榜单信息：") 
    if self.m_RankMeinBox:GetActive() then 
        self.m_RankInfo.m_ScrollView:ResetPosition()  
        if not g_RankCtrl.m_RankList[self.m_CurSubid] or next(g_RankCtrl.m_RankList[self.m_CurSubid]) == nil then  
            g_NotifyCtrl:FloatMsg("该榜单暂无信息")      
            return
        end 
        self.m_IsSwitch = false      
        self:ShowRankInfo()
    elseif self.m_RankInfo:GetActive() then
        self:ResetScrollView()
        self:ShowMienInfo()
    end
end

function CRankListView.ShowGuessTipView(self)
    --nethuodong.C2GSWorldCupHistory()
    g_SoccerWorldCupGuessHistoryTipCtrl:ShowTipView()
end

--显示排行榜信息
function CRankListView.ShowRankInfo(self) 
    self.m_RankMeinBox:SetActive(false)
    self.m_RankInfo:SetActive(true)
    self.m_RankBtn:SetText("三甲风采") 
end

--显示前3甲风采
function CRankListView.ShowMienInfo(self)
    self.m_RankInfo:SetActive(false)
    self.m_RankMeinBox:SetActive(true)
    self.m_RankBtn:SetText("榜单详情")  
end

function CRankListView.ShowDesView(self)
    local instruction = data.instructiondata.DESC[self.m_RankData.des]
    local zContent = {title = instruction.title, desc = instruction.desc}
    g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

function CRankListView.RefrenshScore(self, score)
    if  g_RankCtrl:IsHideMyInfo(self.m_CurSubid) then
        self.m_MyLevel:SetActive(false)
        self.m_MyRank:SetActive(false)
        self.m_MyGuess:SetActive(false)
        self.m_GuessRecordBtn:SetActive(false)
        self.m_RankBtn:SetActive(false)
        return
    end
    self.m_MyLevel:SetActive(true)
    self.m_MyRank:SetActive(true)
    self.m_MyGuess:SetActive(false)
    self.m_RankBtn:SetActive(true)
    self.m_GuessRecordBtn:SetActive(false)
    local mark = score or g_AttrCtrl.grade
    if table.index(self.m_ExaminationType, self.m_CurSubid) then
        self.m_MyLevel:SetText(self.m_RankType[self.m_CurSubid]..g_TimeCtrl:GetLeftTimeString(mark))
    elseif table.index(self.m_OrgRankType, self.m_CurSubid) then
        if g_AttrCtrl.orgname and g_AttrCtrl.orgname ~= "" then
            self.m_MyLevel:SetText(self.m_RankType[self.m_CurSubid]..g_AttrCtrl.orgname)
        else
            self.m_MyLevel:SetText(self.m_RankType[self.m_CurSubid].."无")
        end
    elseif table.index(self.m_GuessType, self.m_CurSubid) then
        local myrate = 0
        --if g_SoccerWorldCupGuessHistoryTipCtrl.m_MyRankIn == false then
         if g_SoccerWorldCupGuessHistoryTipCtrl.m_MySuccessRate ~= nil then
            myrate = g_SoccerWorldCupGuessHistoryTipCtrl.m_MySuccessRate
        else
            --myrate = g_RankCtrl.m_MySuccessRate
            myrate = 0
        end
        printc("g_SoccerWorldCupGuessHistoryTipCtrl.m_MyRankIn:", g_SoccerWorldCupGuessHistoryTipCtrl.m_MyRankIn)
        printc("2 g_SoccerWorldCupGuessHistoryTipCtrl.m_MySuccessRate:", g_SoccerWorldCupGuessHistoryTipCtrl.m_MySuccessRate, " g_RankCtrl.m_MySuccessRate:", g_RankCtrl.m_MySuccessRate)
        local mycount = 0
        --if g_SoccerWorldCupGuessHistoryTipCtrl.m_MyRankIn == false then
        if g_SoccerWorldCupGuessHistoryTipCtrl.m_MySuccessCount ~= nil then
            mycount = g_SoccerWorldCupGuessHistoryTipCtrl.m_MySuccessCount
        else
            --mycount = g_RankCtrl.m_MySuccessCount
            mycount = 0
        end
        self.m_MyLevel:SetText(self.m_RankType[self.m_CurSubid]..myrate.."%")
        self.m_MyGuess:SetText(self.m_MyGuessLabel[self.m_CurSubid]..mycount)
        self.m_MyGuess:SetActive(true)
        self.m_GuessRecordBtn:SetActive(true)
        self.m_RankBtn:SetActive(false)
    else
        if table.index(g_RankCtrl.m_HideMyRankCid, self.m_CurSubid) then
            self.m_MyLevel:SetText(self.m_RankType[self.m_CurSubid]..g_AttrCtrl.score) 
        else
            self.m_MyLevel:SetText(self.m_RankType[self.m_CurSubid]..mark)
        end
    end
    
end

function CRankListView.CloseView(self)
    CViewBase.CloseView(self)
end

return CRankListView