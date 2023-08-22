local CWishBottleCtrl = class("CWishBottleCtrl", CCtrlBase)

function CWishBottleCtrl.ctor(self)
    CCtrlBase.ctor(self)
    self:Clear()
end

function CWishBottleCtrl.Clear(self)
    self.m_BottleId = nil
    self.m_BottleInfo = {}
    self.m_InputCache = nil
end

function CWishBottleCtrl.SendMsg(self, iBottleId, sMsg)
    if iBottleId ~= self.m_BottleId then
        return
    end
    nethuodong.C2GSBottleSend(self.m_BottleId, sMsg)
    self:UpdateBottleId(-1)
end

function CWishBottleCtrl.ShowBottleView(self)
    if not next(self.m_BottleInfo) then return end
    if not self.m_BottleId or self.m_BottleId <= 0 then
        printc("has sent bottle!!!")
        return
    end
    CWishBottleView:ShowView(function(oView)
        oView:InitInfo(self.m_BottleInfo)
    end)
end

function CWishBottleCtrl.GetBottle(self)
    return self.m_BottleId or 0
end

function CWishBottleCtrl.SetInputCache(self, sContent)
    self.m_InputCache = sContent
end

function CWishBottleCtrl.GetInputCache(self)
    return self.m_InputCache
end

function CWishBottleCtrl.AskForBottleInfo(self)
    nethuodong.C2GSBottleDetail(self.m_BottleId)
end

function CWishBottleCtrl.UpdateBottleId(self, iBottleId)
    self.m_BottleId = iBottleId
    if iBottleId > 0 and self.m_InputCache then
        self.m_InputCache = nil
    end
    if self.m_BottleId and self.m_BottleId > 0 then
        self:AskForBottleInfo()
    else
        self.m_BottleInfo = {}
        self:OnEvent(define.WishBottle.Event.ReceiveBottle)
    end
end

function CWishBottleCtrl.GS2CBottleDetail(self, dInfo)
    self.m_BottleId = dInfo.bottle
    self.m_BottleInfo = dInfo
    local dbottleConfig = data.huodongdata.bottle[1]
    if dbottleConfig then
        local iTimeOut = dInfo.send_time + dbottleConfig.bottle_time
        self:OnEvent(define.WishBottle.Event.UpdateBottleTime, iTimeOut)
    end
end

return CWishBottleCtrl