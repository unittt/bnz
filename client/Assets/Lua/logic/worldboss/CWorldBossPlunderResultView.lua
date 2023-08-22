local CWorldBossPlunderResultView = class("CWorldBossPlunderResultView", CViewBase)

function CWorldBossPlunderResultView.ctor(self, cb)
	CViewBase.ctor(self, "UI/WorldBoss/WorldBossPlunderResultView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"
end

function CWorldBossPlunderResultView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_OkBtn = self:NewUI(2, CButton)
	self.m_ResultL = self:NewUI(3, CLabel)
	self.m_TitleL = self:NewUI(4, CLabel)
	self.m_PlayerBox = self:NewUI(5, CBox)
	
	self:InitContent()
end

function CWorldBossPlunderResultView.InitContent(self)
	self:InitPlayerBox()
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_OkBtn:AddUIEvent("click", callback(self, "OpenWorldBossView"))
end

function CWorldBossPlunderResultView.InitPlayerBox(self)
	local oBox = self.m_PlayerBox
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_NameL = oBox:NewUI(2, CLabel)
	-- oBox.m_ScoreL = oBox:NewUI(3, CLabel)
	oBox.m_SchoolSpr = oBox:NewUI(4, CSprite)
	oBox.m_HonorL = oBox:NewUI(5, CLabel)
	oBox.m_GradeL = oBox:NewUI(6, CLabel)
	oBox.m_ParnterSprs = {
		[1] = oBox:NewUI(7, CSprite),
		[2] = oBox:NewUI(8, CSprite),
	}
	oBox.m_HurtSprClone = oBox:NewUI(9, CSprite)
	oBox.m_HurtSprClone:SetActive(false)
end

function CWorldBossPlunderResultView.SetPlunderResult(self, dResult)
	self.m_ResultInfo = dResult 
	self:RefreshPlyerBox()
	self:RefreshBaseInfo()
end

function CWorldBossPlunderResultView.RefreshPlyerBox(self)
	local oBox = self.m_PlayerBox
	local dInfo = self.m_ResultInfo
	local sSchoolName = data.schooldata.DATA[dInfo.school].name

	local function AddHurtSpr(oSpr)
		local oHurtL = oBox.m_HurtSprClone:Clone()
		oHurtL:SetLocalPos(Vector3.zero)
		oHurtL:SetActive(true)
		oHurtL:SetParent(oSpr.m_Transform)
	end

	oBox.m_IconSpr:SpriteAvatar(dInfo.player.sid)
	oBox.m_NameL:SetText(dInfo.name)
	-- oBox.m_ScoreL:SetText(dInfo.score)
	oBox.m_SchoolSpr:SpriteSchool(dInfo.school)
	--TODO:未修改 门派改头衔
	oBox.m_HonorL:SetText(sSchoolName)
	oBox.m_GradeL:SetText(dInfo.grade.."级")
	for i,oPartnerSpr in ipairs(oBox.m_ParnterSprs) do
		local dPartner = dInfo.partner[i]
		if dPartner then
			local dData = DataTools.GetPartnerInfo(dPartner.sid)
			oPartnerSpr:SpriteAvatar(dData.shape)
			if dPartner.die == 1 then
				AddHurtSpr(oPartnerSpr)
			end
		else
			oPartnerSpr:SetActive(false)
		end
	end
	if dInfo.player.die == 1 then
		AddHurtSpr(oBox.m_IconSpr)
	end
end

function CWorldBossPlunderResultView.RefreshBaseInfo(self)
	if self.m_ResultInfo.win_side == 1 then
		self.m_TitleL:SetText("抢夺成功")
		self.m_ResultL:SetText(self.m_ResultInfo.point)--string.format("抢夺成功，获得%s积分", self.m_ResultInfo.point))
	else 
		self.m_TitleL:SetText("抢夺失败")
		self.m_ResultL:SetText(0)--"抢夺失败，未获得积分")
	end
end

function CWorldBossPlunderResultView.OpenWorldBossView(self)
	CWorldBossMainView:ShowView()
	self:CloseView()
end

return CWorldBossPlunderResultView