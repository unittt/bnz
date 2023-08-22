local CPKPrepareView = class("CPKPrepareView", CViewBase)

function CPKPrepareView.ctor(self, cb)
    CViewBase.ctor(self, "UI/PK/PKPrepareView.prefab", cb)
    self.m_ExtendClose = "Shelter"
end

function CPKPrepareView.OnCreateView(self)
    self.m_LeftGrid = self:NewUI(1, CGrid)  --己方队员信息
    self.m_PlayerBox = self:NewUI(2, CBox)  --队员信息克隆体
    self.m_RightGrid = self:NewUI(3, CGrid)   --对方队员信息
    self.m_CountTime = self:NewUI(5, CLabel)  --准备倒计时
    
    self.m_PlayerBox:SetActive(false)
end

--刷新双方信息
function CPKPrepareView.InitContent(self, matchlist1, matchlist2)
    --self:ShowCountTime()
    local tSchoolData = data.schooldata.DATA
    local myTeam = nil
    local otherTeam = nil
    if self:GetMyTeamByname(matchlist1) then
       myTeam = matchlist1
       otherTeam = matchlist2
    elseif self:GetMyTeamByname(matchlist2) then
       myTeam = matchlist2
       otherTeam = matchlist1
    end 
    for k,v in pairs(myTeam) do
        local playerBox = self:InitPlayerBox(self.m_PlayerBox:Clone())
        playerBox.icon:SetSpriteName(v.icon)
        playerBox.lv:SetText(v.grade) 
        playerBox.name:SetText(v.name)
        playerBox.mark:SetText(v.score)
        playerBox.schoolIcon:SetSpriteName(tostring(tSchoolData[v.school].icon))
        self.m_LeftGrid:AddChild(playerBox)
        playerBox:SetActive(true)
    end
    for k,v in pairs(otherTeam) do
        local playerBox = self:InitPlayerBox(self.m_PlayerBox:Clone())
        playerBox.icon:SetSpriteName(v.icon)
        playerBox.lv:SetText(v.grade.."级") 
        playerBox.name:SetText(v.name)
        playerBox.mark:SetText(v.score)
        playerBox.schoolIcon:SetSpriteName(tostring(tSchoolData[v.school].icon))
        self.m_RightGrid:AddChild(playerBox)
        playerBox:SetActive(true)
    end
end

--初始化队员信息
function CPKPrepareView.InitPlayerBox(self, playerBox)
    playerBox.icon = playerBox:NewUI(1, CSprite)
    playerBox.lv = playerBox:NewUI(2, CLabel)
    playerBox.name = playerBox:NewUI(3, CLabel)
    playerBox.mark = playerBox:NewUI(4, CLabel)
    playerBox.schoolIcon = playerBox:NewUI(5, CSprite)
    return playerBox
end

--开启倒计时
function CPKPrepareView.ShowCountTime(self, time)
    -- local time = 3
    Utils.AddTimer(function()
        if Utils.IsExist(self) then
           self.m_CountTime:SetText(time)
        else
           return false
        end
        if time <= 0 then
           return false
        end
        time = time - 1
        return true
    end,1,0)
end

function CPKPrepareView.GetMyTeamByname(self,teamlist)
    for k,v in pairs(teamlist) do
        if v.name == g_AttrCtrl.name then
           return true
        end
    end
end

return CPKPrepareView