local CRespondOrgItem = class("CRespondOrgItem", CBox)

function CRespondOrgItem.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_ItemBG             = self:NewUI(1, CSprite)
    self.m_HasRespondSprite   = self:NewUI(2, CSprite)
    self.m_IDLabel            = self:NewUI(3, CLabel)
    self.m_OrgNameLabel       = self:NewUI(4, CLabel)
    self.m_LeaderSchoolSprite = self:NewUI(5, CSprite)
    self.m_LeaderNameLabel    = self:NewUI(6, CLabel)
    self.m_RespondNumLabel    = self:NewUI(7, CLabel)
    self.m_LeaderGradeLabel   = self:NewUI(8, CLabel)
    self.m_RespondOrgid = nil
    self.m_LeaderId = nil
    self.m_NameColor = {
        friend = "a64e00",
        other = "244B4E"
    }
    self:InitContent()
end

function CRespondOrgItem.InitContent(self)
    self.m_ItemBG:AddUIEvent("click", callback(self, "ItemCallBack"))
    self.m_LeaderNameLabel:AddUIEvent("click", callback(self, "OnClickedLeaderNameLabel"))
end

function CRespondOrgItem.SetCallback(self, cb)
    self.m_CallBack = cb
end

function CRespondOrgItem.SetGroup(self, groupId)
    self.m_ItemBG:SetGroup(groupId)
end

function CRespondOrgItem.SetBoxInfo(self, respondOrg, itemCount)
    if respondOrg == nil then
        return
    end

    self.m_RespondOrgid = respondOrg.orgid
    self.m_LeaderId = respondOrg.leaderid

    -- BG
    if itemCount % 2  == 1 then  -- 奇数
        self.m_ItemBG:SetSpriteName("h7_di_3")
    else    -- 偶数
        self.m_ItemBG:SetSpriteName("h7_di_4")
    end 

    -- 响应 ./（默认没响应）
    if respondOrg.hasrespond == g_OrgCtrl.HAS_RESPOND_ORG then
        self.m_HasRespondSprite:SetActive(true)
    else
        self.m_HasRespondSprite:SetActive(false)
    end

    -- ID
    self.m_IDLabel:SetText(respondOrg.showid)

    -- 名称
    self.m_OrgNameLabel:SetText(respondOrg.name)

    -- 帮主门派头像
    self.m_LeaderSchoolSprite:SpriteSchool(tonumber(respondOrg.school))
    
    -- 帮主名字
    self.m_LeaderNameLabel:SetText(respondOrg.leadername)
    self:RefreshNameColor()
    -- if respondOrg.isfriend == COrgCtrl.LEADER_IS_MY_FRIEND then
    --     self.m_LeaderNameLabel:SetColor(Color.turquoise)
    -- else
    --     self.m_LeaderNameLabel:SetColor(Color.brown)
    -- end

    -- 响应人数
    local maxRespondNum = data.orgdata.OTHERS[1].create_respond_people
    self.m_RespondNumLabel:SetText(respondOrg.respondcnt .. "/" .. maxRespondNum)

    --TODO
    self.m_LeaderGradeLabel:SetText("0")
end

function CRespondOrgItem.RefreshNameColor(self)
    local bIsFriend = g_FriendCtrl:IsMyFriend(self.m_LeaderId)
    local color = Color.RGBAToColor(bIsFriend and self.m_NameColor.friend or self.m_NameColor.other)
    self.m_LeaderNameLabel:SetColor(color)
end

function CRespondOrgItem.UpdateResponded(self)
    local org = g_OrgCtrl:GetRespondOrgById(self.m_RespondOrgid)
    if org.hasrespond == g_OrgCtrl.HAS_RESPOND_ORG then
        self.m_HasRespondSprite:SetActive(true)
    else
        self.m_HasRespondSprite:SetActive(false)
    end
    local maxRespondNum = data.orgdata.OTHERS[1].create_respond_people
    self.m_RespondNumLabel:SetText(org.respondcnt .. "/" .. maxRespondNum)
end

function CRespondOrgItem.ItemCallBack(self)
    -- printc("响应帮派界面，点击 item")
    if self.m_CallBack then
        self.m_CallBack()
    end
end

function CRespondOrgItem.OnClickedLeaderNameLabel(self)
    -- printc("响应帮派界面，点击帮主名字")
    netplayer.C2GSGetPlayerInfo(self.m_LeaderId)
end

function CRespondOrgItem.SetSelected(self)
    self.m_ItemBG:SetSelected(true)
end

return CRespondOrgItem