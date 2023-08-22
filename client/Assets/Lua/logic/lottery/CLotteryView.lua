local CLotteryView = class("CLotteryView", CViewBase)


function CLotteryView.ctor(self, cb)

    CViewBase.ctor(self, "UI/Lottery/LotteryView.prefab", cb)

    self.m_ExtendClose = "Black" 
    self.m_LotteryRewardList = {}
end

function CLotteryView.OnCreateView(self)

    self.m_turnNode = self:NewUI(1, CWidget)
    self.m_LotteryBtn = self:NewUI(2, CWidget)

    self.m_lotteryCountLabel = self:NewUI(3, CLabel)

    self.m_RewardObjList = {}

    self.m_RewardObjList[1] = self:NewUI(4, CLotteryBox)
    self.m_RewardObjList[2] = self:NewUI(5, CLotteryBox)
    self.m_RewardObjList[3] = self:NewUI(6, CLotteryBox)
    self.m_RewardObjList[4] = self:NewUI(7, CLotteryBox)
    self.m_RewardObjList[5] = self:NewUI(8, CLotteryBox)
    self.m_RewardObjList[6] = self:NewUI(9, CLotteryBox)
    self.m_RewardObjList[7] = self:NewUI(10, CLotteryBox)
    self.m_RewardObjList[8] = self:NewUI(11, CLotteryBox)
    self.m_SelectBG         = self:NewUI(12, CWidget)
    self.m_CloseBtn         = self:NewUI(13, CWidget)

    self.isRotating = false

    self:InitEvent()

    self:InitRewardList()

    self:UpdateLotteryCount()


end

function CLotteryView.InitEvent(self)

    self.m_LotteryBtn:AddUIEvent("click", callback(self, "OnClickStartLottery"))
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
 
end



function CLotteryView.OnClose(self)

    if self.isRotating == false then 

        self:CloseView()
    
    end  

end

--初始化物品列表
function CLotteryView.InitRewardList(self)
    
    self.m_LotteryRewardList = data.lotterydata.lottery

    for k ,v in ipairs(self.m_LotteryRewardList) do 

        if v.pos ~= nil and v.idx == 1001 then 

            local item = self.m_RewardObjList[v.pos]
            
            if item ~= nil then 

                item:SetData(v.sid, v.amount)

            end 

        end 

    end 


end

function CLotteryView.OnClickStartLottery(self)
    if self.isRotating then
        g_NotifyCtrl:FloatMsg("正在抽奖中")
        return
    end
    if self.m_lotteryCount > 0 then 
        if self.m_SelectBG:GetActive() then
            self.m_SelectBG:SetActive(false)
        end
        nethuodong:C2GSSignInLottery()

    else 

        g_NotifyCtrl:FloatMsg("剩余抽奖次数不够")        

    end 



    
end

--开始旋转动画
function CLotteryView.StartToPlayLottery(self, data)

    self.data = data

    if self.isRotating == false then 

        local rand = self.data.idx
        local degree = self:GetDegreeByIndex(rand)
        local tween = DOTween.DORotate(self.m_turnNode.m_Transform, Vector3.New(0, 0, degree + (-360 *2)), 2, 1)
        self.isRotating = true
        local function onEnd()
            self:EndToPlayLottery()
            self.isRotating = false
            self.m_SelectBG:SetActive(true)
        end
        DOTween.OnComplete(tween, onEnd)

    end

end

--动画结束，发送结束协议
function CLotteryView.EndToPlayLottery(self, data)

    local sessionidx = self.data.sessionidx
    netother.C2GSCallback(sessionidx)
end


--抽奖完毕后会更新
function CLotteryView.UpdateLotteryCount(self)

    self.m_lotteryCount = g_LotteryCtrl.m_lotteryCount
    self.m_lotteryCountLabel:SetText(g_LotteryCtrl.m_lotteryCount)
  
end

function CLotteryView.GetDegreeByIndex(self, index)   

    local degree = ((2 * index) - 1) * 22.5 * -1
    return degree

end

return CLotteryView