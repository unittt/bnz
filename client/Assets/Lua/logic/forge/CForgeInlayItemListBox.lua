 local CForgeInlayItemListBox = class("CForgeInlayItemListBox", CBox)
 
function CForgeInlayItemListBox.ctor(self, obj)
	CBox.ctor(self, obj)
	
	self.m_ComposeBtn = self:NewUI(1, CButton)
	self.m_GemStoneBtnGrid = self:NewUI(2, CGrid)
	self.m_GemStoneBtnScrollView = self:NewUI(3, CScrollView)
	self.m_GemStoneItemGrid = self:NewUI(4, CGrid)
	self.m_GemStoneItemClone = self:NewUI(5, CBox)
	self.m_ScrollView = self:NewUI(6, CScrollView)
	self.m_SelSprs = {
		[1] = self:NewUI(7, CSprite),
		[2] = self:NewUI(8, CSprite),
		[3] = self:NewUI(9, CSprite),
	}

	self.m_SelectedColor = 1
	self.m_MaxGrade = 1

	self:InitContent()
end

function CForgeInlayItemListBox.InitContent(self)
	self:InitGemStoneBtnGrid()
	self.m_GemStoneItemClone:SetActive(false)
	self.m_ComposeBtn:AddUIEvent("click", callback(self, "OnClickCompose"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
end

function CForgeInlayItemListBox.InitGemStoneBtnGrid(self)
	local function Init(obj, idx)
		local oBtn = CButton.New(obj)
		-- oBtn:AddUIEvent("click", callback(self, "OnClickSwitchStone", idx))
		return oBtn
	end 
	self.m_GemStoneBtnGrid:InitChild(Init)
end

function CForgeInlayItemListBox.SetSelectCallback(self, cb)
	self.m_SelectedCb = cb
end

function CForgeInlayItemListBox.SetMaxGrade(self, iGrade)
	self.m_MaxGrade = iGrade
end

function CForgeInlayItemListBox.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem or 
		oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		self:RefreshItemGrid()
	end
end

-----------------------refresh ui-------------------------------
function CForgeInlayItemListBox.RefreshScrollView(self)
	self.m_ScrollView:ResetPosition()
end

function CForgeInlayItemListBox.RefreshItemGrid(self)
	--TODO:获取魂石列表
	self.m_GemStoneItemGrid:SetActive(self.m_SelectedColor ~= -1)
	if self.m_SelectedColor == -1 then
		return
	end
	local lGemStone = g_ItemCtrl:GetGemStoneList(self.m_SelectedColor, true, 1, self.m_MaxGrade, nil, nil, true)

	local iMax = math.max(self.m_GemStoneItemGrid:GetCount(), #lGemStone)
	local bIsEmpty = #lGemStone == 0

	for i=1,iMax do
		local oBox = self.m_GemStoneItemGrid:GetChild(i)
		if not oBox then
			oBox = self:CreateGemStoneIemBox()
			self.m_GemStoneItemGrid:AddChild(oBox)
		end
		local oItem = lGemStone[i]
		self:UpdateGemStoneItemBox(oBox, oItem)
	end
end

function CForgeInlayItemListBox.CreateGemStoneIemBox(self)
	local oBox = self.m_GemStoneItemClone:Clone()
	oBox.m_ItemBox = oBox:NewUI(1, CItemBaseBox)
	oBox.m_NameL = oBox:NewUI(2, CLabel)
	oBox.m_AttrL = oBox:NewUI(3, CLabel)
	oBox.m_BindSpr = oBox:NewUI(4, CSprite)
	oBox:AddUIEvent("click", callback(self, "OnClickGemStoneItem"))
	return oBox
end

function CForgeInlayItemListBox.UpdateGemStoneItemBox(self, oBox, oItem)
	oBox:SetActive(oItem ~= nil)
	if not oItem then
		return
	end
	oBox.m_Item = oItem
	oBox.m_ItemBox:SetBagItem(oItem)
	local sName = oItem:GetItemName()
	oBox.m_NameL:SetText(sName)
	oBox.m_BindSpr:SetActive(oItem:IsBinding())
	--TODO:魂石属性
	local lAttr = oItem:GetGemStoneAttr()
	local sAttr = ""
	for i,dAttr in ipairs(lAttr) do
		sAttr = string.format("%s%s +%d\n", sAttr, dAttr.attrname, dAttr.value)
	end
	oBox.m_AttrL:SetText(sAttr)
end

-----------------------click event------------------------------
function CForgeInlayItemListBox.OnClickCompose(self)
	CItemComposeView:ShowView(function(oView)
		--TODO:跳转到合成界面
		oView:JumpToGemStoneCompose(nil)
	end)
end

function CForgeInlayItemListBox.OnClickSwitchStone(self, iColor)
	self.m_SelectedColor = iColor
	-- self.m_GemStoneBtnGrid:GetChild(iColor):ForceSelected(true)
	for i=1,3 do
		self.m_SelSprs[i]:SetActive(i == iColor)
		local oBtn = self.m_GemStoneBtnGrid:GetChild(i)
		oBtn:SetAlpha(i == iColor and 1 or 0.5)
	end
	self:RefreshItemGrid()
end

function CForgeInlayItemListBox.OnClickGemStoneItem(self, oBox)
	if self.m_SelectedCb then
		self.m_SelectedCb(oBox)
	end
end

return CForgeInlayItemListBox

