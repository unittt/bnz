local CBarrageCtrl = class("CBarrageCtrl", CCtrlBase)

function CBarrageCtrl.ctor(self)

	CCtrlBase.ctor(self)

	self.m_TextId = 0
	self.m_TextDataList = {}
	self.m_MovingList = {}

	self.m_PlotBarrageData = {}      ---当前剧情弹幕的数据 

end

function CBarrageCtrl.GS2CStoryBulletBarrageData(self, pbdata)
 

	self.m_PlotBarrageData = {}
	local story_id = pbdata.story_id        --剧情id
	local lst = pbdata.lst
	for k, v in pairs(lst) do 
		self.m_PlotBarrageData[v.sec] = v.base
	end 

end

function CBarrageCtrl.GS2CWarBulletBarrage(self, pbdata)
	local war_id = pbdata.war_id --战斗ID
	local bout = pbdata.bout --回合
	local secs = pbdata.secs --距离回合开始的时间戳
	local name = pbdata.name --发弹幕的人
	local msg = pbdata.msg --弹幕信息

	if g_WarCtrl.m_bullet_send == 0 then 
		return
	end

	if g_WarCtrl.m_bullet_show == 0 or not g_WarCtrl.m_bullet_show then 
		return
	end

	local isShowName = false
	if g_WarCtrl.m_bullet_show == 1 then 
		isShowName =  true
	elseif g_WarCtrl.m_bullet_show == 2 then 
		isShowName = false
	end 

	local list = {name = name, msg = msg, isShowName = isShowName}

	table.insert(self.m_TextDataList, list)

end

--帮派弹幕
function CBarrageCtrl.GS2COrgBulletBarrage(self, pbdata)
	local orgid = pbdata.orgid
	local name = pbdata.name
	local msg = pbdata.msg

	if g_WarCtrl:IsWar() or g_WarCtrl.m_ViewSide then 
	 	return
	end 

	if g_ChatCtrl:GetOrgBarrage() == 1 then

		local list = {name = name, msg = msg,  isShowName = data.barragedata.GLOBAL[1].org_showname == 1}
		table.insert(self.m_TextDataList, list)

		local oView = CBarragePopView:GetView()
		if not oView then
			CBarragePopView:ShowView(function (oView)
					oView:StartBarrage()
			end)
		end
	end

end

function CBarrageCtrl.GS2CWarInfoBulletBarrage(self, pbdata)

	local war_id = pbdata.war_id 
	local msg = pbdata.msg --弹幕信息

	if g_WarCtrl.m_bullet_show == 0 or not g_WarCtrl.m_bullet_show then 
		return
	end

	local list = {name = "", msg = msg, isShowName = false}

	table.insert(self.m_TextDataList, 1, list)


end



--插入自己的剧情弹幕数据
function CBarrageCtrl.InsertPlotData(self, list)

	table.insert(self.m_TextDataList, 1, list)

end

function CBarrageCtrl.InsertInfoData(self, list)

	if g_WarCtrl.m_bullet_show == 0 or not g_WarCtrl.m_bullet_show then 
		return
	end
	table.insert(self.m_TextDataList, 1, list)

end


--开始检查剧情播放时刻
function CBarrageCtrl.StartCheckPlotTime(self, startTime)

	self:CloseBarrageView()
	
	local fun = function ( ... )
		local curTime = g_TimeCtrl:GetTimeS() - startTime
		local dataList = self.m_PlotBarrageData[curTime]
		if dataList then 
			for k, v in pairs(dataList) do
				v.isShowName = data.barragedata.GLOBAL[1].plot_showname == 1
				table.insert(self.m_TextDataList, v)
			end 

		end

		return true   

	end

	self.m_Timer = Utils.AddTimer(fun, 1, 0)

end

--结束检查
function CBarrageCtrl.StopCheckPlotTime(self)
	
	if self.m_Timer then 

		Utils.DelTimer(self.m_Timer)
		--清空弹幕数据
		self:CloseBarrageView()

		 self.m_Timer = nil
		
	end 

end

--打开弹幕
function CBarrageCtrl.OpenBarrageView(self)

	local oView = CBarragePopView:GetView()
	if not oView then
		CBarragePopView:ShowView(function (oView)
			oView:StartBarrage()
		end)
	end

end


--关闭弹幕ui，清空数据
function CBarrageCtrl.CloseBarrageView(self)
	
	self.m_TextDataList = {}

	local oView = CBarragePopView:GetView()
	if  oView then
		oView:StopBarrage()	
	end

end

--隐藏或显示弹幕
function CBarrageCtrl.ShowBarrageView(self, show)
	
	local oView = CBarragePopView:GetView()
	if  oView then
		oView:SetActive(show)	
	end

end


return CBarrageCtrl