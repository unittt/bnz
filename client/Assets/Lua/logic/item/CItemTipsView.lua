local CItemTipsView = class("CItemTipsView", CViewBase)

function CItemTipsView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemTipsView.prefab", cb)
	self.m_DepthType = "Dialog"
	-- printerror("item tips view --------------------- ")
end

function CItemTipsView.OnCreateView(self)
	self.m_MainBox = self:NewUI(1, CItemTipsMainBox, true, function () self:CloseView() end)
	self.m_ExtraBox = self:NewUI(2, CItemExtraBox)
	self.m_GainWayBox = self:NewUI(3, CItemGainBox)
	self.m_EquipBox = self:NewUI(4, CItemEquipBox)
	self.m_GiftSelBox = self:NewUI(5, CItemGiftSelBox)
	self.m_SummonEquipBox = self:NewUI(6, CSummonEquipTipBox)
	self.m_Container = self:NewUI(7, CWidget)
	self.m_RingBox = self:NewUI(8, CItemRingBox)
	self.m_WenShiBox = self:NewUI(9, CItemWenShiBox)

	g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))

	self.m_ActiveCfg = {
		["main"] 		= {true, false, false, false, false, false, false, false},
		["extra"] 	 	= {true, true, false, false, false, false, false, false},
		["gainway"]	 	= {true, false, true, false, false, false, false, false},
		["equip"] 	 	= {false, false, false, true, false, false, false, false},
		["gift"] 		= {true, false, false, false, true, false, false, false},
		["summonequip"] = {false, false, false, false, false, true, false, false},
		["ring"]        = {false, false, false, false, false, false, true, false},
		["wenshi"]      = {false, false, false, false, false, false, false, true},
	}
	self.m_Boxs = { 

		[1] = self.m_MainBox,
		[2] = self.m_ExtraBox,
		[3] = self.m_GainWayBox,
		[4] = self.m_EquipBox,
		[5] = self.m_GiftSelBox,
		[6] = self.m_SummonEquipBox,
		[7] = self.m_RingBox,
		[8] = self.m_WenShiBox,
	}
	self.m_ItemInfo = nil
	g_ItemTempBagCtrl:AddCtrlEvent(self:GetInstanceID(),callback(self,"CloseView"))
end
--装备回收
function CItemTipsView.ItemRecovery(self, id)
	-- body
	self:InitBoxActive("equip")
	self.m_EquipBox:SetRecoveryItem(id)
end
--临时背包
function CItemTipsView.TempBag(self, oItem) 
	self.m_ItemInfo = oItem
	if  self.m_ItemInfo:IsEquip() then
		self:InitBoxActive("equip")
		self.m_EquipBox:TempBag(oItem)
	elseif self.m_ItemInfo:IsSummonEquip() then
		self:InitBoxActive("summonequip")
		self.m_SummonEquipBox:TempBag(oItem)
	else
		self:InitBoxActive("main")
		self.m_MainBox:SetItemTips(oItem)
	end
		
end

function CItemTipsView.SetRingItem(self, itemdata)
	self.m_ItemInfo = itemdata
	self:InitBoxActive("ring")
	self.m_RingBox:InitRingBox(self.m_ItemInfo)
end

function CItemTipsView.SetItem(self, citem, hitExtend)
	self.m_ItemInfo = citem
	if self.m_ItemInfo:IsEquip() then
		self:OpenEquipView()
	elseif self.m_ItemInfo:IsSummonEquip() then
		self:OpenSummonEquipView()
	elseif self.m_ItemInfo:IsWenShi() then 
		self:OpenWenShiView()
	else
		self:SetItemInfo(hitExtend)
	end
end

function CItemTipsView.SetItemInfo(self, hitExtend)
	if self.m_EquipBox.m_RelativeView then
	   self.m_EquipBox.m_RelativeView:SetActive(false)
	end
	self:InitBoxActive("main")
	self.m_MainBox:SetInitBox(self.m_ItemInfo, hitExtend)
end

function CItemTipsView.OpenExtraView(self)
	self:InitBoxActive("extra")
	self.m_ExtraBox:SetInitBox(self.m_ItemInfo)
	self:CalculatePos(false)
end

function CItemTipsView.OpenGainWayView(self)
	if g_KuafuCtrl:IsInKS(true) then
		return
	end

	self:InitBoxActive("gainway")

	local screenWidth = UnityEngine.Screen.width
	local screenHeight = UnityEngine.Screen.height
	local oMainBoxScreenPos = g_CameraCtrl:GetUICamera():WorldToScreenPoint(self.m_MainBox.m_ContentBg:GetPos())
	local oMainBoxWidth = self.m_MainBox.m_ContentBg:GetWidth()
	local oMainBoxHeight = self.m_MainBox.m_ContentBg:GetHeight()
	local oGainBoxWidth = self.m_GainWayBox.m_ContentBg:GetWidth()
	local oGainBoxHeight = 362--self.m_GainWayBox.m_ContentBg:GetHeight()

	-- printc("11111111", oMainBoxScreenPos.x, "  ", oMainBoxWidth, "  ", oGainBoxWidth, "  ", screenWidth)

	self.m_GainWayBox.m_ContentBg:SetAnchorTarget(self.m_MainBox.m_ContentBg.m_GameObject, 0, 0, 0, 0)
	self.m_GainWayBox.m_ContentBg:SetAnchor("leftAnchor", 0, 1)
	self.m_GainWayBox.m_ContentBg:SetAnchor("topAnchor", 0, 1)
    self.m_GainWayBox.m_ContentBg:SetAnchor("bottomAnchor", -87, 0)
    self.m_GainWayBox.m_ContentBg:SetAnchor("rightAnchor", 433, 1)
	self.m_GainWayBox.m_ContentBg:ResetAndUpdateAnchors()

	if not self.m_Container:IsInRect(self.m_GainWayBox.m_ContentBg.m_UIWidget.worldCorners[3]) then
		self.m_GainWayBox.m_ContentBg:SetAnchorTarget(self.m_MainBox.m_ContentBg.m_GameObject, 0, 0, 0, 0)
		self.m_GainWayBox.m_ContentBg:SetAnchor("leftAnchor", 0, 1)
		self.m_GainWayBox.m_ContentBg:SetAnchor("topAnchor", 0, 1)
	    self.m_GainWayBox.m_ContentBg:SetAnchor("bottomAnchor", -87, 0)
	    self.m_GainWayBox.m_ContentBg:SetAnchor("rightAnchor", 433, 1)
		self.m_GainWayBox.m_ContentBg:ResetAndUpdateAnchors()

		self.m_GainWayBox.m_ContentBg.m_UIWidget:SetAnchor(self.m_GameObject)
		-- printc("222222", self.m_GainWayBox.m_CheckWidget.m_UIWidget.leftAnchor.absolute)

		self.m_GainWayBox.m_ContentBg:SetAnchor("leftAnchor", -433, 1)
		self.m_GainWayBox.m_ContentBg:SetAnchor("topAnchor", 0, 1)
	    self.m_GainWayBox.m_ContentBg:SetAnchor("bottomAnchor", oGainBoxHeight, 0)
	    self.m_GainWayBox.m_ContentBg:SetAnchor("rightAnchor", 0, 1)
		self.m_GainWayBox.m_ContentBg:ResetAndUpdateAnchors()

		local offsetY = self.m_GainWayBox.m_ContentBg:GetLocalPos().y - self.m_MainBox.m_ContentBg:GetLocalPos().y
		self.m_GainWayBox.m_ContentBg:SetAnchor("leftAnchor", -433, 1)
		self.m_GainWayBox.m_ContentBg:SetAnchor("topAnchor", -offsetY, 1)
	    self.m_GainWayBox.m_ContentBg:SetAnchor("bottomAnchor", -offsetY-oGainBoxHeight, 1)
	    self.m_GainWayBox.m_ContentBg:SetAnchor("rightAnchor", 0, 1)
		self.m_GainWayBox.m_ContentBg:ResetAndUpdateAnchors()

		self.m_MainBox.m_Transform.localPosition = Vector3.New(self.m_GainWayBox.m_ContentBg:GetLocalPos().x - oGainBoxWidth/2 - oMainBoxWidth/2,
		self.m_MainBox.m_Transform.localPosition.y, self.m_MainBox.m_Transform.localPosition.z)
	end

	self.m_GainWayBox:SetInitBox(self.m_ItemInfo)
	-- self:CalculatePos(true)
end

function CItemTipsView.OpenWenShiView(self, oItem, typeInfo, hitExtend)

	if typeInfo == 1 then
		self.m_WenShiBox:BagPutInStore(oItem ,hitExtend)
	else
		self.m_WenShiBox:WHPutInBackBox(oItem ,hitExtend)
	end

	self:InitBoxActive("wenshi")
	oItem = oItem or self.m_ItemInfo
	self.m_WenShiBox:SetInfo(oItem)
	
end

function CItemTipsView.OpenEquipView(self ,oItem ,typeInfo, hitExtend)
	if self.m_EquipBox.m_RelativeView then
	   return
	end
	if  not self.m_ItemInfo then
		self.m_ItemInfo = oItem
	end 

	if typeInfo == 1 then
		self.m_EquipBox:BagPutInStore(oItem ,hitExtend)
	else
		self.m_EquipBox:WHPutInBackBox(oItem ,hitExtend)
	end
	self:InitBoxActive("equip")
	self.m_EquipBox:InitRelativeView()
	self.m_EquipBox:SetInitBox(self.m_ItemInfo)
end

function CItemTipsView.OpenGiftSelBox(self)
	self:InitBoxActive("gift")
	self.m_GiftSelBox:SetInitBox(self.m_ItemInfo)
end

-- btnType: 0 or nil:跳转  1:更换  2:装备
function CItemTipsView.OpenSummonEquipView(self, oItem, typeInfo, hitExtend, btnType)
	if not self.m_ItemInfo then
		self.m_ItemInfo = oItem
	end
	if typeInfo == 1 then
		self.m_SummonEquipBox:BagPutInStore(oItem ,hitExtend)
	else
		self.m_SummonEquipBox:WHPutInBackBox(oItem ,hitExtend)
	end
	self:InitBoxActive("summonequip")
	self.m_SummonEquipBox:SetInitBox(self.m_ItemInfo, btnType)
end

function CItemTipsView.InitBoxActive(self, sConfig)
	local lConfig = self.m_ActiveCfg[sConfig]
	for i,oBox in ipairs(self.m_Boxs) do
		oBox:SetActive(lConfig[i])
	end
end

function CItemTipsView.CalculatePos(self, direction)
	local pos_x = (direction and -235) or -235
	self:SetLocalPos(Vector3.New(pos_x, 0, 0))
end

function CItemTipsView.HideBtns(self)
	if self.m_ItemInfo:IsEquip() then
		self.m_EquipBox:HideButton()
		self.m_EquipBox:HideRelativeView()
	elseif self.m_ItemInfo:IsSummonEquip() then
		self.m_SummonEquipBox:HideButton()
	else
		self.m_MainBox:HideButton()
	end
end

function CItemTipsView.ShowGainWayBtn(self)
	if not self.m_ItemInfo:GetCValueByKey("gainWayIdStr") or #self.m_ItemInfo:GetCValueByKey("gainWayIdStr") == 0 then
		self:HideBtns()
		return
	end
	if self.m_ItemInfo:IsEquip() then
		self.m_EquipBox:ShowGainWayBtn()
		self.m_MainBox:ShowGainWayBtn()
	else
		self.m_MainBox:ShowGainWayBtn()
	end
end

-- 获取面板全部用物品面板
function CItemTipsView.ShowGainWayView(self, oItem, hitExtend)
	self.m_ItemInfo = oItem
	self:SetItemInfo(hitExtend)
	self:ShowGainWayBtn()
end

return CItemTipsView