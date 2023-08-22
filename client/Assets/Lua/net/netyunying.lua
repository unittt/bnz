module(..., package.seeall)

--GS2C--

function GS2CYunYingForeShow(pbdata)
	local show_list = pbdata.show_list
	--todo
end

function GS2CCustServInfo(pbdata)
	local channel = pbdata.channel --0 代表全部渠道
	local platform = pbdata.platform --0 代表全部平台
	local official_info = pbdata.official_info
	--todo

	local platformID = g_LoginPhoneCtrl:GetPlatform()
	local channelID = g_FeedbackCtrl:GetChannel()

	local bServInfo = (platform == 0 and channel == 0) or (platformID == platform and channelID == channel)
	if bServInfo then
		g_FeedbackCtrl:GS2CCustomerServiceInfo(official_info)
		g_FeedbackCtrl:OnEvent(define.Feedback.Event.RefreshFeedbackServInfo)
	end
end


--C2GS--

