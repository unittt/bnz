local CTaskCommitSummonView = class("CTaskCommitSummonView", CViewBase)

function CTaskCommitSummonView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Notify/CommitItemView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "ClickOut"
end

function CTaskCommitSummonView.OnCreateView(self)
	self.m_Sessionidx = ""
	self.m_SumData = nil

	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_CommitBtn = self:NewUI(2, CButton)
	self.m_TitleLabel = self:NewUI(3, CLabel)
	self.m_ItemBoxSry = self:NewUI(4, CScrollView)
	self.m_BoxGrid = self:NewUI(5, CGrid)
	self.m_CloneCommitSumBox = self:NewUI(6, CCommitSummonBox)

	CTaskCommitItemView:CloseView()

	self:InitContent()
end

function CTaskCommitSummonView.InitContent(self)
	self.m_CloneCommitSumBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CommitBtn:AddUIEvent("click", callback(self, "OnCommitBtn"))
end

function CTaskCommitSummonView.SetContent(self, sessionidx, oTask)
	self.m_Sessionidx = sessionidx
	self.m_TitleLabel:SetText("任务提交宠物")
	local sumidList, tNeedSum = CTaskHelp.GetTaskFindSummonDic(oTask)
	self.m_NeedSum = tNeedSum
	local sumList
	if oTask:GetAllowBB() then
		sumList = CTaskHelp.GetSummonDicBySidList(sumidList, true)
	else
		sumList = CTaskHelp.GetSummonDicBySidList(sumidList)
	end
	self:InitSumBoxGrid(sumList)
end

function CTaskCommitSummonView.InitSumBoxGrid(self, sumList)
	if not sumList then
		return
	end
	-- 获取可提交宠物数据
	local gridID = self.m_BoxGrid:GetInstanceID()

	--选中提交宠物
	if next(sumList) then
		self.m_SumData = sumList[1]
	end

	self.m_BoxGrid:Clear()
	for _,v in ipairs(sumList) do
		local oSumBox = self.m_CloneCommitSumBox:Clone(function ()
			self.m_SumData = v
		end)
		oSumBox:SetGroup(gridID)
		self.m_BoxGrid:AddChild(oSumBox)
		oSumBox:SetCommitSumInfo(v)
		oSumBox:SetActive(true)
		if v == self.m_SumData then
			oSumBox:ForceSelected(true)
		end
	end
end

function CTaskCommitSummonView.OnCommitBtn(self)
	if self.m_SumData then
		if self.m_SumData.type == 1 then
			local commitList = {self.m_SumData.id}
			netother.C2GSCallback(self.m_Sessionidx, nil, nil, commitList)
			self:CloseView()
		else
			local windowConfirmInfo = {
				msg = data.textdata.TASK[63035].content,
				title = "提交宠物",
				okCallback = function ()
					local commitList = {self.m_SumData.id}
					netother.C2GSCallback(self.m_Sessionidx, nil, nil, commitList)
					self:CloseView()
				end,
				okStr = "确定",
				cancelStr = "取消",
			}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
		end
	else
		g_NotifyCtrl:FloatMsg("请选择提交宠物")
	end
end

function CTaskCommitSummonView.OnHideView(self)
	g_TaskCtrl.m_HelpOtherTaskData = {}
end

return CTaskCommitSummonView