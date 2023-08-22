local CBonfireExpandBox = class("CBonfireExpandBox", CBox)

function CBonfireExpandBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)
    self.m_PopBtn = self:NewUI(1, CButton)
    self.m_Addition = self:NewUI(2, CLabel)
    self.m_WineBtn = self:NewUI(3, CButton)
    self.m_GiveBtn = self:NewUI(4, CButton)
    self.m_AnswerBtn = self:NewUI(5, CButton)
    self.m_DesBtn = self:NewUI(6, CButton)
    self.m_Content = self:NewUI(7, CObject)
    self:InitContent()
end

function CBonfireExpandBox.InitContent(self)
    self:BindMenuArea()
    self.m_PopBtn:AddUIEvent("click", callback(self, "OnPopBtn"))
    self.m_WineBtn:AddUIEvent("click", callback(self, "OnWineBtn"))
    self.m_GiveBtn:AddUIEvent("click", callback(self, "OnGiveBtn"))
    self.m_AnswerBtn:AddUIEvent("click", callback(self, "OnAnswer"))
    self.m_DesBtn:AddUIEvent("click", function ()
        local zContent = {title = "规则",desc = "规则"}
    	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
    end)
    if g_BonfireCtrl.m_DrinkBuffAdds then
       self:SetInfo(g_BonfireCtrl.m_DrinkBuffAdds)
    end
end

function CBonfireExpandBox.BindMenuArea(self)
	local tweenPos = self.m_Content:GetComponent(classtype.TweenPosition)
	local tweenRotation = self.m_PopBtn:GetComponent(classtype.TweenRotation)
	local callback = function()
        tweenRotation:Play(g_MainMenuCtrl:GetAreaStatus(define.MainMenu.AREA.Bonfire))
    end
	g_MainMenuCtrl:AddPopArea(define.MainMenu.AREA.Bonfire, tweenPos, callback, false)
end

function CBonfireExpandBox.OnPopBtn(self)
	if g_MainMenuCtrl:GetAreaStatus(define.MainMenu.AREA.Bonfire) then
		g_MainMenuCtrl:HideArea(define.MainMenu.AREA.Bonfire)
	else
	    g_MainMenuCtrl:ShowArea(define.MainMenu.AREA.Bonfire)
	end
end

function CBonfireExpandBox.SetInfo(self, info)
    self.m_Addition:SetText(info.."%")
end

function CBonfireExpandBox.OnWineBtn(self)
    CBonfireWineView:ShowView()
end

function CBonfireExpandBox.OnGiveBtn(self)
    g_BonfireCtrl:C2GSCampfireQueryGiftables()
end

function CBonfireExpandBox.OnAnswer(self)
    if g_BonfireCtrl.m_CurQuestionState == 0 or next(g_BonfireCtrl.m_CurTopicInfo) == nil then
        g_NotifyCtrl:FloatMsg("答题活动未开始！")
        return
    elseif self.m_CurQuestionState == 2 then
        g_NotifyCtrl:FloatMsg("答题活动已结束！")
        return
    end
    local view = CBonfireAnswerView:GetView()
    if view then

        return
    else
        --g_NotifyCtrl:FloatMsg("请等待下一轮答题！")
        CBonfireAnswerView:ShowView(function (oView)
            oView:SetInfo()
        end)
    end
end

return CBonfireExpandBox