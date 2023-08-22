local CSuperRebateView = class("CSuperRebateView", CViewBase)

function CSuperRebateView.ctor(self, cb)
	-- body
	CViewBase.ctor(self, "UI/Superrebate/SuperRebateView.prefab", cb)
	self.m_ExtendClose = "Shelter"
	self.m_GroupName = "main"
	self.m_DepthType = "Dialog"
	-- 是否正在旋转中
	self.m_IsRotating = false
	self.m_IconList = {}
	self.m_Timer = nil 
end

function CSuperRebateView.OnCreateView(self)
	-- body
	-- self.m_TitleLab    =   self:NewUI(1, CLabel)
	self.m_LeftTimeLab =   self:NewUI(1, CLabel)
	self.m_TurnNode    =   self:NewUI(3, CBox)
	self.m_SelectedBG  =   self:NewUI(4, CWidget)
	self.m_RebateBtn   =   self:NewUI(5, CWidget)
	self.m_RebateSpr   =   self:NewUI(6, CSprite)
	self.m_IconList[1] =   self:NewUI(7, CWidget)
	self.m_IconList[2] =   self:NewUI(8, CWidget)
	self.m_IconList[3] =   self:NewUI(9, CWidget)
	self.m_IconList[4] =   self:NewUI(10, CWidget)
	self.m_IconList[5] =   self:NewUI(11, CWidget)
	self.m_IconList[6] =   self:NewUI(12, CWidget)
	self.m_HDTimeLab   =   self:NewUI(13, CLabel)
	self.m_Tipbtn      =   self:NewUI(14, CButton)
	self.m_Table       =   self:NewUI(15, CTable)
	self.m_LableClone  =   self:NewUI(16, CLabel)
	self.m_ReceiveBtn  =   self:NewUI(17, CButton)
	self.m_ReceiveLab  =   self:NewUI(18, CLabel)
	self.m_ClosBtn    		   =   self:NewUI(19, CButton)
	self.m_TurnNodeRedPoint    =   self:NewUI(20, CSprite)
	self.m_ReceiveRedPoint     =   self:NewUI(21, CSprite)
	
	self:InitEvent()
	self:InitContent()
end

function CSuperRebateView.InitEvent(self)
	self:InitBoxSprite()
	self.m_RebateBtn:AddUIEvent("click", callback(self, "OnRebateBtnClick"))
	self.m_ReceiveBtn:AddUIEvent("click", callback(self, "OnReceiveBtnClick"))
	self.m_Tipbtn:AddUIEvent("click", callback(self, "OnTipBtnClick"))
	self.m_ClosBtn:AddUIEvent("click", callback(self, "OnClose"))
	g_SuperRebateCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CSuperRebateView.InitBoxSprite(self)
	local SprDict = {[1] = "h7_font_12bei", [3] = "h7_font_15bei"}
	for k, v in pairs(SprDict) do
		local mulSpr = self.m_IconList[k]:Find("mul").gameObject
		if mulSpr then
			local sprite = mulSpr:GetComponent(classtype.UISprite)
			sprite.spriteName = v
		end
	end
end

function CSuperRebateView.InitContent(self)
	-- body
	if g_SuperRebateCtrl.m_RebateMul and g_SuperRebateCtrl.m_RebateMul > 0 then
		 local degree = self:GetDegreeByIndex(g_SuperRebateCtrl.m_RebateMul)
		self.m_TurnNode:SetEulerAngles(Vector3.New(0,0,degree))
		self.m_SelectedBG:SetActive(true)
		self.m_RebateSpr:SetSpriteName("h7_chongzhi_5") -- 充值
	else
		self.m_SelectedBG:SetActive(false)
		self.m_TurnNode:SetEulerAngles(Vector3.New(0,0,0))
		self.m_RebateSpr:SetSpriteName("h7_choujiang") -- 抽奖
	end

	self.m_TurnNodeRedPoint:SetActive(g_SuperRebateCtrl:LotteryBtnHasRedPoint())

	self.m_ReceiveRedPoint:SetActive(g_SuperRebateCtrl:HasReceiveBtnRedPoint())

	self.m_LeftTimeLab:SetText(g_SuperRebateCtrl.m_MaxLotteryCnt - g_SuperRebateCtrl.m_HasLotteryCnt)
	self.m_ReceiveLab:SetText(g_SuperRebateCtrl.m_GoldCoinValue)
    
	self:RefreshTable()
	self:Calculatetime()
end

function CSuperRebateView.Calculatetime(self)
	-- body
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	local endtime = g_SuperRebateCtrl.m_SuperrebateTime  - g_TimeCtrl:GetTimeS() 
	-- local function timer()
	-- 	if Utils.IsNil(self) then
	-- 		return 
	-- 	end

	-- 	local day = math.floor(endtime/24/3600)
 --        local hours = math.modf(endtime/3600) - day*24
 --        local minutes = math.floor ((endtime%3600)/60)
 --        local seconds = endtime % 60
 --        endtime = endtime - 1
 --        if endtime >= 0 then
 --        	local str = "%d天%d小时%d分钟"
	-- 		self.m_HDTimeLab:SetText(string.format(str,day,hours,minutes))
 --            return true
 --        else
 --            return false
 --        end
 --    end

	-- self.m_Timer = Utils.AddTimer(timer, 1, 0.2)
	self.m_HDTimeLab:SetText(g_TimeCtrl:GetLeftTimeDHM(endtime))
end

function CSuperRebateView.RefreshTable(self)
	-- body
	local mulinfo = data.superrebatedata.REBATE
	local strinfo = data.superrebatedata.TEXT[9001].content
	self.m_Table:Clear()
	local tablelist = g_SuperRebateCtrl.m_RecordList
	local len = #tablelist
	local templist = {}
	if len> 10 then
		for i=len,len -10,-1  do
			local v = tablelist[i]
			table.insert(templist, v)
		end
	else
		templist = tablelist
	end
	for i=1,#templist do
		local lab = self.m_Table:GetChild(i)
		local v = tablelist[i]
		if not lab then
			lab = self.m_LableClone:Clone()
			lab:SetActive(true)
			self.m_Table:AddChild(lab)
			local mul = mulinfo[v.value].show_ratio
			local str = string.format(strinfo, v.name, mul)
			lab:SetText(str)
		end
	end
	self.m_Table:Reposition()
end

function CSuperRebateView.OnRebateBtnClick(self)
	-- body
	if g_SuperRebateCtrl.m_RebateMul > 0 then -- 前往充值
		if self.m_IsRotating then 
	        g_NotifyCtrl:FloatMsg(data.superrebatedata.TEXT[9003].content)
	        return
	    end
		CNpcShopMainView:ShowView(function(oView)
			-- body
			oView:ShowSubPageByIndex(3)
		end)
	else
		if self.m_IsRotating then 
	        g_NotifyCtrl:FloatMsg(data.superrebatedata.TEXT[9003].content)
	        return
	    end
	    nethuodong.C2GSSuperRebateLottery()
	end
end


function CSuperRebateView.OnReceiveBtnClick(self)
	-- body
	if g_SuperRebateCtrl.m_GoldCoinValue and g_SuperRebateCtrl.m_GoldCoinValue>0  then
		nethuodong.C2GSSuperRebateGetReward()
	else
		g_NotifyCtrl:FloatMsg(data.superrebatedata.TEXT[1005].content)
	end
end

function CSuperRebateView.OnTipBtnClick(self)
	-- body
	local Id = 13001
	if data.instructiondata.DESC[Id]~= nil then
		local Content = {
		title = data.instructiondata.DESC[Id].title,
	 	desc = data.instructiondata.DESC[Id].desc
		}
		g_WindowTipCtrl:SetWindowInstructionInfo(Content)
	end
end

function CSuperRebateView.OnClose(self)
	-- body
	if not self.m_IsRotating then
		self:CloseView()
		if g_HotTopicCtrl.m_SignCallback then
        	g_HotTopicCtrl:m_SignCallback()
        	g_HotTopicCtrl.m_SignCallback = nil
    	end
	end
end

function CSuperRebateView.OnCtrlEvent(self, oCtrl)
	-- body
	if oCtrl.m_EventID == define.SuperRebate.Event.RefreshSuperRebateMul then -- 旋转转盘
		self:StartRotate()
	elseif oCtrl.m_EventID == define.SuperRebate.Event.SuperRebateEnd then
		self:CloseView()
	elseif oCtrl.m_EventID == define.SuperRebate.Event.RereshSuperRebateValue then
		self:RereshValue(oCtrl)
	elseif oCtrl.m_EventID == define.SuperRebate.Event.RecordList then
		self:RefreshTable()
	elseif oCtrl.m_EventID == define.SuperRebate.Event.SuperRebateStart  then
		self:Calculatetime()
	end
end

function CSuperRebateView.StartRotate(self)
	-- body
	self.m_SelectedBG:SetActive(false)
	local rand = g_SuperRebateCtrl.m_RebateMul
    local degree = self:GetDegreeByIndex(rand)
    local tween = DOTween.DORotate(self.m_TurnNode.m_Transform, Vector3.New(0, 0, degree + (-360 *2)), 2, 1)
    self.m_IsRotating = true
    local mulinfo = data.superrebatedata.REBATE
	local showmul = mulinfo[rand].show_ratio
	local truemul = mulinfo[rand].trueratio
	local stgr = data.superrebatedata.TEXT[9002].content
    local function onEnd()
    	self:InitContent()
        self.m_IsRotating = false
        self.m_SelectedBG:SetActive(true)
        local windowConfirmInfo = {
        	color = Color.RGBAToColor("FFFFFFFF"),
        	title = "超级返利",
            msg = string.format(stgr, showmul, truemul),
            pivot = enum.UIWidget.Pivot.Center,
            okCallback =  function() 
                              CNpcShopMainView:ShowView(function(oView)
								-- body
								oView:ShowSubPageByIndex(3)
							end)
	                    end ,
            }
        g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
    end
    DOTween.OnComplete(tween, onEnd)
end

function CSuperRebateView.GetDegreeByIndex(self, index)   
    local list = { [1]=-34.4,[2]= -95.7,[3]=-156.9,[4]=144.4,[5]=85.1,[6]=25.1}
    return list[index]
end

function CSuperRebateView.RereshValue(self, oCtrl)
	-- body
	self.m_LeftTimeLab:SetText(oCtrl.m_MaxLotteryCnt - oCtrl.m_HasLotteryCnt)
	self.m_ReceiveLab:SetText(oCtrl.m_GoldCoinValue)
	self.m_TurnNodeRedPoint:SetActive(g_SuperRebateCtrl:LotteryBtnHasRedPoint())
	self.m_ReceiveRedPoint:SetActive(g_SuperRebateCtrl:HasReceiveBtnRedPoint())
	if g_SuperRebateCtrl.m_RebateMul and g_SuperRebateCtrl.m_RebateMul > 0 then
		 local degree = self:GetDegreeByIndex(g_SuperRebateCtrl.m_RebateMul)
		self.m_TurnNode:SetEulerAngles(Vector3.New(0,0,degree))
		self.m_SelectedBG:SetActive(true)
		self.m_RebateSpr:SetSpriteName("h7_chongzhi_5") -- 充值
	else
		self.m_SelectedBG:SetActive(false)
		self.m_TurnNode:SetEulerAngles(Vector3.New(0,0,0))
		self.m_RebateSpr:SetSpriteName("h7_choujiang") -- 抽奖
	end

end

return CSuperRebateView