local CTitleDescItem = class("CTitleDescItem", CBox)

function CTitleDescItem.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_ContentTitle = self:NewUI(1, CLabel)
    self.m_ContentLabel = self:NewUI(2, CLabel)
end

function CTitleDescItem.SetBoxInfo(self, tid, field)
    local fieldid   = field.id
    local fieldname = field.name
    local fieldtext = field.text
    local content = data.titledata.INFO[tonumber(tid)][fieldname]

    -- 如果是“持续时间” item
    if fieldname == "duration_time" then
        local durationTimeMin = content

        -- 没有使用持续时间
        if durationTimeMin == 0 then
            self:SetActive(false)
            return
        end
        
        --少于1分钟时显示为1分钟
        if durationTimeMin <= 1 then
            local time = durationTimeMin * 60
            content = g_TimeCtrl:GetLeftTimeDHMAlone(time)
            self.m_ContentTitle:SetText("[244b4e]"..fieldtext.."[-]")
            self.m_ContentLabel:SetText("[63432c]"..content.."[-]")
            return
        end

        -- 有使用持续时间
        local title = g_TitleCtrl:GetTitle(tonumber(tid))
        if not title then
            self:SetActive(false)
            return
        end
        local leftTimeS = title.achieve_time + durationTimeMin * 60 - g_TimeCtrl:GetTimeS()
        if leftTimeS <= 0 then
            self:SetActive(false)
            return
        end
        -- local leftTimeMin = math.floor(leftTimeS)
        -- if leftTimeMin == 0 then
        --     leftTimeMin = 1  -- 避免显示 0 分钟时实际上还有几十秒的情况
        -- end
        -- 整点显示为59分
        local i = leftTimeS % 3600
        if i > 3540 and i < 3600 then
            leftTimeS = leftTimeS - 60
        end
        content = g_TimeCtrl:GetLeftTimeDHM(leftTimeS)
    end

    -- 如果没有内容，不显示这个 item
    if content == nil or content == "" then
        self:SetActive(false)
        return
    end
    
    -- 标题
    self.m_ContentTitle:SetText("[244b4e]"..fieldtext.."[-]")

    -- 内容
    self.m_ContentLabel:SetText("[63432c]"..content.."[-]")
end

function CTitleDescItem.GetTimeDHMStr(self, mins)
    mins = tonumber(mins)

    -- 计算 DD:HH:MM
    local DD = math.floor(mins / (60 * 24))
    mins = mins - DD * 60 * 24
    local HH = math.floor(mins / 60)
    mins = mins - HH * 60
    local MM = mins

    -- 拼字符串
    local s = ""
    if DD ~= 0 then
        s = s .. DD .. "天"
    end
    if HH ~= 0 then
        s = s .. HH .. "小时"
    end
    if MM ~= 0 then
        s = s .. MM .. "分钟"
    end
    return s
end

return CTitleDescItem