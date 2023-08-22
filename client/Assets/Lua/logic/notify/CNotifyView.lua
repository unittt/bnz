local CNotifyView = class("CNotifyView", CViewBase)

function CNotifyView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Notify/NotifyView.prefab", cb)
	-- self.m_DepthType = "Notify"
	self.m_DepthType = "BeyondGuide"
	self.m_DelayTimer = nil
	self.m_SmsgTimer = nil
end

function CNotifyView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_OrderBtn = self:NewUI(2, CButton)
	self.m_GMShopBtn = self:NewUI(3, CButton)
	self.m_MainMenuBtn = self:NewUI(4, CButton)
	self.m_FloatTable = self:NewUI(5, CBox)
	self.m_FloatBoxClone = self:NewUI(6, CFloatBox)
	self.m_HintBox = self:NewUI(7, CHintBox)
	self.m_ProgressBar = self:NewUI(8, CProgressBox)
	self.m_RumorBox = self:NewUI(9, CRumorBox)
	self.m_TreasureBoxParent = self:NewUI(10, CBox)
	self.m_NpcListBox = self:NewUI(11, CNpcListBox)

	local oListBox = self:GetObject(11):Instantiate()
	oListBox.transform:SetParent(self.m_NpcListBox:GetParent())
	oListBox.transform.localScale = Vector3.one
	self.m_WarriorListBox = CWarriorListBox.New(oListBox)

	self.m_FloatAudioBox = self:NewUI(12, CFloatAudioBox)
	self.m_RedPacketItem = self:NewUI(13, CBox)
	self.m_RedPacketGetBtn = self:NewUI(14, CBox)
	self.m_FloatPieceObj = self:NewUI(15, CWidget)
	self.m_FloatPieceClone = self:NewUI(16, CBox)
	self.m_RedPacketEffect = self:NewUI(17, CWidget)
	self.m_LockScreen  = self:NewUI(18, CLockScreenBox)
	self.m_TaskDoneEffect = self:NewUI(19, CWidget)
	self.m_TreasurePrizeEffect = self:NewUI(20, CWidget)
	self.m_SysOpenBox = self:NewUI(21, CBox)
	self.m_FlowerEffect = self:NewUI(22, CWidget)
	self.m_DisableAreaWidget = self:NewUI(23, CBox)
	self.m_ScreenWidget = self:NewUI(24, CWidget)
	self.m_ChapterOpen = self:NewUI(25, CBox)
	self.m_IngotTipsSpr = self:NewUI(26, CSprite)
	self.m_IngotTipsLabel1 = self:NewUI(27, CLabel)
	self.m_IngotTipsLabel2 = self:NewUI(28, CLabel)
	self.m_NetCircle = self:NewUI(29, CBox)
	-- 内存打印在面板上
	self.m_MenoryBox = self:NewUI(30, CMenoryBox)
	self.m_FloatLabel = self:NewUI(31, CLabel)
	self.m_StatsBox = self:NewUI(32, CStatsBox)

	self.m_PowerSaveLayer = self:NewUI(33, CTexture)

	self.m_FloatItemList = {}
	self.m_FloatPieceList = {}
	self.m_LastTween = nil
	self.m_EnableCache = true

	self:InitContent()
end

function CNotifyView.InitContent(self)
	-- self.m_MainMenuBtn:SetText("缓存")
	UITools.ResizeToRootSize(self.m_Container)

	self:ResetGM()
	self:InitFloatMsgBox()
	self:InitFloatItemBox()
	self:InitSysOpenBox()
	self:InitChapterOpenBox()
	self:InitNetBusyBox()

	self.m_DisableAreaLbl = self.m_DisableAreaWidget:NewUI(1, CLabel)
	self.m_RedPacketGetBtn2 = self.m_RedPacketItem:NewUI(2, CBox)
	
	self.m_TreasureBoxParent:SetActive(true)

	self.m_MenoryBox:SetActive(false)
	self.m_StatsBox:SetActive(false)
	self.m_FloatBoxClone:SetActive(false)
	self.m_HintBox:SetActive(false)
	self.m_ProgressBar:SetActive(false)
	self.m_NpcListBox:SetActive(false)
	self.m_WarriorListBox:SetActive(false)
	self.m_FloatAudioBox:SetActive(false)
	self.m_RedPacketItem:SetActive(false)
	self.m_FloatPieceClone:SetActive(false)
	self.m_LockScreen:SetActive(false)
	self.m_SysOpenBox:SetActive(false)
	self.m_DisableAreaWidget:SetActive(false)
	self.m_DisableAreaLbl:SetActive(false)
	self.m_IngotTipsSpr:SetActive(false)
	self.m_NetCircle:SetActive(false)
	UITools.ResizeToRootSize(self.m_SysOpenClickWidget)
	UITools.ResizeToRootSize(self.m_PowerSaveLayer, 4, 4)

	self.m_OrderBtn:AddUIEvent("click", callback(self, "OnOrder"))
	self.m_GMShopBtn:AddUIEvent("click", callback(self, "OnGMShop"))
	self.m_RedPacketGetBtn:AddUIEvent("click", callback(self, "OnClickRedPacketGet"))
	self.m_RedPacketGetBtn2:AddUIEvent("click", callback(self, "OnClickRedPacketGet"))
	self.m_MainMenuBtn:AddUIEvent("click", callback(self, "OnClickMainMenu"))
	self.m_SysOpenClickWidget:AddUIEvent("click", callback(self, "OnClickSysOpenClickWidget"))
	self.m_DisableAreaWidget:AddUIEvent("click", callback(self, "OnClickDisableWidget"))
	g_ChatCtrl:AddCtrlEvent("click", callback(self, "OnChatEvent"))
	g_AttrCtrl:AddCtrlEvent("click", callback(self, "OnAttrEvent"))
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWarEvent"))
	g_EngageCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEngageEvent"))
	--g_MainMenuCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnUpdateScoreEvent"))
	g_UITouchCtrl:TouchOutDetect(self.m_IngotTipsSpr, callback(self.m_IngotTipsSpr, "SetActive", false))
end

function CNotifyView.InitFloatMsgBox(self)
	self.m_FloatTable:SetActive(true)
	self.m_FloatBoxList = {}
	self.m_FloatBoxHashList = {}
	for i = 1, 3 do
		local oBox = self.m_FloatTable:NewUI(i, CBox)
		oBox.m_FloatLabel = oBox:NewUI(1, CLabel)
		oBox.m_BgSprite = oBox:NewUI(2, CSprite)
		oBox.m_ItemIconSp = oBox:NewUI(3, CSprite)
		oBox.m_ItemCountLbl = oBox:NewUI(4, CLabel)
		oBox.m_ItemIconSp:SetActive(false)
		oBox.m_ItemCountLbl:SetActive(false)
		oBox.m_Index = i
		oBox.m_Key = i
		oBox.m_IsUsing = false
		oBox:SetActive(false)
		table.insert(self.m_FloatBoxList, oBox)
		self.m_FloatBoxHashList[oBox.m_Index] = oBox
	end
	self.m_FloatMsgList = {}
	self.m_FloatStartY = 15
	self.m_FloatPosList = {Vector3.New(0, 165, 0), Vector3.New(0, 115, 0),  Vector3.New(0, 65, 0)}
	self.m_FloatHideTime = {1.2, 1.4, 1.6}
end

function CNotifyView.InitFloatItemBox(self)
	self.m_FloatItemSprList = {}
	for i = 1, 15 do
		local oItemSpr = self.m_TreasureBoxParent:NewUI(i, CSprite)
		table.insert(self.m_FloatItemSprList, oItemSpr)
	end
end

function CNotifyView.InitSysOpenBox(self)
	self.m_SysOpenClickWidget = self.m_SysOpenBox:NewUI(2, CWidget)
	self.m_SysTexBg = self.m_SysOpenBox:NewUI(3, CTexture)
	self.m_SysTotalBg = self.m_SysOpenBox:NewUI(4, CObject)
end

function CNotifyView.InitNetBusyBox(self)
	self.m_NetCircle.m_CircleSprite = self.m_NetCircle:NewUI(1, CSprite)
	self.m_NetCircle.m_SubSprite = self.m_NetCircle:NewUI(2, CSprite)
	self.m_NetCircle.m_TipLabel = self.m_NetCircle:NewUI(3, CLabel)
end

function CNotifyView.InitChapterOpenBox(self)
	self.m_ChapterOpenTitleSp1 = self.m_ChapterOpen:NewUI(1, CSprite)
	self.m_ChapterOpenTitleSp2 = self.m_ChapterOpen:NewUI(2, CSprite)
	self.m_ChapterOpenTitleSp3 = self.m_ChapterOpen:NewUI(3, CSprite)
	self.m_ChapterOpenMaskTexture = self.m_ChapterOpen:NewUI(4, CTexture)
end

function CNotifyView.OnWarEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.WarStart or oCtrl.m_EventID == define.War.Event.WarEnd then
		self:ShowRedPacket()
	end
end

function CNotifyView.OnEngageEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Engage.Event.EngageSuccess then
		self:PlayEngageEffect()
	end
end

--订婚特效
function CNotifyView.PlayEngageEffect(self)
	local idx = g_EngageCtrl.m_Type
	local pathlist = {
		[2] = "Effect/UI/ui_eff_0086/Prefabs/ui_eff_0086.prefab", 
		[3] = "Effect/UI/ui_eff_0087/Prefabs/ui_eff_0087.prefab",
	}
	if self.m_Effect == nil and idx ~= 1 then
		local path = pathlist[idx]
		local function PlayCallback()
			local function func()
				if self.m_Effect == nil then
    				return false
    			end
				self.m_Effect:Destroy()
				self.m_Effect = nil
				return false
			end
			self.m_Timer = Utils.AddTimer(func, 0.1, 5)
		end
		self.m_Effect = CEffect.New(path, self:GetLayer(), false, PlayCallback)

		if self.m_Effect then
			self.m_Effect:SetParent(self.m_Transform)
			self.m_Effect:SetLocalPos(Vector3.zero)
		end
	end
end

function CNotifyView.ResetGM(self)
	local showOrderBtn = Utils.IsEditorOrGM()
	self.m_OrderBtn:SetActive(showOrderBtn)
	self.m_GMShopBtn:SetActive(showOrderBtn)
	self.m_MainMenuBtn:SetActive(showOrderBtn)
end

function CNotifyView.OnChatEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Chat.Event.AddMsg then
		local oMsg = oCtrl.m_EventData
		if self.m_HideEffMsg then return end
		if oMsg:IsHorseRace() then
			self.m_RumorBox:SetActive(true)
			self.m_RumorBox:AddMsg(oMsg)
		end
	end
	-- if oCtrl.m_EventID == define.Chat.Event.SetChuanyinPos then
	--    self:ResetBubblePos()
	-- end
end

function CNotifyView.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Gm then
		self:ResetGM()
	end
end

function CNotifyView.OnClickIngot(self, parent)
		local oUICamera = g_CameraCtrl:GetUICamera()
    	if g_AttrCtrl.rplgoldcoin >0 then
        	self.m_IngotTipsLabel1:SetText(g_AttrCtrl.goldcoin)
        	self.m_IngotTipsLabel2:SetText(g_AttrCtrl.rplgoldcoin)
        	local Width1 = self.m_IngotTipsLabel1:GetWidth()
        	local Width2 = self.m_IngotTipsLabel2:GetWidth()
        	if Width1 > Width2 then
        		self.m_IngotTipsSpr:SetWidth(Width1 +65)
        	else
        		self.m_IngotTipsSpr:SetWidth(Width2 +65)
        	end

       	 	if self.m_DelayTimer then
            	Utils.DelTimer(self.m_DelayTimer)
            	self.m_DelayTimer = nil
        	end
        	self.m_IngotTipsSpr:SetActive(true)
        	local time = 3
        	local function fun()
        	    time = time - 1
            	if time < 0 then	
             	   self.m_IngotTipsSpr:SetActive(false)
                	return false
            	else
                	return true
            	end
        	end
       	 	self.m_DelayTimer = Utils.AddTimer(fun, 1 ,0)

        	if parent then
        		local spos = oUICamera:WorldToScreenPoint(parent:GetPos())
        		spos = spos + Vector3.New(0,50,0)
        		local wpos = oUICamera:ScreenToWorldPoint(spos)
        		self.m_IngotTipsSpr:SetPos(wpos)
        	end
   		end

end

function CNotifyView.OnClickMainMenu(self)
	if g_MainMenuCtrl:IsExpand() then
		g_MainMenuCtrl:HideAreas(define.MainMenu.HideConfig.Default)
	else
		g_MainMenuCtrl:ShowMainFunctionArea()
		g_MainMenuCtrl:ShowAllArea()
	end
end

function CNotifyView.OnOrder(self, oBtn)
	CGmMainView:ShowView()
end

function CNotifyView.OnGMShop(self)
	CGMShopMainView:ShowView()
end

function CNotifyView.OnClickRedPacketGet(self)
	if next(g_RedPacketCtrl.m_MainViewRedPacketList) then
		netredpacket.C2GSRobRP(g_RedPacketCtrl.m_MainViewRedPacketList[1].id)
		table.remove(g_RedPacketCtrl.m_MainViewRedPacketList, 1)
		if next(g_RedPacketCtrl.m_MainViewRedPacketList) then
			self.m_RedPacketItem:SetActive(true)
			if g_WarCtrl:IsWar() then
				self.m_RedPacketGetBtn:SetActive(false)
				self.m_RedPacketGetBtn2:SetActive(true)
			else
				self.m_RedPacketGetBtn:SetActive(true)
				self.m_RedPacketGetBtn:NewUI(3, CLabel):SetText(g_RedPacketCtrl.m_MainViewRedPacketList[1].ownername)
				self.m_RedPacketGetBtn2:SetActive(false)
			end
			self.m_RedPacketGetBtn:SetLocalEulerAngles(Vector3.New(0, 0, 45))
			self.m_RedPacketGetBtn2:SetLocalEulerAngles(Vector3.New(0, 0, 45))
			if self.m_LastTween then
				self.m_LastTween:Kill(false)
			end
			if self.m_LastTween2 then
				self.m_LastTween2:Kill(false)
			end
			local tween = DOTween.DOLocalRotate(self.m_RedPacketGetBtn.m_Transform, Vector3.New(0, 0, -45), 1)
			--Restart 0, Yoyo 1, Incremental 2
			DOTween.SetLoops(tween, -1, 1)
			self.m_LastTween = tween

			local tween2 = DOTween.DOLocalRotate(self.m_RedPacketGetBtn2.m_Transform, Vector3.New(0, 0, -45), 1)
			DOTween.SetLoops(tween2, -1, 1)
			self.m_LastTween2 = tween2
		else
			self.m_RedPacketItem:SetActive(false)
		end		
	else
		self.m_RedPacketItem:SetActive(false)
	end
end

function CNotifyView.ShowHint(self, text, nearWidget, nearType, offset)
	self.m_HintBox:SetActive(true)
	self.m_HintBox:SetHintText(text)
	UITools.NearTarget(nearWidget, self.m_HintBox, nearType, offset)
	g_UITouchCtrl:TouchOutDetect(self.m_HintBox, callback(self.m_HintBox, "SetActive", false))
end

function CNotifyView.ClearFloatMsg(self)
	if self.m_FloatTimer then
		Utils.DelTimer(self.m_FloatTimer)
		self.m_FloatTimer = nil
	end
	self.m_FloatMsgList = {}
	for k,v in pairs(self.m_FloatBoxList) do
		v:SetActive(false)
		v.m_IsUsing = false
		if v.m_Tween then
			v.m_Tween:Kill(false)
			v.m_Tween = nil
		end
		if v.m_DelayCloseTimer then
			Utils.DelTimer(v.m_DelayCloseTimer)
			v.m_DelayCloseTimer = nil
		end
	end

	-- self.m_FloatTable:Clear()
end

function CNotifyView.FloatMsg(self, sText, itemData, bNotCheckTime)
	if not bNotCheckTime and g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.FloatSameMsg, sText) then
		return
	end
	g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.FloatSameMsg, sText, 1)

	table.insert(self.m_FloatMsgList, {sText, itemData})
	local function onFloat()
		self:ShowFloatBox(self.m_FloatMsgList[1][1], self.m_FloatMsgList[1][2])
		table.remove(self.m_FloatMsgList, 1)
		if not next(self.m_FloatMsgList) then
			self.m_FloatTimer = nil
			return false
		end
		return true
	end
	if not self.m_FloatTimer then
		self.m_FloatTimer = Utils.AddTimer(onFloat, 0.3, 0.3)
	end

	-- local oBox = self.m_FloatBoxClone:Clone()
	-- oBox.m_ItemIconSp = oBox:NewUI(3, CSprite)
	-- oBox.m_ItemCountLbl = oBox:NewUI(4, CLabel)
	-- oBox.m_ItemIconSp:SetActive(false)
	-- oBox.m_ItemCountLbl:SetActive(false)
	-- oBox:SetActive(true)
	-- oBox:SetText(sText, itemData)
	-- self:AddFloatBox(oBox)
end

function CNotifyView.GetNotUsingFloatIndex(self)
	-- local oKey = nil
	-- local oIndex = nil
	-- for k,v in ipairs(self.m_FloatBoxList) do
	-- 	if not v.m_IsUsing then
	-- 		if not oKey then
	-- 			oIndex = v.m_Index
	-- 			oKey = k
	-- 		else
	-- 			if oIndex > v.m_Index then
	-- 				oIndex = v.m_Index
	-- 				oKey = k
	-- 			end
	-- 		end
	-- 	end
	-- end
	-- return oKey
	if not self.m_FloatBoxHashList[1].m_IsUsing then
		return true
	end
	if not self.m_FloatBoxHashList[2].m_IsUsing then
		return true
	end
	if not self.m_FloatBoxHashList[3].m_IsUsing then
		return true
	end
end

function CNotifyView.GetFloatIndex(self)	
	-- for k,v in ipairs(self.m_FloatBoxList) do
	-- 	if v.m_Index == 1 then
	-- 		return k
	-- 	end
	-- end
	return self.m_FloatBoxHashList[1].m_Key
end

function CNotifyView.GetFloatIndexThree(self)	
	-- for k,v in ipairs(self.m_FloatBoxList) do
	-- 	if v.m_Index == 3 then
	-- 		return k
	-- 	end
	-- end
	return self.m_FloatBoxHashList[3].m_Key
end

function CNotifyView.GetUsingFloatNum(self)
	local oCount = 0
	-- for k,v in ipairs(self.m_FloatBoxList) do
	-- 	if v.m_IsUsing then
	-- 		oCount = oCount + 1
	-- 	end
	-- end
	if self.m_FloatBoxHashList[1].m_IsUsing then
		oCount = oCount + 1
	end
	if self.m_FloatBoxHashList[2].m_IsUsing then
		oCount = oCount + 1
	end
	if self.m_FloatBoxHashList[3].m_IsUsing then
		oCount = oCount + 1
	end
	return oCount
end

function CNotifyView.GetUsingFloatByIndex(self, oIndex)
	-- for k,v in ipairs(self.m_FloatBoxList) do
	-- 	if v.m_IsUsing and oIndex == v.m_Index then
	-- 		return k
	-- 	end
	-- end
	if self.m_FloatBoxHashList[oIndex].m_IsUsing then
		return self.m_FloatBoxHashList[oIndex].m_Key
	end
end

function CNotifyView.ShowFloatBox(self, sText, itemData)
	local oNotUsingIndex = self:GetNotUsingFloatIndex()
	local oIndex = self:GetFloatIndex()

	if oNotUsingIndex then
		local oThreeIndex = self:GetFloatIndexThree()
		local oUsingCount = self:GetUsingFloatNum()

		if oUsingCount <= 0 then
			self:SetFloatBox(self.m_FloatBoxList[oThreeIndex], sText, itemData)
			self:TweenFloatMsg(self.m_FloatBoxList[oThreeIndex], true)
		else
			local oKey3 = self:GetUsingFloatByIndex(3)
			if oKey3 then
				self.m_FloatBoxHashList = {}
				if oThreeIndex == 1 then
					self.m_FloatBoxHashList[2] = self.m_FloatBoxList[1]
					self.m_FloatBoxHashList[3] = self.m_FloatBoxList[2]
					self.m_FloatBoxHashList[1] = self.m_FloatBoxList[3]
					self.m_FloatBoxList[1].m_Index = 2
					
					if self.m_FloatBoxList[1].m_IsUsing then
						self:TweenFloatMsg(self.m_FloatBoxList[1])
					end
					self.m_FloatBoxList[2].m_Index = 3
					
					self:SetFloatBox(self.m_FloatBoxList[2], sText, itemData)
					self:TweenFloatMsg(self.m_FloatBoxList[2], true)
					self.m_FloatBoxList[3].m_Index = 1
					
					if self.m_FloatBoxList[3].m_IsUsing then
						self:TweenFloatMsg(self.m_FloatBoxList[3])
					end
				elseif oThreeIndex == 2 then
					self.m_FloatBoxHashList[2] = self.m_FloatBoxList[2]
					self.m_FloatBoxHashList[3] = self.m_FloatBoxList[3]
					self.m_FloatBoxHashList[1] = self.m_FloatBoxList[1]
					self.m_FloatBoxList[2].m_Index = 2
					
					if self.m_FloatBoxList[2].m_IsUsing then
						self:TweenFloatMsg(self.m_FloatBoxList[2])
					end
					self.m_FloatBoxList[3].m_Index = 3
					
					self:SetFloatBox(self.m_FloatBoxList[3], sText, itemData)
					self:TweenFloatMsg(self.m_FloatBoxList[3], true)
					self.m_FloatBoxList[1].m_Index = 1
					
					if self.m_FloatBoxList[1].m_IsUsing then
						self:TweenFloatMsg(self.m_FloatBoxList[1])
					end
				elseif oThreeIndex == 3 then
					self.m_FloatBoxHashList[2] = self.m_FloatBoxList[3]
					self.m_FloatBoxHashList[3] = self.m_FloatBoxList[1]
					self.m_FloatBoxHashList[1] = self.m_FloatBoxList[2]
					self.m_FloatBoxList[3].m_Index = 2
					
					if self.m_FloatBoxList[3].m_IsUsing then
						self:TweenFloatMsg(self.m_FloatBoxList[3])
					end
					self.m_FloatBoxList[1].m_Index = 3
					
					self:SetFloatBox(self.m_FloatBoxList[1], sText, itemData)
					self:TweenFloatMsg(self.m_FloatBoxList[1], true)
					self.m_FloatBoxList[2].m_Index = 1
					
					if self.m_FloatBoxList[2].m_IsUsing then
						self:TweenFloatMsg(self.m_FloatBoxList[2])
					end
				end
			else
				self:SetFloatBox(self.m_FloatBoxList[oThreeIndex], sText, itemData)
				self:TweenFloatMsg(self.m_FloatBoxList[oThreeIndex], true)
			end
		end
	else
		self.m_FloatBoxHashList = {}
		if oIndex == 1 then
			self.m_FloatBoxHashList[3] = self.m_FloatBoxList[1]
			self.m_FloatBoxHashList[1] = self.m_FloatBoxList[2]
			self.m_FloatBoxHashList[2] = self.m_FloatBoxList[3]
			self.m_FloatBoxList[1].m_Index = 3
			
			self:SetFloatBox(self.m_FloatBoxList[1], sText, itemData)
			self:TweenFloatMsg(self.m_FloatBoxList[1], true)
			self.m_FloatBoxList[2].m_Index = 1
			
			self:TweenFloatMsg(self.m_FloatBoxList[2])
			self.m_FloatBoxList[3].m_Index = 2
			
			self:TweenFloatMsg(self.m_FloatBoxList[3])
		elseif oIndex == 2 then
			self.m_FloatBoxHashList[3] = self.m_FloatBoxList[2]
			self.m_FloatBoxHashList[1] = self.m_FloatBoxList[3]
			self.m_FloatBoxHashList[2] = self.m_FloatBoxList[1]
			self.m_FloatBoxList[2].m_Index = 3
			
			self:SetFloatBox(self.m_FloatBoxList[2], sText, itemData)
			self:TweenFloatMsg(self.m_FloatBoxList[2], true)
			self.m_FloatBoxList[3].m_Index = 1
			
			self:TweenFloatMsg(self.m_FloatBoxList[3])
			self.m_FloatBoxList[1].m_Index = 2
			
			self:TweenFloatMsg(self.m_FloatBoxList[1])
		elseif oIndex == 3 then
			self.m_FloatBoxHashList[3] = self.m_FloatBoxList[3]
			self.m_FloatBoxHashList[1] = self.m_FloatBoxList[1]
			self.m_FloatBoxHashList[2] = self.m_FloatBoxList[2]
			self.m_FloatBoxList[3].m_Index = 3
			
			self:SetFloatBox(self.m_FloatBoxList[3], sText, itemData)
			self:TweenFloatMsg(self.m_FloatBoxList[3], true)
			self.m_FloatBoxList[1].m_Index = 1
			
			self:TweenFloatMsg(self.m_FloatBoxList[1])
			self.m_FloatBoxList[2].m_Index = 2
			
			self:TweenFloatMsg(self.m_FloatBoxList[2])
		end
	end
end

function CNotifyView.SetFloatBox(self, oBox, sText, itemData)
	oBox.m_FloatLabel:SetRichText(sText, nil, nil, true)

	local oStr, oCount = string.gsub(sText, "#cur_%d", "")
	if oCount > 0 then
		oBox.m_BgSprite:SetAnchorTarget(oBox.m_FloatLabel.m_GameObject, 0, 0, 0, 0)		
		oBox.m_BgSprite:SetAnchor("topAnchor", 14, 1)
        oBox.m_BgSprite:SetAnchor("bottomAnchor", -16, 0)
	else
		oBox.m_BgSprite:SetAnchorTarget(oBox.m_FloatLabel.m_GameObject, 0, 0, 0, 0)		
		oBox.m_BgSprite:SetAnchor("topAnchor", 14, 1)
        oBox.m_BgSprite:SetAnchor("bottomAnchor", -16, 0)     
	end
	oBox.m_BgSprite:SetAnchor("leftAnchor", -91, 0)
	oBox.m_BgSprite:SetAnchor("rightAnchor", 91, 1)
	oBox.m_BgSprite:ResetAndUpdateAnchors()

	oBox.m_ItemIconSp:SetActive(false)
	if itemData and type(itemData) == "table" then
		oBox.m_ItemIconSp:SetActive(true)
		if itemData.icon then
			oBox.m_ItemIconSp:SpriteItemShape(tonumber(itemData.icon))
		elseif itemData.shape then
			oBox.m_ItemIconSp:SpriteAvatar(tonumber(itemData.shape))
		end
		--暂时屏蔽
		-- if itemData.count > 1 then
		-- 	oBox.m_ItemCountLbl:SetActive(true)
		-- 	oBox.m_ItemCountLbl:SetText(itemData.count)
		-- else
		-- 	oBox.m_ItemCountLbl:SetActive(false)
		-- end	
	end
end

function CNotifyView.TweenFloatMsg(self, oBox, bResetPos)
	oBox:SetActive(true)
	if bResetPos then
		oBox:SetLocalPos(Vector3.New(0, self.m_FloatStartY, 0))
	end
	oBox.m_IsUsing = true
	if oBox.m_Tween then
		oBox.m_Tween:Kill(false)
		oBox.m_Tween = nil
	end
	if oBox.m_DelayCloseTimer then
		Utils.DelTimer(oBox.m_DelayCloseTimer)
		oBox.m_DelayCloseTimer = nil
	end
	local oPathList = {self.m_FloatPosList[oBox.m_Index]}
	local oMoveLen = 0
	if bResetPos then
		oPathList = {Vector3.New(0, self.m_FloatStartY, 0), self.m_FloatPosList[oBox.m_Index]}
		oMoveLen = self.m_FloatPosList[oBox.m_Index].y - self.m_FloatStartY
	else
		oPathList = {oBox:GetLocalPos(), self.m_FloatPosList[oBox.m_Index]}
		oMoveLen = self.m_FloatPosList[oBox.m_Index].y - oBox:GetLocalPos().y
	end
	oBox.m_Tween = DOTween.DOLocalPath(oBox.m_Transform, oPathList, 0.3/(self.m_FloatPosList[3].y - self.m_FloatStartY) *oMoveLen, 0, 0, 10, nil)
	DOTween.SetEase(oBox.m_Tween, 1)
	local function onTweenEnd()
		oBox.m_Tween = nil		
		if oBox.m_DelayCloseTimer then
			Utils.DelTimer(oBox.m_DelayCloseTimer)
			oBox.m_DelayCloseTimer = nil
		end
		local function progress()
			if Utils.IsNil(oBox) then
				return false
			end
			oBox.m_IsUsing = false
			oBox:SetActive(false)
			oBox.m_DelayCloseTimer = nil
			return false
		end
		oBox.m_DelayCloseTimer = Utils.AddTimer(progress, 0, self.m_FloatHideTime[oBox.m_Index])
	end
	DOTween.OnComplete(oBox.m_Tween, onTweenEnd)
end

function CNotifyView.FloatSimpleMsg(self, sText, vPos, iFloatHeight, vColor)
	self.m_FloatLabel:SetActive(true)
	self.m_FloatLabel:SetPos(vPos)
	if vColor then
		self.m_FloatLabel:SetColor(vColor)
	end

	local lPath = {vPos, Vector3.New(vPos.x, vPos.y + iFloatHeight, vPos.z)}
	local oTweenPath = DOTween.DOPath(self.m_FloatLabel.m_Transform, lPath, 1, 0, 0, 10, nil)
	local function onTweenEnd()
		self.m_FloatLabel:SetActive(false)
	end
	DOTween.OnComplete(oTweenPath, onTweenEnd)
end

-- function CNotifyView.AddFloatBox(self, oBox)
-- 	oBox:SetActive(true)
-- 	oBox:SetTimer(2, callback(self, "OnTimerUp"))
-- 	self.m_FloatTable:AddChild(oBox)
-- 	local v3 = oBox:GetLocalPos()
-- 	oBox:SetLocalPos(Vector3.New(v3.x, v3.y-20, v3.z))
-- 	oBox:SetAsFirstSibling()
-- end

-- function CNotifyView.OnTimerUp(self, oBox)
-- 	self.m_FloatTable:RemoveChild(oBox)
-- 	self.m_FloatTable:Reposition()
-- end


function CNotifyView.ShowProgress(self, cbFun, sText, waitTime, pastTime, cancelFunc, oMarkPosPoint)
	self.m_ProgressBar:SetActive(true)
	local screenWidth = UnityEngine.Screen.width
	local screenHeight = UnityEngine.Screen.height

	--指定位置
	local posPoint = oMarkPosPoint or 5
	if posPoint == 1 then
		self.m_ProgressBar:SetPos(self:GetWorldPos(Vector2.New(screenWidth*0.25, screenHeight*0.75)))
	elseif posPoint == 2 then
		self.m_ProgressBar:SetPos(self:GetWorldPos(Vector2.New(screenWidth*0.5, screenHeight*0.75)))
	elseif posPoint == 3 then
		self.m_ProgressBar:SetPos(self:GetWorldPos(Vector2.New(screenWidth*0.75, screenHeight*0.75)))
	elseif posPoint == 4 then
		self.m_ProgressBar:SetPos(self:GetWorldPos(Vector2.New(screenWidth*0.25, screenHeight*0.5)))
	elseif posPoint == 5 then
		self.m_ProgressBar:SetPos(self:GetWorldPos(Vector2.New(screenWidth*0.5, screenHeight*0.5)))
	elseif posPoint == 6 then
		self.m_ProgressBar:SetPos(self:GetWorldPos(Vector2.New(screenWidth*0.75, screenHeight*0.5)))
	elseif posPoint == 7 then
		self.m_ProgressBar:SetPos(self:GetWorldPos(Vector2.New(screenWidth*0.25, screenHeight*0.25)))
	elseif posPoint == 8 then
		self.m_ProgressBar:SetPos(self:GetWorldPos(Vector2.New(screenWidth*0.5, screenHeight*0.25)))
	elseif posPoint == 9 then
		self.m_ProgressBar:SetPos(self:GetWorldPos(Vector2.New(screenWidth*0.75, screenHeight*0.25)))
	else
		self.m_ProgressBar:SetPos(self:GetWorldPos(Vector2.New(screenWidth*0.5, screenHeight*0.5)))
	end

	local function hide()
		self.m_ProgressBar:SetActive(false)
		if cbFun then
			cbFun()
		end
	end
	self.m_ProgressBar:SetProgress(sText, waitTime, hide, pastTime, cancelFunc)
end

function CNotifyView.CancelProgress(self, cbFun)
	if cbFun then
		cbFun()
	end
	self.m_ProgressBar:SetActive(false)
	self.m_ProgressBar:ResetTimer()
end

--传的是物品的图片id
function CNotifyView.FloatItemBox(self, itemiconid, vpos, time, bScale, cb)
	local tempCache = {itemiconid = itemiconid, vpos = vpos, time = time, bScale = bScale}
	table.insert(self.m_FloatItemList, tempCache)
	local isUpdate = false
	local function set()
		isUpdate = true
		local oItemSpr = self.m_FloatItemSprList[1] --self.m_TreasureBoxClone:Clone()
		table.remove(self.m_FloatItemSprList, 1)
		oItemSpr:SetActive(true)		
		-- oBox:SetParent(self.m_TreasureBoxParent.m_Transform)
		oItemSpr:SpriteItemShape(tonumber(self.m_FloatItemList[1].itemiconid))
		local function onEnd()
			-- oBox:Destroy()
			oItemSpr:SetActive(false)
			table.insert(self.m_FloatItemSprList, oItemSpr)
			g_NotifyCtrl:SetMenuBagEffect()
		end
		local screenWidth = UnityEngine.Screen.width
		local screenHeight = UnityEngine.Screen.height
		oItemSpr:SetPos( self.m_FloatItemList[1].vpos or self:GetWorldPos(Vector2.New(screenWidth/2,screenHeight/2)))
		oItemSpr:SetLocalScale(Vector3.New(0.8, 0.8, 1))
		if self.m_FloatItemList[1].bScale == false then

		else
			local tweeScale = DOTween.DOScale(oItemSpr.m_Transform, Vector3.New( 1.2, 1.2, 0), 0.4)
			DOTween.SetDelay(tweeScale, 0.2)
		end	
		-- local up = {self:GetWorldPos(Vector2.New(screenWidth/2,screenHeight*0.4)), self:GetWorldPos(Vector2.New(screenWidth/2,screenHeight/2))}
		-- local tweenUp = DOTween.DOPath(oBox.m_Transform, up, 0.5, 0, 0, 10, nil)

		local vet = {self.m_FloatItemList[1].vpos or self:GetWorldPos(Vector2.New(screenWidth/2,screenHeight/2)),--self:GetWorldPos(Vector2.New(screenWidth*0.65,screenHeight*0.35)),--self:GetWorldPos(Vector2.New(screenWidth*0.735,screenHeight*0.4)),
		self:GetWorldPos(Vector2.New(screenWidth*97/100,screenHeight*1/6))} --self:GetWorldPos(Vector2.New(screenWidth*3/4,screenHeight*3/4)),
		-- table.print(vet,"飘物品的worldpos")

		local tweenPath = DOTween.DOPath(oItemSpr.m_Transform, vet, 1, 0, 0, 10, nil)
		DOTween.OnComplete(tweenPath, onEnd)
		DOTween.SetDelay(tweenPath, 0.6)
		DOTween.SetEase(tweenPath, enum.DOTween.Ease.InQuad)
		local tweenScale = DOTween.DOScale(oItemSpr.m_Transform, Vector3.New(0.7,0.7,0), 0.5)
		DOTween.SetDelay(tweenScale, 0.8)

		table.remove(self.m_FloatItemList,1)
		if not next(self.m_FloatItemList) then
			if self.m_TreasureTimer then
				Utils.DelTimer(self.m_TreasureTimer)
				self.m_TreasureTimer = nil
				if cb then
					cb()
				end
				isUpdate = false
			end
		end
		return isUpdate
	end
	if not self.m_TreasureTimer then
		self.m_TreasureTimer = Utils.AddTimer(set, 0.4, self.m_FloatItemList[1].time or 0.4)
	end
end

-- floatList ={    [1] = { icon = iconsid, worldpos = pos } ,[2] = ...      }
function CNotifyView.FloatMultipleItemBox(self, floatList, bScale, cb)
	for i,v in ipairs(floatList) do
		local oItemSpr = self.m_FloatItemSprList[1]:Clone()
		oItemSpr:SetActive(true)
		oItemSpr:SetParent(self.m_TreasureBoxParent.m_Transform)
		oItemSpr:SetPos(v.worldpos)
		--元宝狂欢相关
		if v.icon == "yuanbaojoy1" then
			oItemSpr:SetStaticSprite("MiscAtlas", "h7_50jc")
		elseif v.icon == "yuanbaojoy2" then
			oItemSpr:SetStaticSprite("MiscAtlas", "h7_30jc")
		elseif v.icon == "yuanbaojoy3" then
			oItemSpr:SetStaticSprite("MiscAtlas", "h7_20jc")
		else
			oItemSpr:SpriteItemShape(v.icon)
		end	
		
		local  function onEnd()
			-- body
			oItemSpr:Destroy()
			if i == #floatList and cb then
				cb()
			end
		end 

		local screenWidth = UnityEngine.Screen.width
		local screenHeight = UnityEngine.Screen.height
		-- vet 顶点路径
		local vet = {v.worldpos, self:GetWorldPos(Vector2.New(screenWidth*97/100,screenHeight*1/6)) }  
		

		local tweenPath = DOTween.DOPath(oItemSpr.m_Transform, vet, 1, 0, 0, 10, nil)

		DOTween.OnComplete(tweenPath, onEnd)
		DOTween.SetDelay(tweenPath, 0.6)
		DOTween.SetEase(tweenPath, enum.DOTween.Ease.InQuad)

		 -- 是否缩放
		if bScale then
			local tweeScale = DOTween.DOScale(oItemSpr.m_Transform, Vector3.New( 1.2, 1.2, 0), 0.4)
			DOTween.SetDelay(tweeScale, 0.2)
			local tweenScale = DOTween.DOScale(oItemSpr.m_Transform, Vector3.New(0.7,0.7,0), 0.5)
			DOTween.SetDelay(tweenScale, 0.8)
		end	

	end

end

function CNotifyView.QuickFloatItemBox(self, itemiconid, vStartpos, vEndPos)
	local function set()
		local oItemSpr = self.m_FloatItemSprList[1] --self.m_TreasureBoxClone:Clone()
		if not oItemSpr then
			return
		end
		table.remove(self.m_FloatItemSprList, 1)
		oItemSpr:SetActive(true)		
		-- oBox:SetParent(self.m_TreasureBoxParent.m_Transform)
		oItemSpr:SpriteItemShape(tonumber(itemiconid))
		local function onEnd()
			-- oBox:Destroy()
			oItemSpr:SetActive(false)
			table.insert(self.m_FloatItemSprList, oItemSpr)
			g_NotifyCtrl:SetMenuBagEffect()
		end
		local screenWidth = UnityEngine.Screen.width
		local screenHeight = UnityEngine.Screen.height
		oItemSpr:SetPos( vStartpos or self:GetWorldPos(Vector2.New(screenWidth/2,screenHeight/2)))
		oItemSpr:SetLocalScale(Vector3.New(0.8, 0.8, 1))

		local vet = {vStartpos or self:GetWorldPos(Vector2.New(screenWidth/2,screenHeight/2)),
		self:GetWorldPos(vEndPos or Vector2.New(screenWidth*97/100,screenHeight*1/6))} 

		local tweenPath = DOTween.DOPath(oItemSpr.m_Transform, vet, 1, 0, 0, 10, nil)
		DOTween.OnComplete(tweenPath, onEnd)
		DOTween.SetDelay(tweenPath, 0.6)
		DOTween.SetEase(tweenPath, enum.DOTween.Ease.InQuad)
		local tweenScale = DOTween.DOScale(oItemSpr.m_Transform, Vector3.New(0.7,0.7,0), 0.5)
		DOTween.SetDelay(tweenScale, 0.8)
	end
	Utils.AddTimer(set, 0.4, 0.4)
end

function CNotifyView.GetWorldPos(self, screenPos)
	local oUICamera = g_CameraCtrl:GetUICamera()
	local WorldPos = oUICamera:ScreenToWorldPoint(screenPos)
	return WorldPos
end

function CNotifyView.FloatNpcInfoList(self, npcInfoList)
	self.m_NpcListBox:InitNpcInfoList(npcInfoList)
end

function CNotifyView.FloatWarriorList(self, widList)
	self.m_WarriorListBox:InitWarriorList(widList)
end

--飘语音的错误提示界面
function CNotifyView.FloatAudioMsg(self, sText)
	self.m_FloatAudioBox:SetActive(true)
	self.m_FloatAudioBox:SetText(sText)
	self.m_FloatAudioBox:ShowView()
end

function CNotifyView.ShowRedPacket(self)
	if self.m_HideEffMsg then return end
	if next(g_RedPacketCtrl.m_MainViewRedPacketList) then
		self.m_RedPacketItem:SetActive(true)
		if g_WarCtrl:IsWar() then
			self.m_RedPacketGetBtn:SetActive(false)
			self.m_RedPacketGetBtn2:SetActive(true)
		else
			self.m_RedPacketGetBtn:SetActive(true)
			self.m_RedPacketGetBtn:NewUI(3, CLabel):SetText(g_RedPacketCtrl.m_MainViewRedPacketList[1].ownername)
			self.m_RedPacketGetBtn2:SetActive(false)
		end
		self.m_RedPacketGetBtn:SetLocalEulerAngles(Vector3.New(0, 0, 45))
		self.m_RedPacketGetBtn2:SetLocalEulerAngles(Vector3.New(0, 0, 45))
		if self.m_LastTween then
			self.m_LastTween:Kill(false)
		end
		if self.m_LastTween2 then
			self.m_LastTween2:Kill(false)
		end
		local tween = DOTween.DOLocalRotate(self.m_RedPacketGetBtn.m_Transform, Vector3.New(0, 0, -45), 1)
		--Restart 0, Yoyo 1, Incremental 2
		DOTween.SetLoops(tween, -1, 1)
		self.m_LastTween = tween

		local tween2 = DOTween.DOLocalRotate(self.m_RedPacketGetBtn2.m_Transform, Vector3.New(0, 0, -45), 1)
		DOTween.SetLoops(tween2, -1, 1)
		self.m_LastTween2 = tween2
	else
		self.m_RedPacketItem:SetActive(false)
	end
end

function CNotifyView.FloatPieceBox(self, oChapterId, oPieceIndex)
	if g_NotifyCtrl.m_IsChapterOpenShowing then
		g_NotifyCtrl.m_IsChapterOpenEndCb = function ()
			g_NotifyCtrl:FloatPieceBox(oChapterId, oPieceIndex)
		end	
		return
	end
	table.insert(self.m_FloatPieceList, {oChapterId, oPieceIndex})
	local function set()
		g_NotifyCtrl:FloatMsg("获得剧情碎片！")
		
		local oBox = self.m_FloatPieceClone:Clone()
		oBox:SetActive(true)
		oBox:SetParent(self.m_FloatPieceObj.m_Transform)
		oBox.m_PieceSp = oBox:NewUI(1, CSprite)
		oBox.m_Texture = oBox:NewUI(2, CTexture)
		oBox.m_PieceSp:SetActive(true)
		oBox.m_PieceSp:SetLocalScale(Vector3.New(1, 1, 1))
		oBox.m_Texture:SetActive(false)
		-- local sTextureName = "Texture/Task/"..self:GetPieceTexName(self.m_FloatPieceList[1][1])..self:GetEachIndex(self.m_FloatPieceList[1][2])..".png"
		-- g_ResCtrl:LoadAsync(sTextureName, callback(self, "SetPieceTexture", oBox))

		local screenWidth = UnityEngine.Screen.width
		local screenHeight = UnityEngine.Screen.height

		oBox:DelEffect("Screen")
		oBox:AddEffect("Screen", "ui_eff_0013_fly", nil, nil, nil, nil, nil, "ui_eff_0013")
		oBox.m_Effects["Screen"]:SetActive(false)

		local tweenScale = DOTween.DOScale(oBox.m_PieceSp.m_Transform, Vector3.New(0, 0, 0), 1)
		local function onScaleEnd()
			oBox.m_Effects["Screen"]:SetActive(true)
			oBox.m_PieceSp:SetActive(false)
			oBox:SetPos(self:GetWorldPos(Vector2.New(screenWidth/2, screenHeight*0.5)))
			local vet = {self:GetWorldPos(Vector2.New(screenWidth/2, screenHeight*0.5)), --self:GetWorldPos(Vector2.New(screenWidth*0.7,screenHeight*0.65)),
			self:GetWorldPos(Vector2.New(screenWidth*0.88, screenHeight*0.8))}
			local tweenPath = DOTween.DOPath(oBox.m_Transform, vet, 1.3, 0, 0, 10, nil)
			local function onEnd()
				oBox:DelEffect("Screen")
				oBox:AddEffect("Screen", "ui_eff_0013_hit2", nil, nil, nil, nil, nil, "ui_eff_0013")
				local function delay()
					if Utils.IsNil(oBox) then
						return false
					end
					oBox:SetParent(nil)
					oBox:Destroy()
					if self.m_FloatPieceObj.m_Transform.childCount <= 1 then
						g_NotifyCtrl.m_IsPieceShowing = false
						if g_NotifyCtrl.m_IsPieceEndCb then
							g_NotifyCtrl.m_IsPieceEndCb()
							g_NotifyCtrl.m_IsPieceEndCb = nil
						end
					end
					return false
				end
				Utils.AddTimer(delay, 0, 0.2)			
			end
			DOTween.OnComplete(tweenPath, onEnd)
			DOTween.SetDelay(tweenPath, 0) --0.6
			DOTween.SetEase(tweenPath, enum.DOTween.Ease.InQuad)
		end
		DOTween.OnComplete(tweenScale, onScaleEnd)
		DOTween.SetDelay(tweenScale, 0.5) --1	

		table.remove(self.m_FloatPieceList, 1)
		if not next(self.m_FloatPieceList) then
			self.m_PieceTimer = nil
			return false
		end
		return true
	end
	if not self.m_PieceTimer then
		self.m_PieceTimer = Utils.AddTimer(set, 0.4, 0.4)
	end
end

--以后要根据需求修改
function CNotifyView.GetPieceTexName(self, oChapterId)
	if oChapterId == 1 then
		return "h7_bei_"
	elseif oChapterId == 2 then
		return "h7_nu_"
	elseif oChapterId == 3 then
		return "h7_xi_"
	elseif oChapterId == 4 then
		return "h7_si_"
	else
		return "h7_bei_"
	end
end

function CNotifyView.GetEachIndex(self, oIndex)
	if oIndex == 1 then
		return 4
	elseif oIndex == 2 then
		return 8
	elseif oIndex == 3 then
		return 3
	elseif oIndex == 4 then
		return 7
	elseif oIndex == 5 then
		return 2
	elseif oIndex == 6 then
		return 6
	elseif oIndex == 7 then
		return 1
	elseif oIndex == 8 then
		return 5
	else
		return 4
	end
end

function CNotifyView.SetPieceTexture(self, oBox, prefab, errcode)
	if prefab then
		oBox.m_Texture:SetMainTexture(prefab)
		oBox.m_Texture:SetActive(true)
		oBox.m_Texture:SetLocalScale(Vector3.one)
	end
end

function CNotifyView.ShowRedPacketEffect(self)
	-- self.m_UIPanel.sortingOrder = -1
	if self.m_HideEffMsg then return end
	self.m_RedPacketEffect:DelEffect("Screen")
	self.m_RedPacketEffect:AddEffect("Screen", "ui_eff_0041")
end

function CNotifyView.RefreshLockScreen(self, bIsLock)
	self.m_LockScreen:RefreshLockState(bIsLock)
end

function CNotifyView.ShowTaskDoneEffect(self)
	self.m_TaskDoneEffect:DelEffect("TaskDone")
	self.m_TaskDoneEffect:AddEffect("TaskDone")
end

function CNotifyView.ShowTreasurePrizeEffect(self, index)
	if index == 1 then
		self.m_TreasurePrizeEffect:DelEffect("TreasureGoldPrize")
		self.m_TreasurePrizeEffect:AddEffect("TreasureGoldPrize")
	else
		self.m_TreasurePrizeEffect:DelEffect("TreasureSilverPrize")
		self.m_TreasurePrizeEffect:AddEffect("TreasureSilverPrize")
	end
end

function CNotifyView.SetSysOpenBoxActive(self, bActive)
	local screenWidth = UnityEngine.Screen.width
	local screenHeight = UnityEngine.Screen.height
	self.m_SysOpenBox:SetPos(self:GetWorldPos(Vector2.New(screenWidth*0.5, screenHeight*0.6)))
	self.m_SysOpenBox:SetActive(true)
	if bActive then
		self.m_SysTotalBg:SetActive(true)
		self.m_SysTexBg:DelEffect("SysOpen")
		self.m_SysTexBg:AddEffect("SysOpen")
	else
		self.m_SysTexBg:DelEffect("SysOpen")
	end
end

function CNotifyView.OnClickSysOpenClickWidget(self)
	g_OpenSysCtrl:CancelShow()
end

function CNotifyView.ShowFlowerEffect(self, effectId)
	if effectId <= 0 then
		return
	end
	if self.m_HideEffMsg then
		return
	end
	local effectList = {[1001] = "RoseSea", [1002] = "RoseRain", [1003] = "CarnationSea", [1004] = "CarnationRain"}
	for k,v in pairs(effectList) do
		if self.m_FlowerEffect.m_Effects[v] then
			return
		end
	end
	
	for k,v in pairs(effectList) do
		self.m_FlowerEffect:DelEffect(v)
	end
	self.m_FlowerEffect:AddEffect(effectList[effectId])
	if effectId == 1002 then
		self.m_FlowerEffect:AddEffect(effectList[1001])
	elseif effectId == 1004 then
		self.m_FlowerEffect:AddEffect(effectList[1003])
	end

	local function finish()
		if Utils.IsNil(self) then
			return false
		end
		for k,v in pairs(effectList) do
			self.m_FlowerEffect:DelEffect(v)
		end
		return false
	end
	Utils.AddTimer(finish, 0, 10)
end

function CNotifyView.ClearRumor(self)
	self.m_RumorBox.m_MsgList = {}
	self.m_RumorBox.m_Bg:SetActive(false)
	self.m_RumorBox.m_Label:SetActive(false)
end

-- function CNotifyView.OnUpdateScoreEvent(self , oCtrl)
-- 	-- body
-- 	if oCtrl.m_EventID == define.Rank.Event.UpdataScore then
-- 		printc("显示积分变化")
-- 		self:AddFloatBoxA(oCtrl.m_CurrScore)
-- 	end
-- end

function CNotifyView.OnClickDisableWidget(self)
	if not self.m_IsAudio then
		g_NotifyCtrl:FloatMsg("您当前不可操作哦")
	end
end

function CNotifyView.ShowDisableWidget(self, bIsShow, sText, oAudioOffset)
	self.m_IsAudio = oAudioOffset
	self.m_DisableAreaWidget:SetActive(bIsShow)
	if sText then
		self.m_DisableAreaLbl:SetActive(true)
		self.m_DisableAreaLbl:SetText(sText)
	else
		self.m_DisableAreaLbl:SetActive(false)
	end
	if oAudioOffset then
		self.m_DisableAreaWidget:SetAnchorTarget(self.m_GameObject, 0, 0, 0, 0)
		self.m_DisableAreaWidget:SetAnchor("leftAnchor", oAudioOffset, 0)
		self.m_DisableAreaWidget:SetAnchor("topAnchor", 0, 1)
        self.m_DisableAreaWidget:SetAnchor("bottomAnchor", 0, 0)
        self.m_DisableAreaWidget:SetAnchor("rightAnchor", 0, 1)
		self.m_DisableAreaWidget:ResetAndUpdateAnchors()
	else
		self.m_DisableAreaWidget:SetAnchorTarget(self.m_GameObject, 0, 0, 0, 0)
		self.m_DisableAreaWidget:SetAnchor("leftAnchor", 0, 0)
		self.m_DisableAreaWidget:SetAnchor("topAnchor", 0, 1)
        self.m_DisableAreaWidget:SetAnchor("bottomAnchor", 0, 0)
        self.m_DisableAreaWidget:SetAnchor("rightAnchor", 0, 1)
		self.m_DisableAreaWidget:ResetAndUpdateAnchors()
	end
end

function CNotifyView.ShowScreenEffect(self, effectName)
	self.m_ScreenWidget:ClearEffect()
	self.m_ScreenWidget:AddEffect("Screen", effectName)

	local function finish()
		if Utils.IsNil(self) then
			return false
		end
		self.m_ScreenWidget:ClearEffect()
		return false
	end
	Utils.AddTimer(finish, 0, 10)
end

--第一章id是对应2
function CNotifyView.ShowChapterOpen(self, oChapterId)
	if g_NotifyCtrl.m_IsPieceShowing then
		g_NotifyCtrl.m_IsPieceEndCb = function ()
			g_NotifyCtrl:ShowChapterOpen(oChapterId)
		end	
		return
	end
	self.m_FloatTable:SetActive(false)
	self.m_TreasureBoxParent:SetActive(false)
	self.m_ChapterOpen:SetActive(true)
	self.m_ChapterOpenMaskTexture:SetActive(true)
	self.m_ChapterOpen:ClearEffect()
	self.m_ChapterOpen:AddEffect("Screen", "ui_eff_0015")
	self.m_ChapterOpenTitleSp1:SetSpriteName("h7_zhang_"..(oChapterId-1))
	self.m_ChapterOpenTitleSp2:SetSpriteName("h7_zhang2_"..(oChapterId-1))
	self.m_ChapterOpenTitleSp3:SetSpriteName("h7_zhang3_"..(oChapterId-1))

	local tween = self.m_ChapterOpenTitleSp1:GetComponent(classtype.TweenAlpha)
	self.m_ChapterOpenTitleSp1:SetAlpha(0)
	tween.enabled = true
	tween.from = 0
	tween.to = 1
	tween.duration = 2
	tween:ResetToBeginning()
	tween.delay = 0
	tween:PlayForward()
	tween.onFinished = function ()
		self.m_ChapterOpenMaskTexture:SetActive(false)
		local function finish()
			self.m_ChapterOpen:ClearEffect()
			self.m_FloatTable:SetActive(true)
			self.m_TreasureBoxParent:SetActive(true)
			self.m_ChapterOpen:SetActive(false)
			g_NotifyCtrl.m_IsChapterOpenShowing = false
			if g_NotifyCtrl.m_IsChapterOpenEndCb then
				g_NotifyCtrl.m_IsChapterOpenEndCb()
				g_NotifyCtrl.m_IsChapterOpenEndCb = nil
			end
		end

		local tween2 = self.m_ChapterOpenTitleSp1:GetComponent(classtype.TweenAlpha)
		self.m_ChapterOpenTitleSp1:SetAlpha(1)
		tween2.enabled = true
		tween2.from = 1
		tween2.to = 0
		tween2.duration = 1
		tween2:ResetToBeginning()
		tween2.delay = 0
		tween2:PlayForward()
		tween2.onFinished = function ()
			finish()
		end
	end
end

function CNotifyView.ShowOrgMatchBox(self, bIsShow)
	self.m_OrgMatchBox:SetActive(bIsShow)
end

function CNotifyView.ShowNetCircle(self, bShow, sTip, bContent)
	sTip = nil
	sTip = sTip or bContent and "重连中..." or "加载中..."
	if bContent == true then
		self.m_NetCircle.m_CircleSprite:SetActive(false)
		self.m_NetCircle.m_SubSprite:SetActive(true)
	else
		self.m_NetCircle.m_CircleSprite:SetActive(true)
		self.m_NetCircle.m_SubSprite:SetActive(false)
	end
	-- self.m_NetCircle.m_CircleSprite:SetHeight(showTip and 110 or 88)
	-- self.m_NetCircle.m_TipLabel:SetActive(showTip and true or false)
	self.m_NetCircle.m_TipLabel:SetText(sTip)
	self.m_NetCircle:SetActive(bShow)
end

function CNotifyView.SetFloatTableActive(self, bActive)
	self.m_FloatTable:SetActive(bActive)
end

function CNotifyView.SetMenoryInfo(self, monery)
	self.m_MenoryBox:SetMenoryInfo(monery)
end

function CNotifyView.SetStatsInfo(self, open)
	self.m_StatsBox:SetStatsInfo(open)
end

-- 屏蔽部分消息/特效
function CNotifyView.SetEffectMsgActive(self, bActive)
	self.m_HideEffMsg = not bActive
	self.m_FlowerEffect:SetActive(bActive)
	self.m_TreasureBoxParent:SetActive(bActive)
	if self.m_HideEffMsg then
		self:ClearFloatMsg()
		self.m_ProgressBar:SetActive(false)
		self.m_RumorBox:SetActive(false)
		self.m_NpcListBox:SetActive(false)
		self.m_FloatAudioBox:SetActive(false)
		self.m_RedPacketItem:SetActive(false)
		self.m_RedPacketEffect:DelEffect("Screen")
	else
		self:ShowRedPacket()
	end
end

function CNotifyView.RefreshPowerSaveLayer(self, bShow)
	self.m_PowerSaveLayer:SetActive(bShow)
end

return CNotifyView