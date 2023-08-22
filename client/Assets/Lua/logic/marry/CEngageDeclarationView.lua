local CEngageDeclarationView = class("CEngageDeclarationView", CViewBase)

function CEngageDeclarationView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Marry/EngageDeclarationView.prefab", cb)

	self.m_GroupName = "main"
	self.m_DepthType = "Middle"
    --self.m_ExtendClose = "Shelter"
end


function CEngageDeclarationView.LoadDone(self)
	CViewBase.LoadDone(self)
	g_ViewCtrl:ShowByGroup(self.m_GroupName)
end

function CEngageDeclarationView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TipLbl = self:NewUI(2, CLabel)
	self.m_NpcTexture = self:NewUI(3, CActorTexture)
	self.m_RingSp = self:NewUI(4, CSprite)
	self.m_RingLbl = self:NewUI(5, CLabel)
	self.m_Input = self:NewUI(6, CInput)
	self.m_Btn = self:NewUI(7, CButton)
	self.m_WaitLbl = self:NewUI(8, CLabel)

	self:InitContent()
end

function CEngageDeclarationView.InitContent(self)
	-- body
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnCloseView"))
	self.m_Btn:AddUIEvent("click", callback(self, "OnBtnClick"))
	self.m_Input:AddUIEvent("select", callback(self, "OnInputSelect"))
	g_EngageCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEngageEvent"))

	self.m_Input:SetCharLimit(20)
	local dtext = DataTools.GetEngageData("TEXT", 1013)
	self.m_DefaultText = dtext.content
	self.m_Input:SetDefaultText(self.m_DefaultText)
	-- initRing --
	local dConfig = g_EngageCtrl:GetRingConfig()
	local atlas, icon = dConfig.atlas, dConfig.icon
	self.m_RingSp:SetStaticSprite(atlas, icon)
	self.m_RingSp:AddEffect(dConfig.ringEffect, nil, 1) --戒指等级特效，默认显示1级

	local t = {"银", "金", "钻石"}
	local desc = t[dConfig.type].."戒指礼包"
	self.m_RingLbl:SetText(desc)

	self.m_RingLbl:SetGradientTop(Color.RGBAToColor(dConfig.color.top))
	self.m_RingLbl:SetGradientBottom(Color.RGBAToColor(dConfig.color.bottom))
	self.m_RingLbl:SetEffectColor(Color.RGBAToColor(dConfig.color.shadow))

	local label = data.engagedata.TEXT[1031].content
	local name = g_EngageCtrl:GetTeamParterName()
	local mReplace = {type = t[dConfig.type], role = name}

	local text = string.FormatString(label, mReplace, true)  --todo
	self.m_TipLbl:SetText("[63432C]"..text)

	self:InitNpcTexture()

end

function CEngageDeclarationView.InitNpcTexture(self)
	local model_info = g_EngageCtrl:GetNpcModelInfo()
	self.m_NpcTexture:ChangeShape(model_info)
end

function CEngageDeclarationView.OnEngageEvent(self, oCtrl)
	local successID = define.Engage.Event.EngageSuccess
	local failID = define.Engage.Event.EngageFail
	if oCtrl.m_EventID == successID or oCtrl.m_EventID == failID then
		self:CloseView()
		g_EngageCtrl.m_IsCannotMove = false
	end
end

function CEngageDeclarationView.OnCloseView(self)
	local name = g_EngageCtrl:GetTeamParterName()
	 -- 1027 --
	local dtext = data.engagedata.TEXT[1027].content
	local text = string.FormatString(dtext, {role = name}, true)
	local msg = "[63432C]"..text
	local args = {
		msg = msg,
		okCallback = function()
			netengage.C2GSCancelEngage()
		end,
		color = Color.white,
	}
	g_WindowTipCtrl:SetWindowConfirm(args)
end

function CEngageDeclarationView.HideBtn(self)
	self.m_Btn:SetActive(false)
	self.m_WaitLbl:SetActive(true)
end

function CEngageDeclarationView.OnInputSelect(self)
	self.m_Input:SetDefaultText(self.m_DefaultText)
end

function CEngageDeclarationView.OnBtnClick(self)
	-- todo --
	local msg1 =  data.engagedata.TEXT[1033].content 
	local msg2 = data.engagedata.TEXT[1034].content    
	local text = self.m_Input:GetText()
	if text:len() == 0 then
		local defaultText = self.m_Input:GetDefaultText()

		if defaultText:find("[896055FF]") then
			text = string.sub(defaultText, 14, -4)
		else
			text = defaultText
		end
	end

	if string.isIllegal(text) == false then
         g_NotifyCtrl:FloatMsg(msg1)
         return
    end

	local bMaskWord = g_EngageCtrl:ContainsMaskWordAndHighlight(text, self.m_Input, msg2)
	if not bMaskWord then --敏感字字符
		netengage.C2GSSetEngageText(text)
	end
	
end

function CEngageDeclarationView.Destroy(self)
	g_EngageCtrl.m_IsCannotMove = false
	CViewBase.Destroy(self)
end

return CEngageDeclarationView