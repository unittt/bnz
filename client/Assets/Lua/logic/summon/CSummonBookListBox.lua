local CSummonBookListBox = class("CSummonBookListBox", CBox)

function CSummonBookListBox.ctor(self, obj)
    CBox.ctor(self, obj)

    self.m_NormalSummon = {}
    self.m_SpecialSummon = {}
    self.m_SummonBoxDict = {}
    self.m_CurSummonId = nil
    self.m_CurGrade = nil
    self:InitContent()
end

function CSummonBookListBox.InitContent(self)
    self.m_SummonGrid = self:NewUI(1, CGrid)
    self.m_SummonItemBox = self:NewUI(2, CSummonBookItemBox)
    self.m_ScrollView = self:NewUI(3, CScrollView)
    self.m_NormalBtn = self:NewUI(4, CButton)
    self.m_SpecialBtn = self:NewUI(5, CButton)

    self.m_SummonItemBox:SetActive(false)
    self:InitBtns()
end

function CSummonBookListBox.InitBtns(self)
    self.m_NormalBtn:SetGroup(self:GetInstanceID())
    self.m_SpecialBtn:SetGroup(self:GetInstanceID())
    self.m_NormalBtn:AddUIEvent("click", callback(self, "OnSelType", 1))
    self.m_SpecialBtn:AddUIEvent("click", callback(self, "OnSelType", 2))
end

function CSummonBookListBox.InitInfo(self)
    self:UnselectCurSummon()
    self:CalculateList()
    self:HandleDefaultSelSumm()
    self:InitSummonGrid(self.m_SelType)
    if self.m_SelType == 2 then
        self.m_SpecialBtn:SetSelected(true)
    else
        self.m_NormalBtn:SetSelected(true)
    end
    -- g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
end

function CSummonBookListBox.InitSummonGrid(self, iType)
    local summonListInfo
    if iType == 1 then
        summonListInfo = self.m_SummonNormalList
    elseif iType == 2 then
        summonListInfo = self.m_SummonSpecialList
    end
    self.m_SummonBoxDict = {}
    self.m_SummonGrid:HideAllChilds()
    local bSel = false
    for i, info in ipairs(summonListInfo) do
        local oItem = self.m_SummonGrid:GetChild(i)
        if not oItem then
            oItem = self:CreateSummonItem()
        end
        oItem:SetActive(true)
        oItem:SetInfo(info)
        oItem.idx = i
        self.m_SummonBoxDict[info.id] = oItem
        oItem:AddUIEvent("click", callback(self, "OnClickSummon", info))
        if not bSel then
            local iSel = self.selId
            if (iSel and iSel==info.id) or (not iSel and i == 1) then
                oItem.m_SelSpr:SetActive(true)
                self:OnClickSummon(info)
                bSel = true
                self.selId = nil
            end
        end
    end
    self.m_SummonGrid:Reposition()
    self.m_ScrollView:ResetPosition()
end

function CSummonBookListBox.HandleDefaultSelSumm(self)
    if self.selId then
        self.m_SelType = SummonDataTool.IsUnnormalSummon(dSumm.type) and 2 or 1
    else
        local dSumm = g_SummonCtrl:GetCurSummonInfo()
        if dSumm then
            self.selId = dSumm.typeid
            self.m_SelType = SummonDataTool.IsUnnormalSummon(dSumm.type) and 2 or 1
        else --没宠物默认选中特殊第一个
            self.selId = nil
            self.m_SelType = 2
        end
    end
end

function CSummonBookListBox.SetSelBtn(self, iType)
    local oBtn = iType == 1 and self.m_NormalBtn or self.m_SpecialBtn
    oBtn:SetSelected(true)
end

function CSummonBookListBox.CreateSummonItem(self)
    local oBox = self.m_SummonItemBox:Clone()
    self.m_SummonGrid:AddChild(oBox)
    oBox:SetGroup(self.m_SummonGrid:GetInstanceID())
    return oBox
end

-------------------- data -----------------
function CSummonBookListBox.CalculateList(self)
    local dList = SummonDataTool.GetBookSummonList()
    self.m_SummonNormalList = dList.nor
    self.m_SummonSpecialList = dList.spc
    self.m_CurGrade = g_AttrCtrl.grade
end

function CSummonBookListBox.GetSummonById(self, iSummon)
    return self.m_SummonBoxDict[iSummon]
end

function CSummonBookListBox.UnselectCurSummon(self)
    if self.m_CurSummonId then
        local oBox = self.m_SummonBoxDict[self.m_CurSummonId]
        if oBox then
            oBox.m_SelSpr:SetActive(false)
        end
    end
end

------------------- events ---------------------
function CSummonBookListBox.OnSelType(self, iType)
    if not self.selId and iType == self.m_SelType then
        return
    end
    self.m_SelType = iType
    self:UnselectCurSummon()
    self:InitSummonGrid(iType)
end

function CSummonBookListBox.OnClickSummon(self, info)
    if not info or info.id == self.m_CurSummonId then
        return
    end
    self:UnselectCurSummon()
    self.m_CurSummonId = info.id
    if self.m_ParentView then
        self.m_ParentView:OnSelSummon(info)
    end
    local oBox = self.m_SummonBoxDict[info.id]
    if oBox then
        oBox.m_SelSpr:SetActive(true)
    end
end

function CSummonBookListBox.OnAttrEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.Change then
        if oCtrl.m_EventData.dAttr and oCtrl.m_EventData.dAttr.grade then
            if not self.m_CurGrade or self.m_CurGrade < oCtrl.m_EventData.dAttr.grade then
                self:CalculateList()
                self:UnselectCurSummon()
                self:InitSummonGrid(self.m_SelType)
            end
        end
    end
end

return CSummonBookListBox