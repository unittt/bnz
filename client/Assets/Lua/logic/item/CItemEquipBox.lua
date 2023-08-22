local CItemEquipBox = class("CItemEquipBox", CBox)

function CItemEquipBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_BtnNode = self:NewUI(1, CWidget)
	self.m_ItemBox = self:NewUI(2, CItemBaseBox)
	self.m_RoleTypeLabel = self:NewUI(3, CLabel)
	self.m_LevelLabel = self:NewUI(4, CLabel)
	self.m_CloneLine = self:NewUI(5, CSprite) 
	self.m_NameLabel = self:NewUI(6, CLabel)
	self.m_AttrTable = self:NewUI(7, CTable)
	self.m_BtnBox = self:NewUI(8, CItemButtonBox, true, function()
		local oView = CItemTipsView:GetView()
		if oView then
			oView:CloseView()
		end
	end)
	self.m_StatusSpr = self:NewUI(9, CSprite)
	self.m_DescLabel = self:NewUI(10, CLabel)
	self.m_AttrBoxClone = self:NewUI(11, CBox)
	self.m_ScoreLabel = self:NewUI(12, CLabel)
	self.m_LastLabel = self:NewUI(13, CLabel)
	self.m_EquipPosLabel = self:NewUI(14, CLabel)
	self.m_PickUpBtn = self:NewUI(15,CButton)
	self.m_BtnInfo = self:NewUI(16, CLabel)
	self.m_RightBtn = self:NewUI(17, CButton)
	self.m_LeftBtn = self:NewUI(18, CButton)
	self.m_PersonalSpr = self:NewUI(19, CSprite)
	self.m_PreviewBtn = self:NewUI(20, CButton)
	self.m_PreviewBox = self:NewUI(21 , CItemPreviewBox)
	self.m_GemItemBoxClone = self:NewUI(22, CBox)
	self.m_StallFlagSpr = self:NewUI(23, CSprite)

	self.m_HasCompare = false
	self.m_RelativeView = nil
	self.m_PickUpBtn:SetActive(false)
	self:HideFanQieBtn()
	self:InitButtonBox()
	self.m_CurCompareView = nil
	self.m_RightBtn:AddUIEvent("click",callback(self, "ItemMove", true))
	self.m_LeftBtn:AddUIEvent("click",callback(self, "ItemMove", false))
	self.m_PreviewBtn:AddUIEvent("click", callback(self, "OnClickPreview"))
end

-- 背包存入仓库
function CItemEquipBox.BagPutInStore(self ,oItem ,hitExtend)
	-- body
	if hitExtend then
		self.m_PickUpBtn:SetActive(true)
		self.m_BtnBox:SetActive(false)
		self.m_HasCompare = false
		self.m_BtnInfo:SetText("存入仓库")
		self.m_PickUpBtn:AddUIEvent("click",callback(self, "PutInStore"))
	end
end
   
function CItemEquipBox.PutInStore(self,oItem)
	-- body
	g_ItemCtrl.C2GSWareHouseWithStore(g_ItemCtrl.m_RecordWHIndex, self.m_Item.m_ID)
	local CItemTipsView = CItemTipsView:GetView()
	CItemTipsView:CloseView()
end

--仓库取回背包
function CItemEquipBox.WHPutInBackBox(self ,oItem, hitExtend)
	-- body
	if hitExtend then
		self.m_PickUpBtn:SetActive(true)
		self.m_BtnBox:SetActive(false)
		self.m_BtnInfo:SetText("取回包裹")
		self.m_RightBtn:SetActive(false)
		self.m_LeftBtn:SetActive(false)
		self.m_PickUpBtn:AddUIEvent("click",callback(self,"PutInBackBox" ,oItem))
	end
end

function CItemEquipBox.PutInBackBox(self,oItem)
	-- body
	g_ItemCtrl.C2GSWareHouseWithDraw(g_ItemCtrl.m_RecordWHIndex, oItem:GetSValueByKey("pos"))
	local CItemTipsView = CItemTipsView:GetView()
	CItemTipsView:CloseView()
end

--检验 对比界面 CompareView
function CItemEquipBox.TestCompareView(self)
	-- body
	if self.m_CurCompareView and self.m_HasCompare==false then
		self.m_CurCompareView:SetActive(false)
	end
	if self.m_CurCompareView and self.m_HasCompare==true then
		self.m_CurCompareView:SetActive(true)
	end
end

--翻切按钮 
function CItemEquipBox.ItemMove(self, isRightMove)
	-- body
	local nextItem = nil

	if  not self.m_Item:IsEquiped() then
		nextItem = g_ItemCtrl:NextLastEquip(self.m_Item, isRightMove)
	else
		nextItem = g_ItemCtrl:WareEquipInfo(self.m_Item, isRightMove)
	end

	if not nextItem then return end

	if nextItem.m_Type == "Re" then
		local oView = CRecoveryItemView:GetView()
		if oView then
			oView:SetCurrItem(nextItem)
		end
	end
	self.m_Item = nextItem
	self:CreateItem()
	g_ItemCtrl:SetSelectSpr(self.m_Item)
	self:TestCompareView()
	self.m_BtnBox:SetInitBox(self.m_Item)
end

--鼠小二回收装备
function CItemEquipBox.SetRecoveryItem(self , id)
	local oItem =  g_RecoveryCtrl:GetRecoveryItemByID(id)
	self.m_Item = CItem.New(oItem)
	self.m_Item.m_Type = "Re"
	self:SetLocalPos(Vector3.New(217, 0, 0))
	self.m_BtnBox:SetActive(false)
	self.m_PickUpBtn:SetActive(true)
	self.m_BtnInfo:SetText("确认取回")
	self.m_PickUpBtn:AddUIEvent("click",callback(self,"PickUpItem"))
	self:CreateItem()
end

function CItemEquipBox.PickUpItem(self)
	g_RecoveryCtrl:C2GSRecoveryItem(self.m_Item.m_ID)
	local view = CItemTipsView:GetView()
	view:CloseView()	
end

--临时背包
function CItemEquipBox.TempBag(self, oItem)
	self.m_Item = oItem 
	self:SetLocalPos(Vector3.New(217, 0, 0))
	self.m_BtnInfo:SetText("取回物品")
	self.m_PickUpBtn:SetActive(true)
	self.m_PickUpBtn:AddUIEvent("click",callback(self,"OnTempBagItem"))
	self.m_BtnBox:SetActive(false)	
	self:CreateItem()
end

function CItemEquipBox.SetInitBox(self, citem)
	self.m_Item = citem 
	self.m_BtnBox:SetInitBox(citem)
	self:CreateItem()

	if not self.m_Item:IsEquiped() then 
	    if not self.m_HasCompare then
	    	if self.m_Item.m_Type == "Bag" then
		     	self:SetLocalPos(Vector3.New(-235, 0, 0))
		      else
		      	self:SetLocalPos(Vector3.New(217, 0, 0))
		     end
	    end
	end

	if self.m_Item:IsEquiped() then 
		self:SetLocalPos(Vector3.New(217, 0, 0))
	end
end

function CItemEquipBox.InitRelativeView(self)
	self.m_HasCompare = false
	if self.m_RelativeView then
		self:HideRelativeView()
		self.m_RelativeView:Destroy()
		self.m_RelativeView = nil
	end
end

function CItemEquipBox.InitButtonBox(self)
	self.m_BtnBox:SetParentNode(self.m_BtnNode)
end

function CItemEquipBox.CreateItem(self)
	--确保克隆的适合table为空，不至于重复克隆属性
	self.m_AttrTable:Clear()

	self.m_StallFlagSpr:SetActive(self.m_Item:IsGainByStall())
	self.m_PersonalSpr:SetActive(self.m_Item:IsBinding())
	local oCurEquip = g_ItemCtrl:GetEquipedByPos(self.m_Item:GetCValueByKey("equipPos"))
 	self.m_HasCompare = false
	if  self.m_Item:IsEquiped() == false and oCurEquip then
		self.m_HasCompare = true
	end

	self.m_StatusSpr:SetActive(self.m_Item:IsEquiped())
	self:InitBg()
	self.m_StrengthLv = 0
	local iTempStrengthLv = self.m_Item:GetSValueByKey("equip_info").tmp_strength

	if iTempStrengthLv and iTempStrengthLv > 0 then
		self.m_StrengthLv = iTempStrengthLv
	else
		self.m_StrengthLv = g_ItemCtrl:GetStrengthenLv(self.m_Item:GetCValueByKey("equipPos"))
	end

	local iQuality = self.m_Item:GetQuality()
	local sName = string.format(data.colorinfodata.ITEM[iQuality].color, self.m_Item:GetItemName())
	local iSchool = self.m_Item:GetCValueByKey("school")
	local iSex = self.m_Item:GetCValueByKey("sex")
	local iRace = self.m_Item:GetCValueByKey("race")
	local iRoleType = self.m_Item:GetCValueByKey("roletype")
	local iLevel = self.m_Item:GetItemEquipLevel()

	local sLevel = g_AttrCtrl.grade < iLevel and "[c]#R"..iLevel or "#W"..iLevel

	local sRoleType = ""
	if iRoleType and iRoleType > 0 then
		sRoleType = data.roletypedata.DATA[iRoleType].desc
		sRoleType = g_AttrCtrl.roletype ~= iRoleType and "[c]#R"..sRoleType or "#W"..sRoleType 
	elseif iSex and iSex ~= 0 then --TODO:待配表处理
		local tData = data.roletypedata.Race[iRace]--DataTools.GetRoleType(iSex, iSchool)
		if tData then
			sRoleType = tData.name..define.Sex.Desc[iSex]
		else
			sRoleType = define.Sex.Desc[iSex]
			sRoleType = g_AttrCtrl.sex ~= iSex and "[c]#R"..sRoleType or "#W"..sRoleType 
		end
	else
		sRoleType = "通用"
	end

	if self.m_StrengthLv > 0 then
		sName = string.format("%s[0fff32]+%d[-]", sName, self.m_StrengthLv)
		local iTempStrengthScore = self.m_Item:GetSValueByKey("equip_info").tmp_score
		local strength_score = iTempStrengthScore > 0 and iTempStrengthScore or g_ItemCtrl:GetStrengthenScore(self.m_Item:GetCValueByKey("equipPos")) 
		self.m_ScoreLabel:SetText(math.floor((self.m_Item:GetSValueByKey("equip_info").score + strength_score)/1000))
	else
		self.m_ScoreLabel:SetText(math.floor(self.m_Item:GetSValueByKey("equip_info").score/1000))
	end
	self.m_ItemBox:SetBagItem(self.m_Item)
	self.m_ItemBox:SetEnableTouch(false)
	self.m_ItemBox:SetAmountText(0)
	self.m_NameLabel:SetRichText(sName, nil, nil, true)
	self.m_DescLabel:SetRichText("#W"..self.m_Item:GetCValueByKey("description"), nil, nil, true)
	self.m_LevelLabel:SetText(sLevel)
	self.m_LastLabel:SetText(self.m_Item:GetEquipLast())
	self.m_EquipPosLabel:SetText(self.m_Item:GetCValueByKey("partName"))
	self.m_RoleTypeLabel:SetText(sRoleType)

	local isTreasure = self.m_Item:GetSValueByKey("itemlevel") >= define.Item.Quality.Purple
	if self.m_ItemBox.m_TreasureSprite then
		--TODO:策划待修改稀有度规则
		self.m_ItemBox.m_TreasureSprite:SetActive(false)
       -- self.m_ItemBox.m_TreasureSprite:SetActive(isTreasure)
    end
	self:CreateCompareView()
	self:RefreshAttrTable()
	self:ResetBg()
	self:InitCompareViewPos()
end

function CItemEquipBox.OnTempBagItem(self)
	-- body
	nettempitem.C2GSTranToItemBag(self.m_Item.m_SData.id)
	local oView = CItemTipsView:GetView()
	if oView then
		oView:CloseView()
	end
end

function CItemEquipBox.RefreshAttrTable(self)
	self.m_AttrTable:Clear()
	local dEquipInfo = self.m_Item.m_SData.equip_info
	--普通属性
	self:CreateBaseAttr(dEquipInfo)
	--镶嵌宝石
	self:CreateGemStoneAttr(dEquipInfo)
	--附加属性
	self:CreateAttachAttr(dEquipInfo)
	--特效
	self:CreateSpecialEffc(dEquipInfo)
	--特技
	self:CreateSpecialSkill(dEquipInfo)
	--附魂属性
	self:CreateSoulAttr(dEquipInfo)
	--神魂灵性
	self:CreateSoulExtralAttr(dEquipInfo)
	--特殊武器无级别属性
	self:CreateTimeAttr(dEquipInfo)
	--剧情技能增加的属性
	self:CreateFuZhuanAttr(dEquipInfo)
end

function CItemEquipBox.CreateBaseAttr(self, dEquipInfo)
	local tEffData = nil
	local oCurEquip= nil

	if self.m_Item.m_Type == "Bag" then
		oCurEquip = g_ItemCtrl:GetEquipedByPos(self.m_Item:GetCValueByKey("equipPos"))
	end

	if self.m_StrengthLv > 0 then --
		tEffData = DataTools.GetEquipStrengthData(self.m_Item:GetSValueByKey("pos"), self.m_StrengthLv) 
	end
	local iCurAddRatio = 1
	if dEquipInfo.se ~= nil then
		for k,v in pairs(dEquipInfo.se) do
			local iEffectId = tonumber(v)
			local iRatio = DataTools.GetEquipStrengthRatioBySe(iEffectId)
			iCurAddRatio = math.max(iCurAddRatio, iRatio)
		end
	end

	local sDesc = "[8FF2E2]基本属性[-]"
	local oBox = self:CreateAttr(sDesc)
	self.m_AttrTable:AddChild(oBox)

	local function GetSoulAttrValue(sKey, dFuhun)
		if not dFuhun or table.count(dFuhun) == 0 then
			return 0
		end
		for i,v in ipairs(dFuhun) do
			if v.key == sKey then
				return v.value
			end
		end
		return 0
	end 


	local function GetAttrValue(sKey)
		local dInfo = oCurEquip:GetSValueByKey("apply_info")
		local dFuhun = self.m_Item.m_SData.equip_info.fuhun_attr
		for i,v in ipairs(dInfo) do
			if v.key == sKey then
				return v.value + GetSoulAttrValue(dFuhun)
			end
		end
		return 0
	end

	for k,v in ipairs(self.m_Item:GetSValueByKey("apply_info")) do
		local sAttr = data.attrnamedata.DATA[v.key].name
		local sStrengthEff = nil
		if self.m_StrengthLv > 0 and tEffData ~= nil and tEffData[v.key] and self.m_IsCompareView ~= true then
			sStrengthEff = string.format("[0fff32]【强化+%d】[-]",math.floor(tEffData[v.key]*iCurAddRatio))
		end
		local iCompare = nil
		if not self.m_Item:IsEquiped() and (self.m_Item.m_IsCompareEquip == nil or self.m_Item.m_IsCompareEquip) then
			if oCurEquip then
				-- local dInfo = oCurEquip:GetSValueByKey("apply_info")
				iCompare = v.value - GetAttrValue(v.key)--dInfo[k].value
				if iCompare == 0 then
					iCompare = nil
				end
				self.m_HasCompare = true
			end
		end
		oBox = self:CreateAttr("  [c8fff1]"..sAttr, "[c8fff1]+"..v.value + GetSoulAttrValue(v.key, dEquipInfo.fuhun_attr), sStrengthEff, iCompare)
		self.m_AttrTable:AddChild(oBox)
	end
end

function CItemEquipBox.CreateFuZhuanAttr(self, dEquipInfo)
	local oCount
	if #dEquipInfo.fuzhuan > 1 then
		for k,v in ipairs(dEquipInfo.fuzhuan) do
			local oLen = string.len(tostring(v.value))
			if not oCount then
				oCount = oLen
			else
				if oLen > oCount then
					oCount = oLen
				end
			end			
		end
	end
	for k,v in ipairs(dEquipInfo.fuzhuan) do
		local oLeftTime = v.time - g_TimeCtrl:GetTimeS()
		if oLeftTime > 0 then
			local oDescStr = "  临时"
			local oAttr = data.attrnamedata.DATA[v.attr]
			if oAttr then
				oDescStr = oDescStr..oAttr.name.." +"..v.value.." "
				if oCount then
					local oNeedLen = oCount - string.len(tostring(v.value))
					if oNeedLen > 0 then
						for i=1, oNeedLen do
							oDescStr = oDescStr.." "
						end
					end
				end
				oDescStr = oDescStr.."剩余 "..g_TimeCtrl:GetLeftTimeDHMAlone(oLeftTime, true)
				local oBox = self:CreateAttr("[0fff32]"..oDescStr.."[-]")
				self.m_AttrTable:AddChild(oBox)
			end
		end
	end
end

function CItemEquipBox.CreateAttachAttr(self, dEquipInfo)
	local function GetAttrArea(sFormula, iMinRatio, iMaxRatio)
		local iEquipLv = self.m_Item:GetItemEquipLevel()
		iEquipLv = math.floor(iEquipLv/10)*10

		sFormula = string.replace(sFormula, "lv", iEquipLv)
		local sNewFormula = string.replace(sFormula, "k", iMinRatio)
		local func = loadstring("return "..sNewFormula)
		local iMinValue = math.floor(func()/100)
		sNewFormula = string.replace(sFormula, "k", iMaxRatio)
		local func = loadstring("return "..sNewFormula)
		local iMaxValue = math.floor(func()/100)
		return iMinValue, iMaxValue
	end

	local dAttachData = DataTools.GetEquipAttachAttrData(g_AttrCtrl.school)
	local function GetAttrColor(dAttachAttr)
		local vColor = "[0fff32]"
		local dAttrData = dAttachData[dAttachAttr.key] 
		local iMinValue,iMaxValue = GetAttrArea(dAttrData.formula, dAttrData.minRatio, dAttrData.maxRatio)
		local iRatio = (dAttachAttr.value - iMinValue)/(iMaxValue - iMinValue)

		if iRatio > 0.25 and iRatio <= 0.5 then
			vColor = "[00baff]"
		elseif iRatio > 0.5 and iRatio <= 0.75 then
			vColor = "[d74aff]"
		elseif iRatio > 0.75 and iRatio <= 1 then
			vColor = "[ff9600]"
		end
		return vColor
	end

	if table.count(dEquipInfo.attach_attr) > 0 then
		local sDesc = "[8FF2E2]附加属性[-]"
		local oBox = self:CreateAttr(sDesc)
		self.m_AttrTable:AddChild(oBox)
		local sAttr = ""
		local iCount = 1
		for k,v in ipairs(dEquipInfo.attach_attr) do
			local vColor = GetAttrColor(v)
			sAttr = string.format("%s  %s%s+%d[-]", sAttr, vColor, data.attrnamedata.DATA[v.key].name, v.value)
			if iCount%3 == 0 or k == #dEquipInfo.attach_attr then
				oBox = self:CreateAttr(sAttr)
				self.m_AttrTable:AddChild(oBox)
				sAttr = ""
				iCount = 0
			end
			iCount = iCount + 1
		end
	elseif dEquipInfo.is_make == 1 and (self.m_Item:GetItemEquipLevel() >= DataTools.GetEquipWashLvLimit() or self.m_Item:IsTimeEquip()) then
		local sDesc = "[8FF2E2]附加属性[-]"
		local oBox = self:CreateAttr(sDesc)
		self.m_AttrTable:AddChild(oBox)
		local sDesc = "[0fff32]未洗炼[-]"
		local oBox = self:CreateAttr(sDesc)
		self.m_AttrTable:AddChild(oBox)
	end
end

function CItemEquipBox.CreateSpecialEffc(self, dEquipInfo)
	if dEquipInfo.se ~= nil then
		for k,v in pairs(dEquipInfo.se) do
			local iEffectId = tonumber(v)
			local dSkill = data.skilldata.SPECIAL_EFFC[iEffectId]
			local sDesc = string.format("[00baff]特效:   %s", dSkill.name)
			local oBox = self:CreateAttr(sDesc, nil, nil, nil, dSkill.icon)
			oBox:AddUIEvent("click", callback(self, "OnClickSpecialEffect", iEffectId))
			self.m_AttrTable:AddChild(oBox)
		end
	end 
end

function CItemEquipBox.CreateSpecialSkill(self, dEquipInfo)
	if dEquipInfo.sk ~= nil then
		local iCount = 0
		for k,v in pairs(dEquipInfo.sk) do
			local iSkillId = tonumber(v)
			local dSkill = data.skilldata.SPECIAL_EFFC[iSkillId]
			local sDesc = string.format("[00baff]特技:   %s[-]", dSkill.name)
			local oBox = self:CreateAttr(sDesc, nil, nil, nil, dSkill.icon)
			oBox:AddUIEvent("click", callback(self, "OnClickSpecialSkill", iSkillId))
			self.m_AttrTable:AddChild(oBox)
			iCount = iCount + 1
		end
		if iCount == 0 then
			local sDesc = "[00baff]特技:无(打造时有概率获得)"
			local oBox = self:CreateAttr(sDesc, nil, nil, nil, nil)
			self.m_AttrTable:AddChild(oBox)
		end
	end  
end

function CItemEquipBox.CreateSoulAttr(self, dEquipInfo)
	-- if table.count(dEquipInfo.fuhun_attr) > 0 then
	-- 	local sDesc =  "[8FF2E2]附魂属性[-]"
	-- 	local oBox = self:CreateAttr(sDesc)
	-- 	self.m_AttrTable:AddChild(oBox)
	-- 	for k,v in ipairs(dEquipInfo.fuhun_attr) do
	-- 		local sAttr = data.attrnamedata.DATA[v.key].name
	-- 		oBox = self:CreateAttr("  "..sAttr, string.format("[0fff32]+%d[-]",v.value))
	-- 		self.m_AttrTable:AddChild(oBox)
	-- 	end
	-- end
end

function CItemEquipBox.CreateSoulExtralAttr(self, dEquipInfo)
	if table.count(dEquipInfo.fuhun_extra) > 0 then
		local sDesc =  "[8FF2E2]神魂灵性[-]"
		local oBox = self:CreateAttr(sDesc)
		self.m_AttrTable:AddChild(oBox)
		for k,v in ipairs(dEquipInfo.fuhun_extra) do
			local sAttr = data.attrnamedata.DATA[v.key].name
			local iVal = v.value
			if v.key == "seal_ratio" or v.key == "res_seal_ratio" then
				iVal = iVal * 10
			end
			oBox = self:CreateAttr("  [ffde00]"..sAttr..string.format("[ffde00]+%d[-]", iVal))
			self.m_AttrTable:AddChild(oBox)
		end
	end
end

function CItemEquipBox.CreateGemStoneAttr(self, dEquipInfo)
	if dEquipInfo.hunshi ~= nil and table.count(dEquipInfo.hunshi) > 0 then
		local sDesc = "[8FF2E2]镶嵌宝石[-]"
		local oBox = self:CreateAttr(sDesc)
		self.m_AttrTable:AddChild(oBox)
		local iEquipLv = self.m_Item:GetItemEquipLevel()
		if iEquipLv % 10 ~= 0 then
			iEquipLv = math.floor(iEquipLv/10)*10
		end
		local dLimitData = data.hunshidata.EQUIPLIMIT[iEquipLv]
		local iItemId, sName, dInfo
		local function reset()
			iItemId = nil
			sName = nil
			dInfo = nil
		end
		for i=1,3 do
			local bIsLast = i == dLimitData.holecnt
			local dInfo = self.m_Item:GetInlayItemByPos(i)
			local sName = "未镶嵌"
			local sAttr = ""
			if dInfo then
				iItemId = data.hunshidata.COLOR[dInfo.color].itemsid
				local dItemData = DataTools.GetItemData(iItemId)
				sName = dInfo.grade.."级"..dItemData.name
				for i,sAttrKey in ipairs(dInfo.addattr) do
					local sAttrName = data.attrnamedata.DATA[sAttrKey].name
					local dAttrData = DataTools.GetGemStoneAttrData(iItemId, dInfo.grade, sAttrKey)
					sAttr = string.format("%s%s+%d ", sAttr, sAttrName, dAttrData.value)
				end
			end

			local oBox = self:CreateGemStone(iItemId, sName, sAttr)
			self.m_AttrTable:AddChild(oBox)
			reset()
			if bIsLast then
				break
			end
		end
	end 
end

function CItemEquipBox.CreateTimeAttr(self, dEquipInfo)
	if dEquipInfo.grow_level > 0 and dEquipInfo.left_minute > 0 then
		local sDesc = string.format("[c8fff1]持续在线[c]#G%d#n[/c]分钟后属性提升[-]", dEquipInfo.left_minute)
		local oBox = self:CreateAttr(sDesc)
		self.m_AttrTable:AddChild(oBox)
	end
end

function CItemEquipBox.CreateAttr(self, sAttr1, sAttr2, sAttr3, iCompare, iSkillId)
	local oBox = self.m_AttrBoxClone:Clone()
	oBox:SetActive(true)
	oBox.m_AttrLabel = oBox:NewUI(1, CLabel)
	oBox.m_ValueLabel = oBox:NewUI(2, CLabel)
	oBox.m_ExtraLabel = oBox:NewUI(3, CLabel)
	oBox.m_CompareSpr = oBox:NewUI(4, CSprite)
	oBox.m_SkillSpr = oBox:NewUI(5, CSprite)

	oBox.m_AttrLabel:SetRichText(sAttr1)
	if sAttr2 then
		oBox.m_ValueLabel:SetRichText(sAttr2)
	else
		oBox.m_ValueLabel:SetActive(false)
	end
	if sAttr3 then
		oBox.m_ExtraLabel:SetRichText(sAttr3)
		if string.find(sAttr3, "强化") then
			local pos = oBox.m_ExtraLabel:GetPos()
			pos.x = pos.x - 10
			oBox.m_ExtraLabel:SetPos(pos)
		end
	else
		oBox.m_ExtraLabel:SetActive(false)
		oBox.m_ExtraLabel:SetText("")
		local pos = oBox.m_ValueLabel:GetPos()
		local w,h = oBox.m_ValueLabel:GetSize()
		pos.x = math.max((pos.x + w),(pos.x + 50))
		oBox.m_ExtraLabel:SetPos(pos)
	end
	oBox.m_CompareSpr:SetActive(iCompare ~= nil)
	if iCompare then
		if iCompare > 0 then
			oBox.m_CompareSpr:SetSpriteName("h7_sheng")
		else
			oBox.m_CompareSpr:SetSpriteName("h7_jiang")
		end
	end
	oBox.m_SkillSpr:SetActive(iSkillId ~= nil)
	if iSkillId then
		oBox.m_SkillSpr:SpriteSkill(iSkillId)
	end
	return oBox
end

function CItemEquipBox.CreateGemStone(self, iItemId, sName, sAttr)
	local oBox = self.m_GemItemBoxClone:Clone()
	oBox.m_ItemSpr = oBox:NewUI(1, CSprite)
	oBox.m_NameL = oBox:NewUI(2, CLabel)
	oBox.m_AttrL = oBox:NewUI(3, CLabel)
	oBox.m_ItemBg = oBox:NewUI(4, CSprite)
	oBox:SetActive(true)

	oBox.m_ItemBg:SetActive(iItemId == nil)
	oBox.m_ItemSpr:SetActive(iItemId ~= nil)

	if iItemId ~= nil then
		local dItem = DataTools.GetItemData(iItemId)
		oBox.m_ItemSpr:SpriteItemShape(dItem.icon)
		oBox.m_AttrL:SetText(sAttr)
		oBox.m_NameL:SetText(sName)
	end
	
	return oBox
end

function CItemEquipBox.CreateCompareView(self)
	if not self.m_HasCompare  then
		return
	end
	local oCurEquip = g_ItemCtrl:GetEquipedByPos(self.m_Item:GetCValueByKey("equipPos"))
	local oCompareView = nil
	if not self.m_CurCompareView then
		oCompareView = self:Clone()
		self.m_CurCompareView = oCompareView
	end
	if self.m_ItemBox.m_TreasureSprite then
	    local SpTransform = oCompareView.m_ItemBox:Find("BorderSprite(Clone)")
	    if SpTransform then
	       CObject.New(SpTransform.gameObject):SetActive(false)
		end
    end
	self.m_RelativeView = self.m_CurCompareView
	self.m_CurCompareView.m_RelativeView = self
	self.m_CurCompareView.m_IsCompareView = true
	self.m_CurCompareView.m_AttrTable:Clear()
	self.m_CurCompareView:SetInitBox(oCurEquip)
	self.m_CurCompareView:HideButton()
	self.m_CurCompareView:SetParent(self.m_Transform.parent)
	self.m_CurCompareView.m_LeftBtn:SetActive(false)
	self.m_CurCompareView.m_RightBtn:SetActive(false)
end

function CItemEquipBox.InitCompareViewPos(self)
	if not self.m_HasCompare then
		return
	end
	local w,h = self:GetSize()
	local w1,h1 = self.m_RelativeView:GetSize()
	local pos = self:GetLocalPos()
	local iOffsetX = w/2 + 10
	local iOffsetY = (h1 - h)/2
	pos.x = iOffsetX
	if iOffsetY > 75 then
		iOffsetY = iOffsetY/2
		pos.y = iOffsetY
	end
	self:SetLocalPos(pos)
	self.m_RelativeView:SetLocalPos(Vector2.New(-iOffsetX, -iOffsetY))
end

function CItemEquipBox.HideRelativeView(self)
	if not self.m_RelativeView or not self.m_RelativeView:GetActive() then
		return
	end
	self.m_RelativeView:SetActive(false)
	local pos = self:GetLocalPos()
	pos.x = 0
	self:SetLocalPos(pos)
end

function CItemEquipBox.InitBg(self)
	local w,h = self:GetSize()
	h = 320
	self:SetSize(w, h)
end

function CItemEquipBox.ResetBg(self)
	local w,h = self:GetSize()
	local tableH = self.m_AttrTable:GetCount()*30
	local list = self.m_AttrTable:GetChildList()
	local num = tableH/30-#list
	-- if num ~= 0 then
	-- 	for i = 1, num  do
	-- 		local item = self.m_AttrTable.m_TransformList
	-- 		item[i].gameObject:Destroy()
	-- 	end
	-- end
	h = math.max(h + tableH + 20, h)
	self:SetSize(w, h)
end

function CItemEquipBox.HideButton(self)
	self.m_BtnNode:SetAnchor("bottomAnchor",0, 0)
	self.m_BtnBox:SetActive(false)
	self.m_LeftBtn:SetActive(false)
	self.m_RightBtn:SetActive(false)
	local w,h = self:GetSize()
	h = h - 50 
	self:SetSize(w, h)
end

--显示获取途径按钮
function CItemEquipBox.ShowGainWayBtn(self)
	self.m_BtnBox:SetCenterButton("获得途径", callback(self, "OnGainWayBtnCB"))
	self.m_BtnBox:ShowCenterBtn(true)
end

function CItemEquipBox.OnGainWayBtnCB(self)
	local oView = CItemTipsView:GetView()
	if oView then
		oView:OpenGainWayView()
	end
end

function CItemEquipBox.OnClickSpecialEffect(self, iEffectId)
	-- self:HideRelativeView()
	local args = {widget =  self, side = enum.UIAnchor.Side.Right,offset = Vector2.New(-140, 50)}
	g_WindowTipCtrl:SetWindowEquipEffectTipInfo(iEffectId, args) 
end

function CItemEquipBox.OnClickSpecialSkill(self, iSkillId)
	-- self:HideRelativeView()
	local args = {widget =  self, side = enum.UIAnchor.Side.Right,offset = Vector2.New(-140, 50)}
	g_WindowTipCtrl:SetWindowEquipEffectTipInfo(iSkillId, args, true) 
end

function CItemEquipBox.OnClickPreview(self)
	local iViewPosX = self:GetLocalPos().x
	iViewPosX = iViewPosX == 0 and 1 or iViewPosX
	local iDir = -iViewPosX/math.abs(iViewPosX)
	local vPos = self.m_PreviewBox:GetLocalPos()
	vPos.x = math.abs(vPos.x)*iDir
	self.m_PreviewBox:SetLocalPos(vPos)
	self.m_PreviewBox:SetItem(self.m_Item)
	self.m_PreviewBox:SetActive(true)
end

-- function CItemEquipBox.OnClickGemStone(self, dInfo)
-- 	local args = {widget =  self, side = enum.UIAnchor.Side.Right,offset = Vector2.New(-140, 50)}
-- 	g_WindowTipCtrl:SetWindowGemStoneTipInfo(dInfo.itemsid, dInfo.addattr, dInfo.grade, args) 
-- end


function CItemEquipBox.HideFanQieBtn(self)
	-- body
	local iItemList = g_ItemCtrl:GetEquipList()
	local equiplist = {}
	for i,item in ipairs(iItemList) do
		if item.m_SData.pos > 100 then
			if item:IsEquip() and not item:IsSummonEquip()then
				table.insert(equiplist, item)
			end
		end
	end
	if #equiplist>1 then
		self.m_LeftBtn:SetActive(true)
		self.m_RightBtn:SetActive(true)
	else
		self.m_LeftBtn:SetActive(false)
		self.m_RightBtn:SetActive(false)
	end
end

return CItemEquipBox