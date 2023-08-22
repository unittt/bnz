local CChatViewCtrl = class("CChatViewCtrl")

function CChatViewCtrl.ctor(self)
	
end

function CChatViewCtrl.OpenChatOrgChannel(self)
	if not(g_AttrCtrl.org_id and g_AttrCtrl.org_id ~= 0) then
		g_NotifyCtrl:FloatMsg("您还没加入任何帮派")
		return
	end
	CChatMainView:ShowView(function (oView)
		oView:SwitchChannel(define.Channel.Org)
	end)
end

return CChatViewCtrl