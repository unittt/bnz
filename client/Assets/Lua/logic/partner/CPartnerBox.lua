local CPartnerBox = class("CPartnerBox", CBox)
CPartnerBox.typeSprName = {
	"h7_fashu",
	"h7_wuli",
	"h7_zhiliao",
	"h7_fengying",
	"h7_fuzu", 
}

CPartnerBox.StatusSpr = {
	["fight"] = "h7_zhanli",
	["recruit"] = "h7_kezhaowu",
	["lock"] = "h7_weizhaowu",
}

function CPartnerBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_IconSprite = self:NewUI(1, CSprite)
	self.m_Quality = self:NewUI(2, CSprite)
	self.m_StartGrid = self:NewUI(3, CGrid)
	self.m_StartClone = self:NewUI(4, CSprite)
	self.m_NameLabel = self:NewUI(5, CLabel)
	self.m_GradeLabel = self:NewUI(6, CLabel)
	self.m_TypeSprite = self:NewUI(7, CSprite)
	self.m_FactionIcon = self:NewUI(8, CSprite)
	self.m_FactionName = self:NewUI(9, CLabel)
	self.m_TipSprite = self:NewUI(10, CSprite)
	self.m_LineupSpr = self:NewUI(11, CSprite)
	self.m_SelNameLabel = self:NewUI(12, CLabel)
	self.m_SelFactionName = self:NewUI(13, CLabel)
	self.m_StartClone:SetActive(false)
end

function CPartnerBox.SetPartnerBox(self, partnerInfo)
	local partnerData = g_PartnerCtrl:GetRecruitPartnerDataByID(partnerInfo.id)
	self.m_IconSprite:SpriteAvatar(partnerInfo.shape)
	--TODO:品质用星星取代
	local quality = (partnerData and partnerData.quality or partnerInfo.quality) - 1
	self.m_Quality:SetItemQuality(quality)
	self.m_NameLabel:SetText(partnerInfo.name)
	self.m_SelNameLabel:SetText(partnerInfo.name)
	local gradeStr = partnerData and partnerData.grade .. "级" or ""
	self.m_GradeLabel:SetText(gradeStr)
	-- local partnerType = DataTools.GetPartnerType(partnerInfo.type)
	self.m_TypeSprite:SetSpriteName(CPartnerBox.typeSprName[partnerInfo.type])
	local schoolInfo = data.schooldata.DATA[partnerInfo.school]
	self.m_FactionIcon:SpriteSchool(schoolInfo.icon)
	self.m_FactionName:SetText(partnerInfo.style)
	self.m_SelFactionName:SetText(partnerInfo.style)
	self:SetStart(partnerData and partnerData.upper or 0)

	local iRedPointStatus = g_PartnerCtrl:GetRedPointStatus(partnerInfo.id)
	if iRedPointStatus ~= nil then
		self.m_IgnoreCheckEffect = true
		self:AddEffect("RedDot", 20, Vector2(-13, -17))
	else
		self:DelEffect("RedDot")
	end

	local sStatusSpr = ""
	if partnerData and g_PartnerCtrl:IsInCurLineup(partnerData.id) then
		sStatusSpr = CPartnerBox.StatusSpr.fight
	elseif iRedPointStatus == define.Partner.RedPoint.Recruit then
		sStatusSpr = CPartnerBox.StatusSpr.recruit
	elseif partnerData == nil then
		sStatusSpr = CPartnerBox.StatusSpr.lock
	end
	self.m_TipSprite:SetSpriteName(sStatusSpr)
end

function CPartnerBox.SetStart(self, count)
	local startBoxList = self.m_StartGrid:GetChildList()
	local startBox = nil
	-- for i=1,5 do
	-- 	if i > #startBoxList then
	-- 		startBox = self.m_StartClone:Clone()
	-- 		self.m_StartGrid:AddChild(startBox)
	-- 		startBox:SetActive(true)
	-- 	else
	-- 		startBox = startBoxList[i]
	-- 	end
	-- 	startBox:SetGrey(i > count)
	-- end
end

function CPartnerBox.ShowLineupSprite(self, bIsShow)
	self.m_LineupSpr:SetActive(bIsShow)
end

function CPartnerBox.FiterLineupPartner(self, bIsFiter)
	self:SetGrey(bIsFiter)
	self.m_IconSprite:SetGrey(bIsFiter)
	self.m_Quality:SetGrey(bIsFiter)
	self.m_TypeSprite:SetGrey(bIsFiter)
	self.m_FactionIcon:SetGrey(bIsFiter)
	self.m_TipSprite:SetGrey(bIsFiter)
	self:EnableTouch(not bIsFiter)
end
return CPartnerBox