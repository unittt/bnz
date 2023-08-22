local CJieBaiSetTitleView = class("CJieBaiSetTitleView", CViewBase)

function CJieBaiSetTitleView.ctor(self, cb)

	CViewBase.ctor(self, "UI/JieBai/JieBaiSetTitleView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "sub"
    self.m_ExtendClose = "Black"

end

function CJieBaiSetTitleView.OnCreateView(self)

	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_InvitedList = self:NewUI(2, CJieBaiInvitedItemList)
	self.m_Time = self:NewUI(3, CLabel)
	self.m_NameInput = self:NewUI(4, CInput)
	self.m_SaiZi = self:NewUI(5, CSprite)
	self.m_Des = self:NewUI(6, CLabel)
	self.m_Btn = self:NewUI(7, CSprite)

	self:InitContent()

end

function CJieBaiSetTitleView.InitContent(self)
	
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_SaiZi:AddUIEvent("click", callback(self, "OnClickSaiZi"))
	self.m_Btn:AddUIEvent("click", callback(self, "OnClickBtn"))

	self:RefreshTime()
	self:RefreshDes()

end

function CJieBaiSetTitleView.RefreshTime(self)
	
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

function CJieBaiSetTitleView.RefreshDes(self)
	
	local tip = g_JieBaiCtrl:GetTextTip(1084)
	self.m_Des:SetText(tip)

end

function CJieBaiSetTitleView.OnClickBtn(self)
	
	local title = self.m_NameInput:GetText()
	local len = string.utfStrlen(title)
	if len > 4 then
		local tip = g_JieBaiCtrl:GetTextTip(1032)
		g_NotifyCtrl:FloatMsg(tip)
	else
		if len == 0 then 
			g_NotifyCtrl:FloatMsg("请输入称号")
		else
			if g_MaskWordCtrl:IsContainMaskWord(title) or string.isIllegal(title) == false then 
				g_NotifyCtrl:FloatMsg("含有非法字符请重新输入!")
			else
				g_JieBaiCtrl:C2GSJBSetTitle(title)
				-- CViewBase.OnClose(self)		
			end 
		end 
	end 


end

function CJieBaiSetTitleView.OnClose(self)
	
	CViewBase.OnClose(self)
	g_JieBaiCtrl:ViewOnClose()

end

function CJieBaiSetTitleView.OnClickSaiZi(self)
	
	local title = g_JieBaiCtrl:GetRandomTitle()
	if string.utfStrlen(title) <= 4 then 
		self.m_NameInput:SetText(title)
	end 

end

return CJieBaiSetTitleView