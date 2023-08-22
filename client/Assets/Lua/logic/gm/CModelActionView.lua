local CModelActionView = class("CModelActionView", CViewBase)

function CModelActionView.ctor(self, cb)
	CViewBase.ctor(self, "UI/GM/ModelActionView.prefab", cb)
end

function CModelActionView.OnCreateView(self)
	self.m_Input = self:NewUI(1, CInput)
	self.m_ConfirmModel = self:NewUI(2, CButton)
	self.m_ConfirmFigure = self:NewUI(3, CButton)
	self.m_ChangeAnimator = self:NewUI(4, CButton)
	self.m_CloseBtn = self:NewUI(5, CButton)
	self.m_ActionGrid = self:NewUI(6, CGrid)
	self.m_CloneBtn = self:NewUI(7, CButton)

	self.m_CloneBtn:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ConfirmModel:AddUIEvent("click", callback(self, "ChangeShape"))
	self.m_ConfirmFigure:AddUIEvent("click", callback(self, "ChangeFigure"))
	self.m_ChangeAnimator:AddUIEvent("click", callback(self, "ChangeAnimator"))
	-- self.m_Input:SetPermittedChars("0", "9")
	self:InitActionBtn(g_AttrCtrl.model_info.shape)

	self.m_CurShape = 1110
	self.m_AnimatorFlag = 1
	CGmMainView:CloseView()
end

function CModelActionView.InitActionBtn(self, shape, isWar)
	self.m_CurShape = shape
	local fileTable = IOTools.GetFiles(IOTools.GetGameResPath(string.format("/Model/Character/%d/Anim/", shape)), "*.anim", false)
	local actionTable = {}
	for k,v in ipairs(fileTable) do
		local _, _, action = string.find(v, "/(%w+).anim")
		if action then
			table.insert(actionTable, action)
		end
	end

	self.m_ActionGrid:Clear()
	for k, v in ipairs(actionTable) do
		local oBtn = self.m_CloneBtn:Clone(false)
		oBtn:SetActive(true)
		oBtn:SetText(v)
		oBtn:AddUIEvent("click", callback(self, "SetAction", v))
		self.m_ActionGrid:AddChild(oBtn)
	end
end

function CModelActionView.SetAction(self, action)
	local oHero = g_MapCtrl:GetHero()
	oHero:CrossFade(action, 0.1)
end

function CModelActionView.ChangeShape(self)
	local strs  = string.split(self.m_Input:GetText(), ' ')
	local shape = tonumber(strs[1])
	local weapon = tonumber(strs[2])
	if weapon and string.len(strs[2]) ~= 5 then
		g_NotifyCtrl:FloatMsg("## 非法的武器 ##", weapon)
		return
	end
	local oHero = g_MapCtrl:GetHero()
	if shape and oHero then
		local model_info = {
			shape = shape,
			weapon = weapon,
			Shenqi = shape > 8300 and shape < 8310
		}
		oHero:ChangeShape(model_info)
		self:InitActionBtn(shape)
		self.m_AnimatorFlag = 1
	end
end

function CModelActionView.ChangeFigure(self)
	local strs  = string.split(self.m_Input:GetText(), ' ')
	local figure = tonumber(strs[1])
	local weapon = tonumber(strs[2])
	if weapon and string.len(strs[2]) ~= 5 then
		g_NotifyCtrl:FloatMsg("## 非法的武器 ##", weapon)
		return
	end
	local oHero = g_MapCtrl:GetHero()
	if figure and oHero then
		local modelConfig = ModelTools.GetModelConfig(figure)
		local shape = modelConfig.model
		local model_info = {
			--shape = shape,
			figure = figure,
			weapon = weapon,
			scale = modelConfig.scale,
			Shenqi = shape > 8300 and shape < 8310
		}
		oHero:ChangeShape(model_info)
		self:InitActionBtn(shape)
		self.m_AnimatorFlag = 1
	end
end

function CModelActionView.ChangeAnimator(self)
	self.m_AnimatorFlag = self.m_AnimatorFlag == 1 and 2 or 1
	local oHero = g_MapCtrl:GetHero()
	oHero.m_Actor.m_LoadDoneModelList["main"]:ReloadAnimator(self.m_CurShape, self.m_AnimatorFlag)
end

return CModelActionView