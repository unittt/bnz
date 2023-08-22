local CWingAspectPageBox = class("CWingAspectPageBox", CBox)

function CWingAspectPageBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_BoxGrid = self:NewUI(1, CGrid)
    self.m_PageTipGrid = self:NewUI(2, CGrid)
    self.m_PageTip = self:NewUI(3, CBox)
    self.m_LeftBtn = self:NewUI(4, CSprite)
    self.m_RightBtn = self:NewUI(5, CSprite)
    self.m_ScrollView = self:NewUI(6, CScrollView)
    self.m_MoveWgt = self:NewUI(7, CWidget)
    self:InitContent()
end

function CWingAspectPageBox.InitContent(self)
    self.m_ItemBoxClone = nil
    self.m_PageCnt = 0
    self.m_CurPage = 1
    self.m_PerPageCnt = 3
    self.m_MoveX = 0
    self.m_WingInfoList = {}
    self.m_PageTip:SetActive(false)

    self.m_LeftBtn:AddUIEvent("click", callback(self, "OnClickLeft"))
    self.m_RightBtn:AddUIEvent("click", callback(self, "OnClickRight"))
    self.m_MoveWgt:SetActive(false)
    self.m_MoveWgt:AddUIEvent("dragstart", callback(self, "OnScrollPageStart"))
    self.m_MoveWgt:AddUIEvent("drag", callback(self, "OnScrollPage"))
    self.m_MoveWgt:AddUIEvent("dragend", callback(self, "OnScrollPageEnd"))
end

function CWingAspectPageBox.InitPageBox(self, oBox, iPerPageCnt)
    self.m_ItemBoxClone = oBox
    oBox:SetActive(false)
    self.m_PerPageCnt = iPerPageCnt or 3
end

function CWingAspectPageBox.RefreshAll(self, wingInfoList)
    if wingInfoList then
        self.m_WingInfoList = wingInfoList
        self.m_PageCnt = math.ceil(#wingInfoList/self.m_PerPageCnt)
        if self.m_CurPage > self.m_PageCnt then
            self.m_CurPage = 1
        end
    end
    self:RefreshPage()
    self:RefreshPageTips()
end

function CWingAspectPageBox.ChangePage(self, iChange)
    local iPage = self.m_CurPage + iChange
    if iPage > self.m_PageCnt then
        return
    elseif iPage <= 0 then
        return
    end
    self.m_CurPage = iPage
    self:RefreshPage()
    self:RefreshPageTips()
end

function CWingAspectPageBox.RefreshPage(self)
    self.m_BoxGrid:HideAllChilds()
    local iStart = (self.m_CurPage-1)*self.m_PerPageCnt + 1
    for i = iStart, iStart + self.m_PerPageCnt - 1 do
        local dInfo = self.m_WingInfoList[i]
        if not dInfo then
            break
        end
        local idx = i - iStart + 1
        local oBox = self.m_BoxGrid:GetChild(idx)
        if not oBox then
            oBox = self.m_ItemBoxClone:Clone()
            self.m_BoxGrid:AddChild(oBox)
        end
        oBox:SetActive(true)
        oBox:SetInfo(dInfo)
    end
    self.m_LeftBtn:SetActive(self.m_CurPage > 1)
    self.m_RightBtn:SetActive(self.m_CurPage < self.m_PageCnt)
    self.m_ScrollView:ResetPosition()
end

function CWingAspectPageBox.RefreshPageTips(self)
    self.m_PageTipGrid:HideAllChilds()
    for i = 1, self.m_PageCnt do
        local oPageTip = self.m_PageTipGrid:GetChild(i)
        if not oPageTip then
            oPageTip = self.m_PageTip:Clone()
            oPageTip.curSpr = oPageTip:NewUI(1, CSprite)
            self.m_PageTipGrid:AddChild(oPageTip)
        end
        oPageTip:SetActive(true)
        oPageTip.curSpr:SetActive(i == self.m_CurPage)
    end
end

function CWingAspectPageBox.OnClickLeft(self)
    self:ChangePage(-1)
end

function CWingAspectPageBox.OnClickRight(self)
    self:ChangePage(1)
end

function CWingAspectPageBox.OnScrollPageStart(self, obj)
    self.m_MoveX = 0
end

function CWingAspectPageBox.OnScrollPage(self, obj, moveDelta)
    local adjust = UITools.GetPixelSizeAdjustment()
    self.m_MoveX = self.m_MoveX + moveDelta.x*adjust
end

function CWingAspectPageBox.OnScrollPageEnd(self, obj)
    if self.m_MoveX > 50 then
        self:ChangePage(-1)
    elseif self.m_MoveX < -50 then
        self:ChangePage(1)
    end
end

return CWingAspectPageBox