 local CClothesBuyView = class("CClothesBuyView", CViewBase)

function CClothesBuyView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ClothesBuyView.prefab", cb)

	--界面设置
	self.m_ExtendClose = "Black"	


end

function CClothesBuyView.OnCreateView(self)

	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_Name = self:NewUI(2, CLabel)
	self.m_ActorTexture = self:NewUI(3, CActorTexture)
	self.m_SevenCount = self:NewUI(4, CLabel)
	self.m_SevenBtn = self:NewUI(5, CSprite)
	self.m_ForeverCount = self:NewUI(6, CLabel)
	self.m_ForeverBtn = self:NewUI(7, CSprite)
	self.m_Des = self:NewUI(8, CLabel)
	self.m_TimeDes = self:NewUI(9, CLabel)


	self.m_CloseBtn:AddUIEvent("click", callback(self, "CloseView"))
	self.m_SevenBtn:AddUIEvent("click", callback(self, "OnClickSeven"))
	self.m_ForeverBtn:AddUIEvent("click", callback(self, "OnClickForever"))

	g_WaiGuanCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	
end

function CClothesBuyView.SetInfo(self, info, colorInfo)
	
	self.m_Info = info
	self.m_ColorInfo = colorInfo
	self.m_SevenCount:SetText(info.openSeven)
	self.m_ForeverCount:SetText(info.openForever)
	self.m_Name:SetText(info.name)

	--初始化模型
	self:RefreshModel()

	self:RefreshDes()

end


function CClothesBuyView.OnClickSeven(self)
	
	local msg = nil
	local title = nil

	msg = g_WaiGuanCtrl:GetTipText(3003, self.m_Info.name)
	title = g_WaiGuanCtrl:GetTipText(6202)

	local windowConfirmInfo = {
		msg = msg,
		title = title,
		okCallback = function ()

		    g_WaiGuanCtrl:C2GSOpenShiZhuang(2, self.m_Info.szId)

		end,
		cancelCallback = function ()
		end,
	}


    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)
       --todo
    end)

end

function CClothesBuyView.RefreshDes(self)

	if self.m_Info.isForever and self.m_Info.isForever > 0 then 
		g_TimeCtrl:DelTimer(self)
		self.m_TimeDes:SetActive(false)
		self.m_Des:SetText("永久")
		self.m_Des:SetActive(true)
		return 
	end 
	
	if  self.m_Info.isUnLock then 

		if not self.m_Info.time or self.m_Info.time == 0 then
			self.m_Des:SetText(g_WaiGuanCtrl:GetTipText(6203))
			self.m_TimeDes:SetActive(false)
		    self.m_Des:SetActive(true)
		else

			local cb = function (time)
		        
		        if not time then 
		            self.m_Des:SetText(g_WaiGuanCtrl:GetTipText(6203))
		            self.m_TimeDes:SetActive(false)
		            self.m_Des:SetActive(true)
		        else
		            self.m_TimeDes:SetText(time)
		            self.m_TimeDes:SetActive(true)
		            self.m_Des:SetActive(false)
		        end 

		    end

		    local leftTime = self.m_Info.time - g_TimeCtrl:GetTimeS()

		    g_TimeCtrl:StartCountDown(self, leftTime, 1, cb)

		end 

	else

		self.m_Des:SetText(g_WaiGuanCtrl:GetTipText(6204))
	    self.m_TimeDes:SetActive(false)
        self.m_Des:SetActive(true)
		g_TimeCtrl:DelTimer(self)

	end 

end

function CClothesBuyView.OnClickForever(self)
	
	--printc("click -------------forever")
	local msg = nil
	local title = nil

	msg = g_WaiGuanCtrl:GetTipText(6205, self.m_Info.name)
	title = g_WaiGuanCtrl:GetTipText(6202)

	local windowConfirmInfo = {
		msg = msg,
		title = title,
		okCallback = function ()

		    g_WaiGuanCtrl:C2GSOpenShiZhuang(1, self.m_Info.szId)

		end,
		cancelCallback = function ()
		end,
	}

	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)
       --todo
    end)


end

function CClothesBuyView.RefreshModel(self)
	
 	local model_info = {}
 	model_info.shape = g_AttrCtrl.model_info.shape
 	model_info.shizhuang = self.m_Info.szId
    model_info.rendertexSize = 1.1
    if self.m_Info.isUnLock then 
    	if self.m_ColorInfo.isUnLock then 
    		model_info.ranse_shizhuang = self.m_ColorInfo.id
    	end  
    end 
    model_info.weapon = g_AttrCtrl.model_info.weapon
    model_info.fuhun = g_AttrCtrl.model_info.fuhun
	self.m_ActorTexture:ChangeShape(model_info)

end

function CClothesBuyView.OnCtrlEvent(self)
	
	local id = self.m_Info.szId
	for k, v in ipairs(g_WaiGuanCtrl.m_SzInfoList) do 
		if v.szId == id then 
			self.m_Info = v
			self:RefreshDes()
		end 
	end 

end


return CClothesBuyView