local CNpcShowView = class("CNpcShowView", CViewBase)

function CNpcShowView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Task/NpcShowView.prefab", cb)
	--界面设置
	self.m_DepthType = "BeyondGuide"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Shelter"
end

function CNpcShowView.OnCreateView(self)
	self.m_ActorTexture = self:NewUI(1, CActorTexture)
	self.m_ParnetNamLab = self:NewUI(2, CLabel)
	self.m_ConfirmBtn = self:NewUI(3, CButton)
	self.m_EffectWidget = self:NewUI(4, CWidget)
	self.m_ParnetBg = self:NewUI(5, CSprite)
	self.m_ParnetDesLab = self:NewUI(6, CLabel)
	self.m_ParnetBox = self:NewUI(7, CBox)
	self.m_SummonBox = self:NewUI(8, CBox)
	self.m_SummonNameBG = self:NewUI(9, CLabel)
	self.m_SummonNameLab = self:NewUI(10, CLabel)
	self.m_TypeSp = self:NewUI(11, CSprite)
	self.m_TypeHuobanSp = self:NewUI(12, CSprite)

	self.m_NpcType = {
		Partner = 1,
		Summon = 2,
	}
	self:InitContent()
end

function CNpcShowView.InitContent(self)	
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnClickConfirm"))
end

function CNpcShowView.RefreshUI(self, pbdata)
	if not pbdata or (pbdata.parnter == 0 and pbdata.summon == 0) then
		return
	end
	self.m_ShowData = pbdata
	self.m_EffectWidget:DelEffect("Screen")
	self.m_EffectWidget:AddEffect("Screen", "ui_eff_0068")
	if pbdata.parnter ~= 0 then
		-- self.m_TypeSp:SetStaticSprite("CommonAtlas", "huoban_03")
		-- self.m_TypeSp:MakePixelPerfect()
		self.m_TypeSp:SetActive(false)
		self.m_TypeHuobanSp:SetActive(true)
		self.m_ParnetBox:SetActive(true)
		self.m_SummonBox:SetActive(false)
		self.m_ActorTexture:SetEnabled(true)
		self.m_ActorTexture:SetClickCallback(callback(self, "OnClickTexture"))
		self.m_CurType = self.m_NpcType.Partner 
		local config = DataTools.GetPartnerInfo(pbdata.parnter)
		self.m_ParnetNamLab:SetText(config.name)
		self.m_ParnetDesLab:SetText(config.character)
		local h = self.m_ParnetDesLab:GetHeight()
		self.m_ParnetBg:SetHeight(h+50)
		
		local model_info = {}
		model_info.shape = data.modeldata.CONFIG[config.shape].model
		model_info.rendertexSize = 1
		self.m_ActorTexture:ChangeShape(model_info, function ()
			local sShowName = "show"
			-- local clipInfo = ModelTools.GetAnimClipData(data.modeldata.CONFIG[config.shape].model)
			-- if clipInfo and clipInfo.show2 then
			-- 	sShowName = "show2"
			-- end
			local oActor = self.m_ActorTexture.m_ActorCamera and self.m_ActorTexture.m_ActorCamera:GetActor()
			-- local shape = oActor.m_LoadDoneModelList["main"]:GetShape()
			oActor:CrossFade(sShowName)
			-- local function cb()				
			-- 	oActor:CrossFade(sShowName)
			-- end
			-- oActor.m_LoadDoneModelList["main"]:ReloadAnimator(shape, 2, cb)		
		end)
	elseif pbdata.summon ~= 0 then
		self.m_ParnetBox:SetActive(false)
		self.m_SummonBox:SetActive(true)
		-- self.m_ActorTexture:SetEnabled(false)
		self.m_CurType = self.m_NpcType.Summon
		local config = DataTools.GetSummonInfo(pbdata.summon)
		self.m_TypeSp:SetActive(true)
		self.m_TypeHuobanSp:SetActive(false)
		self.m_TypeSp:SetStaticSprite("CommonAtlas", data.summondata.SUMMTYPE[config.type].icon)
		self.m_TypeSp:MakePixelPerfect()
		self.m_SummonNameLab:SetText(config.name)
		local model_info = {}
		model_info.shape = data.modeldata.CONFIG[config.shape].model
		model_info.rendertexSize = 1
		self.m_ActorTexture:ChangeShape(model_info, function ()
			local sShowName = "show"
			-- local clipInfo = ModelTools.GetAnimClipData(data.modeldata.CONFIG[config.shape].model)
			-- if clipInfo and clipInfo.show2 then
			-- 	sShowName = "show2"
			-- end
			local oActor = self.m_ActorTexture.m_ActorCamera and self.m_ActorTexture.m_ActorCamera:GetActor()
			-- local shape = oActor.m_LoadDoneModelList["main"]:GetShape()
			oActor:CrossFade(sShowName)
			-- local function cb()
			-- 	oActor:CrossFade(sShowName)
			-- end
			-- oActor.m_LoadDoneModelList["main"]:ReloadAnimator(shape, 2, cb)	
		end)
	end
end

function CNpcShowView.OnClickConfirm(self)
	self:CloseView()
end

function CNpcShowView.OnHideView(self)
	g_MapCtrl.m_IsNpcCloseUp = false
	for k,v in pairs(g_MapCtrl.m_NpcShowEndCbList) do
		if v then
			v()
		end
	end
	g_MapCtrl.m_NpcShowEndCbList = {}
	g_NotifyCtrl:SetFloatTableActive(true)
	if self.m_ShowData and self.m_ShowData.parnter and self.m_ShowData.parnter ~= 0 then
		g_NotifyCtrl:FloatMsg("#G"..DataTools.GetPartnerInfo(self.m_ShowData.parnter).name.."#n加入队伍")
	end
end

function CNpcShowView.OnClickTexture(self)
	if self.m_CurType == self.m_NpcType.Partner then
		local oActor = self.m_ActorTexture.m_ActorCamera and self.m_ActorTexture.m_ActorCamera:GetActor()
		if not oActor then
			return
		end
		oActor:CrossFade("show")
	end
end

return CNpcShowView