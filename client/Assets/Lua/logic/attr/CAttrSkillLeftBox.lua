local CAttrSkillLeftBox = class("CAttrSkillLeftBox", CBox)

function CAttrSkillLeftBox.ctor(self, obj)
	CBox.ctor(self, obj)
	--self.m_TitleLabel = self:NewUI(1, CLabel)
    self.m_SkillGrid = self:NewUI(2, CGrid)
    self.m_SkillBox = self:NewUI(3, CBox)
end

function CAttrSkillLeftBox.SetInfo(self, info, cb)
    local infoList = {}
    self.m_cb = cb

     for _,v in pairs(data.skilldata.ORGSKILL) do
        for _,k in  pairs(info) do
            if v.id == k.sk then
                k.sort = v.sort
            end
        end
    end

    for key,value in pairs(info) do
        --TODO:魂石系统屏蔽
        if value.sk ~= 4107 then
            table.insert(infoList,value)
        end
    end

    table.sort( infoList, function(a,b)
       return a.sort < b.sort 
    end)

    for i,v in ipairs(infoList) do
        local skillData = data.skilldata.ORGSKILL[v.sk]
        local oBox = self.m_SkillGrid:GetChild(i)
        if oBox == nil then
            oBox = self.m_SkillBox:Clone()
            oBox.icon = oBox:NewUI(1, CSprite)
            oBox.name = oBox:NewUI(2, CLabel)
            oBox.grade = oBox:NewUI(3, CLabel)
            oBox.selName = oBox:NewUI(4, CLabel)
            oBox.selLv = oBox:NewUI(5, CLabel)
            self.m_SkillGrid:AddChild(oBox)
            oBox:SetGroup(self.m_SkillGrid:GetInstanceID())
        end    
        oBox:SetActive(true)
        oBox.selLv:SetActive(false)
        oBox:SetName(tostring(skillData.sort))
        oBox.icon:SetSpriteName(skillData.icon)
        oBox.name:SetText(skillData.name)
        oBox.grade:SetText(v.level.."级")
        oBox.m_SkillInfo = v
        oBox.m_Sk = v.sk
        oBox:AddUIEvent("click", callback(self, "OnShowSkillInfo", v, cb, i))

        -- 默认选择第一个
        if self.m_CurSelId == nil and skillData.sort == 1 then
            oBox:SetSelected(true)
            self:OnShowSkillInfo(v, cb, i)
        elseif self.m_CurSelId == v.sk then
            self:OnShowSkillInfo(v, cb, i) 
        end
    end
    for j = #infoList+1, self.m_SkillGrid:GetCount() do
        self.m_SkillGrid:GetChild(j):SetActive(false)
    end
end

function CAttrSkillLeftBox.OnShowSkillInfo(self, v, cb, idx)
    local oBox = self.m_SkillGrid:GetChild(idx)
    if not oBox then
        return
    end
    self.m_CurSelId = v.sk
    oBox.selName:SetText(oBox.name:GetText())
    oBox.selLv:SetText(v.level.."级")
    if cb then
        cb(v)
    end
end

function CAttrSkillLeftBox.JumpToSkillByItem(self, item, skill)
  
    local dSkill = DataTools.GetOrgSkillByItem(item)
    -- if dSkill then
        for i, oBox in ipairs(self.m_SkillGrid:GetChildList()) do
            if dSkill and oBox.m_Sk == dSkill.id  or oBox.m_Sk == skill then
                oBox:SetSelected(true)
                self:OnShowSkillInfo(oBox.m_SkillInfo , self.m_cb, i)
                break
            end
        end
    -- end

end

return CAttrSkillLeftBox
