local CScheduleCrapsView = class("CScheduleCrapsView", CViewBase)

function CScheduleCrapsView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Schedule/ScheduleCrapsView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Shelter"
    self.m_GroupName = "main"
    self.m_OnLineTimer = nil
    self.m_Lottery = nil
    self.m_LastCount = 0 -- 剩余的次数
    self.m_MaxGoldCount = 10
    self.m_DicePoint = { [1] = "h7_yidian_1",[2]= "h7_liangdian",[3]= "h7_sandian",
                        [4]= "h7_sidian",[5]= "h7_wudian",[6]= "h7_liudian",
                        }
    self.m_CrapsInfo = nil
    self.m_ExistItemRwd = nil  -- ExistItemReward 集齐六个6获得特殊奖励的ID
    self.m_FloatItemList = {} -- copy notifyview的入袋动画
    self.m_SixCnt = 0  --当前六点的数量
    self.m_RewardId = nil
    self.m_FinishEffect = nil --特效
    self.m_Text = nil

    self.m_IsShootCraps = false --记录每次摇骰子的状态
    self.m_LastSixCount = 0
end

function CScheduleCrapsView.OnCreateView(self)
    -- self.m_AllCount = self:NewUI(1, CLabel)
    self.m_CrapsTable = self:NewUI(2, CTable)
    self.m_SureBtn = self:NewUI(3, CButton)
    self.m_DesBtn = self:NewUI(4, CButton)
    --self.m_OnLineLab = self:NewUI(5, CLabel)

    self.m_RewardItemBox = self:NewUI(6, CBox)
    self.m_ItemSpr = self.m_RewardItemBox:NewUI(1, CSprite)
    self.m_ItemAmountLab = self.m_RewardItemBox:NewUI(2, CLabel)

    self.m_CloseBtn = self:NewUI(7, CButton)

    self.m_CrapsEndBox = self:NewUI(8, CBox)
    self.m_MultipleLab = self.m_CrapsEndBox:NewUI(1, CLabel)
    self.m_EndDiceGrid = self.m_CrapsEndBox:NewUI(2, CGrid)
    self.m_EndDiceSpr = self.m_CrapsEndBox:NewUI(3, CSprite)
    self.m_EndBtn = self.m_CrapsEndBox:NewUI(4, CButton)
    self.m_MultipleSpr =  self.m_CrapsEndBox:NewUI(5, CSprite)

    self.m_Effect = self:NewUI(9, CSprite)
    self.m_PreViewBtn = self:NewUI(10, CTexture)
    self.m_ItemFloatNode = self:NewUI(11, CObject)
    self.m_DiceGrid = self:NewUI(12, CGrid)
    self.m_DiceCell = self:NewUI(13, CBox)
    self.m_CountLab = self:NewUI(14, CLabel)
    self.m_GetBtn = self:NewUI(15, CButton)
    self.m_LastAccelerationY = 0
    self.m_AccelerationDis = 2

    self:InitContent()
end
function CScheduleCrapsView.InitContent(self)
   
    local function InitCraps(obj, idx)
        local sprite = CSprite.New(obj)
        sprite:SetSpriteName(idx)
        return sprite  
    end
    self.m_CrapsTable:InitChild(InitCraps)
    self.m_Effect:SetActive(false)
    self.m_RewardItemBox:SetActive(false)
    self.m_DesBtn:AddUIEvent("click",callback(self, "OnDescribe"))
    self.m_CloseBtn:AddUIEvent("click",callback(self, "OnClose"))
    self.m_EndBtn:AddUIEvent("click", callback(self, "OnEndBtn"))
    self.m_GetBtn:AddUIEvent("click", callback(self, "OnTweenPlay"))
    self.m_SureBtn:AddUIEvent("click", callback(self, "OnSure"))
    g_CrapsCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCrapEvent"))
    --g_ScheduleCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnScheduleEvent")) 
    self.m_StartTime = 0

    local dicelist = self.m_DiceGrid:GetChildList()
    for i=1,6 do
        local dice = nil
        if i>#dicelist then
            dice = self.m_DiceCell:Clone()
            self.m_DiceGrid:AddChild(dice)
            dice:SetGroup(self.m_DiceGrid:GetInstanceID())
            -- dice:SetActive(true)
            dice.spr = dice:NewUI(1, CSprite)
            dice.light = dice:NewUI(2, CSprite)
        else
            dice = dicelist[i]
        end
        dice.state = 0 -- 未点亮
    end  
    self:CheckShake()
    --摇一摇的时候禁止屏幕翻转
    if not Utils.IsIOS() then
        UnityEngine.Screen.autorotateToLandscapeLeft = false
        UnityEngine.Screen.autorotateToLandscapeRight = false
    end
end


function CScheduleCrapsView.OnCrapEvent(self, oCtrl)
    -- body
    -- if oCtrl.m_EventID == define.Crap.Event.Timer then
    --     -- body
    --     if Utils.IsNil(self) then
    --         return
    --     end
    --     if g_CrapsCtrl.m_Time and g_CrapsCtrl.m_Time>=0 then
    --         -- local hours = math.modf(g_CrapsCtrl.m_Time/3600)
    --         local minutes = math.floor ((g_CrapsCtrl.m_Time%3600)/60)
    --         local seconds = g_CrapsCtrl.m_Time % 60
    --         local str = string.format("%02d:%02d",minutes, seconds)
    --         self.m_OnLineLab:SetText("[AFDBCEFF]在线[-][ff7633ff]"..str.."[-][AFDBCEFF]获得[-][0fff32ff]1[-][AFDBCEFF]次[-]")
    --     end
    -- end
end

function CScheduleCrapsView.OnScheduleEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Schedule.Event.RefreshSchedule then
        -- local data = oCtrl.m_SvrScheduleList[1017]

        -- local goldcointimes = data.maxtimes - data.times
        -- if goldcointimes > 5 then
        --     self.m_CountLab:SetText("免费次数：".. (data.times.."/"..data.maxtimes)) --todo
        -- else

        -- end
        
        -- self.m_LastCount = data.maxtimes-data.times
    end
end

function CScheduleCrapsView.InitDiceGrid(self, OpenCnt)
    self.m_LastSixCount = OpenCnt
    local childlist = self.m_DiceGrid:GetChildList()
    for i, oDice in ipairs(childlist) do
        local bActive = (i <= OpenCnt)
        oDice:SetActive(bActive)
        oDice.spr:SetColor(bActive and Color.RGBAToColor("FFFFFFFF") or Color.RGBAToColor("B2B2B2CC"))
        oDice.light:SetActive(bActive) 
        oDice.state = bActive and 1 or 0
    end 
end

function CScheduleCrapsView.OnDescribe(self)
    local info = data.instructiondata.DESC[8001]
    local zContent = {title = info.title,desc = info.desc}
    g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

function CScheduleCrapsView.OnSure(self)
    local isFull = g_ItemCtrl:IsBagFull()
    if isFull then
        g_NotifyCtrl:FloatMsg("背包已经满了，请整理后再进行活动！")
        return
    end
    if self.m_Lottery or g_TimeCtrl:GetTimeS() - self.m_StartTime <= 3 then
        g_NotifyCtrl:FloatMsg("请稍候！")
        return
    end
    if self.m_LastCount <= 0 then
        g_NotifyCtrl:FloatMsg("次数已用完，请明天再来！")
        return
    end

    if self.m_SixCnt >= 6 then
        for i ,dice in ipairs(self.m_DiceGrid:GetChildList()) do
            dice.spr:SetColor(Color.RGBAToColor("B2B2B2CC"))
            dice.light:SetActive(false)
            dice.state = 0   
            dice:SetActive(false)
        end
        self.m_RewardItemBox:SetActive(false)
        self.m_CrapsEndBox:SetActive(false)
    end
    if self.m_FinishEffect then
        self.m_FinishEffect:Destroy()
        self.m_FinishEffect = nil
    end

    --每天首次花费元宝摇骰子时(即剩余次数为10时)，弹出二次确认
    if self.m_LastCount == self.m_MaxGoldCount then
        local args = {
            msg = "免费次数已用完，你确定花元宝摇骰子吗？",
            title = "提示",
            okCallback = function ()
                self:ShootCrapWithGoldCoin()
            end,
            cancelCallback = function ()
                self:OnClose()
            end,
            pivot = enum.UIWidget.Pivot.Center,
        }
        g_WindowTipCtrl:SetWindowConfirm(args)
    elseif self.m_LastCount < self.m_MaxGoldCount then
        self:ShootCrapWithGoldCoin()
    else
        g_CrapsCtrl:C2GSShootCrapStart()
        self.m_IsShootCraps = true
        self.m_SureBtn:SetActive(false)
    end
    
    self.m_DiceGrid:SetActive(true)
    self.m_RewardItemBox:SetActive(false)
    self.m_StartTime = g_TimeCtrl:GetTimeS()
end

-- 使用元宝摇骰子
function CScheduleCrapsView.ShootCrapWithGoldCoin(self)
    local goldcoincnt = self.m_MaxGoldCount - self.m_LastCount
    local goldcoinCost = g_CrapsCtrl:GetGoldCoinCost(goldcoincnt)
    local totalGoldCoin = g_AttrCtrl.goldcoin + g_AttrCtrl.rplgoldcoin

    if totalGoldCoin < goldcoinCost then
        g_NotifyCtrl:FloatMsg("元宝不足")
        CNpcShopMainView:ShowView(function(oView) 
            oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge")) 
        end)
        return
    end
    nethuodong.C2GSShootCrapsExchangeCnt()
    self.m_IsShootCraps = true
    self.m_SureBtn:SetActive(false)
end

function CScheduleCrapsView.SetInfo(self, info) --初始化配置,刷新骰子数

    if Utils.IsNil(self) then
        return
    end

    self.m_SixCnt = info.sixcnt
    if info.sixlitemlist and next(info.sixlitemlist) then
        local oItem  = DataTools.GetItemData(info.sixlitemlist[1])
        local rewardinfo = data.rewarddata.SHOOTCRAPREWARD
        local tempreward = {}
        for i,v in ipairs(rewardinfo) do
            if v.idx == 1001 then
                table.insert(tempreward, v)
            end
        end
        local count = 1
        for i,v in ipairs(tempreward) do
            if info.sixlitemlist[1] == tonumber(v.sid) then
                count = v.amount
            end
        end
        self.m_Text = "获得#G"..oItem.name.."#n×#G".. count.."#n个"
        self.m_ExistItemRwd = oItem.icon
    end
    -- if self.m_OnLineTimer then
    --     Utils.DelTimer(self.m_OnLineTimer)
    -- end
    -- if not info.onlinetime or info.onlinetime == 0 then self.m_OnLineLab:SetText("剩余次数不足") end
    self.m_PreViewBtn:AddUIEvent("click", callback(self, "OnTips"))

    --最大免费数量加上最大元宝数量，减去已使用免费和元宝数量，剩下的为剩余数量
    self.m_LastCount = (info.maxcount + self.m_MaxGoldCount) - (info.count + info.goldcoincnt)

    if info.count == info.maxcount then
         self.m_CountLab:SetText("元宝次数："..info.goldcoincnt.."/"..self.m_MaxGoldCount)
    else
        self.m_CountLab:SetText("免费次数："..info.count.."/"..info.maxcount)
    end

    if info.count == info.maxcount then
        local costCoin = g_CrapsCtrl:GetGoldCoinCost(info.goldcoincnt)
        if self.m_LastCount > 0 then
            self.m_SureBtn:SetText(costCoin.."#cur_2".."摇一次")
        else
            self.m_SureBtn:SetText("摇一摇")
        end
    end
end

function CScheduleCrapsView.OnEndBtn(self)
    local sign = false
    if self.m_CrapsInfo then
        for i,v in ipairs(self.m_CrapsInfo.point_lst) do
            if v == 6 then
                sign = true
                self:FloatSixPoint(1, i)
            end
        end
    end

    if self.m_ExistItemRwd then
        self.m_CrapsEndBox:SetActive(false)
        self.m_SureBtn:SetActive(false)
    else
        if sign then
            self.m_EndBtn:SetActive(true)
        else
           self.m_CrapsEndBox:SetActive(false)
           self.m_SureBtn:SetActive(true)
        end
    end
end

function CScheduleCrapsView.FloatToItem(self)
    self.m_CrapsEndBox:SetActive(false)  

    local path = "Effect/UI/ui_eff_0069/Prefabs/ui_eff_0069.prefab"
    local function effectDone ()
        if Utils.IsNil(self) then
            self.m_FinishEffect:Destroy()
            return false
        end
        self.m_FinishEffect:SetParent(self.m_Transform)
    end
    local time = 1
    -- local endpos = self.m_RewardItemBox:GetPos()
    -- for i=1,6 do 
        -- local dice = self.m_DiceGrid:GetChild(i)
        -- local inlpos = dice:GetPos()
        -- local spr = dice.spr:Clone()
        -- spr:SetActive(true)
        -- spr:SetParent(self.m_Transform)
        -- spr:SetPos(inlpos)
        -- spr:SetColor(Color.RGBAToColor("FFFFFFFF"))
        -- spr:SetSpriteName("h7_yulanjieguo")
        -- spr:SetDepth(100)
        -- spr:SetActive(false)
        -- local vet  = {inlpos,  endpos}
        -- local tweenPath = DOTween.DOPath(spr.m_Transform, vet, 2, 0, 0, 10, nil)
        local function onEnd()
            -- body
            -- if  self.m_FinishEffect then
            --      self.m_FinishEffect:Destroy()
            -- end
            self.m_RewardItemBox:SetActive(true)
            self.m_ItemSpr:SpriteItemShape(self.m_ExistItemRwd)
            self.m_GetBtn:SetActive(true)
            -- spr:Destroy()
        end
        -- DOTween.OnStart(tweenPath, function ()
            -- body
            -- self.m_FinishEffect = CEffect.New(path, self:GetLayer(), false, effectDone)
            -- self.m_DiceGrid:SetActive(false)
            -- dice.light:SetActive(false)
            -- spr:SetActive(true)
        -- end)
        -- DOTween.OnComplete(tweenPath, onEnd)
        -- DOTween.SetDelay(tweenPath, 1.5)
    -- end
        local function OnStart()
            -- body
            self.m_DiceGrid:SetActive(false)
            if not self.m_FinishEffect then
                self.m_FinishEffect = CEffect.New(path, self:GetLayer(), false, effectDone)
            end
            time = time + 1
            if time > 3 then
                onEnd()
                return false
            end
            return true
        end
    Utils.AddTimer(OnStart, 1, 1.4) 
end

function CScheduleCrapsView.FloatSixPoint(self, i, idx)
    self.m_SureBtn:SetActive(false)
    self.m_CrapsEndBox:SetActive(false)

    local function set()
        local spr = self.m_EndDiceGrid:GetChild(idx):Clone()
        local wpos = self.m_EndDiceGrid:GetChild(idx):GetPos()
        spr:SetParent(self.m_Transform)
        spr:SetSpriteName("h7_liudian")
        spr:SetPos(wpos) 

        --上次六点数和本次六点数的总和
        local sixCount = self:GetAllSixPointCount()
        if sixCount > 6 then
            sixCount = 6
        end
        
        local wendpos = nil
        if sixCount > 0 then
             for i=1, sixCount do
                 local dice = self.m_DiceGrid:GetChild(i)
                 if dice.state == 0 then
                    dice.state = 1
                    wendpos = dice:GetPos() 
                    break
                 end
             end
        end
        -- wendpos = wendpos or self.m_DiceGrid:GetChild(6):GetPos() --多出来的六点
        if not wendpos then spr:Destroy() return false  end
        local function onEnd()
            if self.m_SixCnt and self.m_SixCnt > 0 and self.m_SixCnt <= 6 then
                for i=1, self.m_SixCnt do
                    local dice = self.m_DiceGrid:GetChild(i)
                    dice:SetActive(true)
                    dice.spr:SetColor(Color.RGBAToColor("FFFFFFFF"))
                    dice.light:SetActive(true) 
                    dice.state = 1               
                end
                self.m_LastSixCount = self.m_SixCnt < 6 and self.m_SixCnt or 0
            end
            spr:Destroy()
        end
       
        local vet = {wpos, wendpos}
        local tweenPath = DOTween.DOPath(spr.m_Transform, vet, 1, 0, 0, 10, nil)
        DOTween.OnComplete(tweenPath, onEnd)
        DOTween.SetDelay(tweenPath, 0.2)
        DOTween.SetEase(tweenPath, enum.DOTween.Ease.InQuad)
        
        if sixCount == 6 then
            self:FloatToItem()
        else
            self.m_SureBtn:SetActive(true)
        end
    end
    set()
end

--计算上次六点数和本次六点数的总和
function CScheduleCrapsView.GetAllSixPointCount(self)
    local count = self.m_LastSixCount
    if self.m_CrapsInfo and self.m_CrapsInfo.point_lst then
        for i, v in pairs(self.m_CrapsInfo.point_lst) do
            if v == 6 then
                count = count + 1
            end
        end
    end
    return count
end

function CScheduleCrapsView.SetReward(self) 
    if Utils.IsNil(self) then return end
    -- self.m_CountLab:SetActive(false)
    self.m_CrapsEndBox:SetActive(true) --
    -- self.m_EndBtn:SetActive(true)
    if not self.m_CrapsInfo then return end
    
    if self.m_CrapsInfo.flowerid == 1 then
        self.m_MultipleSpr:SetActive(true)
        self.m_MultipleLab:SetText("3倍奖励")
    else
        self.m_MultipleSpr:SetActive(false)
    end
    local diceEndList = self.m_EndDiceGrid:GetChildList()
    for i=1, 6 do
        local dice = nil
        if i>#diceEndList then
            dice = self.m_EndDiceSpr:Clone()
            dice:SetActive(true)
            dice:SetGroup(self.m_EndDiceGrid:GetInstanceID())
            self.m_EndDiceGrid:AddChild(dice)
        else
            dice = diceEndList[i]
        end
        dice:SetSpriteName(self.m_DicePoint[self.m_CrapsInfo.point_lst[i]])
    end
end

function CScheduleCrapsView.OnTips(self)
    CCrapsPreView:ShowView() 
end

function CScheduleCrapsView.StartLottery(self, info)
    self.m_CrapsInfo = info
    for k,v in pairs(self.m_CrapsTable:GetChildList()) do
        v:SetActive(false)
    end
    local startTime = g_TimeCtrl:GetTimeS()
    local i = 1
    local function Lottery()
        if Utils.IsNil(self) then
            return false
        end
        if i > 40 then
           return false
        end
        self:StartSpriteAnimation()
        if i == 25 then
           local obj1 = self.m_CrapsTable:GetChild(1)
           printc(obj1)
           if obj1 then
              obj1:SetSpriteName(info.point_lst[1])
              obj1:SetActive(true)
           end
        elseif i == 27 then
           local obj1 = self.m_CrapsTable:GetChild(2)
           if obj1 then
              obj1:SetSpriteName(info.point_lst[2])
              obj1:SetActive(true)
           end
        elseif i == 31 then
            local obj1 = self.m_CrapsTable:GetChild(3)
           if obj1 then
              obj1:SetSpriteName(info.point_lst[3])
              obj1:SetActive(true)
           end
        elseif i == 34 then
            local obj1 = self.m_CrapsTable:GetChild(4)
           if obj1 then
              obj1:SetSpriteName(info.point_lst[4])
              obj1:SetActive(true)
           end
        elseif i == 37 then
            local obj1 = self.m_CrapsTable:GetChild(5)
           if obj1 then
              obj1:SetSpriteName(info.point_lst[5])
              obj1:SetActive(true)
           end
        elseif i == 40 then
           local obj1 = self.m_CrapsTable:GetChild(6)
           if obj1 then
              obj1:SetSpriteName(info.point_lst[6])
              obj1:SetActive(true)
           end
           self:EndLottery(info)           
           return false
        end
        i = i + 1
        return true
    end
    if self.m_Lottery then
        Utils.DelTimer(self.m_Lottery)
        self.m_Lottery = nil
    end
    self.m_Lottery = Utils.AddTimer(Lottery, 0.01, 0)
end

function CScheduleCrapsView.EndLottery(self, info)
    if self.m_Lottery then
        Utils.DelTimer(self.m_Lottery)
        self.m_Lottery = nil
    end
    self:PauseSpriteAnimation()
    local function End()
        g_CrapsCtrl:C2GSShootCrapEnd()
        self.m_IsShootCraps = false
        return false
    end  
    Utils.AddTimer(End, 0.1, 0.7)
end

function CScheduleCrapsView.StartSpriteAnimation(self)
    self.m_Effect:SetActive(true)
    self.m_Effect:StartSpriteAnimation()
end

function CScheduleCrapsView.PauseSpriteAnimation(self)
    self.m_Effect:SetActive(false)
    self.m_Effect:PauseSpriteAnimation()
end

function CScheduleCrapsView.CheckShake(self)
    local function update()
        if Utils.IsNil(self) or self.m_LastCount <= 0 then
            return
        end
        if self.m_Lottery or g_TimeCtrl:GetTimeS() - self.m_StartTime <= 3 then
            return true
        end
        local iCurAccelerationY = UnityEngine.Input.acceleration.y
        local iDisY = iCurAccelerationY - self.m_LastAccelerationY
        self.m_LastAccelerationY = iCurAccelerationY
        if iDisY > self.m_AccelerationDis then
            self.m_LastAccelerationY = 0
            if self.m_SureBtn:GetActive() then -- 点击确定按钮播放摇骰子动画
                -- if self.m_CrapsEndBox:GetActive() then
                --     self.m_CrapsEndBox:SetActive(false)
                -- end
                self:OnSure()
                C_api.Utils.Vibrate()
            end   
        end
        return true
    end
    Utils.AddTimer(update, 0.033, 0.1)
end
function CScheduleCrapsView.OnTweenPlay(self)
    -- body
    if self.m_Text then
        g_NotifyCtrl:FloatMsg(self.m_Text)
    end
    self.m_Text = nil
    self.m_GetBtn:SetActive(false)
    self.m_RewardItemBox:SetActive(false)
    g_NotifyCtrl:FloatItemBox(self.m_ExistItemRwd, self.m_RewardItemBox:GetPos(), 0, false)
    self.m_ExistItemRwd = nil
    self.m_SureBtn:SetActive(true)

    if self.m_LastSixCount > 0 then
        self.m_DiceGrid:SetActive(true)
        self:InitDiceGrid(self.m_LastSixCount)
    end
end

function CScheduleCrapsView.CloseView(self)
    CViewBase.CloseView(self)
    if not Utils.IsIOS() then
        UnityEngine.Screen.autorotateToLandscapeLeft = true
        UnityEngine.Screen.autorotateToLandscapeRight = true
    end
end

function CScheduleCrapsView.SetBtnActive(self, btn, bIsActive)
    -- body
    btn:SetActive(bIsActive)
end

function CScheduleCrapsView.OnClose(self)
    if self.m_IsShootCraps then
        g_CrapsCtrl:C2GSShootCrapEnd()
    end

    CViewBase.OnClose(self)
end

return CScheduleCrapsView