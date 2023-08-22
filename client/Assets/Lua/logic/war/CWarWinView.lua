local CWarWinView = class("CWarWinView", CViewBase)

function CWarWinView.ctor(self, cb)
	CViewBase.ctor(self, "UI/War/WarWinView.prefab", cb)

	self.m_GroupName = "WarMain"
	self.m_ExtendClose = "Black"
end

function CWarWinView.OnCreateView(self)
end

function CWarWinView.CloseView(self)
	g_WarCtrl:SetInResult(false)
	CViewBase.CloseView(self)
end

return CWarWinView