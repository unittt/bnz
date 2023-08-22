local CTaskStoryChapterView = class("CTaskStoryChapterView", CViewBase)

function CTaskStoryChapterView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Task/TaskStoryChapterView.prefab", cb)
	--界面设置
	self.m_DepthType = "Fourth"
	-- self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"

	self.m_Test = false
	self.m_IsSkiped = false
	self.m_ChapterBgIndex = 1
end

function CTaskStoryChapterView.OnCreateView(self)
	self.m_Widget = self:NewUI(1, CWidget)
	self.m_DragWidget = self:NewUI(2, CWidget)
	self.m_ChapterBg = self:NewUI(3, CTexture)
	self.m_MaskBg = self:NewUI(4, CTexture)
	self.m_SkipBtn = self:NewUI(5, CButton)
	self.m_ChapterNameLbl = self:NewUI(6, CLabel)
	self.m_ChapterDescLbl = self:NewUI(7, CLabel)
	self.m_FengGeXianSp = self:NewUI(8, CSprite)
	
	self:InitContent()
end

function CTaskStoryChapterView.InitContent(self)
	UITools.ResizeToRootSize(self.m_MaskBg, 200, 200)
	self.m_SkipBtn:AddUIEvent("click", callback(self, "OnClickSkipChapter"))
end

function CTaskStoryChapterView.RefreshUI(self)
	self.m_IsSkiped = false
	self.m_ChapterBgIndex = 1
	self.m_SkipBtn:GetComponent(classtype.BoxCollider).enabled = true

	self.m_MaskBg:SetActive(true)
	self.m_ChapterNameLbl:SetActive(true)
	self.m_ChapterDescLbl:SetActive(true)
	self.m_FengGeXianSp:SetActive(true)
	self.m_MaskBg:SetAlpha(1)
	self.m_FengGeXianSp:SetAlpha(1)

	if self.m_Test then
		g_TaskCtrl.m_TaskCurChapter = 1
	end

	if g_TaskCtrl.m_TaskCurChapter <= 0 then
		return
	end

	local path = "Texture/Minimap/"..g_TaskCtrl:GetChapterBgList()[g_TaskCtrl.m_TaskCurChapter][self.m_ChapterBgIndex]..".jpg"
	g_ResCtrl:LoadAsync(path, callback(self, "SetTexture"))

	local config = data.taskdata.TASKCHAPTER[g_TaskCtrl.m_TaskCurChapter]
	self.m_ChapterNameLbl:SetAlpha(1)
	self.m_ChapterNameLbl:SetText(config.name)
	self.m_ChapterNameLbl:SetLocalPos(Vector3.New(0, define.Task.Pos.ChapterNamePosYFrom, 0))
	local tween = DOTween.DOLocalMoveY(self.m_ChapterNameLbl.m_Transform, define.Task.Pos.ChapterNamePosYTo, define.Task.Time.MoveDown)
	DOTween.SetEase(tween, 1)

	self.m_ChapterDescLbl:SetAlpha(1)
	self.m_ChapterDescLbl:SetText(config.desc)
	self.m_ChapterDescLbl:SetLocalPos(Vector3.New(0, define.Task.Pos.ChapterDescPosYFrom, 0))
	local tween = DOTween.DOLocalMoveY(self.m_ChapterDescLbl.m_Transform, define.Task.Pos.ChapterDescPosYTo, define.Task.Time.MoveUp)
	DOTween.SetEase(tween, 1)

	self:SetMaskHideEffect(self.m_MaskBg)
	self:SetMaskHideEffect(self.m_ChapterNameLbl)
	self:SetMaskHideEffect(self.m_ChapterDescLbl)
	self:SetMaskHideEffect(self.m_FengGeXianSp)

	self:SetChapterBgTime()
end

function CTaskStoryChapterView.SetMaskHideEffect(self, oWidget)
	local tween = oWidget:GetComponent(classtype.TweenAlpha)
	oWidget:SetAlpha(1)
	tween.from = 1
	tween.to = 0
	tween.duration = 1
	tween:ResetToBeginning()
	tween.delay = define.Task.Time.ChapterMaskHideTime
	tween:PlayForward()
end

function CTaskStoryChapterView.SetBgHideEffect(self, oWidget)
	oWidget:GetComponent(classtype.TweenAlpha).enabled = true
	local tween = oWidget:GetComponent(classtype.TweenAlpha)
	oWidget:SetAlpha(1)
	tween.from = 1
	tween.to = 0
	tween.duration = define.Task.Time.ChapterBgHideDurationTime
	tween:ResetToBeginning()
	tween.delay = define.Task.Time.ChapterBgHideTime
	tween:PlayForward()
end

--设置章节图片的倒计时
function CTaskStoryChapterView.SetChapterBgTime(self)
	self:ResetChapterBgTimer()
	local function progress()
		self.m_ChapterBgIndex = self.m_ChapterBgIndex + 1

		if not Utils.IsNil(self) then
			local path = "Texture/Minimap/"..g_TaskCtrl:GetChapterBgList()[g_TaskCtrl.m_TaskCurChapter][self.m_ChapterBgIndex]..".jpg"
			g_ResCtrl:LoadAsync(path, callback(self, "SetTexture"))
		end

		if #g_TaskCtrl:GetChapterBgList()[g_TaskCtrl.m_TaskCurChapter] <= self.m_ChapterBgIndex then
			self:ExecuteEndEvent()
			return false
		end
		return true
	end	

	self.m_BgTimer = Utils.AddTimer(progress, define.Task.Time.ChapterBgIntervalTime, define.Task.Time.ChapterBgStartDelayTime)	
end

function CTaskStoryChapterView.SetTexture(self, prefab, errcode)
	if prefab then
		self.m_ChapterBg:SetMainTexture(prefab)
		UITools.ResizeToRootSize(self.m_ChapterBg, 10, 10)
		UITools.ResizeToRootSize(self.m_MaskBg, 200, 200)
	else
		print(errcode)
	end
end

function CTaskStoryChapterView.ResetChapterBgTimer(self)
	if self.m_BgTimer then
		Utils.DelTimer(self.m_BgTimer)
		self.m_BgTimer = nil			
	end
end

--结束的倒计时
function CTaskStoryChapterView.SetChapterEndTime(self)
	self:ResetChapterEndTimer()
	local function progress()
		if not self.m_Test then
		end
		if not Utils.IsNil(self) then
			self:CloseView()
		end

		return false
	end	

	self.m_EndTimer = Utils.AddTimer(progress, 1, define.Task.Time.ChapterEndCloseViewDelayTime)	
end

function CTaskStoryChapterView.ResetChapterEndTimer(self)
	if self.m_EndTimer then
		Utils.DelTimer(self.m_EndTimer)
		self.m_EndTimer = nil			
	end
end

-------------------以下是点击事件--------------

function CTaskStoryChapterView.OnClickSkipChapter(self)
	if not self.m_IsSkiped then
		--结束章节图片的倒计时
		self:ResetChapterBgTimer()

		local maxindex = #g_TaskCtrl:GetChapterBgList()[g_TaskCtrl.m_TaskCurChapter]
		local path = "Texture/Minimap/"..g_TaskCtrl:GetChapterBgList()[g_TaskCtrl.m_TaskCurChapter][maxindex]..".jpg"
		g_ResCtrl:LoadAsync(path, callback(self, "SetTexture"))
	end

	self:ExecuteEndEvent()
end

function CTaskStoryChapterView.ExecuteEndEvent(self)
	if not self.m_IsSkiped then
		self.m_SkipBtn:GetComponent(classtype.BoxCollider).enabled = false
		
		if self.m_DelayTimer1 then
			Utils.DelTimer(self.m_DelayTimer1)
			self.m_DelayTimer1 = nil			
		end
		local function delay()
			if Utils.IsNil(self) then
				return false
			end
			self:SetBgHideEffect(self.m_ChapterBg)
			self:SetBgHideEffect(self.m_SkipBtn)
			return false
		end
		self.m_DelayTimer1 = Utils.AddTimer(delay, 0, define.Task.Time.ChapterEndEffectShowDelayTime)

		self:SetChapterEndTime()
	end
	self.m_IsSkiped = true
end

return CTaskStoryChapterView