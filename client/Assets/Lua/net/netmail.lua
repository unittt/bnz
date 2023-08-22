module(..., package.seeall)

--GS2C--

function GS2CLoginMail(pbdata)
	local simpleinfo = pbdata.simpleinfo
	--todo
	g_MailCtrl:Reset()
	for _, mail in pairs(simpleinfo) do
		g_MailCtrl.m_Mails[mail.mailid] = mail  -- key:mailid, value:mail
	end
	g_MailCtrl:SortMails()
	g_MailCtrl:OnEvent(define.Mail.Event.Sort)
end

function GS2CMailInfo(pbdata)
	local mailid = pbdata.mailid --邮件id
	local title = pbdata.title --邮件标题
	local context = pbdata.context --邮件内容
	local createtime = pbdata.createtime --创建时间
	local validtime = pbdata.validtime --到期时间
	local pid = pbdata.pid --发件人id
	local name = pbdata.name --发件人名字
	local opened = pbdata.opened --是否打开过，1.打开过，0.没有
	local hasattach = pbdata.hasattach --是否有附件，1.有，0.没有，2.领取过
	local attachs = pbdata.attachs --附件
	--todo
	g_MailCtrl:PullUpdateMailInfo(pbdata)
end

function GS2CDelMail(pbdata)
	local mailids = pbdata.mailids --邮件id
	--todo
	g_MailCtrl:PullDelMails(mailids)
end

function GS2CAddMail(pbdata)
	local simpleinfo = pbdata.simpleinfo
	--todo
	g_MailCtrl:PullAddMail(simpleinfo)
end

function GS2CMailOpened(pbdata)
	local mailids = pbdata.mailids --邮件id
	--todo
	if #mailids > 1 then
		g_MailCtrl:PullOpenMails(mailids)
	elseif #mailids == 1 then
		g_MailCtrl:PushOpenMail(mailids[1])
	end	
end


--C2GS--

function C2GSOpenMail(mailid)
	local t = {
		mailid = mailid,
	}
	g_NetCtrl:Send("mail", "C2GSOpenMail", t)
end

function C2GSAcceptAttach(mailid)
	local t = {
		mailid = mailid,
	}
	g_NetCtrl:Send("mail", "C2GSAcceptAttach", t)
end

function C2GSAcceptAllAttach()
	local t = {
	}
	g_NetCtrl:Send("mail", "C2GSAcceptAllAttach", t)
end

function C2GSDeleteMail(mailids)
	local t = {
		mailids = mailids,
	}
	g_NetCtrl:Send("mail", "C2GSDeleteMail", t)
end

function C2GSDeleteAllMail(cnt_only_client)
	local t = {
		cnt_only_client = cnt_only_client,
	}
	g_NetCtrl:Send("mail", "C2GSDeleteAllMail", t)
end

