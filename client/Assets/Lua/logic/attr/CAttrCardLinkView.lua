local CAttrCardLinkView = class("CAttrCardLinkView", CViewBase)

function CAttrCardLinkView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Attr/AttrCardLinkView.prefab", cb)
	self.m_ExtendClose = "ClickOut"
    self.m_NeedGoldCoin = 580  --非免费改名需要元宝数量
	self.m_RenameMaxGrade = 50 --超过此等级需要元宝
	self.m_RenameMinGrade = 10 --低于此等级无法改名
	self.m_LikeNeedGrade = 30  --点赞需要等级
	self.m_ChannelList = {
		define.Channel.Current,
	  	define.Channel.Org,	 	  
	  	define.Channel.Team,
	  	define.Channel.World,
	}
	self.m_Isupvote = 0	
end

function CAttrCardLinkView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_LvLabel = self:NewUI(2, CLabel)	
	self.m_RenameBtn = self:NewUI(4, CButton)
	self.m_InfoGrid = self:NewUI(5, CGrid)    
	self.m_AddFriendBtn = self:NewUI(6, CButton)
	self.m_Pid = self:NewUI(7, CLabel)	
	self.m_ActorTexture = self:NewUI(8, CActorTexture)
    self.m_Moods = self:NewUI(9, CLabel)
    self.m_GiveBtn = self:NewUI(10, CButton)
    self.m_PraiseBtn = self:NewUI(11, CButton)
    self.m_FindBtn = self:NewUI(12, CButton)
    self.m_SendCardBtn = self:NewUI(13, CButton)
	self.m_SchoolPic = self:NewUI(14, CSprite)
	self.m_ChannelBtnGrid = self:NewUI(15, CGrid)
	self.m_ChannelBtns = self:NewUI(16, CBox)
	self.m_RankBtn = self:NewUI(17, CButton)
	self.m_AwardBtn = self:NewUI(18, CButton)
	self.m_MyRank = self:NewUI(19, CLabel)

	self.m_RankBtn:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.Rank))

	self.m_ChannelBtns:SetActive(false)
	g_UITouchCtrl:TouchOutDetect(self.m_ChannelBtns, callback(self.m_ChannelBtns, "SetActive", false))

	local function InitAttr(obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_AttrLabel = oBox:NewUI(2, CLabel)
		oBox.m_AttrLabel:SetText("暂无")
		if gameconfig.Issue.Shiedle then
			if idx == 3 or idx == 4 or idx == 6 then
				oBox:SetActive(false)
			end
		end
		return oBox
	end
	self.m_InfoGrid:InitChild(InitAttr)


	self.m_ShowPosBtn = self.m_InfoGrid:GetChild(6):NewUI(3, CButton)
	self.m_Pos = self.m_InfoGrid:GetChild(6).m_AttrLabel


	self.m_OrgText = self.m_InfoGrid:GetChild(2).m_AttrLabel
	self.m_TitleText = self.m_InfoGrid:GetChild(1).m_AttrLabel
	local function InitChannelBtns(obj, idx)
		local btn = CButton.New(obj)
		btn:AddUIEvent("click",callback(self, "SendMSg", idx))
		return btn
	end
	self.m_ChannelBtnGrid:InitChild(InitChannelBtns)
	self:RegisterEvent()
	netrank.C2GSGetRankInfo(102,1)	--获取人气排行榜信息
	netplayer.C2GSUpvoteReward()    --领取奖品信息获取
end

function CAttrCardLinkView.RegisterEvent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_AddFriendBtn:AddUIEvent("click", callback(self, "OnAddFriend"))
	self.m_RenameBtn:AddUIEvent("click", callback(self, "OpenRenameWindow"))
    self.m_GiveBtn:AddUIEvent("click", callback(self, "OnGiveGift"))
    self.m_SendCardBtn:AddUIEvent("click",callback(self, "SendCard"))
    self.m_PraiseBtn:AddUIEvent("click", callback(self, "OnPraise"))
    self.m_FindBtn:AddUIEvent("click", callback(self, "OnFind"))
	self.m_ShowPosBtn:AddUIEvent("click", callback(self, "OnShowPos"))
	self.m_RankBtn:AddUIEvent("click", callback(self, "OnRank"))
	self.m_AwardBtn:AddUIEvent("click", callback(self, "OnAward"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_FriendCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CAttrCardLinkView.OnClose(self)
	local info = {pid = self.m_CardPid, upvote = nil}
	g_RankCtrl:OnEvent(define.Rank.Event.UpdateMeinUpvote, info) -- 刷新排行榜被赞
	self:CloseView()
end

function CAttrCardLinkView.OnCtrlEvent(self, oCtrl)	
	--刷新当前UI
	if oCtrl.m_EventID == define.Attr.Event.Change and self.m_CardPid == g_AttrCtrl.pid then
		g_LinkInfoCtrl:RfreshMyCardInfo()
		local info = g_LinkInfoCtrl:GetSelfAttrCardInfo()
		if info then
			self:SetSelfCardInfo(info)
		end
	end	
	if oCtrl.m_EventID == define.Friend.Event.Add or oCtrl.m_EventID == define.Friend.Event.Update then 	
		if self.m_CardPid == nil or self.m_CardPid == g_AttrCtrl.pid then 
			return
		end 
		if g_FriendCtrl:IsMyFriend(self.m_CardPid) then
			self.m_AddFriendBtn:SetText("已加好友")		
		else
			self.m_AddFriendBtn:SetText("加为好友")	
		end
	end	
end
 
function CAttrCardLinkView.SetSelfCardInfo(self, data)
	self.m_Isupvote = data.isupvote    
	if self.m_Isupvote >= 1 then 
    	self.m_PraiseBtn:SetSpriteName("h7_xiaoan_4_1")
	else
		self.m_PraiseBtn:SetSpriteName("h7_xiaoan_4")
	end
	self.m_GiveBtn:SetActive(false)	
    self.m_AddFriendBtn:SetActive(false)
    self.m_SendCardBtn:SetActive(true)
	self.m_RenameBtn:SetActive(true)
	if gameconfig.Issue.Shiedle then
		self.m_AwardBtn:SetActive(false)
	else
		self.m_AwardBtn:SetActive(true)
	end
	self.m_MyRank:SetText(data.rank)
	self.m_ShowPosBtn:SetActive(true)
	g_AttrCtrl.rank = data.rank
    self:SetCardInfo(data)
end

function CAttrCardLinkView.SetCardLinkInfo(self, data)
    self.m_RenameBtn:SetActive(false)
    self.m_GiveBtn:SetActive(false)
	self.m_Isupvote = data.isupvote
	if self.m_Isupvote == 1 then 
		self.m_PraiseBtn:SetSpriteName("h7_xiaoan_4_1")   	
	else
		self.m_PraiseBtn:SetSpriteName("h7_xiaoan_4")
	end
    self.m_AddFriendBtn:SetActive(true)
	if g_FriendCtrl:IsMyFriend(data.pid) then
		self.m_AddFriendBtn:SetText("已加好友")		
	else
		self.m_AddFriendBtn:SetText("加为好友")	
	end	
    self.m_SendCardBtn:SetActive(false)
	self.m_AwardBtn:SetActive(false)
    self.m_ShowPosBtn:SetActive(false)
    self:SetCardInfo(data)
end

function CAttrCardLinkView.SetCardInfo(self, info)
    local attr = g_AttrCtrl
    if info ~= nil then 
        attr = info
    end 
	self.m_CardPid = attr.pid
	self.m_IsShowPos = attr.position_hide
	self.m_MoodsAmount = attr.upvote_amount
	local rank = attr.rank 
	if rank == 0 or rank == nil then 
		rank = "榜外"
	end
	self.m_InfoGrid:GetChild(5).m_AttrLabel:SetText(attr.score)
	attr.model_info.size  = 1
	
	local model_info =  table.copy(attr.model_info)
	model_info.rendertexSize = 1.2
	model_info.horse = nil
	self.m_ActorTexture:ChangeShape(model_info)

	self.m_MyRank:SetText(rank)
	self.m_SchoolPic:SetSpriteName(tostring(attr.school))
    self.m_NameLabel:SetText(attr.name)
	self.m_LvLabel:SetText("等级: [c][63432C]" .. attr.grade)
	local showID = (attr.show_id and attr.show_id > 0) and attr.show_id or attr.pid
	self.m_Pid:SetText("编号: " .. showID)
	self.m_Moods:SetText(attr.upvote_amount)
	if attr.title_info ~= nil and next(attr.title_info) ~= nil then
		if attr.title_info.name ~= "" then
			self.m_TitleText:SetText(attr.title_info.name)
		end
	end
	if attr.orgname ~= nil and attr.orgname ~= "" then 
		self.m_OrgText:SetText(attr.orgname)
	end
	if self.m_IsShowPos == 1 then
		self.m_Pos:SetText(attr.position)
		self.m_ShowPosBtn:SetSpriteName("h7_xiaoan_6")
	else
		self.m_Pos:SetText("已隐藏")
		self.m_ShowPosBtn:SetSpriteName("h7_xiaoan_7")
	end	
	g_LinkInfoCtrl.m_CurAttrCardLinkView = self	
end


function CAttrCardLinkView.SendMSg(self,idx)
	self.m_ChannelBtns:SetActive(false)
	local channel = self.m_ChannelList[idx]
	if channel == define.Channel.Org then 
		--判断是否有帮派
		if g_OrgCtrl:IamInOrg() == false then 
			g_NotifyCtrl:FloatMsg("您还没有帮派!")
			return
		end	
	end 
	if channel == define.Channel.Team then 
		--判断是否有队伍
		if not g_TeamCtrl:IsJoinTeam() then 
			g_NotifyCtrl:FloatMsg("您还没有队伍!")
			return
		end 
	end 
	CChatMainView:ShowView(function(oView)
		oView:SwitchChannel(channel)
		local applyLink = LinkTools.GenerateAttrCardLink("名片-" .. g_AttrCtrl.name, g_AttrCtrl:GetShowID())
		local msg = applyLink
		oView.m_ChatPage:AppendText(msg)
	end)
	self:OnClose()
end

function CAttrCardLinkView.SendCard(self)
	self.m_ChannelBtns:SetActive(not self.m_ChannelBtns:GetActive())
end

function CAttrCardLinkView.OpenRenameWindow(self)
	if g_AttrCtrl.grade < self.m_RenameMinGrade then 
		g_NotifyCtrl:FloatMsg("你的等级＜10级无法改名!")
		return
	end

	local item = DataTools.GetItemData(10178)
	local cardCount = g_ItemCtrl:GetBagItemAmountBySid(10178)
	local des = "[1d8e00]10≤自身等级≤50[-][63432c],第一次改名免费!"
	if g_AttrCtrl.grade > self.m_RenameMaxGrade or g_AttrCtrl.rename > 0 then
		if cardCount and cardCount > 0 then
			des = "[63432c]本次改名免费[-][63432c](最多6个字)"
		else
			des = "[63432c]本次改名需要消耗[-][1d8e00]"..self.m_NeedGoldCoin.."[-][63432c]#cur_2(最多6个字)"
		end
	end

	local windowInputInfo = {
		des				= des,
		title			= "角色改名",
		inputLimit		= 12,
		defaultCallback = nil,
		okCallback		= function (input)
		 	self:OkRename(input)
		end,
		isclose         = false,
		defaultText		= "请输入新的名字",
	}
	g_WindowTipCtrl:SetWindowInput(windowInputInfo, function (oView)
		self.m_RenameView = oView
	end)
end

function CAttrCardLinkView.OkRename(self, input)
	local g_AttrCtrl = g_AttrCtrl
	--//一个汉字占用三个字节
	if  input:GetInputLength() > 18 then 
		g_NotifyCtrl:FloatMsg("名字长度最多6个字符!")
		return
	end 
	local name = input:GetText()

	if string.len(name) <= 0 then
		g_NotifyCtrl:FloatMsg("请输入新的名字!")
		return
	end

	if g_MaskWordCtrl:IsContainMaskWord(name) or string.isIllegal(name) == false then 
		g_NotifyCtrl:FloatMsg("含有非法字符请重新输入!")
		return
	end

	local cardCount = g_ItemCtrl:GetBagItemAmountBySid(10178)
	if not cardCount or cardCount <= 0 then
		--判断元宝是否需要元宝
		if (g_AttrCtrl.grade > self.m_RenameMaxGrade or g_AttrCtrl.rename > 0) and g_AttrCtrl:GetGoldCoin() < self.m_NeedGoldCoin then
			g_NotifyCtrl:FloatMsg("元宝不足,请充值!")
			g_ShopCtrl:ShowChargeView()
			return
		end
	end

	netplayer.C2GSRename(name)
	if self.m_RenameView then
		self.m_RenameView:OnClose()
	end
end

function CAttrCardLinkView.OnGiveGift(self)
    print("赠送礼物")
end

function CAttrCardLinkView.OnAddFriend(self)
	if self.m_CardPid == g_AttrCtrl.pid then
		g_NotifyCtrl:FloatMsg("不能添加自己为好友!")
		return
	end
	if g_FriendCtrl:IsMyFriend(self.m_CardPid) then
		g_NotifyCtrl:FloatMsg("对方已经是您的好友了!")
		return
	end
	self:OnClose()
	netfriend.C2GSApplyAddFriend(self.m_CardPid)
end

--是否显示位置
function CAttrCardLinkView.OnShowPos(self)
	local hide = self.m_IsShowPos == 0 and 1 or 0
	netplayer.C2GSHidePosition(hide)
end

--点赞
function CAttrCardLinkView.OnPraise(self)
	if g_AttrCtrl.grade < self.m_LikeNeedGrade then 
		g_NotifyCtrl:FloatMsg("点赞需要等级达到"..self.m_LikeNeedGrade.."级!")
		return
	end 
	if self.m_Isupvote == 1 then 
		g_NotifyCtrl:FloatMsg("同一个好友只能点赞一次哦!")
		return
	end 
	if self.m_CardPid then 	
		netplayer.C2GSUpvotePlayer(self.m_CardPid)
	end
end

--打开点赞列表
function CAttrCardLinkView.OnFind(self)
	if self.m_MoodsAmount <= 0 then 
		CCardLikeListView:ShowView(function (oView)
			oView:SetData(nil)
		end)
		return
	end 
	netplayer.C2GSPlayerUpvoteInfo(self.m_CardPid)
end

--添加点赞人数
function CAttrCardLinkView.MoodsAdd(self)
	g_LinkInfoCtrl:SaveAttrCardInfo(self.m_CardPid, 1)
	if self.m_CardPid == g_AttrCtrl.pid then --自己点赞会自动刷新
		return
	end

	self.m_MoodsAmount = self.m_MoodsAmount + 1	
	self.m_Moods:SetText(self.m_MoodsAmount)
	self.m_Isupvote = 1
	self.m_PraiseBtn:SetSpriteName("h7_xiaoan_4_1")
end

function CAttrCardLinkView.OnRank(self)  
	CMoodsRankView:ShowView(function (oView)
		local info = g_AttrCtrl.upvoteInfo[1]  --打开默认显示第一页
		oView:SetInfo(info)
	end)
end 

function CAttrCardLinkView.OnAward(self)
	CUpvoteRwardView:ShowView(function (oView)	
	end)
end

return CAttrCardLinkView