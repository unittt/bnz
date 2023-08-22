local CJieBaiDeclarationView = class("CJieBaiDeclarationView", CViewBase)

function CJieBaiDeclarationView.ctor(self, cb)

	CViewBase.ctor(self, "UI/JieBai/JieBaiDeclarationView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "sub"
    self.m_ExtendClose = "Shelter"

end

function CJieBaiDeclarationView.OnCreateView(self)

	--self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_InvitedList = self:NewUI(2, CJieBaiInvitedItemList)
	self.m_Time = self:NewUI(3, CLabel)
	self.m_JieBaiBtn = self:NewUI(4, CSprite)

	self:InitContent()
    
end

function CJieBaiDeclarationView.InitContent(self)

	--self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_JieBaiBtn:AddUIEvent("click", callback(self, "OnClickJieBai"))
	self:RefreshTime()
	
end

function CJieBaiDeclarationView.RefreshTime(self)
	
	local remainTime = g_JieBaiCtrl:GetYiShiStateTime()
	local cb = function (time)
	    if not time then 
	        self.m_Time:SetText("00:00")
	    else
	        self.m_Time:SetText(time)
	    end 
	end
	g_TimeCtrl:StartCountDown(self, remainTime, 4, cb)

end

function CJieBaiDeclarationView.OnClickJieBai(self)
	
	g_JieBaiCtrl:C2GSJBJingJiu()
	self.m_JieBaiBtn:SetSpriteName("h7_jingjiu_2")

end

return CJieBaiDeclarationView