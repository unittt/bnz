local CWidget = class("CWidget", CObject, CUIEventHandler)

function CWidget.ctor(self, obj)
	CObject.ctor(self, obj)
	CUIEventHandler.ctor(self, obj)
	self.m_UIWidget = self:GetComponent(classtype.UIWidget)
	self.m_UIToggle = nil
	self.m_IsTouchEabled = nil
	self.m_IsLockActive = false
	self.m_IsColliderActive = true
	self.m_Effects = {}
end

function CWidget.Destroy(self)
	self:ClearEffect()
	CObject.Destroy(self)
	CUIEventHandler.Destroy(self)
end

--只有UISprite子类才可以用
function CWidget.SetFlip(self, flip)
	self.m_UIWidget.flip = flip
end

function CWidget.SetEnabled(self, bEnabled)
	self.m_UIWidget.enabled = bEnabled
end

function CWidget.SimulateOnEnable(self)
	self:ReActive()
end

function CWidget.ResetAndUpdateAnchors(self)
	self.m_UIWidget:ResetAndUpdateAnchors()
end

function CWidget.SetUVRect(self, rect)
	self.m_UIWidget.uvRect = rect
end

function CWidget.SetSize(self, iW, iH)
	self:SetWidth(iW)
	self:SetHeight(iH)
end

function CWidget.GetSize(self)
	return self.m_UIWidget.width, self.m_UIWidget.height
end

function CWidget.SetWidth(self, iW)
	self.m_UIWidget.width = iW
end

function CWidget.GetWidth(self)
	return self.m_UIWidget.width
end

function CWidget.SetHeight(self, iH)
	self.m_UIWidget.height = iH
end

function CWidget.GetHeight(self)
	return self.m_UIWidget.height
end

function CWidget.SetKeepAspectRatio(self, iRatio)
	self.m_UIWidget.keepAspectRatio = iRatio
end

function CWidget.SetAspectRatio(self, iRatio)
	self.m_UIWidget.aspectRatio = iRatio
end

--设置锚点目标
function CWidget.SetAnchorTarget(self, obj, left, bottom, right, top)
	if obj == nil then 
		return
	end 
	self.m_UIWidget:SetAnchor(obj, left, bottom, right, top)
end

--设置锚点距离
--dir:锚点方向 rightAnchor,bottomAnchor,topAnchor,leftAnchor
--absolute:绝对绝对距离
--relative:相对距离 0:bottom,left   0.5:center   1:top,right
function CWidget.SetAnchor(self, dir, absolute, relative)
	self.m_UIWidget[dir].absolute = absolute
	self.m_UIWidget[dir].relative = relative
end

function CWidget.IsInRect(self, worldPostion)
	local worldCorners = self.m_UIWidget.worldCorners
	local vBottomLeft = worldCorners[1]
	local vTopRight = worldCorners[3]
	if worldPostion.x < vBottomLeft.x or
		worldPostion.x > vTopRight.x or
		worldPostion.y < vBottomLeft.y or
		worldPostion.y > vTopRight.y then
		return false
	else
		return true
	end
end

function CWidget.SetDepth(self, iDepth)
	self.m_UIWidget.depth = iDepth
end

function CWidget.TopChildDepth(self)
	local childs = self:GetComponentsInChildren(classtype.UIWidget, true)
	for i=0, childs.Length-1 do
		local widget = childs[i]
		widget.depth = self.m_UIWidget.depth + 1
	end
end

function CWidget.GetDepth(self)
	return self.m_UIWidget.depth
end

function CWidget.CalculateBounds(self, relativeParent)
	return self.m_UIWidget:CalculateBounds(relativeParent)
end

function CWidget.MakePixelPerfect(self)
	self.m_UIWidget:MakePixelPerfect()
end

function CWidget.SetColor(self, color)
	self.m_UIWidget.color = color
end

function CWidget.GetColor(self)
	return self.m_UIWidget.color
end

function CWidget.SetAlpha(self, alpha)
	self.m_UIWidget.alpha = alpha
end

function CWidget.GetAlpha(self)
	return self.m_UIWidget.alpha
end

function CWidget.GetPivot(self)
	return self.m_UIWidget.pivot
end

function CWidget.SetPivot(self, pivot)
	self.m_UIWidget.pivot = pivot
end

function CWidget.IsVisible(self)
	if self.m_UIWidget.panel then
		return self.m_UIWidget.panel:IsVisible(self.m_UIWidget)
	end
	return self:GetActive(true)
end

function CWidget.InitToggle(self)
	if not self.m_UIToggle then
		self.m_UIToggle = self:GetMissingComponent(classtype.UIToggle)
		if self.m_UIToggle then
			self.m_UIToggle:Start()
		end
	end

	return self.m_UIToggle
end

function CWidget.SetGroup(self, iGroup)
	self:InitToggle()
	self.m_UIToggle.group = iGroup
end

function CWidget.SetSelected(self, b)
	self:InitToggle()
	self.m_UIToggle.value = b
end

function CWidget.GetSelected(self)
	self:InitToggle()
	return self.m_UIToggle.value
end

function CWidget.ForceSelected(self, b)
	self:InitToggle()
	self.m_UIToggle:Set(b, false)
end

function CWidget.SetGrey(self, bGrey)
	if bGrey then
		self.m_UIWidget.color = Color.gray
	else
		self.m_UIWidget.color = Color.white
	end
end

function CWidget.SetGreySprites(self, bGrey)
	local color = Color.white
	if bGrey then
		color = Color.gray
	end
	self.m_UIWidget.color = color
	local childlist = self:GetComponentsInChildren(classtype.UISprite, true)
	for i=1,childlist.Length do
		childlist[i-1].color = color
	end
end

function CWidget.IsGrey(self)
	return (self.m_UIWidget.color == Color.gray)
end

function CWidget.EnableTouch(self, b)
	local collider = self:GetComponent(classtype.BoxCollider)
	if collider then
		collider.enabled = b
	end
	self.m_IsTouchEabled = b
end

function CWidget.IsTouchEabled(self)
	if self.m_IsTouchEabled == nil then
		local collider = self:GetComponent(classtype.BoxCollider)
		self.m_IsTouchEabled = collider.enabled
	end
	return self.m_IsTouchEabled
end

function CWidget.SetHint(self, textOrFunc, near, offset)
	local function showHint(oWidget)
		local text = ""
		if type(textOrFunc) == "function" then
			text = textOrFunc()
		elseif type(textOrFunc) == "string" then
			text = textOrFunc
		end
		local oView = CNotifyView:GetView()
		if oView then
			oView:ShowHint(text, oWidget, near, offset)
		end
	end
	self:AddUIEvent("click", showHint)
end

function CWidget.AddEffect(self, sType, ...)
	if not sType then
		printerror("无效的特效类型")
		return
	end
	if self.m_Effects[sType] then
		return self.m_Effects[sType]
	end
	local oEff = g_EffectCtrl:CreateUIEffect(sType, self,...)
	oEff:SetParent(self.m_Transform)
	self.m_Effects[sType] = oEff
	return oEff
end

function CWidget.DelEffect(self, sType)
	local oEff = self.m_Effects[sType]
	if oEff then
		oEff:Destroy()
		self.m_Effects[sType] = nil
	end
end

function CWidget.AddEffectByPath(self, key, path, ...)
	if not key or self.m_Effects[key] then
		return
	end
	local oEff = g_EffectCtrl:CreateEffectByPath(path, self, ...)
	if oEff then
		oEff:SetParent(self.m_Transform)
		self.m_Effects[key] = oEff
	end
	return oEff
end

function CWidget.DelEffectByPath(self, key)
	local oEff = self.m_Effects[key]
	if oEff then
		oEff:Destroy()
		self.m_Effects[key] = nil
	end
end

function CWidget.ClearEffect(self)
	for sType, oEffect in pairs(self.m_Effects) do
		oEffect:Destroy()
	end
	self.m_Effects = {}
end

function CWidget.ClickClearEffect(self)
	for sType, oEffect in pairs(self.m_Effects) do
		if oEffect.ClickEffect then
			oEffect:ClickEffect()
		end
		oEffect:Destroy()
	end
	self.m_Effects = {}
end

function CWidget.GetEffect(self, sType)
	return self.m_Effects[sType]
end

function CWidget.RecaluatePanelDepth(self, key)
	local oEff = self.m_Effects[key]
	if oEff then
		oEff:RecaluatePanelDepth()
	end
end

function CWidget.GetCenterPos(self)
	local p = self:GetParent()
	if p then
		local x, y = UITools.GetCenterOffsetPixel(self)
		local pos = self:GetLocalPos()
		pos.x = pos.x - x
		pos.y = pos.y - y
		return p:TransformPoint(pos)
	else
		return Vector3.zero
	end
end

--禁止scrollView自动设置active
function CWidget.SetActiveLock(self, b)
	self.m_IsLockActive = b
end

function CWidget.IsActiveLock(self)
	return self.m_IsLockActive
end

return CWidget