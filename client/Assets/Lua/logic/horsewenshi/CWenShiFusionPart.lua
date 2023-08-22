local CWenShiFusionPart = class("CWenShiFusionPart", CPageBase)

function CWenShiFusionPart.ctor(self, obj)

	CPageBase.ctor(self, obj)
	self.m_SelId = nil
	self.m_SelWenShiIdList = {}

end

function CWenShiFusionPart.OnInitPage(self)

	self.m_Name = self:NewUI(1, CLabel)
	self.m_Icon = self:NewUI(2, CSprite)
	self.m_ItemLeft = self:NewUI(3, CBox)
	self.m_ItemRight = self:NewUI(4, CBox)
	self.m_Probability = self:NewUI(5, CLabel)
	self.m_AttrLeftGrid = self:NewUI(6, CGrid)
	self.m_AttrRightGrid = self:NewUI(7, CGrid)
	self.m_FusionBtn = self:NewUI(8, CSprite)
	self.m_AttrLeft = self:NewUI(9, CBox)
	self.m_AttrRight = self:NewUI(10, CBox)
	self.m_TipBtn = self:NewUI(11, CSprite)
	self.m_Ratio = self:NewUI(12, CLabel)
	self.m_LeftTip = self:NewUI(13, CLabel)
	self.m_RightTip = self:NewUI(14, CLabel)
	self.m_EffectNode = self:NewUI(15, CWidget)

	self:InitContent()

end

function CWenShiFusionPart.InitContent(self)

	self:InitWenShiItemLeft()
	self:InitWenShiItemRight()
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnRefreshItem"))
	g_WenShiCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWenShiEvent"))

	self.m_FusionBtn:AddUIEvent("click", callback(self, "OnClickFusionBtn"))
	self.m_TipBtn:AddUIEvent("click", callback(self, "OnClickTipBtn"))

end

function CWenShiFusionPart.ShowPage(self)

	CPageBase.ShowPage(self)
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnRefreshItem"))

end

function CWenShiFusionPart.HidePage(self)

	CPageBase.HidePage(self)
	g_ItemCtrl:DelCtrlEvent(self:GetInstanceID())

end

function CWenShiFusionPart.InitWenShiItemLeft(self)

	local oItem = self.m_ItemLeft
	oItem.icon = oItem:NewUI(1, CSprite)
	oItem.resetBtn = oItem:NewUI(2, CSprite)
	oItem.name = oItem:NewUI(3, CLabel)
	oItem.boxCollider = oItem:NewUI(4, CWidget)
	oItem.addIcon = oItem:NewUI(5, CSprite)
	oItem.resetBtn:AddUIEvent("click", callback(self, "OnResetHorseWenShiItem", oItem))
	oItem.boxCollider:AddUIEvent("click", callback(self, "OnClickHorseWenShiItem", oItem))
	oItem.main = true
	oItem.name:SetText("点击选择主纹饰")
	
end

function CWenShiFusionPart.InitWenShiItemRight(self)

	local oItem = self.m_ItemRight
	oItem.icon = oItem:NewUI(1, CSprite)
	oItem.resetBtn = oItem:NewUI(2, CSprite)
	oItem.name = oItem:NewUI(3, CLabel)
	oItem.boxCollider = oItem:NewUI(4, CWidget)
	oItem.addIcon = oItem:NewUI(5, CSprite)
	oItem.resetBtn:AddUIEvent("click", callback(self, "OnResetHorseWenShiItem", oItem))
	oItem.boxCollider:AddUIEvent("click", callback(self, "OnClickHorseWenShiItem", oItem))
	oItem.name:SetText("点击选择副纹饰")

end

function CWenShiFusionPart.OnResetHorseWenShiItem(self, item)

	local info = item.info

	--刷新界面
	if item.main then 
		--刷新 副 中间
		self:ClearLeftWenShiItem()
		self:ClearRightWenShiItem()
		self:ClearFusionItem()
		self:ClearRatio()
	else
		self:ClearRightWenShiItem()
	end  

end

function CWenShiFusionPart.OnClickHorseWenShiItem(self, item)

	self.m_CurSelWenShiItem = item

	--先判断选中的是主的还是副的
	local main = item.main
	if main then 
		if not self.m_CurSelWenShiItem.info then 
			local wenShiDataList = g_WenShiCtrl:GetBagWenShiDataLessthanLv(3)
			CWenShiAddView:ShowView(function ( oView )
				oView:SetData(wenShiDataList, callback(self, "WenShiSelectHandle"))
			end)
		end

	else
		if self.m_ItemLeft.info then 
			local lv = self.m_ItemLeft.info.lv
			local wenShiDataList = g_WenShiCtrl:GetBagWenShiDataByLv(lv)
			--去掉主纹饰
			local id = self.m_ItemLeft.info.id
			wenShiDataList[id] = nil
			--去掉不同种类的
			local colorType = self.m_ItemLeft.info.colorType
			for k, v in pairs(wenShiDataList) do 
				if v.colorType ~= colorType then 
					wenShiDataList[v.id] = nil
				end 
			end 

			CWenShiAddView:ShowView(function ( oView )
				oView:SetData(wenShiDataList, callback(self, "WenShiSelectHandle"))
			end)
 
		else
			g_NotifyCtrl:FloatMsg(g_HorseCtrl:GetTextTip(1043))
		end 

	end 


end

--纹饰道具 {id, lv, icon, colorType}
function CWenShiFusionPart.WenShiSelectHandle(self, info)

	self.m_CurSelWenShiItem.info = info



	self:RefreshWenShiItem()

end

function CWenShiFusionPart.RefreshWenShiItem(self)

	local main = self.m_CurSelWenShiItem.main
	local info = self.m_CurSelWenShiItem.info

	self.m_CurSelWenShiItem.icon:SpriteItemShape(info.icon)
	self.m_CurSelWenShiItem.name:SetText(info.lv .. "级".. info.name)
	self.m_CurSelWenShiItem.icon:SetActive(true)
	self.m_CurSelWenShiItem.addIcon:SetActive(false)
	self.m_CurSelWenShiItem.resetBtn:SetActive(true)
	self.m_CurSelWenShiItem.name:SetActive(true)

	self:RefreshFusionItem()

	if main then 
		self:RefreshLeftWenShiDes()
		self:RefreshRatio(info.colorType, info.lv)
	else
		self:RefreshRightWenShiDes()
	end 


end

function CWenShiFusionPart.RefreshLeftWenShiDes(self)
	
	self.m_LeftTip:SetActive(false)
	local attrList = self.m_ItemLeft.info.attr
	local attrNameConfig = data.attrnamedata.DATA
	for k, v in ipairs(attrList) do 
		local data = attrNameConfig[v.key]
		if data then 
			local item = self.m_AttrLeftGrid:GetChild(k)
			if not item then 
				item = self.m_AttrLeft:Clone()
				item:SetActive(true)
				self.m_AttrLeftGrid:AddChild(item)
			end 
			local value = v.value / 100
			item:SetActive(true)
			item.name = item:NewUI(1, CLabel)
			item.attr = item:NewUI(2, CLabel)

			if g_AttrCtrl:IsRatioAttr(v.key) then 
				value = value .. "%"
			end 
			item.name:AlignmentWidth(data.name) 
		    item.name:SetText("[63432CFF]" .. data.name .. "[-]")
		    item.attr:SetText("[63432CFF]:" .. value .. "[-]")
		end 
	end 

end

function CWenShiFusionPart.RefreshRightWenShiDes(self)
	
	self.m_RightTip:SetActive(false)
	local attrList = self.m_ItemRight.info.attr
	local attrNameConfig = data.attrnamedata.DATA
	for k, v in ipairs(attrList) do 
		local data = attrNameConfig[v.key]
		if data then 
			local item = self.m_AttrRightGrid:GetChild(k)
			if not item then 
				item = self.m_AttrRight:Clone()
				item:SetActive(true)
				self.m_AttrRightGrid:AddChild(item)
			end 
			local value = v.value / 100
			item:SetActive(true)
			item.name = item:NewUI(1, CLabel)
			item.attr = item:NewUI(2, CLabel)

			if g_AttrCtrl:IsRatioAttr(v.key) then 
				value = value .. "%"
			end 
			item.name:AlignmentWidth(data.name) 

		    item.name:SetText("[63432CFF]" .. data.name .. "[-]")
		    item.attr:SetText("[63432CFF]:" .. value .. "[-]")
		end 
	end 

end

function CWenShiFusionPart.SelectMainWenShi(self, id)

	if not id then 
		return
	end 

	local info = g_WenShiCtrl:GetBagWenShiDataById(id)
	if info then 
		self.m_CurSelWenShiItem = self.m_ItemLeft
		self.m_CurSelWenShiItem.boxCollider:ForceSelected(true)
		self:WenShiSelectHandle(info)
	end 

end

function CWenShiFusionPart.ClearLeftWenShiDes(self)
	
	self.m_AttrLeftGrid:HideAllChilds()
	self.m_LeftTip:SetActive(true)

end

function CWenShiFusionPart.ClearRightWenShiDes(self)
	
	self.m_AttrRightGrid:HideAllChilds()
	self.m_RightTip:SetActive(true)

end

function CWenShiFusionPart.ClearLeftWenShiItem(self)
	
	self.m_ItemLeft.icon:SetActive(false)
	self.m_ItemLeft.addIcon:SetActive(true)
	self.m_ItemLeft.resetBtn:SetActive(false)
	self.m_ItemLeft.name:SetText("点击选择主纹饰")
	self.m_ItemLeft.info = nil
	self:ClearLeftWenShiDes()

end

function CWenShiFusionPart.ClearRightWenShiItem(self)
	
	self.m_ItemRight.icon:SetActive(false)
	self.m_ItemRight.addIcon:SetActive(true)
	self.m_ItemRight.resetBtn:SetActive(false)
	self.m_ItemRight.name:SetText("点击选择副纹饰")
	self.m_ItemRight.info = nil
	self:ClearRightWenShiDes()

end

function CWenShiFusionPart.RefreshFusionItem(self)
	
	local info = self.m_ItemLeft.info
	if info then 
		self.m_Icon:SpriteItemShape(info.icon)
		self.m_Name:SetText("[1d8e00ff]" .. (info.lv + 1) .. "级[-] [244B4EFF]" .. info.name .. "[-]")
		self.m_Icon:SetActive(true)
		self.m_Name:SetActive(true)
	end 

end

function CWenShiFusionPart.ClearFusionItem(self)
	
	self.m_Icon:SetActive(false)
	self.m_Name:SetActive(false)

end

function CWenShiFusionPart.OnClickFusionBtn(self)
	
	if not self.m_ItemLeft.info then 
		g_NotifyCtrl:FloatMsg("请选择主纹饰")
		return
	end 

	if not self.m_ItemRight.info then 
		g_NotifyCtrl:FloatMsg("请选择副纹饰")
		return
	end 

	local mainId = self.m_ItemLeft.info.id
	local subId = self.m_ItemRight.info.id

	g_WenShiCtrl:C2GSWenShiCombine(mainId, subId)


end

function CWenShiFusionPart.OnWenShiEvent(self, oCtrl)
	
	if oCtrl.m_EventID == define.WenShi.Event.Fusion then 
		local flag = oCtrl.m_EventData
		if flag == 1 and self.m_FusionItem then 
			self.m_EffectNode:AddEffect("WenShiFusion")
			self.m_EffectNode:SetActive(true)

			local delay = function ()		
				if Utils.IsNil(self) then 
					return
				end 
				self.m_EffectNode:SetActive(false)

				CWenShiFusionSuccessView:ShowView(function ( oView )
					oView:SetData(self.m_FusionItem, self.m_ItemLeft.info, self.m_ItemRight.info)
					self:ClearLeftWenShiItem()
					self:ClearRightWenShiItem()
					self:ClearFusionItem()
					self:ClearRatio()
				end)
			end

			Utils.AddTimer(delay, 0, 2)

		else
			self:ClearLeftWenShiItem()
			self:ClearRightWenShiItem()
			self:ClearFusionItem()
			self:ClearRatio()
			self.m_FusionItem = nil
		end 

	end 

end

function CWenShiFusionPart.OnRefreshItem(self, oCtrl)
	
	if oCtrl.m_EventID == define.Item.Event.AddItem then 
		local oItem = oCtrl.m_EventData
		local id = oItem.m_ID  
		local isWenShiItem = g_ItemCtrl:IsWenShiItem(id)
		if isWenShiItem then
			self.m_FusionItem = oItem
		end 
	end 

end

function CWenShiFusionPart.OnClickTipBtn(self)
	
	local desInfo = data.instructiondata.DESC[10062]
	if desInfo then 
		local zContent = {title = desInfo.title, desc = desInfo.desc}
		g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
	end 

end

function CWenShiFusionPart.RefreshRatio(self, colorType, lv)
	
	local config = data.itemwenshidata.COLOR_CONFIG[colorType]
	if config then 
		local combineRatio = config.combine_ratio
		for k, v in ipairs(combineRatio) do
			if v.level == lv then 
				self.m_Ratio:SetText("成功概率:" .. tostring(v.ratio) .. "%")
				self.m_Ratio:SetActive(true)
			end 
		end 
	end 

end

function CWenShiFusionPart.ClearRatio(self)
	
	self.m_Ratio:SetActive(false)	

end


return CWenShiFusionPart