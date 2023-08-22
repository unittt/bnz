module(...)
System={
    PARTNER_SYS={
        sub={"PARTNER_BZ"},
    },
    PARTNER_BZ={
        main="PARTNER_SYS",
    },

    SKILL_SYS={
        sub={"HELPSKILL","SKILL_ZD","XIU_LIAN_SYS"},
    },
    HELPSKILL={
        main="SKILL_SYS",
    },
    SKILL_ZD={
        main="SKILL_SYS",
    },
    XIU_LIAN_SYS={
        main="SKILL_SYS",
    },

    GROW={
        main="ZHIYIN",
    },
    ZHIYIN={
        sub={"GROW"},
    },

    RANK_SYS={
        eff_config={
            {eff_type="Circu"},
        },
    },

    EQUIP_SYS={
        sub={"EQUIP_DZ","EQUIP_XL","EQUIP_FH"},
    },
    EQUIP_DZ={
        main="EQUIP_SYS",
    },
    EQUIP_XL={
        main="EQUIP_SYS",
    },
    EQUIP_FH={
        main="EQUIP_SYS",
    },

    BAG_S={
        sub={"VIGOR"},
    },
    VIGOR={
        main="BAG_S",
    },

    JJC_SYS={
        record_cnt=2,
    },

    RIDE_SYS={
        eff_config={
            {eff_type="Circu"},
        },
    },

    ROLE_S={
        eff_config={
            {eff_type="RedDot",pos={-22,-23},size=24},
        },
        sub={"ROLE_ADDPOINT"},
    },
    ROLE_ADDPOINT={
        main="ROLE_S",
    },

    TRADE_S={
        sub={"AUCTION"},
    },
    AUCTION={
        main="TRADE_S",
    },

    BADGE={
        eff_config={
            {eff_type="Circu"},
        },
    },
}