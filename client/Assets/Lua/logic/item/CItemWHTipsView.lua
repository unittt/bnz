local CItemWHTipsView = class("CItemWHTipsView", CViewBase)

function CItemWHTipsView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemWHTipsView.prefab", cb)
end

function CItemWHTipsView.OnCreateView(self)
	self.m_CItem = nil

	self.m_MainBox = self:NewUI(1, CItemWHTipsMainBox, false, function() self:CloseView() end)
	self.m_MainBox:SetActive(false)
end

function CItemWHTipsView.SetItemData(self, citem, btntype)

	self.m_CItem = citem
	self.m_WHBtnType = btntype
	
	self.m_PosList = {
		[define.Item.CellType.BagCell] = {-253, 184},
		[define.Item.CellType.WHCell] = {217, 184},
	}
	self:InitView()
end

function CItemWHTipsView.InitView(self)	
	if self.m_CItem:IsEquip() then
		g_WindowTipCtrl:ItemWHEquipShow(self.m_CItem,self.m_WHBtnType,true)
		self:CloseView()
	elseif self.m_CItem:IsSummonEquip() then
		g_WindowTipCtrl:ItemWHSummonEquipShow(self.m_CItem,self.m_WHBtnType,true)
		self:CloseView()
	elseif self.m_CItem:IsWenShi() then
		g_WindowTipCtrl:ItemWHWenShiShow(self.m_CItem,self.m_WHBtnType,true)
		self:CloseView()
	else
		self.m_MainBox:SetActive(true)
		self.m_MainBox:SetInitBox(self.m_CItem, self.m_WHBtnType)
		self.m_MainBox:OnShowBox(self)
		local vpos = self.m_PosList[self.m_WHBtnType]
		self.m_MainBox:SetLocalPos(Vector3.New(vpos[1], vpos[2], 0))
		g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
	end
end

return CItemWHTipsView