local CFormationSettingBox = class("CFormationSettingBox", CBox)

function CFormationSettingBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_PosBoxs = {}
	self.m_ActorTextures = {}
	for i=1,5 do
		self.m_PosBoxs[i] = self:NewUI(i, CBox)
	end

	self.m_SwapPos = 0
	self.m_DefaultPos = Vector3.New(0, 10, 0) 
	self.m_SpecialShape = {
		[2301] = true --白素贞特殊处理雨伞
	}
	self.m_ActorTouchEabled = true

	self:InitContent()
end

function CFormationSettingBox.SetListener(self, cb)
	self.m_callback = cb
end

function CFormationSettingBox.EnableTouchActor(self, b)
	self.m_ActorTouchEabled = b
	for k,v in pairs(self.m_ActorTextures) do
		v:SetDragEnable(b)
	end
end

function CFormationSettingBox.InitContent(self)
	self:InitPosBox()
	for k,v in pairs(self.m_ActorTextures) do
		v:SetClickListener(callback(self,"OnClickActor"))
		v:SetDragStartListener(callback(self, "OnDragActorStart"))
		v:SetDragEndListener(callback(self, "OnDragActorEnd"))
	end
end 

function CFormationSettingBox.InitPosBox(self)
	for i=1,5 do
		local oBox = self.m_PosBoxs[i]
		oBox.m_ActorTexture = oBox:NewUI(1, CFormationActorTexture)
		oBox.m_DefaultSpr = oBox:NewUI(2, CSprite)
		oBox.m_SchoolSpr = oBox:NewUI(3, CSprite)
		oBox.m_SwapSpr = oBox:NewUI(4, CSprite)
		oBox.m_NameL = oBox:NewUI(5, CLabel)
		oBox.m_BgSpr = oBox:NewUI(6, CSprite)

		oBox.m_ActorTexture:SetFormationPos(i)
		self.m_ActorTextures[i] = oBox.m_ActorTexture
	end
end

function CFormationSettingBox.SwapPos(self, pos1, pos2, iType)
	local list = nil
	if iType == CFormationActorTexture.Type.Player then
		list = self.m_PlayerList
	else
		list = self.m_PartnerList
	end
	local temp = list[pos1]
	list[pos1] = list[pos2]
	list[pos2] = temp

	self:RefreshUI()
end

function CFormationSettingBox.GetPosList(self)
	return self.m_PlayerList, self.m_PartnerList
end

-----------------------------ui refresh----------------------------------
function CFormationSettingBox.SetSelSprite(self, iFmtPos)
	for i,oBox in ipairs(self.m_PosBoxs) do
		if oBox.m_ActorTexture.m_FmtPos ~= 1 and 
			oBox.m_ActorTexture.m_FmtPos ~= iFmtPos and 
			oBox.m_ActorTexture:GetType() == self.m_SelectedType and 
			not oBox.m_DefaultSpr:GetActive() then
			oBox.m_SwapSpr:SetActive(true)
			oBox.m_BgSpr:SetSpriteName("h7_zhenfadi 1")
			oBox.m_NameL:SetColor(Color.RGBAToColor("a64e00"))
		end
	end
	-- local oBox = self.m_PosBoxs[iFmtPos] 
	-- oBox.m_SwapSpr:SetActive(true)
	-- self.m_SelSprite = oBox.m_SwapSpr
end

function CFormationSettingBox.ResetSelSprite(self)
	self.m_SwapPos = 0
	self.m_SelectedType = -1
	-- if self.m_SelSprite then
	-- 	self.m_SelSprite:SetActive(false)
	-- 	self.m_SelSprite = nil
	-- end
	for i,oBox in ipairs(self.m_PosBoxs) do
		oBox.m_SwapSpr:SetActive(false)
		oBox.m_BgSpr:SetSpriteName("h7_zhenfadi_1")
		oBox.m_NameL:SetColor(Color.RGBAToColor("244B4E"))
	end
end

function CFormationSettingBox.SetFormationInfo(self, dInfo, tPlayerList, tPartnerList)
	self.m_FmtId = dInfo.fmt_id
	self.m_FormationInfo = dInfo
	self.m_Grade = dInfo.grade
	self.m_PlayerList = tPlayerList
	self.m_PartnerList = tPartnerList
	self:ResetSelSprite()
end

function CFormationSettingBox.RefreshUI(self)
	self:RefreshActorTextures()
	-- self:RefreshActorPos()
end

function CFormationSettingBox.ResetAllActor(self)
	for i,oActor in ipairs(self.m_ActorTextures) do
		local oBox = self.m_PosBoxs[i]
		oBox.m_NameL:SetText("")
		oBox.m_SchoolSpr:SetActive(false)
		oBox.m_SwapSpr:SetActive(false)
		oBox.m_DefaultSpr:SetActive(true)
		oActor:SetActive(false)
	end
end

function CFormationSettingBox.RefreshActorTextures(self)
	self:ResetAllActor()
	self:RefreshActorPos()
	local iCount = 0
	for i,iPid in ipairs(self.m_PlayerList) do
		local oMember = g_TeamCtrl:GetMember(iPid)
		local oBox = self.m_PosBoxs[i]

		local model_info = nil
		if not oMember and iPid == g_AttrCtrl.pid then
			model_info = g_AttrCtrl.model_info
		end
		if oMember then
			model_info = oMember.model_info
		end
		if model_info then
			local oActor = self.m_ActorTextures[i]
			self:RefreshActorTexture(oActor, model_info, oActor.Type.Player, i)
			iCount = iCount + 1
		end
		self:RefreshBaseInfo(oBox, oMember)
	end
	if not self.m_PartnerList then
		return
	end
	for i,iPid in ipairs(self.m_PartnerList) do
		if iCount >= 5 then
			break
		end
		local oPartner = g_TeamCtrl:GetTeamPartnerById(iPid) or g_PartnerCtrl:GetRecruitPartnerDataBySID(iPid)
		if oPartner then
			iCount = iCount + 1
			local oActor = self.m_ActorTextures[iCount]
			local oBox = self.m_PosBoxs[iCount]
			self:RefreshActorTexture(oActor, oPartner.model_info, oActor.Type.Partner, i)
			self:RefreshBaseInfo(oBox, nil, oPartner)
		end
	end
end

function CFormationSettingBox.RefreshActorTexture(self, oActor, dModelInfo, iType, iPos)
	local modelInfo = table.copy(dModelInfo)
	modelInfo.horse = nil

	local bIsSpecial = self.m_SpecialShape[modelInfo.shape]
	if bIsSpecial then
		modelInfo.rendertexSize = 1
		modelInfo.scale = 1100
		modelInfo.pos = Vector3.New(0, -0.83, 3)
	end

	oActor:SetActive(true)
	oActor:ChangeShape(modelInfo)
	oActor:SetType(iType)
	oActor:SetTablePos(iPos)
end

function CFormationSettingBox.RefreshBaseInfo(self, oPosBox, oMember, oPartner)
	local sName, iSchool
	if oMember then
		sName = oMember.name
		iSchool = oMember.school
	elseif oPartner then
		local dPartnerData = data.partnerdata.INFO[oPartner.sid]
		sName = dPartnerData.name
		iSchool = dPartnerData.school
	else
		sName = g_AttrCtrl.name
		iSchool = g_AttrCtrl.school
	end
	oPosBox.m_NameL:SetText(sName)
	oPosBox.m_SchoolSpr:SpriteSchool(iSchool)
	oPosBox.m_SchoolSpr:SetActive(true)
	oPosBox.m_DefaultSpr:SetActive(false)
end

function CFormationSettingBox.RefreshActorPos(self)
	for i,oActor in ipairs(self.m_ActorTextures) do
		oActor:SetLocalPos(self.m_DefaultPos)
	end
end

------------------------------ui event---------------------------------------
function CFormationSettingBox.OnClickActor(self, oActor)
	if not self.m_ActorTouchEabled then
		g_NotifyCtrl:FloatMsg("只有队长才能调整站位")
		return
	end
	if self.m_SelectedType ~= oActor:GetType() then
		self:ResetSelSprite()
	end
	if self.m_SwapPos == 0 then
		self.m_SwapPos = oActor.m_TablePos
		self.m_SelectedType = oActor:GetType()
		self:SetSelSprite(oActor.m_FmtPos)
	elseif self.m_SwapPos ~= oActor.m_TablePos then
		self:SwapPos(self.m_SwapPos, oActor.m_TablePos, self.m_SelectedType)
		if self.m_callback then
			self.m_callback()
		end
		self:ResetSelSprite()
		g_FormationCtrl:SetLocalPosList(self.m_FmtId, self.m_PlayerList)
	end
end


function CFormationSettingBox.OnDragActorStart(self, oActor)
	if not self.m_ActorTouchEabled then
		return
	end
	self.m_SwapPos = oActor.m_TablePos
	self.m_SelectedType = oActor:GetType()
	self:SetSelSprite(oActor.m_FmtPos)
end

function CFormationSettingBox.OnDragActorEnd(self, oActor)
	if not self.m_ActorTouchEabled then
		return
	end
	local oCurBounds = oActor:CalculateBounds(self.m_Transform)
	local oTargetActor = nil
	for k,v in pairs(self.m_ActorTextures) do
		 local oBounds =  v:CalculateBounds(self.m_Transform)
		 if v.m_TablePos ~= oActor.m_TablePos and oBounds:Contains(oCurBounds.center) and 
		 	v:GetType() == self.m_SelectedType then
		 	oTargetActor = v
		 	break
		 end
	end
	if oTargetActor and oTargetActor:GetActive() and not oTargetActor:IsTeamLeader() then
		self:OnClickActor(oTargetActor)
	else
		self:RefreshActorPos()
	end
end
return CFormationSettingBox

