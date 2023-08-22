local CItemSevenDayBox = class("CItemSevenDayBox", CBox)

function CItemSevenDayBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self:InitContent()
end

function CItemSevenDayBox.InitContent(self)
	self.m_HuluSp = self:NewUI(1, CSprite)
	self.m_HuluLightSp = self:NewUI(2, CSprite)
	self.m_GotSp = self:NewUI(3, CSprite)
	self.m_Hint = self:NewUI(4, CSprite)
	self.m_IdxTop = self:NewUI(5, CLabel)
	self.m_IdxBottom = self:NewUI(6, CLabel)

	self:AddUIEvent("click", callback(self, "OnItemClick"))
end

function CItemSevenDayBox.SetData(self, data)

	self.m_Day = data.day

	self.m_IdxTop:SetText("#mark_"..data.day)
	self.m_IdxBottom:SetText("#mark_"..data.day)
	
	-- 最后一个葫芦改变造型
	if data.day == 7 then
		self.m_HuluSp:SetSpriteName("h7_hulu_3")
		self.m_HuluSp:MakePixelPerfect()
	end
	self:RefreshBox()
end

function CItemSevenDayBox.SetBoxState(self, state)
	local startTime = g_TimelimitCtrl:GetSevenDayDuration()
	if g_TimeCtrl:GetTimeS() < startTime then
		self:SetItemColorDark(true)
		self.m_HuluLightSp:SetActive(false) --可领取
		self.m_GotSp:SetActive(false)
		self.m_State = 0
		return
	end
	
	self.m_HuluLightSp:SetActive(state == 1) --可领取
	self.m_GotSp:SetActive(state == 2)  --已领取

	self:SetItemColorDark(not state)
end

function CItemSevenDayBox.SetItemColorDark(self, iDark)
	local color = Color.RGBAToColor("ffffff")	
	if iDark then
		color = Color.RGBAToColor("a19887")	
	end
	self.m_HuluSp:SetColor(color)  --日期未到，不能领取
	self.m_Hint:SetColor(color)
end

function CItemSevenDayBox.GetRewardList(self, day)

	local reward = DataTools.GetHuodongData("SEVENLOGIN")
	local rewardlist = DataTools.GetRewardItems("SEVENLOGIN", reward[day].rewardidx)
	return rewardlist
end

function CItemSevenDayBox.OnItemClick(self)

	local itemlist = self:GetRewardList(self.m_Day)
	local titleText = string.number2text(self.m_Day)

	local str = "星葫芦"
	local title = titleText..str

	local args = {
		showSelSpr = false,
		title = title,
        desc = "领取宝箱将获得丰厚奖励",
        items = itemlist,
        comfirmText = "领取",
		}

	if self.m_State == 1 then
		args.comfirmCb = function()
			local curDay = g_TimelimitCtrl:GetCurLoginDay()
			g_TimelimitCtrl:C2GSSevenDayGetReward(curDay)		
		end
		args.desc = ""
	end

	g_WindowTipCtrl:ShowItemBoxView(args)
end

--领取后刷新宝箱
function CItemSevenDayBox.RefreshBox(self)
	local rewardList = g_TimelimitCtrl.m_SevenDayRewardList
	if self.m_Day == nil then
		return
	end

	local index = self.m_Day
	self.m_State = rewardList[index]
	self:SetBoxState(self.m_State)
end

return CItemSevenDayBox