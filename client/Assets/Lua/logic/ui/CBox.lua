local CBox = class("CBox", CWidget, CGameObjContainer)

function CBox.ctor(self, obj)
	CWidget.ctor(self, obj)
	CGameObjContainer.ctor(self, obj)
end

function CBox.Destroy(self)
	CWidget.Destroy(self)
	CGameObjContainer.Destroy(self)
end

return CBox
