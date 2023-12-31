-- ./excel/perform/perform_se.xlsx
return {

    [9000] = {
        ai_action_type = 104,
        ai_target = 2,
        cd = 0,
        desc = "为自己或队友恢复一定量的气血,消耗30点怒气",
        effectType = 1114,
        id = 9000,
        is_active = 1,
        name = "治疗",
        pflogic = 9000,
        priority = 100,
        skill_icon = 51205,
        type_desc = "单体恢复",
    },

    [9001] = {
        ai_action_type = 104,
        ai_target = 2,
        cd = 0,
        desc = "为自己或队友恢复气血量=400+气血上限的6%,消耗60点怒气",
        effectType = 1114,
        id = 9001,
        is_active = 1,
        name = "名医治疗",
        pflogic = 9001,
        priority = 100,
        skill_icon = 51205,
        type_desc = "单体恢复",
    },

    [9002] = {
        ai_action_type = 104,
        ai_target = 2,
        cd = 0,
        desc = "为自己或队友恢复气血量=600+气血上限的9%,消耗90点怒气",
        effectType = 1114,
        id = 9002,
        is_active = 1,
        name = "御医治疗",
        pflogic = 9002,
        priority = 100,
        skill_icon = 51205,
        type_desc = "单体恢复",
    },

    [9003] = {
        ai_action_type = 106,
        ai_target = 2,
        cd = 0,
        desc = "为自己恢复魔法值=自身等级*5+魔法上限的10%,消耗50点怒气",
        effectType = 1114,
        id = 9003,
        is_active = 1,
        name = "回气术",
        pflogic = 9003,
        priority = 100,
        skill_icon = 51205,
        type_desc = "单体恢复",
    },

    [9004] = {
        ai_action_type = 106,
        ai_target = 2,
        cd = 0,
        desc = "为自己恢复魔法值=自身等级*10+魔法上限的15%,消耗80点怒气",
        effectType = 1114,
        id = 9004,
        is_active = 1,
        name = "聚气术",
        pflogic = 9004,
        priority = 100,
        skill_icon = 51205,
        type_desc = "单体恢复",
    },

    [9005] = {
        ai_action_type = 104,
        ai_target = 2,
        cd = 0,
        desc = "为自己恢复气血量=气血上限的25%，但不超过等级*12,消耗60点怒气",
        effectType = 1114,
        id = 9005,
        is_active = 1,
        name = "续命术",
        pflogic = 9005,
        priority = 100,
        skill_icon = 51205,
        type_desc = "单体恢复",
    },

    [9006] = {
        ai_action_type = 104,
        ai_target = 2,
        cd = 0,
        desc = "为自己恢复气血量=气血上限的50%，但不超过等级*20,消耗130点怒气",
        effectType = 1114,
        id = 9006,
        is_active = 1,
        name = "回命术",
        pflogic = 9006,
        priority = 100,
        skill_icon = 51205,
        type_desc = "单体恢复",
    },

    [9007] = {
        ai_action_type = 204,
        ai_target = 2,
        cd = 0,
        desc = "为己方全体恢复一定量的气血，对有“鬼魂”技能的宠物无效,消耗140点怒气",
        effectType = 1114,
        id = 9007,
        is_active = 1,
        name = "天降甘霖",
        pflogic = 9007,
        priority = 100,
        skill_icon = 51202,
        type_desc = "群体恢复",
    },

    [9008] = {
        ai_action_type = 206,
        ai_target = 2,
        cd = 0,
        desc = "为己方所有队员恢复魔法量=魔法上限的25%，但最大不超过其等级*12,消耗80点怒气",
        effectType = 1114,
        id = 9008,
        is_active = 1,
        name = "凝神归元",
        pflogic = 9008,
        priority = 100,
        skill_icon = 51202,
        type_desc = "群体恢复",
    },

    [9009] = {
        ai_action_type = 107,
        ai_target = 2,
        cd = 0,
        desc = "复活已死亡的队友，恢复其150点气血,消耗100点怒气",
        effectType = 1114,
        id = 9009,
        is_active = 1,
        name = "回魂术",
        pflogic = 9009,
        priority = 100,
        skill_icon = 51202,
        type_desc = "单体复活",
    },

    [9010] = {
        ai_action_type = 107,
        ai_target = 2,
        cd = 0,
        desc = "复活已死亡的队友，恢复其50%气血,消耗120点怒气",
        effectType = 1114,
        id = 9010,
        is_active = 1,
        name = "浴火重生",
        pflogic = 9010,
        priority = 100,
        skill_icon = 51204,
        type_desc = "单体复活",
    },

    [9011] = {
        ai_action_type = 207,
        ai_target = 2,
        cd = 0,
        desc = "复活所有队友，使其气血完全恢复；使用后自己的法力值为零、气血和气血上限均降为最大值的10%；不能复活鬼魂，消耗150点怒气",
        effectType = 1114,
        id = 9011,
        is_active = 1,
        name = "慈航普度",
        pflogic = 9011,
        priority = 100,
        skill_icon = 51207,
        type_desc = "群体复活",
    },

    [9012] = {
        ai_action_type = 105,
        ai_target = 2,
        cd = 0,
        desc = "为己方单体解除各种异常状态,消耗40点怒气",
        effectType = 1114,
        id = 9012,
        is_active = 1,
        name = "定心诀",
        pflogic = 9012,
        priority = 100,
        skill_icon = 51207,
        type_desc = "解除封印",
    },

    [9013] = {
        ai_action_type = 105,
        ai_target = 2,
        cd = 0,
        desc = "为己方单体解除各种异常状态，并恢复气血量=气血上限的25%，但不超过其等级*12,消耗80点怒气",
        effectType = 1114,
        id = 9013,
        is_active = 1,
        name = "平心诀",
        pflogic = 9013,
        priority = 100,
        skill_icon = 51207,
        type_desc = "解除封印",
    },

    [9014] = {
        ai_action_type = 205,
        ai_target = 2,
        cd = 0,
        desc = "解除己方全体的异常状态,消耗110点怒气",
        effectType = 1114,
        id = 9014,
        is_active = 1,
        name = "圣心诀",
        pflogic = 9014,
        priority = 100,
        skill_icon = 51207,
        type_desc = "解除封印",
    },

    [9015] = {
        ai_action_type = 205,
        ai_target = 2,
        cd = 0,
        desc = "解除己方全体的异常状态，并恢复一定量的气血，对有“鬼魂”技能的宠物无效,消耗150点怒气",
        effectType = 1114,
        id = 9015,
        is_active = 1,
        name = "宁心诀",
        pflogic = 9015,
        priority = 100,
        skill_icon = 50120,
        type_desc = "解除封印",
    },

    [9016] = {
        ai_action_type = 108,
        ai_target = 2,
        cd = 0,
        desc = "减少敌人单人愤怒值70点,消耗40点怒气",
        effectType = 1114,
        id = 9016,
        is_active = 1,
        name = "道友息怒",
        pflogic = 9016,
        priority = 100,
        skill_icon = 50128,
        type_desc = "单体辅助",
    },

    [9017] = {
        ai_action_type = 106,
        ai_target = 2,
        cd = 0,
        desc = "提高己方单体10%攻击力，效果不叠加，持续至战斗结束,消耗40点怒气",
        effectType = 1114,
        id = 9017,
        is_active = 1,
        name = "狂兽之术",
        pflogic = 9017,
        priority = 100,
        skill_icon = 50218,
        type_desc = "单体辅助",
    },

    [9018] = {
        ai_action_type = 206,
        ai_target = 2,
        cd = 0,
        desc = "提高己方全体5%物理攻击力，效果不叠加，持续至战斗结束,消耗70点怒气",
        effectType = 1114,
        id = 9018,
        is_active = 1,
        name = "狂兽神术",
        pflogic = 9018,
        priority = 100,
        skill_icon = 50145,
        type_desc = "群体辅助",
    },

    [9019] = {
        ai_action_type = 106,
        ai_target = 2,
        cd = 0,
        desc = "提高己方单体10%防御，效果不叠加，持续至战斗结束,消耗40点怒气",
        effectType = 1114,
        id = 9019,
        is_active = 1,
        name = "固甲术",
        pflogic = 9019,
        priority = 100,
        skill_icon = 50145,
        type_desc = "单体辅助",
    },

    [9020] = {
        ai_action_type = 206,
        ai_target = 2,
        cd = 0,
        desc = "提高己方全体5%防御，效果不叠加，持续至战斗结束,消耗80点怒气",
        effectType = 1114,
        id = 9020,
        is_active = 1,
        name = "圣甲术",
        pflogic = 9020,
        priority = 100,
        skill_icon = 50145,
        type_desc = "群体辅助",
    },

    [9021] = {
        ai_action_type = 106,
        ai_target = 2,
        cd = 0,
        desc = "提高己方单体10%速度，效果不叠加，持续至战斗结束,消耗40点怒气",
        effectType = 1114,
        id = 9021,
        is_active = 1,
        name = "狂风诀",
        pflogic = 9021,
        priority = 100,
        skill_icon = 50145,
        type_desc = "单体辅助",
    },

    [9022] = {
        ai_action_type = 206,
        ai_target = 2,
        cd = 0,
        desc = "提高己方全体5%速度，效果不叠加，持续至战斗结束,消耗80点怒气",
        effectType = 1114,
        id = 9022,
        is_active = 1,
        name = "神风诀",
        pflogic = 9022,
        priority = 100,
        skill_icon = 50145,
        type_desc = "群体辅助",
    },

    [9023] = {
        ai_action_type = 106,
        ai_target = 2,
        cd = 0,
        desc = "只能对自己使用，使自己三回合内受到攻击的伤害降低30%，并将此部分伤害返还给攻击者,消耗120点怒气",
        effectType = 1114,
        id = 9023,
        is_active = 1,
        name = "摩罗咒",
        pflogic = 9023,
        priority = 100,
        skill_icon = 50145,
        type_desc = "单体辅助",
    },

    [9024] = {
        ai_action_type = 108,
        ai_target = 2,
        cd = 0,
        desc = "降低敌方单体10%攻击力，效果不叠加，持续至战斗结束,消耗45点怒气",
        effectType = 1114,
        id = 9024,
        is_active = 1,
        name = "回头是岸",
        pflogic = 9024,
        priority = 100,
        skill_icon = 50147,
        type_desc = "单体辅助",
    },

    [9025] = {
        ai_action_type = 208,
        ai_target = 2,
        cd = 0,
        desc = "降低敌方全体5%物理攻击力，效果不叠加，持续至战斗结束,消耗80点怒气",
        effectType = 1114,
        id = 9025,
        is_active = 1,
        name = "当头棒喝",
        pflogic = 9025,
        priority = 100,
        skill_icon = 50147,
        type_desc = "群体辅助",
    },

    [9026] = {
        ai_action_type = 108,
        ai_target = 2,
        cd = 0,
        desc = "降低敌方单体10%物理防御，效果不叠加，持续至战斗结束,消耗40点怒气",
        effectType = 1114,
        id = 9026,
        is_active = 1,
        name = "破甲术",
        pflogic = 9026,
        priority = 100,
        skill_icon = 50147,
        type_desc = "单体辅助",
    },

    [9027] = {
        ai_action_type = 208,
        ai_target = 2,
        cd = 0,
        desc = "降低敌方全体5%物理防御，效果不叠加，持续至战斗结束,消耗80点怒气",
        effectType = 1114,
        id = 9027,
        is_active = 1,
        name = "破盾术",
        pflogic = 9027,
        priority = 100,
        skill_icon = 50147,
        type_desc = "群体辅助",
    },

    [9028] = {
        ai_action_type = 108,
        ai_target = 2,
        cd = 0,
        desc = "降低敌方单体10%速度，效果不叠加，持续至战斗结束,消耗40点怒气",
        effectType = 1114,
        id = 9028,
        is_active = 1,
        name = "霜冻术",
        pflogic = 9028,
        priority = 100,
        skill_icon = 50147,
        type_desc = "单体辅助",
    },

    [9029] = {
        ai_action_type = 208,
        ai_target = 2,
        cd = 0,
        desc = "降低敌方全体5%速度，效果不叠加，持续至战斗结束,消耗80点怒气",
        effectType = 1114,
        id = 9029,
        is_active = 1,
        name = "冰天术",
        pflogic = 9029,
        priority = 100,
        skill_icon = 50147,
        type_desc = "群体辅助",
    },

    [9030] = {
        ai_action_type = 101,
        ai_target = 2,
        cd = 0,
        desc = "对敌方单人连续使用两次普通物理攻击,消耗80点怒气",
        effectType = 1114,
        id = 9030,
        is_active = 1,
        name = "无双连斩",
        pflogic = 9030,
        priority = 100,
        skill_icon = 51403,
        type_desc = "单体攻击",
    },

    [9031] = {
        ai_action_type = 101,
        ai_target = 2,
        cd = 0,
        desc = "对敌方单人连续使用两次普通法术攻击,消耗80点怒气",
        effectType = 1114,
        id = 9031,
        is_active = 1,
        name = "无双法连",
        pflogic = 9031,
        priority = 100,
        skill_icon = 51305,
        type_desc = "单体攻击",
    },

    [9032] = {
        ai_action_type = 101,
        ai_target = 2,
        cd = 0,
        desc = "临时提高自身的物理攻击力，但是伤害结果降低，适合对付高防御的目标,消耗50点怒气",
        effectType = 1114,
        id = 9032,
        is_active = 1,
        name = "破绽突破",
        pflogic = 9032,
        priority = 100,
        skill_icon = 51305,
        type_desc = "单体攻击",
    },

    [9033] = {
        ai_action_type = 101,
        ai_target = 2,
        cd = 0,
        desc = "减少敌方单人当前气血的20%，自己增加相应量的气血但不超过自己等级*15；对BOSS无效,消耗70点怒气",
        effectType = 1114,
        id = 9033,
        is_active = 1,
        name = "气血转换",
        pflogic = 9033,
        priority = 100,
        skill_icon = 51305,
        type_desc = "单体攻击",
    },

    [9034] = {
        ai_action_type = 108,
        ai_target = 2,
        cd = 0,
        desc = "减少敌方单人当前魔法的30%，自己增加相应量的魔法但不超过自己等级*10；对NPC无效,消耗90点怒气",
        effectType = 1114,
        id = 9034,
        is_active = 1,
        name = "法力汲取",
        pflogic = 9034,
        priority = 100,
        skill_icon = 51305,
        type_desc = "单体辅助",
    },

    [9035] = {
        ai_action_type = 101,
        ai_target = 2,
        cd = 0,
        desc = "减少敌方单人一定气血,消耗60点怒气",
        effectType = 1114,
        id = 9035,
        is_active = 1,
        name = "穿心刺",
        pflogic = 9035,
        priority = 100,
        skill_icon = 51305,
        type_desc = "单体攻击",
    },

    [9036] = {
        ai_action_type = 201,
        ai_target = 2,
        cd = 0,
        desc = "减少敌方最多5人一定气血,消耗110点怒气",
        effectType = 1114,
        id = 9036,
        is_active = 1,
        name = "断魂斩",
        pflogic = 9036,
        priority = 100,
        skill_icon = 51305,
        type_desc = "群体攻击",
    },

    [9037] = {
        ai_action_type = 101,
        ai_target = 2,
        cd = 0,
        desc = "以物理攻击敌人，并同时减少其一定魔法值,消耗60点怒气",
        effectType = 1114,
        id = 9037,
        is_active = 1,
        name = "神剑破法",
        pflogic = 9037,
        priority = 100,
        skill_icon = 51305,
        type_desc = "单体攻击",
    },

    [9038] = {
        ai_action_type = 106,
        ai_target = 2,
        cd = 0,
        desc = "使自己四回合内抵御一切的附加效果,消耗90点怒气",
        effectType = 1114,
        id = 9038,
        is_active = 1,
        name = "禅言定心",
        pflogic = 9038,
        priority = 100,
        skill_icon = 51305,
        type_desc = "单体辅助",
    },

    [9039] = {
        ai_action_type = 106,
        ai_target = 2,
        cd = 0,
        desc = "使己方单人隐身一回合,消耗40点怒气",
        effectType = 1114,
        id = 9039,
        is_active = 1,
        name = "影遁",
        pflogic = 9039,
        priority = 100,
        skill_icon = 50218,
        type_desc = "单体辅助",
    },

    [9203] = {
        ai_action_type = 53,
        ai_target = 2,
        cd = 0,
        desc = "普通物理攻击时，有3%几率对目标追加一次普通攻击，每次追加的攻击其伤害结果会降低20%。（特效指定部位：武器）",
        effectType = 1114,
        id = 9203,
        is_active = 0,
        name = "连斩",
        pflogic = 9203,
        priority = 100,
        skill_icon = 50022,
        type_desc = "单体辅助",
    },

    [9204] = {
        ai_action_type = 53,
        ai_target = 2,
        cd = 0,
        desc = "普通物理攻击时有20%几率将当前气血小于攻击者等级×20的普通怪物直接击飞。（只对NPC起效，若为鬼魂生物则直接击倒）",
        effectType = 1114,
        id = 9204,
        is_active = 0,
        name = "击退",
        pflogic = 9204,
        priority = 100,
        skill_icon = 50018,
        type_desc = "单体辅助",
    },

    [9205] = {
        ai_action_type = 53,
        ai_target = 2,
        cd = 0,
        desc = "选择防御指令时，所受到的物理伤害由50%降为40%",
        effectType = 1114,
        id = 9205,
        is_active = 0,
        name = "固防",
        pflogic = 9205,
        priority = 100,
        skill_icon = 50036,
        type_desc = "单体辅助",
    },

    [9206] = {
        ai_action_type = 53,
        ai_target = 2,
        cd = 0,
        desc = "每回合开始时可以回复小量气血",
        effectType = 1114,
        id = 9206,
        is_active = 0,
        name = "自我恢复",
        pflogic = 9206,
        priority = 100,
        skill_icon = 50049,
        type_desc = "单体辅助",
    },

    [9207] = {
        ai_action_type = 53,
        ai_target = 2,
        cd = 0,
        desc = "战斗中使用法术时有15%几率不消耗魔法",
        effectType = 1114,
        id = 9207,
        is_active = 0,
        name = "凝神",
        pflogic = 9207,
        priority = 100,
        skill_icon = 50029,
        type_desc = "单体辅助",
    },

    [9208] = {
        ai_action_type = 53,
        ai_target = 2,
        cd = 0,
        desc = "自动为出场宠物添加（伤害结果提高10%）状态，持续八回合（对鬼魂宠物无效）",
        effectType = 1114,
        id = 9208,
        is_active = 0,
        name = "御灵",
        pflogic = 9208,
        priority = 100,
        skill_icon = 50016,
        type_desc = "单体辅助",
    },

    [9209] = {
        ai_action_type = 53,
        ai_target = 2,
        cd = 0,
        desc = "因气血损失而增加愤怒时，会额外获得20%的愤怒",
        effectType = 1114,
        id = 9209,
        is_active = 0,
        name = "易怒",
        pflogic = 9209,
        priority = 100,
        skill_icon = 50045,
        type_desc = "单体辅助",
    },

    [9210] = {
        ai_action_type = 53,
        ai_target = 2,
        cd = 0,
        desc = "使用特技消耗的愤怒值降低为80%",
        effectType = 1114,
        id = 9210,
        is_active = 0,
        name = "怒气节制",
        pflogic = 9210,
        priority = 100,
        skill_icon = 50035,
        type_desc = "单体辅助",
    },

    [9212] = {
        ai_action_type = 53,
        ai_target = 2,
        cd = 0,
        desc = "气血为0时，有20%几率复活并恢复一定气血",
        effectType = 1114,
        id = 9212,
        is_active = 0,
        name = "返生",
        pflogic = 9212,
        priority = 100,
        skill_icon = 50032,
        type_desc = "单体辅助",
    },

    [9213] = {
        ai_action_type = 53,
        ai_target = 2,
        cd = 0,
        desc = "受到药品的治疗效果提高10%",
        effectType = 1114,
        id = 9213,
        is_active = 0,
        name = "药力催化",
        pflogic = 9213,
        priority = 100,
        skill_icon = 50020,
        type_desc = "单体辅助",
    },

    [9214] = {
        ai_action_type = 53,
        ai_target = 2,
        cd = 0,
        desc = "对他人使用有恢复效果的药品时，自身也会受到10%的恢复效果",
        effectType = 1114,
        id = 9214,
        is_active = 0,
        name = "药力吸收",
        pflogic = 9214,
        priority = 100,
        skill_icon = 50020,
        type_desc = "单体辅助",
    },

    [9215] = {
        ai_action_type = 53,
        ai_target = 2,
        cd = 0,
        desc = "有3%的概率在当前回合开始时增加速度10%",
        effectType = 1114,
        id = 9215,
        is_active = 0,
        name = "疾风",
        pflogic = 9215,
        priority = 100,
        skill_icon = 50034,
        type_desc = "单体辅助",
    },

    [9211] = {
        ai_action_type = 53,
        ai_target = 2,
        cd = 0,
        desc = "使用药品的效果提高10%",
        effectType = 1114,
        id = 9211,
        is_active = 0,
        name = "药理掌握",
        pflogic = 9211,
        priority = 100,
        skill_icon = 50033,
        type_desc = "单体辅助",
    },

}
