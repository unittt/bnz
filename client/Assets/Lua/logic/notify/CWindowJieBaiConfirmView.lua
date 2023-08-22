local CWindowJieBaiConfirmView = class("CWindowJieBaiConfirmView", CWindowComfirmView)


function CWindowJieBaiConfirmView.ctor(self, cb)

	CWindowComfirmView.ctor(self, cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"

end

return CWindowJieBaiConfirmView