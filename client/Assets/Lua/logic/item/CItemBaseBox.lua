local CItemBaseBox = class("CItemBaseBox", CBox)

function CItemBaseBox.ctor(self, obj, boxType)
	CBox.ctor(self, obj)

	self.m_IconSprite = self:NewUI(1, CSprite)
	self.m_LockSprite = self:NewUI(2, CSprite)
	self.m_BorderSprite = self:NewUI(3, CSprite)
	self.m_GradeLabel = self:NewUI(4, CLabel)
	self.m_AmountLabel = self:NewUI(5, CLabel)
	
	self:ResetStatus()

	self.m_BoxType = boxType
	self.m_ClickCallback = nil
	self.m_IsBindEvent = false
end

function CItemBaseBox.BindUIEvent(self)
	if not self.m_IsBindEvent then
		self:AddUIEvent("click", callback(self, "OnItemBoxClick"))
		self.m_IsBindEvent = true
	end
end

function CItemBaseBox.CreateIDLabel(self, id)
	if g_GmCtrl.m_IsShowItemID then
		if not self.m_IDLabel then
			self.m_IDLabel = self.m_AmountLabel:Clone()
			self.m_IDLabel:SetActive(g_GmCtrl.m_IsShowItemID)
			self.m_IDLabel:SetParent(self.m_Transform)
			local pos = self.m_AmountLabel:GetLocalPos()
			pos.y = pos.y + 30
			self.m_IDLabel:SetLocalPos(pos)
		end
		self.m_IDLabel:SetText("ID:"..id)
	end
end

function CItemBaseBox.ResetStatus(self)
	self.m_Item = nil
	self.m_ID = nil
	self.m_Lock = false
	self.m_ShowEquipLv = false
	self.m_ShowWenShiLv = false
    --self.m_isTreasure = false    --珍品图标默认 隐藏
    self.m_TreasureSprite = nil 

	self:RefreshBox()
end

function CItemBaseBox.SetClickCallback(self, cb)
	self.m_ClickCallback = cb
end

function CItemBaseBox.OnItemBoxClick(self)
	if not self.m_Item then
		return
	end
	if self.m_ClickCallback then
		self.m_ClickCallback(self)
		return
	end
	-- g_WindowTipCtrl:SetWindowItemTip(self.m_Item:GetCValueByKey("id"),
	-- 	{widget=  self, side = enum.UIAnchor.Side.Right,offset = Vector2.New(10, 50)})
	g_WindowTipCtrl:SetWindowGainItemTip(self.m_Item:GetCValueByKey("id"), nil, nil, self.m_Item:GetSValueByKey("hunshi_info"))
end

function CItemBaseBox.GetBagItem(self)
	return self.m_Item
end

function CItemBaseBox.SetBagItem(self, oItem)
	local isTouch = false
	if not self.m_Lock then
		self.m_Item = oItem
		if oItem then
			self.m_ID = oItem:GetSValueByKey("id")
			self.m_Name = oItem:GetItemName()
			isTouch = true
		end
		self:RefreshBox()
	elseif self.m_BoxType == define.Item.CellType.ModelEquip then
		isTouch = false
	else
		isTouch = true
	end

	self:SetEnableTouch(isTouch)
end

function CItemBaseBox.SetEnableTouch(self, isTouch)
	self:EnableTouch(isTouch)
	if isTouch then
		self:BindUIEvent()
	end
end

function CItemBaseBox.RefreshBox(self)
	self:SetLock(self.m_Lock)

	self:SetGradeText(0)

	local showItem = not self.m_Lock and self.m_Item ~= nil
	self.m_IconSprite:SetActive(showItem)
	self:ShowTreasureSprite(false)  --隐藏珍品图标
	if showItem then
		local shape = self.m_Item:GetCValueByKey("icon") or 0
		self.m_IconSprite:SpriteItemShape(shape)
		local amount = self.m_Item:GetSValueByKey("amount") or 0
		self:SetAmountText(amount, self.m_Item:GetCValueByKey("maxOverlay"))
		local quality = self.m_Item:GetQuality()
		local itemId = self.m_Item:GetSValueByKey("sid")
		local isDrage = false
		if itemId >= 10046 and itemId <= 10064 then  --特殊处理
		   quality = 0
		   isDrage = true
		end
		if quality then
			self:SetBaseItemQuality(true, quality)
			if not isDrage and self.m_Item:IsEquip() then
			   self:ShowTreasureSprite(self.m_Item:GetSValueByKey("itemlevel") >= define.Item.Quality.Purple)  --刷新珍品图标的显隐
			end	
		else		
			self:SetBaseItemQuality(false)
		end
		if self.m_ShowEquipLv and self.m_Item:IsEquip() then
			local equipLv = self.m_Item:GetItemEquipLevel()
			self:SetGradeText(equipLv)
		end
		if self.m_ShowWenShiLv and self.m_Item:IsWenShi() then 
			local lv = self.m_Item:GetItemWenShiLevel()
			self:SetGradeText(lv)
		end 
		self:CreateIDLabel(self.m_Item.m_ID)
	else
		self:SetAmountText(0)
		self:SetBaseItemQuality(false)
	end
end

function CItemBaseBox.SetLock(self, isLock, index)
	self.m_Lock = isLock
	if index then
		self.m_Index = index
	end
	self.m_LockSprite:SetActive(isLock)
end

function CItemBaseBox.SetBaseItemQuality(self, isBorder, quality)
	if quality then
		self.m_BorderSprite:SetItemQuality(quality)
	end
	self.m_BorderSprite:SetActive(isBorder)
end

function CItemBaseBox.SetGradeText(self, grade)
	local showGrade = grade and grade > 0
	self.m_GradeLabel:SetActive(showGrade)
	if showGrade then self.m_GradeLabel:SetText("Lv."..grade) end
end

function CItemBaseBox.SetAmountText(self, amount, maxOverlay)
	local maxOverlay = maxOverlay or 100
	local showAmount = amount >= 1 and maxOverlay > 1 
	self.m_AmountLabel:SetActive(showAmount)
	self.m_Amount = amount
	if showAmount then self.m_AmountLabel:SetText(amount) end
end

function CItemBaseBox.ShowEquipLevel(self, bIsShow)
	self.m_ShowEquipLv = bIsShow
end

function CItemBaseBox.ShowWenShiLevel(self, bIsShow)
	
	self.m_ShowWenShiLv = bIsShow

end

--是否是珍品
function CItemBaseBox.ShowTreasureSprite(self, isTreasure) 
	--TODO:策划珍品规则未确认，临时屏蔽
	isTreasure = false
	if isTreasure then
		if not self.m_TreasureSprite then
			self.m_TreasureSprite = self.m_BorderSprite:Clone()
			self.m_TreasureSprite:SetParent(self.m_Transform)
			local pos = self.m_TreasureSprite:GetLocalPos() + Vector3.New(-12, 12, 0)
			self.m_TreasureSprite:SetLocalPos(pos)
			local iconDepth = self.m_IconSprite:GetDepth()
			local borderDepth = self.m_BorderSprite:GetDepth()
			local depth = iconDepth > borderDepth and iconDepth or borderDepth
			self.m_TreasureSprite:SetDepth(depth + 1)
			self.m_TreasureSprite:SetSpriteName("h7_zhenpin")
			self.m_TreasureSprite:MakePixelPerfect()
			-- self.m_TreasureSprite:SetStaticSprite("Equip","h7_zhenpin",function ()
			-- 	self.m_TreasureSprite:MakePixelPerfect()
			-- end)
		end
		self.m_TreasureSprite:SetActive(isTreasure)
    else if self.m_TreasureSprite then
		    self.m_TreasureSprite:SetActive(isTreasure)
         end
    end	
end

return CItemBaseBox