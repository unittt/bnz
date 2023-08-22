local CWarItemView = class("CWarItemView", CViewBase)

function CWarItemView.ctor(self, cb)
	CViewBase.ctor(self, "UI/War/WarItemView.prefab", cb)
	self.m_GroupName = "main"
	self.m_ExtendClose = "ClickOut"
end

function CWarItemView.OnCreateView(self)
	self.m_ItemList = {
		{10051, 10052, 10053, 10054, 10055, 10056},
		{10046, 10047, 10048, 10049, 10050, 10057, 10058, 10059, 10060, 10061, 10062, 10063, 10064}
	}

	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ItemGrid = self:NewUI(2, CGrid)
	self.m_ItemClone = self:NewUI(3, CBox)
	self.m_ItemUseBtn = self:NewUI(4, CSprite)
	self.m_M2ItemCount = self:NewUI(5, CLabel)
	self.m_M3ItemCount = self:NewUI(6, CLabel)
	self.m_ItemInfoObj = self:NewUI(7, CObject)
	self.m_ItemInfoName = self:NewUI(8, CLabel)
	self.m_ItemInfoUsed = self:NewUI(9, CLabel)
	self.m_ItemInfoProps = self:NewUI(10, CLabel)
	self.m_ItemInfoDesc = self:NewUI(11, CLabel)
	self.m_ItemNilObj = self:NewUI(12, CObject)
	self.m_ItemNilTitle = self:NewUI(13, CLabel)
	self.m_ItemNilTip = self:NewUI(14, CLabel)
	self.m_ItemNilTipContent = self:NewUI(15, CLabel)
	self.m_ItemInfoObj:SetActive(false)
	self.m_ItemNilObj:SetActive(true)
	self:InitContent()
end

function CWarItemView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ItemUseBtn:AddUIEvent("click", callback(self, "OnItemUse"))
	self:InitItemContent()
end

function CWarItemView.SetIsHero(self, bHero)
	self.m_IsHero = bHero
	local status = g_WarCtrl:GetHero() and g_WarCtrl:GetHero().m_Status
	if status then
		self.m_M2ItemCount:SetText("[502E10]已使用2级药     #G" .. (status.item_use_cnt2 or 0) .. "/20")
		self.m_M3ItemCount:SetText("[502E10]已使用3级药和酒 #G" .. (status.item_use_cnt1 or 0) .. "/10")
	end
end

function CWarItemView.OnItemUse(self)
	-- 使用道具
	if self.m_RecordItem then
		if self.m_IsHero then
			g_WarOrderCtrl:SetHeroOrder("WarItem", self.m_RecordItem:GetSValueByKey("id"))
		else
			g_WarOrderCtrl:SetSummonOrder("WarItem", self.m_RecordItem:GetSValueByKey("id"))
		end
		self:CloseView()
		return
	end
	g_NotifyCtrl:FloatMsg("请选择要使用的道具")
end

function CWarItemView.InitItemContent(self)
	self.m_ItemClone:SetActive(false)
	local itemBoxList = self.m_ItemGrid:GetChildList()
	local itemDataList = g_ItemCtrl:GetWarItemList()
	local gridID = self.m_ItemGrid:GetInstanceID()
	local count = math.max(#itemDataList, 12)
	-- local index = 1
	-- if #itemDataList > 0 then
	-- 	index = itemDataList + 1
	-- 	if #itemDataList >= 12 then
	-- 		count = count + 1
	-- 	end
	-- end
	for i=1,count do
	-- for i,v in ipairs(itemDataList) do
		local oItemBox = nil
		if i > #itemBoxList then
			oItemBox = self.m_ItemClone:Clone()
			self.m_ItemGrid:AddChild(oItemBox)
			oItemBox:SetGroup(gridID)
			oItemBox.m_Icon = oItemBox:NewUI(1, CSprite)
			oItemBox.m_Count = oItemBox:NewUI(2, CLabel)
			oItemBox.m_Quality = oItemBox:NewUI(3, CSprite)
			oItemBox.m_AddSpr = oItemBox:NewUI(4, CSprite)
		else
			oItemBox = itemBoxList[i]
		end

		local show = i <= #itemDataList-- or i == index

		oItemBox.m_Icon:SetActive(show)
		oItemBox.m_Count:SetActive(show)
		oItemBox.m_Quality:SetActive(show)
		oItemBox.m_AddSpr:SetActive(false)

		if show then
			-- if i == index then
			-- 	oItemBox.m_Icon:SetActive(false)
			-- 	oItemBox.m_Count:SetActive(false)
			-- 	oItemBox.m_Quality:SetActive(false)
			-- 	oItemBox.m_AddSpr:SetActive(true)
			-- 	oItemBox:AddUIEvent("click", function ()
			-- 		-- 打开商店
			-- 		printc("打开商店")
			-- 	end)
			-- else
				local v = itemDataList[i]
				oItemBox:AddUIEvent("click", function ()
					oItemBox:SetSelected(true)
					if self.m_RecordBoxIndex ~= i then
						self.m_RecordBoxIndex = i
						self.m_RecordItem = v
						-- local config = {widget = oItemBox}
						-- g_WindowTipCtrl:SetWindowItemTip(v:GetSValueByKey("sid"), config)
						self.m_ItemInfoObj:SetActive(true)
						self.m_ItemNilObj:SetActive(false)
						local quality = v:GetQuality()
						local textName = string.format(data.colorinfodata.ITEM[quality].color, v:GetItemName())
						self.m_ItemInfoName:SetText(textName)
						self.m_ItemInfoUsed:SetText(v:GetCValueByKey("introduction"))
						self.m_ItemInfoProps:SetText("属性描述")
						local info = g_ItemViewCtrl:ShowDragDes(v)
						if v.m_SID == 10174 then
							self.m_ItemInfoDesc:SetText("[c][502E10]" .. v:GetCValueByKey("description") .. "\n" .. (info or ""))
						else
							self.m_ItemInfoDesc:SetText(v:GetCValueByKey("description") .. "\n" .. (info or ""))
						end
						
						local status = g_WarCtrl:GetHero() and g_WarCtrl:GetHero().m_Status
						local countList = {cur = {}, max = {20, 10}}
						if status then
							countList.cur = {status.item_use_cnt2 or 0, status.item_use_cnt1 or 0}
						end

						local itemid = self.m_RecordItem:GetSValueByKey("sid")
						for i,v in ipairs(self.m_ItemList) do
							if table.index(v, itemid) then
								if countList.cur[i] and countList.cur[i] >= countList.max[i] then
									self.m_ItemUseBtn:SetGrey(true)
									self.m_ItemUseBtn:EnableTouch(false)
									return
								end
								break
							end
						end
						self.m_ItemUseBtn:SetGrey(false)
						self.m_ItemUseBtn:EnableTouch(true)
					end
				end)
				oItemBox.m_Icon:SpriteItemShape(v:GetCValueByKey("icon"))
				oItemBox.m_Count:SetText(v:GetSValueByKey("amount"))
				oItemBox.m_Quality:SetItemQuality(0)
			end
		-- end
		oItemBox:SetActive(true)
	end
	for i=count+1,#itemBoxList do
		itemBoxList[i]:SetActive(false)
	end
end

return CWarItemView