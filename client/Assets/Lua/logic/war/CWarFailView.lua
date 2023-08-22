local CWarFailView = class("", CViewBase)

function CWarFailView.ctor(self, cb)
	CViewBase.ctor(self, "UI/War/WarFailView.prefab", cb)

	self.m_ExtendClose = "ClickOut"
end

function CWarFailView.OnCreateView(self)
end

function CWarFailView.CloseView(self)
	g_WarCtrl:SetInResult(false)
	CViewBase.CloseView(self)
end

return CWarFailView