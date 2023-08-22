local CWenShiFusionSuccessView = class("CWenShiFusionSuccessView", CViewBase)

function CWenShiFusionSuccessView.ctor(self, cb)

	CViewBase.ctor(self, "UI/Horse/WenShiFusionSuccessView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "sub"
    self.m_ExtendClose = "Black"

    self.m_Cb = nil
    self.m_WenShiDataList = nil

end

function CWenShiFusionSuccessView.OnCreateView(self)

    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_Icon = self:NewUI(2, CSprite)
    self.m_Name = self:NewUI(3, CLabel)
    self.m_Grid = self:NewUI(4, CGrid)
    self.m_Attr = self:NewUI(5, CBox)
    self.m_ConfirmBtn = self:NewUI(6, CSprite)

    self:InitContent()

end

function CWenShiFusionSuccessView.InitContent(self)

	 self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	 self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnClickConfirmBtn"))

end

function CWenShiFusionSuccessView.SetData(self, oItem, leftInfo, rightInfo)
	
	local sid = oItem.m_SID
	local wenshiConfigItem = data.itemwenshidata.WENSHI[sid]
	local name = wenshiConfigItem.name
	local icon = wenshiConfigItem.icon
	local lv = oItem.m_SData.equip_info.grow_level
	local attrList = oItem.m_SData.equip_info.attach_attr

	self:FindDiffAttr(attrList, leftInfo, rightInfo)

	self:RefreshName(name, lv)
	self:RefreshIcon(icon)
	self:RefreshAttr(attrList)

end

function CWenShiFusionSuccessView.FindDiffAttr(self, attrList, leftInfo, rightInfo)
	
	self.m_DiffAttr = {}
	if not leftInfo or not rightInfo then 
		return 
	end 

	local isInAttrList = function (key, attr)
		if not attr then 
			return
		end 
		for j, i in ipairs(attr) do
			if key == i.key then 
				return true
			end 
		end
		return false 
	end

	for k, attr in ipairs(attrList) do 
		local key = attr.key
		if isInAttrList(key, leftInfo.attr) then 
			self.m_DiffAttr[key] = nil
		elseif isInAttrList(key, rightInfo.attr) then 
			self.m_DiffAttr[key] = nil
		else
			self.m_DiffAttr[key] = true
		end   
	end 

end

function CWenShiFusionSuccessView.RefreshName(self, name, lv)
	
	self.m_Name:SetText("[1D8E00FF]" .. tostring(lv) .. "级[-][244B4EFF]" .. name .. "[-]")

end

function CWenShiFusionSuccessView.RefreshIcon(self, icon)
	
	self.m_Icon:SpriteItemShape(icon)

end

function CWenShiFusionSuccessView.RefreshAttr(self, attrList)
	
	local attrNameConfig = data.attrnamedata.DATA
	for k, v in ipairs(attrList) do 
		local data = attrNameConfig[v.key]
		if data then 
			local item = self.m_Grid:GetChild(k)
			if not item then 
				item = self.m_Attr:Clone()
				item:SetActive(true)
				self.m_Grid:AddChild(item)
			end 
			local value = v.value / 100

			item:SetActive(true)

			item.name = item:NewUI(1, CLabel)
			item.attr = item:NewUI(2, CLabel)

			local strlen = string.utfStrlen(data.name)

			if strlen <= 2 then 
			     item.name:SetSpacingX(34)
			elseif strlen == 3 then 
			    item.name:SetSpacingX(8)
			else
			    item.name:SetSpacingX(0)
			end 

		    item.name:SetText("[63432CFF]" .. data.name .. "[-]")
		    item.attr:SetText("[63432CFF]:" .. value .. "[-]")

			if self.m_DiffAttr[v.key] then
				item:AddEffect("WenShiAttr")
			end 
		end 
	end 

end

function CWenShiFusionSuccessView.OnClickConfirmBtn(self)
	
	self:OnClose()

end


return CWenShiFusionSuccessView
