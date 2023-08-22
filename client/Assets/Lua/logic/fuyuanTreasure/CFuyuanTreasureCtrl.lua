local CFuyuanTreasureCtrl = class("CFuyuanTreasureCtrl", CCtrlBase)

function CFuyuanTreasureCtrl.ctor(self)

	CCtrlBase.ctor(self)
    self.m_IsUseYuanBao = false

end

function CFuyuanTreasureCtrl.C2GSOpenFuYuanBox(self, box_idx, times, use_goldcoin)

    nethuodong.C2GSOpenFuYuanBox(box_idx, times, use_goldcoin)

end


--打开界面
function CFuyuanTreasureCtrl.GS2COpenFuYuanBoxView(self, id, rewardList)

    local view = CFuyuanTreasureView:GetView()
    if view then 
         view:SetData(id, rewardList)
    else
        CFuyuanTreasureView:ShowView(function (oView) 
            oView:SetData(id, rewardList)
        end)
    end  

end

--抽奖成功
function CFuyuanTreasureCtrl.GS2CFuYuanBoxReward(self, times, rewardList)

    self.m_RewardList = rewardList

end

function CFuyuanTreasureCtrl.GetRewardList(self)
    
    return self.m_RewardList

end

function CFuyuanTreasureCtrl.GS2CFuYuanLottery(self, sessionidx, id)
    
    local oview = CFuyuanTreasureView:GetView()
    if oview then
       oview:DoAnimation(id)
    end

end

--关闭界面
function CFuyuanTreasureCtrl.GS2CCloseFuYuanBoxView(self)
    
     local oview = CFuyuanTreasureView:GetView()
     if oview then
        oview:CloseView()
     end

end

function CFuyuanTreasureCtrl.UseYuanBao(self, use)
    
    self.m_IsUseYuanBao = use

end

function CFuyuanTreasureCtrl.IsUseYuanBao(self)
    
    return self.m_IsUseYuanBao

end

return CFuyuanTreasureCtrl