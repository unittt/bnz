local CDissolveEngageView = class("CDissolveEngageView", CViewBase)

function CDissolveEngageView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Marry/DissolveEngageView.prefab", cb)

	self.m_GroupName = "main"
    self.m_ExtendClose = "Shelter"
end

function CDissolveEngageView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_NpcTexture = self:NewUI(2, CActorTexture)
	self.m_PreDissolveNode = self:NewUI(3, CBox)
	self.m_DissolveNode = self:NewUI(4, CBox)
	
	--self.m_DissolveNode:SetActive(false)

	self:InitContent()
end

function CDissolveEngageView.InitContent(self)
	-- todo --
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))

	self:InitPreDissNode()
	self:InitDissolveNode()
	self:InitNpcTexture()
end

function CDissolveEngageView.InitPreDissNode(self)
	local pDissolve = self.m_PreDissolveNode
	pDissolve.m_Title = pDissolve:NewUI(1, CLabel)
	pDissolve.m_Desc = pDissolve:NewUI(2, CLabel)
	pDissolve.m_Btn = pDissolve:NewUI(3, CButton)

	local dText = data.engagedata.TEXT

	--解除订婚费用
	self.m_Resume = g_EngageCtrl:GetCDissolveEngageResume()
	local cost = tostring(self.m_Resume)
	local title = dText[5005].content
	local msg = string.gsub(title, "#count", tostring(cost).."#cur_4")
	pDissolve.m_Title:SetText(msg)
	
	local desc = dText[5001].content
	for i=5002, 5004 do
		desc = desc.."\n"..dText[i].content
	end
	pDissolve.m_Desc:SetText(desc)
	pDissolve.m_Btn:AddUIEvent("click", callback(self, "OnPreDissClick"))

end

function CDissolveEngageView.InitDissolveNode(self)
	local dissolve = self.m_DissolveNode
	dissolve.m_Title = dissolve:NewUI(1, CLabel)
	dissolve.m_Desc = dissolve:NewUI(2, CLabel)
	dissolve.m_Btn = dissolve:NewUI(3, CButton)

	local dText = data.engagedata.TEXT

	local text1 = dText[5006].content
	dissolve.m_Title:SetText(text1)
	local text2 = dText[5007].content
	local name = g_AttrCtrl.engageInfo.name
	local mReplace = {role = name}
	local desc = string.FormatString(text2, mReplace, true)
	dissolve.m_Desc:SetText("[63432C]"..desc)
	dissolve.m_Btn:AddUIEvent("click", callback(self, "OnDissolveClick"))
end

function CDissolveEngageView.InitNpcTexture(self)
	local model_info = g_EngageCtrl:GetNpcModelInfo()
	self.m_NpcTexture:ChangeShape(model_info)
end

function CDissolveEngageView.OnPreDissClick(self)
		-- 解除订婚 --
	if g_AttrCtrl.silver < self.m_Resume then
		g_NotifyCtrl:FloatMsg("银币不足")
		-- CCurrencyView:ShowView(function(oView)
		-- 	oView:SetCurrencyView(define.Currency.Type.Silver)
		-- end)
		g_ShopCtrl:ShowAddMoney(define.Currency.Type.Silver)
	else
		netengage.C2GSDissolveEngage()
	end
	
	self:CloseView()
end

function CDissolveEngageView.OnDissolveClick(self)
	self.m_DissolveNode:SetActive(false)
	self.m_PreDissolveNode:SetActive(true)
end

return CDissolveEngageView