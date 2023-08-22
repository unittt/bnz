local CSystemSetPart = class("CSystemSetPart", CPageBase)

function CSystemSetPart.ctor(self, obj)

	CPageBase.ctor(self, obj)
	self.m_LocalVolume = {}
    self.BtnList = {
        {name = "推送设置", sort = 1, fun = "OnMsgPushSetting", hide = true},
        {name = "三界精灵", sort = 2, fun = "OnSpirit", hide = not g_SpiritCtrl:GetOpenState() },
        {name = "客服反馈", sort = 3, fun = "OnFeedback", hide = not g_FeedbackCtrl:IsFeedbackOpen()},
        {name = "用户中心", sort = 4, fun = "OnAccountCenter", hide = Utils.IsPC() or not g_SdkCtrl:IsSupportUserCenter()},
    }
end

function CSystemSetPart.OnInitPage(self)

	self.m_MusicCheckSprite = self:NewUI(1, CSprite)
	self.m_MusicSlider = self:NewUI(2, CSlider)

	self.m_SoundEffectCheckSprite = self:NewUI(3, CSprite)
	self.m_SoundEffectSlider = self:NewUI(4, CSlider)

	self.m_VoiceCheckSprite = self:NewUI(5, CSprite)
	self.m_VoiceSlider = self:NewUI(6, CSlider)
	self.m_SavePowerModeCheckSprite = self:NewUI(7, CSprite)
	self.m_Open = self:NewUI(8, CSprite)

	self.m_SaveRestNotifyModeCheckSprite = self:NewUI(9, CSprite)
	self.m_RestNotifyOpen = self:NewUI(10, CSprite)

	self.m_BtnGrid = self:NewUI(11, CGrid)

	self.m_ItemBtn = self:NewUI(12, CBox)

	self:InitContent()

end

function CSystemSetPart.InitContent(self)

    g_FeedbackCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFeedbackEvent"))

	local tOn_OffData = g_SystemSettingsCtrl.m_OnOff

	--音乐开关
	self.m_MusicCheckSprite:AddUIEvent("click", callback(self, "OnMusicCheckSprite"))
	self.m_MusicCheckSprite:SetSelected(tOn_OffData[1])
	self:SetOnoff(1,tOn_OffData[1])

	--音乐百分比
	self.m_MusicSlider:AddUIEvent("click", callback(self, "OnMusicPercentageChanged"))
	self.m_MusicSlider:AddUIEvent("change", callback(self, "OnMusicPercentageChanged"))
	self:SetSliderEnabled(self.m_MusicSlider, tOn_OffData[1],1)

	--音效开关
	self.m_SoundEffectCheckSprite:AddUIEvent("click", callback(self, "OnSoundEffectCheckSprite"))
	self.m_SoundEffectCheckSprite:SetSelected(tOn_OffData[2])
	self:SetOnoff(2,tOn_OffData[2])
	
	--音效百分比
	self.m_SoundEffectSlider:AddUIEvent("click", callback(self, "OnSoundEffectPercentageChanged"))
	self.m_SoundEffectSlider:AddUIEvent("change", callback(self, "OnSoundEffectPercentageChanged"))
	self:SetSliderEnabled(self.m_SoundEffectSlider, tOn_OffData[2],2)
	
	--语音
	self.m_VoiceCheckSprite:AddUIEvent("click", callback(self, "OnVoiceClick"))
	self.m_VoiceCheckSprite:SetSelected(tOn_OffData[3])
	self:SetOnoff(3,tOn_OffData[3])

	--语音百分比
	self.m_VoiceSlider:AddUIEvent("click", callback(self, "OnVoicePercentageChanged"))
	self.m_VoiceSlider:AddUIEvent("change", callback(self, "OnVoicePercentageChanged"))
	self:SetSliderEnabled(self.m_VoiceSlider, tOn_OffData[3],3)

	--省电模式
	self.m_SavePowerModeCheckSprite:AddUIEvent("click", callback(self, "OnSavePowerModeCheckSprite"))
	self.m_SavePowerModeCheckSprite:SetSelected(tOn_OffData[4])
	self.m_Open:SetActive(not tOn_OffData[4])

	--贴心管家
	self.m_SaveRestNotifyModeCheckSprite:AddUIEvent("click", callback(self, "OnSaveRestNotifyModeCheckSprite"))
	self.m_SaveRestNotifyModeCheckSprite:SetSelected(tOn_OffData[6])
	self.m_RestNotifyOpen:SetActive(not tOn_OffData[6])

	self:InitOtherBtn()
	
end

function CSystemSetPart.InitOtherBtn(self)

	local setItemBtnInfo = function (itemBtn, info)
		itemBtn.name = itemBtn:NewUI(1, CLabel)
		itemBtn.collider = itemBtn:NewUI(2, CSprite)
		if info.fun then 
			itemBtn.collider:AddUIEvent("click", callback(self, info.fun))
		end 
		itemBtn.name:SetText(info.name)
        if info.name == "客服反馈" then
            if g_FeedbackCtrl.m_bShowRedpt then
                itemBtn.collider:AddEffect("RedDot", 22, Vector2(-15, -17))
            else
                itemBtn.collider:DelEffect("RedDot")
            end
        end
	end

	for k, v in ipairs(self.BtnList) do
        if not v.hide then 
            local item = self.m_BtnGrid:GetChild(k)
            if not item then 
                item = self.m_ItemBtn:Clone()
                item:SetActive(true)
                self.m_BtnGrid:AddChild(item)
            end 
            item:SetName(tostring(v.sort))
            setItemBtnInfo(item, v)
        end
	end 

	self.m_BtnGrid:Reposition()

end

--开关
function CSystemSetPart.SetOnoff(self, index, isEnabled)
    local on_off = isEnabled == true and 1 or 0
    local sliderValue = g_SystemSettingsCtrl.m_Values[index].value/100
    if index == 1 then  --设置音乐的开和关
       g_SystemSettingsCtrl:SetMusicVolume(on_off*sliderValue)
    end
    if index == 2 then  --设置音效的开和关
       g_SystemSettingsCtrl:SetSoundVolume(on_off*sliderValue)
    end
    if index == 3 then  --设置语音的开和关
       g_SystemSettingsCtrl:SetVoiceVolume(on_off*sliderValue)
    end

end

--根据开关判断是否可以滑动
function CSystemSetPart.SetSliderEnabled(self, slider, isEnabled, index)
    slider:SetEnabled(isEnabled)
    if isEnabled == false then
       local sliderValue = g_SystemSettingsCtrl.m_Values[index].value/100
       -- if sliderValue <= 0 then
       --    return
       -- end
       self.m_LocalVolume[index] = sliderValue
       g_SystemSettingsCtrl:SaveLocalSettings(index, 0)
       slider:SetValue(0)
    else
       local val = self.m_LocalVolume[index] or g_SystemSettingsCtrl.m_Values[index].value/100
       g_SystemSettingsCtrl:SaveLocalSettings(index, val)
       slider:SetValue(val)
    end
    -- 以后可能会修改，例如加上百分比 Text
end

function CSystemSetPart.OnMusicCheckSprite(self)

    local isChecked = self.m_MusicCheckSprite:GetSelected()
    --printc("系统设置界面，音乐, isChecked = " .. tostring(isChecked))
    self:SetSliderEnabled(self.m_MusicSlider, isChecked, 1)
    self:SetOnoff(1, isChecked)
    g_SystemSettingsCtrl:SaveLocalOnOffSettings(1, isChecked)

end

function CSystemSetPart.OnMusicPercentageChanged(self)

    local percentage = self.m_MusicSlider:GetValue()
    percentage = self:ReverseFloatingNumber(percentage)
    printc("系统设置界面，音乐百分比：" .. percentage)
    g_SystemSettingsCtrl:SaveLocalSettings(1, percentage)
    g_SystemSettingsCtrl:SetMusicVolume(percentage)

end

function CSystemSetPart.OnMusicCheckSprite(self)

    local isChecked = self.m_MusicCheckSprite:GetSelected()
    printc("系统设置界面，音乐, isChecked = " .. tostring(isChecked))
    self:SetSliderEnabled(self.m_MusicSlider, isChecked, 1)
    self:SetOnoff(1, isChecked)
    g_SystemSettingsCtrl:SaveLocalOnOffSettings(1, isChecked)

end

function CSystemSetPart.OnSoundEffectCheckSprite(self)

    local isChecked = self.m_SoundEffectCheckSprite:GetSelected()
    self:SetSliderEnabled(self.m_SoundEffectSlider, isChecked, 2)
    self:SetOnoff(2, isChecked)
    g_SystemSettingsCtrl:SaveLocalOnOffSettings(2, isChecked)

end

function CSystemSetPart.OnSoundEffectPercentageChanged(self)

    local percentage = self.m_SoundEffectSlider:GetValue()
    percentage = self:ReverseFloatingNumber(percentage)
   -- printc("系统设置界面，音效百分比：" .. percentage)
    g_SystemSettingsCtrl:SaveLocalSettings(2, percentage)
    g_SystemSettingsCtrl:SetSoundVolume(percentage)

end

function CSystemSetPart.OnVoiceClick(self)

    local isChecked = self.m_VoiceCheckSprite:GetSelected()
    self:SetSliderEnabled(self.m_VoiceSlider, isChecked, 3)
    self:SetOnoff(3, isChecked)
    g_SystemSettingsCtrl:SaveLocalOnOffSettings(3, isChecked)

end

function CSystemSetPart.OnVoicePercentageChanged(self)

    local percentage = self.m_VoiceSlider:GetValue()
    percentage = self:ReverseFloatingNumber(percentage)
    g_SystemSettingsCtrl:SaveLocalSettings(3, percentage)
    g_SystemSettingsCtrl:SetVoiceVolume(percentage)

end
function CSystemSetPart.OnSavePowerModeCheckSprite(self)

    local isChecked = self.m_SavePowerModeCheckSprite:GetSelected()
    self.m_Open:SetActive(not isChecked)
    g_SystemSettingsCtrl:SaveLocalOnOffSettings(4, isChecked)
    g_SystemSettingsCtrl:StartCheckClick(isChecked)   --检测是否进入省电模式
    if isChecked then
        g_NotifyCtrl:FloatMsg("一段时间不操作进入省电模式")
    else
        g_NotifyCtrl:FloatMsg("已退出省电模式")
    end

end

function CSystemSetPart.OnSaveRestNotifyModeCheckSprite(self)

    local isChecked = self.m_SaveRestNotifyModeCheckSprite:GetSelected()
    self.m_RestNotifyOpen:SetActive(not isChecked)
    g_SystemSettingsCtrl:SaveLocalOnOffSettings(6, isChecked)
    if isChecked then
        g_NotifyCtrl:FloatMsg("一段时间不操作显示贴心管家")
    else
        g_NotifyCtrl:FloatMsg("已禁止显示贴心管家")
    end

end

function CSystemSetPart.ReverseFloatingNumber(self, number)    -- 现在保留两位小数
    return number - number % 0.01
end



function CSystemSetPart.OnAccountCenter(self)
    --printc("点击系统设置界面,用户中心按钮")
    g_NotifyCtrl:FloatMsg("用户中心")
    g_SdkCtrl:EnterUserCenter()
end

function CSystemSetPart.OnMsgPushSetting(self)
    if not g_SdkCtrl:IsInitXG() then
        g_NotifyCtrl:FloatMsg("推送初始化失败，请重启后尝试")
        return
    end
    CPushSettingsView:ShowView()
end

function CSystemSetPart.OnFeedback(self)
    CFeedbackMainView:ShowView(function(oView)
        if g_FeedbackCtrl.m_bShowRedpt then
            g_FeedbackCtrl.m_bShowRedpt = false
            netother.C2GSFeedBackSetCheckState()
            g_FeedbackCtrl:OnEvent(define.Feedback.Event.RefreshFeedbackRedPt)
        end
    end)
end

function CSystemSetPart.OnSpirit(self)
    if Utils.IsPC() or g_LoginPhoneCtrl.m_IsQrPC then
        UnityEngine.Application.OpenURL(g_SpiritCtrl:GetUrl())
    else
        CSpiritInfoView:ShowView(function (oView)
            oView:RefreshUI()
        end)
    end
end

function CSystemSetPart.OnFeedbackEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Feedback.Event.RefreshFeedbackRedPt then
        self:InitOtherBtn()
    end
end

return CSystemSetPart