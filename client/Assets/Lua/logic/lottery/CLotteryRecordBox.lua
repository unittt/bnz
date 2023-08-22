local CLotteryRecordBox = class("CLotteryRecordBox", CBox)

function CLotteryRecordBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_ScrollView = self:NewUI(1, CScrollView)
    self.m_Table = self:NewUI(2, CTable)
    self.m_RecordL = self:NewUI(3, CLabel)
    self.m_TitleL = self:NewUI(4, CLabel)
    self.m_RecordL:SetActive(false)
    self.m_MaxCnt = 15
    self.m_RecordList = {}
end

function CLotteryRecordBox.RefreshAll(self, recordList)
    if recordList then
        self.m_RecordList = recordList
    end
    self:HideAllChilds()
    local idx = #self.m_RecordList
    if idx > self.m_MaxCnt then
        for i = 1, idx - self.m_MaxCnt do
            table.remove(self.m_RecordList, 1)
        end
        idx = #self.m_RecordList
    end
    for i = 1, idx do
        local obj = self:GetObjByIdx(i)
        obj:SetText(self.m_RecordList[idx-i+1].msg)
    end
    self.m_Table:Reposition()
    -- Utils.AddTimer(callback(self, "ResetScrollView"), 0, 0)
end

function CLotteryRecordBox.ResetScrollView(self)
    local oScroll = self.m_ScrollView.m_UIScrollView
    oScroll:SetDragAmount(0, 1, false)
end

function CLotteryRecordBox.HideAllChilds(self)
    for i, obj in ipairs(self.m_Table:GetChildList()) do
        obj:SetActive(false)
    end
end

function CLotteryRecordBox.GetObjByIdx(self, idx)
    local obj = self.m_Table:GetChild(idx)
    if not obj then
        obj = self.m_RecordL:Clone()
        self.m_Table:AddChild(obj)
    end
    obj:SetActive(true)
    return obj
end

function CLotteryRecordBox.SetMaxCnt(self, iCnt)
    self.m_MaxCnt = iCnt
end

function CLotteryRecordBox.AddRecordList(self, recordList)
    for i, v in ipairs(recordList) do
        table.insert(self.m_RecordList, v)
    end
    self:RefreshAll()
end

function CLotteryRecordBox.AddRecord(self, dMsg)
    table.insert(self.m_RecordList, dMsg)
    self:RefreshAll()
end

return CLotteryRecordBox