local CJieBaiDelMemberView = class("CJieBaiDelMemberView", CViewBase)

function CJieBaiDelMemberView.ctor(self, cb)

	CViewBase.ctor(self, "UI/JieBai/JieBaiDelMemberView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "sub"
    self.m_ExtendClose = "Black"

end

function CJieBaiDelMemberView.OnCreateView(self)

    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_Grid = self:NewUI(2, CGrid)
    self.m_Item = self:NewUI(3, CJieBaiDelMemberItem)

    self:InitContent()

end

function CJieBaiDelMemberView.InitContent(self)
  
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))

    self:RefreshList()
  
end

function CJieBaiDelMemberView.RefreshList(self)
    
    local list = g_JieBaiCtrl:GetOtherMemberList()
    self.m_Grid:HideAllChilds()

    for k, v in ipairs(list) do 
        local item = self.m_Grid:GetChild(k)
        if item == nil then
            item = self.m_Item:Clone() 
            item:SetActive(true)
            self.m_Grid:AddChild(item)  
        end
        item:SetActive(true)
        item:SetInfo(v, callback(self, "OnClickItem"))
    end 

end

function CJieBaiDelMemberView.OnClickItem(self)
    
    self:OnClose()

end

return CJieBaiDelMemberView