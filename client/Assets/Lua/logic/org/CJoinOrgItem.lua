local CJoinOrgItem = class("CJoinOrgItem", CBox)

function CJoinOrgItem.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_HasApplySprite     = self:NewUI(1, CSprite)
    self.m_IdLabel            = self:NewUI(2, CLabel)
    self.m_OrgNameLabel       = self:NewUI(3, CLabel)
    self.m_LevelLabel         = self:NewUI(4, CLabel)
    self.m_NumPeopleLabel     = self:NewUI(5, CLabel)
    self.m_LeaderSchoolSprite = self:NewUI(6, CSprite)
    self.m_LeaderNameLabel    = self:NewUI(7, CLabel)
    self.m_ItemBG             = self:NewUI(8, CSprite)

    self.m_CallBack = nil
    self.m_Orgid = nil
    self.m_LeaderID = nil

    self.m_NameColor = {
        friend = "a64e00",
        other = "244B4E"
    }
    self:InitContent()
end

function CJoinOrgItem.InitContent(self)
    self.m_ItemBG:AddUIEvent("click", callback(self, "ItemCallBack"))
    self.m_LeaderNameLabel:AddUIEvent("click", callback(self, "OnClickedLeaderNameLabel"))
end

function CJoinOrgItem.SetCallback(self, cb)
    self.m_CallBack = cb
end

function CJoinOrgItem.SetGroup(self, groupId)
    self.m_ItemBG:SetGroup(groupId)
end

function CJoinOrgItem.SetBoxInfo(self, org, idx)
    if org == nil then
        return
    end
    self.m_Orgid = org.orgid
    self.m_LeaderID = org.leaderid
    -- BG
    if idx % 2  == 1 then  -- 奇数
        self.m_ItemBG:SetSpriteName("h7_di_3")
    else    -- 偶数
        self.m_ItemBG:SetSpriteName("h7_di_4")
    end 
    -- 申请 ./（默认没申请）
    if org.hasapply == g_OrgCtrl.HAS_APPLY_ORG then
        self.m_HasApplySprite:SetActive(true)
    else
        self.m_HasApplySprite:SetActive(false)
    end
    -- ID
    self.m_IdLabel:SetText(org.showid)
    -- 名称
    self.m_OrgNameLabel:SetText(org.name)
    -- 等级
    self.m_LevelLabel:SetText(org.level)
    -- 人数
    --local maxNum = data.orgdata.POSITIONLIMIT[org.level].formal
    self.m_NumPeopleLabel:SetText(org.memcnt .. "/" .. org.maxcnt)
    -- 帮主头像
    self.m_LeaderSchoolSprite:SpriteSchool(tonumber(org.leaderschool))
    -- 帮主名字
    self.m_LeaderNameLabel:SetText(org.leadername)
    -- if org.isfriend == COrgCtrl.LEADER_IS_MY_FRIEND then
    --     self.m_LeaderNameLabel:SetColor(Color.turquoise)
    -- else
    --     self.m_LeaderNameLabel:SetColor(Color.brown)
    -- end
    self:RefreshNameColor()
end

function CJoinOrgItem.RefreshNameColor(self)
    local bIsFriend = g_FriendCtrl:IsMyFriend(self.m_LeaderID)
    local color = Color.RGBAToColor(bIsFriend and self.m_NameColor.friend or self.m_NameColor.other)
    self.m_LeaderNameLabel:SetColor(color)
end

function CJoinOrgItem.UpdateApplied(self)  -- 1 申请入帮，0 取消申请
    local org = g_OrgCtrl:GetOrgById(self.m_Orgid)
    if org.hasapply == g_OrgCtrl.HAS_APPLY_ORG then
        self.m_HasApplySprite:SetActive(true)
    else
        self.m_HasApplySprite:SetActive(false)
    end    
end

function CJoinOrgItem.ItemCallBack(self)
    -- printc("加入帮派界面，点击 item, self.m_CallBack = " .. tostring(self.m_CallBack))
    if self.m_CallBack then
        self.m_CallBack()
    end
end

function CJoinOrgItem.SetSelected(self)
    self.m_ItemBG:SetSelected(true)
end

function CJoinOrgItem.OnClickedLeaderNameLabel(self)
    netplayer.C2GSGetPlayerInfo(self.m_LeaderID)
end

return CJoinOrgItem