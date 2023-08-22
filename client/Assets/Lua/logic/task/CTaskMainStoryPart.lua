local CTaskMainStoryPart = class("CTaskMainStoryPart", CPageBase)

function CTaskMainStoryPart.ctor(self, obj)
	CPageBase.ctor(self, obj)

	self.m_OldBox = self:NewUI(1, CObject)
	self.m_NewBox = self:NewUI(2, CObject)
	self.m_LeftArrowBtn = self:NewUI(3, CButton)
	self.m_RightArrowBtn = self:NewUI(4, CButton)
	self.m_ChapterName = self:NewUI(5, CLabel)
	-- self.m_DragScrollView = self:NewUI(5, CScrollView)
	-- self.m_PrizeBtn = self:NewUI(6, CButton)
	self.m_ChapterScrollView = self:NewUI(7, CScrollView)
	self.m_ChapterGrid = self:NewUI(8, CGrid)
	-- self.m_ChapterClone = self:NewUI(9, CBox)
	-- self.m_MaskBg = self:NewUI(10, CTexture)
	-- self.m_OpenBtn = self:NewUI(11, CButton)
	self.m_DragArea = self:NewUI(12, CWidget)

	-- self.m_DragTable = self:NewUI(13, CTable)
	self.m_DragWidget = self:NewUI(14, CWidget)

	self.m_ChapterBoxList = {}
	for i = 15, 27 do
		local oBox = self:NewUI(i, CBox)
		oBox.m_Texture = oBox:NewUI(1, CTexture)
		oBox.m_PrizeBtn = oBox:NewUI(2, CButton)
		oBox.m_MaskSp = oBox:NewUI(7, CSprite)
		oBox.m_EffectWidget = oBox:NewUI(8, CWidget)
		oBox.m_PrizeEffect = oBox:NewUI(9, CSprite)
		oBox.m_KuangSp = oBox:NewUI(10, CSprite)
		oBox.m_LightSp = oBox:NewUI(11, CSprite)

		table.insert(self.m_ChapterBoxList, oBox)
	end
	self.m_ChapterBoxList[#self.m_ChapterBoxList]:NewUI(3, CSprite):SetActive(false)
	self.m_ChapterBoxList[#self.m_ChapterBoxList]:NewUI(4, CSprite):SetActive(false)
	self.m_ChapterBoxList[#self.m_ChapterBoxList]:NewUI(5, CSprite):SetActive(false)
	self.m_ChapterBoxList[#self.m_ChapterBoxList]:NewUI(6, CSprite):SetActive(false)

	self.m_ListScrollView = self:NewUI(28, CScrollView)
	self.m_ListGrid = self:NewUI(29, CGrid)
	self.m_PieceBox = self:NewUI(30, CBox)
	self.m_PrizeScrollView = self:NewUI(31, CScrollView)
	self.m_PrizeGrid = self:NewUI(32, CGrid)
	self.m_PrizeBoxClone = self:NewUI(33, CBox)
	self.m_PrizeGetBtn = self:NewUI(34, CButton)
	self.m_HasRewardSp = self:NewUI(35, CSprite)
	self.m_NextPieceWidget = self:NewUI(36, CWidget)
	self.m_NextPieceLbl = self:NewUI(37, CLabel)

	g_GuideCtrl:AddGuideUI("task_story_getbtn", self.m_PrizeGetBtn)

	local function init(obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_PrizeSp = oBox:NewUI(1, CSprite)
		oBox.m_PrizeLightSp = oBox:NewUI(2, CSprite)
		oBox.m_PrizeHasGet = oBox:NewUI(3, CSprite)
		oBox:SetGroup(self:GetInstanceID())
		oBox:AddUIEvent("click", callback(self, "OnClickListBox", idx))
		return oBox
	end
	self.m_ListGrid:InitChild(init)

	self.m_ChapterList = {}
	for i = 1, 7 do
		local oBox = self.m_PieceBox:NewUI(i, CBox)
		oBox.m_ChildList = {}
		for j = 1, 8 do
			table.insert(oBox.m_ChildList, oBox:NewUI(j, CTexture))
		end
		table.insert(self.m_ChapterList, oBox)
	end

	-- self.m_CenterIndex = 1
	-- self.m_ChapterScrollView:CenterOn(self.m_ChapterBoxList[self.m_CenterIndex].m_Transform)
	-- self:CheckChapterBox()

	self.m_ChapterScrollView:InitCenterOnCompnent(self.m_ChapterGrid, callback(self, "OnCenterChapter"))
	self.m_MoveStartX = 0	
	-- self.m_CurChapter = 1

	self.m_SelectChapterData = nil
	self.m_SelectChapterIndex = g_TaskCtrl:GetShowIndex()

	if g_TaskCtrl.m_IsUseChapterNew then
		self.m_OldBox:SetActive(false)
		self.m_NewBox:SetActive(true)
	else
		self.m_OldBox:SetActive(true)
		self.m_NewBox:SetActive(false)
	end

	self:InitContent()
end

function CTaskMainStoryPart.OnInitPage(self)
	local function delay()
		if Utils.IsNil(self) then
			return false
		end
		if self.m_DefaultChapter and self.m_DefaultChapter ~= 0 then
			self.m_CenterIndex = self.m_DefaultChapter
			self.m_ChapterScrollView:CenterOn(self.m_ChapterBoxList[self.m_CenterIndex].m_Transform)
		else
			self.m_CenterIndex = g_TaskCtrl:GetShowIndex()
			self.m_ChapterScrollView:CenterOn(self.m_ChapterBoxList[self.m_CenterIndex].m_Transform)
		end
		return false
	end
	Utils.AddTimer(delay, 0, 0.1)
	-- print(string.format("<color=#00FFFF> >>> .%s | 程序执行到这里了 | %s </color>", "OnInitPage", "剧情Part，什么都没有"))
	if g_TaskCtrl.m_IsUseChapterNew then
		local oTargetBox = self.m_ListGrid:GetChild(self.m_SelectChapterIndex)
		if oTargetBox then
			UITools.MoveToTarget(self.m_ListScrollView, oTargetBox)
		end
	end
end

function CTaskMainStoryPart.InitContent(self)
	self.m_PrizeBoxClone:SetActive(false)	
	-- self.m_LeftArrowBtn:GetComponent(classtype.BoxCollider).enabled = true
	-- self.m_LeftArrowBtn:SetGrey(false)
	self.m_RightArrowBtn:GetComponent(classtype.BoxCollider).enabled = true
	self.m_RightArrowBtn:SetGrey(false)

	self.m_LeftArrowBtn:AddUIEvent("click", callback(self, "OnClickLeftArrow"))
	self.m_RightArrowBtn:AddUIEvent("click", callback(self, "OnClickRightArrow"))

	self.m_DragWidget:AddUIEvent("dragstart", callback(self, "OnDragChapterStart"))
	self.m_DragWidget:AddUIEvent("drag", callback(self, "OnDragChapter"))
	self.m_DragWidget:AddUIEvent("dragend", callback(self, "OnDragChapterEnd"))

	for k,v in ipairs(self.m_ChapterBoxList) do
		v.m_Texture:AddUIEvent("click", callback(self, "OnClickChapterItem", k))
		v.m_PrizeBtn:AddUIEvent("click", callback(self, "OnClickPrize", k))
	end
	self.m_PrizeGetBtn:AddUIEvent("click", callback(self, "OnClickGetPrize"))

	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlTaskEvent"))

	self:RefreshUI()
end

function CTaskMainStoryPart.OnCtrlTaskEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Task.Event.RefreshChapterInfo then
		self:RefreshUI()
	end
end

function CTaskMainStoryPart.RefreshUI(self)
	self.m_ChapList = g_TaskCtrl:GetShowChapterList()
	for i =1, #self.m_ChapterBoxList do
		if i <= #self.m_ChapList then
			self.m_ChapterBoxList[i]:SetActive(true)
			local config = g_TaskCtrl:GetChapterConfig()[self.m_ChapList[i].chapter]
			local oHasReward = table.index(g_TaskCtrl.m_ChapterHasRewardPrizeList, self.m_ChapList[i].chapter) ~= nil
			if table.count(self.m_ChapList[i].pieces) >= config.proceeds and not oHasReward then
				self.m_ChapterBoxList[i].m_PrizeBtn:SetSpriteName("h7_baoxiang")
				self.m_ChapterBoxList[i].m_PrizeEffect:SetActive(true)
				-- self.m_ChapterBoxList[i].m_EffectWidget:AddEffect("Screen", "ui_eff_0035", Vector3.New(3, 3, 3), nil, nil, -2)
			elseif table.count(self.m_ChapList[i].pieces) >= config.proceeds and oHasReward then
				self.m_ChapterBoxList[i].m_PrizeBtn:SetSpriteName("h7_baoxiang_1")
				self.m_ChapterBoxList[i].m_PrizeEffect:SetActive(false)
				-- self.m_ChapterBoxList[i].m_EffectWidget:DelEffect("Screen")
			elseif table.count(self.m_ChapList[i].pieces) < config.proceeds then
				self.m_ChapterBoxList[i].m_PrizeBtn:SetSpriteName("h7_baoxiang")
				self.m_ChapterBoxList[i].m_PrizeEffect:SetActive(false)
				-- self.m_ChapterBoxList[i].m_EffectWidget:DelEffect("Screen")
			end

			self.m_ChapterBoxList[i].m_KuangSp:SetActive(false)
			self.m_ChapterBoxList[i].m_LightSp:SetActive(false)
			if table.count(self.m_ChapList[i].pieces) >= config.proceeds then
				self.m_ChapterBoxList[i].m_MaskSp:SetSpriteName("h7_yiwancheng")
			elseif i == g_TaskCtrl.m_TaskCurChapter and g_TaskCtrl.m_TaskCurChapter ~= 0 then
				self.m_ChapterBoxList[i].m_MaskSp:SetSpriteName("h7_jinxingzhong")
				self.m_ChapterBoxList[i].m_KuangSp:SetActive(true)
				self.m_ChapterBoxList[i].m_LightSp:SetActive(true)
			else
				self.m_ChapterBoxList[i].m_MaskSp:SetSpriteName("h7_weikaiqi")
			end
		else
			self.m_ChapterBoxList[i]:SetActive(false)
		end
	end
	--暂时屏蔽
	-- self.m_ChapterBoxList[#self.m_ChapList]:NewUI(3, CSprite):SetActive(false)
	-- self.m_ChapterBoxList[#self.m_ChapList]:NewUI(4, CSprite):SetActive(false)
	-- self.m_ChapterBoxList[#self.m_ChapList]:NewUI(5, CSprite):SetActive(false)
	-- self.m_ChapterBoxList[#self.m_ChapList]:NewUI(6, CSprite):SetActive(false)
	self.m_ChapterGrid:Reposition()

	self:RefreshLeftList()
	self:RefreshRightChapterByIndex(self.m_SelectChapterIndex)
end

-- function CTaskMainStoryPart.SetShowChapterIndex(self, index)
-- 	self.m_CurChapter = index
-- end


function CTaskMainStoryPart.SetChapterBgHideEffect(self, oWidget)
	local tween = oWidget:GetComponent(classtype.TweenAlpha)
	tween.enabled = true
	oWidget:SetAlpha(1)
	tween.from = 1
	tween.to = 0
	tween.duration = define.Task.Time.StoryPartBgHideDurationTime
	tween:ResetToBeginning()
	-- tween.delay = define.Task.Time.MoveDown
	tween:PlayForward()
end

function CTaskMainStoryPart.SetChapterBgShowEffect(self, oWidget)
	local tween = oWidget:GetComponent(classtype.TweenAlpha)
	tween.enabled = true
	oWidget:SetAlpha(0)
	tween.from = 0
	tween.to = 1
	tween.duration = define.Task.Time.StoryPartBgShowDurationTime
	tween:ResetToBeginning()
	-- tween.delay = define.Task.Time.MoveDown
	tween:PlayForward()
end

function CTaskMainStoryPart.GetLeftOffsetX(self, oIndex)
	local offsetX = 0
	-- if oIndex == 1 then
	-- 	offsetX = offsetX + oIndex*15/2
	-- else
	-- 	offsetX = offsetX + oIndex*15/2
	-- 	printc("GetLeftOffsetX start", offsetX, "  oIndex", oIndex)
	-- 	for i = oIndex-1, 1, -1 do
	-- 		offsetX = offsetX + 15*i
	-- 		printc("GetLeftOffsetX progress", offsetX)
	-- 	end
	-- end
	if oIndex == 1 then
		offsetX = 7.5
	elseif oIndex == 2 then
		offsetX = 30
	elseif oIndex == 3 then
		offsetX = 67.5
	elseif oIndex == 4 then
		offsetX = 120
	elseif oIndex == 5 then
		offsetX = 187.5
	elseif oIndex == 6 then
		offsetX = 270
	elseif oIndex == 7 then
		offsetX = 367.5
	elseif oIndex == 8 then
		offsetX = 480
	else
		offsetX = 7.5
	end
	return offsetX
end

--193 177
function CTaskMainStoryPart.CheckChapterBox(self)
	-- for k,v in pairs(self.m_ChapterBoxList) do
	-- 	v:NewUI(1, CTexture):SetWidth(207)
	-- 	v:NewUI(1, CTexture):SetLocalPos(Vector3.New(0, 0, 0))
	-- end
	self.m_ChapterBoxList[self.m_CenterIndex]:NewUI(1, CTexture):SetWidth(207)
	self.m_ChapterBoxList[self.m_CenterIndex]:NewUI(1, CTexture):SetLocalPos(Vector3.New(0, 0, 0))
	--暂时屏蔽
	-- if self.m_CenterIndex < #self.m_ChapList then
	-- 	self.m_ChapterBoxList[self.m_CenterIndex]:NewUI(3, CSprite):SetActive(false)
	-- 	self.m_ChapterBoxList[self.m_CenterIndex]:NewUI(4, CSprite):SetActive(false)
	-- 	self.m_ChapterBoxList[self.m_CenterIndex]:NewUI(5, CSprite):SetActive(true)
	-- 	self.m_ChapterBoxList[self.m_CenterIndex]:NewUI(6, CSprite):SetActive(true)
	-- end

	if self.m_CenterIndex-1 >= 1 then
		local offsetX = 0
		for i = 1, self.m_CenterIndex-1 do
			self.m_ChapterBoxList[i]:NewUI(1, CTexture):SetWidth(math.floor( (207 - 15*(self.m_CenterIndex - i)) ))
			local curIndex = (self.m_CenterIndex - i)
			self.m_ChapterBoxList[i]:NewUI(1, CTexture):SetLocalPos(Vector3.New(self:GetLeftOffsetX(curIndex), 0, 0))

			--暂时屏蔽
			-- self.m_ChapterBoxList[i]:NewUI(3, CSprite):SetActive(true)
			-- self.m_ChapterBoxList[i]:NewUI(4, CSprite):SetActive(true)
			-- self.m_ChapterBoxList[i]:NewUI(5, CSprite):SetActive(false)
			-- self.m_ChapterBoxList[i]:NewUI(6, CSprite):SetActive(false)
		end
	end

	if self.m_CenterIndex+1 <= #self.m_ChapList then
		local offsetX = 0
		for i = self.m_CenterIndex+1, #self.m_ChapList do
			self.m_ChapterBoxList[i]:NewUI(1, CTexture):SetWidth(math.floor(  (207 - 15*(i - self.m_CenterIndex)) ))
			local curIndex = (i - self.m_CenterIndex)			
			self.m_ChapterBoxList[i]:NewUI(1, CTexture):SetLocalPos(Vector3.New(-self:GetLeftOffsetX(curIndex), 0, 0))

			--暂时屏蔽
			-- if i < #self.m_ChapList then
			-- 	self.m_ChapterBoxList[i]:NewUI(3, CSprite):SetActive(false)
			-- 	self.m_ChapterBoxList[i]:NewUI(4, CSprite):SetActive(false)
			-- 	self.m_ChapterBoxList[i]:NewUI(5, CSprite):SetActive(true)
			-- 	self.m_ChapterBoxList[i]:NewUI(6, CSprite):SetActive(true)
			-- end
		end
	end
end

---------------以下是点击事件--------------

function CTaskMainStoryPart.OnClickChapterItem(self, oIndex)
	self.m_CenterIndex = oIndex
	self.m_ChapterScrollView:CenterOn(self.m_ChapterBoxList[self.m_CenterIndex].m_Transform)
	-- self:CheckChapterBox()
	local oChapterData = g_TaskCtrl:GetChapterInfoByIndex(oIndex)
	if oChapterData then
		CTaskStoryPieceView:ShowView(function (oView)
			oView:RefreshUI(oChapterData)
		end)
	end
end

function CTaskMainStoryPart.OnClickLeftArrow(self)
	self.m_CenterIndex = self.m_CenterIndex - 1
	if self.m_CenterIndex < 1 then
		self.m_CenterIndex = 1
	end
	self.m_ChapterScrollView:CenterOn(self.m_ChapterBoxList[self.m_CenterIndex].m_Transform)
	-- self:CheckChapterBox()
end

function CTaskMainStoryPart.OnClickRightArrow(self)
	self.m_CenterIndex = self.m_CenterIndex + 1
	if self.m_CenterIndex > #self.m_ChapList then
		self.m_CenterIndex = #self.m_ChapList
	end
	self.m_ChapterScrollView:CenterOn(self.m_ChapterBoxList[self.m_CenterIndex].m_Transform)
	-- self:CheckChapterBox()
end

function CTaskMainStoryPart.OnCenterChapter(self, oGridCenter, gameObject)
	-- printc("哈哈哈哈哈哈", gameObject.name)
	self.m_CenterIndex = tonumber(gameObject.name)
	-- self.m_ChapterScrollView:CenterOn(self.m_ChapterBoxList[self.m_CenterIndex].m_Transform)
	self:CheckChapterBox()
end

function CTaskMainStoryPart.OnClickPrize(self, oIndex)
	if g_TaskCtrl:GetChapterInfoByIndex(oIndex) then
		CTaskStoryChapterPrizeView:ShowView(function (oView)
			oView:RefreshUI(g_TaskCtrl:GetChapterInfoByIndex(oIndex))
		end)
	end
end

------------暂时没用-------------

function CTaskMainStoryPart.OnDragChapterStart(self, obj)
	self.m_MoveStartX = UnityEngine.Input.mousePosition.x
end

function CTaskMainStoryPart.OnDragChapter(self, obj, moveDelta)
end

function CTaskMainStoryPart.OnDragChapterEnd(self, obj)
	local moveDeltax = UnityEngine.Input.mousePosition.x - self.m_MoveStartX
	if moveDeltax < 0 then
		-- printc("CTaskMainStoryPart.OnClickRightArrow")
		local isRefresh = true
		self.m_CenterIndex = self.m_CenterIndex + 1
		if self.m_CenterIndex > #self.m_ChapList then
			isRefresh = false
			self.m_CenterIndex = #self.m_ChapList
		end
		if isRefresh then
			self.m_ChapterScrollView:CenterOn(self.m_ChapterBoxList[self.m_CenterIndex].m_Transform)
			self:CheckChapterBox()
		end
	elseif moveDeltax > 0 then
		-- printc("CTaskMainStoryPart.OnClickLeftArrow")
		local isRefresh = true
		self.m_CenterIndex = self.m_CenterIndex - 1
		if self.m_CenterIndex < 1 then
			isRefresh = false
			self.m_CenterIndex = 1
		end
		if isRefresh then
			self.m_ChapterScrollView:CenterOn(self.m_ChapterBoxList[self.m_CenterIndex].m_Transform)
			self:CheckChapterBox()
		end
	end
end

-----------------新剧情界面修改----------------

function CTaskMainStoryPart.RefreshLeftList(self)
	for k,v in ipairs(self.m_ListGrid:GetChildList()) do
		local oChapterData = g_TaskCtrl:GetChapterInfoByIndex(k)
		if oChapterData then
			local config = g_TaskCtrl:GetChapterConfig()[oChapterData.chapter]

			local oHasReward = table.index(g_TaskCtrl.m_ChapterHasRewardPrizeList, oChapterData.chapter) ~= nil
			if table.count(oChapterData.pieces) >= config.proceeds and not oHasReward then
				v.m_PrizeSp:SetSpriteName("h7_baoxiang")
				v.m_PrizeLightSp:SetActive(true)
				v.m_PrizeHasGet:SetActive(false)
				v.m_PrizeSp:SetGrey(false)
			elseif table.count(oChapterData.pieces) >= config.proceeds and oHasReward then
				v.m_PrizeSp:SetSpriteName("h7_baoxiang_1")
				v.m_PrizeLightSp:SetActive(false)
				v.m_PrizeHasGet:SetActive(true)
				v.m_PrizeSp:SetGrey(true)
			else
				v.m_PrizeSp:SetSpriteName("h7_baoxiang")
				v.m_PrizeLightSp:SetActive(false)
				v.m_PrizeHasGet:SetActive(false)
				v.m_PrizeSp:SetGrey(true)
			end

			if g_TaskCtrl:CheckTaskChapterList(oChapterData.chapter) then
				v:SetGrey(false)				
			else
				v:SetGrey(true)
			end
		end
	end
end

function CTaskMainStoryPart.RefreshRightChapterByIndex(self, oIndex)
	self.m_SelectChapterIndex = oIndex
	local oChapterData = g_TaskCtrl:GetChapterInfoByIndex(oIndex)
	self:RefreshRightChapter(oChapterData)
end

function CTaskMainStoryPart.RefreshRightChapter(self, oChapterData)
	if not oChapterData then
		return
	end
	self.m_SelectChapterData = oChapterData

	local oListBox = self.m_ListGrid:GetChild(oChapterData.chapter)
	if oListBox then
		oListBox:SetSelected(true)
	end

	if not self.m_ChapterList[oChapterData.chapter] then
		return
	end
	for k,v in ipairs(self.m_ChapterList) do
		if k == oChapterData.chapter then
			v:SetActive(true)
		else
			v:SetActive(false)
		end
	end

	local texList = self.m_ChapterList[oChapterData.chapter].m_ChildList
	for k,v in ipairs(texList) do
		v:SetGrey(true)
		-- v:SetActive(false)
	end
	for k,v in pairs(oChapterData.pieces) do
		texList[self:GetEachIndex(v)]:SetGrey(false)
		-- texList[self:GetEachIndex(v)]:SetActive(true)
	end

	-- if table.count(oChapterData.pieces) < data.taskdata.STORYCHAPTER[oChapterData.chapter].proceeds then
	-- 	self.m_ChapterList[oChapterData.chapter]:SetLocalPos(Vector3.New(-218, 237, 0))
	-- 	self.m_ChapterList[oChapterData.chapter]:SetCellSize(145, 198)
	-- 	self.m_ChapterList[oChapterData.chapter]:Reposition()
	-- else
	-- 	self.m_ChapterList[oChapterData.chapter]:SetLocalPos(Vector3.New(-215, 237, 0))
	-- 	self.m_ChapterList[oChapterData.chapter]:SetCellSize(143, 196)
	-- 	self.m_ChapterList[oChapterData.chapter]:Reposition()
	-- end

	local config = g_TaskCtrl:GetChapterConfig()[oChapterData.chapter]
	local prizedata = g_GuideHelpCtrl:GetRewardList("STORY", config.reward)
	self:SetPrizeList(prizedata)

	local oHasReward = table.index(g_TaskCtrl.m_ChapterHasRewardPrizeList, oChapterData.chapter) ~= nil
	self.m_PrizeGetBtn.m_UIButton.tweenTarget = nil
	if table.count(oChapterData.pieces) >= config.proceeds and not oHasReward then
		self.m_PrizeGetBtn:SetActive(true)
		self.m_PrizeGetBtn:GetComponent(classtype.BoxCollider).enabled = true
		self.m_PrizeGetBtn:SetBtnGrey(false)		
		self.m_PrizeGetBtn:AddEffect("Rect")
		self.m_HasRewardSp:SetActive(false)
	elseif table.count(oChapterData.pieces) >= config.proceeds and oHasReward then
		self.m_PrizeGetBtn:SetActive(false)
		self.m_PrizeGetBtn:SetBtnGrey(true)
		self.m_PrizeGetBtn:DelEffect("Rect")
		self.m_HasRewardSp:SetActive(true)
	else
		self.m_PrizeGetBtn:SetActive(true)
		self.m_PrizeGetBtn:GetComponent(classtype.BoxCollider).enabled = false
		self.m_PrizeGetBtn:SetBtnGrey(true)
		self.m_PrizeGetBtn:DelEffect("Rect")
		self.m_HasRewardSp:SetActive(false)
	end

	if g_TaskCtrl.m_TaskCurChapter > 0 then
		if oChapterData.chapter == g_TaskCtrl.m_TaskCurChapter and table.count(oChapterData.pieces) < config.proceeds then
			local oNextPiece = #oChapterData.pieces+1 >= config.proceeds and config.proceeds or (#oChapterData.pieces+1)
			local oTaskConfig = g_TaskCtrl:GetChapterToTaskConfig(oChapterData.chapter, oNextPiece)
			self.m_NextPieceWidget:SetActive(true)
			if next(oTaskConfig) then
				local oShowStr = "主线-第"..string.printInChinese(oTaskConfig[1].chapter_mark.chapternameid).."章\n(" --oChapterData.chapter+1
				for k,v in ipairs(oTaskConfig) do
					if k == 1 then
						oShowStr = oShowStr..v.name
					else
						oShowStr = oShowStr.."\n或"..v.name
					end
				end
				oShowStr = oShowStr..")"
				self.m_NextPieceLbl:SetText(oShowStr)
			end	
			UITools.NearTarget(texList[self:GetEachIndex(oNextPiece)], self.m_NextPieceWidget, enum.UIAnchor.Side.Center, Vector2.New(0, 0))
		else
			self.m_NextPieceWidget:SetActive(false)
		end
	else
		self.m_NextPieceWidget:SetActive(false)
	end
end

function CTaskMainStoryPart.GetEachIndex(self, oIndex)
	if oIndex == 1 then
		return 1
	elseif oIndex == 2 then
		return 2
	elseif oIndex == 3 then
		return 3
	elseif oIndex == 4 then
		return 4
	elseif oIndex == 5 then
		return 5
	elseif oIndex == 6 then
		return 6
	elseif oIndex == 7 then
		return 7
	elseif oIndex == 8 then
		return 8
	else
		return 1
	end
end

function CTaskMainStoryPart.SetPrizeList(self, oList)
	local optionCount = #oList
	local GridList = self.m_PrizeGrid:GetChildList() or {}
	local oPrizeBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oPrizeBox = self.m_PrizeBoxClone:Clone(false)
				-- self.m_PrizeGrid:AddChild(oOptionBtn)
			else
				oPrizeBox = GridList[i]
			end
			self:SetPrizeBox(oPrizeBox, oList[i])
		end

		if #GridList > optionCount then
			for i=optionCount+1,#GridList do
				GridList[i]:SetActive(false)
			end
		end
	else
		if GridList and #GridList > 0 then
			for _,v in ipairs(GridList) do
				v:SetActive(false)
			end
		end
	end

	self.m_PrizeGrid:Reposition()
	self.m_PrizeScrollView:ResetPosition()
end

function CTaskMainStoryPart.SetPrizeBox(self, oPrizeBox, oPrize)
	oPrizeBox:SetActive(true)
	oPrizeBox.m_IconSp = oPrizeBox:NewUI(1, CSprite)
	oPrizeBox.m_CountLbl = oPrizeBox:NewUI(2, CLabel)
	oPrizeBox.m_QualitySp = oPrizeBox:NewUI(3, CSprite)

	oPrizeBox.m_IconSp = oPrizeBox:NewUI(1, CSprite)
	oPrizeBox.m_CountLbl = oPrizeBox:NewUI(2, CLabel)
	oPrizeBox.m_QualitySp = oPrizeBox:NewUI(3, CSprite)
    oPrizeBox.m_QualitySp:SetItemQuality(g_ItemCtrl:GetQualityVal( oPrize.item.id, oPrize.item.quality or 0 ) )
	oPrizeBox.m_IconSp:SpriteItemShape(oPrize.item.icon)
	oPrizeBox.m_CountLbl:SetText(oPrize.amount)
	
	oPrizeBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickPrizeBox", oPrize, oPrizeBox))

	self.m_PrizeGrid:AddChild(oPrizeBox)
	self.m_PrizeGrid:Reposition()
end

--显示奖励tips
function CTaskMainStoryPart.OnClickPrizeBox(self, oPrize, oPrizeBox)
	local args = {
        widget = oPrizeBox,
        side = enum.UIAnchor.Side.Top,
        offset = Vector2.New(0, 0)
    }
    g_WindowTipCtrl:SetWindowItemTip(oPrize.item.id, args)
end

function CTaskMainStoryPart.OnClickListBox(self, oIndex)
	self:RefreshRightChapterByIndex(oIndex)
end

function CTaskMainStoryPart.OnClickGetPrize(self)
	if self.m_SelectChapterData then
		nettask.C2GSRewardStoryChapter(self.m_SelectChapterData.chapter)
	end
end

return CTaskMainStoryPart