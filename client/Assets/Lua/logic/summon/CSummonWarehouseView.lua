local CSummonWarehouseView = class("CSummonWarehouseView", CViewBase)

function CSummonWarehouseView.ctor(self, cb)
	-- body
	CViewBase.ctor(self, "UI/Summon/SummonWarehouseView.prefab", cb)
	self.m_GroupName = "main"
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CSummonWarehouseView.OnCreateView(self)
	-- body
	self.m_CloseBtn       = self:NewUI(1, CButton)
	self.m_TakeOutGrid    = self:NewUI(2, CGrid)
	self.m_PopSummonBox   = self:NewUI(3, CSummonWarehouseBox)
	self.m_PutInGrid      = self:NewUI(4, CGrid)
	self.m_PushSummonBox  = self:NewUI(5, CSummonWarehouseBox)
	self.m_PopBtn         = self:NewUI(6, CButton)
	self.m_PushBtn        = self:NewUI(7, CButton)
	self:InitContent()
end

function CSummonWarehouseView.InitContent(self)
	-- body
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_PopBtn:AddUIEvent("click", callback(self, "OnTakeOutSumBtn")) --弹出
	self.m_PushBtn:AddUIEvent("click", callback(self, "OnPutInSumBtn"))  --推入
	g_SummonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnSumCtrl"))
end


function CSummonWarehouseView.SetCKSummonData(self, summondata, extsize)
	-- body
	-- local config = data.globaldata.SUMMONCK[1]
	--初始化 左侧
	local leftlist = self.m_TakeOutGrid:GetChildList()
	for i=1,extsize+1 do
		local obox = nil
		if i>#leftlist then
			obox = self.m_PopSummonBox:Clone()
			self.m_TakeOutGrid:AddChild(obox)
			obox:SetGroup(self.m_TakeOutGrid:GetInstanceID())
			if i == extsize+1 and extsize ~= 10 then
				obox:SetSummonBoxData(nil, true)
			else
				obox:SetSummonBoxData(summondata[i])
			end
			obox:SetActive(true)
		else
			obox = leftlist[i]
		end
	end

	if extsize+1 >10 then
		self.m_TakeOutGrid:GetChild(extsize+1):SetActive(false)
	end
	self.m_PopSummonBox:SetActive(false)
	self.m_TakeOutGrid:Reposition()

	--初始化 右侧
	local hadSummonInfo = {}
	for i,v in pairs(g_SummonCtrl.m_SummonsDic) do
		table.insert(hadSummonInfo, v)
	end
	local rightlist = self.m_PutInGrid:GetChildList()
	
	for i=1,g_SummonCtrl.m_SummonMax  do
		local obox = nil
		if i>#leftlist then
			obox = self.m_PushSummonBox:Clone()
			self.m_PutInGrid:AddChild(obox)
			obox:SetGroup(self.m_TakeOutGrid:GetInstanceID())
			obox:SetSummonBoxData(hadSummonInfo[i])
			obox:SetActive(true)
		else
			obox = leftlist[i]
		end
	end
	self.m_PushSummonBox:SetActive(false)
	self.m_PutInGrid:Reposition()
end

function CSummonWarehouseView.OnSumCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.Summon.Event.AddCKSummon then 

		g_NotifyCtrl:FloatMsg("已将#G"..oCtrl.m_EventData.name.."#n放入宠物仓库")
		g_SummonCtrl.m_CKChooseSum = nil
		self:RefreshGrid()

	elseif oCtrl.m_EventID == define.Summon.Event.DelCKSummon then

		g_NotifyCtrl:FloatMsg("已将#G"..oCtrl.m_EventData.name.."#n取出仓库")
		g_SummonCtrl.m_CKChooseSum = nil

	elseif  oCtrl.m_EventID == define.Summon.Event.AddSummon then

		self:RefreshGrid()

	elseif oCtrl.m_EventID == define.Summon.Event.AddCkExtendSize then --增加宠物仓库上限

	 	g_NotifyCtrl:FloatMsg("已将宠物仓库上限提升至"..oCtrl.m_EventData.."个")
		self:RefreshGrid()

	elseif oCtrl.m_EventID == define.Summon.Event.AddExtendSize then --增加宠物携带上限
	
 		self:RefreshGrid()
	end
end

function CSummonWarehouseView.RefreshGrid(self)
	-- body
	self.m_PutInGrid:Clear()
	self.m_TakeOutGrid:Clear()
	self:SetCKSummonData(g_SummonCtrl.m_CKSummondata, g_SummonCtrl.m_CKExtSize)
end

function CSummonWarehouseView.OnTakeOutSumBtn(self) --取出
	-- body
	if g_SummonCtrl.m_CKChooseSum and g_SummonCtrl.m_CKChooseSum.id then
		netsummon.C2GSChangeCkSummon(g_SummonCtrl.m_CKChooseSum.id)
	else
		g_NotifyCtrl:FloatMsg("请选择一个要取出的宠物")
	end
end

function CSummonWarehouseView.OnPutInSumBtn(self) --存入
	-- body
	if g_SummonCtrl.m_CKChooseSum and g_SummonCtrl.m_CKChooseSum.id then
		if g_SummonCtrl:GetSummonAmount() == 1 then
        	g_NotifyCtrl:FloatMsg("只携带#G1个#n宠物时不能进行寄存")
		elseif g_SummonCtrl.m_CKChooseSum.id ~= g_SummonCtrl.m_FightId then
			netsummon.C2GSAddCkSummon(g_SummonCtrl.m_CKChooseSum.id)
		else
			g_NotifyCtrl:FloatMsg("出战宠物无法寄存仓库，请切换至休息状态")
		end
	else
		g_NotifyCtrl:FloatMsg("请选择一个要放入仓库的宠物")
	end
end

return CSummonWarehouseView