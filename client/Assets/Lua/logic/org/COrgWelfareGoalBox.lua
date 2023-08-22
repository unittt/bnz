local COrgWelfareGoalBox = class("COrgWelfareItemBox", CBox)

function COrgWelfareGoalBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_CurRighInfo = {}
    self.m_CurGetInfo  = {}
    self.m_LeftItemGrid = self:NewUI(1, CGrid)
    self.m_LeftItem = self:NewUI(2, CBox)
    self.m_RightItemGrid = self:NewUI(3, CGrid)
    self.m_RightItem = self:NewUI(4, CBox)
    self.m_CloseBtn = self:NewUI(5, CButton)
    self.m_ScrollView = self:NewUI(6, CScrollView)

    self.m_CurLeftItem = nil

    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgEvent"))
end

function COrgWelfareGoalBox.InitContent(self, info)
    self.m_CurGetInfo = {}
    for k,v in pairs(info) do
        self.m_CurGetInfo[v.achid] = v
    end
    self.m_LeftItemGrid:Clear()
    for k,v in pairs(data.orgdata.GOAL) do
        local leftItem = self.m_LeftItem:Clone()
        leftItem:SetActive(true)
        leftItem.icon = leftItem:NewUI(1, CSprite)      
        leftItem.name = leftItem:NewUI(2, CLabel)
        leftItem.selname = leftItem:NewUI(3, CLabel)
        leftItem.icon:SetActive(true)
        leftItem.icon:SetSpriteName("h7_quanbudacheng")
        leftItem.tag_name = k  
        leftItem:AddUIEvent("click", callback(self, "OnSelectType", leftItem , v))
        leftItem:SetGroup(self.m_LeftItemGrid:GetInstanceID()) 
        local bIsAllDone = true
        local bShowRedPoit = false
        for j,c in pairs(v) do
            local dInfo = self.m_CurGetInfo[c.id]
            if dInfo == nil or dInfo.ach_status == 0 and bIsAllDone then
                bIsAllDone = false
                leftItem.icon:SetSpriteName("h7_xiang_1")  
            end
            if not bShowRedPoit and dInfo and dInfo.ach_status == 1 then
                bShowRedPoit = true
                leftItem:AddEffect("RedDot", 20, Vector2(-15, -19))
            end
        end
        leftItem.name:SetText(k)
        leftItem.selname:SetText(k)
        self.m_LeftItemGrid:AddChild(leftItem)
    end
    local item = self.m_LeftItemGrid:GetChild(1)
    item:SetSelected(true)
    self:UpdateRightInfo(data.orgdata.GOAL[item.tag_name])
    self.m_CurRighInfo = data.orgdata.GOAL[item.tag_name]    
end

function COrgWelfareGoalBox.OnOrgEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Org.Event.UpdateAchieveInfo then
        self.m_CurGetInfo[oCtrl.m_EventData.achid] = oCtrl.m_EventData       
        self:UpdateRightInfo(self.m_CurRighInfo)
    end
end

function COrgWelfareGoalBox.UpdateRightInfo(self, info)
    local i = 1
    local iRedPoindCnt = 0
    for k,v in ipairs(info) do
        local rightItem = self.m_RightItemGrid:GetChild(i)
        if rightItem == nil then
            rightItem = self:AddRihtItem()
        end
        rightItem:SetActive(true)
        rightItem:SetColor(Color.white) 
        rightItem.icon:SetSpriteName(tostring(v.reward_icon))
        rightItem.icon:AddUIEvent("click", callback(self, "OnShowItemTips", v.reward, rightItem.icon))
        local desc = v.desc
        local process = 0
        if self.m_CurGetInfo[v.id] == nil then
            rightItem.done:SetActive(false)
            rightItem.getbtn:SetActive(true)
            rightItem.geted:SetActive(false)
            rightItem.getbtn:SetGrey(true)
            process = 0
        else
            local bShowRedPoint = false
            if self.m_CurGetInfo[v.id].ach_status == 2 then
                rightItem.icon:SetSpriteName(tostring(v.open_icon))
                rightItem:SetColor(Color.RGBAToColor("CECECEFF")) 
                rightItem.getbtn:SetActive(false)
                rightItem.geted:SetActive(true)
            else
                rightItem.getbtn:SetActive(true)
                rightItem.getbtn:SetGrey(false)
                rightItem.geted:SetActive(false)
                bShowRedPoint = true
            end
            if self.m_CurGetInfo[v.id].ach_status == 0 then
                rightItem.done:SetActive(false)
                rightItem.getbtn:SetGrey(true)
                bShowRedPoint = false
            else
                rightItem.done:SetActive(true)
            end
            if bShowRedPoint then
                iRedPoindCnt = iRedPoindCnt + 1
                rightItem.getbtn:AddEffect("RedDot", 20, Vector2(-15, -19))
            else
                rightItem.getbtn:DelEffect("RedDot")
            end
            process = self.m_CurGetInfo[v.id].process
        end
        if v.type == 6 then
            desc = string.gsub(desc, "V", process) 
        end
        rightItem.title:SetText(desc)
        rightItem.condition:SetText(v.des)
        rightItem.getbtn:AddUIEvent("click", callback(self,"OnGetAward", v))
        i = i+1
    end
    if self.m_CurLeftItem then
        if iRedPoindCnt > 0 then
            self.m_CurLeftItem:AddEffect("RedDot", 20, Vector2(-15, -19))
        else
            self.m_CurLeftItem:DelEffect("RedDot")
        end
    end
    for j = i, self.m_RightItemGrid:GetCount() do
        self.m_RightItemGrid:GetChild(j):SetActive(false)
    end
end

function COrgWelfareGoalBox.AddRihtItem(self)
    local rightItem = self.m_RightItem:Clone()
    rightItem:SetActive(true)
    rightItem.icon = rightItem:NewUI(1, CButton)
    rightItem.title = rightItem:NewUI(2, CLabel)
    rightItem.done = rightItem:NewUI(3, CSprite)
    rightItem.getbtn = rightItem:NewUI(4, CButton)
    rightItem.geted = rightItem:NewUI(5, CSprite)
    rightItem.condition = rightItem:NewUI(6, CLabel)
    self.m_RightItemGrid:AddChild(rightItem)
    return rightItem
end

function COrgWelfareGoalBox.OnSelectType(self, oItem, v)
    self.m_CurLeftItem = oItem
    self.m_CurRighInfo = v
    self:UpdateRightInfo(v)
    self.m_ScrollView:ResetPosition()
end

function COrgWelfareGoalBox.OnGetAward(self, v)
    if self.m_CurGetInfo[v.id] == nil or self.m_CurGetInfo[v.id].ach_status == 0 then
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1103].content)
        return
    end
    if g_OrgCtrl.m_Org.info.hisoffer < v.receive_offer then
        g_NotifyCtrl:FloatMsg(string.gsub(data.orgdata.TEXT[1105].content,"#orgoffer", v.receive_offer))
        return
    end
    if g_AttrCtrl.grade < v.receive_lv then
        g_NotifyCtrl:FloatMsg(string.gsub(data.orgdata.TEXT[1011].content, "#grade", v.receive_lv))
        return
    end
    netorg.C2GSReceiveAchieve(v.id)
end

function COrgWelfareGoalBox.OnShowItemTips(self, info, icon)
    COrgWelfareItemTipsView:ShowView(function (oView)
        oView:InitContent(info, icon)
    end)
end

function COrgWelfareGoalBox.OnClose(self)
    self:SetActive(false)
    local view = COrgInfoView:GetView()
    if view then
        view:ShowRPanel()
        view.m_WelfarePart.m_ItemGrid:SetActive(true) 
    end    
end

return COrgWelfareGoalBox