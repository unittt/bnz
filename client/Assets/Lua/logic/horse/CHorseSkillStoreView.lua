local CHorseSkillStoreView = class("CHorseSkillStoreView", CViewBase)

function CHorseSkillStoreView.ctor(self, cb)

	CViewBase.ctor(self, "UI/Horse/HorseSkillStoreView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "sub"
    self.m_ExtendClose = "Black"
    
end

function CHorseSkillStoreView.OnCreateView(self)

	self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_PreviewRowBox = self:NewUI(2, CHorsePreviewSkillRowBox)
    self.m_Grid = self:NewUI(3, CGrid)

    self:InitContent()

end

function CHorseSkillStoreView.InitContent(self)

    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self:InitSkillStoreGrid()

end


function CHorseSkillStoreView.InitSkillStoreGrid(self)

    local horseSkill = g_HorseCtrl:GetHorseSkill()

    for k, v in ipairs(horseSkill) do 

        local rowBox = self.m_Grid:GetChild(k)
        if not rowBox then 
            rowBox = self.m_PreviewRowBox:Clone()
            rowBox:SetActive(true)
            self.m_Grid:AddChild(rowBox)
        end 
        rowBox:SetInfo(v)
    end 

end

return CHorseSkillStoreView