local CFeedbackCtrl = class("CFeedbackCtrl", CCtrlBase)

function CFeedbackCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self:Clear()
end

function CFeedbackCtrl.Clear(self)
	self.m_GeneralInfo = {}
	self.m_FeedbackInfo = {}

	self.m_ImagePathList = {}

	self.m_Channel = nil
	self.m_bShowRedpt = false
	self.m_bFeedbackOpen = false
	self.m_bFeedbackInfoOpen = false
end

function CFeedbackCtrl.InitChannel(self, channel)
	self.m_Channel = channel
end

function CFeedbackCtrl.GetChannel(self)
	return self.m_Channel
end

function CFeedbackCtrl.GS2CSysSwitch(self, syslist)
	if syslist then
		self.m_bFeedbackOpen = (syslist[1].state == 1)
		self.m_bFeedbackInfoOpen = (syslist[2].state == 1)
	end
end

function CFeedbackCtrl.GS2CFeedBackAnswerList(self, question_list, iState)
	if #question_list < 1 then  --没有反馈信息，不做处理
		return
	end

	if #question_list > 1 then
		for i, v in ipairs(question_list) do
			table.insert(self.m_FeedbackInfo, v)
		end
	else
		local question = question_list[1]
		local bCommited = false
		for i, v in ipairs(self.m_FeedbackInfo) do
			if v.question_id == question.question_id then
				for k, val in pairs(question) do
					v[k] = val
				end
				bCommited = true
				break
			end
		end
		if not bCommited then
			table.insert(self.m_FeedbackInfo, question) --找不到id时直接插入消息
		end
	end

	self:CheckFeedbackCount()

	table.sort(self.m_FeedbackInfo, function(a, b)
		return a.question_id < b.question_id
	end)

	self:OnEvent(define.Feedback.Event.RefreshFeedbackInfo)

	-- 若是回复消息，显示红点(判断聊天界面是否打开)
	local oView = CFeedbackMainView:GetView()
	if oView then
		if iState == 0 then
			netother.C2GSFeedBackSetCheckState()
		end
	else
		self.m_bShowRedpt = iState == 0  --红点显示即未读状态
		self:OnEvent(define.Feedback.Event.RefreshFeedbackRedPt)
	end
end

--官方客服信息
function CFeedbackCtrl.GS2CCustomerServiceInfo(self, official_info)
	local CustomerServiceInfo =  string.split(official_info, "%s")
	if next(self.m_GeneralInfo) then
		self.m_GeneralInfo = {}
	end
	for i=1, #CustomerServiceInfo, 2 do
		local t = {}
		t.title = CustomerServiceInfo[i]
		t.content = CustomerServiceInfo[i + 1]
		table.insert(self.m_GeneralInfo, t)
	end
end

--提交
function CFeedbackCtrl.CommitFeedbackMsg(self, msg)
	local type = msg.type
	local context = msg.context
	local image_urls = {}
	local qq_no = msg.qq_no or ""
	local phone_no = msg.phone_no or ""
	local net_type = C_api.Utils.GetNetworkType()
	local signal_strength = ""
	if net_type == "WIFI" then
		signal_strength = C_api.Utils.GetWifiSignal()
	end
	
	--上传图片至服务器
	for k, path in pairs(self.m_ImagePathList) do
		local dTime = os.time()
		local iKey = string.format("%d_feedback_%d", g_AttrCtrl.pid, dTime)
		table.insert(image_urls, {picture_url = iKey})
		g_QiniuCtrl:UploadFile(iKey, path, enum.QiniuType.Image, function(key, iSucc)
			if iSucc then
				g_NotifyCtrl:FloatMsg("图片提交成功")
			else
				g_NotifyCtrl:FloatMsg("图片上传失败")
			end
		end)
	end
	
	netother.C2GSFeedBackQuestion(type, context, image_urls, qq_no, phone_no, net_type, signal_strength)
	self:ClearImagePath()
	g_NotifyCtrl:FloatMsg("感谢您本次的提问，请耐心等待回复哦！")
end

--若反馈信息数量大于10，只留后10条
function CFeedbackCtrl.CheckFeedbackCount(self)
	local len = #self.m_FeedbackInfo
	if len > 10 then
		local list = {}
		for i = len, len - 9, -1 do
			local info = self.m_FeedbackInfo[i]
			table.insert(list, 1, info)
		end
		self.m_FeedbackInfo = list
	end
end

--是否已回复
function CFeedbackCtrl.IsAnswered(self)

	if #self.m_FeedbackInfo == 0 then
		return true
	end

	local dInfo = self.m_FeedbackInfo[#self.m_FeedbackInfo]
	local bAnswered = false
	if string.len(dInfo.answer) >= 1 then
		bAnswered = true 
	end

	return bAnswered
end

--清除全部图片缓存
function CFeedbackCtrl.ClearImagePath(self)
	for i=1, 3 do
		self:DelImagePath(i)
	end
end

function CFeedbackCtrl.AddImagePath(self, idx, path)
	self.m_ImagePathList[idx] = path
end

function CFeedbackCtrl.DelImagePath(self, idx)
	local filename
	if self.m_ImagePathList[idx] then
		filename = self.m_ImagePathList[idx]
		self.m_ImagePathList[idx] = nil
	end
	return filename
end

function CFeedbackCtrl.ConvertTimeL(self, iSec)
	return os.date("%Y年%m月%d日 %H:%M:%S", iSec)
end

function CFeedbackCtrl.GetImageUrls(self)
	local list = {}
	for k, v in pairs(self.m_ImagePathList) do
		table.insert(list, v)
	end
	return list
end

--反馈信息(用于UI显示)
function CFeedbackCtrl.GetFeedbackInfoList(self)
	local infoList = {}
	for i, v in ipairs(self.m_FeedbackInfo) do
		if string.len(v.question) >= 1 then
			table.insert(infoList, {tag = 1, msg = v.question, time = v.question_time})
		end

		if string.len(v.answer) >= 1 then
			table.insert(infoList, {tag = 2, msg = v.answer, time = v.answer_time})
		end
	end
	return infoList
end

--游戏官网: yhxj.shcljoy.com  微信公众号： yhxj.ci  客服公众号： 810441813 玩家交流群： 38399

function CFeedbackCtrl.GetGeneralInfo(self)
	return self.m_GeneralInfo
end

function CFeedbackCtrl.IsFeedbackOpen(self)
	local bFDSysOpen = g_OpenSysCtrl:GetOpenSysState("FEEDBACK") and self.m_bFeedbackOpen
    local bFDnfoSysOpen = g_OpenSysCtrl:GetOpenSysState("FEEDBACKINFO") and self.m_bFeedbackInfoOpen
    if bFDSysOpen or bFDnfoSysOpen then
        return true
    else
        return false
    end
end

return CFeedbackCtrl