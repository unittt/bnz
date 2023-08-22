local CJieBaiTeamMemberItem = class("CJieBaiTeamMemberItem", CBox)

function CJieBaiTeamMemberItem.ctor(self, obj)

	CBox.ctor(self, obj)
    self.m_Icon = self:NewUI(1, CSprite)
    self.m_Flag = self:NewUI(2, CSprite)
    self.m_Lv = self:NewUI(3, CLabel)
    self.m_Name = self:NewUI(4, CLabel)
    self.m_SchoolSprite = self:NewUI(5, CSprite)
    self.m_TitleMingHao = self:NewUI(6, CLabel)
    self.m_ModifyMingHao = self:NewUI(7, CSprite)

    self:InitContent()

end

function CJieBaiTeamMemberItem.InitContent(self)

    self.m_ModifyMingHao:AddUIEvent("click", callback(self, "OnClickMingHao"))

end

function CJieBaiTeamMemberItem.SetInfo(self, info)
    
    local icon = info.icon
    local name = info.name
    local lv = info.lv
    local titleMingHao = info.titleMingHao
    local school = info.school

    self.m_Info = info
    self.m_Pid = info.pid
    self.m_Icon:SpriteAvatar(icon)
    self.m_Name:SetText(name)
    self.m_Lv:SetText(lv)
    self.m_TitleMingHao:SetText(titleMingHao or "")
    
    self.m_SchoolSprite:SpriteSchool(school)

    local sponsorPid = g_JieBaiCtrl:GetSponsorInfo().pid

    local flagName = nil
    if sponsorPid == info.pid then 
    	flagName = "h7_laoda"
    elseif g_AttrCtrl.pid == info.pid then 
    	flagName = "h7_ziji"
    end  
    if flagName then 
    	self.m_Flag:SetSpriteName(flagName)
    	self.m_Flag:SetActive(true)
   	else
   		self.m_Flag:SetActive(false)
   	end 

   	self.m_ModifyMingHao:SetActive(g_AttrCtrl.pid == info.pid)

end

function CJieBaiTeamMemberItem.OnClickMingHao(self)

	CJieBaiTeamSetNameView:ShowView()

end


return CJieBaiTeamMemberItem