local CChatItemPart = class("CChatItemPart", CPageBase)

function CChatItemPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CChatItemPart.OnInitPage(self)
	self.m_EmojiPage = self:NewUI(1, CFactoryPartScroll)
	self:InitContent()
	list = g_ItemCtrl:GetBagItemListByType("all")
end

function CChatItemPart:InitContent()
	local oPage = self.m_EmojiPage
	oPage:SetPartSize(6, 2)
	local function factory(oClone, dData)
		if dData then
			local oBox = oClone:Clone()
			oBox.m_Sprite = oBox:NewUI(1, CSprite)
			oBox.m_Icon = oBox:NewUI(2, CSprite)
			oBox.m_Icon:SpriteItemShape(dData.shape)
			oBox.m_CountLabel = oBox:NewUI(3, CLabel)
			oBox.m_Equiped = oBox:NewUI(4, CSprite)
			oBox.m_Bind = oBox:NewUI(5, CSprite)
			oBox.m_BorderSp = oBox:NewUI(6, CSprite)
			if dData.amount > 1 then
				oBox.m_CountLabel:SetText(string.format("%d", dData.amount))
			end
			if dData.isequiped then
				oBox.m_Equiped:SetActive(true)
			else
				oBox.m_Equiped:SetActive(false)
				oBox.m_Bind:SetActive(dData.isbind == 1)
			end
			oBox.m_BorderSp:SetItemQuality(dData.quality)
			oBox.m_Sprite:AddUIEvent("click", callback(self, "OnEmoji", dData))
			oBox:SetActive(true)
			return oBox
		end
	end
	oPage:SetFactoryFunc(factory)
	local itemTable = g_ItemCtrl:GetAllItem()
	local function data()
		local t = {}
		for k, oItem in ipairs(itemTable) do
			local data = {
				id = oItem:GetSValueByKey("id"),
				name = oItem:GetItemName(),
				shape = oItem:GetCValueByKey("icon"),
				quality = oItem:GetQuality(),
				sid = oItem:GetSValueByKey("sid"),
				amount = oItem:GetSValueByKey("amount"),
				isequiped = oItem:IsEquiped(),
				isbind = oItem:GetSValueByKey("key")
			}
			table.insert(t, data)
		end
		return t
	end
	
	if table.count(itemTable) > 0 then
		oPage:SetDataSource(data)
		oPage:RefreshAll()
	end
	
end

function CChatItemPart.OnEmoji(self, dData)
	local oStr = LinkTools.GenerateItemLink(g_AttrCtrl.pid, dData.id, dData.sid, dData.amount, dData.name)
	-- printc(oStr)
	self.m_ParentView:Send(oStr)
end

return CChatItemPart