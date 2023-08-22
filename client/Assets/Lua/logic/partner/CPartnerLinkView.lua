local CPartnerLinkView = class("CPartnerLinkView", CViewBase)

function CPartnerLinkView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/PartnerLinkView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_DepthType = "Dialog"
end

function CPartnerLinkView.OnCreateView(self)
	self.m_ActorTexture = self:NewUI(1, CActorTexture)
	self.m_ScoreL = self:NewUI(2, CLabel)
	self.m_NameL = self:NewUI(3, CLabel)
	self.m_CloseBtn = self:NewUI(4, CWidget)
	self.m_StarGrid = self:NewUI(5, CGrid)
	self.m_StarSprClone = self:NewUI(6, CSprite)
	self.m_EquipBtn = self:NewUI(7, CWidget)
	self.m_SpecialL = self:NewUI(8, CLabel)
	self.m_SkillListBox = self:NewUI(10, CPartnerSkillListBox)
	self.m_AttrBox = self:NewUI(11, CPartnerAttrBox)
	self.m_EquipGrid = self:NewUI(12, CGrid)
	self.m_EquipClone = self:NewUI(13, CBox)

	self.m_ItemIcon = {"h7_wuqi","h7_maozi","h7_shoushi","h7_yifu","h7_toushi","h7_xiezi"}

	self.m_EquipClone:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

----------------------reset data---------------------------------------------------
function CPartnerLinkView.SetPartner(self, pbdata)
	table.print(pbdata)
	self.m_PartnerInfo = data.partnerdata.INFO[pbdata.partnerdata.sid]
	self.m_PartnerSData = pbdata.partnerdata
	
	self.m_SkillListBox:SetPartnerId(self.m_PartnerInfo.id, true, self.m_PartnerSData)
	self.m_AttrBox:SetPartnerId(self.m_PartnerInfo.id, self.m_PartnerSData)
	
	self:RefreshAll()
end

----------------------refresh ui-------------------------------------------------
function CPartnerLinkView.RefreshAll(self)
	self:RefreshBaseInfo()
	self:RefreshActorTexture()
	self:RefreshEquipGrid()
end

function CPartnerLinkView.RefreshBaseInfo(self)
	self.m_SpecialL:SetText("擅长："..self.m_PartnerInfo.character)
	self.m_NameL:SetText(self.m_PartnerSData.grade.."级 "..self.m_PartnerInfo.name)
	local score = self.m_PartnerSData and self.m_PartnerSData.score or g_PartnerCtrl:GetPartnerScore(self.m_PartnerInfo.id)
	self.m_ScoreL:SetText("评分 ".. score)

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

function CPartnerLinkView.RefreshActorTexture(self)
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

function CPartnerLinkView.RefreshEquipGrid(self)
	for i=1,6 do
		local oBox = self.m_EquipGrid:GetChild(i)
		if not oBox then
			oBox = self:CreateEquipBox(i)
			self.m_EquipGrid:AddChild(oBox)
		end
		local dEquip = (self.m_PartnerSData and self.m_PartnerSData.equipsid) and self.m_PartnerSData.equipsid[i]
		self:RefreshEquipBox(oBox, dEquip)
	end
end

function CPartnerLinkView.CreateEquipBox(self, iIndex)
	local oBox = self.m_EquipClone:Clone()
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_QualitySpr = oBox:NewUI(2, CSprite)
	oBox.m_LvL = oBox:NewUI(3, CLabel)
	oBox.m_LinesSpr = oBox:NewUI(4, CSprite)
	oBox.m_StrengthenL = oBox:NewUI(5, CLabel)

	oBox.m_LinesSpr:SetSpriteName(self.m_ItemIcon[iIndex])
	oBox.m_LinesSpr:MakePixelPerfect()
	oBox:SetActive(true)

	oBox:AddUIEvent("click", callback(self, "OnClickEquip", oBox))
	return oBox
end

function CPartnerLinkView.RefreshEquipBox(self, oBox, dEquip)
	local bIsEmpty = dEquip == nil
	oBox.m_IconSpr:SetActive(not bIsEmpty)
	oBox.m_LvL:SetActive(not bIsEmpty)
	oBox.m_StrengthenL:SetActive(not bIsEmpty and dEquip.strength > 0)
	oBox.m_LinesSpr:SetActive(bIsEmpty)

	oBox.m_EquipInfo = dEquip
	if not dEquip then
		return
	end
	local iItemIcon = DataTools.GetPartnerEquipIcon(dEquip.equip_sid, dEquip.level)
	oBox.m_IconSpr:SpriteItemShape(iItemIcon)
	oBox.m_QualitySpr:SetItemQuality(0)
	oBox.m_LvL:SetText(dEquip.level.."级")
	oBox.m_StrengthenL:SetText("+"..dEquip.strength) 
end

function CPartnerLinkView.OnClickEquip(self, oBox)
	if not oBox.m_EquipInfo then
		return
	end
	CPartnerEquipTipsView:ShowView(function(oView)
		oView:SetEquipInfo(self.m_PartnerSData, oBox.m_EquipInfo, true)
	end)
end

return CPartnerLinkView