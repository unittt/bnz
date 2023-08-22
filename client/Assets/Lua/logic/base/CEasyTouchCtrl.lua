local CEasyTouchCtrl = class("CEasyTouchCtrl")

CEasyTouchCtrl.EventType = {
    TouchDown = 1,
    TouchUp = 2,
    Swipe = 3,
    LongTabStart = 4,
    LongTab = 5,
    LongTapEnd = 6,
    Drag = 7,
    SwipeStart = 8,
    SwipeEnd = 9,
    TouchDown2Fingers = 10,
    TouchUp2Fingers = 11,
}

CEasyTouchCtrl.EventFunc = {
	[CEasyTouchCtrl.EventType.TouchDown] = "OnTouchDown",
	[CEasyTouchCtrl.EventType.TouchUp] = "OnTouchUp",
	[CEasyTouchCtrl.EventType.Swipe] = "OnSwipe",
	[CEasyTouchCtrl.EventType.LongTabStart] = "OnLongTabStart",
	[CEasyTouchCtrl.EventType.LongTab] = "OnLongTab",
	[CEasyTouchCtrl.EventType.LongTapEnd] = "LongTapEnd",
	[CEasyTouchCtrl.EventType.Drag] = "OnDrag",
	[CEasyTouchCtrl.EventType.SwipeStart] = "OnSwipeStart",
	[CEasyTouchCtrl.EventType.SwipeEnd] = "OnSwipeEnd",
	[CEasyTouchCtrl.EventType.TouchDown2Fingers] = "OnTouchDown2Fingers",
	[CEasyTouchCtrl.EventType.TouchUp2Fingers] = "OnTouchUp2Fingers",
}

function CEasyTouchCtrl.ctor(self)
	self.m_Toucher = {}
end

function CEasyTouchCtrl.InitCtrl(self)
	C_api.EasyTouchHandler.AddCamera(g_CameraCtrl:GetMainCamera().m_Camera, false)
	C_api.EasyTouchHandler.AddCamera(g_CameraCtrl:GetWarCamera().m_Camera, false)
	C_api.EasyTouchHandler.SetCallback(callback(self, "OnTouchEvent"))

	g_EasyTouchCtrl:AddTouch("maptouch", g_MapTouchCtrl)
	g_EasyTouchCtrl:AddTouch("wartouch", g_WarTouchCtrl)
	g_EasyTouchCtrl:AddTouch("rolecreatetouch", g_RoleCreateTouchCtrl)
	g_EasyTouchCtrl:AddTouch("guidetouch", g_GuideCtrl)
end

function CEasyTouchCtrl.ResetCtrl(self)
	self.m_Toucher = {}
end

function CEasyTouchCtrl.AddTouch(self, skey, dispatchobj)
	self.m_Toucher[skey] = dispatchobj
end

function CEasyTouchCtrl.DelTouch(self, skey)
	self.m_Toucher[skey] = nil
end


function CEasyTouchCtrl.OnTouchEvent(self, eventType, x, y, x1, y1)
	local func = CEasyTouchCtrl.EventFunc[eventType]
	if func then
		for _, v in pairs(self.m_Toucher) do
			if v and v[func] then
				local pos = Vector2.New(x, y)
				local pos1 = Vector2.New(x1, y1)
				v[func](v, pos, pos1)
			end
		end
	end
end

return CEasyTouchCtrl
