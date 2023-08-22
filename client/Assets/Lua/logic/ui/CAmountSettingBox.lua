local CAmountSettingBox = class("CAmountSettingBox", CBox)

function CAmountSettingBox.ctor(self, obj)
	CBox.ctor(self, obj)
	
	self.m_SubBtn = self:NewUI(1, CWidget)
	self.m_AddBtn = self:NewUI(2, CWidget)
	self.m_AmountLabel = self:NewUI(3, CLabel)

	self.m_CurValue = 0
	self.m_MinValue = 1
	self.m_MaxValue = 10
	self.m_StepValue = 1
	self.m_MidValue = nil
	self.m_EnableKeyBoard = true
	self.m_EnableGrey = false
	self.m_MinFloatMsg = "不能再减少了"
	self.m_MaxFloatMsg = "不能再增加了"
	self:InitContent()
end

function CAmountSettingBox.InitContent(self)
	self.m_AddBtn:AddUIEvent("click", callback(self, "ChangeValue", 1))
	self.m_SubBtn:AddUIEvent("click", callback(self, "ChangeValue", -1))
	self:AddUIEvent("click", callback(self, "OpenKeyBoard"))
	self:SetValue(1)
end

--设置回调，回调函数带参以方便返回当前控件 
--example:OnValueChange(oBox)
--@param cb 回调函数
function CAmountSettingBox.SetCallback(self, cb)
	self.m_Callback = cb
end

function CAmountSettingBox.SetAmountRange(self, iMin, iMax)
	self.m_MinValue = iMin or 1
	self.m_MaxValue = iMax or 99
end

function CAmountSettingBox.SetValue(self, iValue)
	local sValue = tostring(iValue)
	self.m_AmountLabel:SetCommaNum(iValue)
	if self.m_MidValue and iValue < self.m_MidValue then
		--sValue = "[c]#I"..sValue
		self.m_AmountLabel:SetColor(Color.RGBAToColor("11AE19FF"))
	elseif self.m_MidValue and iValue > self.m_MidValue then
		--sValue = "[c]#R"..sValue
		self.m_AmountLabel:SetColor(Color.RGBAToColor("FF0000FF"))
	elseif self.m_MidValue and iValue == self.m_MidValue then
		self.m_AmountLabel:SetColor(Color.RGBAToColor("63432CFF"))
	end
	
	
	self.m_CurValue = iValue
	if self.m_Callback then
		self.m_Callback(iValue)
	end
	self:UpdateGreyStatus()
end

function CAmountSettingBox.SetStepValue(self, iValue)
	self.m_StepValue = iValue
end

function CAmountSettingBox.SetMidValue(self, iValue)
	self.m_MidValue = iValue
end

function CAmountSettingBox.SetWarningMsg(self, sMin, sMax)
	self.m_MinFloatMsg = sMin
	self.m_MaxFloatMsg = sMax
end

function CAmountSettingBox.EnableTouch(self, b)
	CBox.EnableTouch(self, b)
	self.m_SubBtn:SetActive(b)
	self.m_AddBtn:SetActive(b)
end

function CAmountSettingBox.EnableGrey(self, b)
	self.m_EnableGrey = b
	self:UpdateGreyStatus()
end

function CAmountSettingBox.EnableKeyBoard(self, b)
	self.m_EnableKeyBoard = b
end

function CAmountSettingBox.GetValue(self)
	return self.m_CurValue
end

function CAmountSettingBox.ChangeValue(self, iChange)
	local iLastValue = self.m_CurValue
	local iNewValue = self.m_CurValue + iChange*self.m_StepValue
	iNewValue = self:AdjustValue(iNewValue)
	if iNewValue == iLastValue then
		if iChange < 0 then
			g_NotifyCtrl:FloatMsg(self.m_MinFloatMsg or "不能再减少了")
		elseif iChange > 0 then
			g_NotifyCtrl:FloatMsg(self.m_MaxFloatMsg or "不能再增加了")
		end
	end
	self:SetValue(iNewValue)
end

function CAmountSettingBox.AdjustValue(self, iValue)
	iValue = math.min(iValue, self.m_MaxValue)
	iValue = math.max(iValue, self.m_MinValue)
	return iValue
end

function CAmountSettingBox.UpdateGreyStatus(self)
	if self.m_EnableGrey then
		self.m_AddBtn:SetGrey(self.m_EnableGrey and self.m_MaxValue == self.m_CurValue)
		self.m_SubBtn:SetGrey(self.m_EnableGrey and self.m_MinValue == self.m_CurValue)
	end
end

function CAmountSettingBox.OpenKeyBoard(self)
	if not self.m_EnableKeyBoard then
		return
	end
	local function keycallback(oView)
		local iValue = oView:GetNumber()--tonumber(self.m_AmountLabel:GetText())
		-- local iAdjustValue = self:AdjustValue(iValue)
		-- self:SetValue(iAdjustValue)
	end
	local function ConfirCallback(oView)
		local iValue = oView:GetNumber()
		self:SetValue(iValue)
	end 
	CSmallKeyboardView:ShowView(function (oView)
		oView:SetData(self.m_AmountLabel, keycallback, ConfirCallback, nil, self.m_MinValue, self.m_MaxValue, self.m_CurValue)
		oView:SetWarningMsg(self.m_MinFloatMsg, self.m_MaxFloatMsg)
	end)
end
return CAmountSettingBox