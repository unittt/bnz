local CEditorArgBoxBase = class("CEditorArgBoxBase", CBox)

function CEditorArgBoxBase.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Key = nil
end

function CEditorArgBoxBase.SetArgInfo(self, dInfo)

end

function CEditorArgBoxBase.GetArgData(self)

end

function CEditorArgBoxBase.SetKey(self, k)
	self.m_Key = k
end

function CEditorArgBoxBase.GetKey(self)
	return self.m_Key
end

function CEditorArgBoxBase.SetValue(self, v, bInput)

end

function CEditorArgBoxBase.ResetDefault()

end

return CEditorArgBoxBase