local COfferRewardCtrl = class("COfferRewardCtrl", CCtrlBase)

function COfferRewardCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_ItemSid = 11038
	self:CheckOfferRewardPrizeConfig()
end

function COfferRewardCtrl.Clear(self)
	
end

function COfferRewardCtrl.CheckOfferRewardPrizeConfig(self)
	self.m_OfferRewardPrizeConfig = {}
	for i,v in ipairs(data.scheduledata.SCHEDULE[1031].rewardlist) do
		local strs = string.split(v, ":")
		local itemID, itemAmount = strs[1], strs[2]
		local itemData = DataTools.GetItemData(itemID)
		if itemData then
			table.insert(self.m_OfferRewardPrizeConfig, {item = itemData, amount = tonumber(itemAmount)})
		end
	end
end

return COfferRewardCtrl