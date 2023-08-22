local CItemViewCtrl = class("CItemViewCtrl")

function CItemViewCtrl.ctor(self)
	
end

--使用物品或快速使用都会走这边的逻辑，处理一些特殊的逻辑如使用修炼丹打开修炼界面
function CItemViewCtrl.RequestUseItem(self, item, bIsNotCloseTip)
	-- TODO >>> 判断是否需要关闭ItemTipView
	if bIsNotCloseTip == nil or not bIsNotCloseTip then
		CItemQuickUseView:CloseView()
		CItemTipsView:CloseView()
	end
	local iItemID = item:GetSValueByKey("sid")
	local bIsNormal = false
	if iItemID == 10004 or iItemID == 10005 then
		-- 洗点丹和人参果特殊处理
		if g_AttrCtrl.grade >= 50 then
			CAttrMainView:ShowView(function (oView)
				oView:ShowSubPageByIndex(oView:GetPageIndex("Point"))
			end)
		else
			g_NotifyCtrl:FloatMsg("50级才可以使用")
		end
		
	elseif iItemID == 10031 then
		-- 还童丹
		g_SummonCtrl:ShowWashView()
		
	elseif iItemID == 10032 then
		-- 技能石
		g_SummonCtrl:ShowSutdySkillView()
		
	elseif iItemID == 10034 then
		-- 资质丹
		g_SummonCtrl:ShowCultureView()
	elseif iItemID == 10035 then
		local dFightSumm = g_SummonCtrl:GetCurFightSummonInfo()
		if dFightSumm then
			local sMsg = string.format("#D是否确认对#G%s#n（当前出战宠物）使用%s？", dFightSumm.name, item:GetSValueByKey("name"))
			local windowConfirmInfo = {
	        	msg = sMsg,
	        	okCallback = function()
	        		local id = item:GetSValueByKey("id")
	        		netitem.C2GSItemUse(id)
	        	end,
	        	color = Color.white,
	        	--cancelCallback = function() isUse = false return isUse end  
	      	}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
		else
			g_NotifyCtrl:FloatMsg("没有参战宠物")
		end
	elseif iItemID == 10036 then
		-- 洗点丹
		g_SummonCtrl:ShowWashPointView(true)
		
	elseif iItemID == 10033 or iItemID == 10038 or iItemID == 10037 or iItemID == 10011 or iItemID == 10047 then
		g_SummonCtrl:ShowPropertyView(iItemID)
	elseif iItemID == 10178 then
		-- 改名卡
		g_LinkInfoCtrl:GetAttrCardInfo(g_AttrCtrl.pid)
	elseif iItemID >= 30000 and iItemID <= 30599 then
		g_SummonCtrl:ShowSummonStudyBookView()	 --宠物打书
	elseif iItemID == 11175 then
		g_SummonCtrl:GotoExchangeNpc(4002)
	elseif iItemID == 11176 then
		g_SummonCtrl:GotoExchangeNpc(5001)
	elseif iItemID == 11185 then
		g_SummonCtrl:GotoExchangeNpc(5002)
	elseif iItemID >= 11177 and iItemID <= 11180 then
	    CSummonEquipEditView:ShowView(function(oView)
	        oView:ShowResetPage()
	    end)
	elseif iItemID == 10007 or iItemID == 10008 then
		-- g_SkillViewCtrl:OpenSkillCultivatePart(iItemID)

		local opendata = DataTools.GetViewOpenData(define.System.Cultivation)
		if g_AttrCtrl.grade < opendata.p_level then
			local stext = "人物达到#GXX#n级开启#G修炼技能#n后才可使用"
			local msg = string.gsub(stext, "XX", opendata.p_level)
			g_NotifyCtrl:FloatMsg(msg)
		else
			if iItemID == 10007 then
				local oCulIndex = g_SkillCtrl:GetIsCultivateCouldUp(1)
				if not oCulIndex then
					g_NotifyCtrl:FloatMsg("修炼技能已达上限暂无法学习")
				else
					CSkillMainView:ShowView(function (oView)
		            	local part = oView:GetCultivatePart()
		            	part:SetDefaultIndex(oCulIndex)
		            	oView:ShowSubPageByIndex(oView:GetPageIndex("Cultivation"))
		        	end)
				end
			elseif iItemID == 10008 then
				local oCulIndex = g_SkillCtrl:GetIsCultivateCouldUp(2)
				if not oCulIndex then
					g_NotifyCtrl:FloatMsg("修炼技能已达上限暂无法学习")
				
				else
					CSkillMainView:ShowView(function (oView)
		            	local part = oView:GetCultivatePart()
		            	part:SetDefaultIndex(oCulIndex)
		            	oView:ShowSubPageByIndex(oView:GetPageIndex("Cultivation"))
		        	end)
				end
			end
		end
		
	elseif iItemID == define.Treasure.Config.Item5 or iItemID == define.Treasure.Config.Item4 then
		-- table.print(item,"使用宝图道具11500或11501:")
		if g_LimitCtrl:CheckIsLimit(true, true) then
	    	return
	    end
	    if g_LimitCtrl:CheckIsCannotMove() then
			return
		end
		if g_LimitCtrl:CheckIsInFight("战斗中不可使用") then
			return
		end
		CItemMainView:CloseView()
		local treasureinfo = self:GetTreasureInfo(item)
		if treasureinfo then
			netitem.C2GSItemUse(item:GetSValueByKey("id"))
		else
			printc("使用宝图道具的treasureinfo为nil")
		end
	elseif (iItemID >= 12000 and iItemID <= 12068) or (iItemID >= 12600 and iItemID <= 12848) then
		CForgeMainView:ShowView(
			function(oView)
				oView:ShowSubPageByIndex(oView:GetPageIndex("Forge"))
			end
		)
	elseif iItemID >= 12300 and iItemID <= 12405 then
		CForgeMainView:ShowView(
			function(oView)
				oView:ShowSubPageByIndex(oView:GetPageIndex("Forge"))
			end
		)
	elseif iItemID >= 12100 and iItemID <= 12405 then
		CForgeMainView:ShowView(
			function(oView)
				oView:ShowSubPageByIndex(oView:GetPageIndex("Attach"))
			end
		)
	elseif iItemID == 11097 then
		CForgeMainView:ShowView(
			function(oView)
				oView:ShowSubPageByIndex(oView:GetPageIndex("Wash"))
			end
		)
	elseif (iItemID >= 11092 and iItemID <= 11096) or (iItemID >= 11160 and iItemID <= 11164) then
		CForgeMainView:ShowView(
			function(oView)
				oView:ShowSubPageByIndex(oView:GetPageIndex("Strengthen"))
			end
		)
	elseif DataTools.GetItemData(iItemID, "PARTNEREQUIP") then
		-- 伙伴装备
		-- CPartnerMainView:ShowView()
	elseif DataTools.GetItemData(iItemID, "PARTNER") then
		if iItemID >= 30630 and iItemID < 30660 then
			-- printc("============ 伙伴合成碎片")
			g_ItemCtrl:RequestComposeItem(item)
		else
			g_PartnerCtrl:OpenPartnerMainView(iItemID)
		end
	elseif iItemID == define.Treasure.Config.Item1 or iItemID == define.Treasure.Config.Item2 or iItemID == define.Treasure.Config.Item3 then
		local iAmount1 = g_ItemCtrl:GetBagItemAmountBySid(define.Treasure.Config.Item1)
		local iAmount2 = g_ItemCtrl:GetBagItemAmountBySid(define.Treasure.Config.Item2)
		local iAmount3 = g_ItemCtrl:GetBagItemAmountBySid(define.Treasure.Config.Item3)
		if iAmount1 > 0 and iAmount2 > 0 and iAmount3 > 0 then
			--材料足够是1，用元宝是2
			netitem.C2GSCompoundItem(define.Treasure.Config.Item4,1)
		else
			CTreasureMatView:ShowView()
		end
	elseif iItemID >= 11082 and iItemID <= 11090 then
		CFormationMainView:ShowView(function(oView)
			local iFmtId = DataTools.GetFormationIdByItem(iItemID)
			oView:JumpToTargetFormation(iFmtId, true)
		end)
	elseif iItemID >= 10051 and iItemID <= 10056 then
         CAttrSkillMakePart:ShowView(function (view)
         	view.m_CurSkill = g_AttrCtrl.org_skill[4102]
            view:InitContent(view.m_CurSkill)
            end)
	elseif iItemID == 10009 then
		   CLongChatView:ShowView()
	elseif iItemID == 11098 then
		COrgBarrageSendView:ShowView(function (oView)
			oView:RefreshUI()
		end)
	elseif iItemID == 10010 then
		self:EnergyUseTips(item:GetSValueByKey("id"))
	elseif iItemID == 11143 or iItemID == 11183 then
		CBadgeView:ShowView()
	elseif iItemID == 11142 then
		if g_WarCtrl:IsWar() then
			g_NotifyCtrl:FloatMsg("请战斗结束后再使用")
		else
			nethuodong.C2GSDanceAuto()
			CItemMainView:CloseView()
		end
	elseif iItemID >= 13500 and iItemID < 13600 then
		-- 开宝箱界面
		self:UseTreasureBox(iItemID)
	elseif iItemID == 11155 or iItemID == 11156 then
		self:UseBoxKey(iItemID)
	-- 集字换礼物品跳转界面（暂时处理方式）
	elseif iItemID == 10186 or iItemID == 10187 or iItemID == 10188 or iItemID == 10189 then
		-- CCelebrationView:ShowView(function (oView)
		-- 	oView:OnClickBtn(define.Celebration.Tab.CollectGift)
		-- end)
		if g_WelfareCtrl:IsCollectOpen() then
			CTimelimitView:ShowView(function(oView)
				oView:ForceSelPage("CollectGift")
			end)
		else
			return true
		end
	elseif iItemID == 10182 or iItemID == 10183 or iItemID == 10184  then 
		netopenui.C2GSFindGlobalNpc(5230)
		local oView = CItemMainView:GetView()
		if oView then
			CItemMainView:CloseView()
		end
	elseif iItemID == 10185 then 
		g_WaiGuanCtrl:OpenWaiGuanView()
	elseif iItemID == 10075 or iItemID == 10076 then
		CFriendInfoView:ShowView(function (oView)
			oView.m_Brief:ShowFriend()
		end)
	elseif iItemID == 11091 then
		local iComposeId = data.itemcomposedata.ITEM2COMPOSE[iItemID][1]
		if data.itemcomposedata.ITEM2CAT[iComposeId] then
			CItemComposeView:ShowView(function(oView)
				oView:JumpToCompose(iComposeId)
			end)
		end
	elseif iItemID == 10077 then
		if g_AttrCtrl.org_id ~= 0 then
			CItemMainView:CloseView()
			return true
		else
			g_NotifyCtrl:FloatMsg("未加入帮派不能使用")
		end
	elseif item:IsGemStone() then
		CForgeMainView:ShowView(
			function(oView)
				oView:ShowSubPageByIndex(oView:GetPageIndex("Inlay"))
			end
		)
	elseif iItemID == 11181 then --魂石锻魂锤
		CItemComposeView:ShowView(function(oView)
			oView.m_CurrentBox:JumpToTargetCatalog(4, 0)
		end)
	elseif  iItemID == 11099 or iItemID == 11187  or iItemID == 10197 then
		if not g_OpenSysCtrl.m_SysOpenList[define.System.RideUpgrade] then
			local tip = g_HorseCtrl:GetTextTip(1047)
			g_NotifyCtrl:FloatMsg(tip)
			return
		end
		CHorseMainView:ShowView(function (oView)
			oView:ShowSpecificPart(2)
		end)
	elseif iItemID == 11186 then
		-- 宠物包袱
		g_SummonCtrl:ShowPropertyView()
	elseif iItemID == 11189 then
		g_SummonCtrl:ShowCompoundView()
	elseif iItemID == 10179 then --帮派改名卡
		self:ChangeOrgName()
	elseif iItemID == 10198 then 
		local state = g_JieBaiCtrl:GetJieBaiState()
		if state == define.JieBai.State.AfterYiShi then 
			g_JieBaiCtrl:ShowJieBaiView()
		else
			g_NotifyCtrl:FloatMsg("无法使用")
		end  
	elseif iItemID == 11075 then --帮派建筑许可证
		if g_AttrCtrl.org_id > 0 then
			COrgBuildingUpgradeView:ShowView(function()
				netorg.C2GSGetBuildInfo()
				netorg.C2GSOrgMainInfo(0)
			end)
		end
	elseif iItemID == 11184 then -- 宠物技能绑定
		g_SummonCtrl:ShowPropertyView()
	elseif iItemID == 11192 then
		g_SummonCtrl:GotoExchangeNpc(5005)
	elseif iItemID == 11191 then
		g_ItemCtrl:RequestExcItem(iItemID)
	elseif iItemID == 11193 then
		g_SummonCtrl:GotoExchangeNpc(5001)
	elseif iItemID == 11194 then
		g_SummonCtrl:GotoExchangeNpc(5004)
	elseif iItemID == 10169 then
		CArtifactMainView:ShowView(function (oView)		
			oView:ShowSubPageByIndex(oView:GetPageIndex("main"))
		end)
	elseif iItemID == 10170 then
		g_ArtifactCtrl:OnShowArtifactQHView()
	elseif iItemID == 10171 or iItemID == 10172 or iItemID == 10173 then
		g_ArtifactCtrl:OnShowArtifactQiLingView()
	elseif g_WingCtrl:IsWingItem(iItemID) then
		g_WingCtrl:ShowWingPropertyPage()
	elseif g_WingCtrl:IsTimeWingItem(iItemID) then
		g_WingCtrl:ShowTimeWingPage(iItemID)
	elseif iItemID == data.skilldata.CONFIG[1].active_itemid then
		CSkillMainView:ShowView(function (oView)
            oView.m_SchoolPart:SetCurSkillByCouldUp()
            oView:ShowSubPageByIndex(oView:GetPageIndex("School"))
            oView.m_SchoolPart:PreSelect()
            g_ViewCtrl:TopView(oView)
        end)
    elseif iItemID == data.yuanbaojoydata.CONFIG[1].hditem then
    	if g_YuanBaoJoyCtrl.m_IsOpenState then
    		g_YuanBaoJoyCtrl:OnShowYuanBaoMainView()
    	else
    		g_NotifyCtrl:FloatMsg("元宝狂欢活动未开启，该道具暂时无法使用")
    	end
    elseif iItemID == 10155 or iItemID == 10156 or iItemID == 10157 or iItemID == 10158 then
    	local opendata = DataTools.GetViewOpenData(define.System.FaBao)
    	if g_AttrCtrl.grade >= opendata.p_level then
    		CFaBaoView:ShowView(function(oView)
    			oView:ShowSubPageByIdx(1)
    		end)
    	else
    		local pLevel = opendata.p_level
    		g_NotifyCtrl:FloatMsg(string.format("#G%d#n级之后开启法宝系统", pLevel))
    	end
    elseif iItemID == 11038 then
    	local opendata = DataTools.GetViewOpenData(define.System.XuanShang)
    	if g_OpenSysCtrl:GetOpenSysState(define.System.XuanShang) then
    		CTaskHelp.WalkToGlobalNpc(define.Task.TaskCategory.XUANSHANG.ID)
    		CItemMainView:CloseView()
    	else
    		g_NotifyCtrl:FloatMsg(opendata.p_level.."级"..opendata.name.."活动开启后才能使用")
    	end
    elseif iItemID == 11060 or iItemID == 11061 or iItemID == 11062 or iItemID == 11063 or iItemID == 11064 or iItemID == 11065
    or iItemID == 11066 or iItemID == 11067 or iItemID == 11068 or iItemID == 11069 or iItemID == 11070 or iItemID == 11071
    or iItemID == 11072 or iItemID == 11073 or iItemID == 11074 then
    	local opendata = DataTools.GetViewOpenData(define.System.Yibao)
    	if g_OpenSysCtrl:GetOpenSysState(define.System.Yibao) then
    		CTaskHelp.ScheduleTaskLogic(define.Task.TaskCategory.YIBAO.ID)
    		g_NotifyCtrl:FloatMsg("该道具可用于完成异宝任务")
    	else
    		g_NotifyCtrl:FloatMsg(opendata.p_level.."级"..opendata.name.."活动开启后才能使用")
    	end
	else
		return true
	end
	return bIsNormal
end

--返回宝图道具11076或11077的道具treasureinfo信息
function CItemViewCtrl.GetTreasureInfo(self,item)
	local treasureinfo
	for i=#item:GetSValueByKey("treasuremap_info"),1,-1 do
		if g_MapCtrl:GetMapID() == item:GetSValueByKey("treasuremap_info")[i].treasure_mapid then
			treasureinfo = item:GetSValueByKey("treasuremap_info")[i]
			break
		end
	end
	if not treasureinfo then
		local maxIndex = #item:GetSValueByKey("treasuremap_info")
		treasureinfo = item:GetSValueByKey("treasuremap_info")[maxIndex]
	end
	return treasureinfo
end

function CItemViewCtrl.ShowDragDes(self,itemInfo)
	local itemEffect = string.gsub(itemInfo:GetCValueByKey("introduction"),"功能：","")
	itemEffect = string.gsub(itemEffect,"类型：烹饪","")
	itemEffect = string.gsub(itemEffect,"类型：丹药","")
	local checkEffect = itemInfo:GetCValueByKey("item_formula")
	local itemsid = itemInfo:GetSValueByKey("sid")
	local itemlevel = itemInfo:GetSValueByKey("itemlevel")
	
	local effectTable = {["quality"] = itemlevel,["grade"] = g_AttrCtrl.grade,["carrylv"] = g_AttrCtrl.grade}
	if itemsid == 10050 then
	   local temp = string.split(checkEffect,",")
	   local des = string.split(itemEffect,"，")
	   local effectDes = ""
	   for i,v in ipairs(temp) do
	   	   local func = loadstring("return " ..string.gsub(v, "quality", itemlevel))
	   	   local effectValue = func()
	   	   if effectDes == "" then
	   	      effectDes = effectDes..des[i]..math.floor(effectValue)
	   	  else
	   	  	  effectDes = effectDes..", "..des[i]..math.floor(effectValue)
	   	  end
	   end
	   --printc(effectDes)
	   local resultStr = "品质:"..itemlevel..", "..effectDes
	   return resultStr
	end
	if itemsid >= 10046 and itemsid <= 10064 then  --特殊处理
		local stageTwo = itemsid >= 10050 and itemsid <= 10057
		if stageTwo and g_WarCtrl:IsWar() then
			return itemInfo:GetCValueByKey("introduction")
		end

	   local formula = checkEffect
       for k,v in pairs(effectTable) do
       	   formula = string.gsub(formula, k, v)
       end
	   local func = loadstring("return " .. formula)
	   local v = func()
	   --printc(itemEffect..math.floor(v))
	   local resultStr = "品质:"..itemlevel..", "..itemEffect..math.floor(v)
	   return string.gsub(resultStr, "；", ",")  --所有分号替换为英文逗号
	end
end

function CItemViewCtrl.EnergyUseTips(self, id)
	local maxEnergy = g_AttrCtrl:GetMaxEnergy()
	local addEnergy = 200--100 + (g_AttrCtrl.grade / 30) * 10
	--local isUse = true
	if g_AttrCtrl.energy >= maxEnergy then
		g_NotifyCtrl:FloatMsg(DataTools.GetMiscText(1041, "ITEM").content)
	elseif g_AttrCtrl.energy + addEnergy >= maxEnergy then
	  	local windowConfirmInfo = {
        	msg = "使用后您的活力将超过活力上限，你确定要使用？",
        	okCallback = function() netitem.C2GSItemUse(id) end,
        	--cancelCallback = function() isUse = false return isUse end  
      	}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		netitem.C2GSItemUse(id)
	end
end

-- 宝箱使用
function CItemViewCtrl.UseTreasureBox(self, iItemID)
	local dItemData = DataTools.GetItemData(iItemID)
	if not dItemData then
		return
	end
	local iMinGrade = dItemData.minGrade
	if g_AttrCtrl.grade >= iMinGrade then
		-- CTreasureBoxView:ShowView(function(oView)
		-- 	oView:InitInfo(iItemID)
		-- end)
		local dBoxData = DataTools.GetItemData(iItemID)
		if dBoxData then
 	        local dOpenCost = dBoxData.open_cost[1]
    	    if dOpenCost then
        	    local iKeyCnt = g_ItemCtrl:GetBagItemAmountBySid(dOpenCost.sid)
        	    if iKeyCnt >= dOpenCost.amount then
        	    	netopenui.C2GSOpenBox(iItemID)
        	    else
        	    	local dKeyInfo = DataTools.GetItemData(dOpenCost.sid)
		            local sMsg = DataTools.GetMiscText(1005, "BOX").content
		            g_NotifyCtrl:FloatMsg(string.gsub(sMsg, "#item", dKeyInfo.name))
        	    end
        	end
        end
	else
		g_NotifyCtrl:FloatMsg(string.format(DataTools.GetMiscText(1006, "BOX").content, iMinGrade))
	end
end

--钥匙使用
function CItemViewCtrl.UseBoxKey(self, iItemID)
	-- 钥匙暂时没规定id范围/配置对应宝箱信息，先写死
	local dKeyInfo = {
		[11155] = 13500,
		[11156] = 13501,
	}
	local iKeyBoxId = dKeyInfo[iItemID]
	if iKeyBoxId then
		local iBoxAmount = g_ItemCtrl:GetBagItemAmountBySid(iKeyBoxId)
		if iBoxAmount > 0 then
			self:UseTreasureBox(iKeyBoxId)
		else
			g_NotifyCtrl:FloatMsg(DataTools.GetMiscText(1007, "BOX").content)
		end
	else
		g_NotifyCtrl:FloatMsg("找不到对应宝箱")
	end
end

--帮派改名
function CItemViewCtrl.ChangeOrgName(self)
	if g_AttrCtrl.org_id == 0 or g_AttrCtrl.org_pos ~= 1 then
		g_NotifyCtrl:FloatMsg("只有帮主才可以改名")
		return
	end
	local dItemData = DataTools.GetItemData(10179)
	local sMsg = string.format("[63432c]本次改名需要消耗[c]#I%sX1", dItemData.name)
	local windowInputInfo = {
		des				= sMsg,
		title			= "帮派改名",
		inputLimit		= 12,
		defaultText		= "请输入新的名字",
		defaultCallback = function (inputStr)
			local len = string.len(inputStr)
			if inputStr and len > 0 then
				if g_MaskWordCtrl:IsContainMaskWord(inputStr) then
					g_NotifyCtrl:FloatMsg("帮派名含有非法字符！")
					return true
				end
				if len < 6 then
       				local str = string.gsub(data.orgdata.TEXT[1015].content, "#zszifu", 6)
        			g_NotifyCtrl:FloatMsg(str)
        			return true
    			end
				netorg.C2GSRenameNormalOrg(inputStr)
			else
				g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1014].content)
				return true
			end
		end,
	}
	g_WindowTipCtrl:SetWindowInput(windowInputInfo, function (oView)
		self.m_WinInputViwe = oView
	end)
end

return CItemViewCtrl