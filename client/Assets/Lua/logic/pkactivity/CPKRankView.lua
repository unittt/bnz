local CPKRankView = class("CPKRankView", CViewBase)

function CPKRankView.ctor(self, cb)
    CViewBase.ctor(self, "UI/PK/PKRankView.prefab", cb)
    self.m_ExtendClose = "ClickOut"
    self.m_Top3 = {"h7_no1","h7_no2","h7_no3"}
end

function CPKRankView.OnCreateView(self)
    self.m_Grid = self:NewUI(1, CGrid)
    self.m_RankClone = self:NewUI(2, CBox)
    self.m_MyRankBox = self:NewUI(3, CBox)
    self.m_Close = self:NewUI(4, CButton)
    self.m_TipBtn = self:NewUI(5, CButton)
    
    self.m_RankClone:SetActive(false)
    self.m_Close:AddUIEvent("click", callback(self, "OnClose"))
    self.m_TipBtn:AddUIEvent("click", callback(self, "ShowTipView"))

    self:InitMyRankBox()
end

function CPKRankView.InitContent(self,ranklist)
    local myrankinfo = g_PKCtrl.m_MyRankInfo
    local curRank = 0
    local curPoint = -1
    for k,v in ipairs(ranklist) do
        while true do
            if v.point <= 0 then
               break
            end 
            if v.point < curPoint or curPoint == -1 then
                curPoint = v.point
                curRank = curRank + 1
            end
            local rankBox = self:InitRankBox(self.m_RankClone:Clone())
            rankBox.sort:SetText(curRank)
            rankBox.mark:SetText(v.point)
            rankBox.winNum:SetText(v.maxwin)
            rankBox.sort:SetActive(curRank > 3)
            if curRank <= 3 then
               rankBox.top3Spr:SetSpriteName(self.m_Top3[curRank])
            else
               rankBox.top3Spr:SetSpriteName("")
            end
            if v.name == g_AttrCtrl.name then
               rankBox.name:SetText("[A64E00]"..v.name)
            else
               rankBox.name:SetText("[244B4E]"..v.name)
            end
            rankBox.schoolIcon:SetSpriteName(data.schooldata.DATA[v.school].icon)
            self.m_Grid:AddChild(rankBox)
            rankBox:SetActive(true)
            break
        end
    end
    local myrankBox = self.m_MyRankBox
    if myrankinfo.rank > 20 or myrankinfo.rank <= 0 then
        myrankBox.sort:SetText("榜单外")
    else
        if myrankinfo.point <= 0 then
           myrankBox.sort:SetText("暂无排名")
        else
           myrankBox.sort:SetText(myrankinfo.rank)
        end
    end 
    --myrankBox.name:SetText(myrankinfo.name)
    myrankBox.mark:SetText(myrankinfo.point)
    -- myrankBox.winNum:SetText(myrankinfo.maxwin)
    myrankBox.checkbox:SetSelected(g_PKCtrl:IsAutoBuildTeam())
end

function CPKRankView.InitRankBox(self, rankBox)
    rankBox.sort = rankBox:NewUI(1, CLabel)
    rankBox.name = rankBox:NewUI(2, CLabel)
    rankBox.winNum = rankBox:NewUI(3, CLabel)
    rankBox.mark = rankBox:NewUI(4, CLabel)
    rankBox.schoolIcon = rankBox:NewUI(5, CSprite)
    rankBox.top3Spr = rankBox:NewUI(6, CSprite)
    return rankBox
end

function CPKRankView.InitMyRankBox(self)
    local oBox = self.m_MyRankBox
    oBox.sort = oBox:NewUI(1, CLabel)
    oBox.name = oBox:NewUI(2, CLabel)
    oBox.checkbox = oBox:NewUI(3, CWidget)
    oBox.mark = oBox:NewUI(4, CLabel)
    oBox.checkbox:AddUIEvent("click", callback(self, "OnClickCheckBox"))
    return oBox
end

function CPKRankView.OnClickCheckBox(self)
    local flag = 0
    if self.m_MyRankBox.checkbox:GetSelected() then
        flag = 1
    end
    nethuodong.C2GSBWMakeTeam(flag)
end

function CPKRankView.ShowTipView(self)
    local id = define.Instruction.Config.Biwu
    local content = {
        title = data.instructiondata.DESC[id].title,
        desc  = data.instructiondata.DESC[id].desc
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(content)
end

return CPKRankView