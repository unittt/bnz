local CSysUIEffectCtrl = class("CSysUIEffectCtrl", CCtrlBase)

function CSysUIEffectCtrl.ctor(self)
    CCtrlBase.ctor(self)
    self:SetLinkSys()
    self:Reset()
end

function CSysUIEffectCtrl.Reset(self)
    self.m_WidgetDict={}
    self.m_SysEffInfo = nil
    self:InitSysEffInfo()
end

function CSysUIEffectCtrl.SetLinkSys(self)
    self.m_LinkSysDict = {
        PARTNER_SYS = {"PARTNER_BZ"},
    }
end

function CSysUIEffectCtrl.Register(self, sys, oWidget, effIdx, idx)
    if not oWidget or Utils.IsNil(oWidget) then return end
    self:CheckEmptyInfo(sys)
    local widgets = self.m_WidgetDict[sys]
    if not widgets then
        widgets = {}
        self.m_WidgetDict[sys] = widgets
    end
    effIdx = effIdx or 1
    idx = idx or 1
    local dWidget = setmetatable({obj=oWidget,effIdx=effIdx,idx=idx}, {__mode="v"})
    table.insert(widgets, dWidget)
    self:RefreshWidgetEff(sys, oWidget, effIdx, idx)
end

function CSysUIEffectCtrl.UnRegister(self, sys, oWidget)
    local widgets = self.m_WidgetDict[sys]
    if not widgets or not next(widgets) then return end
    for i, d in ipairs(widgets) do
        local o = d.obj
        if o and not Utils.IsNil(o) and oWidget == o then
            table.remove(widgets, i)
            break
        end
    end
end

function CSysUIEffectCtrl.CheckEmptyInfo(self, sys)
    local widgets = self.m_WidgetDict[sys]
    if not widgets then
        return
    end
    local len = #widgets
    for i = len, 1, -1 do
        local dW = widgets[i]
        if not dW.obj or Utils.IsNil(dW.obj) then
            table.remove(widgets, i)
        end
    end
end

function CSysUIEffectCtrl.CheckAllEmpty(self)
    for k in pairs(self.m_WidgetDict) do
        self:CheckEmptyInfo(k)
    end
end

-------------------外部调用，去除特效记录-------------------
function CSysUIEffectCtrl.DelSysEff(self, sys, idx)
    if not self.m_SysEffInfo[sys] then return end
    local dConfig = self:GetSysEffConfig(sys)
    local bRefresh = false
    local bTmp = false
    if dConfig.main then
        bTmp = self:DelSysEffInfo(dConfig.main)
        bRefresh = bRefresh or bTmp
    end
    if dConfig.sub then
        for i, s in ipairs(dConfig.sub) do
            bTmp = self:DelSysEffInfo(s)
            bRefresh = bRefresh or bTmp
        end
    end
    bTmp = self:DelSysEffInfo(sys, idx)
    bRefresh = bRefresh or bTmp
    if bRefresh then
        self:SaveSysEffInfo()
    end
end

---------------------- 系统开启调用 --------------------
function CSysUIEffectCtrl.OpenSys(self, sys, bSave)
    local dConfig = self:GetSysEffConfig(sys)
    if not dConfig then return end
    self:AddSysEffInfo(sys)
    if dConfig.main then
        self:AddSysEffInfo(dConfig.main)
    end
    if bSave then
        self:SaveSysEffInfo()
    end
end

function CSysUIEffectCtrl.OpenSystems(self, sysList)
    for i, v in ipairs(sysList) do
        if self.m_LinkSysDict[v] then
            for _, l in ipairs(self.m_LinkSysDict[v]) do
                self:OpenSys(l)
            end
        end
        self:OpenSys(v)
    end
    self:SaveSysEffInfo()
end

--------------------------控件特效相关-------------------
function CSysUIEffectCtrl.RefreshWidgetEff(self, sys, oWidget, effIdx, idx, bOnlyAdd)
    idx = idx or 1
    local record = self:GetSysEffInfo(sys)
    local idxRecord = record and record[idx]
    local bShow = idxRecord and idxRecord > 0
    if bOnlyAdd and not bShow then return end
    local dConfig = self:GetSysEffConfig(sys)
    if not dConfig then return end
    local dEff = dConfig.eff_config
    if not dEff then
        if dConfig.main then
            dEff = {{eff_type="RedDot"}}
        else
            dEff = {{eff_type="Circu"}}
        end
    end
    local dArgs = dEff[effIdx or 1]
    if oWidget and not Utils.IsNil(oWidget) then
        if bShow then
            local bMain = not dConfig.main
            self:AddWidgetEff(oWidget, dArgs, bMain)
        else
            self:DelWidgetEff(sys, oWidget, dArgs.eff_type)
        end
    end
end

function CSysUIEffectCtrl.TryAddEff(self, sys, oWidget, effIdx, idx)
    self:RefreshWidgetEff(sys, oWidget, effIdx, idx, true)
end

function CSysUIEffectCtrl.RefreshSysEffs(self, sys, idx)
    local dConfig = self:GetSysEffConfig(sys)
    local widgets = self.m_WidgetDict[sys]
    if not widgets or not next(widgets) or not dConfig then
        return
    end
    idx = idx or 1
    for i, d in ipairs(widgets) do
        if d.idx == idx and not dConfig.main then --子系统不刷新
            self:RefreshWidgetEff(sys, d.obj, d.effIdx, d.idx)
        end
    end
end

function CSysUIEffectCtrl.DelWidgetEff(self, sys, oWidget, sEff)
    if self:IsCanDelEff(sys) then
        oWidget:DelEffect(sEff)
    end
end

-- bMain是否是主系统，用于默认的设置
function CSysUIEffectCtrl.AddWidgetEff(self, oWidget, args, bMain)
    local sType = args.eff_type
    if sType == "Circu" or sType == "Rect" then
        self:AddRectEff(oWidget, args)
    elseif sType == "RedDot" then
        self:AddRedDotEff(oWidget, args, bMain)
    end
end

function CSysUIEffectCtrl.AddRectEff(self, oWidget, args)
    local sType = args.eff_type
    local vPos = nil
    local pos = args.pos
    if pos then
        vPos = Vector2(pos[1],pos[2])
    end
    oWidget:AddEffect(sType, vPos, args.order)
end

function CSysUIEffectCtrl.AddRedDotEff(self, oWidget, args, bMain)
    local sType = args.eff_type
    local pos = args.pos or (bMain and {-27,-26} or {-13,-17})
    local vPos = Vector2(pos[1],pos[2])
    local size = args.size or (bMain and 22 or 20)
    oWidget:AddEffect(sType, size, vPos)
end

-------------------------数据-----------------------------
function CSysUIEffectCtrl.InitSysEffInfo(self)
    local path = IOTools.GetRoleFilePath("/SysUIEff")
    local dEffInfo = IOTools.LoadJsonFile(path)
    self.m_SysEffInfo = dEffInfo or {}
end

function CSysUIEffectCtrl.GetSysEffInfo(self, sys)
    return self.m_SysEffInfo and self.m_SysEffInfo[sys]
end

function CSysUIEffectCtrl.GetSysEffConfig(self, sys)
    return datauser.uisystemeffectdata.System[sys]
end

function CSysUIEffectCtrl.SaveSysEffInfo(self)
    local path = IOTools.GetRoleFilePath("/SysUIEff")
    IOTools.SaveJsonFile(path, self.m_SysEffInfo)
end

function CSysUIEffectCtrl.AddSysEffInfo(self, sys)
    local dConfig = self:GetSysEffConfig(sys)
    if dConfig then
        local iCnt = dConfig.record_cnt or 1
        local list = {}
        self.m_SysEffInfo[sys] = list
        for i=1, iCnt do
            table.insert(list, 1)
            self:RefreshSysEffs(sys, i)
        end
    end
end

function CSysUIEffectCtrl.DelSysEffInfo(self, sys, idx)
    idx = idx or 1
    local effInfo = self.m_SysEffInfo[sys]
    local idxRecord = effInfo and effInfo[idx]
    local bRefresh = idxRecord and idxRecord > 0
    if effInfo then
        effInfo[idx] = 0
        local bEmpty = true
        for i, s in ipairs(effInfo) do
            if s and s > 0 then
                bEmpty = false
                break
            end
        end
        if bEmpty then
            self.m_SysEffInfo[sys] = nil
        end
    end
    self:RefreshSysEffs(sys, idx)
    return bRefresh
end

function CSysUIEffectCtrl.IsExistRecord(self, sys, idx)
    local record = self:GetSysEffInfo(sys)
    idx = idx or 1
    local idxRecord = record and record[idx]
    return idxRecord and true or false
end

--------------检测是否还有其他条件不能删除特效--------------
function CSysUIEffectCtrl.IsCanDelEff(self, sys, s)
    local name = string.format("Check%s%s", sys, s)
    local func = self[name]
    if func then
        return func()
    end
    return true
end

return CSysUIEffectCtrl