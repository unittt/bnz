local CWarLB = class("CWarLB", CBox)

function CWarLB.ctor(self, obj)
	CBox.ctor(self, obj)
 
    self.m_WarUI = self:NewUI(1, CBarrageWarUI)

end

function CWarLB.OpenBarrageWarUI(self, isOpen)

    self.m_WarUI:ShowUI(isOpen)

end


return CWarLB