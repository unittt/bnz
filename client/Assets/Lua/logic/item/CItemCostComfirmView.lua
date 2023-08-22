local CItemCostComfirmView = class("CItemCostComfirmView", CViewBase)

function CItemCostComfirmView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Item/ItemCostComfirmView.prefab", cb)
    -- self.m_ExtendClose = "Pierce"
    self.m_DepthType = "Dialog"
end

function CItemCostComfirmView.OnCreateView(self)
    -- body
    self.m_Grid     = self:NewUI(1, CGrid)
    self.m_Item     = self:NewUI(2, CBox)
    self.m_SureBtn  = self:NewUI(3, CButton)
    self.m_CloseBtn = self:NewUI(4, CButton)
    self.m_BgSpr    = self:NewUI(5, CSprite)
    self.m_CancelBtn = self:NewUI(6, CButton)
    self.m_ContentL = self:NewUI(7, CLabel)
    self.m_TitleL = self:NewUI(8, CLabel)
    self:InitContent()
end

function CItemCostComfirmView.InitContent(self)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_SureBtn:AddUIEvent("click", callback(self, "OnClickSure"))
    self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClickCancel"))
    self.m_Item:SetActive(false)
    g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
end

--[[
args:
    color
    title
    msg
    okCallback
    cancelCallback
    closeCallback
    pivot
    okStr
    cancelStr
    items: repeat {sid, count, amount}
]]
function CItemCostComfirmView.SetWindowConfirm(self, args)
    self.m_Args = args
    if args.color then
        self.m_ContentL:SetColor(args.color)
    end
    self.m_TitleL:SetText(args.title)
    self.m_ContentL:SetText(args.msg)
    self.m_CancelCb = args.cancelCallback
    self.m_SureCb = args.okCallback
    self.m_CloseCb = args.closeCallback
    self.m_ContentL:SetPivot(args.pivot)
    if args.okStr then
        self.m_SureBtn:SetText(args.okStr)
    end
    if args.cancelStr then
        self.m_CancelBtn:SetText(args.cancelStr)
    end
    if args.items then
        self:InitItemInfo(args.items)
    end
end

                                       --{sid = itemsid, count = 已有的， amount= --需要的 }
function CItemCostComfirmView.InitItemInfo(self, itemlist)
    local list = self.m_Grid:GetChildList()
    for i,v in ipairs(itemlist) do
        local cell = nil
        if i>#list then 
            cell = self.m_Item:Clone()
            self.m_Grid:AddChild(cell)
            cell:SetGroup(self.m_Grid:GetInstanceID())
            cell.icon = cell:NewUI(1, CSprite)
            cell.num  = cell:NewUI(2, CLabel)
            cell.name = cell:NewUI(3, CLabel)
            cell.quality = cell:NewUI(4, CSprite)
            local itemdata = DataTools.GetItemData(v.sid)
            cell.icon:SetSpriteName(itemdata.icon)
            cell.num:SetText(string.format("[c]%d[/c]/%d", v.count, v.amount))
            cell.name:SetText(itemdata.name)
            cell.quality:SetItemQuality(itemdata.quality)
            cell.icon:AddUIEvent("click", callback(self, "OpenTipView", v.sid))
            cell:SetActive(true)
        else
            cell = list[i]
        end
    end
end

function CItemCostComfirmView.OpenTipView(self, sid)
    -- local oView = CQuickGetTipView:ShowView(function (oView)
    --     oView:InitItemInfo(sid)
    -- end)
    --TODO:临时替换旧的跳转
    g_WindowTipCtrl:SetWindowGainItemTip(sid)
end

function CItemCostComfirmView.OnClickSure(self)
    if self.m_SureCb then
        self.m_SureCb()
    end
    self:CloseView()
end

function CItemCostComfirmView.OnClickCancel(self)
    if self.m_CancelCb then
        self.m_CancelCb()
    end
    self:CloseView()
end

function CItemCostComfirmView.OnClose(self)
    if self.m_CloseCb then
        self.m_CloseCb()
    end
    self:CloseView()
end

return CItemCostComfirmView