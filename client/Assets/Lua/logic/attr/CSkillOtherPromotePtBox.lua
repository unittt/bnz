local CSkillOtherPromotePtBox = class("CSkillOtherPromotePtBox", CBox)

function CSkillOtherPromotePtBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Icon = self:NewUI(1, CSprite)
	self.m_Value = self:NewUI(2, CLabel)
	self.m_AddBtn = self:NewUI(3, CWidget, false)

	self.m_Icon:AddUIEvent("click", callback(self, "OnIconClick"))
	if self.m_AddBtn then
		self.m_AddBtn:AddUIEvent("click", callback(self, "OnAddBtnClick"))
	end

	  -- 帮贡 -- 活力 -- 剧情点
	self.m_PromotePtMap = {[1] = 1001,[2] = 1002,[3]=1003 ,[4] = 1008, [5] = 1026 , [6] = 1024}
	self.m_CurrencyType = nil
end

function CSkillOtherPromotePtBox.SetPromotePtData(self, sCurrentType)
	self.m_CurrencyType  = sCurrentType
end

function CSkillOtherPromotePtBox.OnIconClick(self)
	g_WindowTipCtrl:SetWindowGainItemTip(self.m_PromotePtMap[self.m_CurrencyType], function ()
        local oView = CItemTipsView:GetView()
        UITools.NearTarget(self.m_Icon, oView.m_MainBox, enum.UIAnchor.Side.Top, Vector2.New(0, 10))
    end)
end

function CSkillOtherPromotePtBox.OnAddBtnClick(self)
	g_ShopCtrl:ShowAddMoney(self.m_CurrencyType)
	-- if self.m_CurrencyType == define.Currency.Type.Gold then
	-- 	CCurrencyView:ShowView(function(oView)
	-- 		oView:SetCurrencyView(define.Currency.Type.Gold)
	-- 	end)
	-- elseif self.m_CurrencyType == define.Currency.Type.Silver then
	-- 	CCurrencyView:ShowView(function(oView)
	-- 		oView:SetCurrencyView(define.Currency.Type.Silver)
	-- 	end)
	-- elseif self.m_CurrencyType == define.Currency.Type.GoldCoin then
	-- 	CNpcShopMainView:ShowView(function(oView) 
	-- 		oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge")) 
	-- 	end) 
	-- else
	-- 	return
	-- end
end

return CSkillOtherPromotePtBox