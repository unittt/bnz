local CSystemSettingsCtrl = class("CSystemSettingsCtrl")

CSystemSettingsCtrl.m_Values = {
   {id = 1, value = 100 }, --音乐
   {id = 2, value = 100 }, --音效
   {id = 3, value = 100 }, --语音
   {id = 4, value = 100 }, --画质
}


function CSystemSettingsCtrl.ctor(self)
    CCtrlBase.ctor(self)
    self.m_InShengdianModel = false
    self.m_Brightness = 255
    self.m_RecomendImage = 1
    self.m_CurBrightness = C_api.Utils.GetScreenBrightness()
    -- (音乐，音效，语音，省电，锁屏开关，贴心管家, 拒绝添加我为好友, 加好友需要验证, 拒绝陌生人信息）
    self.m_OnOff = {true, true, true, true, false, true, false, true, true}
    self.m_OnOffCount = 9

    -- self.m_WarEffectState = true
    -- self.m_WeaponEffectState = true
    -- self.m_RideEffectState = true
    -- self.m_SceneEffectState = true
    -- self.m_WingEffectState = true

    local renderLv = self:GetRenderLv()
    self.m_DefaultEffect = {
        scene = renderLv, 
        weapon = renderLv, 
        war = renderLv,
        ride = renderLv,
        wing = renderLv,
    }

    self.m_SameScreenLv = self:GetCpuLv()
end

function CSystemSettingsCtrl.Clear(self)
    self.m_OnOff = {true, true, true, true, false, true, false, true, true}
end

function CSystemSettingsCtrl.InitData(self)
    --self.m_Timer_save = nil
end

function CSystemSettingsCtrl.Reset(self)
    --printc("-------重置点击记录，计时器------")
    if self.m_Timer_save then
        Utils.DelTimer(self.m_Timer_save)
        self.m_Timer_save = nil
    end
    self:InitData()
end

function CSystemSettingsCtrl.InitEffectOpen(self)
    local effectlist = self:GetEffectOpenInfo()
    for k, v in pairs(effectlist) do
        if k == "scene" then
            self:OpenSceneEffect(v)
        elseif k == "weapon" then
            self:OpenWeaponEffect(v)
        elseif k == "war" then
            self:OpenWarEffectState(v)
        elseif k == "ride" then
            self:OpenRideEffect(v)
        elseif k == "wing" then 
            self:OpenWingEffect(v)
        end 
    end
end

function CSystemSettingsCtrl.InitSameScreenLv(self)
    
    local lv = self:GetSameScreenLv()
    g_MapPlayerNumberCtrl:SetMapPlayerNumber(lv)

end

function CSystemSettingsCtrl.GetSameScreenLv(self)
    
    local sameScrLv = IOTools.GetClientData("SameScreenSetting")
    sameScrLv = sameScrLv or self.m_SameScreenLv
    return sameScrLv

end

function CSystemSettingsCtrl.SetSameScreenLv(self, lv)
    
    g_MapPlayerNumberCtrl:SetMapPlayerNumber(lv)
    IOTools.SetClientData("SameScreenSetting", lv)

end

function CSystemSettingsCtrl.ReadLocalSettings(self)
    local settingInfo = IOTools.GetClientData("system_settings")
    if settingInfo then
        self.m_Values = settingInfo
        self:LoginSet(self.m_Values)
    end
    self:InitEffectOpen()
    self:InitSameScreenLv()
end

--保存数据
function CSystemSettingsCtrl.SaveLocalSettings(self, k, v)
    local tAccount = self.m_Values
    for key,val in pairs(tAccount) do
        if val.id == k then
            tAccount[key].value = v*100
        end
    end
    IOTools.SetClientData("system_settings", tAccount)
end

--保存开关值
function CSystemSettingsCtrl.SaveLocalOnOffSettings(self, k, v)
    local tOn_Off = self.m_OnOff
    tOn_Off[k] = v
end

--设置音乐大小
function CSystemSettingsCtrl.SetMusicVolume(self, value)
    g_AudioCtrl:SetMusicVol(value)
end

--设置音效大小
function CSystemSettingsCtrl.SetSoundVolume(self, value)
    g_AudioCtrl:SetSoundVol(value)
end

--设置语音大小
function CSystemSettingsCtrl.SetVoiceVolume(self, value)
    g_AudioCtrl:SetSoloVol(value)
end

function CSystemSettingsCtrl.C2GSSysConfig(self)
    --printc("发送系统设置到服务器")
    local on_off = self:ChangeOnOffDecimal()
    netplayer.C2GSSysConfig(on_off, self.m_Values)
end

function CSystemSettingsCtrl.GS2CSysConfig(self, pbdata)
    local on_off = pbdata.on_off --二进制开关，前端使用位操作
    local values = pbdata.values
    table.print(pbdata,"服务器下发系统设置数据:")

    if next(pbdata) ~= nil then
        self.m_Values[4] = values[4] --只同步画质设置
        self:ChangeOnOffBinary(on_off)
    end
    self:LoginSet(self.m_Values)
end

--开关值转为10进制数据
function CSystemSettingsCtrl.ChangeOnOffDecimal(self)
    local sum = 0
    local sendData = self.m_OnOff
    for k,v in ipairs(sendData) do 
        v = v and 1 or 0
        sum = sum + MathBit.lShiftOp(v, k-1)
    end
    -- printc(sum)
    return sum
end

--解析服务器下发开关值
function CSystemSettingsCtrl.ChangeOnOffBinary(self, openValue)
    self.m_OnOff = {}
    for i= 1, self.m_OnOffCount do
        local temp = MathBit.andOp(MathBit.rShiftOp(openValue,i-1),1)
        self.m_OnOff[i] = temp == 1
    end

    -- table.print(self.m_OnOff, "--- 解析服务器下发开关值 ---")
end

--设置屏幕亮度
function CSystemSettingsCtrl.SetScreenBright(self, brightness)
    C_api.Utils.SetBrightness(brightness)
end

--获取屏幕亮度
function CSystemSettingsCtrl.GetScreenBrightness(self)
    return C_api.Utils.GetScreenBrightness()
end

--检测是否点击屏幕
function CSystemSettingsCtrl.CheckClick(self, isClick)
    if isClick and self.m_OnOff[4] then
        self:StartCheckClick()
    end
end

function CSystemSettingsCtrl.StartCheckClick(self, bResetBright)
    self:Reset()
    local isOn_off = self.m_OnOff[4]
    -- printc("---省电模式是否开启-----", isOn_off)
    if isOn_off then
        if bResetBright and self.m_InShengdianModel then
            -- 是否进行重置亮度,登录和退出省电模式会执行这里
            -- printc("进行重置亮度")
            if Utils.IsAndroid() then
                self:SetScreenBright(-1)
            else
                self:SetScreenBright(math.floor(self.m_CurBrightness))
            end
            -- 退出省电帧率恢复
            main.ChangeFrameRate(30)

            local openInfo = self:GetEffectOpenInfo()
            self:OpenSceneEffect(openInfo.scene)
            self:OpenWeaponEffect(openInfo.weapon)
            self:OpenRideEffect(openInfo.ride)
            self:OpenWingEffect(openInfo.wing)
            self.m_InShengdianModel = false
            g_NotifyCtrl:RefreshPowerSaveLayer(false)
        end
        local update = function()  
            --g_NotifyCtrl:FloatMsg("进入省电模式")
            -- 降低屏幕亮度 
            --(==========接口貌似无效============)
            self.m_CurBrightness = self:GetScreenBrightness()
            self:SetScreenBright(math.floor(self.m_Brightness*0.2))

            -- 进入省电帧率降低
            main.ChangeFrameRate(10)
            --关特效
            local minLv = 0
            self:OpenSceneEffect(minLv)
            self:OpenWeaponEffect(minLv)
            self:OpenRideEffect(minLv)
            self:OpenWingEffect(minLv)
            self.m_InShengdianModel = true
            --灰色遮罩层
            g_NotifyCtrl:RefreshPowerSaveLayer(true)
            return false
        end
        --进入省电模式的检查时间
        self.m_Timer_save = Utils.AddTimer(update, 0, 300)
    end
end

--设置画质
function CSystemSettingsCtrl.SetImage(self)
    --local imageLevel = self.m_Values[4].value/100
    -- printc("设置画质：",imageLevel)
    --g_MapCtrl:SetAllMapEffectActive(imageLevel > 2, false)

    --self:OpenWeaponEffect(true)

    -- if imageLevel > 2 then 
    --     self:OpenRideEffect(true)
    -- else
    --     self:OpenRideEffect(false)
    -- end 

end

function CSystemSettingsCtrl.GetEffectOpenInfo(self)

    local effectlist = IOTools.GetClientData("SysEffectSettingValue") or self.m_DefaultEffect
    return effectlist

end

function CSystemSettingsCtrl.SaveSceneLv(self, lv)
    local openInfo = self:GetEffectOpenInfo()
    openInfo.scene = lv
    self:SetEffectOpenInfo(openInfo)
    self:OpenSceneEffect(lv)


end

function CSystemSettingsCtrl.SaveWeaponLv(self, lv)
    local openInfo = self:GetEffectOpenInfo()
    openInfo.weapon = lv
    self:SetEffectOpenInfo(openInfo)
    self:OpenWeaponEffect(lv)

end

function CSystemSettingsCtrl.SaveRideLv(self, lv)
    local openInfo = self:GetEffectOpenInfo()
    openInfo.ride = lv
    self:SetEffectOpenInfo(openInfo)
    self:OpenRideEffect(lv)

end

function CSystemSettingsCtrl.SaveWingLv(self, lv)
    local openInfo = self:GetEffectOpenInfo()
    openInfo.wing = lv
    self:SetEffectOpenInfo(openInfo)
    self:OpenWingEffect(lv)

end

function CSystemSettingsCtrl.SetEffectOpenInfo(self, openInfo)
    
     IOTools.SetClientData("SysEffectSettingValue", openInfo)

end

--设置场景特效
function CSystemSettingsCtrl.OpenSceneEffect(self, lv)
    
    self.m_SceneEffectState = lv > 0 and true or false
    g_MapCtrl:SetMapEffectActive(self.m_SceneEffectState)

end

--战斗特效
function CSystemSettingsCtrl.OpenWarEffectState(self, lv)
    
    self.m_WarEffectState = lv > 0 and true or false

end

--武器特效
function CSystemSettingsCtrl.OpenWeaponEffect(self, lv)
    
    self.m_WeaponEffectLv = lv 

    if not g_MapCtrl.m_Players then 
        return
    end
  
    for k, oPlayer in pairs(g_MapCtrl.m_Players) do
         if k ~= g_AttrCtrl.pid then 
             oPlayer:ShowWeaponEffect(lv)
         else
             oPlayer:ShowWeaponEffect(define.Performance.Level.high)
         end 
    end  

end

--坐骑特效
function CSystemSettingsCtrl.OpenRideEffect(self, lv)

    self.m_RideEffectLv = lv
   
   for k, oPlayer in pairs(g_MapCtrl.m_Players) do
        if k ~= g_AttrCtrl.pid then 
            oPlayer:ShowRideEffect(lv)
        else
            oPlayer:ShowRideEffect(define.Performance.Level.high)
        end 
   end

end

--翅膀特效
function CSystemSettingsCtrl.OpenWingEffect(self, lv)
    
     self.m_WingEffectLv = lv

     if not g_MapCtrl.m_Players then 
         return
     end
   
    for k, oPlayer in pairs(g_MapCtrl.m_Players) do
         if k ~= g_AttrCtrl.pid then 
             oPlayer:ShowWingEffect(lv)
         else
             oPlayer:ShowWingEffect(define.Performance.Level.high)
         end 
    end

end

function CSystemSettingsCtrl.GetWingEffectLv(self)
    
    return self.m_WingEffectLv

end

function CSystemSettingsCtrl.GetRideEffectLv(self)
    
    return self.m_RideEffectLv

end

function CSystemSettingsCtrl.GetWeaponEffectLv(self)
    
    return self.m_WeaponEffectLv

end

function CSystemSettingsCtrl.GetWarEffectState(self)
    
    return self.m_WarEffectState

end

function CSystemSettingsCtrl.GetSceneEffectState(self)
    
    return self.m_SceneEffectState

end


--画质等级
function CSystemSettingsCtrl.GetImageLevel(self)
    return self.m_Values[4].value/100  --当前画质
end

--特效开关
function CSystemSettingsCtrl.GetCurImage(self)
    local imageLevel = self.m_Values[4].value/100  --当前画质
    return imageLevel > 2 and true or false
end

--登录后系统设置生效
function CSystemSettingsCtrl.LoginSet(self, setValue)
    printc("登录系统设置生效")
    self:SetMusicVolume(setValue[1].value/100)
    self:SetSoundVolume(setValue[2].value/100)
    self:SetVoiceVolume(setValue[3].value/100)
    self:StartCheckClick()
end

-- 获取指定开关
function CSystemSettingsCtrl.GetSitchByIndex(self, index)
    return self.m_OnOff[index]
end

function CSystemSettingsCtrl.GS2CGamePushConfig(self, values)
    do return end
    self.m_PushConfigs = {}
    for i,v in ipairs(values) do
        self.m_PushConfigs[v.id] = v.value
    end
    local dData = data.gamepushdata.DATA
    for i,dPush in pairs(dData) do
        if not self.m_PushConfigs[dPush.id] or self.m_PushConfigs[dPush.id] == 0 then
            C_api.XinGeSdk.SetTag("PUSH_TASK_"..dPush.id)
        else
            C_api.XinGeSdk.DeleteTag("PUSH_TASK_"..dPush.id)
        end
    end
end

function CSystemSettingsCtrl.GetGamePushConfigById(self, id)
    --推送是0开启1关闭
    return self.m_PushConfigs[id] or 0 
end

function CSystemSettingsCtrl.SetGamePushConfig(self, id, value)
    self.m_PushConfigs[id] = value
end

function CSystemSettingsCtrl.ShowPushSettingView(self)
    CPushSettingsView:ShowView()
end

function CSystemSettingsCtrl.GetRenderLv(self)
    
    if Utils.IsAndroid() then 
        local msize = tonumber(tostring(C_api.PlatformAPI.getTotalMemory()/1024))
        local memoryConfig = data.performancedata.MEMORY
        for k, v in ipairs(memoryConfig) do
            if k == 3 then 
                if msize > v.low then 
                    return v.lv
                end 
            else
                if msize > v.low and msize <= v.high then 
                    return v.lv
                end 
            end  
        end 
    elseif Utils.IsIOS() then 
        return self:GetIosMemoryLv()
    else
        return define.Performance.Level.high
    end 

end

function CSystemSettingsCtrl.GetIosMemoryLv(self)
    
    local msize = tonumber(tostring(C_api.PlatformAPI.getTotalMemory()/1024))
    local memoryConfig = data.performancedata.MEMORY
    local lv = define.Performance.Level.mid
    for k, v in ipairs(memoryConfig) do
        if k == 3 then 
            if msize > v.lowIos then 
                lv = v.lv
            end 
        else
            if msize > v.lowIos and msize <= v.hightIos then 
                lv = v.lv
            end 
        end  
    end 

    return lv

end

function CSystemSettingsCtrl.GetIOSCpuLv(self)
    
    local cpuFrequency = UnityEngine.SystemInfo.processorFrequency
    local config = data.performancedata.CPUFREQUENCY
    for k, v in ipairs(config) do
        if k == 3 then 
            if cpuFrequency > v.lowIos then 
                return v.lv
            end 
        else
            if cpuFrequency > v.lowIos and cpuFrequency <= v.hightIos then 
                return v.lv
            end 
        end
    end 

end

function CSystemSettingsCtrl.GetAndroidCpuLv(self)
    
    local cpuFrequency = UnityEngine.SystemInfo.processorFrequency
    local cpuCount = UnityEngine.SystemInfo.processorCount
    local config = data.performancedata.CPUFREQUENCY
    local lv = define.Performance.Level.mid
    for k, v in ipairs(config) do
        if k == 3 then 
            if cpuFrequency > v.low then 
                if cpuCount >= 8 then 
                    lv = v.lv
                else
                    lv = define.Performance.Level.mid
                end 
            end 
        else
            if cpuFrequency > v.low and cpuFrequency <= v.high then 
                lv = v.lv
            end 
        end
    end

    return lv 

end

--获取cpu等级
function CSystemSettingsCtrl.GetCpuLv(self)
    
    local cpuFrequency = UnityEngine.SystemInfo.processorFrequency
    local lv = define.Performance.Level.low
    if Utils.IsAndroid() then 
        lv = self:GetAndroidCpuLv()
    elseif Utils.IsIOS() then 
        lv = self:GetIosMemoryLv()
    else
        lv = define.Performance.Level.high
    end 

    return lv

end

return CSystemSettingsCtrl