local CYibaoMainView = class("CYibaoMainView", CViewBase)

function CYibaoMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/YiBao/YibaoMainView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CYibaoMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TitleLbl = self:NewUI(2, CLabel)
	self.m_MySelfPart = self:NewPage(3, CYibaoMySelfPart)
	self.m_OtherPart = self:NewPage(4, CYibaoOtherPart)
	
	self:InitContent()
end

function CYibaoMainView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))

	g_YibaoCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

--协议通知返回
function CYibaoMainView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Yibao.Event.RefreshUI then
		local mask = oCtrl.m_EventData.mask
		local owner = oCtrl.m_EventData.owner --面板属于哪个玩家(pid)
		local create_day = oCtrl.m_EventData.create_day --异宝创建日期（上行时使用）
		local seek_gather_tasks = oCtrl.m_EventData.seek_gather_tasks --异宝寻物的已用求助的任务id
		local seek_gather_max = oCtrl.m_EventData.seek_gather_max --异宝寻物的最大求助次数
		local done_yibao_info = oCtrl.m_EventData.done_yibao_info --已经完成的异宝任务信息(因为此任务已经删除，但要显示在UI)
		local doing_yibao_info = oCtrl.m_EventData.doing_yibao_info --正在进行的异宝任务信息(因为这个面板可以显示其他玩家的任务状况，自己看自己则不需要此数据)
		local main_yibao_info = oCtrl.m_EventData.main_yibao_info --主任务信息，主要是预览奖励

		if owner == g_AttrCtrl.pid then
			self:ShowMySelfPart()
			self.m_MySelfPart:RefreshUI(oCtrl.m_EventData)
		else
			self:ShowOtherPart()
			self.m_OtherPart:RefreshUI(oCtrl.m_EventData)
		end
	end
end

function CYibaoMainView.SetContent(self, pbdata)
	local mask = pbdata.mask
	local owner = pbdata.owner --面板属于哪个玩家(pid)
	local create_day = pbdata.create_day --异宝创建日期（上行时使用）
	local seek_gather_tasks = pbdata.seek_gather_tasks --异宝寻物的已用求助的任务id
	local seek_gather_max = pbdata.seek_gather_max --异宝寻物的最大求助次数
	local done_yibao_info = pbdata.done_yibao_info --已经完成的异宝任务信息(因为此任务已经删除，但要显示在UI)
	local doing_yibao_info = pbdata.doing_yibao_info --正在进行的异宝任务信息(因为这个面板可以显示其他玩家的任务状况，自己看自己则不需要此数据)
	local main_yibao_info = pbdata.main_yibao_info --主任务信息，主要是预览奖励

	if owner == g_AttrCtrl.pid then
		self:ShowMySelfPart()
		self.m_MySelfPart:RefreshUI(pbdata)
	else
		self:ShowOtherPart()	
		self.m_OtherPart:RefreshUI(pbdata)
		self.m_OtherPart:SetClickData()
	end
end

function CYibaoMainView.ShowMySelfPart(self)
	self:ShowSubPage(self.m_MySelfPart)
end

function CYibaoMainView.ShowOtherPart(self)
	self:ShowSubPage(self.m_OtherPart)
end

return CYibaoMainView