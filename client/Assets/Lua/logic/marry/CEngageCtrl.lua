local CEngageCtrl = class("CEngageCtrl", CCtrlBase)

function CEngageCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_Members = nil
	self.m_Type = 2
	self.m_IsCannotMove = false
	self.m_IsShowRingRed = false
	self.m_EngageStatus = false
end

CEngageCtrl.m_IconCnfig = {
	[12929] = {atlas = "MarryAtlas", icon = "h7_yinjz", color = {top = "ffffff", bottom = "a2edf5", shadow = "125473"} },
	[12930] = {atlas = "MarryAtlas", icon = "h7_jinjz", color = {top = "fff8b0", bottom = "fbc85f", shadow = "682c12"} },
	[12931] = {atlas = "MarryAtlas", icon = "h7_zhuanjz", color = {top = "fffeb0", bottom = "cfb8ff", shadow = "801b1b"} },
}
CEngageCtrl.m_RingEffect = {"Seliver", "Gold", "Diamond"}

function CEngageCtrl.GetEngageConfig()
	local config = {}
	config.cost = data.engagedata.CONFIG.dissolve_silver --离婚消耗
	config.degree = data.engagedata.CONFIG.re_marry_friend_piont --好友值
	return config
end

function CEngageCtrl.GetAllRingConfig(self)
	local RingData = {}
	local len = #data.engagedata.TYPE
	for i=1, len do
		local data = self:GetRingConfig(i)
		RingData[i] = data
	end
	return RingData
end

function CEngageCtrl.GetRingConfig(self, _type)
	local _type = _type or self.m_Type
	local dConfig = {}
	local data = DataTools.GetEngageData("TYPE", _type)
	local item = self.m_IconCnfig[data.cost]

	dConfig.type = data.type
	dConfig.desc = data.desc
	dConfig.atlas = item.atlas
	dConfig.icon = item.icon
	dConfig.color = item.color
	dConfig.sid = data.cost
	dConfig.ringEffect = self.m_RingEffect[data.type]

	return dConfig
end

function CEngageCtrl.GetNpcModelInfo(self)
	local modelConfig = ModelTools.GetModelConfig(3115)
	local pos = Vector3.New(0, modelConfig.posy, 3)
	local model_info = {figure = 3115}
	model_info.pos = pos
	model_info.talkState = true
	model_info.horse = nil
	return model_info
end

function CEngageCtrl.GetTeamInfo(self)
	local teamID = g_TeamCtrl.m_TeamID
	local teamInfo = g_MapCtrl:GetTeamInfo(teamID)
	return teamInfo
end

function CEngageCtrl.GetTeamParterName(self)
	local teamInfo = self:GetTeamInfo()
	for i, v in ipairs(teamInfo) do
		if v ~= g_AttrCtrl.pid then
			local oPlayer = g_MapCtrl:GetPlayer(v)
			local name = oPlayer.m_Name
			return name
		end
	end
end

function CEngageCtrl.GetPartnerInfo(self)
	return self.m_Members[2]
end

function CEngageCtrl.GetCDissolveEngageResume(self)
	local etype = g_AttrCtrl.engageInfo.etype
	local typedata = data.engagedata.TYPE[etype]
	if g_AttrCtrl.engageInfo.active == 1 then
		return typedata.dissolve_silver
	else
		return typedata.dissolve_silver2
	end
end

function CEngageCtrl.IsRingGift(self, sid)
	if self.m_IconCnfig[sid] then
		return true
	end
	return false
end

function CEngageCtrl.CheckIsCannotMove(self)
	if self.m_IsCannotMove then
		return true
	end
end

function CEngageCtrl.ContainsMaskWordAndHighlight(self, str, cinput, msg)
	local charList = g_MaskWordCtrl:GetCharList(str)
	local reaplceStr = g_MaskWordCtrl:ReplaceMaskWord(str, true)
    local charList2 = g_MaskWordCtrl:GetCharList(reaplceStr)

    -- 比较 CharList & CharList2，看是否有敏感词
    local contained = false
    local startIdx = 0
    local endIdx = 0
    for i = 1, #charList do  -- 替换时参数为 true 保证了 charList, charList2 长度相等
        if charList[i] ~= charList2[i] then  -- 被替换了，记录 startIdx, endIdx
            contained = true
            if startIdx == 0 then
                startIdx = i
            end
        else
            if startIdx > 0 then
                endIdx = i - 1
                break
            end
        end
    end
    if startIdx > 0 and endIdx == 0 then  -- 敏感词在末尾
        endIdx = #charList
    end

    -- 有敏感词，替换并飘字提示
    if contained then
        -- printc("有敏感词, [" .. startIdx .. ", " .. endIdx .. "]")
        g_NotifyCtrl:FloatMsg(msg)
        local coloredStr = ""
        for i = 1, #charList do
            if i == startIdx then
                coloredStr = coloredStr .. "#R" .. charList[i]  -- 敏感词替换为红色
            elseif i == endIdx then
                coloredStr = coloredStr .. charList[i] .. "#n"
            else
                coloredStr = coloredStr .. charList[i]
            end
        end
        coloredStr = "[c][896055FF]" .. coloredStr .. "[-]"

        --cinput.activeTextColor = Color.clear
        --coverLabel:SetColor(Color.white)
        cinput:SetText("")
        cinput:SetDefaultText(coloredStr)
        return true
    end
    return false

end

function CEngageCtrl.ShowEngageGiftView(self)
	local dConfig = DataTools.GetViewOpenData(define.System.Engage)
	local pLevel = dConfig.p_level
	if g_AttrCtrl.grade >= pLevel then
		CEngageGiftSelectView:ShowView()
	else
		local text = string.format("%d级才能订婚", pLevel)
		g_NotifyCtrl:FloatMsg(text)
	end
end

function CEngageCtrl.SetEngageCondition(self, members, type, status)
	if members then
		self.m_Members = members
	end
	if type then
		self.m_Type = type
	end
	
	local condition = self:CheckEngageCondition()

	CEngageConfirmView:ShowView(function(oView)
		oView:ShowConfirmUI(condition, status)
	end)

	self.m_IsCannotMove = true
	self.m_EngageStatus = true
end

function CEngageCtrl.CheckEngageCondition(self)
	local condition = {}
	local bOpositeSex, bLevel, bDegree, bSingle = false, false, false, false

	local dConfig = DataTools.GetViewOpenData(define.System.Engage)
	local pLevel = dConfig.p_level
	local degree = data.engagedata.CONFIG.re_marry_friend_piont
	local p1, p2 = self.m_Members[1], self.m_Members[2]
	if p1 and p2 then
		bOpositeSex = p1.sex ~= p2.sex
		bLevel = p1.grade >= pLevel and p2.grade >= pLevel
		bSingle = p1.couple == 1 and p2.couple == 1
		bDegree = p1.degree >= degree and p2.degree >= degree
	end
	table.insert(condition, {bCondition = bOpositeSex, descID = 3002}) --互为异性
	table.insert(condition, {bCondition = bLevel, descID = 3003}) --和队友都满足等级
	table.insert(condition, {bCondition = bDegree, descID = 3005}) --满足好友度
	table.insert(condition, {bCondition = bSingle, descID = 3004}) --都是单身

	return condition
end

function CEngageCtrl.OnEngageTextRusult(self)
	local oView = g_ViewCtrl:GetView(CEngageDeclarationView)
	if oView then
		oView:HideBtn()
	end
end

function CEngageCtrl.OnEngageFail(self)
	-- 订婚失败
	self:OnEvent(define.Engage.Event.EngageFail)
	self.m_EngageStatus = false
	if g_HotTopicCtrl.m_HotCallback then
		g_HotTopicCtrl:m_HotCallback()
		g_HotTopicCtrl.m_HotCallback = nil
	elseif g_HotTopicCtrl.m_SignCallback then
		g_HotTopicCtrl:m_SignCallback()
		g_HotTopicCtrl.m_SignCallback = nil
	end
end

function CEngageCtrl.ShowEngageSuccess(self)
	--订婚成功
	self:OnEvent(define.Engage.Event.EngageSuccess)
	self.m_EngageStatus = false
	self.m_IsShowRingRed = true

	if g_HotTopicCtrl.m_HotCallback then
		g_HotTopicCtrl:m_HotCallback()
		g_HotTopicCtrl.m_HotCallback = nil
	elseif g_HotTopicCtrl.m_SignCallback then
		g_HotTopicCtrl:m_SignCallback()
		g_HotTopicCtrl.m_SignCallback = nil
	end
end

return CEngageCtrl