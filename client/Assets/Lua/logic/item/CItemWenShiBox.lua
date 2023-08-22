local CItemWenShiBox = class("CItemWenShiBox", CBox)

function CItemWenShiBox.ctor(self, obj)

	CBox.ctor(self, obj)
	self.m_Icon = self:NewUI(1, CSprite)
	self.m_Name = self:NewUI(2, CLabel)
	self.m_Lv = self:NewUI(3, CLabel)
	self.m_Score = self:NewUI(4, CLabel)
	self.m_Last = self:NewUI(5, CLabel)
	self.m_Attr = self:NewUI(6, CBox)
	self.m_RightBtnBox = self:NewUI(7, CBox)
	self.m_LeftBtnBox = self:NewUI(8, CBox)
	self.m_FeatureTable = self:NewUI(9, CTable)
	self.m_FeatureBtnBox = self:NewUI(10, CBox)
	self.m_PreViewBtn = self:NewUI(11, CSprite)
	self.m_PreViewBox = self:NewUI(12, CBox)
	self.m_AttrGrid = self:NewUI(13, CGrid)
	self.m_PreAttrItem = self:NewUI(14, CBox)
	self.m_PreGrid = self:NewUI(15, CGrid)
	self.m_Quality = self:NewUI(16, CSprite)
	self.m_BandDing = self:NewUI(17, CSprite)
	self.m_ButtonBox = self:NewUI(18, CItemButtonBox)
	self.m_Des = self:NewUI(19, CLabel)
	self.m_PickUpBtn = self:NewUI(20,CButton)
	self.m_BtnInfo = self:NewUI(21, CLabel)

	self.m_FeatureBtnList = {
		[1] = { name = "洗练", cb = "OnClickWashBtn"},
		[2] = { name = "融合", cb = "OnClickFusionBtn"},
		[3] = { name = "分解", cb = "OnClickFusionDecomposeBtn"}
	}

	self.m_ExpandBtn = false
	self.m_ShowPreViewBox = false

	self.m_PreViewBtn:AddUIEvent("click", callback(self, "OnClickPreViewBtn"))

end

function CItemWenShiBox.SetInfo(self, oItem)
	
	self.m_Item = oItem
	self:RefreshTop()
	self:RefreshAttr()
	--self:RefreshBtns()
	--self:CreateFeatureBtns()
	self.m_ButtonBox:SetInitBox(oItem)
	self.m_ButtonBox:ShowCenterBtn(false)

end

function CItemWenShiBox.RefreshTop(self)
	
	local icon = self.m_Item:GetCValueByKey("icon")
	local name = self.m_Item:GetCValueByKey("name")
	local quality = self.m_Item:GetCValueByKey("quality")
	local bandding = self.m_Item:GetSValueByKey("key")
	local des = self.m_Item:GetCValueByKey("description")
	self.m_Icon:SpriteItemShape(icon)
	local sName = string.format(data.colorinfodata.ITEM[quality].color, name)
	self.m_Name:SetRichText(sName, nil, nil, true)
	self.m_Quality:SetItemQuality(quality)
	local equipInfo = self.m_Item:GetEquipInfo()
	if equipInfo then 
		local score = equipInfo.score
		local last = equipInfo.last
		local attrList = equipInfo.attach_attr
		local lv = equipInfo.grow_level
		self.m_Score:SetText(score)
		self.m_Last:SetText(last)
		self.m_Lv:SetText(lv)
		self.m_BandDing:SetActive(bandding == 1)
	end 

	self.m_Des:SetText(des)

end

function CItemWenShiBox.RefreshAttr(self)
	
	self.m_AttrGrid:HideAllChilds()
	local equipInfo = self.m_Item:GetEquipInfo()
	local attrNameConfig = data.attrnamedata.DATA
	if equipInfo then 
		local attrList = equipInfo.attach_attr
		table.print(attrList)
		for k, v in ipairs(attrList) do 
 			local attrItem = self.m_AttrGrid:GetChild(k)
 			if not attrItem then 
 			    attrItem = self.m_Attr:Clone()
 			    attrItem:SetActive(true)
 			    self.m_AttrGrid:AddChild(attrItem)
 			end 
 			local data = attrNameConfig[v.key]
 			local name = data.name
 			local value = v.value / 100
 			attrItem:SetActive(true)
 			attrItem.name = attrItem:NewUI(1, CLabel)
 			attrItem.value = attrItem:NewUI(2, CLabel)

 			if g_AttrCtrl:IsRatioAttr(v.key) then 
 				value = value .. "%"
 			end 
 			attrItem.name:AlignmentWidth(name)
 			attrItem.name:SetText(name)
 			attrItem.value:SetText("+" .. value)
		end 

	end

end

function CItemWenShiBox.RefreshBtns(self)

	self:RefreshRightBtn()
	self:RefreshLeftBtn()

end


function CItemWenShiBox.BagPutInStore(self ,oItem ,hitExtend)

	if hitExtend then
		self.m_PickUpBtn:SetActive(true)
		self.m_ButtonBox:SetActive(false)
		self.m_BtnInfo:SetText("存入仓库")
		self.m_PickUpBtn:AddUIEvent("click",callback(self, "PutInStore"))
	end

end

function CItemWenShiBox.PutInStore(self,oItem)

	g_ItemCtrl.C2GSWareHouseWithStore(g_ItemCtrl.m_RecordWHIndex, self.m_Item.m_ID)
	local CItemTipsView = CItemTipsView:GetView()
	CItemTipsView:CloseView()

end

function CItemWenShiBox.PutInBackBox(self,oItem)

	g_ItemCtrl.C2GSWareHouseWithDraw(g_ItemCtrl.m_RecordWHIndex, oItem:GetSValueByKey("pos"))
	local CItemTipsView = CItemTipsView:GetView()
	CItemTipsView:CloseView()

end


function CItemWenShiBox.WHPutInBackBox(self ,oItem, hitExtend)

	if hitExtend then
		self.m_PickUpBtn:SetActive(true)
		self.m_ButtonBox:SetActive(false)
		self.m_BtnInfo:SetText("取回包裹")
		self.m_PickUpBtn:AddUIEvent("click",callback(self,"PutInBackBox" ,oItem))
	end

end

function CItemWenShiBox.RefreshRightBtn(self)
	
	self.m_RightBtnBox.btnText = self.m_RightBtnBox:NewUI(1, CLabel)
	self.m_RightBtnBox.collider = self.m_RightBtnBox:NewUI(2, CWidget)
	self.m_RightBtnBox.btnText:SetText("镶嵌")
	self.m_RightBtnBox.collider:AddUIEvent("click", callback(self, "OnClickRightBtn"))

end

function CItemWenShiBox.RefreshLeftBtn(self)
	
	self.m_LeftBtnBox.btnText = self.m_LeftBtnBox:NewUI(1, CLabel)
	self.m_LeftBtnBox.collider = self.m_LeftBtnBox:NewUI(2, CWidget)
	self.m_LeftBtnBox.btnText:SetText("更多")
	self.m_LeftBtnBox.collider:AddUIEvent("click", callback(self, "OnClickLeftBtn"))

end

function CItemWenShiBox.OnClickRightBtn(self)


	if g_OpenSysCtrl.m_SysOpenList[define.System.RideTongYu] then 
		CHorseTongYuMainView:ShowView(function ( oView )
			
			oView:OpenWenShiWearPart()

		end)
	else
		local openInfo = data.opendata.OPEN.RIDE_TY
		if openInfo then 
			local name = openInfo.name
			local lv = openInfo.p_level
			g_NotifyCtrl:FloatMsg(name .. lv .. "级开放，敬请期待")
		end 
	end 
	
end

function CItemWenShiBox.OnClickLeftBtn(self)
	
	self.m_ExpandBtn = not self.m_ExpandBtn
	--创建功能按钮
	self.m_FeatureTable:SetActive(self.m_ExpandBtn)

end

function CItemWenShiBox.CreateFeatureBtns(self)
	
	for k, v in ipairs(self.m_FeatureBtnList) do 
		local itemBtn = self.m_FeatureTable:GetChild(k)
		if not itemBtn then 
			itemBtn = self.m_FeatureBtnBox:Clone()
			itemBtn:SetActive(true)
			self.m_FeatureTable:AddChild(itemBtn)
		end 
		itemBtn.btnText = itemBtn:NewUI(1, CLabel)
		itemBtn.collider = itemBtn:NewUI(2, CWidget)
		itemBtn.btnText:SetText(v.name)
		itemBtn.collider:AddUIEvent("click", callback(self, v.cb))
	end 

end

function CItemWenShiBox.OnClickWashBtn(self)
	
	if g_OpenSysCtrl.m_SysOpenList[define.System.RideTongYu] then 
		CHorseWenShiMainView:ShowView(function ( oView )
			oView:OpenWashPart(self.m_Item.m_ID)
		end)
	else
		local openInfo = data.opendata.OPEN.RIDE_TY
		if openInfo then 
			local name = openInfo.name
			local lv = openInfo.p_level
			g_NotifyCtrl:FloatMsg(name .. lv .. "级开放，敬请期待")
		end 
	end  

end

function CItemWenShiBox.OnClickFusionBtn(self)

	if g_OpenSysCtrl.m_SysOpenList[define.System.RideTongYu] then 
		CHorseWenShiMainView:ShowView(function ( oView )
			oView:OpenFusionPart(self.m_Item.m_ID)
		end)
	else
		local openInfo = data.opendata.OPEN.RIDE_TY
		if openInfo then 
			local name = openInfo.name
			local lv = openInfo.p_level
			g_NotifyCtrl:FloatMsg(name .. lv .. "级开放，敬请期待")
		end 
	end 

end

function CItemWenShiBox.OnClickFusionDecomposeBtn(self)
	
	 g_ItemCtrl:DeComposeItem(self.m_Item.m_ID, 1)

end

function CItemWenShiBox.OnClickPreViewBtn(self)
	
	self.m_ShowPreViewBox = not self.m_ShowPreViewBox
	if self.m_ShowPreViewBox then 
		self.m_PreViewBox:SetActive(true)
		self:RefreshPreView()
	else
		self.m_PreViewBox:SetActive(false)
	end 


end

function CItemWenShiBox.RefreshPreView(self)
	
	self.m_PreGrid:HideAllChilds()
	local sid = self.m_Item.m_SID
	local totalAttr = g_WenShiCtrl:GetWenShiTotalAttr(sid)
	local str = nil
	for k, v in ipairs(totalAttr) do 
		local attrItem = self.m_PreGrid:GetChild(k)
		if not attrItem then 
		    attrItem = self.m_PreAttrItem:Clone()
		    attrItem:SetActive(true)
		    self.m_PreGrid:AddChild(attrItem)
		end 
		attrItem:SetActive(true)
		attrItem.name = attrItem:NewUI(1, CLabel)
		attrItem.value = attrItem:NewUI(2, CLabel)

		attrItem.name:AlignmentWidth(v.name)
		attrItem.name:SetText(v.name)
		attrItem.value:SetText("+" .. v.value)
	end 

end

return CItemWenShiBox