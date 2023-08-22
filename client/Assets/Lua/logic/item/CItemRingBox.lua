local CItemRingBox = class("CItemRingBox", CBox)

function CItemRingBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_ItemBox = self:NewUI(1, CBox)
	self.m_Name = self:NewUI(2, CLabel)
	self.m_Introduction = self:NewUI(3, CLabel)
	self.m_Desc = self:NewUI(4, CLabel)
	self.m_EngageDate = self:NewUI(5, CLabel)
	self.m_Declaration = self:NewUI(6, CLabel)
	self.m_MarryDate = self:NewUI(7, CLabel)
	self.m_MarryPic = self:NewUI(8, CLabel)
	self.m_BgSpr = self:NewUI(9, CSprite)

	self.m_MarryPic:AddUIEvent("click", callback(self, "OnClickMarryPic"))
end

function CItemRingBox.InitRingBox(self, item)
	self.m_ItemInfo = item
	local sid = item.equip.sid
	local dItem = DataTools.GetItemData(sid)

	local oItemBox = self.m_ItemBox
	oItemBox.m_Icon = oItemBox:NewUI(1, CSprite)
	oItemBox.m_Broader = oItemBox:NewUI(2, CSprite)

	oItemBox.m_Icon:SpriteItemShape(dItem.icon)
	oItemBox.m_Broader:SetItemQuality(dItem.quality)

	local iQuality = dItem.quality
	local sName = string.format(data.colorinfodata.ITEM[iQuality].color, dItem.name)
	self.m_Name:SetRichText(sName, nil, nil, true)

	local equipInfo = self.m_ItemInfo.equip.equip_info
	if equipInfo then
		
		self.m_Introduction:SetText(dItem.introduction)
		self.m_Desc:SetRichText(dItem.description, nil, nil, true)

		--日期--
		local time = equipInfo.engage_time
		local text = equipInfo.engage_text


		local date = os.date("%Y/%m/%d", time)
		self.m_EngageDate:SetText(date)

		--宣言----银戒指不显示宣言
		local bDeclaration = sid ~= 22901
		self.m_Declaration:SetActive(bDeclaration)
		if bDeclaration then
			local name = item.name
			if name then
				local sName = "#G("..name..")[-]"
				local declaration = "[62A897]"..text..sName
				self.m_Declaration:SetRichText(declaration, nil, nil, true)
			end
		end
		self:RefreshMarryInfo(bDeclaration)
	end
end

function CItemRingBox.RefreshMarryInfo(self, bDeclaration)
	local bMarry = g_MarryCtrl:IsMarried()
	self.m_MarryPic:SetActive(bMarry)
	self.m_MarryDate:SetActive(bMarry)
	local height
	if bMarry then
		local time = g_MarryCtrl:GetMarryTime()
		if time > 0 then
			self.m_MarryDate:SetText(os.date("%Y/%m/%d", time))
		else
			self.m_MarryDate:SetText("")
		end
		local iType = g_MarryCtrl:GetMarryType()
	    local dConfig = DataTools.GetEngageData("TYPE", iType)
	    if dConfig then
	    	self.m_MarryPic:SetText(string.format("[0fff32]【%s】", dConfig.pic_name))
	    else
	    	self.m_MarryPic:SetText("")
	    end
		local pos = self.m_MarryDate:GetLocalPos()
		if bDeclaration then
			pos.y = -322
			height = 404
		else
			pos.y = -280
			height = 362
		end
		self.m_MarryDate:SetLocalPos(pos)
	else
		-- if bDeclaration then
			height = 330
		-- else
		-- 	height = 290
		-- end
	end
	self.m_BgSpr:SetHeight(height)
end

function CItemRingBox.OnClickMarryPic(self)
	g_MarryCtrl:ShowShareMarriedView(false)
	CItemTipsView:CloseView()
end

return CItemRingBox