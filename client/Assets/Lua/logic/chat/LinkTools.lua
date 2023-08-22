module(..., package.seeall)
g_LinkCache = {}
g_LinkFuncMap = {
	link1 = "ItemLink",
	link2 = "CreateTeamLink",
	link3 = "GetTeamInfoLink",
	link4 = "ApplyTeamLink",
	link5 = "SummonLink",
	link6 = "SpeechLink",
	link7 = "EquipSpecialEffLink",
	link8 = "ScheduleLink",
	link9 = "AttrCardLink",
	link10 = "OrgRespondLink",
	link11 = "OrgWorldAdvertiseLink",
	link12 = "TaskLink",
	link13 = "OpenOrgChatLink",
	link14 = "OrgPlayerCallLink",
	link15 = "DevilChallengeLink",
	link16 = "AuctionLink",
	link17 = "YibaoHelpUpStarLink",
	link18 = "YibaoHelpSubmitLink",
	link19 = "YibaoContinueHelpUpStarLink",
	link20 = "RedPacketGetLink",
	link21 = "OpenUrlOnBrowserLink",
	link22 = "ChatMessageLink",
	link23 = "OrgSkillLink",
	link24 = "PartnerLink",
	link25 = "WarObserverLink",
	link26 = "TitleLink",
	link27 = "EquipSpecialSkillLink",
	link28 = "BiwuActivityLink",
	link29 = "OrgApplyLink",
	link30 = "RunringHelpSubmitLink",
	link31 = "ItemTipsLink",
	link32 = "SpiritLink",
	link33 = "PlayerInfoLink",
}

---------------------以下函数的目的是根据text得到具体的文字和具体的函数----------------------------

--type func
--{link1,1001}
function ItemLink(iUrlID, iPid, iItemID, iShape, iAmount, iName)
	iItemID = tonumber(iItemID)
	iPid = tonumber(iPid)
	iAmount = tonumber(iAmount)
	local dLink = {
		sType = "ItemLink",
		iItemID = iItemID,
		iPid = iPid,
		func = function() g_LinkInfoCtrl:GetItemInfo(iPid, iItemID) end
	}
	
	local sUrl
	if iAmount == 1 then
		if iName then
			sUrl = BuildUrlText(iUrlID, string.format("#K[%s]#n", iName), iItemID)
		else
			local itemdata = DataTools.GetItemData(iShape)
			sUrl = BuildUrlText(iUrlID, string.format("#K[%s]#n", itemdata.name), iItemID)
		end
	else		
		if iName then
			sUrl = BuildUrlText(iUrlID, string.format("#K[%s×%d]#n", iName, iAmount), iItemID)
		else
			local itemdata = DataTools.GetItemData(iShape)
			sUrl = BuildUrlText(iUrlID, string.format("#K[%s×%d]#n", itemdata.name, iAmount), iItemID)
		end
	end
	return sUrl, dLink
end

function CreateTeamLink(iUrlID)
	local dLink = {
		sType = "CreateTeamLink",
		func = function() netteam.C2GSCreateTeam() end
	}
	local sUrl = BuildUrlText(iUrlID, "#K[创建队伍]#n")
	return sUrl, dLink
end

function SummonLink(iUrlID, iPid, iSummonID, iTypeID, iTime)
	iSummonID = tonumber(iSummonID)
	iPid = tonumber(iPid)
	iTime = tonumber(iTime)
	local dLink = {
		sType = "SummonLink",
		iSummonID = iSummonID,
		iPid = iPid,
		iTime = iTime,
		func = function() g_LinkInfoCtrl:GetSummonInfo(iPid, iSummonID) end
	}
	local summonInfo = data.summondata.INFO
	iTypeID = tonumber(iTypeID)
	name = summonInfo[iTypeID]["name"]
	local sUrl = BuildUrlText(iUrlID, string.format("#K[%s]#n", name), iSummonID)
	return sUrl, dLink
end

function GetTeamInfoLink(iUrlID, iTeamId, sTarget)
	local dLink = {
		sType = "GetTeamInfoLink",
		func = function() netteam.C2GSTeamInfo(iTeamId) end
	}
	local sUrl = BuildUrlText(iUrlID, string.format("#K%s#n", sTarget))
	return sUrl, dLink
end

function ApplyTeamLink(iUrlID, iTeamid)
	local dLink = {
		sType = "ApplyTeamLink",
		func = function() netteam.C2GSApplyTeam(iTeamid, 0, 2) end
	}
	local sUrl = BuildUrlText(iUrlID, "#K[u][加入队伍][/u]#n")
	return sUrl, dLink
end

function SpeechLink(iUrlID, sSpeechKey, sTranslate, iTime)
	local dLink = {
		sType = "SpeechLink",
		sKey = sSpeechKey,
		sTranslate = sTranslate,
		iTime = iTime,
		func = function ()
			g_SpeechCtrl:PlayWithKey(sSpeechKey)
		end
	}
	local sUrl = BuildUrlText(iUrlID, "#K#audio"..sTranslate)
	if g_SpeechCtrl:IsPlay(sSpeechKey) then
		sUrl = BuildUrlText(iUrlID, "#K#500"..sTranslate)
	end
	return sUrl, dLink
end

function EquipSpecialEffLink(iUrlID, iEffectId)
	local dLink = {
		sType = "EquipSpecialEffLink",
		iEffectId = iEffectId,
		func = function(oView) 
			local args = {widget =  oView, side = enum.UIAnchor.Side.Right,offset = Vector2.New(10, 50)}
			g_WindowTipCtrl:SetWindowEquipEffectTipInfo(iEffectId, args) 
		end
	}
	local sEffName = data.skilldata.SPECIAL_EFFC[tonumber(iEffectId)].name
	local sUrl = BuildUrlText(iUrlID, string.format("#K%s#n", sEffName))
	return sUrl, dLink
end

function ScheduleLink(iUrlID, sText, iSid)
	iSid = tonumber(iSid)
	local dLink = {
		sType = "ScheduleLink",
		iSid = iSid,
		sText = sText,
		func = function()
			CScheduleInfoView:ShowView(function (oView)
			oView:SetScheduleID(iSid)
			end)
		end
	}
	local sUrl = BuildUrlText(iUrlID, string.format("#K[%s]#n", sText))
	return sUrl, dLink
end

function AttrCardLink(iUrlID, sText, pid)
	pid = tonumber(pid)
	local dLink = {
		sType = "AttrCardLink",
		pid = pid,
		sText = sText,
		func = function()
			g_LinkInfoCtrl:GetAttrCardInfo(pid)
		end
	}
	local sUrl = BuildUrlText(iUrlID, string.format("#K[%s]#n", sText),pid)
	return sUrl, dLink
end

function OrgRespondLink(iUrlID, orgid)
	orgid = tonumber(orgid)
	local dLink = {
		sType = "OrgRespondLink",
		func = function()
			netorg.C2GSRespondOrg(orgid, g_OrgCtrl.HAS_RESPOND_ORG)
		end
	}
	local sUrl = BuildUrlText(iUrlID, "#K[立刻响应]#n")
	return sUrl, dLink
end

function OrgWorldAdvertiseLink(iUrlID, orgid, leaderid)
	local dLink = {
		sType = "OrgWorldAdvertiseLink",
		func = function()
			if leaderid == g_AttrCtrl.pid then
				g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1025].content)
			else
				netorg.C2GSRespondOrg(orgid, g_OrgCtrl.HAS_RESPOND_ORG)
			end
		end
	}
	local sUrl = BuildUrlText(iUrlID, "#K[立刻响应]#n")
	return sUrl, dLink
end

function TaskLink(iUrlID, taskid, title, target, desc)
	local dLink = {
		sType = "TaskLink",
		func = function()
			CTaskLinkView:ShowView(
				function(oView) oView:SetTaskData(taskid, title, target, desc) end
			)
		end
	}
	local sUrl = BuildUrlText(iUrlID, string.format("#K[%s]#n", title))
	return sUrl, dLink
end

function OpenOrgChatLink(iUrlID, orgid, btnStr)
	local dLink = {
		sType = "OpenOrgChatLink",
		func = function()
			g_ChatViewCtrl:OpenChatOrgChannel()
		end
	}
	local sUrl = BuildUrlText(iUrlID, btnStr)
	return sUrl, dLink
end

function OrgPlayerCallLink(iUrlID, pid, name)
	local dLink = {
		sType = "OrgPlayerCallLink",
		pid = pid,
		name = name,
		func = function()
			
		end
	}
	local sUrl = BuildUrlText(iUrlID,  string.format("#K@%s#n ", name))
	return sUrl, dLink
end

function DevilChallengeLink(iUrlID, mapid, pos_x, pos_y, npcid)
	local dLink = {
		sType = "DevilChallengeLink",
		mapid = tonumber(mapid),
		pos_x = tonumber(pos_x),
		pos_y = tonumber(pos_y),
		npcid = tonumber(npcid),
		func = function()
			printc("去挑战天魔链接", mapid, " ", pos_x, " ", pos_y, " ", npcid)
			local pos = Vector3.New(pos_x, pos_y, 0)
			g_MapTouchCtrl:CrossMapPos(mapid, netscene.DecodePos(pos), npcid, define.Walker.Npc_Talk_Distance)
		end
	}
	local sUrl = BuildUrlText(iUrlID,  string.format("#K[%d,%d]#n ", math.floor(pos_x/1000), math.floor(pos_y/1000)))
	return sUrl, dLink
end

function AuctionLink(iUrlID, iAuctionid, iPrice, sName)
	local dLink = {
		sType = "AuctionLink",
		func = function()
			netauction.C2GSClickLink(tonumber(iAuctionid))
		end
	}
	local sUrl = BuildUrlText(iUrlID, string.format("#K[%s-#G%d#n]#n", sName, iPrice))
	return sUrl, dLink
end

function YibaoHelpUpStarLink(iUrlID, target, taskid, create_day)
	local dLink = {
		sType = "YibaoHelpUpStarLink",
		target = tonumber(target),
		taskid = tonumber(taskid),
		create_day = tonumber(create_day),
		func = function()
			nettask.C2GSYibaoGiveHelp(target, taskid, create_day)
		end
	}
	local sUrl = BuildUrlText(iUrlID,  "#K[协助升星]#n")
	return sUrl, dLink
end

function YibaoHelpSubmitLink(iUrlID, target, taskid, create_day)
	local dLink = {
		sType = "YibaoHelpSubmitLink",
		target = tonumber(target),
		taskid = tonumber(taskid),
		create_day = tonumber(create_day),
		func = function()
			g_YibaoCtrl.m_YibaoOtherGiveHelpTaskid = tonumber(taskid)
			nettask.C2GSYibaoGiveHelp(target, taskid, create_day)	
		end
	}
	local sUrl = BuildUrlText(iUrlID,  "#K[协助上交]#n")
	return sUrl, dLink
end

function YibaoContinueHelpUpStarLink(iUrlID, target, taskid, create_day)
	local dLink = {
		sType = "YibaoContinueHelpUpStarLink",
		target = tonumber(target),
		taskid = tonumber(taskid),
		create_day = tonumber(create_day),
		func = function()
			nettask.C2GSYibaoGiveHelp(target, taskid, create_day)
		end
	}
	local sUrl = BuildUrlText(iUrlID,  "#K[继续协助]#n")
	return sUrl, dLink
end

function RedPacketGetLink(iUrlID, redpacketid, redpacketname)
	local dLink = {
		sType = "RedPacketGetLink",
		redpacketid = tonumber(redpacketid),
		redpacketname = tostring(redpacketname),
		func = function()
			netredpacket.C2GSRobRP(redpacketid)
		end
	}
	local sUrl = BuildUrlText(iUrlID,  "#K[#jiang "..redpacketname.."]#n")
	return sUrl, dLink
end

function OpenUrlOnBrowserLink(iUrlID, urllink, urlname)
	local dLink = {
		sType = "OpenUrlOnBrowserLink",
		urllink = tostring(urllink),
		urlname = tostring(urlname),
		func = function()
			UnityEngine.Application.OpenURL(urllink)
		end
	}
	local sUrl = BuildUrlText(iUrlID,  "#K"..urlname.."#n")
	return sUrl, dLink
end

function ChatMessageLink(iUrlID, text)
	local dLink = {
		sType = "ChatMessageLink",
		text = tostring(text),
		func = function()
			
		end
	}
	local sUrl = BuildUrlText(iUrlID,  text)
	return sUrl, dLink
end

function OrgSkillLink(iUrlID, skillid, title, level, desc)
	local dLink = {
		sType = "OrgSkillLink",
		func = function()
			COrgSkillLinkView:ShowView(
				function(oView) oView:SetSkillData(skillid, title, level, desc) end
			)
		end
	}
	local sUrl = BuildUrlText(iUrlID, string.format("#K[%s]#n", title))
	return sUrl, dLink
end

function PartnerLink(iUrlID, iPid, iPartnerID, sName, iTime)
	iPartnerID = tonumber(iPartnerID)
	iPid = tonumber(iPid)
	iTime = tonumber(iTime)
	local dLink = {
		sType = "PartnerLink",
		iPartnerID = iPartnerID,
		iPid = iPid,
		iTime = iTime,
		func = function() g_LinkInfoCtrl:GetPartnerInfo(iPid, iPartnerID, iTime) end
	}

	local sUrl = BuildUrlText(iUrlID, string.format("#K[%s]#n", sName), iPartnerID)
	return sUrl, dLink
end

function WarObserverLink(iUrlID, campid, npcid, target)
	local dLink = {
		sType = "WarObserverLink",
		func = function() 
			netplayer.C2GSObserverWar(tonumber(campid or 1), tonumber(npcid or 0), tonumber(target or 0))
		end
	}
	local sUrl = BuildUrlText(iUrlID, "#K[观战]#n")
	return sUrl, dLink
end

function TitleLink(iUrlID, sText, tid)
	pid = tonumber(pid)
	local dLink = {
		sType = "TitleLink",
		tid = tid,
		name = sText,
		sText = sText,
		func = function()
			g_LinkInfoCtrl:ShowTitleInfo(sText, tid)
		end
	}
	local sUrl = BuildUrlText(iUrlID, string.format("#K[%s]#n", sText),pid)
	return sUrl, dLink
end

function EquipSpecialSkillLink(iUrlID, iSkillId)
	local dLink = {
		sType = "EquipSpecialSkillLink",
		iSkillId = iSkillId,
		func = function(oView) 
			local args = {widget =  oView, side = enum.UIAnchor.Side.Right,offset = Vector2.New(10, 50)}
			g_WindowTipCtrl:SetWindowEquipEffectTipInfo(iSkillId, args, true) 
		end
	}
	local sEffName = data.skilldata.SPECIAL_SKILL[tonumber(iSkillId)].name
	local sUrl = BuildUrlText(iUrlID, string.format("#K%s#n", sEffName))
	return sUrl, dLink
end

--比武大会链接
function BiwuActivityLink(iUrlID, pos_x, pos_y)
	local dLink = {
		sType = "BiwuActivityLink",
		pos_x = tonumber(pos_x),
		pos_y = tonumber(pos_y),
		func = function()
			--printc("比武大会链接,请求服务器寻路：", pos_x, pos_y)
			netopenui.C2GSFindHDNpc()
		end
	}
	local sUrl = BuildUrlText(iUrlID,  string.format("#K(%d,%d)#n ", math.floor(pos_x), math.floor(pos_y)))
	return sUrl, dLink
end

function OrgApplyLink(iUrlID, orgid, orgname)
	orgid = tonumber(orgid)
	local dLink = {
		sType = "OrgApplyLink",
		func = function()
			g_OrgCtrl:ApplyJoinOrg(orgid)
		end
	}
	local sUrl = BuildUrlText(iUrlID, string.format("#K[加入%s]#n", orgname))
	return sUrl, dLink
end

function RunringHelpSubmitLink(iUrlID, target, taskid, create_week, ring)
	local dLink = {
		sType = "RunringHelpSubmitLink",
		target = tonumber(target),
		taskid = tonumber(taskid),
		create_week = tonumber(create_week),
		ring = tonumber(ring),
		func = function()
			nettask.C2GSRunringGiveHelp(tonumber(target), tonumber(taskid), tonumber(create_week), tonumber(ring))	
		end
	}
	local sUrl = BuildUrlText(iUrlID,  "#K[协助上交]#n")
	return sUrl, dLink
end

function ItemTipsLink(iUrlID, iItemSID)
	iItemSID = tonumber(iItemSID)
	local dLink = {
		sType = "ItemTipsLink",
		func = function()
			CWindowItemTipView:ShowView(function (oView)
				oView:SetWindowItemTipInfo(iItemSID)
				oView.m_TipWidget:SetLocalPos(Vector3.New(-234, 159, 0))
			end)
		end
	}
	local oItemConfig = DataTools.GetItemData(iItemSID)
	local sUrl = BuildUrlText(iUrlID, string.format("#K[%s]#n", oItemConfig and oItemConfig.name or ""))
	return sUrl, dLink
end

function SpiritLink(iUrlID, iSpiritItemId)
	iSpiritItemId = tonumber(iSpiritItemId)
	local dLink = {
		sType = "SpiritLink",
		func = function()
			local oRandomConfig = g_SpiritCtrl:GetRandomItemConfig(iSpiritItemId)
			local oMsgStr = data.spiritdata.SPIRITITEM[iSpiritItemId].content.."\n您可能还感兴趣："..string.format("{link32,%d}", oRandomConfig[1].id).."、"..string.format("{link32,%d}", oRandomConfig[2].id)
			table.insert(g_SpiritCtrl.m_MsgList, 1, {type = 2, msg = oMsgStr})
			table.insert(g_SpiritCtrl.m_MsgList, 1, {type = 1, msg = data.spiritdata.SPIRITITEM[iSpiritItemId].name})
			g_SpiritCtrl:OnEvent(define.Spirit.Event.Question)
		end
	}
	local oConfig = data.spiritdata.SPIRITITEM[iSpiritItemId]
	local sUrl = BuildUrlText(iUrlID, string.format("#K[%s]#n", oConfig.name))
	return sUrl, dLink
end

function PlayerInfoLink(iUrlID, oPid, oName)
	local dLink = {
		sType = "PlayerInfoLink",
		oPid = tonumber(oPid),
		func = function()
			netplayer.C2GSGetPlayerInfo(tonumber(oPid))
		end
	}
	local sUrl = BuildUrlText(iUrlID,  "[u]"..oName.."[/u]")
	return sUrl, dLink
end

--为了显示具体文字使用，可以不传, 只是为了显示在Label中方便查看
--urlId,具体显示文字,参数
function BuildUrlText(iUrlID, sPrinted, ...)
	local sArgs = table.concat({...}, ",")
	local s = string.format("[url=%d,%s]%s[/url]" , iUrlID , sArgs, sPrinted)
	return s
end

---------------------下边的函数是设置聊天点击发送按钮时向服务器传的text------------------------

--client generate func
function GenerateCreateTeamLink()
	return "{link2}"
end

function GenerateItemLink(iPid, iItemID, iShape, iAmount, iName)
	return string.format("{link1,%d,%d,%d,%d,%s}", iPid, iItemID, iShape, iAmount, iName)
end

function GenerateSummonLink(iPid, iSummonID, iTypeID, iTime)
	return string.format("{link5,%d,%d,%d,%d}", iPid, iSummonID, iTypeID, iTime)
end

function GenerateGetTeamInfoLink(iTeamId, sTarget)
	return string.format("{link3,%d,%s}", iTeamId, sTarget)
end

function GenerateApplyTeamLink(iTeamid)
	return string.format("{link4,%d}", iTeamid)
end

function GenerateSpeechLink(sKey, sTranslate, iTime)
	return string.format("{link6,%s,%s,%d}", sKey, sTranslate, iTime)
end

function GenerateEquipSpecialEffLink(iEffectId)
	return string.format("{link7,%d}", iEffectId)
end

function GenerateAttrCardLink(sText, pid)
	return string.format("{link9,%s,%d}", sText, pid)
end

function GenerateOrgRespondLink()
	return string.format("{link10,%d}")  -- orgid
end

function GenerateOrgWorldAdvertiseLink()
	return string.format("{link11,%d,%d}")  -- orgid, leaderid
end

function GenerateTaskLink(taskid, title, targe, desc)
	return string.format("{link12,%d,%s,%s,%s}", taskid, title, targe, desc)	
end

function GenerateOpenOrgChatLink()
	return string.format("{link13,%d}")  -- orgid
end

function GenerateOrgPlayerCallLink(pid, name)
	return string.format("{link14,%d,%s}", pid, name)
end

function GenerateDevilChallengeLink(mapid, pos_x, pos_y, npcid)
	return string.format("{link15,%d,%d,%d,%d}", mapid, pos_x, pos_y, npcid)
end

function GenerateAuctionLink(iAuctionid, iPrice, sName)
	return string.format("{link16,%d,%d,%s}", iAuctionid, iPrice, sName)
end

function GenerateYibaoHelpUpStarLink(target, taskid, create_day)
	return string.format("{link17,%d,%d,%d}", target, taskid, create_day)
end

function GenerateYibaoHelpSubmitLink(target, taskid, create_day)
	return string.format("{link18,%d,%d,%d}", target, taskid, create_day)
end

function GenerateYibaoContinueHelpUpStarLink(target, taskid, create_day)
	return string.format("{link19,%d,%d,%d}", target, taskid, create_day)
end

function GenerateRedPacketGetLink(redpacketid, redpacketname)
	return string.format("{link20,%d,%s}", redpacketid, redpacketname)
end

function GenerateOpenUrlOnBrowserLink(urllink, urlname)
	return string.format("{link21,%s,%s}", urllink, urlname)
end

function GenerateChatMessageLink(text)
	return string.format("{link22,%s}", text)
end

function GenerateOrgSkillLink(skillid, title, level, desc)
	return string.format("{link23,%d,%s,%s,%s}", skillid, title, level, desc)	
end

function GeneratePartnerLink(iPid, iPartnerID, sName, iTime)
	return string.format("{link24,%d,%d,%s,%d}", iPid, iPartnerID, sName, iTime)
end

function GenerateWarObserverLink(campid, npcid, target)
	return string.format("{link25,%d,%d,%d}", campid, npcid, target)
end

function GenerateTitleLink(sText, tid)
	return string.format("{link26,%s,%d}", sText, tid)
end

function GenerateEquipSpecialSkillLink(iSkillId)
	return string.format("{link27,%d}", iSkillId)
end

function GenerateBiwuActivityLink(pos_x, pos_y)
	return string.format("{link28,%d,%d}", pos_x, pos_y)
end

function GenerateOrgApplyLink(iOrgId, sOrgName)
	return string.format("{link29,%d,%s}", iOrgId, sOrgName)
end

function GenerateRunringHelpSubmitLink(target, taskid, create_week, ring)
	return string.format("{link30,%d,%d,%d,%d}", target, taskid, create_week, ring)
end

function GenerateItemTipsLink(iItemSID)
	return string.format("{link31,%d}", iItemSID)
end

function GenerateSpiritLink(iSpiritItemId)
	return string.format("{link32,%d}", iSpiritItemId)
end

function GeneratePlayerInfoLink(oPid, oName)
	return string.format("{link33,%d,%s}", oPid, oName)
end

---------------------以下函数的目的也是根据text得到具体的文字和具体的函数----------------------

--这里是ParseOne()找到的函数返回具体的文字和函数，这个函数可以寻找多个链接
function GetLinks(text)
	text = text or ""
	if g_LinkCache[text] then
		return g_LinkCache[text].sUrl, g_LinkCache[text].lLink
	end
	local lLink = {} 
	local iUrlID = 1
	--sOneUrl是输入框的具体文字,dLink是一个具体的函数或者逻辑
	local function process(match)
		iUrlID = #lLink + 1
		local sOneUrl, dLink = ParseOne(match, iUrlID)
		table.insert(lLink, dLink)
		return sOneUrl
	end
	local sUrl = string.gsub(text, "%b{}", process)
	g_LinkCache[text] = {sUrl=sUrl, lLink=lLink}
	--sUrl是被具体文字替换后的，lLink是具体函数的list
	return sUrl, lLink
end

--这里是根据发送的链接字符串解析，得到type和各个参数，根据type找到g_LinkFuncMap对应的函数，执行该函数
function ParseOne(s, iUrlID)
	local list = string.split(string.gsub(s, "[{}]", ""), ",")
	if #list > 0 then
		local sType = table.remove(list, 1)
		local funcName = g_LinkFuncMap[sType]
		if funcName then
			local linkFunc = LinkTools[funcName]
			if linkFunc then
				local sUrl, dLink = linkFunc(iUrlID, unpack(list, 1, #list))
				return sUrl, dLink
			end
		end

	end
	return s, {}
end

--这里是只取出具体的函数
function FindLink(text, sType)
	local _, lLink = GetLinks(text)
	for k, dLink in pairs(lLink) do
		if dLink.sType == sType then
			return dLink
		end
	end
end

--这里是只取出具体的文字，显示在输入框里面
function GetPrintedText(text)
	if text == "" then
		return text
	end
	local sUrl, _ = GetLinks(text) 
	local sText, _ = string.gsub(sUrl, "%[url=(.-)%](.-)%[/url%]", "%2")
	sText = string.gsub(sText, "#%u", "")
	sText = string.gsub(sText, "#n", "")
	sText = string.gsub(sText, "%[u%]", "")
	sText = string.gsub(sText, "%[/u%]", "")

	return sText
end

--这里是只取出具体的文字,带颜色的文字，显示在输入框里面
function GetPrintedColorText(text)
	if text == "" then
		return text
	end
	local sUrl, _ = GetLinks(text) 
	local sText, _ = string.gsub(sUrl, "%[url=(.-)%](.-)%[/url%]", "%2")
	sText = string.gsub(sText, "%[u%]", "")
	sText = string.gsub(sText, "%[/u%]", "")

	return sText
end

--清除具体的文字和函数对应字典的数据,g_LinkCache只是方便使用
function ClearLinkCache(text)
	if g_LinkCache[text] then
		g_LinkCache[text] = nil
	end
end

function ClearAllLinkCache()
	g_LinkCache = {}
end