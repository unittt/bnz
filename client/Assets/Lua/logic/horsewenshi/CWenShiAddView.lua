local CWenShiAddView = class("CWenShiAddView", CViewBase)

function CWenShiAddView.ctor(self, cb)

	CViewBase.ctor(self, "UI/Horse/WenShiAddView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "sub"
    self.m_ExtendClose = "Black"

    self.m_Cb = nil
    self.m_WenShiDataList = nil

end

function CWenShiAddView.OnCreateView(self)

    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_Grid = self:NewUI(2, CGrid)
    self.m_WenShiItem = self:NewUI(3, CBox)
    self.m_ConfirmBtn = self:NewUI(4, CSprite)

    self:InitContent()

end

function CWenShiAddView.InitContent(self)

	 self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	 self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnClickConfirmBtn"))

end


function CWenShiAddView.SetData(self, wenshiDataList, cb)
 
	self.m_WenShiDataList = wenshiDataList
	self.m_Cb = cb

	self:RefresnWenShiItems()

end

function CWenShiAddView.InitWenShiItem(self, item)
	
	item.icon = item:NewUI(1, CSprite)
	item.bg = item:NewUI(2, CSprite)
	item.collider = item:NewUI(3, CWidget)
	item.lv = item:NewUI(4, CLabel)
	item.collider:AddUIEvent("click", callback(self, "OnClickWenShiItem", item))
	return item

end

function CWenShiAddView.RefresnWenShiItems(self)
	
	if not self.m_WenShiDataList then
		return
	end

	local sortList = {}
	for k, v in pairs(self.m_WenShiDataList) do 
		table.insert(sortList, v)
	end

	-- red blue yellow
	table.sort(sortList, function (a, b)
		if a.colorType < b.colorType then 
			return true	
		elseif a.colorType == b.colorType then 
			if a.lv > b.lv then 
				return true
			else
				return false
			end 
		else
			return false
		end   
	end)

	table.insert(sortList, 1, {})

	for k, v in ipairs(sortList) do 
		local item = self.m_Grid:GetChild(k)
		if not item then 
			item = self.m_WenShiItem:Clone()
			item:SetActive(true)
			self.m_Grid:AddChild(item)
		end 
		item:SetActive(true)
		item:SetName(tostring(k))
		item = self:InitWenShiItem(item)
		if next(v) then 
			item.info = v
			item.icon:SpriteItemShape(v.icon)
			item.icon:SetActive(true)
			item.bg:SetActive(false)
			item.lv:SetActive(true)
			item.lv:SetText(v.lv .. "级")

		else
			item.icon:SetActive(false)
			item.bg:SetActive(true)
			item.lv:SetActive(false)
		end 

	end 

end

function CWenShiAddView.OnClickWenShiItem(self, item)
	
	local info = item.info
	if info then 
		self.m_CurWenShiInfo = info
		self:ShowTip()
	else
		CEcononmyMainView:ShowView(function ( oView )
			oView:ShowSubPageByIndex(oView:GetPageIndex("Guild"))
			oView:JumpToTargetItem(13601)
		end)
		self:OnClose()
	end 	

end

function CWenShiAddView.ShowTip(self)
	
	CWenShiTipView:ShowView(function ( oView )
		oView:SetInfo(self.m_CurWenShiInfo)
		oView:HideBtn()
	end)

end

function CWenShiAddView.OnClickConfirmBtn(self)
	
	if self.m_Cb and self.m_CurWenShiInfo then 
		self.m_Cb(self.m_CurWenShiInfo)
		self:OnClose()
	else
		g_NotifyCtrl:FloatMsg("请选择纹饰")
	end  

end


return CWenShiAddView