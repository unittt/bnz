local CPanel = class("CPanel", CObject, CUIEventHandler)

function CPanel.ctor(self, obj)
	CObject.ctor(self, obj)
	CUIEventHandler.ctor(self, obj)
	self.m_UIPanel = self:GetComponent(classtype.UIPanel)
	self.m_m_StartClipMoveCheck = false
	self.m_PreCnt = 1
end

function CPanel.Destroy(self)
	self.m_UIPanel:Destroy()
	CUIEventHandler.Destroy(self)
	CObject.Destroy(self)
end

function CPanel.SetClipping(self, clipping)
	self.m_UIPanel.clipping = clipping
end

function CPanel.SetDepth(self, iDepth)
	self.m_UIPanel.depth = iDepth
end

function CPanel.GetDepth(self)
	return self.m_UIPanel.depth
end

function CPanel.SetSortOrder(self, iSortOrder)
	if self.m_UIPanel.sortingOrder then
		self.m_UIPanel.sortingOrder = iSortOrder
	end
end

function CPanel.GetSortOrder(self)
	return self.m_UIPanel.sortingOrder
end

function CPanel.SetAlpha(self, alpha)
	self.m_UIPanel.alpha = alpha
end

function CPanel.GetAlpha(self)
	return self.m_UIPanel.alpha
end

function CPanel.IsFullOut(self, oWidget)
	local bounds = oWidget:CalculateBounds(self.m_Transform)
	local w, h = oWidget:GetSize()
	local v = self.m_UIPanel:CalculateConstrainOffset(bounds.min, bounds.max)
	if v.x < -self.m_PreCnt*w or v.x > self.m_PreCnt*w or v.y < -self.m_PreCnt*h or v.y > self.m_PreCnt*h then
		return true
	else
		return false
	end
end

function CPanel.SetBaseClipRegion(self, vector4)
	self.m_UIPanel.baseClipRegion = vector4
end

function CPanel.GetBaseClipRegion(self)
	return self.m_UIPanel.baseClipRegion
end

function CPanel.SetClipOffset(self, vector2)
	self.m_UIPanel.clipOffset = vector2
end

function CPanel.GetClipOffset(self)
	return self.m_UIPanel.clipOffset
end

function CPanel.StartClipMoveCheck(self)
	if not self.m_StartClipMoveCheck then
		self.m_StartClipMoveCheck = true
		self:AddUIEvent("UIPanelOnClipMove", callback(self, "ClipMove"))
	end
end

function CPanel.ClipMove(self)
	--todo
end

function CPanel.GetSize(self)
	local size = self.m_UIPanel:GetViewSize()
	return size.x, size.y
end

function CPanel.SetRect(self, x, y, w, h)
	self.m_UIPanel:SetRect(x, y, w, h)
end
return CPanel
