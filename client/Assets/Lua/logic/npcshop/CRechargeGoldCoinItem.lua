local CRechargeGoldCoinItem = class("CRechargeGoldCoinItem", CBox)

function CRechargeGoldCoinItem.ctor(self, obj, cb)
    CBox.ctor(self, obj)

    self.m_TitleLabel = self:NewUI(1, CLabel)
    self.m_NeedCashLabel = self:NewUI(2, CLabel)
    self.m_ItemBg = self:NewUI(3, CTexture)
    self.m_JiaoBiaoSprite = self:NewUI(4, CSprite)
    self.m_CommonRewardLabel = self:NewUI(5, CLabel)
    self.m_FirstRewardLabel = self:NewUI(6, CLabel)

    self.m_CallBack = cb
    self.m_ItemBg:AddUIEvent("click", callback(self, "ButtonCallBack"))
end

function CRechargeGoldCoinItem.SetBoxInfo(self, datalist)
    self.m_CommonRewardLabel:SetActive(false)
    self.m_NeedCashLabel:SetText(datalist.RMB)
    local sName = ""
    local sDay = ""
    if datalist.spc_key == "goldcoin_gift_1" then
        sName = "周卡"
    elseif datalist.spc_key == "goldcoin_gift_2" then
        sName = "月卡"
    end
    local dGiftInfo = DataTools.GetChargeData("YUANBAO", datalist.spc_key)
    if dGiftInfo then
        sDay = tostring(dGiftInfo.days)
    end
    self.m_TitleLabel:SetText(string.AddCommaToNum(datalist.gold_coin_gains) .. "元宝" .. sName)
    
    self.m_FirstRewardLabel:SetText(string.format("每日赠送%s元宝，持续%s天", string.ConvertToArt(datalist.reward_gold_coin), sDay))
    local sTextureName = "Texture/Currency/"..datalist.icon..".png"
    local oTexture = g_ResCtrl:LoadAsync(sTextureName, callback(self, "SetTexture"))
    self.m_JiaoBiaoSprite:SetActive(datalist.tag == 0)
end

function CRechargeGoldCoinItem.ButtonCallBack(self)
    if self.m_CallBack then
        self.m_CallBack()
    end
end

function CRechargeGoldCoinItem.SetTexture(self, prefab, errcode)
    if prefab then
        self.m_ItemBg:SetMainTexture(prefab)
    else
        print(errcode)
    end
end

return CRechargeGoldCoinItem