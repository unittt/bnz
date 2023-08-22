local CSystemSettingsMainView = class("CSystemSettingsMainView", CViewBase)

function CSystemSettingsMainView.ctor(self, cb)
    CViewBase.ctor(self, "UI/SystemSettings/SystemSetView.prefab", cb)
    self.m_DepthType = "Dialog"  --层次
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"

    self.m_ImageTable = {}
    self.m_LocalVolume = {}

    self.m_EffectOpenList = {"scene", "weapon", "war", "horse", "wing"}
end

function CSystemSettingsMainView.OnCreateView(self)
    self.m_CloseBtn = self:NewUI(1, CButton)

   
    self.m_LockScreenBtn = self:NewUI(2, CSprite)

    self.m_UpdateGongGaoBtn = self:NewUI(3, CButton)
    self.m_SwtichRoleBtn = self:NewUI(4, CButton)
    self.m_RalateMobBtn = self:NewUI(5, CButton)
    self.m_QuitGameBtn = self:NewUI(6, CButton)


    self.m_RoleNameLabel = self:NewUI(7, CLabel)
    self.m_RoleIDLabel = self:NewUI(8, CLabel)
    self.m_ServerLabel = self:NewUI(9, CLabel)
    self.m_HeadSprite = self:NewUI(10, CSprite)
    self.m_LevelLabel = self:NewUI(11, CLabel)
    self.m_SchoolSpr = self:NewUI(12, CSprite)

    self.m_QrBox = self:NewUI(13, CBox)
    self.m_QrBtn = self:NewUI(14, CButton)
    self.m_QrBox:SetActive(false)

    self.m_SysBtn = self:NewUI(15, CSprite)
    self.m_ImgBtn = self:NewUI(16, CSprite)

    self.m_SysPart = self:NewPage(17, CSystemSetPart)
    self.m_ImgPart = self:NewPage(18, CImageSetPart)

    self:InitContent()
end

function CSystemSettingsMainView.OnClickSysBtn(self)

    CGameObjContainer.ShowSubPageByIndex(self, 1)

end

function CSystemSettingsMainView.OnClickImgBtn(self)
    
    CGameObjContainer.ShowSubPageByIndex(self, 2)

end

function CSystemSettingsMainView.InitContent(self)
    local tAccount = g_SystemSettingsCtrl.m_Values
    local tOn_OffData = g_SystemSettingsCtrl.m_OnOff 

    -- 关闭按钮
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))


    local lv = g_SystemSettingsCtrl:GetSameScreenLv()

    self:ShowRecomendImage(g_SystemSettingsCtrl.m_RecomendImage)

    self.m_SysBtn:AddUIEvent("click", callback(self, "OnClickSysBtn"))
    self.m_ImgBtn:AddUIEvent("click", callback(self, "OnClickImgBtn"))

     CGameObjContainer.ShowSubPageByIndex(self, 1)

    -- 锁定屏幕
    self.m_LockScreenBtn:AddUIEvent("click", callback(self, "OnLockScreenBtn"))


    -- 头像
    self.m_HeadSprite:SpriteAvatar(g_AttrCtrl.icon)

    --角色等级
    self.m_LevelLabel:SetText(g_AttrCtrl.grade.."级")

    -- 服务器
    self.m_ServerLabel:SetText("服务器: " .. (g_ServerPhoneCtrl:GetCurServerName()))

    -- 角色名
    self.m_RoleNameLabel:SetText("角色名: " .. g_AttrCtrl.name)

    --角色id
    self.m_RoleIDLabel:SetText("角色ID: "..g_AttrCtrl.pid)

    --门派
    local tSchoolInfo = DataTools.GetSchoolInfo(g_AttrCtrl.school)
    self.m_SchoolSpr:SetSpriteName(tSchoolInfo.icon)

    -- 关联手机
    self.m_RalateMobBtn:AddUIEvent("click", callback(self, "OnSwitchAccountBtn"))

    -- 更换角色
    self.m_SwtichRoleBtn:AddUIEvent("click", callback(self, "OnSwtichRoleBtn"))

    -- 退出游戏
    self.m_QuitGameBtn:AddUIEvent("click", callback(self, "OnQuitGameBtn"))

    -- 更新公告
    self.m_UpdateGongGaoBtn:AddUIEvent("click", callback(self, "OnUpdateGongGaoBtn"))

    self.m_QrBtn:AddUIEvent("click", callback(self, "OnClickQrBtn"))

    --主要是为了请求角色信息
    g_ServerPhoneCtrl:UpdateGSData()

    if not g_LoginPhoneCtrl.m_IsPC and not g_LoginPhoneCtrl.m_IsQrPC then
        self.m_QrBox:SetActive(true)
    end
end



function CSystemSettingsMainView.UpdateEffectOpenState(self, itemName, open)
    if itemName == "scene" then
        g_SystemSettingsCtrl:OpenSceneEffect(open)
    elseif itemName == "weapon" then
        g_SystemSettingsCtrl:OpenWeaponEffect(open)
    elseif itemName == "war" then
        g_SystemSettingsCtrl:OpenWarEffectState(open)
    elseif itemName == "horse" then
        g_SystemSettingsCtrl:OpenRideEffect(open)
    elseif itemName == "wing" then 
        g_SystemSettingsCtrl:OpenWingEffect(open)
    end

    self.m_EffectInfo[itemName] = open
    IOTools.SetClientData("SysEffectSetting", self.m_EffectInfo)
end


function CSystemSettingsMainView.OnLockScreenBtn(self)
    g_NotifyCtrl:ShowLockScreen(true)
    self:OnClose()
end

function CSystemSettingsMainView.OnSwitchAccountBtn(self)
    --printc("系统设置界面，关联手机 clicked")
    g_NotifyCtrl:FloatMsg("关联手机")
end

function CSystemSettingsMainView.OnSwtichRoleBtn(self)
    local refresh = function()
    
        if g_LoginPhoneCtrl.m_IsPC then
            CSystemSettingsMainView:CloseView()
            CServerSelectPhoneView:ShowView(function (oView)
                oView:RefreshUI()
            end)
        else
            CSystemSettingsMainView:CloseView()
            CServerSelectPhoneView:ShowView(function (oView)
                oView:RefreshUI()
            end)
        end

    end
    local windowConfirmInfo = {
        title      = "切换角色",
        msg        = "确定切换角色？",
        okCallback = function()
            refresh()
        end,
        pivot = enum.UIWidget.Pivot.Center
    }
    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)
        self.m_WinTipViwe = oView
    end)
end

function CSystemSettingsMainView.OnUpdateGongGaoBtn(self)
    --printc("系统设置界面，更新公告 clicked")
    --g_NotifyCtrl:FloatMsg("更新公告")
    CUpdateNoticeView:ShowView(function (oView)
        oView:RefreshUI()
    end)
end

function CSystemSettingsMainView.OnQuitGameBtn(self)
    local refresh = function()
        if g_LoginPhoneCtrl.m_IsPC then
            g_LoginPhoneCtrl:ResetAllData()
            CLoginPhoneView:ShowView(function (oView)
                oView:RefreshUI()
            end)
        else
            if g_LoginPhoneCtrl.m_IsQrPC then
                g_LoginPhoneCtrl:ResetAllData()
                CLoginPhoneView:ShowView(function (oView)
                    oView:RefreshUI()
                end)
            else
                g_SdkCtrl:Logout()
            end
        end
    end
    
    local windowConfirmInfo = {
        title      = "注销登录",
        msg        = "确定登出当前账号？",
        okStr      = "登出",
        okCallback = function()
            refresh()
        end,
        pivot = enum.UIWidget.Pivot.Center
    }
    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)
        self.m_WinTipViwe = oView
    end)
end

function CSystemSettingsMainView.OnAccountCenter(self)
    --printc("点击系统设置界面,用户中心按钮")
    g_NotifyCtrl:FloatMsg("用户中心")
    g_SdkCtrl:EnterUserCenter()
end

function CSystemSettingsMainView.OnSoundEffectPercentageChanged(self)
    local percentage = self.m_SoundEffectSlider:GetValue()
    percentage = self:ReverseFloatingNumber(percentage)
   -- printc("系统设置界面，音效百分比：" .. percentage)
    g_SystemSettingsCtrl:SaveLocalSettings(2, percentage)
    g_SystemSettingsCtrl:SetSoundVolume(percentage)
end


function CSystemSettingsMainView.ReverseFloatingNumber(self, number)    -- 现在保留两位小数
    return number - number % 0.01
end

--根据开关判断是否可以滑动
function CSystemSettingsMainView.SetSliderEnabled(self, slider, isEnabled, index)
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

--开关
function CSystemSettingsMainView.SetOnoff(self, index, isEnabled)
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

function CSystemSettingsMainView.SetDragActive(self,dragBox,value)
    --printc("SetDragActive---",value)
    if value <= 0.05 then
        dragBox:SetActive(false)
    else
        dragBox:SetActive(true)
    end
end

function CSystemSettingsMainView.OnClose(self)
    self:CloseView()
    --self.m_LocalVolume = {}
    g_SystemSettingsCtrl:C2GSSysConfig()
end

function CSystemSettingsMainView.ShowRecomendImage(self, index)
    -- local image_obj = self.m_ImageGrid:GetChild(index)
    -- image_obj.recommend:SetActive(true)
end

function CSystemSettingsMainView.OnClickQrBtn(self)
    local oSysView = CSystemSettingsMainView:GetView()
    if oSysView then
        oSysView:SetActive(false)
    end
    local function closeCallback()
        local oSysView = CSystemSettingsMainView:GetView()
        if oSysView then
            oSysView:SetActive(true)
        end
    end
    CQRCodeScanView:CloseView()
    CQRCodeScanView:ShowView(function (oView)
        oView:SetData(closeCallback)
    end)
end

function CSystemSettingsMainView.OnMsgPushSetting(self)
    if not g_SdkCtrl:IsInitXG() then
        g_NotifyCtrl:FloatMsg("推送初始化失败，请重启后尝试")
        return
    end
    CPushSettingsView:ShowView()
end

return CSystemSettingsMainView