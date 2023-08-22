local CJieBaiInvitedItemList = class("CJieBaiInvitedItemList", CBox)

function CJieBaiInvitedItemList.ctor(self, obj)

	CBox.ctor(self, obj)
    self.m_Grid = self:NewUI(1, CGrid)
    self.m_Item = self:NewUI(2, CBox)

    self:InitContent()

end

function CJieBaiInvitedItemList.InitContent(self)
    
    self.m_PidList = g_JieBaiCtrl:GetSponsorInviterIdList()
    self:RefreshItems()

end

function CJieBaiInvitedItemList.RefreshItems(self)
    
    self.m_Grid:HideAllChilds()
    for k, pid in ipairs(self.m_PidList) do 
        local item = self.m_Grid:GetChild(k)
        if item == nil then
            item = self.m_Item:Clone() 
            item:SetActive(true)
            self.m_Grid:AddChild(item)  
        end
        item:SetActive(true)
        item.icon = item:NewUI(1, CSprite)
        item.name = item:NewUI(2, CLabel)
        item.minghao = item:NewUI(3, CLabel)
        local info = g_JieBaiCtrl:GetInvitedInfoByPid(pid)
        if not info then 
            info = g_JieBaiCtrl:GetSponsorInfo()
        end
        item.icon:SpriteAvatar(info.icon)
        item.name:SetText(info.name)

        local minghao = g_JieBaiCtrl:GetTitleMingHao(pid)
        if minghao then 
            item.minghao:SetText(minghao)
            item.minghao:SetActive(true)
        else
            item.minghao:SetActive(false)
        end 
    end 

end


return CJieBaiInvitedItemList
