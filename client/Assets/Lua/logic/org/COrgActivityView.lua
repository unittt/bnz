local COrgActivityView = class("COrgActivityView", CViewBase)

function COrgActivityView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Org/OrgActivityView.prefab", cb)
    -- self.m_DepthType = "Dialog"
    -- self.m_GroupName = "sub"
    -- self.m_ExtendClose = "Black"
end

function COrgActivityView.OnCreateView(self)
    self.m_BuildTexture = self:NewUI(1, CTexture)
    self.m_BuildNameL = self:NewUI(2, CLabel)
    self.m_BuildGradeL = self:NewUI(3, CLabel)
    self.m_DesL = self:NewUI(4, CLabel)
    self.m_BgSpr = self:NewUI(5, CSprite)
    self.m_BottomNode = self:NewUI(6, CObject)
    self.m_ActivityGrid = self:NewUI(7, CGrid)
    self.m_ActivityBoxClone = self:NewUI(8, CBox)

    self:InitContent()
end

function COrgActivityView.InitContent(self)
    self.m_ActivityBoxClone:SetActive(false)

    netorg.C2GSClickOrgBuild(104)
    g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
    g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
    g_OrgMatchCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlOrgMatchEvent"))

    self:InitBuildInfo()
end

function COrgActivityView.InitBuildInfo(self)
    self.m_BuildInfo = g_OrgCtrl:GetBuildInfo(104)
    self:RefreshBaseInfo(self.m_BuildInfo)
end

function COrgActivityView.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Org.Event.GetActivityInfo then
        self:RefreshActivityGrid(oCtrl.m_EventData)
    end
end

function COrgActivityView.OnCtrlOrgMatchEvent(self, oCtrl)
    if oCtrl.m_EventID == define.OrgMatch.Event.RefreshOrgMatchList then
        local iCnt = #g_OrgMatchCtrl:GetOrgMatchList()
        if not COrgMatchListView:GetView() and iCnt > 0 then
            COrgMatchListView:ShowView()
            self:CloseView()
        end
    end
end

function COrgActivityView.RefreshAll(self)
    self:RefreshActivityGrid()
end

function COrgActivityView.RefreshBaseInfo(self, buildInfo)
     local info = data.orgdata.BUILDLEVEL[buildInfo.bid][buildInfo.level]
    if info == nil then 
        info = data.orgdata.BUILDLEVEL[buildInfo.bid][1]
    end 
    self.m_BuildTexture:SetChangeMainTexture("Org", info.texture)
    self.m_BuildNameL:SetText(info.name)
    self.m_BuildGradeL:SetText(buildInfo.level.."/"..#data.orgdata.BUILDLEVEL[buildInfo.bid])
    self.m_DesL:SetText(info.updes)
end

function COrgActivityView.RefreshActivityGrid(self, lActivity)
    self.m_ActivityGrid:Clear()
    for i,dInfo in ipairs(lActivity) do
        local oBox = self:CreateActivityBox()
        self:UpdateActivityBox(oBox, dInfo)
        self.m_ActivityGrid:AddChild(oBox)
    end

    self:ResetBg()
    self.m_ActivityGrid:Reposition()
end

function COrgActivityView.CreateActivityBox(self)
    local oBox = self.m_ActivityBoxClone:Clone()
    oBox.m_TimeL = oBox:NewUI(1, CLabel)
    oBox.m_ExtraL = oBox:NewUI(2, CLabel)
    oBox.m_NameL = oBox:NewUI(3, CLabel)
    oBox.m_BgTexture = oBox:NewUI(4, CTexture)
    oBox.m_CheckBtn = oBox:NewUI(5, CButton)

    oBox.m_CheckBtn:AddUIEvent("click", callback(self, "OnClickCheck", oBox))
    oBox:SetActive(true)
    return oBox
end

function COrgActivityView.UpdateActivityBox(self, oBox, dInfo)
    local tActivity = data.orgdata.ACTIVITY[dInfo.active_id]
    local tSchedule = data.scheduledata.SCHEDULE[dInfo.active_id]

    oBox.m_ActivityId = dInfo.active_id
    oBox.m_TimeL:SetText(tSchedule.activetime)
    oBox.m_ExtraL:SetText(dInfo.extra_msg)
    -- oBox.m_BgTexture:SetChangeMainTexture("Org", tActivity.bg)
    oBox.m_NameL:SetText(tActivity.name)
end

function COrgActivityView.ResetBg(self)
    local w,h = self.m_BgSpr:GetSize()
    local _,cellH = self.m_ActivityGrid:GetCellSize()
    local h = self.m_ActivityGrid:GetCount()*cellH + h
    self.m_BgSpr:SetSize(w, h)
end

function COrgActivityView.OnClickCheck(self, oBox)
    --帮派竞赛
    if oBox.m_ActivityId == 1025 then
        -- COrgMatchListView:ShowView()
        nethuodong.C2GSOrgWarOpenMatchList(2)
    end 
end

return COrgActivityView 