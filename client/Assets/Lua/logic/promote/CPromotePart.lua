local CPromotePart = class("CPromotePart", CPageBase)


function CPromotePart.ctor(self, obj)
    CPageBase.ctor(self, obj)
    
    self.m_SelIndex = 1
end

function CPromotePart.OnInitPage(self)
    self.m_LeftGrid = self:NewUI(1, CGrid)
    self.m_LeftBoxClone = self:NewUI(2, CBox)
    self.m_CurMarkLabel = self:NewUI(4, CLabel)
    self.m_MoreMarkLabel = self:NewUI(3, CLabel)
    self.m_SysGrid = self:NewUI(5, CGrid)
    self.m_SysBox = self:NewUI(6, CBox)
    self.m_MarkLabel = self:NewUI(7, CLabel)
    self.m_RightGrid = self:NewUI(8, CGrid)
    self.m_RightBoxClone = self:NewUI(9, CBox)
    self.m_RightPage = self:NewUI(10, CScrollView)
    self.m_ScrollPage = self:NewUI(11, CScrollView)
    self.m_TipsLabel = self:NewUI(12, CLabel)
    self.m_MarkSp = self:NewUI(13, CSprite)
    
    -- g_PromoteCtrl:C2GSGetPromote()
    self:InitContent()
    g_PromoteCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnRefresh"))
    g_ScheduleCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnScheduleCtrl"))
    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrCtrl"))
end

function CPromotePart.OnRefresh(self, oCtrl)
    if oCtrl.m_EventID == define.Promote.Event.Refresh then
       self:InitContent()
       self:CreatPowerGrid()
       self:RefreshMark()
    end
end

function CPromotePart.OnScheduleCtrl(self, oCtrl)
    if oCtrl.m_EventID == define.Schedule.Event.RefreshMainUI or oCtrl.m_EventID == define.Schedule.Event.RefreshSchedule then
       self:InitContent()
       self:CreatPowerGrid()
       self:RefreshMark()
    end
end

function CPromotePart.OnAttrCtrl(self, oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.RefreshAssistExp then
        self:CreatOtherGrid()
    end
end

function CPromotePart.InitContent(self)
    self:ShowLeft()
    self.m_TipsLabel:SetActive(false)
    self.m_RightPage:SetDisableDragIfFits(true)
    --self:ShowRight(1)
end

function CPromotePart.ShowLeft(self)
    local tInfo = {
              {name = "我要变强",icon = "h7_bianqiang"},
              {name = "我要升级",icon = "h7_shengji"},
              {name = "我要银币",icon = "h7_yaoying"},
              {name = "我要金币",icon = "h7_yaojin"},
              --{name = "我要装备",icon = "h7_zhuangbei"},
              --{name = "我要强化",icon = "h7_qianghua"},
              {name = "我要修炼",icon = "h7_xiulian"},
    }
    -- local typeData = {}
    -- for k,v in pairs(tInfo) do
    --     if table.count(self:GetOpneSysList(g_PromoteCtrl:GetPromrteTypeData(k))) > 0 then
    --        typeData[#typeData + 1] = v
    --     end 
    -- end
    for i,v in ipairs(tInfo) do
        local box = self.m_LeftGrid:GetChild(i)
        if box == nil then
           box = self.m_LeftBoxClone:Clone()
           box.name = box:NewUI(1, CLabel)
           box.icon = box:NewUI(2, CSprite)
           box.sName = box:NewUI(3, CLabel)
           self.m_LeftGrid:AddChild(box)
           box:SetGroup(self.m_LeftGrid:GetInstanceID())
        end
        box:SetActive(true)
        box.name:SetText(v.name)
        box.icon:SetSpriteName(v.icon)
        box:AddUIEvent("click",callback(self,"OnPromote",i,v))
        if self.m_select == nil  then
           box:SetSelected(true)
           self:ShowRight(1)
        elseif self.m_select == i then
           self:ShowRight(i)
        end                           
    end
end

function CPromotePart.ShowRight(self,index)
    self.m_select = index
    if index == 1 then
       self.m_RightPage:SetActive(true)
       self.m_ScrollPage:SetActive(false)
       self:CreatPowerGrid()
       self:RefreshMark()
    else
       self.m_RightPage:SetActive(false)
       self.m_ScrollPage:SetActive(true)
       self:CreatOtherGrid(index)
       self.m_ScrollPage:ResetPosition()
    end 
end

function CPromotePart.CreatPowerGrid(self)
    local guidInfo = g_PromoteCtrl:GetPromrteTypeData(1)
    local tMarkInfo = data.promotedata.JUDGE
    guidInfo = self:GetOpneSysList(guidInfo)
    if #guidInfo <= 0 then
        self.m_TipsLabel:SetActive(true)
    else
        self.m_TipsLabel:SetActive(false)
    end
    local i = 1
    for k,v in pairs(guidInfo) do
        if v.name ~= "装备附魂" then  --暂时屏蔽装备附魂
          local box = self.m_SysGrid:GetChild(i)
          if box == nil then
             box = self.m_SysBox:Clone()
             box.icon = box:NewUI(1,CSprite)
             box.name = box:NewUI(2,CLabel)
             box.m_Slider = box:NewUI(3,CSlider)
             box.m_Process = box:NewUI(4,CLabel)
             box.goBtn = box:NewUI(5,CButton)
             box.m_Des = box:NewUI(6,CLabel)
             box.m_Finished = box:NewUI(7,CSprite)
             box.m_SliderEff = box:NewUI(8,CObject)
             self.m_SysGrid:AddChild(box)
          end
          box:SetActive(true)
          box.goBtn:SetActive(true)
          box.m_Finished:SetActive(false)
          box.icon:SetSpriteName(v.icon)
          local sysRadio = g_PromoteCtrl.m_SysMarkInfo.radio[k]
          if sysRadio then
             local radioValue = self:GetSysLevelDes(sysRadio,tMarkInfo)
             --服务器返回玩家  开启的系统的值，与promotedata.JUDGE 的值对比
             box.m_Process:SetText(radioValue.progress)
             box.m_Slider:SetValue(0.01 + sysRadio/data.promotedata.JUDGE[1].radio*(1-0.01))
             if sysRadio <= 0 then
                box.m_SliderEff:SetActive(true)
             end

             if sysRadio >= data.promotedata.JUDGE[1].radio then
                box.goBtn:SetActive(false)
                box.m_Finished:SetActive(true)
             end
          end
          box.name:SetText(v.name) 
          box.goBtn:AddUIEvent("click",callback(self,"OnGo",v))
          i = i + 1
        end
    end
end

function CPromotePart.RefreshFinish(self, v, box)
    local scheduleId = v.scheduleId
    if scheduleId <= 0 or v.type_id == 2004 then
       return 
    end
    local scheduleInfo = g_ScheduleCtrl:GetScheduleData(scheduleId)

    --金刚伏魔次数限制调整
    if scheduleId == 1004 then
       if scheduleInfo and scheduleInfo.times and scheduleInfo.times >= 120 then
          box.m_Finished:SetActive(true)
          box.goBtn:SetActive(false)
       end
       return
    end

    if scheduleInfo and scheduleInfo.times then
       if scheduleInfo.times >= scheduleInfo.maxtimes then
          box.m_Finished:SetActive(true)
          box.goBtn:SetActive(false)
        end
    end
end

function CPromotePart.CreatOtherGrid(self, index)
    if index then
      self.m_SelIndex = index
    end
    local guidInfo = g_PromoteCtrl:GetPromrteTypeData(self.m_SelIndex)
    local count = table.count(guidInfo)
    local openData = self:GetOpneSysList(guidInfo)
    if #openData <= 0 then
       self.m_TipsLabel:SetActive(true)
    else
       self.m_TipsLabel:SetActive(false)
    end

    local i = 1
    for k,v in pairs(openData) do
        local box = self.m_RightGrid:GetChild(i)
        if box == nil then
           box = self.m_RightBoxClone:Clone()
           box.icon = box:NewUI(1,CSprite)
           box.name = box:NewUI(2,CLabel)
           box.des = box:NewUI(3,CLabel)
           box.goBtn = box:NewUI(4,CButton)
           box.m_Finished = box:NewUI(5,CSprite)
           box.m_StarGrid = box:NewUI(6, CGrid)
           box.m_StarClone = box:NewUI(7, CSprite)
           box.exp = box:NewUI(8, CLabel)
           box.collider = box:GetComponent(classtype.BoxCollider)
           self.m_RightGrid:AddChild(box)
        end
        box.m_StarClone:SetActive(false)
        box:SetActive(true)
        box.m_Finished:SetActive(false)

        if count < 5 then
           box.collider.enabled = false
        else
           box.collider.enabled = true
        end
        box.icon:SetSpriteName(v.icon)
        box.name:SetText(v.name)
        box.des:SetText(v.des) 
        
        if #v.star == 2 then
            box.m_StarGrid:SetActive(true)
            box.name:SetLocalPos(Vector3.New(-174, 15, 0))
            self:SetStart(box, v.star[1], v.star[2])
        else
            box.m_StarGrid:SetActive(false)
            box.name:SetLocalPos(Vector3.New(-174, 0, 0))
        end
        if v.type_id == 2004 then
            box.goBtn:SetActive(false)
            box.des:SetSize(416, 20)
            box.des:SetLocalPos(Vector3(-87, 16, 0))
            box.exp:SetActive(true)
            local maxAssistExp = g_AttrCtrl.m_MaxAssistExp
            local curAssistExp = g_AttrCtrl.m_AssistExp
            box.exp:SetText(string.format("今日协助经验: %d/%d", curAssistExp, maxAssistExp))
        else
            box.des:SetSize(270, 80)
            box.des:SetLocalPos(Vector3(-87, 0, 0))
            box.exp:SetActive(false)
            box.goBtn:SetActive(true)
            box.exp:SetActive(false)
            box.goBtn:AddUIEvent("click",callback(self,"OnGo",v))
        end       
        self:RefreshFinish(v,box)

        i = i + 1
    end
    

    for j = #openData + 1,self.m_RightGrid:GetCount() do
        local child = self.m_RightGrid:GetChild(j)
        child:SetActive(false)
    end
end

function CPromotePart.SetStart(self, oBox, count, oMax)
  local startBoxList = oBox.m_StarGrid:GetChildList()
  local startBox = nil
  for i=1, oMax do
      if i > #startBoxList then
        startBox = oBox.m_StarClone:Clone()
        oBox.m_StarGrid:AddChild(startBox)
        startBox:SetActive(true)
      else
        startBox = startBoxList[i]
      end
      startBox:SetGrey(i > count)
  end
end

function CPromotePart.OnGo(self, goInfo)
   -- 请求协议参加活动 RequestServer（1、寻人 2、跳转 3、任务 4、UI）
    if g_OpenSysCtrl:GetOpenSysState(goInfo.open_id,true)  then
        if goInfo.opentype == 1 then
          g_MapTouchCtrl:WalkToGlobalNpc(goInfo.openid)
          CGaideMainView:CloseView()
        elseif goInfo.opentype == 2 then
          printc("-------类型2-----")
        elseif goInfo.opentype == 3 then
          --CTaskHelp.ScheduleTaskLogic(goInfo.openid)
          local taskTypeDic = g_TaskCtrl.m_TaskCategoryTypeDic[goInfo.openid]
          local _, oTask = next(taskTypeDic)
          if oTask then
            -- 存在任务，直接开始寻路
            CTaskHelp.ClickTaskLogic(oTask)
            CGaideMainView:CloseView()
            return
          end

          -- 检查到没有任务，开始寻路到接取任务Npc处
          local taskTypeInfo = DataTools.GetTaskType(goInfo.openid)
          local npcid = taskTypeInfo.npcid
          if npcid > 0 then
            if npcid < 100 then
              -- 当npcid小于100，判定为虚拟npcid（门派npcid）
              npcid = DataTools.GetSchoolNpcID(g_AttrCtrl.school)
            end
            g_MapTouchCtrl:WalkToGlobalNpc(npcid)
          end
          CGaideMainView:CloseView()
        elseif goInfo.opentype == 4 then
          if goInfo.type_id == 1009 then
              g_SummonCtrl:ShowCultureView()
              return
          end
          if goInfo.go[1] == "坐骑" then
             if next(g_HorseCtrl:GetAllHorse()) == nil then
              g_NotifyCtrl:FloatMsg("您当前没有坐骑！")
              return
             end
          end
          if goInfo.open_id == "YIBAO" then
              if g_TaskCtrl.m_TaskDataDic[g_TaskCtrl:GetYibaoMainTaskid().taskid] then
                CTaskHelp.ClickTaskLogic(g_TaskCtrl.m_TaskDataDic[g_TaskCtrl:GetYibaoMainTaskid().taskid])
                return
              end
          end
          if goInfo.open_id == "FENGYAO" then
              -- local mapID
              -- local sealNpcMapInfo = DataTools.GetSealNpcMapInfo(g_AttrCtrl.grade)
              -- if not sealNpcMapInfo then
              --     return
              -- end
              -- mapID = sealNpcMapInfo.mapid
              --g_MapCtrl:C2GSClickWorldMap(mapID)
              nethuodong.C2GSFengYaoAutoFindNPC()
              --g_NotifyCtrl:FloatMsg("战胜该场景的闹事妖怪可获得丰厚奖励")
              CGaideMainView:CloseView()
              return
          end
          g_ViewCtrl:ShowViewBySysName(goInfo.go[1],goInfo.go[2])
        end
    end
end

function CPromotePart.OnPromote(self, type, info)
    local box = self.m_LeftGrid:GetChild(type)
    box.sName:SetText(info.name)
    self:ShowRight(type)
end

function CPromotePart.RefreshMark(self)
    local mark_info = data.promotedata.SCORE
    local tMarkInfo = data.promotedata.JUDGE
    if mark_info then
       local mark_point = self:GetNumberString(g_AttrCtrl.score)
       local dScore = mark_info[g_AttrCtrl.grade].reference_score
       local sumscore = self:GetNumberString(dScore)
       local markLv = ""
       -- if g_PromoteCtrl.m_SysMarkInfo.result >= 3 then
       self.m_CurMarkLabel:SetText(mark_point) 
       self.m_MoreMarkLabel:SetText(sumscore)
       local score = tMarkInfo[g_PromoteCtrl.m_SysMarkInfo.result].score 
        for i=1,string.len(score) do
          local v = string.sub(score, i, i)
           -- markLv = markLv.."#mark_"..v
           markLv = markLv..v
        end
        -- self.m_MarkLabel:SetText(markLv)
        self.m_MarkSp:SetSpriteName("h7_score_"..markLv)
    end
end

--获取评分的每一个数字存进一个列表
function CPromotePart.GetEachNumList(self,targetnum)
  --列表是尾插入，越后面的是越高位
  local realPrizeNumList = {}
  local num = targetnum
  while num ~= 0 do
    table.insert(realPrizeNumList,num%10)
    num = math.modf(num/10)
  end
  return realPrizeNumList
end

function CPromotePart.GetNumberString(self,markNum)
    if markNum == 0 then
        return "#mark_0"
    end
    local rawNum = ""
    local realPrizeNumList = self:GetEachNumList(markNum) 
    local numStr = ""
    for k,v in ipairs(realPrizeNumList) do
        numStr = "#mark_"..v..numStr
        rawNum = v..rawNum
    end
    return numStr
end

function CPromotePart.GetSysLevelDes(self, radio, info)
    local length = #info
    for i= length ,1,-1 do
        if radio <= info[i].radio then
           return info[i]
        elseif radio > info[1].radio then
           return info[1]
        end 
    end
end

function CPromotePart.GetOpneSysList(self, info)
    local openData = {}
    for k,v in ipairs(info) do
        if g_OpenSysCtrl:GetOpenSysState(v.open_id) then
          --printc(v.open_id,"开放的",k)
           openData[k] = v
        end
    end
    return openData
end

return CPromotePart