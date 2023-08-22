local CWindowSelectItemView = class("CWindowSelectItemView", CViewBase)

function CWindowSelectItemView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Notify/WindowSelectItemView.prefab", cb)
	self.m_DepthType = "Fourth"
	self.m_ExtendClose = "Black"

	self.m_SureCB = nil
	self.m_CurItem = nil
end

function CWindowSelectItemView.OnCreateView(self)
	-- body
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_SureBtn  = self:NewUI(2, CButton)
	self.m_SureLab  = self:NewUI(3, CLabel)
	self.m_ScrollV  = self:NewUI(4, CScrollView)
	self.m_Grid     = self:NewUI(5, CGrid)
	self.m_BoxClone = self:NewUI(6, CBox)
	self.m_BoxClone:SetActive(false)
	self.m_SVArea   = self:NewUI(7, CWidget)
	self.m_TitleLab = self:NewUI(8, CLabel)
	self.m_DseLab   = self:NewUI(9, CLabel)
	self.m_DefaultIdx = 1
	self:InitContent()
end

function CWindowSelectItemView.InitContent(self)
	-- body
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_SureBtn:AddUIEvent("click", callback(self, "OnSureBtn"))
end

function CWindowSelectItemView.SetWindowInfo(self, args)
	-- body
	self.m_DefaultIdx =  args.selectidx or 1
	self.m_SureCB = args.surecb
	self.m_TitleLab:SetText(args.title)
	self.m_DseLab:SetText(args.des)
	self.m_ItemList = args.itemlist
	self.m_Grid:Clear()
	local list = self.m_Grid:GetChildList()
	for i,v in ipairs(self.m_ItemList) do
		local box = nil
		if i>#list then
			box = self.m_BoxClone:Clone()
			box:SetActive(true)
			self.m_Grid:AddChild(box)
			box.icon = box:NewUI(1, CSprite)
			box.border = box:NewUI(2, CSprite)
			box.amount = box:NewUI(3, CLabel)
			box.tag    = box:NewUI(4, CSprite)
		else
			box = list[i]
		end
		local dItem = DataTools.GetItemData(v.sid)
		box.icon:SpriteItemShape(dItem.icon)
		box.icon:AddUIEvent("click", callback(self, "OnItemClick", box.icon, v.sid))

		box.tag:AddUIEvent("click", callback(self, "OnTagClick", i))
		box.tag:SetGroup(self:GetInstanceID())

		box.border:SetItemQuality(dItem.quality)
		box.amount:SetText(v.amount)
	end
	self.m_Grid:GetChild(self.m_DefaultIdx).tag:SetSelected(true)

	local isHideBtn = args.hideBtn
	if isHideBtn then
		self.m_SureBtn:SetActive(false)
	end    
end

function CWindowSelectItemView.OnSureBtn(self)
	-- body
	if self.m_SureCB then
		self.m_SureCB(self.m_DefaultIdx, self.m_ItemList[self.m_DefaultIdx])
		self:OnClose()
	end
end

function CWindowSelectItemView.OnItemClick(self, icon, sid)
	-- body
	local args = {
        widget = icon
    }
    g_WindowTipCtrl:SetWindowItemTip(sid, args)
end

function CWindowSelectItemView.OnTagClick(self, i)
	-- body
	self.m_DefaultIdx = i
end

return CWindowSelectItemView