local CSummonSkillBox = class("CSummonSkillBox", CBox)

function CSummonSkillBox.ctor(self, obj, count)
    CBox.ctor(self, obj)
    self.m_Cnt = count
    self:InitContent(self)
end

function CSummonSkillBox.InitContent(self)
    self.m_SkillItemGird = self:NewUI(1, CGrid)
    self.m_SkillItem = self:NewUI(2, CSummonSkillItemBox)
    self.m_ScrollView = self:NewUI(3, CScrollView)

    self.m_SkillItem:SetActive(false)
end

-- bOpera： 是否可编辑技能
function CSummonSkillBox.SetInfo(self, info, bOpera)
    self.m_SkillItemGird:HideAllChilds()
    local maxCnt = self.m_Cnt or SummonDataTool.GetMaxSkillCnt(info)
    for i, v in ipairs(info) do
        local oBox = self.m_SkillItemGird:GetChild(i)
        if not oBox then
            oBox = self:CreateItem()
        end
        -- if v.equip then-- or v.talent then
        --     maxCnt = maxCnt + 1
        -- end
        oBox:SetActive(true)
        oBox:SetInfo(v, bOpera)
    end
    local iBegin = #info
    for i = iBegin+1, maxCnt do
        local oBox = self.m_SkillItemGird:GetChild(i)
        if not oBox then
            oBox = self:CreateItem()
        end
        oBox:SetActive(true)
        oBox:SetInfo(nil)
    end
    self.m_ScrollView:ResetPosition()
end

function CSummonSkillBox.CreateItem(self)
    local item = self.m_SkillItem:Clone()
    item:SetGroup(self.m_SkillItemGird:GetInstanceID())
    item:SetActive(true)
    self.m_SkillItemGird:AddChild(item)
    return item
end

return CSummonSkillBox