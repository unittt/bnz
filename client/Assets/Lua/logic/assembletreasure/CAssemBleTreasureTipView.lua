local CAssemBleTreasureTipView = class("CAssemBleTreasureTipView", CViewBase)

function CAssemBleTreasureTipView.ctor(self, cb)
	CViewBase.ctor(self, "UI/AssembleTreasure/AssembleTreasureTipView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Pierce"
	self.m_OkCallBack  = nil
	self.m_HasSelect = false
end

function CAssemBleTreasureTipView.OnCreateView(self)
	self.m_TitleLab = self:NewUI(1, CLabel)
	self.m_InfoLab = self:NewUI(2, CLabel)
	self.m_CancelBtn = self:NewUI(3, CButton)
	self.m_OkBtn = self:NewUI(4, CButton)
	self.m_SelectBtn = self:NewUI(5, CSprite)
	self.m_SelectBtn:SetGroup(self:GetInstanceID())
	self.m_SelectLab = self:NewUI(6, CLabel)
	self.m_TipViewCloseBtn = self:NewUI(7, CButton)
	self:InitContent()
end

function CAssemBleTreasureTipView.InitContent(self)
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnCancelBtn"))
	self.m_OkBtn:AddUIEvent("click",callback(self, "OnOkBtn"))
	self.m_TipViewCloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_SelectBtn:AddUIEvent("click",callback(self, "OnSelect"))
end

function CAssemBleTreasureTipView.OnSelect(self)
	if self.m_HasSelect then
		self.m_SelectBtn:ForceSelected(false)
		self.m_HasSelect = false
	else
		self.m_SelectBtn:ForceSelected(true)
		self.m_HasSelect = true
	end
	
end

function CAssemBleTreasureTipView.OnCancelBtn(self)
	self:CloseView()
end

function CAssemBleTreasureTipView.OnOkBtn(self)
	if self.m_OkCallBack then
		self.m_OkCallBack()
		self:OnClose()
	end
end

function CAssemBleTreasureTipView.SetData(self, isTentime, disconut)
	local index =  isTentime and 1007 or 1006 
	self.m_InfoLab:SetText(string.format(data.assembletreasuredata.TEXT[index].content, disconut))
	-- self.m_SelectBtn:SetActive(true)
	self.m_OkCallBack = function ()
		-- nethuodong.C2GSJuBaoPen(isTentime and 10 or 1)
		self:OnClose()
		if self.m_SelectBtn:GetSelected() then
			g_AssembleTreasureCtrl.m_DonTip = true
		end
		local oView = CAssembleTreasureView:GetView()
		if oView then
			oView:PlayEffect(isTentime)
		end
	end
end

return CAssemBleTreasureTipView