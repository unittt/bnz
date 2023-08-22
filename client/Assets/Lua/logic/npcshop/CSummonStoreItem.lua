local CSummonStoreItem = class("CSummonStoreItem", CBox)

function CSummonStoreItem.ctor(self, obj, cb)
    CBox.ctor(self, obj)
    self.m_CallBack = cb
    self.m_SummonNameLabel = self:NewUI(1, CLabel)
    self.m_SummonHeadSprite = self:NewUI(2, CSprite)
    self.m_SummonPriceLabel = self:NewUI(3, CLabel)
    self.m_ItemBtn = self:NewUI(4, CButton, true, false)
    self.m_NeedSpr = self:NewUI(5, CSprite)
    self.m_ItemBtn:AddUIEvent("click", callback(self, "RowCallBack"))
end

function CSummonStoreItem.SetGroup(self, groupId)
    self.m_ItemBtn:SetGroup(groupId)
end

function CSummonStoreItem.SetBoxInfo(self, summonID)
    local summonInfo = DataTools.GetSummonInfo(summonID)
    local summonStoreInfo = DataTools.GetSummonStoreInfo(summonID)
    self.m_SummonNameLabel:SetText(summonInfo.name)
    self.m_SummonPriceLabel:SetCommaNum(summonStoreInfo.price)
    self.m_SummonHeadSprite:DynamicSprite("Avatar", summonInfo.shape)
    local showNeed = g_TaskCtrl:GetIsTaskNeedSum(summonStoreInfo.typeid)
    self.m_NeedSpr:SetActive(showNeed)
end

function CSummonStoreItem.RowCallBack(self)
    if self.m_CallBack then
        self.m_CallBack()
    end
end

return CSummonStoreItem