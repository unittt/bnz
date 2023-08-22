local CItemMainView = class("CItemMainView", CViewBase)

function CItemMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemMainView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CItemMainView.OnCreateView(self)
	self.m_TitleSpr = self:NewUI(1, CSprite)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_TabBtnGrid = self:NewUI(3, CTabGrid)
	-- 两个分页都有这个组件，所以放在View里
	self.m_ItemBagBox = self:NewUI(4, CItemBagBox)

	self.m_ItemModelPart = self:NewPage(5, CItemModelPart)
	self.m_ItemWHPart = self:NewPage(6, CItemWHPart)
	self.m_RefinePart = self:NewPage(7, CItemRefinePart)
	self.m_ItemWealthBox = self:NewUI(8, CItemWealthBox)
	-- self.m_ActorTexture = self:NewUI(8, CActorTexture)
	
	self.m_ItemGuideWidget1 = self:NewUI(11, CWidget)
	self.m_ItemGuideWidget2 = self:NewUI(12, CWidget)
	self.m_ItemGuideWidget3 = self:NewUI(13, CWidget)

	self:InitContent()
	self:ShowSpecificPart()
	self:RefreshRefineRedPoint()
	self:RegisterSysEffs()

	g_GuideCtrl:AddGuideUI("item_guide_widget1", self.m_ItemGuideWidget1)
	g_GuideCtrl:AddGuideUI("item_guide_widget2", self.m_ItemGuideWidget2)
	g_GuideCtrl:AddGuideUI("item_guide_widget3", self.m_ItemGuideWidget3)

	g_ItemCtrl.m_IsHasOpenItemBagView = true
	g_GuideCtrl:OnTriggerAll()
end

function CItemMainView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	-- 分页按钮
	local groupid = self.m_TabBtnGrid:GetInstanceID()
	local function init(obj, idx)
		local oBtn = CButton.New(obj, false, false)
		oBtn:SetGroup(groupid)
		if idx == 1 then
			g_AudioCtrl:SetRecordInfo(groupid, oBtn:GetInstanceID())
		end
		oBtn:SetClickSounPath(define.Audio.SoundPath.Tab)
		return oBtn
	end
	self.m_TabBtnGrid:InitChild(init)

	--TODO:tab和title的图片待替换
	self.m_PartInfoList = {
		{name = "baoguo", title = "h7_baoguo", part = self.m_ItemModelPart, showbag = true},
		{name = "cangku", title = "h7_cangku_2", part = self.m_ItemWHPart, showbag = true},
		{name = "refine", title = "h7_lianhua", part = self.m_RefinePart, showbag = false, unlock = define.System.Vigor},
	}
	for i,v in ipairs(self.m_PartInfoList) do
		v.btn = self.m_TabBtnGrid:GetChild(i)
		v.btn:AddUIEvent("click", callback(self, "ShowSubPageByIndex", i, v))
		local bIsShow = (v.unlock ~= nil and g_OpenSysCtrl:GetOpenSysState(v.unlock)) or not v.unlock
		v.btn:SetActive(bIsShow)
	end

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemEvent"))
end

function CItemMainView.OnItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshRefineRedPoint then
		self:RefreshRefineRedPoint()		
	end
end

function CItemMainView.ShowSpecificPart(self, tabIndex)
	if not tabIndex then
		g_ItemCtrl.m_RecordItemPartTab = 0
		tabIndex = 1
	end
	self:ShowSubPageByIndex(tabIndex, self.m_PartInfoList[tabIndex])
end

function CItemMainView.ShowSubPageByIndex(self, tabIndex, args)
	if g_ItemCtrl.m_RecordItemPartTab == tabIndex then
		return
	end
	if not args then
		args = self.m_PartInfoList[tabIndex]
	end
	g_ItemCtrl.m_RecordItemPartTab = tabIndex
	self.m_TitleSpr:SetSpriteName(args.title)
	self.m_TitleSpr:MakePixelPerfect()
	self.m_TabBtnGrid:SetTabSelect(args.btn)
	CGameObjContainer.ShowSubPageByIndex(self, tabIndex, args)

	self.m_ItemBagBox:SetActive(args.showbag)
end

function CItemMainView.Destroy(self)
	g_ItemCtrl.m_BagSclyRelative = self.m_ItemBagBox and self.m_ItemBagBox.m_BagItemBoxScly:GetLocalPos() or nil-- + Vector3.New(0, 5, 0)
	CViewBase.Destroy(self)
	g_ItemCtrl:ResetItemUIEffList()

	-- 音效
	g_AudioCtrl:SetRecordInfo(self.m_TabBtnGrid:GetInstanceID())
	if self.m_ItemBagBox and self.m_ItemBagBox.m_TabBtnGrid then
		g_AudioCtrl:SetRecordInfo(self.m_ItemBagBox.m_TabBtnGrid:GetInstanceID())
	end
	if self.m_ItemWHPart and self.m_ItemWHPart.m_WHCellGrid then
		g_AudioCtrl:SetRecordInfo(self.m_ItemWHPart.m_WHCellGrid:GetInstanceID())
	end
end

function CItemMainView.RefreshRefineRedPoint(self)
	if g_ItemCtrl.m_ShowRefineRedPoint then
        self.m_TabBtnGrid:GetChild(3):AddEffect("RedDot", 20, Vector2(-13, -17))
    else
        self.m_TabBtnGrid:GetChild(3):DelEffect("RedDot")
    end
end

function CItemMainView.CloseView(self)
	CViewBase.CloseView(self)
end

function CItemMainView.RegisterSysEffs(self)
	if not self.m_TabBtnGrid then return end
	local lhBtn = self.m_TabBtnGrid:GetChild(3)
	g_SysUIEffCtrl:TryAddEff("VIGOR", lhBtn)
	g_SysUIEffCtrl:DelSysEff("BAG_S")
end

return CItemMainView