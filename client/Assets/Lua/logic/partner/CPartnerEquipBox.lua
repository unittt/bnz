local CPartnerEquipBox = class("CPartnerEquipBox", CBox)

function CPartnerEquipBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_CloseBtn = self:NewUI(1, CSprite)
	self.m_WeaponBoxGrid = self:NewUI(2, CGrid)
	self.m_PropContent = self:NewUI(3, CLabel)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "SetActive", false))
	g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnTouchOutDetect"))
	
	local function init(obj, index)
		local oBox = CBox.New(obj)
		oBox.m_NilIcon = oBox:NewUI(1, CSprite)
		oBox.m_Name = oBox:NewUI(2, CLabel)
		oBox.m_Additional = oBox:NewUI(3, CLabel)
		oBox.m_Additional1 = oBox:NewUI(4, CLabel)
		oBox.m_Additional2 = oBox:NewUI(5, CLabel)
		oBox.m_Icon = oBox:NewUI(6, CSprite)
		oBox.m_Btn = oBox:NewUI(7, CBox)
		oBox.m_AdditionBg = oBox:NewUI(8, CObject)
		oBox.m_Btn:AddUIEvent("click", function ()
			local equipInfo = DataTools.GetPartnerEquipInfo(self.m_PartnerData.sid, index)
			if self.m_EquipInfoList and self.m_EquipInfoList[index] then
				local config = {widget = oBox.m_Btn}
				-- g_WindowTipCtrl:SetWindowItemTip(equipInfo.icon, config)
				-- g_NotifyCtrl:FloatMsg(string.format("#G%s[-]已穿戴装备#G%s", self.m_PartnerData.name, equipInfo.name))
				return
			end
			local equipItemList = g_ItemCtrl:GetBagItemListBySid(equipInfo.equipid)
			if #equipItemList <= 0 then
				printc("打开道具获取途径界面，现在还没有")
				g_NotifyCtrl:FloatMsg("打开道具获取途径界面，现在还没有")
				-- g_NotifyCtrl:FloatMsg(string.format("没有#G%s[-]专属装备#G%s", self.m_PartnerData.name, equipInfo.name))
				return
			end
			local args = {
				msg = DataTools.GetPartnerTextInfo(1008).content,
				title = "穿戴装备", 
				okCallback = function()
					local itemid = equipItemList[1]:GetSValueByKey("id")
					netpartner.C2GSWieldEquip(self.m_PartnerData.id, itemid)
				end,
			}
			g_WindowTipCtrl:SetWindowConfirm(args)
		end)
		return oBox
	end
	self.m_WeaponBoxGrid:InitChild(init)
	self.m_PartnerData = nil
	self.m_EquipInfoList = nil
end

function CPartnerEquipBox.OnTouchOutDetect(self, gameObj)
	if gameObj then
		local nameList = {"clickWidget", "CancelButton", "ThirdButton", "OKButton", "CloseBtn", "BgSprite"}
		if not table.index(nameList, gameObj.name) then
			self:SetActive(false)
		end
	end
end

function CPartnerEquipBox.SetPartnerEquipBoxInfo(self, partnerData)
	self.m_PartnerData = partnerData
	self:SetActive(true)

	local weaponBoxList = self.m_WeaponBoxGrid:GetChildList()
	self.m_EquipInfoList = {}
	for _,v in ipairs(partnerData.equipsid) do
		local equipInfo = DataTools.GetItemData(v, "PARTNEREQUIP")
		self.m_EquipInfoList[equipInfo.equippos] = equipInfo
	end

	for i,v in ipairs(weaponBoxList) do
		local equipInfo = self.m_EquipInfoList[i]
		local showEquip = equipInfo ~= nil
		v.m_NilIcon:SetActive(not showEquip)
		v.m_Icon:SetActive(showEquip)
		v.m_Name:SetText(equipInfo and equipInfo.name or "装备名字")
		v.m_Additional:SetText(showEquip and "附加属性" or "未穿戴装备")
		v.m_AdditionBg:SetActive(showEquip)
		if showEquip then
			v.m_Icon:SpriteItemShape(equipInfo.icon)
		end

		if showEquip then
			for i,eff in ipairs(equipInfo.equip_effect) do
				if i <= 2 then
					local effectStrs = string.split(eff, "%=")
					local sAttrName = data.attrnamedata.DATA[effectStrs[1]].name
					v["m_Additional" .. i]:SetText(sAttrName .. effectStrs[2])
					v["m_Additional" .. i]:SetActive(true)
				end
			end
		end
		for i=(showEquip and #equipInfo.equip_effect or 0)+1,2 do
			v["m_Additional" .. i]:SetActive(false)
		end
	end

	local suiltStr = ""
	local suiltInfo = DataTools.GetPartnerSuiltInfo(partnerData.sid)
	for _,v in ipairs(suiltInfo.suilt_effect) do
		local skillDescCur = g_PartnerCtrl:GetPartnerSkillDesc(v, 1, true)
		if string.len(suiltStr) > 0 then
			suiltStr = suiltStr .. "。" .. skillDescCur
		else
			suiltStr = skillDescCur
		end
	end
	local unSuiltStr = "[c][B2B2B2]" .. suiltStr .. "[-]"
	local suiltStr = "[c]#Q" .. suiltStr .. "[-]"
	local finalSuiltStr = #partnerData.equipsid > 1 and suiltStr or unSuiltStr
	self.m_PropContent:SetText(finalSuiltStr)
end

return CPartnerEquipBox