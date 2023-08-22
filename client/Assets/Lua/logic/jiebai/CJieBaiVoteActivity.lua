local CJieBaiVoteActivity = class("CJieBaiVoteActivity", CBox)

function CJieBaiVoteActivity.ctor(self, obj)

	CBox.ctor(self, obj)
    self.m_Post = self:NewUI(1, CLabel)
    self.m_AgreeBtn = self:NewUI(2, CSprite)
    self.m_DisAgreeBtn = self:NewUI(3, CSprite)
    self.m_Time = self:NewUI(4, CLabel)

    self:InitContent()

end

function CJieBaiVoteActivity.InitContent(self)
    
	self.m_AgreeBtn:AddUIEvent("click", callback(self, "OnClickAgree"))
	self.m_DisAgreeBtn:AddUIEvent("click", callback(self, "OnClickDisAgree"))

end

function CJieBaiVoteActivity.SetInfo(self, info)
	
	self.m_AvtivityInfo = info
	local post = info.post
	self.m_Post:SetText(post)

	local sponsorPid = info.sponsorPid

	if sponsorPid == g_AttrCtrl.pid then 
		self.m_AgreeBtn:SetActive(false)
		self.m_DisAgreeBtn:SetActive(false)
	else
		self.m_AgreeBtn:SetActive(true)
		self.m_DisAgreeBtn:SetActive(true)
	end

	self.m_IsHadVote = g_JieBaiCtrl:IsHadVote()

	self.m_AgreeBtn:SetGrey(self.m_IsHadVote)
	self.m_DisAgreeBtn:SetGrey(self.m_IsHadVote)

	self:RefreshTime()
	
end

function CJieBaiVoteActivity.RefreshTime(self)
	
	local remainTime = self.m_AvtivityInfo.remainTime
	if remainTime then 
		local leftTime = g_JieBaiCtrl:GetJieBaiLeftTime()
		local cb = function (time)
		    if not time then 
		        self.m_Time:SetActive(false)
		    else
		        self.m_Time:SetText("[244B4EFF]投票[-][a64e00ff]" .. time .. "[-][244B4EFF]后过期[-]")
		        self.m_Time:SetActive(true)
		    end 
		end
		g_TimeCtrl:StartCountDown(self, remainTime, 4, cb)
	end 

end

function CJieBaiVoteActivity.OnClickAgree(self)
	
	if self.m_IsHadVote then 
		g_NotifyCtrl:FloatMsg("已经投过票了")
	end 

	g_JieBaiCtrl:C2GSJBVoteKickMember(1)

end

function CJieBaiVoteActivity.OnClickDisAgree(self)
	
	if self.m_IsHadVote then 
		g_NotifyCtrl:FloatMsg("已经投过票了")
	end 
	g_JieBaiCtrl:C2GSJBVoteKickMember(2)

end


return CJieBaiVoteActivity