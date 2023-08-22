local CAttrSkillMakeLeftBox = class("CAttrSkillMakeLeftBox", CBox)

function CAttrSkillMakeLeftBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_SkillGrid = self:NewUI(1, CGrid)
	self.m_SkillItem = self:NewUI(2, CBox)
    local function Init(obj, idx)
        local cbox = CBox.New(obj)
        cbox:SetGroup(self.m_SkillGrid:GetInstanceID())
        return cbox
    end
    self.m_SkillGrid:InitChild(Init)
    self.m_UseItem = {}
    g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "RefreshItem"))
    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "RefreshItem")) 
end

function CAttrSkillMakeLeftBox.SetInfo(self, skill, cb)
    self.m_CurSkill = skill
    self.m_Cb = cb
    local skillData = data.skilldata.ORGSKILL[skill.sk]
    local i = 1
    for k,v in pairs(skillData.make_item) do
        local count =  g_ItemCtrl:GetBagItemAmountBySid(v)  --DataTools.GetItemData(v)
        if count > 0 then
            --local clone = self.m_SkillItem:Clone()
            local clone = self.m_SkillGrid:GetChild(i)
            clone:SetActive(true)
            clone.icon = clone:NewUI(1, CSprite)
            clone.num = clone:NewUI(2, CLabel)
            clone.icon:SetActive(true)
            clone.num:SetActive(true)
            local item = g_AttrCtrl:GetDragItem(v)
            clone.num:SetText(count)
            clone.icon:SetSpriteName(item.icon)
            clone:AddUIEvent("click", callback(self, "OnSelItem", i, item, cb))
            clone:SetGroup(self.m_SkillGrid:GetInstanceID())
            self.m_SkillGrid:AddChild(clone)
            i = i + 1
        end     
    end
    for j = i, self.m_SkillGrid:GetCount() do
        if self.m_SkillGrid:GetChild(j).icon then
            local go = self.m_SkillGrid:GetChild(j)
            go.icon:SetActive(false)
            go.num:SetActive(false)
            -- go:AddUIEvent("click", nil)
        end
    end
end

function CAttrSkillMakeLeftBox.HideSelectSprite(self)
    for i = 1, self.m_SkillGrid:GetCount() do
        local oItem = self.m_SkillGrid:GetChild(i)
        if oItem then
            local b = oItem:GetSelected()
            if b then
                oItem:ForceSelected(false)
                return
            end
        end
    end
end

function CAttrSkillMakeLeftBox.RefreshItem(self, oCtrl)
    if oCtrl.m_EventID == define.Summon.Event.BagItemUpdate or oCtrl.m_EventID == define.Item.Event.AddBagItem 
    or oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
        if self.m_CurSkill and self.m_Cb then          
            self:SetInfo(self.m_CurSkill, self.m_Cb)
        end
    end
    if oCtrl.m_EventID == define.Attr.Event.GetUseOrgSkill then
        
    end
    if oCtrl.m_EventID == define.Attr.Event.AutoMakeDrag then
        self:HideSelectSprite()
    end
end

--function CAttrSkillMakeLeftBox.OnSelItem(self, itemData, clone, cb)
function CAttrSkillMakeLeftBox.OnSelItem(self, i, itemData, cb)
    local oClone = self.m_SkillGrid:GetChild(i)
    if not oClone.icon:GetActive() then
        return
    end
    oClone:SetSelected(true)
    if cb then 
        local list = cb(itemData)
        -- clone.num:SetText(list)
        -- if list <= 0 then
        --     clone.icon:SetActive(false)
        --     clone.num:SetActive(false)
        --     clone:AddUIEvent("click", nil)
        -- end
    end
end

return CAttrSkillMakeLeftBox
