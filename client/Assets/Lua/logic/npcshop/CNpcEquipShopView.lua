local CNpcEquipShopView =  class("CNpcEquipShopView", CViewBase, CNpcShopViewBase)

function CNpcEquipShopView.ctor(self, cb)
	CViewBase.ctor(self, "UI/NpcShop/NpcEquipShopView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CNpcEquipShopView.OnCreateView(self)
	
	CNpcShopViewBase.OnCreateView(self)

	local shopId = 201
	self.m_ShopId = 201

	CNpcShopViewBase.CreateShopItems(self, shopId)

	self.m_Close:AddUIEvent("click",callback(self, "OnClose"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID()-1, callback(self, "OnCtrlShopItemEvent"))
end

function CNpcEquipShopView.OnCtrlShopItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.ItemAmount then
		if CTaskHelp.GetClickTaskShopSelect() then
			local taskNeedList = g_TaskCtrl:GetTaskNeedItemList(CTaskHelp.GetClickTaskShopSelect(), true)
			local taskConfigNeedList = g_TaskCtrl:GetTaskNeedItemList(CTaskHelp.GetClickTaskShopSelect(), false)
			local shopId = g_DialogueCtrl:GetIsNpcShopItem(taskConfigNeedList)
			if (not taskNeedList or not next(taskNeedList)) and shopId and shopId == self.m_ShopId then
				if g_TaskCtrl.m_OpenShopForTaskSessionidx then
					g_TaskCtrl:SendOpenShopForTaskSessionidx()
				elseif g_YibaoCtrl.m_OpenShopForHelpOtherYibaoCb then
					g_YibaoCtrl.m_OpenShopForHelpOtherYibaoCb()
				else
					CTaskHelp.ClickTaskLogic(CTaskHelp.GetClickTaskShopSelect())
				end
				self:OnClose()
			end
		end
	end
end

function CNpcEquipShopView.OnClose(self)
	CTaskHelp.SetClickTaskShopSelect(nil)
	g_TaskCtrl.m_HelpOtherTaskData = {}
    g_TaskCtrl.m_OpenShopForTaskSessionidx = nil
    g_YibaoCtrl.m_OpenShopForHelpOtherYibaoCb = nil
	self:CloseView()
end

return CNpcEquipShopView