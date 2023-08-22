local CWindowItemTipView = class("CWindowItemTipView", CViewBase)

function CWindowItemTipView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Notify/WindowItemTipView.prefab", cb)
	self.m_DepthType = "Notify"
end

function CWindowItemTipView.OnCreateView(self)
	self.m_Icon = self:NewUI(1, CSprite)
	self.m_Quality = self:NewUI(2, CSprite)
	self.m_Name = self:NewUI(3, CLabel)
	self.m_Introduction = self:NewUI(4, CLabel)
	self.m_Description = self:NewUI(5, CLabel)
	self.m_TipWidget = self:NewUI(6, CWidget)
	g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
end

function CWindowItemTipView.SetWindowItemTipInfo(self, itemid, args, hasSpecial, oMarkItemData)
	if type(itemid) == "string" then
		itemid = tonumber(itemid)
		if not itemid then
			printerror("错误的道具ID，无法转为数字，请查证", itemid)
			return
		end
	end
	local itemInfo = oMarkItemData and oMarkItemData or DataTools.GetItemData(itemid)
	local quality = g_ItemCtrl:GetQualityVal( itemInfo.id, itemInfo.quality or 0 )

	self.m_Icon:SpriteItemShape(itemInfo.icon)
	self.m_Quality:SetItemQuality(quality)

	local sName = string.format(data.colorinfodata.ITEM[quality or 0].color, itemInfo.name)--datauser.colordata.ITEM.Quality[itemInfo.quality or 0] .. itemInfo.name
	self.m_Name:SetRichText(sName, nil, nil, true)

	self.m_Introduction:SetText(itemInfo.introduction)
	local description
	if itemid == define.Treasure.Config.Item5 or itemid == define.Treasure.Config.Item4 then
		description = string.format(itemInfo.description, "某地")
	else
		description = g_ItemCtrl:GetItemDesc(itemid)--itemInfo.description
	end	

	if args and args.des then
		description = description.."\n"..args.des
	end
	
	self.m_Description:SetRichText(description, nil, nil, true)
	local _, height = self.m_Description:GetSize()
	self.m_TipWidget:SetHeight(164 + height)

	if hasSpecial then
		self.m_Icon:SetActive(false)
		self.m_Quality:SetActive(false)
		self.m_Name:SetActive(false)
		self.m_Introduction:SetActive(false)
		self.m_TipWidget:SetHeight(height)
	end
	
end

function CWindowItemTipView.SetWindowSumTipInfo(self, sumid)
	local sumInfo = DataTools.GetSummonInfo(sumid)
	self.m_Icon:SpriteAvatar(sumInfo.shape)
	self.m_Quality:SetItemQuality(sumInfo.quality or 0)

	local sName = string.format(data.colorinfodata.ITEM[sumInfo.quality or 0].color, sumInfo.name)--datauser.colordata.ITEM.Quality[sumInfo.quality or 0] .. sumInfo.name
	self.m_Name:SetRichText(sName, nil, nil, true)
	self.m_Introduction:SetText(sumInfo.introduction or "简介：什么都没有")
	self.m_Description:SetRichText(sumInfo.description or "描述：什么都没有", nil, nil, true)

	local _, height = self.m_Description:GetSize()
	local widgetH = 164 + height
	self.m_TipWidget:SetHeight(widgetH)
end

function CWindowItemTipView.SetWindowSkillTipInfo(self, info)
	self.m_Icon:SpriteSkill(tostring(info.icon))
	self.m_Name:SetRichText(info.name, nil, nil, true)
	self.m_Introduction:SetText(info.introduction or "")
	self.m_Description:SetRichText(info.desc or "", nil, nil, true)
	local _, height = self.m_Description:GetSize()
	local widgetH = 164 + height
	self.m_TipWidget:SetHeight(widgetH)
end


return CWindowItemTipView