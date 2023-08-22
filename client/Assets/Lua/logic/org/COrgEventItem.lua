local COrgEventItem = class("COrgEventItem", CBox)

function COrgEventItem.ctor(self, obj, cb)
    CBox.ctor(self, obj)
    self.m_CallBack = cb
    --self.m_ItemBG = self:NewUI(1, CLabel)
    self.m_TimeLabel = self:NewUI(2, CLabel)
    self.m_TextLabel = self:NewUI(3, CLabel)

    --self.m_ItemBG:AddUIEvent("click", callback(self, "ItemCallBack"))
end

function COrgEventItem.SetGroup(self, groupId)
    --self.m_ItemBG:SetGroup(groupId)
end

function COrgEventItem.SetBoxInfo(self, event)
    if event == nil then
        return
    end
    -- 时间
    local time = os.date("%Y-%m-%d %H:%M:%S", event.time)
    self.m_TimeLabel:SetText(time)

    -- 内容
    self.m_TextLabel:SetText("[63432C]"..event.text)
end

function COrgEventItem.ItemCallBack(self)
    -- printc("帮派信息界面，点击 item")
    if self.m_CallBack then
        self.m_CallBack()
    end
end

return COrgEventItem