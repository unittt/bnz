local CTitleView = class("CTitleView", CViewBase)

CTitleView.NORMAL_LIST = 0
CTitleView.SPECIAL_LIST = 1

function CTitleView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Title/TitleMainView.prefab", cb)
    self.m_DepthType = "Dialog"
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"
end

function CTitleView.OnCreateView(self)
    self.m_CloseBtn         = self:NewUI(1, CButton)
    self.m_NormalGrid       = self:NewUI(2, CGrid)
    self.m_SpecialGrid      = self:NewUI(3, CGrid)
    self.m_NormalItemClone  = self:NewUI(4, CNormalTitleItem)
    self.m_SpecialItemClone = self:NewUI(5, CSpecialTitleItem)
    self.m_NormalScrolView  = self:NewUI(6, CScrollView)
    self.m_SpecialScrolView = self:NewUI(7, CScrollView)
    self.m_DescTable        = self:NewUI(8, CTable)
    self.m_DescItem         = self:NewUI(9, CTitleDescItem)
    self.m_NormalBtn        = self:NewUI(10, CButton)
    self.m_SpecialBtn       = self:NewUI(11, CButton)
    self.m_DescContainer    = self:NewUI(12, CWidget)
    self.m_WearBtn          = self:NewUI(13, CButton)
    self.m_HideBtn          = self:NewUI(14, CButton)
    self.m_NoTitleLabel     = self:NewUI(15, CLabel)
    self.m_NoTitleTexture   = self:NewUI(16, CTexture)
    self.m_CurClickedNormalTitleId = nil
    self.m_CurClickedSpecialTitleId = nil
    self.m_CurShownTitle = {}
    self:InitContent()
end

function CTitleView.InitContent(self)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "CloseView"))
    --self.m_NormalBtn:AddUIEvent("click", callback(self, "OnClickNormalBtn"))
    --self.m_SpecialBtn:AddUIEvent("click", callback(self, "OnClickSpecialBtn"))
    self.m_WearBtn:AddUIEvent("click", callback(self, "OnWearBtn"))
    self.m_HideBtn:AddUIEvent("click", callback(self, "OnHideBtn"))
    g_TitleCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTitleEvent"))
    self:RebuildTwoLists()
    self:DefaultSelection()
end

function CTitleView.OnWearBtn(self)
    if self.m_CurShownTitle == nil then 
        g_NotifyCtrl:FloatMsg("请选择一个称谓！")
        return
    end 
    if self.m_CurShownTitle.tid then
        nettitle.C2GSUseTitle(self.m_CurShownTitle.tid, g_TitleCtrl.WEAR_TITLE)
    end
end

function CTitleView.OnHideBtn(self)
    if self.m_CurShownTitle == nil then 
        g_NotifyCtrl:FloatMsg("请选择一个称谓！")
        return
    end 
    if self.m_CurShownTitle.tid then
        nettitle.C2GSUseTitle(self.m_CurShownTitle.tid, g_TitleCtrl.HIDE_TITLE)
    end
end

function CTitleView.OnTitleEvent(self, callbackBase)
    local eventID = callbackBase.m_EventID
    if eventID == define.Title.Event.UpdateTwoLists then
        self:RebuildTwoLists()
    elseif eventID == define.Title.Event.UpdateWearingTitle then
        self:UpdateWearingTitle()
    elseif eventID == define.Title.Event.AddTitles then
        self:UpdateTitleLists()
    elseif eventID == define.Title.Event.DelTitles then
        self:UpdateTitleLists()
    elseif eventID == define.Title.Event.UpdateTitleInfo then
        self:UpdateTitleLists()
    end
end

function CTitleView.UpdateTitleLists(self)
    self:RebuildTwoLists()
    self:ItemCallBack(self.m_CurShownTitle)
end

function CTitleView.RebuildTwoLists(self)
    self:ShowNoTitleUI()
    --self:ResbuildList(g_TitleCtrl.m_NormalList,  self.m_NormalGrid,  self.m_NormalItemClone)
    --self:ResbuildList(g_TitleCtrl.m_SpecialList, self.m_SpecialGrid, self.m_SpecialItemClone)
    self:ResbuildAllList()
end

function CTitleView.ShowNoTitleUI(self)
    -- 如果当前显示普通称谓 list，且没有 item
    if self.m_NormalBtn:GetSelected() and g_TitleCtrl:GetNormalTitleNum() == 0 then
        self.m_NoTitleLabel:SetActive(true)
        self.m_NoTitleTexture:SetActive(true)
        self.m_CurShownTitle = nil
        self:RefreshWearBtn()
        return
    end

    -- 如果当前显示特殊称谓 list，且没有 item
    if self.m_SpecialBtn:GetSelected() and g_TitleCtrl:GetSpecialTitleNum() == 0 then
        self.m_NoTitleLabel:SetActive(true)
        self.m_NoTitleTexture:SetActive(true)
        self.m_CurShownTitle = nil
        self:RefreshWearBtn()
        return
    end
    -- 有称谓
    self.m_NoTitleLabel:SetActive(false)
    self.m_NoTitleTexture:SetActive(false)
    if self.m_CurShownTitle then 
        self:RefreshWearBtn(self.m_CurShownTitle.tid)
    end
end

function CTitleView.SortFunc(titleA, titleB)
    if titleA.use_time == titleB.use_time then
        return titleA.achieve_time > titleB.achieve_time
    end
    return titleA.use_time > titleB.use_time
end


function CTitleView.ResbuildAllList(self)
    local titlelist = {}
    for _, v in pairs(g_TitleCtrl.m_NormalList) do
        table.insert(titlelist, v)
    end
    for _, v in pairs(g_TitleCtrl.m_SpecialList) do
        table.insert(titlelist, v)
    end
    table.sort(titlelist, self.SortFunc)
    for k, title in pairs(titlelist) do
        local oItem = self.m_NormalGrid:GetChild(k)
        if oItem then
            oItem:SetActive(true) 
            oItem:SetBoxInfo(title, function()
                self:ItemCallBack(title)
            end)
        else
            oItem = self:AddSingleTitleItem(self.m_NormalGrid, title, self.m_NormalItemClone)
        end 
        oItem:UpdateWearingSprite()
    end
    for i = #titlelist + 1 , self.m_NormalGrid:GetCount() do
        self.m_NormalGrid:GetChild(i):SetActive(false)
    end        
end

function CTitleView.ResbuildList(self, tlist, grid, itemClone)
    local templist = {}
    for _, v in pairs(tlist) do
        table.insert(templist, v)
    end
    table.sort(templist, self.SortFunc)
    for k, title in pairs(templist) do
        local oItem = grid:GetChild(k)
        if oItem then
            oItem:SetActive(true) 
            oItem:SetBoxInfo(title, function()
                self:ItemCallBack(title)
            end)
        else
            oItem = self:AddSingleTitleItem(grid, title, itemClone)
        end 
        oItem:UpdateWearingSprite()
    end
    for i = #templist +1 , grid:GetCount() do
        grid:GetChild(i):SetActive(false)
    end
end

function CTitleView.AddSingleTitleItem(self, grid, title, itemClone)
    local oItem = itemClone:Clone(
        function()
            self:ResetAllNormalTitlesLabelColor()
        end
    )
    oItem:SetActive(true)
    oItem:SetBoxInfo(title, function()
            self:ItemCallBack(title)
        end)
    grid:AddChild(oItem)
    oItem:SetGroup(grid:GetInstanceID())
    return oItem
end

function CTitleView.ResbuildDescList(self, tid)
    self.m_DescTable:Clear()
    for i = 1, #data.titledata.DESC_FIELD do
        local field = data.titledata.DESC_FIELD[i]
        self:AddSingleFieldDescItem(tid, field)
    end
    Utils.AddTimer(function ()   --如果不延迟调用不能适应锚点对齐
         self.m_DescTable:RepositionLater()
         return false
     end, 0, 0.1)
end

function CTitleView.AddSingleFieldDescItem(self, tid, field)
    local oDescItem = self.m_DescItem:Clone()
    oDescItem:SetActive(true)
    oDescItem:SetBoxInfo(tid, field)
    self.m_DescTable:AddChild(oDescItem)
    oDescItem:SetGroup(self.m_DescTable:GetInstanceID())
end

function CTitleView.ItemCallBack(self, title)
    -- title 有可能 == nil 或 == {}
    if title == nil or title.tid == nil then
        self.m_DescContainer:SetActive(false)
        self:RefreshWearBtn()  -- 不传参，如果没有/没有佩戴称谓，按钮重置
        printc("没有佩戴")
        return
    end
    self.m_CurShownTitle = title 
    --if g_TitleCtrl:GetTitleType(title.tid) == g_TitleCtrl.TYPE_NORMAL then
    self.m_CurClickedNormalTitleId = title.tid
    -- elseif g_TitleCtrl:GetTitleType(title.tid) == g_TitleCtrl.TYPE_SPECIAL then
    --     self.m_CurClickedSpecialTitleId = title.tid
    -- end
    self.m_DescContainer:SetActive(true)
    --printc("佩戴了"..title.tid)
    self:ResbuildDescList(title.tid)
    self:RefreshWearBtn(title.tid)
end

function CTitleView.RefreshWearBtn(self, tid)
    -- 没有佩戴任何称谓
    if tid == nil or not g_TitleCtrl:IsWearingATitle() then
        self.m_WearBtn:SetActive(true)
        self.m_HideBtn:SetActive(false)      
        return
    end

    -- 佩戴了某个称谓，是否跟当前显示的称谓一样，一样才刷新按钮
    if tid ~= self.m_CurShownTitle.tid then
        return
    end

    if g_TitleCtrl:IsWearing(tid) then
        self.m_WearBtn:SetActive(false)
        self.m_HideBtn:SetActive(true)
    else
        self.m_WearBtn:SetActive(true)
        self.m_HideBtn:SetActive(false)
    end
end

function CTitleView.GetNormalItem(self, tid)
    return self:GetItem(tid, self.m_NormalGrid)
end

function CTitleView.GetSpecialItem(self, tid)
    return self:GetItem(tid, self.m_SpecialGrid)
end

function CTitleView.GetItem(self, tid, grid)
    for _, oItem in pairs(grid:GetChildList()) do
        if oItem.m_Id == tid then
            return oItem
        end
    end
end

-- 有佩戴的默认选中佩戴，没有则选中普通称谓第一个，再没有就不显示
function CTitleView.DefaultSelection(self)
    if g_TitleCtrl:IsWearingATitle() then
        local type = g_TitleCtrl:GetTitleType(g_TitleCtrl.m_WearingTitleId)
        if type == g_TitleCtrl.TYPE_NORMAL then
            self:OnClickNormalBtn()
        elseif type == g_TitleCtrl.TYPE_SPECIAL then
            self:OnClickSpecialBtn()
        end
        --self:ItemCallBack(g_TitleCtrl:GetWearingTitle())
    else
        self:OnClickNormalBtn()
    end
end

function CTitleView.OnClickNormalBtn(self)
    -- 选中普通 btn
    self.m_NormalBtn:SetSelected(true)
    self.m_SpecialBtn:SetSelected(false)

    -- 显示普通 scrollview
    self.m_NormalScrolView:SetActive(true)
    self.m_SpecialScrolView:SetActive(false)

    -- 特殊 scrollview 所有 item 取消选中
    self:CancelSelectAllSpecialItems()

    -- 选中普通 scrollview 上次那项，没有就显示第一项，再没有就不显示
    if self.m_CurClickedNormalTitleId then
        self:ItemCallBack(g_TitleCtrl.m_TitleList[self.m_CurClickedNormalTitleId])
    else
        self:ShowListFirstItemOrBlank(self.NORMAL_LIST)
    end

    -- 显示没有称谓的 UI
    self:ShowNoTitleUI()
end

function CTitleView.OnClickSpecialBtn(self)
    -- 选中特殊 btn
    self.m_NormalBtn:SetSelected(false)
    self.m_SpecialBtn:SetSelected(true)

    -- 显示特殊 scrollview
    --self.m_NormalScrolView:SetActive(false)
    --self.m_SpecialScrolView:SetActive(true)

    -- 普通 scrollview 所有 item 取消选中
    self:CancelSelectAllNormalItems()

    -- 选中特殊 scrollview 上次那项，没有就显示第一项，再没有就不显示
    if self.m_CurClickedSpecialTitleId then
        self:ItemCallBack(g_TitleCtrl.m_TitleList[self.m_CurClickedSpecialTitleId])
    else
        self:ShowListFirstItemOrBlank(self.SPECIAL_LIST)
    end
    -- 显示没有称谓的 UI
    self:ShowNoTitleUI()
end

function CTitleView.CancelSelectAllNormalItems(self)
    for _, normalItems in pairs(self.m_NormalGrid:GetChildList()) do
        normalItems:SetSelected(false)
    end
end

function CTitleView.CancelSelectAllSpecialItems(self)
    for _, specialItems in pairs(self.m_SpecialGrid:GetChildList()) do
        specialItems:SetSelected(false)
    end
end

-- 显示列表第一项，没有不显示
function CTitleView.ShowListFirstItemOrBlank(self, type)
    local grid = nil
    local tlist = nil
    if type == self.NORMAL_LIST then
        grid = self.m_NormalGrid
        tlist = g_TitleCtrl.m_NormalList
    elseif type == self.SPECIAL_LIST then
        grid = self.m_SpecialGrid
        tlist = g_TitleCtrl.m_SpecialList
    end
    local firstItem = grid:GetChild(1)
    if firstItem then
        firstItem:SetSelected(true)
        self:ItemCallBack(tlist[firstItem.m_Id])
    else
        self:ItemCallBack()
    end
end

function CTitleView.UpdateWearingTitle(self)
    self:RefreshWearBtn(g_TitleCtrl.m_WearingTitleId)
    if g_TitleCtrl.m_WearingTitleId == 0 then 
        self:UpdateTwoListsWearingSprite()
    end 
    if g_TitleCtrl:IsWearingATitle() then
        g_NotifyCtrl:FloatMsg(string.gsub(data.titledata.TEXT[1003].content, "#title", g_TitleCtrl:GetWearingTitle().name))
    else
        g_NotifyCtrl:FloatMsg(data.titledata.TEXT[1002].content)
    end
end

function CTitleView.UpdateTwoListsWearingSprite(self)
    if self.m_NormalBtn:GetSelected() then 
        for _, normalItem in pairs(self.m_NormalGrid:GetChildList()) do
            normalItem:SetNoWearSprite()
        end
        return
    end
    if self.m_SpecialBtn:GetSelected() then 
        for _, specialItem in pairs(self.m_SpecialGrid:GetChildList()) do
            specialItem:SetNoWearSprite()
        end
    end
end

function CTitleView.ResetAllNormalTitlesLabelColor(self)
    for _, normalItems in pairs(self.m_NormalGrid:GetChildList()) do
        normalItems:ResetLabelColor()
    end
end

return CTitleView