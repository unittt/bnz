local CTaskStoryPieceView = class("CTaskStoryPieceView", CViewBase)

function CTaskStoryPieceView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Task/TaskStoryPieceView.prefab", cb)
	--界面设置
	self.m_DepthType = "Fourth"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CTaskStoryPieceView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	-- self.m_Grid = self:NewUI(2, CGrid)

	self.m_ChapterList = {}
	for i = 2, 8 do
		local oGrid = self:NewUI(i, CGrid)
		local function init(obj, idx)
			local oTex = CTexture.New(obj)
			return oTex
		end
		oGrid:InitChild(init)
		table.insert(self.m_ChapterList, oGrid)
	end

	-- local function init(obj, idx)
	-- 	local oTex = CTexture.New(obj)
	-- 	return oTex
	-- end
	-- self.m_Grid:InitChild(init)
	
	self:InitContent()
end

function CTaskStoryPieceView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CTaskStoryPieceView.RefreshUI(self, oChapterData)
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

	local texList = self.m_ChapterList[oChapterData.chapter]:GetChildList() or {}
	for k,v in ipairs(texList) do
		v:SetGrey(true)
		v:SetActive(false)
	end
	for k,v in pairs(oChapterData.pieces) do
		texList[self:GetEachIndex(v)]:SetGrey(false)
		texList[self:GetEachIndex(v)]:SetActive(true)
	end

	if table.count(oChapterData.pieces) < data.taskdata.STORYCHAPTER[oChapterData.chapter].proceeds then
		self.m_ChapterList[oChapterData.chapter]:SetLocalPos(Vector3.New(-218, 237, 0))
		self.m_ChapterList[oChapterData.chapter]:SetCellSize(145, 198)
		self.m_ChapterList[oChapterData.chapter]:Reposition()
	else
		self.m_ChapterList[oChapterData.chapter]:SetLocalPos(Vector3.New(-215, 237, 0))
		self.m_ChapterList[oChapterData.chapter]:SetCellSize(143, 196)
		self.m_ChapterList[oChapterData.chapter]:Reposition()
	end
end

function CTaskStoryPieceView.SetPieceTexture(self, oTex, prefab, errcode)
	if prefab then
		oTex:SetMainTexture(prefab)
	end
end

--以后要根据需求修改
-- function CTaskStoryPieceView.GetPieceTexName(self, oChapterId)
-- 	if oChapterId == 1 then
-- 		return "h7_bei_"
-- 	elseif oChapterId == 2 then
-- 		return "h7_nu_"
-- 	elseif oChapterId == 3 then
-- 		return "h7_xi_"
-- 	elseif oChapterId == 4 then
-- 		return "h7_si_"
-- 	else
-- 		return "h7_bei_"
-- 	end
-- end

function CTaskStoryPieceView.GetEachIndex(self, oIndex)
	if oIndex == 1 then
		return 4
	elseif oIndex == 2 then
		return 8
	elseif oIndex == 3 then
		return 3
	elseif oIndex == 4 then
		return 7
	elseif oIndex == 5 then
		return 2
	elseif oIndex == 6 then
		return 6
	elseif oIndex == 7 then
		return 1
	elseif oIndex == 8 then
		return 5
	else
		return 4
	end
end

function CTaskStoryPieceView.SetDelayClose(self, oTime)
	if self.m_DelayTimer then
		Utils.DelTimer(self.m_DelayTimer)
		self.m_DelayTimer = nil			
	end
	local function progress()
		if Utils.IsNil(self) then
			return false
		end
		self:CloseView()
		return false
	end	

	self.m_DelayTimer = Utils.AddTimer(progress, 0, oTime)
end

function CTaskStoryPieceView.OnHideView(self)
	g_TaskCtrl.m_IsShowingPieceView = false
	for k,v in pairs(g_TaskCtrl.m_PieceShowingEndCb) do
		if v then v() end
	end
	g_TaskCtrl.m_PieceShowingEndCb = {}
end

return CTaskStoryPieceView