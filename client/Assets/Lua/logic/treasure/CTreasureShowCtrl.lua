local CTreasureShowCtrl = class("CTreasureShowCtrl")

function CTreasureShowCtrl.ctor(self)
	
end

--使用宝图道具寻路到目的地回调
function CTreasureShowCtrl.OnPositionCallback(self,callback_sessionidx)
	printc("使用宝图道具寻路到目的地回调")
	g_MapCtrl:UpdateHeroPos()
	netother.C2GSCallback(callback_sessionidx)
end

return CTreasureShowCtrl