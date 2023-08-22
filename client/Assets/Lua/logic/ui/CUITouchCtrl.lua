local CUITouchCtrl = class("CUITouchCtrl")

function CUITouchCtrl.ctor(self)
	self.m_RefObjs = setmetatable({}, {__mode="k"})
	self.m_DetectDict = setmetatable({}, {__mode="k"})
	self.m_PanelDict = setmetatable({}, {__mode="k"})
	self.m_DragData = {}
	self.m_CurDragObject = nil
end

function CUITouchCtrl.Clear(self)
	self.m_RefObjs = {}
	self.m_DetectDict = {}
	self.m_PanelDict = {}
end

function CUITouchCtrl.AutoCheckDrag(self)
	if not self.m_DragValidTimer then
		self.m_DragValidTimer = Utils.AddTimer(callback(self, "CheckAllDragObject"), 0.1, 0)
	end
end

function CUITouchCtrl.InitCtrl(self)
	local gameEventHandler = C_api.GameEventHandler.Instance
	gameEventHandler:SetClickCallback(callback(self, "ScreenClick"))
end

function CUITouchCtrl.ScreenClick(self, gameObject)
	-- 语音中停止触屏操作
	-- return
	
	if next(self.m_DetectDict) then
		local worldPos = g_CameraCtrl:GetNGUICamera().lastWorldPosition
		local oClkPnl = nil
		if next(self.m_PanelDict) then
			oClkPnl = gameObject:GetComponent(classtype.UIPanel)
			if not oClkPnl then
				local oClkWidget = gameObject:GetComponent(classtype.UIWidget)
				if oClkWidget then
					oClkPnl = oClkWidget.panel
				end
			end
		end
		local bCb = false
		for id, cb in pairs(self.m_DetectDict) do
			local obj = self:GetObj(id)
			if obj then
				if gameObject and not UITools.IsChild(obj.m_Transform, gameObject.transform) then
					bCb = true
					if oClkPnl then
						local oPnl = self:GetPanel(id)
						if oPnl and oClkPnl.depth-oPnl.depth >= define.Depth.View.Increase/2 then
							bCb = false
						end
					end
					if bCb then
						cb(gameObject)
					end
				end
			else
				self.m_DetectDict[id] = nil
				self.m_RefObjs[id] = nil
				self.m_PanelDict[id] = nil
			end
		end
	end
    
	--组队时，判断是否点击了屏幕
	g_TeamCtrl:SetLeaderTouchUI(true)

	--检测点击，进入省电模式
	g_SystemSettingsCtrl:StartCheckClick(true)

	--贴心管家检测
	g_ScheduleCtrl:SetStopNotifyTime()

	--任务间隔提示
	g_TaskCtrl:SetTaskIntervalNotifyTime()
end

function CUITouchCtrl.NotTouchUI(self)
	for id, cb in pairs(self.m_DetectDict) do
		local obj = self:GetObj(id)
		if obj then
			cb()
		end
	end
end

--必须是根结点
-- view: root对应的view，点击的界面深度>view深度时不触发事件，view为nil不检测
function CUITouchCtrl.TouchOutDetect(self, root, cb, view)
	-- printerror("=====>>>>> CUITouchCtrl.TouchOutDetect", root:GetName())
	local function delay()
		if Utils.IsExist(root) then
			self.m_RefObjs[root] = weakref(root)
			self.m_DetectDict[root] = cb
			if view and view.m_UIPanel then
				self.m_PanelDict[root] = weakref(view.m_UIPanel)
			end
		end
	end
	Utils.AddTimer(delay, 0, 0)
end

function CUITouchCtrl.GetObj(self, key)
	local obj = getrefobj(self.m_RefObjs[key])
	if not obj then
		self.m_RefObjs[key] = nil
	end
	return obj
end

function CUITouchCtrl.GetPanel(self, key)
	local obj = getrefobj(self.m_PanelDict[key])
	if not obj then
		self.m_PanelDict[key] = nil
	end
	return obj
end

--拖动
function CUITouchCtrl.CheckAllDragObject(self)
	for key, data in pairs(self.m_DragData) do
		local obj = getrefobj(data.refObj)
		if not self:CheckValidDragObj(obj) then
			if C_api.Utils.IsObjectExist(data.gameObject) then
				data.gameObject:Destroy()
			end
			self.m_DragData[key] = nil
		end
	end
	return true
end

function CUITouchCtrl.CheckValidDragObj(self, oWidget)
	if Utils.IsNil(oWidget) then
		return false
	end
	local data = self.m_DragData[oWidget:GetInstanceID()]
	if data.is_dragging then
		if data.reset_info.parent and C_api.Utils.IsObjectExist(data.reset_info.parent) then
			return true
		else
			return false
		end
	else
		return true
	end
end

function CUITouchCtrl.AddDragObject(self, oWidget, dDragArgs)
	self:AutoCheckDrag()
	oWidget:AddUIEvent("drag", callback(self, "OnDrag"))
	oWidget:AddUIEvent("dragend", callback(self, "OnDragEnd"))
	local x, y = UITools.GetCenterOffsetPixel(oWidget)
	self.m_DragData[oWidget:GetInstanceID()] = {
		start_delta=dDragArgs.start_delta, -- 必备参数
		start_func = dDragArgs.start_func,
		cb_dragstart = dDragArgs.cb_dragstart,
		cb_dragging = dDragArgs.cb_dragging,
		cb_dragend = dDragArgs.cb_dragend,
		offset = dDragArgs.offset or Vector3.zero,
		drag_obj = dDragArgs.drag_obj,
		is_dragging = false,
		drag_center = true,
		center_offset = Vector3.New(x, y, 0),
		refObj = weakref(oWidget),
		gameObject = oWidget.m_GameObject,
		long_press = dDragArgs.long_press,
		component_dragscrollview = oWidget:GetComponent(classtype.UIDragScrollView),
		reset_info = nil, --还原位置
	}
	if dDragArgs.long_press then
		oWidget:SetLongPressTime(dDragArgs.long_press)
		oWidget:SetLongPressAnim(true, dDragArgs.start_func)
		oWidget:AddUIEvent("longpress", callback(self, "OnLongPress"))
	end
end

function CUITouchCtrl.OnLongPress(self, oWidget, bPress)
	if not self:CheckValidDragObj(oWidget) then
		self.m_CurDragObject = nil
		return
	end
	if bPress then
		self:StartDragObject(oWidget)
	else
		self:StopDragObejct(oWidget, true)
	end
end

function CUITouchCtrl.GetDragObjectParent(self)
	return CNotifyView:GetView().m_Transform
end

function CUITouchCtrl.OnDrag(self, oWidget, delta)
	if not self:CheckValidDragObj(oWidget) then
		self.m_CurDragObject = nil
		return false
	end
	local data = self.m_DragData[oWidget:GetInstanceID()]
	local moveobj = data["drag_obj"] or oWidget

	if data.is_dragging then
		local pos = moveobj:GetLocalPos()
		local adjust = UITools.GetPixelSizeAdjustment()
		pos.x = pos.x + delta.x * adjust
		pos.y = pos.y + delta.y * adjust
		moveobj:SetLocalPos(pos)
		if data.cb_dragging then
			data.cb_dragging(oWidget)
		end
	else
		local startDelta = data.start_delta
		if math.abs(delta.x) >= startDelta.x and math.abs(delta.y) >= startDelta.y then
			if startDelta.y < 0 and math.abs(delta.y) >= -startDelta.y then
				return
			end
			if oWidget.m_GameObject == g_CameraCtrl:GetNGUICamera().selectedObject then
				self:StartDragObject(oWidget)
			end
		end
	end
end

function CUITouchCtrl.OnDragEnd(self, oWidget, bCallCb)
	self:StopDragObejct(oWidget, bCallCb)
end

function CUITouchCtrl.StartDragObject(self, oWidget)
	local data = self.m_DragData[oWidget:GetInstanceID()]
	local startFunc = data.start_func
	if startFunc and not startFunc(oWidget) then
		return
	end
	data.is_dragging = true
	local oWidget = getrefobj(data.refObj)
	local moveobj = data["drag_obj"] or oWidget
	if data.cb_dragstart then
		data.cb_dragstart(oWidget)
	end
	local dReset = {
		parent = moveobj.m_Transform.parent,
		sibling = oWidget:GetSiblingIndex(),
		pos = oWidget:GetLocalPos(),
	}
	data["reset_info"] = dReset
	local p = self:GetDragObjectParent()
	moveobj.m_Transform.parent = p
	local localPos = p:InverseTransformPoint(g_CameraCtrl:GetNGUICamera().lastWorldPosition)
	if data.drag_center then
		localPos = localPos + data.center_offset
	end
	moveobj:SetLocalPos(localPos + data.offset) -- 初始化位置
	
	UITools.MarkParentAsChanged(moveobj.m_GameObject)
	if data.component_dragscrollview then
		data.component_dragscrollview.enabled = false
	end
	self.m_CurDragObject = oWidget
end

function CUITouchCtrl.StopDragObejct(self, oWidget, bCallCb)
	oWidget:StopLongPress()
	if self.m_CurDragObject then
		self.m_CurDragObject = nil
	else
		return false
	end
	if not self:CheckValidDragObj(oWidget) then
		return false
	end
	local data = self.m_DragData[oWidget:GetInstanceID()]
	if data.is_dragging then
		data.is_dragging = false
	else
		return
	end
	local moveobj = data["drag_obj"] or oWidget
	local bNeedReset = true
	bCallCb = bCallCb == false and false or true
	if bCallCb and data.cb_dragend then
		bNeedReset = not data.cb_dragend(moveobj) --dragend有做处理则不还原
	end
	
	if bNeedReset and data.reset_info then
		moveobj.m_Transform.parent = data.reset_info.parent
		oWidget:SetSiblingIndex(data.reset_info.sibling)
		oWidget:SetLocalPos(data.reset_info.pos)
		UITools.MarkParentAsChanged(moveobj.m_GameObject)
		if data.component_dragscrollview then
			data.component_dragscrollview.enabled = true
		end
	end
end

function CUITouchCtrl.DelDragObject(self, oWidget)
	local data = self.m_DragData[oWidget:GetInstanceID()]
	if data then
		if data.is_dragging then
			self:StopDragObejct(oWidget, false)
		end
		if data.long_press then
			oWidget:SetLongPressTime(0.2)
			oWidget:AddUIEvent("longpress", nil)
			oWidget:StopLongPress()
		end
		self.m_DragData[oWidget:GetInstanceID()] = nil
		oWidget:AddUIEvent("drag", nil)
		oWidget:AddUIEvent("dragend", nil)
	end
end

function CUITouchCtrl.FroceEndDrag(self, bDestroy)
	if bDestroy and self.m_CurDragObject then
		self:DelDragObject(self.m_CurDragObject)
		self.m_CurDragObject = nil
	elseif self.m_CurDragObject then
		self:OnDragEnd(self.m_CurDragObject, false)
		self.m_CurDragObject = nil
	else
		-- printc("======== 隐藏转圈，待确认需要")
		-- g_NotifyCtrl:HideLongPressAni()
	end
end

return CUITouchCtrl