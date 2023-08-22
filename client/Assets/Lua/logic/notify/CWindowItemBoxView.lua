CWindowItemBoxView = class("CWindowItemBoxView", CViewBase)

function CWindowItemBoxView.ctor(self, cb)
	CViewBase.ctor(self,"UI/Notify/WindowItemBoxView.prefab", cb)

	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"

	-- 传入参数
	self.m_ComfirmCb = nil
	self.m_ClkItemCb = nil
	self.m_ShowSelSpr = false

	self.m_CurItem = nil
end

function CWindowItemBoxView.OnCreateView(self)
	self.m_Title = self:NewUI(1, CLabel)
	self.m_ItemBoxClone = self:NewUI(2, CBox)
	self.m_GetBtn = self:NewUI(3, CButton)
	self.m_CloseBtn = self:NewUI(4, CButton)
	self.m_ScrollView = self:NewUI(5, CScrollView)
	self.m_Grid = self:NewUI(6, CGrid)
	self.m_Tip = self:NewUI(7, CLabel)

	self:InitContent()
end

function CWindowItemBoxView.InitContent(self)
	self.m_ItemBoxClone:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_GetBtn:AddUIEvent("click", callback(self, "OnClickComfirm"))
end

--[[
args
comfirmCb: 确定回调(没有的话默认隐藏确定按钮) arg: 当前选择物品sid
comfirmText: 确定按钮文本
clkItemCb: 点击物品图标回调，arg: 物品sid
showSelSpr: 是否显示物品图标选择框
title / desc: 标题 / 描述
items: {[1] = {sid = 1001, amount = 100} ...}
]]
function CWindowItemBoxView.SetViewArgs(self, args)
	self.m_ComfirmCb = args.comfirmCb
	self.m_ClkItemCb = args.clkItemCb
	self.m_ShowSelSpr = args.showSelSpr -- 显示选中框
	self.m_Title:SetText(args.title or "")
	self.m_Tip:SetText(args.desc or "")
	if args.color then
		self.m_Tip:SetColor(args.color)
	end
	self.m_GetBtn:SetText(args.comfirmText or "确定")
	if self.m_ComfirmCb then
		self.m_GetBtn:SetActive(true)
	else
		self.m_GetBtn:SetActive(false)
		self.m_Tip:SetLocalPos(Vector3.New(0, -102, 0))
	end
	self:RefreshItems(args.items)
end

function CWindowItemBoxView.RefreshItems(self, itemList)
	self.m_Grid:HideAllChilds()
	for i, v in ipairs(itemList) do
		local dItem = table.copy(v)
		dItem.idx = i
		local oItem = self.m_Grid:GetChild(i)
		if not oItem then
			oItem = self.m_ItemBoxClone:Clone()
			oItem.m_IconSp = oItem:NewUI(1, CSprite)
			oItem.m_CountLbl = oItem:NewUI(2, CLabel)
			oItem.m_QualitySp = oItem:NewUI(3, CSprite)
			oItem.m_SelSpr = oItem:NewUI(4, CSprite)
			oItem.m_IconSp:AddUIEvent("click", callback(self, "OnClickItemBox", dItem, oItem))
			self.m_Grid:AddChild(oItem)
		end
		oItem:SetActive(true)
		local data = DataTools.GetItemData(dItem.sid)
		oItem.m_IconSp:SpriteItemShape(data.icon) 
		oItem.m_CountLbl:SetText(dItem.amount)
		oItem.m_QualitySp:SetItemQuality(data.quality or 0)
		oItem.m_SelSpr:SetActive(self.m_ShowSelSpr and true or false)
		if i == 1 then
			self.m_CurItem = dItem
			oItem.m_IconSp:SetSelected(true)
			if self.m_ClkItemCb then
				self.m_ClkItemCb(self.m_CurItem)
			end
		end
	end
	self.m_Grid:Reposition()
end

function CWindowItemBoxView.OnClickItemBox(self, item, oItem)
	local args = {
        widget = oItem
    }
    if item.isMarkItemData then
    	g_WindowTipCtrl:SetWindowItemTip(item.sid, args, nil, nil, item.item)
    else
    	g_WindowTipCtrl:SetWindowItemTip(item.sid, args)
    end
    self.m_CurItem = item
	if self.m_ClkItemCb then
		self.m_ClkItemCb(item)
	end
end

function CWindowItemBoxView.OnClickComfirm(self)
	if self.m_ComfirmCb then
		self.m_ComfirmCb(self.m_CurItem)
	end
	self:OnClose()
end

return CWindowItemBoxView