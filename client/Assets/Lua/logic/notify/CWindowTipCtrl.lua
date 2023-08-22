local CWindowTipCtrl = class("CWindowTipCtrl")

function CWindowTipCtrl.ctor(self)
	
end

-- args = {msg-s信息, title-s标题, okCallback-fun确定回调, cancelCallback-fun取消回调, pivot-Pivot信息对齐, okStr-s确定按钮文字", cancelStr-s取消按钮文字,color-改变内容文本原来的颜色}
function CWindowTipCtrl.SetWindowConfirm(self, args, cb)
	local windowTipInfo = {
		msg				= args.msg or "-----",
		title			= args.title or "提示",
		okCallback		= args.okCallback,
		cancelCallback	= args.cancelCallback,
		thirdCallback	= args.thirdCallback,
		pivot			= args.pivot or enum.UIWidget.Pivot.Left,
		okStr			= args.okStr or "确定",
		cancelStr		= args.cancelStr or "取消",
		thirdStr		= args.thirdStr or "",
		closeType		= args.closeType or 1,
		countdown       = args.countdown or 0,
		default         = args.default or 0,
		color           = args.color,
		style           = args.style or CWindowComfirmView.Style.Multiple,
		closeCallback	= args.closeCallback,
		hideContentBg	= args.hideContentBg,
		alignmemt		= args.alignmemt,
		notnotifytype	= args.notnotifytype,
		notnotifytext	= args.notnotifytext,
		TipBoxCb        = args.TipBoxCb,
		close_btn		= args.close_btn or 0,
	}
	CWindowComfirmView:ShowView(function (oView)
		local extendCloseType = {"ClickOut", "Black", "Shelter", "Pierce"}
		oView.m_ExtendClose = extendCloseType[windowTipInfo.closeType]
		oView:DestroyBeindLayer()
		oView:ExtendClose()
		if g_AttrCtrl.pid == 0 then
			oView:SetSortOrder(4)
			if oView.m_BehidLayer then oView.m_BehidLayer:SetSortOrder(4) end
		end
		local showThirdBtn = windowTipInfo.thirdStr ~= "" and windowTipInfo.thirdCallback ~= nil
		oView.m_ThirdBtn:SetActive(showThirdBtn)

		oView:SetWindowConfirm(windowTipInfo)
		if cb then
			cb(oView)
		end
		if args.depthType then
			oView.m_DepthType = args.depthType
			g_ViewCtrl:TopView(oView)
		end
	end)
end

function CWindowTipCtrl.SetJieBaiWindowConfirm(self, args, cb)
	local windowTipInfo = {
		msg				= args.msg or "-----",
		title			= args.title or "提示",
		okCallback		= args.okCallback,
		cancelCallback	= args.cancelCallback,
		thirdCallback	= args.thirdCallback,
		pivot			= args.pivot or enum.UIWidget.Pivot.Left,
		okStr			= args.okStr or "确定",
		cancelStr		= args.cancelStr or "取消",
		thirdStr		= args.thirdStr or "",
		closeType		= args.closeType or 1,
		countdown       = args.countdown or 0,
		default         = args.default or 0,
		color           = args.color,
		style           = args.style or CWindowComfirmView.Style.Multiple,
		closeCallback	= args.closeCallback,
		hideContentBg	= args.hideContentBg,
		alignmemt		= args.alignmemt,
		notnotifytype	= args.notnotifytype,
		notnotifytext	= args.notnotifytext,
		TipBoxCb        = args.TipBoxCb,
		close_btn		= args.close_btn,
		okButNotClose   = args.okButNotClose,
	}
	CWindowJieBaiConfirmView:ShowView(function (oView)
		local extendCloseType = {"ClickOut", "Black", "Shelter", "Pierce"}
		oView.m_ExtendClose = extendCloseType[windowTipInfo.closeType]
		oView:DestroyBeindLayer()
		oView:ExtendClose()
		if g_AttrCtrl.pid == 0 then
			oView:SetSortOrder(4)
			if oView.m_BehidLayer then oView.m_BehidLayer:SetSortOrder(4) end
		end
		local showThirdBtn = windowTipInfo.thirdStr ~= "" and windowTipInfo.thirdCallback ~= nil
		oView.m_ThirdBtn:SetActive(showThirdBtn)

		oView:SetWindowConfirm(windowTipInfo)
		if cb then
			cb(oView)
		end
		-- if args.depthType then
		-- 	oView.m_DepthType = args.depthType
		-- 	g_ViewCtrl:TopView(oView)
		-- end
	end)
end

-- args = {msg-s信息, title-s标题, okCallback-fun确定回调, cancelCallback-fun取消回调, pivot-Pivot信息对齐, okStr-s确定按钮文字", cancelStr-s取消按钮文字,color-改变内容文本原来的颜色}
--给断线重连提示等界面使用(层级大于引导界面)，跟普通的提示界面功能一样
function CWindowTipCtrl.SetWindowNetConfirm(self, args, cb)
	local windowTipInfo = {
		msg				= args.msg or "-----",
		title			= args.title or "提示",
		okCallback		= args.okCallback,
		cancelCallback	= args.cancelCallback,
		thirdCallback	= args.thirdCallback,
		pivot			= args.pivot or enum.UIWidget.Pivot.Left,
		okStr			= args.okStr or "确定",
		cancelStr		= args.cancelStr or "取消",
		thirdStr		= args.thirdStr or "",
		closeType		= args.closeType or 1,
		countdown       = args.countdown or 0,
		default         = args.default or 0,
		color           = args.color,
		style           = args.style or CWindowNetComfirmView.Style.Multiple,
		isOkNotClose    = args.isOkNotClose,
		hideClose		= args.hideClose,
	}
	CWindowNetComfirmView:ShowView(function (oView)
		oView.m_CloseBtn:SetActive(not windowTipInfo.hideClose)
		local extendCloseType = {"ClickOut", "Black", "Shelter"}
		oView.m_ExtendClose = extendCloseType[windowTipInfo.closeType]
		oView:DestroyBeindLayer()
		oView:ExtendClose()
		if g_AttrCtrl.pid == 0 then
			oView:SetSortOrder(4)
			if oView.m_BehidLayer then oView.m_BehidLayer:SetSortOrder(4) end
		end
		local showThirdBtn = windowTipInfo.thirdStr ~= "" and windowTipInfo.thirdCallback ~= nil
		oView.m_ThirdBtn:SetActive(showThirdBtn)

		oView:SetWindowConfirm(windowTipInfo)
		if cb then
			cb(oView)
		end
	end)
end

-- args = {title-s标题, des-s信息, defaultCallback-fun默认回调, okCallback-fun确定回调, cancelCallback-fun取消回调, okStr-s确定按钮文字", cancelStr-s取消按钮文字}
function CWindowTipCtrl.SetWindowInput(self, args, cb)
	local windowInputInfo = {
		des				= args.des or "",
		title			= args.title or "提示",
		inputLimit		= args.inputLimit or 30,
		cancelCallback	= args.cancelCallback,
		defaultCallback = args.defaultCallback,
		okCallback		= args.okCallback,
		defaultStr		= args.defaultStr or "确定",
		okStr			= args.okStr or "确定",
		cancelStr		= args.cancelStr or "取消",
		thirdStr		= args.thirdStr or "",
		isclose         = args.isclose,
		defaultText     = args.defaultText or nil,
	}
	CWindowInputView:ShowView(function (oView)
		oView:SetWindowInput(windowInputInfo)
		if g_AttrCtrl.pid == 0 then
			oView:SetSortOrder(4)
			if oView.m_BehidLayer then oView.m_BehidLayer:SetSortOrder(4) end
		end
		if cb then
			cb(oView)
		end
	end)
end

function CWindowTipCtrl.SetWindowCommitItem(self, sessionidx, taskid, owner)
	if owner and owner ~= 0 and not g_YibaoCtrl:GetOtherYibaoTaskDataByTaskid(taskid) then
		printc("找不到别人的异宝任务数据")
		return
	end
	CTaskCommitItemView:ShowView(function (oView)
		if not owner or owner == 0 then
			local task = g_TaskCtrl:GetSpecityTask(taskid)
			oView:SetContent(sessionidx, task)
			--异宝还原
			--异宝自动提交
			if task:GetCValueByKey("type") == define.Task.TaskCategory.YIBAO.ID then
				oView.m_IsYibaoCommit = true
				oView:OnCommitBtn()
				oView:CloseView()
			else
				oView.m_IsYibaoCommit = false
			end
		else			
			local task = CTask.New(g_YibaoCtrl:GetOtherYibaoTaskDataByTaskid(taskid).data)
			oView:SetContent(sessionidx, task)
			--异宝还原
			oView.m_IsYibaoCommit = true
			oView:OnCommitBtn()
			oView:CloseView()
		end		
	end)
end

function CWindowTipCtrl.SetWindowCommitSummon(self, sessionidx, taskid, owner)
	if owner and owner ~= 0 and not g_YibaoCtrl:GetOtherYibaoTaskDataByTaskid(taskid) then
		printc("找不到别人的异宝任务数据")
		return
	end
	CTaskCommitSummonView:ShowView(function (oView)
		if not owner or owner == 0 then
			local task = g_TaskCtrl:GetSpecityTask(taskid)
			oView:SetContent(sessionidx, task)
		else
			local task = CTask.New(g_YibaoCtrl:GetOtherYibaoTaskDataByTaskid(taskid).data)
			oView:SetContent(sessionidx, task)
		end
	end)
end

-- args = {widget-widget对位锚点, side-side对位, offset-v2偏移量}
function CWindowTipCtrl.SetWindowItemTip(self, itemid, args, hasSpecial, depthType, oMarkItemData)
	CWindowItemTipView:ShowView(function (oView)
		oView:SetWindowItemTipInfo(itemid, args, hasSpecial, oMarkItemData)
		args = args or {}
		args.widget = args.widget or oView
		args.side = args.side or enum.UIAnchor.Side.Top
		args.offset = args.offset or Vector2.New(0, 10)
		UITools.NearTarget(args.widget, oView.m_TipWidget, args.side, args.offset)
		if depthType then
			oView.m_DepthType = depthType
			g_ViewCtrl:TopView(oView)
		end
	end)
end

function CWindowTipCtrl.SetWindowSkillTip(self, args)
	CWindowItemTipView:ShowView(function (oView)
		oView:SetWindowSkillTipInfo(args)
		args = args or {}
		args.widget = args.widget or oView
		args.side = args.side or enum.UIAnchor.Side.Top
		args.offset = args.offset or Vector2.New(0, 10)
		UITools.NearTarget(args.widget, oView.m_TipWidget, args.side, args.offset)
	end)
end

function CWindowTipCtrl.SetWindowHorseSkillTip(self, args)
	CWindowHorseSkillTipView:ShowView(function (oView)
		if args then 
			local id = args.skId
			oView:SetInfo(id)
			args.widget = args.widget or oView
			args.side = args.side or enum.UIAnchor.Side.Top
			args.offset = args.offset or Vector2.New(0, 10)
			UITools.NearTarget(args.widget, oView.m_TipWidget, args.side, args.offset)
		end
	end)
end

-- args = {widget-widget对位锚点, side-side对位, offset-v2偏移量}
function CWindowTipCtrl.SetWindowSumTip(self, sumid, args)
	CWindowItemTipView:ShowView(function (oView)
		oView:SetWindowSumTipInfo(sumid)
		args = args or {}
		args.widget = args.widget or oView
		args.side = args.side or enum.UIAnchor.Side.Top
		args.offset = args.offset or Vector2.New(0, 10)
		UITools.NearTarget(args.widget, oView.m_TipWidget, args.side, args.offset)
	end)
end

function CWindowTipCtrl.SetWindowEquipEffectTipInfo(self, iEffectId, args, bIsSkill)
	CWindowEquipEffectTipView:ShowView(function (oView)
		oView:SetWindowEffectTipInfo(iEffectId, bIsSkill)
		args = args or {}
		args.widget = args.widget or oView
		args.side = args.side or enum.UIAnchor.Side.Top
		args.offset = args.offset or Vector2.New(0, 10)
		UITools.NearTarget(args.widget, oView.m_TipWidget, args.side, args.offset)
	end)
end

function CWindowTipCtrl.SetSummonEquipSkillTipInfo(self, iSkill, args)
	CWindowEquipEffectTipView:ShowView(function(oView)
		oView:SetSummonSkillTipInfo(iSkill)
		args = args or {}
		args.widget = args.widget or oView
		args.side = args.side or enum.UIAnchor.Side.Top
		args.offset = args.offset or Vector2.New(0, 10)
		UITools.NearTarget(args.widget, oView.m_TipWidget, args.side, args.offset)
	end)
end

function CWindowTipCtrl.SetWindowInstructionInfo(self, content)
	CWindowInstructionView:ShowView(function (oView)
		oView:SetWindowInstructionInfo(content)
	end)
end

--打开仓库的存进存出面板
function CWindowTipCtrl.ItemWHEquipShow(self , oItem, typeBtn, hitExtend)
	-- body
	CItemTipsView:ShowView(function(oView)
       	oView:OpenEquipView(oItem ,typeBtn, hitExtend)
    end)
end

--打开宠物装备仓库面板
function CWindowTipCtrl.ItemWHSummonEquipShow(self, oItem, typeBtn, hitExtend)
	CItemTipsView:ShowView(function(oView)
       	oView:OpenSummonEquipView(oItem ,typeBtn, hitExtend)
    end)
end

--打开纹饰仓库面板
function CWindowTipCtrl.ItemWHWenShiShow(self, oItem, typeBtn, hitExtend)
	CItemTipsView:ShowView(function(oView)
       	oView:OpenWenShiView(oItem ,typeBtn, hitExtend)
    end)
end


--装备回收
function CWindowTipCtrl.ItemRecoveryShow(self, id)
    CItemTipsView:ShowView(function(oView)
       	oView:ItemRecovery(id)
    end)
end
--临时背包道具
function CWindowTipCtrl.TempBagShow(self, oItem)
    CItemTipsView:ShowView(function(oView)
       	oView:TempBag(oItem)
    end)
end

-- itemid, cb, hitExtend
-- 道具ID | 回掉 | 是否隐藏扩展信息
function CWindowTipCtrl.SetWindowGainItemTip(self, itemid, cb, hitExtend, dGemStoneInfo, oDepthType)
	if not DataTools.GetItemGainWayList(itemid) then
       	printc("无获取途径 itemid=",itemid)
   	end 

    CItemTipsView:ShowView(function(oView)
     	local cItem = CItem.CreateDefault(itemid, dGemStoneInfo)
       	oView:ShowGainWayView(cItem, hitExtend)
       	if oDepthType then
       		oView.m_DepthType = oDepthType
            g_ViewCtrl:TopView(oView)
       	end
        if cb then
        	cb()
        end
    end)
end

function CWindowTipCtrl.SetWindowGainItemTipByItem(self, oItem, cb, hitExtend)
	if not DataTools.GetItemGainWayList(oItem.m_SID) then
       	printc("无获取途径 itemid=",oItem.m_SID)
   	end 

    CItemTipsView:ShowView(function(oView)
       	oView:ShowGainWayView(oItem, hitExtend)
        if cb then
        	cb()
        end
    end)
end

function CWindowTipCtrl.SetWindowGemStoneTipInfo(self, iItemId, lAttr, iGrade, args)
	CWindowGemStoneTipView:ShowView(function (oView)
		oView:SetInfo(iItemId, lAttr, iGrade)
		args = args or {}
		args.widget = args.widget or oView
		args.side = args.side or enum.UIAnchor.Side.Top
		args.offset = args.offset or Vector2.New(0, 10)
		UITools.NearTarget(args.widget, oView.m_TipWidget, args.side, args.offset)
	end)
end

function CWindowTipCtrl.ShowCosItemConfirmWindow(self, args)
    CItemCostComfirmView:ShowView(function(oView)
        oView:SetWindowConfirm(args)
    end)
end

function CWindowTipCtrl.ShowItemBoxView(self, args)
	CWindowItemBoxView:ShowView(function(oView)
		oView:SetViewArgs(args)
	end)
end

function CWindowTipCtrl.ShowWindowSelectItemView(self, args)
	-- body
	CWindowSelectItemView:ShowView(function(oView)
		oView:SetWindowInfo(args)
	end)
end

-- 运营活动多处用到
function CWindowTipCtrl.ShowSelectRewardItemView(self, items, idx, cb)
	local args = {
		surecb = cb,
		selectidx = idx,
        title = "可选",
        des = "请选择一份心仪的奖励",
        itemlist = items,
        comfirmText = "确定",
	}
	self:ShowWindowSelectItemView(args)
end

return CWindowTipCtrl