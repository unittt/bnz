local CRebateJoyCtrl = class("CRebateJoyCtrl", CCtrlBase)

function CRebateJoyCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:CheckRewardConfig()
	self:Clear()
	-- self:ResetEightLoginGuide()
end

function CRebateJoyCtrl.Clear(self)
	self.m_IsOpenState = false
	self.m_EndTime = 0
	self.m_ModelId = 0
	self.m_RewardList = {}
	self.m_RewardHashList = {}
	self.m_ConsumeGoldCoin = 0
	self.m_MainConfig = nil
	self.m_RewardConfig = nil
	self.m_RewardSortConfig = nil
	self.m_IsFirstInit = false
	self.m_FanliMultiple = 0
	self.m_ActualFanliMultiple = 0
	self.m_FanliFlag = 0
end

function CRebateJoyCtrl.ResetEightLoginGuide(self)
	CGuideData.EightLogin={
		complete_type=0,
		exceptview = {}, --"CWelfareView", "CYoukaLoginView"
		guide_list={
			[1]={
				click_continue=false,
				effect_list={
					[1]={
						effect_type=[[texture]],
						fixed_pos={x=-0.25+0.24,y=0.125,},
						flip_y=true,
						play_tween=false,
						texture_name=[[guide_1.png]],
					},
					[2]={
						dlg_sprite=[[h7_zhiyinkuang]],
						effect_type=[[dlg]],
						fixed_pos={x=-0.25,y=0.125,},
						play_tween=false,
						text_list={[1]=[[哇，大波福利来啦！]],},
						audio_list={[1]=[[Model/xsydy5.mp3]],},
					},
					[3]={
						effect_type=[[click_ui]],
						offset_pos={x=0,y=0,},
						offset_rotate=0,
						ui_effect=[[Finger]],
						ui_key=[[mainmenu_welfare_btn]],
					},
					[4]={
						effect_type=[[arrowright]],
						offsetx = 286,
					},
				},
				necessary_ui_list={[1]=[[mainmenu_welfare_btn]],},
			},
			[2]={
				click_continue=false,
				effect_list={
					[1]={
						effect_type=[[texture]],
						fixed_pos={x=-0.07,y=0.2,},
						flip_y=true,
						play_tween=false,
						texture_name=[[guide_1.png]],
					},
					[2]={
						dlg_sprite=[[h7_zhiyinkuang]],
						effect_type=[[dlg]],
						fixed_pos={x=-0.07+0.12,y=0.2,},
						play_tween=false,
						text_list={[1]=[[点击八日登录标签]],},
						audio_list={[1]=[[Model/xsydy6.mp3]],},
					},
					[3]={
						effect_type=[[click_ui]],
						offset_pos={x=0,y=0,},
						offset_rotate=0,
						ui_effect=[[Finger]],
						ui_key=[[eightlogin_tab_btn]],
					},
				},
				necessary_ui_list={[1]=[[eightlogin_tab_btn]],},
			},
			[3]={
				click_continue=false,
				effect_list={
					[1]={
						effect_type=[[texture]],
						fixed_pos={x=0+0.28,y=-0.2,},
						flip_y=true,
						play_tween=false,
						texture_name=[[guide_1.png]],
					},
					[2]={
						dlg_sprite=[[h7_zhiyinkuang]],
						effect_type=[[dlg]],
						fixed_pos={x=0,y=-0.1,},
						play_tween=false,
						text_list={[1]=[[有一份礼物可以领取哦]],},
					},
					[3]={
						effect_type=[[click_ui]],
						offset_pos={x=0,y=0,},
						offset_rotate=0,
						ui_effect=[[Finger]],
						ui_key=[[eightlogin_get_btn]],
					},
					[4]={
						effect_type=[[arrowright]],
						offsetx = 311,
					},
				},
				necessary_ui_list={[1]=[[eightlogin_get_btn]],},
			},
			[4]={
				click_continue=false,
				effect_list={
					[1]={
						effect_type=[[texture]],
						fixed_pos={x=0.125,y=0.25,},
						flip_y=false,
						play_tween=false,
						texture_name=[[guide_1.png]],
					},
					[2]={
						dlg_sprite=[[h7_zhiyinkuang]],
						effect_type=[[dlg]],
						fixed_pos={x=0.125+0.12,y=0.25,},
						play_tween=false,
						text_list={[1]=[[关闭界面吧]],},
						audio_list={[1]=[[Model/xsydy7.mp3]],},
					},
					[3]={
						effect_type=[[click_ui]],
						offset_pos={x=0,y=0,},
						offset_rotate=0,
						ui_effect=[[Finger]],
						ui_key=[[welfareview_close_btn]],
					},
				},
				necessary_ui_list={[1]=[[welfareview_close_btn]],},
			},
		},
		necessary_condition=[[eightlogin_open]],
	}
end

function CRebateJoyCtrl.GS2CJoyExpenseState(self, pbdata)
	self.m_IsOpenState = pbdata.state == 1
	self.m_EndTime = pbdata.end_time
	self.m_ModelId = pbdata.mode_id

	if data.rebatejoydata.CONFIG.reward_new.mode_id == self.m_ModelId then
		self.m_MainConfig = data.rebatejoydata.CONFIG.reward_new
		self.m_RewardConfig = data.rebatejoydata.REWARDNEW
		self.m_RewardSortConfig = self.m_RewardNewConfig
	elseif data.rebatejoydata.CONFIG.reward_old.mode_id == self.m_ModelId then
		self.m_MainConfig = data.rebatejoydata.CONFIG.reward_old
		self.m_RewardConfig = data.rebatejoydata.REWARDOLD
		self.m_RewardSortConfig = self.m_RewardOldConfig
	end
	if g_RebateJoyCtrl.m_MainConfig then
		netshop.C2GSEnterShop(g_RebateJoyCtrl.m_MainConfig.shop_id)
	end
	self:OnEvent(define.RebateJoy.Event.JoyExpenseState)
	self:OnEvent(define.RebateJoy.Event.JoyExpenseRedPoint)
end

function CRebateJoyCtrl.GS2CJoyExpenseRewardState(self, pbdata)
	self.m_RewardList = pbdata.reward_list
	self.m_RewardHashList = {}
	for k,v in pairs(pbdata.reward_list) do
		self.m_RewardHashList[v.expense_id] = v
	end
	self:OnEvent(define.RebateJoy.Event.JoyExpenseRewardState)
	self:OnEvent(define.RebateJoy.Event.JoyExpenseRedPoint)
end

function CRebateJoyCtrl.GS2CJoyExpenseGoldCoin(self, pbdata)
	self.m_ConsumeGoldCoin = pbdata.goldcoin
	self:OnEvent(define.RebateJoy.Event.JoyExpenseGoldCoin)
end

function CRebateJoyCtrl.GS2CRplGoldCoinGift(self, pbdata)
	self.m_FanliMultiple = pbdata.multiple
	self.m_ActualFanliMultiple = pbdata.multiple/100
	self.m_FanliFlag = pbdata.flag
	self:OnEvent(define.RebateJoy.Event.RelGoldCoinGift)
end

function CRebateJoyCtrl.CheckIsRebateJoyOpen(self)
	return g_OpenSysCtrl:GetOpenSysState(define.System.RebateJoy) and self.m_IsOpenState
end

function CRebateJoyCtrl.CheckIsRebateJoyRedPoint(self)
	if not self.m_IsOpenState then
		return false
	end
	for k,v in pairs(self.m_RewardList) do
		if v.reward_state == 1 then
			return true
		end
	end
	return false
end

function CRebateJoyCtrl.CheckIsShopYouhui(self)
	return self.m_FanliFlag == 1
end

function CRebateJoyCtrl.CheckIsRebateCircu(self, bIsRedPoint)
	if bIsRedPoint == nil then
		return not self.m_IsFirstInit or g_RebateJoyCtrl:CheckIsRebateJoyRedPoint()
	else
		return not self.m_IsFirstInit or bIsRedPoint
	end
end

function CRebateJoyCtrl.CheckRewardConfig(self)
	self.m_RewardNewConfig = {}
	for k,v in pairs(data.rebatejoydata.REWARDNEW) do
		table.insert(self.m_RewardNewConfig, v)
	end
	table.sort(self.m_RewardNewConfig, function (a, b)
		return a.id < b.id
	end)

	self.m_RewardOldConfig = {}
	for k,v in pairs(data.rebatejoydata.REWARDOLD) do
		table.insert(self.m_RewardOldConfig, v)
	end
	table.sort(self.m_RewardOldConfig, function (a, b)
		return a.id < b.id
	end)
end

return CRebateJoyCtrl