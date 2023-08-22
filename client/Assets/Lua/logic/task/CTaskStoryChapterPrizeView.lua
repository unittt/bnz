local CTaskStoryChapterPrizeView = class("CTaskStoryChapterPrizeView", CViewBase)

function CTaskStoryChapterPrizeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Task/TaskStoryChapterPrizeView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CTaskStoryChapterPrizeView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ScrollView = self:NewUI(2, CScrollView)
	self.m_Grid = self:NewUI(3, CGrid)
	self.m_BoxClone = self:NewUI(4, CBox)
	self.m_TipsLbl = self:NewUI(5, CLabel)
	self.m_ConfirmBtn = self:NewUI(6, CButton)
	self.m_GetBtn = self:NewUI(7, CButton)
	self.m_RewardedSp = self:NewUI(8, CSprite)

	self.m_ChapterData = nil

	self:InitContent()
end

function CTaskStoryChapterPrizeView.InitContent(self)
	self.m_BoxClone:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnClickConfirm"))
	self.m_GetBtn:AddUIEvent("click", callback(self, "OnClickGet"))
end

function CTaskStoryChapterPrizeView.RefreshUI(self, oData)
	self.m_ChapterData = oData
	local config = g_TaskCtrl:GetChapterConfig()[oData.chapter]
	local prizedata = g_GuideHelpCtrl:GetRewardList("STORY", config.reward)
	self:SetPrizeInfo(prizedata)

	local oHasReward = table.index(g_TaskCtrl.m_ChapterHasRewardPrizeList, oData.chapter) ~= nil
	if table.count(oData.pieces) >= config.proceeds and not oHasReward then
		self.m_ConfirmBtn:SetActive(false)
		self.m_GetBtn:SetActive(true)		
		self.m_GetBtn:AddEffect("Rect")
		self.m_RewardedSp:SetActive(false)
	elseif table.count(oData.pieces) >= config.proceeds and oHasReward then
		self.m_ConfirmBtn:SetActive(false)
		self.m_GetBtn:SetActive(false)
		self.m_GetBtn:DelEffect("Rect")
		self.m_RewardedSp:SetActive(true)
	else
		self.m_ConfirmBtn:SetActive(true)
		self.m_ConfirmBtn:SetBtnGrey(true)
		self.m_GetBtn:SetActive(false)
		self.m_GetBtn:DelEffect("Rect")
		self.m_RewardedSp:SetActive(false)
	end
end

function CTaskStoryChapterPrizeView.SetPrizeInfo(self, oData)
	self.m_Grid:Clear()
	if oData and next(oData) then
		for k,v in ipairs(oData) do
			self:AddPrizeBox(v)
		end
	end
	self.m_Grid:Reposition()
	self.m_ScrollView:ResetPosition()
end

function CTaskStoryChapterPrizeView.AddPrizeBox(self, oPrize)
	local oPrizeBox = self.m_BoxClone:Clone()
	
	oPrizeBox:SetActive(true)
	oPrizeBox.m_IconSp = oPrizeBox:NewUI(1, CSprite)
	oPrizeBox.m_CountLbl = oPrizeBox:NewUI(2, CLabel)
	oPrizeBox.m_QualitySp = oPrizeBox:NewUI(3, CSprite)
    oPrizeBox.m_QualitySp:SetItemQuality(g_ItemCtrl:GetQualityVal( oPrize.item.id, oPrize.item.quality or 0 ) )
	oPrizeBox.m_IconSp:SpriteItemShape(oPrize.item.icon)
	oPrizeBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickDayPrizeBox", oPrize, oPrizeBox))
	oPrizeBox.m_CountLbl:SetText(oPrize.amount)
	self.m_Grid:AddChild(oPrizeBox)
	self.m_Grid:Reposition()
	-- self.m_ScrollView:CullContentLater()
end

--显示奖励tips
function CTaskStoryChapterPrizeView.OnClickDayPrizeBox(self, oPrize, oPrizeBox)
	local args = {
        widget = oPrizeBox,
        side = enum.UIAnchor.Side.Top,
        offset = Vector2.New(0, 0)
    }
    g_WindowTipCtrl:SetWindowItemTip(oPrize.item.id, args)
end

-----------------以下是点击事件--------------------

function CTaskStoryChapterPrizeView.OnClickConfirm(self)
	self:CloseView()
end

function CTaskStoryChapterPrizeView.OnClickGet(self)
	if self.m_ChapterData then
		nettask.C2GSRewardStoryChapter(self.m_ChapterData.chapter)
	end
	self:CloseView()
end

return CTaskStoryChapterPrizeView