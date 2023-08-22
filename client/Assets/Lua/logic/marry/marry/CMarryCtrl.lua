local CMarryCtrl = class("CMarryCtrl", CCtrlBase)

function CMarryCtrl.ctor(self, obj)
    CCtrlBase.ctor(self)
    self.m_XtId = 10148
    self:Reset()
end

function CMarryCtrl.Reset(self)
    self.m_IsInMyWedding = true

    -- wedding
    self.m_Bride = nil
    self.m_Groom = nil
    self.m_MarryNo = nil
    self.m_MarryType = nil
    self.m_WeddingTime = -1
    self.m_CacheWedding = nil
end

function CMarryCtrl.ShowScene(self, sceneId, mapId, bIsPlot)
    if not bIsPlot then
        self:EndWedding()
    end
end

function CMarryCtrl.EndWedding(self, bCheckCache)
    if g_MarryPlotCtrl:IsPlayingWeddingPlot() then
        g_MarryPlotCtrl:FinishWeddingPlot()
    end
    self.m_IsInMyWedding = false
    self.m_Bride = nil
    self.m_Groom = nil
    self.m_MarryNo = nil
    self.m_MarryType = nil
    self.m_WeddingTime = -1
    if g_MarryPlotCtrl:IsCheckWedding() then
        g_MarryPlotCtrl:DelCheckPlayTimer()
        g_MarryPlotCtrl.m_IsCheckWedding = false
        g_MarryPlotCtrl.m_DelayPlayElapsedTime = 0
    end
    if bCheckCache and self.m_CacheWedding then
        self:GS2CMarryWedding(self.m_CacheWedding)
    end
    self.m_CacheWedding = nil
end

--------------------- 图片相关 -------------------
function CMarryCtrl.PushWeddingTexture(self, key, cb)
    local sPath = self:GetWeddingTexturePath(key)
    local iTime = os.time()
    printc("begin push wedding texture ------ ", key)
    g_QiniuCtrl:UploadFile(key, sPath, enum.QiniuType.Image, function(key, success)
        if cb then
            cb(key, success)
        end
        printc("push wedding texture ------ ", key, (success and "success" or "fail"), "time ----- ", os.time() - iTime)
        if success then
            netmarry.C2GSSetMarryPic(key)
        end
    end)
end

function CMarryCtrl.FetchWeddingTexture(self, key, cb)
    local iTime = os.time()
    printc("begin download wedding texture ---- ", key)
    g_QiniuCtrl:DownloadFile(key, function (key, www)
        if www then
            local oTex = www.texture
            if cb then
                cb(oTex, key)
            end
            self:SaveLocalWeddingTexture(oTex, key)
            printc("success download Wedding texture ------- ", key, "load time -------- ", os.time() - iTime)
        else
            printc("fail download Wedding texture !!! ------- ", key, "load time -------- ", os.time() - iTime)
        end
    end)
end

function CMarryCtrl.SaveLocalWeddingTexture(self, oTex, key, bRt)
    if not oTex then return end
    local sPath = self:GetWeddingTexturePath(key)
    local bytes = oTex:EncodeToJPG()
    IOTools.SaveByteFile(sPath, bytes)
    -- if Utils.IsIOS() then
    --     C_api.ImagePickerManager.Instance:SaveTextureToCameraRoll(oTex)
    -- end
end

function CMarryCtrl.GetLocalWeddingTexture(self, key, width, height)
    local sPath = self:GetWeddingTexturePath(key)
    if IOTools.IsExist(sPath) then
        local bytes = IOTools.LoadByteFile(sPath)
        local oTex = UnityEngine.Texture2D.New(width, height)
        oTex:LoadImage(bytes)
        return oTex
    end
end

function CMarryCtrl.GetWeddingTexturePath(self, key)
    local sFileName = key..".png"
    local sPath
    if Utils.IsAndroid() then
        sPath = "/mnt/sdcard/DCIM/DHXX/"..sFileName
    else
        sPath = IOTools.GetRoleFilePath("/"..sFileName)
    end
    return sPath
end

function CMarryCtrl.GetWeddingPicKey(self, iGroom, iBride)
    return string.format("%d_%dWedding", iGroom, iBride)
end

function CMarryCtrl.GetMyWeddingPicKey(self)
    if self.m_IsInMyWedding and self.m_Groom and self.m_Bride then
        local iPid1, iPid2 = self.m_Groom.pid, self.m_Bride.pid
        if g_AttrCtrl.pid ~= iPid1 then
            local t = iPid1
            iPid1 = iPid2
            iPid2 = t
        end
        return self:GetWeddingPicKey(iPid1, iPid2)
    elseif self:IsMarried() then
        local iPartner = self:GetPartnerPid()
        if iPartner then
            return self:GetWeddingPicKey(g_AttrCtrl.pid, iPartner)
        end
    end
end

function CMarryCtrl.GetPartnerPid(self)
    local dEngage = g_AttrCtrl.engageInfo
    return dEngage and dEngage.pid
end

------------------------ data ----------------------
function CMarryCtrl.IsInMyWedding(self)
    return self.m_IsInMyWedding
end

function CMarryCtrl.IsMarried(self)
    local dEngage = g_AttrCtrl.engageInfo
    return dEngage and dEngage.status == define.Engage.State.Marry or false
end

function CMarryCtrl.IsSingle(self)
    return not (self:IsInMyWedding() or self:IsMarried())
end

function CMarryCtrl.GetMarryType(self)
    local dEngage = g_AttrCtrl.engageInfo
    return dEngage and dEngage.etype or -1
end

function CMarryCtrl.GetMarryTime(self)
    local dEngage = g_AttrCtrl.engageInfo
    return dEngage and dEngage.marry_time or -1
    
end

function CMarryCtrl.GetWeddingTime(self)
    return self.m_WeddingTime
end

function CMarryCtrl.GetMarryConfig(self)
    return data.engagedata.CONFIG
end

function CMarryCtrl.GetMarryText(self, id)
    local dText = data.engagedata.TEXT[id]
    return dText and dText.content
end

function CMarryCtrl.MarryFloatMsg(self, id)
    local sText = self:GetMarryText(id)
    if sText then
        g_NotifyCtrl:FloatMsg(sText)
    end
end

function CMarryCtrl.IsScreenShotPlot(self)
    return self.m_WeddingTime == 0
end

function CMarryCtrl.GetProtagonistName(self, iSex)
    if g_AttrCtrl.sex == iSex then
        return g_AttrCtrl.name
    end
    local dEngage = g_AttrCtrl.engage_info
    return dEngage and dEngage.name or ""
end

---------------------- view ------------------------
function CMarryCtrl.ShowShareMarriedView(self, bScreenShot, cb)
    CMarrySharedView:ShowView(function(oView)
        if bScreenShot then
            oView:ScreenShot()
        else
            oView:SetMarryTexture()
        end
        if cb then
            cb()
        end
    end)
end

function CMarryCtrl.OpenXTGiftView(self)
    CMarryXTGiftView:ShowView()
end

function CMarryCtrl.ShowXTComfirm(self, args)
    local sContent = args.text or "送你一颗喜糖"
    local windowConfirmInfo = {
        title = "赠送喜糖",
        msg = string.format("[244b4e]是否向#G%s#n赠送#R%d#n颗喜糖？[-]", args.name, args.amount),
        okStr = "确定",
        color = Color.white,
        okCallback = function()
            netmarry.C2GSPresentXT(args.pid, args.amount, sContent)
            local cb = args.cb
            if cb then
                cb()
            end
        end
    }
    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CMarryCtrl.CheckLocalTexture(self, pbdata)
    if pbdata.wedding_time == 0 then
        local iPid = g_AttrCtrl.pid
        local iPid1 = pbdata.player1.pid
        local iPid2 = pbdata.player2.pid
        if iPid1 == iPid or iPid2 == iPid then
            local sKey = self:GetWeddingPicKey(iPid1, iPid2)
            local sPath = self:GetWeddingTexturePath(sKey)
            if IOTools.IsExist(sPath) then
                self:PushWeddingTexture(sKey)
                return true
            end
        end
    end
    return false
end

-------------------- proto --------------------------
function CMarryCtrl.GS2CMarryPayUI(self, pbdata)
    local iSec = pbdata.seconds
    local iMyPay = pbdata.status
    CMarryComfirmView:ShowView(function(oView)
        oView:RefreshInfo(iSec, iMyPay)
    end)
end

function CMarryCtrl.GS2CMarryConfirmUI(self, pbdata)
    local iSec = pbdata.seconds
    local iStatus = pbdata.status
    CMarryAcceptView:ShowView(function(oView)
        oView:RefreshInfo(iSec, iStatus)
    end)
end

function CMarryCtrl.GS2CMarryCancel(self)
    self:OnEvent(define.Engage.Event.CancelMarry)
end

function CMarryCtrl.GS2CSuccessDivorce(self, pbdata)
    local sText = "#D"..self:GetMarryText(2063)
    local windowConfirmInfo = {
        title = "离婚成功",
        msg = sText,
        thirdStr = "确定",
        style = CWindowComfirmView.Style.Single,
        color = Color.white,
        thirdCallback = function()
        end
    }
    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CMarryCtrl.GS2CPickItemXT(self, pbdata)
    
end

function CMarryCtrl.GS2CMarryWedding(self, pbdata)
    if self.m_WeddingTime == 0 and g_MarryPlotCtrl:IsPlayingWeddingPlot() then
        if pbdata.wedding_time ~= 0 then
            self.m_CacheWedding = pbdata
        end
        return
    end
    if self:CheckLocalTexture(pbdata) then
        return
    end
    local dGroom = pbdata.player1
    local dBride = pbdata.player2
    local weddingTime = pbdata.wedding_time
    local iMarryType = pbdata.marry_type
    if dGroom.sex == 2 then
        local tmp = dGroom
        dGroom = dBride
        dBride = tmp
    end
    self.m_Groom = dGroom
    self.m_Bride = dBride
    self.m_MarryNo = pbdata.marry_no
    self.m_MarryType = iMarryType
    self.m_WeddingTime = weddingTime
    self.m_IsInMyWedding = dGroom.pid == g_AttrCtrl.pid or dBride.pid == g_AttrCtrl.pid
    printc("is in my wedding ------- ", self.m_IsInMyWedding)
    local elapsedTime
    if self.m_WeddingTime ~= 0 then
        elapsedTime = math.max(g_TimeCtrl:GetTimeS() - weddingTime, 0)
    else
        elapsedTime = -1
    end
    local dConfig = DataTools.GetEngageData("TYPE", iMarryType)
    local iPlotId = dConfig.plot_id
    if iPlotId > 0 then
        g_MarryPlotCtrl:PlayWeddingPlot(iPlotId, elapsedTime)
    end
end

function CMarryCtrl.GS2CMarryWeddingEnd(self, pbdata)
    self:EndWedding()
end

function CMarryCtrl.GS2CTeamShowWedding(self)
    g_MarryPlotCtrl:TeamShowWedding()
end

return CMarryCtrl