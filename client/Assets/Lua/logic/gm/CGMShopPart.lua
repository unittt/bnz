local CGMShopPart = class("CGMShopPart", CPageBase)

function CGMShopPart.ctor(self, cb)
	CPageBase.ctor(self, cb)
end

function CGMShopPart.OnInitPage(self)
	self.m_TypeScroll = self:NewUI(1, CScrollView)
	self.m_TypeGrid = self:NewUI(2, CGrid)
	self.m_TypeCellClone = self:NewUI(3, CButton)
	self.m_ItemScroll = self:NewUI(4, CScrollView)
	self.m_ItemGrid = self:NewUI(5, CGrid)
	self.m_ItemCellClone = self:NewUI(6, CBox)
	self.m_BuyBtn = self:NewUI(7, CButton)
	self.m_SubBtn = self:NewUI(8, CButton)
	self.m_AddBtn = self:NewUI(9, CButton)
    self.m_CountInput = self:NewUI(10, CLabel)
	self.m_TypeCellClone:SetActive(false)
	self.m_ItemCellClone:SetActive(false)

	self.m_GMShopInfo = data.shopdata.GMSHOP
	self.m_ShopItem = nil
	self.m_ShopCount = 1
	self:InitContent()
end

function CGMShopPart.InitContent(self)
	self.m_BuyBtn:AddUIEvent("click", function ()
		if self.m_ShopItem then
			local count = tonumber(self.m_CountInput:GetText())
			if count and count > 0 then
				local sParam = "clone " .. self.m_ShopItem.item_id .. " " .. count
				netother.C2GSGMCmd(sParam)
				local itemInfo = DataTools.GetItemData(self.m_ShopItem.item_id)
				g_NotifyCtrl:FloatMsg("客户端Tip：购买成功 | #G" .. itemInfo.name .. "[-]*#O" .. count)
				printc("客户端Tip：购买成功 " .. itemInfo.name .. " * " .. count)
			else
				g_NotifyCtrl:FloatMsg("购买的物品数量不合法")
				printc("购买的物品数量不合法")
			end
		else
			g_NotifyCtrl:FloatMsg("请选择要购买的物品")
			printc("请选择要购买的物品")
		end
	end)
	self.m_SubBtn:AddUIEvent("click", function ()
		if not self.m_ShopItem then
			printc("请选择要购买的物品")
			return
		end
		if self.m_ShopCount > 1 then
			self.m_ShopCount = self.m_ShopCount - 1
		else
			g_NotifyCtrl:FloatMsg("已达到最小购买值")
			return
		end
		self.m_CountInput:SetText(self.m_ShopCount)
	end)

	self.m_AddBtn:AddUIEvent("click", function ()
		if not self.m_ShopItem then
			printc("请选择要购买的物品")
			return
		end
		self.m_ShopCount = self.m_ShopCount + 1
		self.m_CountInput:SetText(self.m_ShopCount)
	end)
    self.m_CountInput:AddUIEvent("change", function ()
    	if not self.m_ShopItem then
			printc("请选择要购买的物品")
			return
		end
		
    	local count = tonumber(self.m_CountInput:GetText())
    	if count then
    		self.m_ShopCount = count
    	else
			g_NotifyCtrl:FloatMsg("购买的物品数量不合法")
			self.m_CountInput:SetText(self.m_ShopCount)
    	end
    end)
	self.m_CountInput:AddUIEvent("click", callback(self, "OnKeyBoard"))
	self:InitTypeGrid()
	self:InitItemGrid()
end

function CGMShopPart.InitTypeGrid(self)
	local typeGridBoxList = self.m_TypeGrid:GetChildList()
	local gridID = self.m_TypeGrid:GetInstanceID()
	for k,_ in pairs(self.m_GMShopInfo) do
		local oTypeBox = self.m_TypeCellClone:Clone()
		self.m_TypeGrid:AddChild(oTypeBox)
		oTypeBox:SetGroup(gridID)
		oTypeBox:SetText(k)
		oTypeBox:AddUIEvent("click", function ()
			self:InitItemGrid(k)
		end)
		oTypeBox:SetActive(true)
	end
end

function CGMShopPart.InitItemGrid(self, key)
	key = key or "其他"
	local gridID = self.m_ItemGrid:GetInstanceID()
	local gmShopItemList = self.m_GMShopInfo[key]
	local itemGridBoxList = self.m_ItemGrid:GetChildList()
	for i,v in ipairs(gmShopItemList) do
		local oItemBox = nil
		if i > #itemGridBoxList then
			oItemBox = self.m_ItemCellClone:Clone()
			self.m_ItemGrid:AddChild(oItemBox)
			oItemBox:SetGroup(gridID)
			oItemBox.m_Icon = oItemBox:NewUI(1, CSprite)
			oItemBox.m_Name = oItemBox:NewUI(2, CLabel)
		else
			oItemBox = itemGridBoxList[i]
		end
		local itemInfo = DataTools.GetItemData(v.item_id)
		oItemBox.m_Icon:SpriteItemShape(itemInfo.icon)
		oItemBox.m_Name:SetText(itemInfo.name)
		oItemBox:AddUIEvent("click", function ()
			local config = {widget = oItemBox}
			g_WindowTipCtrl:SetWindowItemTip(v.item_id, config)
			self.m_ShopItem = v
			self.m_ShopCount = 1
			self.m_CountInput:SetText(self.m_ShopCount)
			-- local view = CSmallKeyboardView:GetView()
			-- if view then 
			-- 	view:OnClose()
			-- end 
		end)
		oItemBox:SetActive(true)
	end

	for i=#gmShopItemList+1,#itemGridBoxList do
		itemGridBoxList[i]:SetActive(false)
	end
	self.m_ItemScroll:ResetPosition()
end

function CGMShopPart.OnKeyBoard(self)
	if not self.m_ShopItem then
		printc("请选择要购买的物品")
		return
	end
	local function keycallback(oView)
		self.m_ShopCount = oView:GetNumber()--tonumber(self.m_CountInput:GetText())
	end
	local function buycallback()
		local sParam = "clone " .. self.m_ShopItem.item_id .. " " ..self.m_ShopCount	
		netother.C2GSGMCmd(sParam)
		local itemInfo = DataTools.GetItemData(self.m_ShopItem.item_id)
		g_NotifyCtrl:FloatMsg("客户端Tip：购买成功 | #G" .. itemInfo.name .. "[-]*#O" .. self.m_ShopCount)
		printc("客户端Tip：购买成功 " .. itemInfo.name .. " * " .. self.m_ShopCount)
	end	
	CSmallKeyboardView:ShowView(function (oView)
		oView:SetData(self.m_CountInput, keycallback, nil, nil, 1, 99)
	end)
end

return CGMShopPart