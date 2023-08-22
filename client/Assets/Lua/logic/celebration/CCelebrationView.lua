local CCelebrationView = class("CCelebrationView", CViewBase)

function CCelebrationView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Celebration/CelebrationView.prefab", cb)

	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"	

    self.m_PartDict = {}
    self.m_TabDict = {}
    self.m_RedPointInfo = nil
end

function CCelebrationView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_BtnGrid = self:NewUI(2, CGrid)
	self.m_BtnBox = self:NewUI(3, CBox)
    self.m_BtnBox:SetActive(false)

	self:InitContent()

    g_CelebrationCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnUpdateCelebrationEvent"))
	
end

function CCelebrationView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClickClose"))

    self.m_TabC = define.Celebration.Tab
	self:CreatePage()

	self:CreateBtnGrid()

    self:ShowChargeRedPoints()

    self:SelDefaultPage()
end

--创建page
function CCelebrationView.CreatePage(self)
	-- 顺序由define.Celebration.Tab控制
    
    self.m_GradeRankPart = self:NewPage(4, CCelebrationGradeRankPart)
    self.m_StrengthRankPart = self:NewPage(5, CCelebrationStrengthRankPart)
    self.m_TitleRankPart = self:NewPage(6, CCelebrationTitleRankPart)
    self.m_SummonRankPart = self:NewPage(7, CCelebrationSummonRankPart)
    self.m_OrgRankPart = self:NewPage(8, CCelebrationOrgRankPart)
    self.m_PayRewardPart = self:NewPage(9, CPayGetRewardPart)

    self.m_PartDict =
    {
        -- [self.m_TabC.CaiShen] = self.m_LotteryPart,
        [self.m_TabC.GradeRank] = self.m_GradeRankPart,
        [self.m_TabC.StrengthRank] = self.m_StrengthRankPart,
        [self.m_TabC.TitleRank] = self.m_TitleRankPart,
        [self.m_TabC.SummonRank] = self.m_SummonRankPart,
        [self.m_TabC.OrgRank] = self.m_OrgRankPart,
        [self.m_TabC.PayGetReward] = self.m_PayRewardPart,
    }
end

--创建btn列表 , 判断开启等级
function CCelebrationView.CreateBtnGrid(self, bNotSelectFirst)
    self.m_Index = 900000
    local huodongList = g_CelebrationCtrl:GetOpenHuodong()
	for i,v in ipairs(huodongList) do
        local box = self.m_TabDict[v.idx]
        if box == nil then
           box = self.m_BtnBox:Clone()
           box:SetActive(true)
           box.name = box:NewUI(1,CLabel)
           box.redPoint = box:NewUI(2,CSprite)
           box.colorName = box:NewUI(3, CLabel)
           box:SetGroup(self.m_BtnGrid:GetInstanceID())
           self.m_BtnGrid:AddChild(box)
           self.m_TabDict[v.idx] = box
        end
        self.m_BtnBox:SetActive(false)
        self.m_Index = self.m_Index + 1
        box:SetName(tostring(self.m_Index))
        
        local info = g_CelebrationCtrl:GetViewOpenData(v.key)
        if not info then
            info = g_CelebrationCtrl:GetUnLockViewData(v.key)
        end
        if info then
            box.name:SetText(info.name)
            box.colorName:SetText(info.name)
            box.key = v.idx
            box:AddUIEvent("click",callback(self,"OnClickBtn", v.idx))
        end
    end
    self.m_BtnGrid:Reposition()
end

function CCelebrationView.OnClickBtn(self, tabIndex)
    self.m_TabDict[tabIndex]:ForceSelected(true)
    if self.m_CurSelIdx then
        local oCurPage = self.m_PartDict[self.m_CurSelIdx]
        if oCurPage then
            oCurPage:HidePage()
        end
    end
    self.m_CurSelIdx = tabIndex
	-- CGameObjContainer.ShowSubPageByIndex(self, tabIndex)
    local oPage = self.m_PartDict[tabIndex]
    if oPage then
        oPage:ShowPage()
    end
    -- if self.m_TabC.CaiShen == tabIndex then
    --     if g_CelebrationCtrl:GetIsHasCaishenRedPoint() then
    --         g_CelebrationCtrl.m_HasClickCaishen = true
    --         self:ShowRedPoint(tabIndex, false)
    --         g_CelebrationCtrl:OnEvent(define.Celebration.Event.UpdateRankReward)
    --     end
    -- end
end

function CCelebrationView.ShowChargeRedPoints(self)
    self:ShowRedPoint(self.m_TabC.GradeRank, g_CelebrationCtrl:GetIsHasGradeRedPoint())
    self:ShowRedPoint(self.m_TabC.StrengthRank, g_CelebrationCtrl:GetIsHasScoreRedPoint())
    self:ShowRedPoint(self.m_TabC.OrgRank, g_CelebrationCtrl:GetIsHasOrgCntRedPoint() or g_CelebrationCtrl:GetIsHasOrgLevelRedPoint())
    -- self:ShowRedPoint(self.m_TabC.CaiShen, g_CelebrationCtrl:GetIsHasCaishenRedPoint())
end

function CCelebrationView.ShowRedPoint(self, tagIdx, bState)
    local tagBtn = self.m_TabDict[tagIdx]
    if tagBtn then
        tagBtn.redPoint:SetActive(bState)
    end
end

function CCelebrationView.SelDefaultPage(self)
    local btnList = self.m_BtnGrid:GetChildList()
    local oTopRed, oTop
    for i, oBtn in ipairs(btnList) do
        if not oTop then
            oTop = oBtn
        end
        if oBtn.redPoint:GetActive() then
            oTopRed = oBtn
            break
        end
    end
    local oSel = oTopRed or oTop
    if oSel then
        oSel:SetSelected(true)
        self:OnClickBtn(oSel.key)
    end
end

-- 隐藏界面
function CCelebrationView.HidePage(self, iTab)
    if not self.m_PartDict[iTab] then return end
    local iCurPageId = self.m_CurSelIdx
    local oTab = self.m_TabDict[iTab]
    if oTab then
        oTab:SetSelected(false)
        oTab:SetActive(false)
    end
    if iCurPageId == iTab then
        local iCount = 0
        local iTabCnt = #g_CelebrationCtrl.m_huodongConfig
        while iCount < iTabCnt - 1 do
            iCurPageId = iCurPageId + 1
            if iCurPageId > iTabCnt then
                iCurPageId = 1
            end
            iCount = iCount + 1
            local oNextTab = self.m_TabDict[iCurPageId]
            if oNextTab and oNextTab:GetActive() then
                self:OnClickBtn(iCurPageId)
                self.m_TabDict[iCurPageId]:SetSelected(true)
                break
            end
        end
    end
    self.m_BtnGrid:Reposition()
end

function CCelebrationView.OnUpdateCelebrationEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Celebration.Event.UpdateRankReward then
        self:ShowRedPoint(self.m_TabC.GradeRank, g_CelebrationCtrl:GetIsHasGradeRedPoint())
        self:ShowRedPoint(self.m_TabC.StrengthRank, g_CelebrationCtrl:GetIsHasScoreRedPoint())
        self:ShowRedPoint(self.m_TabC.OrgRank, g_CelebrationCtrl:GetIsHasOrgCntRedPoint() or g_CelebrationCtrl:GetIsHasOrgLevelRedPoint())
    end
end

function CCelebrationView.OnClickClose(self)
	self:CloseView()
end

return CCelebrationView