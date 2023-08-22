local CNormalTitleHud = class("CNormalTitleHud", CAsynHud)

function CNormalTitleHud.ctor(self, cb)
    CAsynHud.ctor(self, "UI/Hud/NormalTitleHud.prefab", cb)
end

function CNormalTitleHud.OnCreateHud(self)
    self.m_NameLabel = self:NewUI(1, CHudLabel)
end

function CNormalTitleHud.SetName(self, tid, name)
    --玩家普通称谓两个表控制，namecolordata 控制默认颜色。 加粗，字号
                            -- titledata 控制特殊颜色
    local titleinfo = data.titledata.INFO[tid]
    local colorinfo = data.namecolordata.TITLEDATA[0]

    -- 文字颜色
    local textColor = titleinfo.text_color
    local color
    if string.len(textColor) >0 then
        color = textColor
    else
        color = colorinfo.color
    end
    
    name = "["..color.."]"..name
    -- name = colorinfo.blod == 1 and "[b]"..name or name
    -- 加粗
    self.m_NameLabel:SetText(name)
    -- 字号
    self.m_NameLabel:SetFontSize(colorinfo.size)

    -- self.m_NameLabel:SetEffectStyle(colorinfo.style)
    -- self.m_NameLabel:SetEffectDistance(Vector2.New(colorinfo.shadow_size, colorinfo.shadow_size))

    -- 描边颜色
    -- local outlineColor = titleinfo.outline_color
    -- if outlineColor == "" then
    --     self.m_NameLabel:SetEffectColor(Color.RGBAToColor(colorinfo.style_color))
    -- else
    --     self.m_NameLabel:SetEffectColor(Color.RGBAToColor(outlineColor))
    -- end
end

function CNormalTitleHud.SetNameByStr(self, sName)
    local colorinfo = data.namecolordata.TITLEDATA[0]
    sName = string.format("[%s]%s", colorinfo.color, sName)
    self.m_NameLabel:SetText(sName)
    self.m_NameLabel:SetFontSize(colorinfo.size)
    -- self.m_NameLabel:SetEffectColor(Color.RGBAToColor(colorinfo.style_color))
end

return CNormalTitleHud