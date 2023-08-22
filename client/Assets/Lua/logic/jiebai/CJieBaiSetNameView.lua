local CJieBaiSetNameView = class("CJieBaiSetNameView", CViewBase)

function CJieBaiSetNameView.ctor(self, cb)

	CViewBase.ctor(self, "UI/JieBai/JieBaiSetNameView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "sub"
    self.m_ExtendClose = "Black"

end

function CJieBaiSetNameView.OnCreateView(self)

	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_InvitedList = self:NewUI(2, CJieBaiInvitedItemList)
	self.m_Time = self:NewUI(3, CLabel)
	self.m_NameInput = self:NewUI(4, CInput)
	self.m_SaiZi = self:NewUI(5, CSprite)
	self.m_Des = self:NewUI(6, CLabel)
	self.m_Btn = self:NewUI(7, CSprite)
	self.m_Title = self:NewUI(8, CLabel)

	self:InitContent()

end

function CJieBaiSetNameView.InitContent(self)
	
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_SaiZi:AddUIEvent("click", callback(self, "OnClickSaiZi"))
	self.m_Btn:AddUIEvent("click", callback(self, "OnClickBtn"))
	g_JieBaiCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnJieBaiEvent"))

	self:RefreshAll()

end

function CJieBaiSetNameView.RefreshAll(self)

	self:RefreshTime()
	self:RefreshDes()
	self:RefreshTitle()
	self:RefreshBtn()
	self:RefreshMingHao()

end

function CJieBaiSetNameView.RefreshTime(self)
	
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

function CJieBaiSetNameView.RefreshDes(self)
	
	local tip = g_JieBaiCtrl:GetTextTip(1084)
	self.m_Des:SetText(tip)

end

function CJieBaiSetNameView.RefreshBtn(self)
	
	local pid = g_AttrCtrl.pid
	local minghao = g_JieBaiCtrl:GetMingHao(pid)
	if minghao then 
		self.m_Btn:SetGrey(true)
	end 

end

function CJieBaiSetNameView.OnClickBtn(self)
	

	local pid = g_AttrCtrl.pid
	local minghao = g_JieBaiCtrl:GetMingHao(pid)
	if not minghao then 
		local text = self.m_NameInput:GetText()
		local len = string.utfStrlen(text)
		if len > 2 then 
			local tip = g_JieBaiCtrl:GetTextTip(1032)
			g_NotifyCtrl:FloatMsg(tip)
		else
			if len == 0 then 
				g_NotifyCtrl:FloatMsg("请输入名号")
			else
				if g_MaskWordCtrl:IsContainMaskWord(text) or string.isIllegal(text) == false then 
					g_NotifyCtrl:FloatMsg("含有非法字符请重新输入!")
				else
					g_JieBaiCtrl:C2GSJBSetMingHao(text)
				end 
			end 
			
		end
	else
		g_NotifyCtrl:FloatMsg("名号已取")
	end  


end

function CJieBaiSetNameView.RefreshTitle(self)
	
	local title = g_JieBaiCtrl:GetTitle()
	self.m_Title:SetText(title)

end

function CJieBaiSetNameView.RefreshMingHao(self)
	
	local minghao = g_JieBaiCtrl:GetMingHao(g_AttrCtrl.pid)
	if minghao then 
		self.m_NameInput:SetText(minghao)
	end 

end


function CJieBaiSetNameView.OnClickSaiZi(self)
	
	local minghao = g_JieBaiCtrl:GetRandomMingHao()
	if string.utfStrlen(minghao) <= 2 then 
		self.m_NameInput:SetText(minghao)
	end 

end

function CJieBaiSetNameView.OnJieBaiEvent(self, oCtrl)
    
    if oCtrl.m_EventID == define.JieBai.Event.JieBaiInfoChange then
        self.m_InvitedList:RefreshItems()
        self:RefreshAll()
    end

end

function CJieBaiSetNameView.OnClose(self)
	
	CViewBase.OnClose(self)
	g_JieBaiCtrl:ViewOnClose()

end

return CJieBaiSetNameView