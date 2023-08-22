local CBaikeView = class("CBaikeView", CViewBase)

function CBaikeView.ctor(self, cb)
	CViewBase.ctor(self,"UI/Schedule/QuestionView.prefab", cb)
	self.m_DepthType = "Fourth"
	self.m_ExtendClose = "Shelter"
    self.m_GroupName = "main"
    
    self.m_Lock1 = false
	self.m_Lock2 = false
	self.m_AnswerList ={}
	self.m_CurrQuestionID = nil
	self.m_QuestionCount = 0
	self.m_DelayTimer = nil
	self.m_EffectTimer = nil
	self.m_lineList = {}
	self.m_BonfireEffect = nil
	self.m_SendSign = false
	self.m_SignLock  = {}
	self.m_RandomList = {}
	self.m_posList ={}
	self.m_CanDropLine = false
	self.m_FirstLine = nil
	self.m_QuestionType = nil
	self.m_ExitLineBox = {} 
	self.m_NodeList = {}
	self.m_oUICamera = g_CameraCtrl:GetUICamera()
end

function CBaikeView.OnCreateView(self)
	-- body
	self.m_CurrTurnBtn = self:NewUI(1, CButton)
	self.m_WeekTurnBtn = self:NewUI(2, CButton)
	self.m_ScoreRankLabel = self:NewUI(3, CLabel)
	self.m_ScoreLabel  = self:NewUI(4, CLabel)
	self.m_RankScroll  = self:NewUI(5, CScrollView)
	self.m_RankGrid = self:NewUI(6 ,CGrid)
	self.m_RankCellClone  = self:NewUI(7, CBox)
	self.m_QuestionLabel = self:NewUI(8, CLabel)
	self.m_TipBtn = self:NewUI(9, CButton)
	self.m_CloseBtn = self:NewUI(10, CButton)
	self.m_CountLabel  = self:NewUI(11, CLabel)
	self.m_TimerLabel = self:NewUI(12, CLabel)
	self.m_Node1 = self:NewUI(13, CBox)
	table.insert(self.m_NodeList,  self.m_Node1)
	self.m_BtnGrid = self:NewUI(14, CGrid)
	self.m_btncell = self:NewUI(15, CBox)
	self.m_Node2 = self:NewUI(16, CBox)
	table.insert(self.m_NodeList,  self.m_Node2)
	self.m_Sign1 = self:NewUI(17, CBox)
	self.m_Sign2 = self:NewUI(18, CBox)
	self.m_DragGrid = self:NewUI(19, CGrid)
	self.m_DragBoxClone = self:NewUI(20, CBox)
	self.m_Node3 = self:NewUI(21, CBox)
	table.insert(self.m_NodeList,  self.m_Node3)
	self.m_LineGrid = self:NewUI(22, CGrid)
	self.m_LineClone = self:NewUI(23, CBox)
	self.m_Sign1.m_TipSpr = self.m_Sign1:NewUI(1, CSprite)
	self.m_Sign1.m_RightSpr = self.m_Sign1:NewUI(2, CSprite)
	self.m_Sign2.m_TipSpr = self.m_Sign2:NewUI(1, CSprite)
	self.m_Sign2.m_RightSpr = self.m_Sign2:NewUI(2, CSprite)
	self.m_FinishInfo = self:NewUI(26, CSprite)
	self:IninContent()
end

function CBaikeView.IninContent(self)
	self.m_LineClone:SetActive(false)
	self.m_RankCellClone:SetActive(false)
	self.m_DragBoxClone:SetActive(false)

	self.m_CurrTurnBtn:AddUIEvent("click", callback(self,"OnCurrTurn", 1))
	self.m_WeekTurnBtn:AddUIEvent("click", callback(self,"OnWeekTurn", 2))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_TipBtn:AddUIEvent("click", callback(self, "OnTipEvent"))
	g_BaikeCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnRefeshUI"))
	g_ScheduleCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self ,"OnScheduleEnd"))

	netopenui.C2GSOpenInterface(2)

	local dConfig = data.huodongdata.BAIKE
	self.m_QuestionCount = dConfig[1].question

	if g_BaikeCtrl.m_dataList then
		self:OnRefeshMianInfo(g_BaikeCtrl.m_dataList)
	end

	if g_BaikeCtrl:GetRankPage() == 1 then
		self.m_CurrTurnBtn:SetSelected(true)
		self:RefreshRank(g_BaikeCtrl.m_CurrRankData)
	end

	if g_BaikeCtrl.m_BaikeFinishSign then
		self.m_FinishInfo:SetActive(true)
	else
		self.m_FinishInfo:SetActive(false)
	end
end

function CBaikeView.OnRefeshMianInfo(self, pbdata)
	g_BaikeCtrl.m_RequestNext = false
	self.m_CurrQuestionID = pbdata.id
	self.m_RingNum = pbdata.ring 
	self.m_QuestionType = pbdata.type
	self.m_AnswerCount = pbdata.answer_cnt
	--self.m_CountLabel:SetText("第"..self.m_RingNum.."/10题")
	self.m_CountLabel:SetText(string.format("第%d/%d题", self.m_RingNum, self.m_QuestionCount))
	self.m_QuestionLabel:SetText(pbdata.content)

	if pbdata.type == 1 then
		self.m_Node1:SetActive(true)
		self:ShowQuestionInfo1(pbdata)
	elseif  pbdata.type == 2 then
		self.m_Node2:SetActive(true)
		self:ShowQuestionInfo2(pbdata)

	elseif pbdata.type == 3 then
		self.m_Node3:SetActive(true)
		self:ShowQuestionInfo3(pbdata)
	end
end

function CBaikeView.OnRefeshUI(self, oCtrl)
	if oCtrl.m_EventID == define.BaiKe.Event.RefreshBaike then
		self:OnRefeshMianInfo(oCtrl.m_dataList)
	elseif oCtrl.m_EventID == define.BaiKe.Event.RefreshBaikeAnswer then
		if self.m_QuestionType == 1 then
			self:ShowRightInfo1(oCtrl.m_info, oCtrl.m_data)
		elseif self.m_QuestionType == 2 then 
			self:ShowRightInfo2(oCtrl.m_info , oCtrl.m_data)
		elseif self.m_QuestionType == 3 then
			self:ShowRightInfo3(oCtrl.m_info , oCtrl.m_data)
		end
	elseif  oCtrl.m_EventID == define.BaiKe.Event.RefreshBaikeCurrRank then
		if g_BaikeCtrl:GetRankPage() == 1 then
			self:RefreshRank(oCtrl.m_CurrRankData)
		end
	elseif oCtrl.m_EventID == define.BaiKe.Event.RefreshBaikeWeekRank then
		if g_BaikeCtrl:GetRankPage() == 2 then
			self:RefreshRank(oCtrl.m_WeekRankUnit)
		end
	elseif oCtrl.m_EventID == define.BaiKe.Event.RefreshBaikeEffect then
		self:PlayEffect()
	elseif oCtrl.m_EventID == define.BaiKe.Event.RefreshBaikeTime then
		self.m_TimerLabel:SetText(g_BaikeCtrl.m_Time.."秒")
	end
end

function CBaikeView.OnClose(self)
	g_BaikeCtrl:SetRankPage(1)
	netopenui.C2GSCloseInterface(2)
	self:CloseView()
end

function CBaikeView.OnCurrTurn(self, index)
	if g_BaikeCtrl:GetRankPage() == index then
		return 
	end
	g_BaikeCtrl:SetRankPage(index)
	self:RefreshRank(g_BaikeCtrl.m_CurrRankData)
end

function CBaikeView.OnWeekTurn(self, index)
	if g_BaikeCtrl:GetRankPage() == index then
		return 
	end
	g_BaikeCtrl:SetRankPage(index)
	g_BaikeCtrl:C2GSBaikeWeekRank()
end

function CBaikeView.RefreshRank(self, data)
	self.m_RankGrid:Clear()
	local ranklist = self.m_RankGrid:GetChildList()
	for i=1,#data do
		local cell = nil
		if i>#ranklist then
			cell = self.m_RankCellClone:Clone()
			cell:SetActive(true)
			self.m_RankGrid:AddChild(cell)
			cell:SetGroup(self.m_RankGrid:GetInstanceID())
			cell.m_score = cell:NewUI(1, CLabel)            --分数
			cell.m_name =  cell:NewUI(2, CLabel)      		--名字
		end
		if g_AttrCtrl.pid == data[i].pid then
			cell.m_score:SetText("[CA5C1AFF]"..data[i].score.."[-]")
			cell.m_name:SetText( "[CA5C1AFF]"..i.."、"..data[i].name.."[-]")
		else
			cell.m_score:SetText("[816D61FF]"..data[i].score.."[-]")
			cell.m_name:SetText("[816D61FF]"..i.."、"..data[i].name.."[-]")
		end
	end
	self.m_RankScroll:ResetPosition()
	self.m_RankGrid:Reposition()
	self:RefreshMyInfo()
end

function CBaikeView.RefreshMyInfo(self)
	if g_BaikeCtrl:GetRankPage() == 1 then --本轮
		self.m_ScoreRankLabel:SetText(g_BaikeCtrl.m_CurRank or  "榜外")
		self.m_ScoreLabel:SetText(g_BaikeCtrl.m_CurScore)
	elseif g_BaikeCtrl:GetRankPage() == 2 then--总榜
		self.m_ScoreRankLabel:SetText(g_BaikeCtrl.m_WeekRank or "榜外")
		self.m_ScoreLabel:SetText(g_BaikeCtrl.m_WeekScore) 
	end
end

function CBaikeView.OnTipEvent(self)
	local Id = define.Instruction.Config.Baike
	local  str1 = ""
	local  str2 = ""
	local function fun(data,SLV)
		-- body
		local v =nil 
		if SLV then
			v  = string.gsub(data,"SLV",g_AttrCtrl.server_grade)
		else
			v = string.gsub(data,"lv", g_AttrCtrl.grade)
		end
		local func = loadstring("return " .. v)
		local num = func()
		return num
	end

	for i ,v in ipairs(data.huodongdata.currank_reward) do
		str1 = str1.."本轮"..v.rank_list[1].."-"..v.rank_list[2].."名:经验×"
				..fun(data.rewarddata.baike_reward[v.reward].exp,false) .."   银币×"
				..fun(data.rewarddata.baike_reward[v.reward].silver,true) .."\n"
	end
	local wreward = DataTools.GetHuodongData("weekrank_reward")
	for i ,v in ipairs(wreward) do
		local link = ""
		if  v.rank_list[2] then
			link="-"..v.rank_list[2]
		end
		str2 = str2.."总榜"..v.rank_list[1]..link.."名:经验×"
				..fun(data.rewarddata.baike_reward[v.reward].exp,false) .."   银币×"
				..fun(data.rewarddata.baike_reward[v.reward].silver,true) .."  称谓-"
				..data.titledata.INFO[v.title].name .."\n"
	end
	if data.instructiondata.DESC[Id]~=nil then
		local Content = {
			title = data.instructiondata.DESC[Id].title,
			desc = data.instructiondata.DESC[Id].desc.."\n\n"..str1.."\n"..str2
		}
		g_WindowTipCtrl:SetWindowInstructionInfo(Content)
	end
	
end

function CBaikeView.PlayEffect(self)
	if self.m_EffectTimer then
		Utils.DelTimer(self.m_EffectTimer)
	end

	local path = "Effect/UI/ui_eff_0050/Prefabs/ui_eff_0050.prefab"
	local function effectDone ()
		if Utils.IsNil(self) then
			self.m_FinishEffect:Destroy()
			return false
		end

        self.m_FinishEffect:SetParent(self.m_Transform)
    	local function func()
			if Utils.IsNil(self) then
    			self.m_FinishEffect:Destroy()
    			return false
    		end
    		g_BaikeCtrl.m_FirstCloseView = false
    		self.m_FinishInfo:SetActive(true)
			return false
		end
   	 	self.m_EffectTimer = Utils.AddTimer(func, 0.1, 1.75)
	end
	self.m_FinishEffect = CEffect.New(path, self:GetLayer(), false, effectDone)
	
end

function CBaikeView.GetRandomList(self, count)
	self.m_RandomList = {}
	local randomlist = {}
	local list = {} 

	for i=1,count do
		table.insert(list, i)
	end

	for i=count,1,-1 do
		local pos = math.random(1, i) 
		table.insert(randomlist, list[pos])
		local temp = list[i]
		list[i] = list[pos]
		list[pos] = temp
	end
	self.m_RandomList = randomlist
	return randomlist
end

function CBaikeView.ShowQuestionInfo1(self, pbdata)
	local list = self.m_BtnGrid:GetChildList()
	local randomlist = self:GetRandomList(#pbdata.choices)
	local ABCD = {[1]="A.",[2]="B.",[3]="C.",[4]="D."}

	for i=1,#pbdata.choices do
		local btnbox = nil
		if i>#list then
			btnbox = self.m_btncell:Clone()
			self.m_BtnGrid:AddChild(btnbox)
			btnbox:SetGroup(self.m_BtnGrid:GetInstanceID())
			btnbox.m_btn = btnbox:NewUI(1, CButton)
			btnbox.m_label = btnbox:NewUI(2, CLabel)

			btnbox.m_btn:AddUIEvent("click", callback(self, "OnAddMsg", randomlist[i]))
		else
			btnbox = list[i]
			btnbox.m_btn:AddUIEvent("click", callback(self, "OnAddMsg", randomlist[i]))
		end
		btnbox.m_btn:SetSpriteName("h7_an_4")
		btnbox.m_label:SetText(ABCD[i]..pbdata.choices[randomlist[i]].text)
	end
	self.m_btncell:SetActive(false)
	self.m_BtnGrid:Reposition()
end

function CBaikeView.GetTime(self)
	local time = g_BaikeCtrl.m_Time
	if time > 20 then
		time = 20
	elseif time == 0 then
		time = 1
	end
	return time
end

function CBaikeView.OnAddMsg(self, OptionID)
	-- body
	if self.m_SendSign then
		return
	end

	local sign = false
	for i,v in ipairs(self.m_AnswerList) do
		if v == OptionID then
			--g_NotifyCtrl:FloatMsg("不要点击相同的答案")
			sign = true
		end
	end
	if not sign then
		table.insert(self.m_AnswerList, OptionID)
		local btnlist = self.m_BtnGrid:GetChildList()
		for i,v in ipairs(self.m_RandomList) do
			if v == OptionID then
				local btnbox = self.m_BtnGrid:GetChild(i)
				if not self.m_SendSign then
					btnbox.m_btn:SetSpriteName("h7_an_3")
				end
			end
		end
	end

	if #self.m_AnswerList == self.m_AnswerCount then
		if not  self.m_SendSign  and  self.m_CurrQuestionID > 0  then 
			table.sort(self.m_AnswerList)
			g_BaikeCtrl:C2GSBaikeChooseAnswer(self.m_CurrQuestionID, self.m_AnswerList, self:GetTime())
			g_BaikeCtrl.m_dataList = nil
			g_BaikeCtrl.m_RequestNext = true
			self.m_SendSign = true
		end
	end
end

function CBaikeView.ShowQuestionInfo2(self, pbdata)
	-- body
	local list = self.m_DragGrid:GetChildList()
	local randomlist = self:GetRandomList(#pbdata.choices)

	for i=1,#pbdata.choices do
		local dragbox = nil
		if i>#list then
			dragbox = self.m_DragBoxClone:Clone()
			dragbox:SetGroup(self.m_DragGrid:GetInstanceID())
			self.m_DragGrid:AddChild(dragbox)
			dragbox.m_label = dragbox:NewUI(1, CLabel)
			dragbox.m_icon = dragbox:NewUI(2, CSprite)
			dragbox.m_TipSpr = dragbox:NewUI(3, CSprite)
			dragbox.m_RightSpr = dragbox:NewUI(4, CSprite)
		else
			dragbox = list[i]
		end
		dragbox:SetActive(true)
		dragbox.m_icon:AddUIEvent("drag", callback(self, "OnDrag") )
		dragbox.m_icon:AddUIEvent("dragend", callback(self, "OnDragEnd"))
		dragbox.m_icon:AddUIEvent("dragstart", callback(self, "OnDragStart", dragbox , randomlist[i], i))

		dragbox.m_icon:EnableTouch(true)
		dragbox.m_icon:SetDepth(40)
		dragbox.m_TipSpr:SetActive(false)
		dragbox.m_RightSpr:SetActive(false)
		dragbox.m_TipSpr:SetSpriteName("h7_duile")
		dragbox.m_RightSpr:SetSpriteName("h7_gougou_1")

		dragbox.m_label:SetText(pbdata.choices[randomlist[i]].text)
		dragbox.m_icon:SetSpriteName(pbdata.choices[randomlist[i]].icon)
	end

	self.m_DragGrid:Reposition()
	self.m_posList = {}
	for i,box in ipairs(self.m_DragGrid:GetChildList()) do
		table.insert(self.m_posList, box:GetPos())
	end
end

function CBaikeView.OnDragStart(self, box, OptionID, index)
	self.m_DragBox = box 
	self.m_DragOption = OptionID
	self.m_DragBoxIdx = index
	self.m_DragBox.m_icon:SetDepth(45)
end

function CBaikeView.OnDrag(self)
	local IsUp = UnityEngine.Input.GetMouseButton(0) 
	if not IsUp then
		self.m_DragBox.m_icon:SetLocalPos(Vector3.New(0,0,0))
	else
		local Mousepos = UnityEngine.Input.mousePosition --鼠标的屏幕坐标
		local wPos = self.m_oUICamera:ScreenToWorldPoint(Mousepos)
		--local v1 =   self.m_oUICamera:WorldToScreenPoint(self.m_Sign1:GetPos())  --sign1的屏幕坐标
		self.m_DragBox.m_icon:SetPos(wPos)
		--local dis = Vector3.Distance(v1, Mousepos)
	end
end

function CBaikeView.OnDragEnd(self)
	local v1 = self.m_oUICamera:WorldToScreenPoint(self.m_Sign1:GetPos()) --sign1 的屏幕坐标
	local v2 = self.m_oUICamera:WorldToScreenPoint(self.m_Sign2:GetPos()) --sign2 的屏幕坐标
	local wPos = self.m_DragBox.m_icon:GetPos()
	local sPos = self.m_oUICamera:WorldToScreenPoint( wPos )

	if Vector3.Distance(sPos,v1)<= 40 and not self.m_Lock1 then
 		self.m_DragBox.m_icon:SetPos( self.m_Sign1:GetPos() )
 		table.insert(self.m_AnswerList, self.m_DragOption)
 		self.m_DragBox.m_kuang = self.m_DragBox:NewUI(5, CSprite)
 		self.m_DragBox.m_kuang:SetActive(false)
 		self.m_DragBox.m_icon:EnableTouch(false)
 		self.m_DragBox.m_icon:SetDepth(40)
 		local t = {}
 		t.Sign = self.m_Sign1
 		t.index = self.m_DragOption
 		self.m_Lock1 = true
 		table.insert(self.m_SignLock ,t)
 	end
 	if Vector3.Distance(sPos,v2)<= 40 and not self.m_Lock2 then
 		self.m_DragBox.m_icon:SetPos( self.m_Sign2:GetPos() )
 		table.insert(self.m_AnswerList, self.m_DragOption)
 		self.m_DragBox.m_kuang = self.m_DragBox:NewUI(5, CSprite)
 		self.m_DragBox.m_kuang:SetActive(false)
 		self.m_DragBox.m_icon:EnableTouch(false)
 		self.m_DragBox.m_icon:SetDepth(40)
 		local t = {}
 		t.Sign = self.m_Sign2
 		t.index = self.m_DragOption
 		self.m_Lock2 = true
 		table.insert(self.m_SignLock ,t)
 	end

 	if self.m_DragBox.m_icon:GetPos()~= self.m_Sign1:GetPos() and self.m_DragBox.m_icon:GetPos()~= self.m_Sign2:GetPos() then
 		self.m_DragBox.m_icon:SetPos(self.m_posList[self.m_DragBoxIdx])
 		self.m_DragBox.m_icon:EnableTouch(true)
 	end
 	if self.m_Lock2	 and self.m_Lock1 then
 		self:JudgeSpr()
 		self.m_Lock1 = false
		self.m_Lock2 = false
 	end
end

function CBaikeView.JudgeSpr(self)

	if not self.m_SendSign and self.m_CurrQuestionID > 0 then
		table.sort(self.m_AnswerList)
		g_BaikeCtrl:C2GSBaikeChooseAnswer(self.m_CurrQuestionID, self.m_AnswerList, self:GetTime())
		-- self:ceshi()
		g_BaikeCtrl.m_dataList = nil
		g_BaikeCtrl.m_RequestNext = true
		self.m_SendSign = true
	end

end

function CBaikeView.ceshi(self)
	-- body
	local data = { [1]=1,[2]=2}
	self:ShowRightInfo2(0,data)
end

function CBaikeView.ShowQuestionInfo3(self, pbdata)
	-- body
	local list = self.m_LineGrid:GetChildList()
	local randomlist = self:GetRandomList(#pbdata.choices)
	self.m_CanDropLine = true
	for i=1,#pbdata.choices do
		local box = nil
		if i>#list then
			box = self.m_LineClone:Clone()
			box:SetGroup(self.m_LineGrid:GetInstanceID())
			self.m_LineGrid:AddChild(box)
			box.m_bgspr = box:NewUI(1, CSprite)
			box.m_line = box:NewUI(2, CSprite)
			box.m_icon = box:NewUI(3, CSprite)
			box.m_label = box:NewUI(4, CLabel)
		else
			box = list[i]
		end
		box:SetActive(true)
		box.m_icon:AddUIEvent("drag", callback(self,"drag"))
		box.m_icon:AddUIEvent("dragend" ,callback(self ,"dragend"))
		box.m_icon:AddUIEvent("dragstart", callback(self,"dragstart", box, randomlist[i]))

		box.m_line:SetSize(30,16,0)
		box.m_bgspr:SetSpriteName("h7_weilian")
		box.m_icon:SetSpriteName(pbdata.choices[randomlist[i]].icon)
		box.m_label:SetText(pbdata.choices[randomlist[i]].text)
	end
	self.m_LineGrid:Reposition()
end

function CBaikeView.GetDegress(self, startPos, endPos)
	local xDelta = endPos.x - startPos.x
	local yDelta = endPos.y - startPos.y
	local iDegress
	if xDelta > 0 and yDelta > 0 then
		iDegress = -(90 - math.deg(math.atan(math.abs(yDelta/xDelta))))
	elseif xDelta > 0 and yDelta == 0 then
		iDegress = -90
	elseif xDelta > 0 and yDelta < 0 then
		iDegress = -(90 + math.deg(math.atan(math.abs(yDelta/xDelta))))
	elseif xDelta == 0 and yDelta > 0 then
		iDegress = 0
	elseif xDelta == 0 and yDelta == 0 then
		iDegress = 0
	elseif xDelta == 0 and yDelta < 0 then
		iDegress = 180
	elseif xDelta < 0 and yDelta > 0 then
		iDegress = 90 - math.deg(math.atan(math.abs(yDelta/xDelta)))
	elseif xDelta < 0 and yDelta == 0 then
		iDegress = 90
	elseif xDelta < 0 and yDelta < 0 then
		iDegress = 90 + math.deg(math.atan(math.abs(yDelta/xDelta)))
	end
	return iDegress
end

function CBaikeView.dragstart(self,  box,  OptionID)
	if not self.m_CanDropLine then
		return
	end
	if self.m_LinkStart and self.m_LinkStart~=OptionID then
		--g_NotifyCtrl:FloatMsg("请单一连线")
		return
	end
	self.m_LineBox = box 
	self.m_LinkStart = OptionID
	self.m_LineBox.m_bgspr:SetSpriteName("h7_yilian")
	self.m_LineBox.m_line:SetSpriteName("h7_zhixiang_3")
	self.m_LineBox.m_line:SetActive(true)
	if self.m_FirstLine == self.m_LineBox.m_line then
		local line = self.m_LineBox.m_line:Clone()
		line:SetParent(self.m_LineBox.m_Transform )
		self.m_LineBox.m_line = line
		self.m_LineBox.m_line:SetSize(0,0,0)
	end
end

function CBaikeView.drag(self)
	-- body
	if not self.m_CanDropLine  then
		return
	end
	local IsUp =UnityEngine.Input.GetMouseButton(0)

	if IsUp then
		local mPos = UnityEngine.Input.mousePosition
		local wPos = self.m_oUICamera:ScreenToWorldPoint(mPos)
		local lPos = self.m_LineBox.m_line:GetPos()--self.m_oUICamera:WorldToScreenPoint()
		--local deltax = (mPos.x - lPos.x)--*1024/self.screenW
		--local deltay = (mPos.y - lPos.y)--*768/self.screenH
		local deltax =(wPos.x -lPos.x) /0.002604167
		local deltay = (wPos.y -lPos.y)/0.002604167
		self.m_LineBox.m_line:SetSize(math.sqrt(deltax*deltax+deltay*deltay), 16,0)
		local angel = self:GetDegress(lPos, wPos)
		self.m_LineBox.m_line:SetLocalEulerAngles(Vector3.New(0,0,angel+90))
		local linelist = self.m_LineGrid:GetChildList()
		for i,box in ipairs(linelist) do
			local boxpos = self.m_oUICamera:WorldToScreenPoint(box:GetPos())
			if Vector3.Distance(mPos,boxpos) < 40 then
				box.m_bgspr:SetSpriteName("h7_yilian")
			else
				if self.m_LineBox ~=  box then
					box.m_bgspr:SetSpriteName("h7_weilian")
				end
			end
		end
		if #self.m_AnswerList> 0 then
			local idx1 = table.index(self.m_RandomList,self.m_AnswerList[1].link2)
			local idx2 = table.index(self.m_RandomList,self.m_AnswerList[1].link1)
			self.m_LineGrid:GetChild(idx2).m_bgspr:SetSpriteName("h7_yilian")
			self.m_LineGrid:GetChild(idx1).m_bgspr:SetSpriteName("h7_yilian")
		end
	else
		self.m_LineBox.m_line:SetLocalPos(Vector3.New(0,0,0))
		self.m_LineBox.m_line:SetActive(false)
		--printc("鼠标抬起")
	end
end

function CBaikeView.dragend(self)
	if not self.m_CanDropLine then
		return
	end
	local mPos = UnityEngine.Input.mousePosition
	local linelist = self.m_LineGrid:GetChildList()
	local sign = false
	for i,box in ipairs(linelist) do
		local boxpos = self.m_oUICamera:WorldToScreenPoint(box:GetPos())
		if self.m_LinkStart ~= self.m_RandomList[i] and  Vector3.Distance(mPos,boxpos) < 40 then
			box.m_bgspr:SetSpriteName("h7_yilian")
			local link = {link1 = self.m_LinkStart,link2 = self.m_RandomList[i] }
			if link.link1 > link.link2 then
				local temp = link.link1
				link.link1 = link.link2
				link.link2 = temp
			end
			self.m_FirstLine = self.m_LineBox.m_line
			table.insert(self.m_AnswerList, link)
			table.sort(self.m_AnswerList, function ( v1,v2 )
				-- body
				if v1~=nil and v2~=nil  then
					return v1.link1 < v2.link1
				end
			end)
			table.insert(self.m_lineList, self.m_LineBox.m_line)
			sign = true
		end
	end
	if not sign then
		-- self.m_LineBox.m_line:SetSize(0,0,0)
		self.m_LineBox.m_line:SetActive(false)
	end
	self.m_LinkStart = nil  
	if #self.m_AnswerList == self.m_AnswerCount then
		self:C2GSBaikeLinkAnswer()
		self.m_CanDropLine = false
		--self:ceshi()
	end
end


function CBaikeView.C2GSBaikeLinkAnswer(self)
	if not self.m_SendSign and self.m_CurrQuestionID > 0 then
		g_BaikeCtrl:C2GSBaikeLinkAnswer(self.m_CurrQuestionID ,self.m_AnswerList, self:GetTime())
		g_BaikeCtrl.m_dataList = nil
		g_BaikeCtrl.m_RequestNext = true
		self.m_SendSign = true
	end
end

function CBaikeView.SetSplitTime1(self)
	local function func ()
		if Utils.IsNil(self) then
			return false
		end

		local list = self.m_BtnGrid:GetChildList()
		for i,box in ipairs(list) do
			if box.m_rightspr then
				box.m_rightspr:SetSpriteName("h7_gougou_1")
				box.m_rightspr:SetActive(false)
				box.m_btn:SetSpriteName("h7_an_4")
			end
		end
		self.m_AnswerList ={}
		self.m_SendSign = false
		self.m_QuestionLabel:SetText("")
		g_BaikeCtrl:C2GSBaikeGetNextQuestion()

		self.m_Node1:SetActive(false)
		return false
	end

	if self.m_DelayTimer then
		Utils.DelTimer(self.m_DelayTimer)
	end

	self.m_DelayTimer = Utils.AddTimer(func, 1, 2)
end

function CBaikeView.SetSplitTime2(self)
	local  function func()
		if Utils.IsNil(self) then
			return 
		end

		local list = self.m_DragGrid:GetChildList()
		for i,box in ipairs(list) do
			if box.m_kuang then
			 	box.m_kuang:SetActive(true)
				box.m_icon:SetPos(box.m_kuang:GetPos())
				box.m_icon:EnableTouch(true)
			end
		end

		self.m_Sign1.m_RightSpr:SetSpriteName("h7_gougou_1")
		self.m_Sign1.m_RightSpr:SetActive(false)
		self.m_Sign1.m_TipSpr:SetSpriteName("h7_duile")
		self.m_Sign1.m_TipSpr:SetActive(false)
		self.m_Sign2.m_RightSpr:SetSpriteName("h7_gougou_1")
		self.m_Sign2.m_RightSpr:SetActive(false)
		self.m_Sign2.m_TipSpr:SetSpriteName("h7_duile")
		self.m_Sign2.m_TipSpr:SetActive(false)

		self.m_Node2:SetActive(false)
		self.m_AnswerList ={}
		self.m_SignLock ={}
		self.m_SendSign = false
		self.m_QuestionLabel:SetText("")
		g_BaikeCtrl:C2GSBaikeGetNextQuestion()
		return false
	end

	if self.m_DelayTimer then
		Utils.DelTimer(self.m_DelayTimer)
	end

	self.m_DelayTimer = Utils.AddTimer(func, 1, 2)
end

function CBaikeView.SetSplitTime3(self)
	local function func()
		if Utils.IsNil(self) then
			return 
		end

		local list = self.m_LineGrid:GetChildList()
		for i,box in ipairs(list) do
			if box.m_line then
				box.m_line:SetSize(0, 0)
				box.m_line:SetLocalEulerAngles(Vector3.zero)
			end
		end
		for i,line in ipairs(self.m_lineList) do
			line:SetActive(false)
		end

		self.m_lineList = {}
		self.m_AnswerList = {}
		self.m_QuestionLabel:SetText("")
		g_BaikeCtrl:C2GSBaikeGetNextQuestion()
		self.m_Node3:SetActive(false)
		self.m_SendSign = false
		
		return false
	end

	if 	self.m_DelayTimer then
		Utils.DelTimer(self.m_DelayTimer)
	end

	self.m_DelayTimer = Utils.AddTimer(func, 1, 2)
end

function CBaikeView.ShowRightInfo1(self, info, data)
	--printc("刷新第1种类型题目的答案")
	local list = self.m_BtnGrid:GetChildList()
	if info == 1 then

		for i,box in ipairs(list) do
			for j,k in ipairs(self.m_AnswerList) do
				if self.m_RandomList[i] == k then
					box.m_rightspr = box:NewUI(3, CSprite)
					box.m_rightspr:SetActive(true)
				end
			end
		end

	else

		for i,v in ipairs(data) do
			for j,box in ipairs(list) do
				if v == self.m_RandomList[j] then
					box.m_rightspr = box:NewUI(3, CSprite)
					box.m_rightspr:SetActive(true)
				end 
			end
		end

		for i,v in ipairs(self.m_AnswerList) do
			for j,box in ipairs(list) do
				if v == self.m_RandomList[j]  then
					box.m_rightspr = box:NewUI(3, CSprite) 
					if  not box.m_rightspr:GetActive() then
						box.m_rightspr:SetActive(true)
						box.m_rightspr:SetSpriteName("h7_chacha_1")
						box.m_btn:SetSpriteName("h7_an_5")
					end
				end
			end
		end

	end
	self:SetSplitTime1()
end

function CBaikeView.ShowRightInfo2(self, info ,data)
	--printc("刷新第2种类型题目的答案")
	for i,box in ipairs(self.m_DragGrid:GetChildList() ) do
		box.m_icon:EnableTouch(false)
	end
	if info ==1 then
		self.m_Sign1.m_RightSpr:SetActive(true)
		self.m_Sign1.m_TipSpr:SetActive(true)
		self.m_Sign2.m_RightSpr:SetActive(true)
		self.m_Sign2.m_TipSpr:SetActive(true)
	else
		for i ,v in ipairs(data) do
			for j, k in ipairs(self.m_SignLock) do
				if v == k.index then
					k.Sign.m_TipSpr:SetActive(true)
					k.Sign.m_RightSpr:SetActive(true)
				end
			end
		end

		if self.m_Sign1.m_TipSpr:GetActive() then
			self.m_Sign2.m_RightSpr:SetActive(true)
			self.m_Sign2.m_TipSpr:SetActive(true)
			self.m_Sign2.m_RightSpr:SetSpriteName("h7_chacha_1")
			self.m_Sign2.m_TipSpr:SetSpriteName("h7_cuole")
		else
			self.m_Sign1.m_RightSpr:SetActive(true)
			self.m_Sign1.m_TipSpr:SetActive(true)
			self.m_Sign1.m_RightSpr:SetSpriteName("h7_chacha_1")
			self.m_Sign1.m_TipSpr:SetSpriteName("h7_cuole")
		end

		local list = self.m_DragGrid:GetChildList()

		for i,box in ipairs(list) do
			if box.m_icon:GetLocalPos().y == 0 then
				box.m_TipSpr = box:NewUI(3, CSprite)
				box.m_TipSpr:SetActive(true)
				box.m_RightSpr = box:NewUI(4, CSprite)
				box.m_RightSpr:SetActive(true)
			end
		end
	end
	self:SetSplitTime2()
end

function CBaikeView.ShowRightInfo3(self, info, data)
	--printc("刷新第3种类型题目的答案")
	if info == 1 then
		--nothing
	else
		for i, line in ipairs(self.m_lineList) do
			line:SetSpriteName("h7_zhixiang_4")
			-- printc("线段变红。。。。")
		end

		local linelist = self.m_LineGrid:GetChildList() 
		for i,v in ipairs(data) do

			for j, k in ipairs(self.m_RandomList) do

				if v.link1 == k then

					local box1 = self.m_LineGrid:GetChild(j)

					local pos = table.index(self.m_RandomList, v.link2)

					local box2 = self.m_LineGrid:GetChild(pos)
					box2.m_bgspr:SetSpriteName("h7_yilian")
					if not box1.m_line then
						box1.m_line = box1:NewUI(2, CSprite)
					end
					local line = box1.m_line:Clone()
					line:SetActive(true)
					table.insert(self.m_lineList, line)
					local pos1 = box1:GetPos()
					local pos2 = box2:GetPos()
					local x =(pos1.x -pos2.x) /0.002604167
					local y = (pos1.y -pos2.y)/0.002604167
					line:SetSize(math.sqrt(x*x+y*y),16,0)
					local angel = self:GetDegress(pos1,pos2)
					line:SetLocalEulerAngles(Vector3.New(0,0,angel+90))
					line:SetSpriteName("h7_zhixiang_3")

					line:SetParent(box1.m_Transform)
					-- printc("新生成一条线段..")
				end
			end 
		end
	end

	self:SetSplitTime3()
end


function CBaikeView.C2GSBaikeGetNextQuestion(self)
	g_BaikeCtrl:SetAnswerInfo(true)
	g_BaikeCtrl:C2GSBaikeGetNextQuestion()
end

function CBaikeView.OnScheduleEnd(self, oCtrl)
	-- body
	if oCtrl.m_EventID == define.Schedule.Event.RefreshHuodong then
		if oCtrl.m_Hdlist and oCtrl.m_Hdlist.scheduleid ==1021 and oCtrl.m_Hdlist.state == 3 then
			if self.m_QuestionType then
				self.m_NodeList[self.m_QuestionType]:SetActive(false)
			end
			self.m_CountLabel:SetText("")
			self.m_QuestionLabel:SetText("")
			self:PlayEffect()
		end
	end
end

return CBaikeView