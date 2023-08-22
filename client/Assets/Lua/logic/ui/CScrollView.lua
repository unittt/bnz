local CScrollView = class("CScrollView", CPanel)

function CScrollView.ctor(self, obj)
	CPanel.ctor(self, obj)
	self.m_UIScrollView = self:GetComponent(classtype.UIScrollView)
	self.m_AbsoluteBounds = UITools.CalculateAbsoluteWidgetBounds(self.m_Transform)

	self.m_ForceCheckCull = false
	self.m_PreCnt = 1

	self.m_MoveCheck = {}
	self.m_CullObj = nil
end

function CScrollView.Destroy(self)
	self.m_MoveCheck = nil
	self.m_CullObj = nil
	if self.m_LaterTimer then
		Utils.DelTimer(self.m_LaterTimer)
		self.m_LaterTimer = nil
	end
	CPanel.Destroy(self)
end

function CScrollView.MoveRelative(self, pos)
	if pos ~= Vector3.zero then
		self.m_UIScrollView:MoveRelative(pos)
	end
end

function CScrollView.MoveAbsolute(self, pos)
	self.m_UIScrollView:MoveAbsolute(pos)
end

function CScrollView.Press(self, bPress)
	self.m_UIScrollView:Press(bPress)
end

function CScrollView.Drag(self)
	self.m_UIScrollView:Drag()
end

function CScrollView.Scroll(self, delta)
	self.m_UIScrollView:Scroll(delta)
end

function CScrollView.SetDragAmount(self, x, y, bUpdateScrollbars)
	local bUpdateScrollbars = bUpdateScrollbars or false
	self.m_UIScrollView:SetDragAmount(x, y, bUpdateScrollbars)
end

function CScrollView.RestrictWithinBounds(self, bInstant)
	return self.m_UIScrollView:RestrictWithinBounds(bInstant)
end

function CScrollView.ResetPosition(self)
	return self.m_UIScrollView:ResetPosition()
end

function CScrollView.DisableSpring(self)
	self.m_UIScrollView:DisableSpring()
end

function CScrollView.GetMovement(self)
	return self.m_UIScrollView.movement
end

function CScrollView.SetDisableDragIfFits(self, bCancel)
	self.m_UIScrollView.disableDragIfFits = bCancel
end

function CScrollView.InitCenterOnCompnent(self, oEventHandler, cb)
	self.m_UIScrollView.centerOnChild = Utils.GetGameObjComponent(oEventHandler, classtype.UICenterOnChild)
	if self.m_UIScrollView.centerOnChild then
		oEventHandler:AddUIEvent("UICenterOnChildOnCenter", cb)
	end
end

function CScrollView.CenterOn(self, transform)
	local o = self.m_UIScrollView.centerOnChild
	if o then
		o:CenterOn(transform)
	end
end

function CScrollView.GetCenteredObject(self)
	local o = self.m_UIScrollView.centerOnChild
	if o then
		return o.centeredObject
	end
end

function CScrollView.SetCullContent(self, obj, cb, index, isWidgetActiveOn, isHideColliderBox, bReposition)
	if obj.GetChildList then
		self.m_CullObj = obj
		self.m_CullCb = cb
		self.m_CullIndex = index
		self.m_CullIsWidgetActiveOn = isWidgetActiveOn
		self.m_CullColliderBox = isHideColliderBox
		self.m_IsReposition = bReposition
		self:StartClipMoveCheck()
	end
end

function CScrollView.AddMoveCheck(self, sType, obj, cb)
	self.m_MoveCheck[sType] = {obj=obj, cb=cb}
	self:StartClipMoveCheck()
end

function CScrollView.ClipMove(self)
	self:CheckMove()
	self:CullContent()
end

function CScrollView.RefreshBounds(self)
	self.m_AbsoluteBounds = UITools.CalculateAbsoluteWidgetBounds(self.m_Transform)
end

function CScrollView.CheckMove(self)
	for sType, dInfo in pairs(self.m_MoveCheck) do
		if not dInfo.obj then
			--continue
		elseif sType == "right" then
			local bounds = UITools.CalculateAbsoluteWidgetBounds(dInfo.obj.m_Transform)
			if bounds.max.x - self.m_AbsoluteBounds.max.x <= -0.03 then
				dInfo.cb()
			end
		elseif sType == "left" then
			local bounds = UITools.CalculateAbsoluteWidgetBounds(dInfo.obj.m_Transform)
			if bounds.min.x - self.m_AbsoluteBounds.min.x >= 0.03 then
				dInfo.cb()
			end
		elseif sType == "down" then
			local bounds = UITools.CalculateAbsoluteWidgetBounds(dInfo.obj.m_Transform)
			if bounds.min.y - self.m_AbsoluteBounds.min.y >= 0.03 then
				dInfo.cb()
			end
		elseif sType == "up" then
			local bounds = UITools.CalculateAbsoluteWidgetBounds(dInfo.obj.m_Transform)
			if bounds.max.y - self.m_AbsoluteBounds.max.y <= -0.03 then
				dInfo.cb()
			end
		
		elseif sType == "upmove" then
			local bounds = UITools.CalculateAbsoluteWidgetBounds(dInfo.obj.m_Transform)
			if bounds.max.y - self.m_AbsoluteBounds.max.y >= 0.03 then
				dInfo.cb()
			end
		
		elseif sType == "downmove" then
			local bounds = UITools.CalculateAbsoluteWidgetBounds(dInfo.obj.m_Transform)
			if bounds.max.y - self.m_AbsoluteBounds.max.y <= -0.03 then
				dInfo.cb()
			end
		end
	end
end

--要设置self.m_CullIsWidgetActiveOn才有效，这里只是改变collider的enabled
function CScrollView.CullContent(self)
	if self.m_CullObj == nil then
		return
	end
	for i, oWidget in ipairs(self.m_CullObj:GetChildList()) do
		local bNeedShow = not self:IsFullOut(oWidget)
		if self.m_CullColliderBox and not oWidget:IsActiveLock() then
			if oWidget.m_IsColliderActive ~= bNeedShow then
				oWidget.m_IsColliderActive = bNeedShow
				local oColliderList = oWidget.m_GameObject:GetComponentsInChildren(classtype.BoxCollider)
				-- printc("1111111111111", oColliderList.Length, bNeedShow)
				if oColliderList.Length-1 >= 0 then
					for i = 0, oColliderList.Length-1 do
						oColliderList[i].enabled = bNeedShow
					end
				end
				-- local oEffectList = oWidget.m_GameObject:GetComponentsInChildren(classtype.ParticleAndAnimation)
				-- if oEffectList.Length > 0 then
				-- 	oWidget.oEffectList = oEffectList
				-- end
				-- if oWidget.oEffectList and oWidget.oEffectList.Length-1 >= 0 then
				-- 	for i = 0, oWidget.oEffectList.Length-1 do
				-- 		oWidget.oEffectList[i].gameObject:SetActive(bActive)
				-- 	end
				-- end
			end
		end
					
		if self.m_CullIsWidgetActiveOn and not oWidget:IsActiveLock() then
			if oWidget:GetActive() ~= bNeedShow then
				oWidget:SetActive(bNeedShow)
				if self.m_IsReposition then
					self.m_CullObj:Reposition()
				end
				-- 当从false变更为true && 且当前为指定下标，执行回调
				if i == self.m_CullIndex then
					printerror("当从false变更为true && 且当前为指定下标，执行回调", self.m_CullIndex)
					if self.m_CullCb then
						self.m_CullCb()
					end
				end
			end
		end
	end
end

function CScrollView.CullContentLater(self)
	if self.m_LaterTimer then
		return
	end
	local function later()
		if Utils.IsExist(self) then
			self.m_LaterTimer = nil
			self:CullContent()
		end
	end
	self.m_LaterTimer = Utils.AddTimer(later, 0, 0.5)
end

function CScrollView.Move2Obj(self, obj, bHorizontal, offset)
	local offset = offset or Vector3.zero
	local pos = obj:GetLocalPos()
	self.m_UIScrollView:ResetPosition()
	if bHorizontal then
		self.m_UIScrollView:MoveRelative(Vector3.New(-pos.x, 0, 0))
	else
		self.m_UIScrollView:MoveRelative(Vector3.New(0, -pos.y, 0))
	end
end

return CScrollView