local CScreenResizeCtrl = class("CScreenResizeCtrl", CCtrlBase)

function CScreenResizeCtrl.ctor(self)
	CCtrlBase.ctor(self)
end

function CScreenResizeCtrl.InitCtrl(self)
	if Utils.IsIOS() then
		C_api.ScreenResizeManager.Instance:SetOnOrientationChangedCallback(callback(self, "OnOrientationChangedCallback"))
	end
end

function CScreenResizeCtrl.OnOrientationChangedCallback(self)
	-- 变更时重新刷新
	self:OnEvent(1)
end

-- 参数 unity gameobject, clip = false
function CScreenResizeCtrl.ResizePanel(self, gameObject)
	if Utils.IsIOS() then
		C_api.ScreenResizeManager.Instance:ResizePanel(gameObject, false);
	end
end

return CScreenResizeCtrl