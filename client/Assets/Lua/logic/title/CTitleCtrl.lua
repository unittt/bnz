local CTitleCtrl = class("CTitleCtrl", CCtrlBase)

CTitleCtrl.TYPE_NORMAL  = 0
CTitleCtrl.TYPE_SPECIAL = 1
CTitleCtrl.NOT_WEARING_TITLE = 0
CTitleCtrl.HIDE_TITLE = 0
CTitleCtrl.WEAR_TITLE = 1

function CTitleCtrl.ctor(self)
    CCtrlBase.ctor(self)
    self:ClearAll()
end

function CTitleCtrl.ClearAll(self)
    self.m_TitleList   = {}   -- 同时包含普通称谓和特殊称谓
    self.m_NormalList  = {}   -- 仅包含普通称谓
    self.m_SpecialList = {}   -- 仅包含特殊称谓
    self.m_WearingTitleId = self.NOT_WEARING_TITLE
end

-- 更新两个称谓列表，并刷新界面
function CTitleCtrl.UpdateTwoLists(self, tlist)
    -- 服务端数据 key 自然数，客户端改为 titleid，方便取
    self.m_TitleList = {}
    for _, title in pairs(tlist) do
        self.m_TitleList[title.tid] = title
    end
    self:SplitTwoLists()
    self:OnEvent(define.Title.Event.UpdateTwoLists)

    local hero = g_MapCtrl:GetHero()
    if hero then
        hero:SetWearingTitle()
    end
end

function CTitleCtrl.SplitTwoLists(self)
    self.m_NormalList = {}
    self.m_SpecialList = {}
    for _, title in pairs(self.m_TitleList) do
        if self:GetTitleType(title.tid) == self.TYPE_NORMAL then
            self.m_NormalList[title.tid] = title
        elseif self:GetTitleType(title.tid) == self.TYPE_SPECIAL then
            self.m_SpecialList[title.tid] = title
        end
    end
end

function CTitleCtrl.GetTitleType(self, tid)
    local titleInfo = data.titledata.INFO[tid]
    if titleInfo then
        return titleInfo.type
    end
end

function CTitleCtrl.HasTitle(self)
    local num = self:GetTitleNum()
    return num > 0
end

function CTitleCtrl.GetTitle(self, tid)
    if self.m_TitleList then
        return self.m_TitleList[tid]
    end
end

function CTitleCtrl.GetTitleNum(self)
    local num = 0
    for _, v in pairs(self.m_TitleList) do
        num = num + 1
    end
    return num
end

function CTitleCtrl.GetNormalTitleNum(self)
    local num = 0
    for _, v in pairs(self.m_NormalList) do
        num = num + 1
    end
    return num
end

function CTitleCtrl.GetSpecialTitleNum(self)
    local num = 0
    for _, v in pairs(self.m_SpecialList) do
        num = num + 1
    end
    return num
end

-- 更新当前佩戴的称谓
-- 0: 没有佩戴任何称谓; ~0: 佩戴称谓 tid
function CTitleCtrl.UpdateWearingTitle(self, tid)
    self.m_WearingTitleId = tid
    self:OnEvent(define.Title.Event.UpdateWearingTitle, tid)
end

-- 判断是否佩戴了某称谓
function CTitleCtrl.IsWearingATitle(self)
    return self.m_WearingTitleId ~= nil and self.m_WearingTitleId ~= self.NOT_WEARING_TITLE
end

-- 判断 tid 是否佩戴中
function CTitleCtrl.IsWearing(self, tid)
    return self:IsWearingATitle() and self.m_WearingTitleId == tid
end

function CTitleCtrl.GetWearingTitle(self)
    return self.m_TitleList[self.m_WearingTitleId]
end

function CTitleCtrl.AddTitles(self, addList)
    for _, addTitle in pairs(addList) do
        self.m_TitleList[addTitle.tid] = addTitle   -- 添加到 m_TitleList
        if self:GetTitleType(addTitle.tid) == self.TYPE_NORMAL then      -- 如果是普通称谓，添加到 m_NormalList
            self.m_NormalList[addTitle.tid] = addTitle
        elseif self:GetTitleType(addTitle.tid) == self.TYPE_SPECIAL then -- 如果是特殊称谓，添加到 m_SpecialList
            self.m_SpecialList[addTitle.tid] = addTitle
        end
    end
    self:OnEvent(define.Title.Event.AddTitles)
end

function CTitleCtrl.DelTitles(self, delIdList)
    for _, delid in pairs(delIdList) do
        self.m_TitleList[delid] = nil
        self.m_NormalList[delid] = nil
        self.m_SpecialList[delid] = nil
    end
    self:OnEvent(define.Title.Event.DelTitles)
end

function CTitleCtrl.UpdateTitleInfo(self, title)
    self.m_TitleList[title.tid] = title
    local type = self:GetTitleType(title.tid)
    if type == self.TYPE_NORMAL then
        self.m_NormalList[title.tid] = title
    elseif type == self.TYPE_SPECIAL then
        self.m_SpecialList[title.tid] = title
    end
    self:OnEvent(define.Title.Event.UpdateTitleInfo)
    local oHero = g_MapCtrl:GetHero()
    if oHero then oHero:SetWearingTitle() end
end
-- 提供一个供外部更改当前称谓的接口           -- 称谓信息 -- 是否改变当前称谓
function CTitleCtrl.ExternalUpdateTitle(self, tidinfo, updatetitle)
    -- body
    -- if not tidinfo then return end

    self.m_TitleList[tidinfo.tid] = tidinfo

    if updatetitle then
        if not self:IsWearing(tidinfo.tid) then -- 没有佩戴该称谓时，改变这个佩戴
            self:UpdateWearingTitle(tidinfo.tid)
        end
    end
end

return CTitleCtrl