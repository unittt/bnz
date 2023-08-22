local COrgWelfarePart = class("COrgWelfarePart", CPageBase)

function COrgWelfarePart.ctor(self, cb)
    CPageBase.ctor(self, cb)
end

function COrgWelfarePart.OnInitPage(self)
    self.m_ItemGrid = self:NewUI(1, CGrid)
    self.m_ItemClone = self:NewUI(2, COrgWelfareItemBox)
    self.m_GoalBox = self:NewUI(7, COrgWelfareGoalBox)
end

function COrgWelfarePart.InitContent(self, info)
    self.m_GoalBox:SetActive(false)
    local i = 1
    for k,v in pairs(data.orgdata.WELFARE) do
        local oCondition = k ~= 1003 or info.pos_status == 1 or (k == 1003 and g_OrgCtrl.m_Org.info.position <= 3)
        --处理红包关闭
        if k == 1006 and not g_OpenSysCtrl:GetOpenSysState(define.System.RedPacket) then
            oCondition = false
        end
        if oCondition then
            local item = self.m_ItemGrid:GetChild(i)
            if item == nil then
                item = self.m_ItemClone:Clone()
                item:SetGroup(self.m_ItemGrid:GetInstanceID()) 
                self.m_ItemGrid:AddChild(item)
            end
            item:SetActive(true)
            if gameconfig.Issue.Shiedle and v.id == 1004 then
               item:SetActive(false)
            end
            item:InitContent(v, info)  
            i = i + 1      
        end        
    end
    self.m_ItemGrid:Reposition()
end

function COrgWelfarePart.ShowGoalBox(self, info)
     self.m_GoalBox:SetActive(true)
     self.m_ItemGrid:SetActive(false)
     self.m_GoalBox:InitContent(info)
end


return COrgWelfarePart