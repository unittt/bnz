local CHeroTrialView = class("CHeroTrialView", CViewBase)

function CHeroTrialView.ctor(self, cb)
    CViewBase.ctor(self, "UI/HeroTrial/HeroTrialView.prefab", cb)
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"
end

function CHeroTrialView.OnCreateView(self)
    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_Grid = self:NewUI(2, CGrid)
    self.m_TrailBox = self:NewUI(3, CHeroTrialBox)
    self.m_TipBtn = self:NewUI(4, CButton)
    self.m_ScrollView = self:NewUI(5, CScrollView)
    self.m_Total = 10

    self:InitContent()
end

function CHeroTrialView.InitContent(self)
    self.m_CharBoxList = {}
    self.m_TrailBox:SetActive(false)
    self.m_CloseBtn:AddUIEvent("click", callback(self,"OnClickClose"))
    self.m_TipBtn:AddUIEvent("click", callback(self,"OnClickTipBtn"))
    g_HeroTrialCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CHeroTrialView.CreateBoxes(self)
    for i=1, self.m_Total do
        local oBox = self.m_CharBoxList[i]
        if not oBox then
            oBox = self.m_TrailBox:Clone()
            oBox:SetIdx(i)
            oBox.m_Bg:AddUIEvent("click", callback(self,"OnClickBox", oBox.m_Idx))
            self.m_Grid:AddChild(oBox)
            table.insert(self.m_CharBoxList, oBox)
        end
        oBox:SetActive(true)
    end
end

function CHeroTrialView.SetInfos(self, info, iTime, iTotal)
    local iCurFight
    self.m_Total = iTotal
    self:CreateBoxes()
    for i, v in ipairs(info) do
        v.status = v.status or 0
        if not iCurFight and v.status == 0 then
            iCurFight = i
            v.retTime = iTime
        end
        self.m_CharBoxList[i]:SetInfo(v)
    end
    iCurFight = iCurFight or #info
    self.m_CurFight = iCurFight
    self:SetScrollPos(iCurFight)
    self:OnClickBox(iCurFight)
    local iLength = g_HeroTrialCtrl:GetLength()
    if iLength > 0 and iCurFight > iLength then
        self.m_CharBoxList[iCurFight]:ShowEffect()
    end
    g_HeroTrialCtrl:SetLength(iCurFight)
end

function CHeroTrialView.SetScrollPos(self, idx)
    if idx <= 2 or self.m_Total < 4 then return end
    local curPos = self.m_Grid:GetLocalPos()
    local cellWidth = self.m_Grid:GetCellSize()
    local scrollWidth = self.m_ScrollView:GetSize()
    local minX = curPos.x + scrollWidth - self.m_Total * cellWidth
    local offset = curPos.x - (idx - 2) * cellWidth
    curPos.x = math.max(minX, offset)
    self.m_Grid:SetLocalPos(curPos)
end

function CHeroTrialView.OnClickTipBtn(self)
    local instructionConfig = data.instructiondata.DESC[10031]
    if instructionConfig then
        local zContent = {
            title = instructionConfig.title,
            desc = instructionConfig.desc,
        }
        g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
    end
end

function CHeroTrialView.OnClickClose(self)
    self:CloseView()
end

function CHeroTrialView.OnClickBox(self, idx)
    if not self.m_CurFight or idx > self.m_CurFight or idx == self.m_SelIdx then return end
    if self.m_SelIdx then
        self.m_CharBoxList[self.m_SelIdx]:SetClickState(false)
    end
    self.m_SelIdx = idx
    self.m_CharBoxList[idx]:SetClickState(true)
end

function CHeroTrialView.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.HeroTrial.Event.UpdateTrialUnit then
        local iPos = oCtrl.m_EventData.pos
        local oBox = self.m_CharBoxList[iPos]
        if oBox then
            oBox:SetInfo(oCtrl.m_EventData.info)
        end
    end
end

return CHeroTrialView