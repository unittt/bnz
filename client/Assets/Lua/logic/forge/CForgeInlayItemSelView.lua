local CForgeInlayItemSelView = class("ForgeInlayItemSelView", CViewBase)

function CForgeInlayItemSelView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Forge/ForgeInlayItemSelView.prefab", cb)
	--界面设置
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "ClickOut"
end

function CForgeInlayItemSelView.OnCreateView(self)
	-- self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ComposeBtn = self:NewUI(1, CButton)
	self.m_GemItemScroll = self:NewUI(2, CScrollView)
	self.m_GemStoneItemGrid = self:NewUI(3, CGrid)
	self.m_GemStoneItemClone = self:NewUI(4, CBox)
	self.m_ContentW = self:NewUI(5, CWidget)
	self.m_EmptyTex = self:NewUI(6, CTexture)

	self:InitContent()
end

function CForgeInlayItemSelView.InitContent(self)
	self.m_GemStoneItemClone:SetActive(false)
	self.m_ComposeBtn:AddUIEvent("click", callback(self, "OnClickCompose"))
	-- g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
end

function CForgeInlayItemSelView.SetSelectCallback(self, cb)
	self.m_SelectedCb = cb
end

function CForgeInlayItemSelView.SetSelGemstoneInfo(self, iGrade, iColor, iHoleIndex)
	self.m_MaxGrade = iGrade
	self.m_SelectedColor = iColor

	self:ResetPos(iHoleIndex)
	self:RefreshItemGrid()
end

function CForgeInlayItemSelView.ResetPos(self, iHoleIndex)
	local lPos = {Vector2.New(-50, -34), Vector2.New(-175, -34), Vector2.New(90, -34)}
	self.m_ContentW:SetLocalPos(lPos[iHoleIndex])
end

-----------------------refresh ui-------------------------------
function CForgeInlayItemSelView.RefreshItemGrid(self)
	--TODO:获取魂石列表
	self.m_GemStoneItemGrid:SetActive(self.m_SelectedColor ~= -1)
	if self.m_SelectedColor == -1 then
		return
	end

	local lOverLv = {}
	local lOtherColor = {}
	local lEquipGemStone = g_ItemCtrl:GetGemStoneList(self.m_SelectedColor, true, 1, self.m_MaxGrade, nil, nil, true, true)
	local iMaxEquipLimit = DataTools.GetGemStoneMaxEquipLimit()

	if self.m_MaxGrade < iMaxEquipLimit then
		lOverLv = g_ItemCtrl:GetGemStoneList(self.m_SelectedColor, true, self.m_MaxGrade + 1, iMaxEquipLimit, nil, nil, true, true)
	end

	local lColor = DataTools.GetRelateGemStoneList(self.m_SelectedColor)
	local dFiliateColor = {}
	for i,iColor in ipairs(lColor) do
		dFiliateColor[iColor] = true
	end
	for iColor=1,6 do
		if iColor ~= self.m_SelectedColor and not dFiliateColor[iColor] then
			local list = g_ItemCtrl:GetGemStoneList(iColor, false, 1, iMaxEquipLimit, nil, nil, true, true)
			if #list > 0 then
				table.insert(lOtherColor, list)
			end
		end
	end

	local iGemStoneCnt = #lOverLv + #lEquipGemStone 
	for i,v in ipairs(lOtherColor) do
		iGemStoneCnt = iGemStoneCnt + #v
	end

	local iMax = math.max(self.m_GemStoneItemGrid:GetCount(), iGemStoneCnt)
	local bIsEmpty = iGemStoneCnt == 0

	self.m_EmptyTex:SetActive(bIsEmpty)
	if bIsEmpty then
		self.m_ComposeBtn:SetText("获取")
		self.m_ComposeBtn:AddUIEvent("click", callback(self, "OnClickItemGain"))
	end

	local function Push(list, status)
		if list ~= nil and list[1] ~= nil then
			local data = list[1]
			data.m_GemstoneStatus = status
			table.remove(list, 1)
			return data
		end
	end

	local function GetGemStone()
		local oItem = Push(lEquipGemStone, 1) or Push(lOverLv, 2) or Push(lOtherColor[1], 3) or Push(lOtherColor[2], 3)
		return oItem
	end

	for i=1,iMax do
		local oBox = self.m_GemStoneItemGrid:GetChild(i)
		if not oBox then
			oBox = self:CreateGemStoneIemBox()
			self.m_GemStoneItemGrid:AddChild(oBox)
		end
		local oItem = GetGemStone()
		self:UpdateGemStoneItemBox(oBox, oItem)
	end
end

function CForgeInlayItemSelView.CreateGemStoneIemBox(self)
	local oBox = self.m_GemStoneItemClone:Clone()
	oBox.m_ItemBox = oBox:NewUI(1, CItemBaseBox)
	oBox.m_NameL = oBox:NewUI(2, CLabel)
	oBox.m_AttrL = oBox:NewUI(3, CLabel)
	oBox.m_BindSpr = oBox:NewUI(4, CSprite)
	oBox.m_BgSpr = oBox:NewUI(5, CSprite)
	oBox:AddUIEvent("click", callback(self, "OnClickGemStoneItem"))
	return oBox
end

function CForgeInlayItemSelView.UpdateGemStoneItemBox(self, oBox, oItem)
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

	if oItem.m_GemstoneStatus > 1 then
		local vGrey = Color.RGBAToColor("5c6163")
		oBox.m_NameL:SetColor(vGrey)
		oBox.m_AttrL:SetColor(vGrey)
		
		vGrey = Color.RGBAToColor("e6e6e6")
		local vEffectColor = Color.RGBAToColor("5c6163")
		oBox.m_ItemBox.m_AmountLabel:SetColor(vGrey)
		oBox.m_ItemBox.m_AmountLabel:SetEffectColor(vEffectColor)

		oBox.m_BgSpr:SetGrey(true)
		oBox.m_BindSpr:SetGrey(true)
		oBox.m_ItemBox.m_IconSprite:SetGrey(true)
		oBox.m_ItemBox.m_BorderSprite:SetGrey(true)
	end
end

-----------------------click event------------------------------
function CForgeInlayItemSelView.OnClickCompose(self)
	CItemComposeView:ShowView(function(oView)
		--TODO:跳转到合成界面
		oView:JumpToGemStoneCompose(nil)
	end)
	self:CloseView()
end


function CForgeInlayItemSelView.OnClickGemStoneItem(self, oBox)
	if oBox.m_Item.m_GemstoneStatus == 2 then
		local iGemStoneLv = oBox.m_Item:GetSValueByKey("hunshi_info").grade
		local iGrade = DataTools.GetGemStoneEquipGradeLimit(iGemStoneLv)
		g_NotifyCtrl:FloatMsg(string.format("该宝石只能由%d级以上的装备镶嵌", iGrade))
		return
	end
	if oBox.m_Item.m_GemstoneStatus == 3 then
		g_NotifyCtrl:FloatMsg("宝石颜色与镶嵌孔不符")
		return
	end
	if self.m_SelectedCb then
		self.m_SelectedCb(oBox)
	end
	self:CloseView()
end

function CForgeInlayItemSelView.OnClickItemGain(self)
	g_WindowTipCtrl:SetWindowGainItemTip(11045)
	self:CloseView()
end

return CForgeInlayItemSelView
