local CSelectRewardsPart = class("CSelectRewardsPart", CBox)

function CSelectRewardsPart.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_RewardGrid = self:NewUI(1, CGrid)
    self.m_RewardBox = self:NewUI(2, CSelectRewardBox)
    self.m_RewardBox:SetActive(false)
    self.m_SelCb = nil
end

function CSelectRewardsPart.SetInfo(self, choices, items, bCanSel)
    self.m_RewardGrid:HideAllChilds()
    for i, d in ipairs(items) do
        local oBox = self:GetRewardBox(i)
        local iSel = choices[i] or 1
        oBox:SetActive(true)
        oBox:SetInfo(iSel, d, bCanSel)
    end
end

function CSelectRewardsPart.GetRewardBox(self, slot)
    local oBox = self.m_RewardGrid:GetChild(slot)
    if not oBox then
        oBox = self.m_RewardBox:Clone()
        self.m_RewardGrid:AddChild(oBox)
        oBox:SetSelCallback(function(idx, dItem, iCurIdx)
            if self.m_SelCb then
                self.m_SelCb(slot, idx, iCurIdx)
            end
        end)
    end
    return oBox
end

function CSelectRewardsPart.GetRewardBoxes(self)
    return self.m_RewardGrid:GetChildList()
end

function CSelectRewardsPart.SetSelCallback(self, cb)
    self.m_SelCb = cb
end

return CSelectRewardsPart