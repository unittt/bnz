local CMaskWordCtrl = class("CMaskWordCtrl")

function CMaskWordCtrl.ctor(self)
	self.m_MaskWordTree = CMaskWordTree.New()
	self.m_MaskWordTree:UpdateNodes(data.maskworddata.DATA)
end

function CMaskWordCtrl.ReplaceMaskWord(self, str, flag)
	return self.m_MaskWordTree:ReplaceMaskWord(str, flag)
end

function CMaskWordCtrl.IsContainMaskWord(self, str)
	return self.m_MaskWordTree:IsContainMaskWord(str)
end

function CMaskWordCtrl.GetCharList(self, str)
    return self.m_MaskWordTree:GetCharList(str)
end

return CMaskWordCtrl