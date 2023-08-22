local CRechargeItem = class("CRechargeItem", CBox)

function CRechargeItem.ctor(self, obj, cb)
	CBox.ctor(self, obj)

	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_NeedCashLabel = self:NewUI(2, CLabel)
	self.m_ItemBg = self:NewUI(3, CTexture)
	self.m_JiaoBiao = self:NewUI(4, CSprite)
	self.m_CommonRewardLabel = self:NewUI(5, CLabel)
	self.m_FirstRewardLabel = self:NewUI(6, CLabel)
	self.m_BgTex = self:NewUI(7, CTexture)

	self.m_CallBack = cb
	self.m_ItemBg:AddUIEvent("click", callback(self, "ButtonCallBack"))
end

function CRechargeItem.SetBoxInfo(self, dataInfo)
	self.m_CommonRewardLabel:SetRichText(string.ConvertToArt(dataInfo.reward_gold_coin))
	self.m_CommonRewardLabel:SetActive(dataInfo.reward_gold_coin > 0)
	self.m_NeedCashLabel:SetText(dataInfo.RMB)
	self.m_TitleLabel:SetText(string.AddCommaToNum(dataInfo.gold_coin_gains) .. "元宝")

	local isFirst = g_ShopCtrl:GetChargeInfo(self.itemKey) <= 0
	if isFirst then
		self.m_FirstRewardLabel:SetText("首次购买送" .. string.ConvertToArt(dataInfo.first_reward) .. "#cur_2")
		self.m_FirstRewardLabel:SetActive(true)
		self.m_CommonRewardLabel:SetActive(false)
	else
		self.m_FirstRewardLabel:SetActive(false)
	end
	local sTextureName = "Texture/Currency/"..dataInfo.icon..".png"
	local oTexture = g_ResCtrl:LoadAsync(sTextureName, callback(self, "SetTexture"))

	local sBgTexName = "Texture/Currency/h7_bao_di.png"
	g_ResCtrl:LoadAsync(sBgTexName, callback(self, "SetBgTexture"))	

	if isFirst then
		self.m_JiaoBiao:SetSpriteName("h7_halfbei")
	else
		self.m_JiaoBiao:SetSpriteName("h7_tuijian")
		if dataInfo.tag == 0 then
			self.m_JiaoBiao:SetActive(false) 
		else
			self.m_JiaoBiao:SetActive(true)
		end
	end
end

function CRechargeItem.ButtonCallBack(self)
	if self.m_CallBack then
		self.m_CallBack()
	end
end

function CRechargeItem.SetTexture(self, prefab, errcode)
	if prefab then
		self.m_ItemBg:SetMainTexture(prefab)
	else
		print(errcode)
	end
end

function CRechargeItem.SetBgTexture(self, prefab, errcode)
	if prefab then
		self.m_BgTex:SetMainTexture(prefab)
	else
		print(errcode)
	end
end

function CRechargeItem.UpdateBuyCount(self, num)
	if num > 0 then
		self.m_FirstRewardLabel:SetActive(false)
		self.m_CommonRewardLabel:SetActive(true)
		self.m_JiaoBiao:SetSpriteName("h7_tuijian")
	else
		self.m_JiaoBiao:SetSpriteName("h7_halfbei")
	end
end

return CRechargeItem