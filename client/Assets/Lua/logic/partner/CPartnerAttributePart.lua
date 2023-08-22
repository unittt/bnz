local CPartnerAttributePart = class("CPartnerAttributePart", CPageBase)

function CPartnerAttributePart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CPartnerAttributePart.OnInitPage(self)	
	self.m_ActorTexture = self:NewUI(1, CActorTexture)
	self.m_ScoreL = self:NewUI(2, CLabel)
	self.m_NameL = self:NewUI(3, CLabel)
	self.m_TipBtn = self:NewUI(4, CWidget)
	self.m_StarGrid = self:NewUI(5, CGrid)
	self.m_StarSprClone = self:NewUI(6, CSprite)
	self.m_EquipBtn = self:NewUI(7, CWidget)
	self.m_UpgradeBtn = self:NewUI(8, CButton, true, false)
	self.m_RecruitBox = self:NewUI(9, CBox)
	self.m_SkillListBox = self:NewUI(10, CPartnerSkillListBox)
	self.m_AttrBox = self:NewUI(11, CPartnerAttrBox)
	self.m_EquipGrid = self:NewUI(12, CGrid)
	self.m_EquipClone = self:NewUI(13, CBox)

	self.m_ItemIcon = {"h7_wuqi","h7_maozi","h7_shoushi","h7_yifu","h7_toushi","h7_xiezi"}

	self.m_EquipClone:SetActive(false)
	self:InitRecruitBox()
	self.m_TipBtn:AddUIEvent("click", callback(self, "ShowTipView"))
	self.m_EquipBtn:AddUIEvent("click", callback(self, "OnClickEquip"))
	self.m_UpgradeBtn:AddUIEvent("click", callback(self, "OnClickUpgrade"))
end

function CPartnerAttributePart.OnShowPage(self)
	self.m_ParentView.m_CloseBtn:SetLocalScale(Vector3.New(1, 1, 1))
	self.m_ParentView.m_CloseBtn:MakePixelPerfect()
	self.m_ParentView.m_CloseBtn:SetLocalPos(Vector3.New(442, 296, 0))
end

function CPartnerAttributePart.InitRecruitBox(self)
	local oBox = self.m_RecruitBox
	oBox.m_CostItemSpr = oBox:NewUI(1, CSprite)
	oBox.m_ItemCountL = oBox:NewUI(2, CLabel)
	oBox.m_ItemNameL = oBox:NewUI(3, CLabel)
	oBox.m_RecruitBtn = oBox:NewUI(4, CButton)
	oBox.m_RecruitGradeL = oBox:NewUI(5, CLabel)
	
	g_GuideCtrl:AddGuideUI("partner_recruit_btn", oBox.m_RecruitBtn)

	oBox.m_RecruitBtn:AddUIEvent("click", callback(self, "OnClickRecruit"))
end

----------------------reset data---------------------------------------------------
function CPartnerAttributePart.ResetPartnerInfo(self)
	self.m_PartnerInfo = self.m_ParentView:GetPartnerBoxNodeInfo()
	self.m_PartnerSData = g_PartnerCtrl:GetRecruitPartnerDataByID(self.m_PartnerInfo.id)

	self.m_SkillListBox:SetPartnerId(self.m_PartnerInfo.id)
	self.m_AttrBox:SetPartnerId(self.m_PartnerInfo.id)
	
	self:RefreshAll()
end

----------------------refresh ui-------------------------------------------------
function CPartnerAttributePart.RefreshAll(self)
	self:RefreshUpgradeOrRecruit()
	self:RefreshBaseInfo()
	self:RefreshActorTexture()
	self:RefreshRedPoint()
	self:RefreshEquipGrid()
	self:RefreshEquipRedPoint()
end

function CPartnerAttributePart.RefreshEquipRedPoint(self)
	for i=1,6 do
		local oBox = self.m_EquipGrid:GetChild(i)
		if oBox then
			oBox:DelEffect("RedDot")
			local dEquip = self.m_PartnerSData and self.m_PartnerSData.equipsid[i]
			if dEquip ~= nil then
				local dRedPoint = g_PartnerCtrl:GetEquipRedPoint(dEquip.equip_sid)

				--NOTE:强化出现频率过高，容易挡住字，去掉
				if dRedPoint ~= nil and (dRedPoint.upgrade) then
					oBox:AddEffect("RedDot", 20, Vector2(-17, -17))
					oBox.m_IgnoreCheckEffect = true
				end
			end
		end
	end
end

function CPartnerAttributePart.RefreshRedPoint(self)
	local iRedStatus = g_PartnerCtrl:GetRedPointStatus(self.m_PartnerInfo.id)

	local oRecruitBtn = self.m_RecruitBox.m_RecruitBtn
	if iRedStatus == define.Partner.RedPoint.Upgrade then
		self.m_UpgradeBtn.m_IgnoreCheckEffect = true
		self.m_UpgradeBtn:AddEffect("RedDot", 30, Vector2(-17, -17))
	elseif iRedStatus == define.Partner.RedPoint.Recruit then
		oRecruitBtn.m_IgnoreCheckEffect = true
		oRecruitBtn:AddEffect("RedDot", 20, Vector2(-13, -17))
	else
		oRecruitBtn:DelEffect("RedDot")
		self.m_UpgradeBtn:DelEffect("RedDot")
	end 
end

function CPartnerAttributePart.RefreshUpgradeOrRecruit(self)
	local bIsRecruit = not self.m_PartnerSData
	self.m_UpgradeBtn:SetActive(not bIsRecruit)
	self.m_RecruitBox:SetActive(bIsRecruit)
	if bIsRecruit then
		self:RefreshRecruitBox()
	end
end

function CPartnerAttributePart.RefreshRecruitBox(self)
	local condeitionStrs = string.split(self.m_PartnerInfo.pre_condition, "%:")
	if #condeitionStrs ~= 2 then
		printerror("错误：招募条件填写错误，伙伴ID", self.m_PartnerInfo.id)
		return
	end
	-- self.m_ConditionDesc:SetText("[c]#D招募条件：" .. condeitionSuffix)
	local item = DataTools.GetPartnerItem(self.m_PartnerInfo.cost.id)
	local bagAmount = g_ItemCtrl:GetPartnerItemAmountBySid(self.m_PartnerInfo.cost.id)
	self.m_IsEnoughtRecruit = bagAmount >= self.m_PartnerInfo.cost.amount
	local oBox = self.m_RecruitBox

	oBox.m_RecruitGradeL:SetActive(false)
	if condeitionStrs[1] == "LV" then
		oBox.m_RecruitGradeL:SetActive(true)
		oBox.m_RecruitGradeL:SetText(condeitionStrs[2].."级可招募")
	end
	oBox.m_CostItemSpr:SpriteItemShape(item.icon)
	oBox.m_ItemNameL:SetText(item.name)

	if self.m_IsEnoughtRecruit then
		oBox.m_ItemCountL:SetText(bagAmount.."/"..self.m_PartnerInfo.cost.amount)
	else
		oBox.m_ItemCountL:SetText(string.format("[c]#R%d#n[/c]/%d", bagAmount, self.m_PartnerInfo.cost.amount))
	end

	oBox.m_CostItemSpr:AddUIEvent("click", function()
		g_WindowTipCtrl:SetWindowGainItemTip(self.m_PartnerInfo.cost.id)
	end)
end

function CPartnerAttributePart.RefreshBaseInfo(self)
	self.m_NameL:SetText(self.m_PartnerInfo.name)
	self.m_ScoreL:SetText("评分 "..g_PartnerCtrl:GetPartnerScore(self.m_PartnerInfo.id))

	local iStarCnt = self.m_PartnerSData and self.m_PartnerSData.quality or 0
	local starBoxList = self.m_StarGrid:GetChildList()
	local oStarSpr = nil
	for i=1,5 do
		if i > #starBoxList then
			oStarSpr = self.m_StarSprClone:Clone()
			self.m_StarGrid:AddChild(oStarSpr)
			oStarSpr:SetActive(true)
		else
			oStarSpr = starBoxList[i]
		end
		oStarSpr:SetGrey(i > iStarCnt)
	end
end

function CPartnerAttributePart.RefreshActorTexture(self)
	local model_info = {}
	
	if self.m_PartnerSData then 
		model_info.shape = self.m_PartnerSData.model_info.shape
	else
		model_info.shape = self.m_PartnerInfo.shape
	end 

	self.m_ActorTexture:ChangeShape(model_info)
	local function playSound()
		local path = DataTools.GetAudioSound(self.m_PartnerInfo.sound)
		g_AudioCtrl:NpcPath(path)
	end
	self.m_ActorTexture:SetClickCallback(playSound)
end

function CPartnerAttributePart.RefreshEquipGrid(self)
	for i=1,6 do
		local oBox = self.m_EquipGrid:GetChild(i)
		if not oBox then
			oBox = self:CreateEquipBox(i)
			self.m_EquipGrid:AddChild(oBox)
		end
		local dEquip = self.m_PartnerSData and self.m_PartnerSData.equipsid[i]
		self:RefreshEquipBox(oBox, dEquip, i)
	end
end

function CPartnerAttributePart.CreateEquipBox(self, iIndex)
	local oBox = self.m_EquipClone:Clone()
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_QualitySpr = oBox:NewUI(2, CSprite)
	oBox.m_LvL = oBox:NewUI(3, CLabel)
	oBox.m_LinesSpr = oBox:NewUI(4, CSprite)
	oBox.m_StrengthenL = oBox:NewUI(5, CLabel)

	oBox.m_LinesSpr:SetSpriteName(self.m_ItemIcon[iIndex])
	oBox.m_LinesSpr:MakePixelPerfect()
	oBox:AddUIEvent("click", callback(self, "OnClickEquip", oBox))
	oBox:SetActive(true)
	return oBox
end

function CPartnerAttributePart.RefreshEquipBox(self, oBox, dEquip, iEquipPos)
	local bIsEmpty = dEquip == nil
	oBox.m_IconSpr:SetActive(not bIsEmpty)
	oBox.m_LvL:SetActive(not bIsEmpty)
	oBox.m_StrengthenL:SetActive(not bIsEmpty and dEquip.strength > 0)
	oBox.m_LinesSpr:SetActive(bIsEmpty)

	oBox.m_EquipInfo = dEquip
	oBox.m_EquipPos = iEquipPos
	if not dEquip then
		return
	end
	local iItemIcon = DataTools.GetPartnerEquipIcon(dEquip.equip_sid, dEquip.level)
	oBox.m_IconSpr:SpriteItemShape(iItemIcon)
	oBox.m_QualitySpr:SetItemQuality(0)
	oBox.m_LvL:SetText(dEquip.level.."级")
	oBox.m_StrengthenL:SetText("+"..dEquip.strength) 
end

function CPartnerAttributePart.CheckRecruitCost(self)
	if not self.m_PartnerInfo then return false end
	local items, currencys
	local itemId = self.m_PartnerInfo.cost.id
	local iNeedItem = self.m_PartnerInfo.cost.amount
	local count = g_ItemCtrl:GetPartnerItemAmountBySid(itemId)
	if count < iNeedItem then
		items = {{sid = itemId, count = count, amount = iNeedItem}}
	end
	local iSilver = self.m_PartnerInfo.silver
	-- printc(iSilver)
	-- table.print(self.m_PartnerInfo)
	-- if iSilver > 0 and iSilver > g_AttrCtrl.silver then
		currencys = {{sid = 1002, count = g_AttrCtrl.silver, amount = iSilver}}
	-- end
	if items or currencys then
		g_QuickGetCtrl:CurrLackItemInfo(items or {}, currencys or {}, nil, function()
			netpartner.C2GSRecruit(self.m_PartnerInfo.id, 1)
		end)
		return not g_QuickGetCtrl.m_IsLackItem
	end
	return true
end

----------------------click Event-----------------------------------------------
function CPartnerAttributePart.ShowTipView(self)
	local id = 4000
    local content = {
        title = data.instructiondata.DESC[id].title,
        desc  = data.instructiondata.DESC[id].desc
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(content)
end

function CPartnerAttributePart.OnClickUpgrade(self)
	self.m_ParentView:ShowPartnerUpgradeBox()	
end

function CPartnerAttributePart.OnClickRecruit(self)
	local condeitionStrs = string.split(self.m_PartnerInfo.pre_condition, "%:")
	if condeitionStrs[1] == "LV" and tonumber(condeitionStrs[2]) > g_AttrCtrl.grade then
		local tipStr = DataTools.GetPartnerTextInfo(1011).content
		g_NotifyCtrl:FloatMsg(tipStr)
		return
	end

	if not self:CheckRecruitCost() then
		return
	end
	-- if self.m_PartnerInfo.silver > 0 and self.m_PartnerInfo.silver > g_AttrCtrl.silver then
	-- 	local tipStr = DataTools.GetPartnerTextInfo(1012).content
	-- 	g_NotifyCtrl:FloatMsg(tipStr)
	-- 	return
	-- end

	-- -- 金币、银币
	-- local virtualConfig = {
	-- 	[1001] = "gold",
	-- 	[1002] = "silver",
	-- 	[1003] = "goldcoin",
	-- 	-- 绑金：TODO
	-- 	-- [1004] = ""
	-- }
	-- local itemType = nil

	-- local virtual = virtualConfig[self.m_PartnerInfo.cost.id]
	-- if virtual then
	-- 	if g_AttrCtrl[virtual] < self.m_PartnerInfo.cost.amount then
	-- 		itemType = "VIRTUAL"
	-- 	end
	-- else
	-- 	local count = g_ItemCtrl:GetPartnerItemAmountBySid(self.m_PartnerInfo.cost.id)
	-- 	if count < self.m_PartnerInfo.cost.amount then
	-- 		itemType = "PARTNER"
	-- 	end
	-- end
	-- if itemType then
	-- 	local item = DataTools.GetItemData(self.m_PartnerInfo.cost.id, itemType)
	-- 	-- local tipStr = string.format("#G%s[-]不足#R%s[-]，无法招募伙伴#G%s", item.name, self.m_PartnerInfo.cost.amount, self.m_PartnerInfo.name)
	-- 	local tipStr = ""
	-- 	if itemType == "VIRTUAL" then
	-- 		tipStr = DataTools.GetPartnerTextInfo(1012).content
	-- 	elseif itemType == "PARTNER" then
	-- 		tipStr = string.gsub(DataTools.GetPartnerTextInfo(1013).content, "#item", item.name)
	-- 	end
	-- 	g_NotifyCtrl:FloatMsg(tipStr)
	-- 	return
	-- end
	--引导相关
	if self.m_PartnerInfo.id == g_GuideHelpCtrl:GetPartner1() then
		CNpcShowView:ShowView(function (oView)
			oView:RefreshUI({parnter = self.m_PartnerInfo.id, summon = 0})
		end)
		g_MapCtrl.m_IsNpcCloseUp = true
		g_MapCtrl.m_IsNpcNeedShowInGuide = true
		g_GuideHelpCtrl.m_IsGetPartnerClick = true
		g_GuideCtrl:OnTriggerAll()
	end

	netpartner.C2GSRecruit(self.m_PartnerInfo.id)
end

function CPartnerAttributePart.OnClickEquip(self, oBox)
	if not oBox.m_EquipInfo then
		printc("OnClickEquip nil")
		return
	end
	CPartnerEquipTipsView:ShowView(function(oView)
		oView:SetEquipInfo(self.m_PartnerSData, oBox.m_EquipInfo, false, oBox.m_EquipPos)
	end)
end

return CPartnerAttributePart