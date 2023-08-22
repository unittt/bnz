local CDemiCtrl = class("CDemiCtrl", CCtrlBase)

function CDemiCtrl.ctor(self)
	CCtrlBase.ctor(self)
	
	--	德米包切换支付的开关。配置（0：原生  1：微信&支付宝）
	self.m_DemiPaySwitch = true
end


function CDemiCtrl.SetDemiPaySwitchByConfigInfo(self, configInfo)
	if configInfo.paySwitch ~= nil and configInfo.paySwitch ~= "" then
		if configInfo.paySwitch == "0" then
			self.m_DemiPaySwitch = false
		else
			self.m_DemiPaySwitch = true
		end
	end
end

function CDemiCtrl.GetDemiPaySwitch(self)
	return self.m_DemiPaySwitch
end

return CDemiCtrl