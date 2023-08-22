module(...)
GCStep = 1024 -- lua gc step 大小
UnloadAtlasCount = 5 -- 达到次数则释放图集

GcAssetReleaseCnt = 5
CloneCacheMaxSize = 150
ObjectCacheMaxSize = 30

ModelCacheTime = 300
CachedTime = 30
CostPerFrame = 5

-- 是否缓存Asset模式
CacheAssetModel = false

DynamicLevel = 
{
	TaskNpc = 12,
	Npc = 11,
	Player = 10,
}

Config = {
	--View缓存
	--需在OnShowView的时候重置界面
	--需在OnHideView的时候清掉不需要的东西
	--["CMainMenuView"] = {cache_time = 60},
	["CGmMainView"] = {cache_time = 120},
	--Box缓存
	["CGmMainView.m_CloneTabBtn"] = {lv=1001},
	["CGmMainView.m_CloneBtnInfoListBtn"] = {lv=1000},

	-- Fmt
	["UI/War/FormationAlly.prefab"] = {cache_time = 300, lv=20},
	["UI/War/FormationEnemy.prefab"] = {cache_time = 300, lv=20},

	-- Path
	["UI/Hud/NameHud.prefab"] = {lv=9},
	["UI/Hud/BloodHud.prefab"] = {lv=9},
	["UI/Hud/WarriorOrderHud.prefab"] = {lv=19},

	-- 模型
	["Model/Character/1110/Prefabs/model1110.prefab"] = {lv=9},
	["Model/Character/1120/Prefabs/model1120.prefab"] = {lv=9},
	["Model/Character/1210/Prefabs/model1210.prefab"] = {lv=9},
	["Model/Character/1220/Prefabs/model1220.prefab"] = {lv=9},
	["Model/Character/1310/Prefabs/model1310.prefab"] = {lv=9},
	["Model/Character/1320/Prefabs/model1320.prefab"] = {lv=9},
	["Model/Character/1130/Prefabs/model1130.prefab"] = {lv=9},
	["Model/Character/1170/Prefabs/model1170.prefab"] = {lv=9},
	["Model/Character/1230/Prefabs/model1230.prefab"] = {lv=9},
	["Model/Character/1270/Prefabs/model1270.prefab"] = {lv=9},
	["Model/Character/1330/Prefabs/model1330.prefab"] = {lv=9},
	["Model/Character/1370/Prefabs/model1370.prefab"] = {lv=9},

	-- 武器
	["Model/Weapon/1110_1/Prefabs/weapon1110_1.prefab"] = {lv=9},
	["Model/Weapon/1120_1/Prefabs/weapon1120_1.prefab"] = {lv=9},
	["Model/Weapon/1210_1/Prefabs/weapon1210_1.prefab"] = {lv=9},
	["Model/Weapon/1220_1/Prefabs/weapon1220_1.prefab"] = {lv=9},
	["Model/Weapon/1310_1/Prefabs/weapon1310_1.prefab"] = {lv=9},
	["Model/Weapon/1320_1/Prefabs/weapon1320_1.prefab"] = {lv=9},

	["Model/Weapon/1110_2/Prefabs/weapon1110_2.prefab"] = {lv=9},
	["Model/Weapon/1120_2/Prefabs/weapon1120_2.prefab"] = {lv=9},
	["Model/Weapon/1210_2/Prefabs/weapon1210_2.prefab"] = {lv=9},
	["Model/Weapon/1220_2/Prefabs/weapon1220_2.prefab"] = {lv=9},
	["Model/Weapon/1310_2/Prefabs/weapon1310_2.prefab"] = {lv=9},
	["Model/Weapon/1320_2/Prefabs/weapon1320_2.prefab"] = {lv=9},

	["Model/Weapon/1110_3/Prefabs/weapon1110_3.prefab"] = {lv=9},
	["Model/Weapon/1120_3/Prefabs/weapon1120_3.prefab"] = {lv=9},
	["Model/Weapon/1210_3/Prefabs/weapon1210_3.prefab"] = {lv=9},
	["Model/Weapon/1220_3/Prefabs/weapon1220_3.prefab"] = {lv=9},
	["Model/Weapon/1310_3/Prefabs/weapon1310_3.prefab"] = {lv=9},
	["Model/Weapon/1320_3/Prefabs/weapon1320_3.prefab"] = {lv=9},

	["Model/Weapon/1110_4/Prefabs/weapon1110_4.prefab"] = {lv=9},
	["Model/Weapon/1120_4/Prefabs/weapon1120_4.prefab"] = {lv=9},
	["Model/Weapon/1210_4/Prefabs/weapon1210_4.prefab"] = {lv=9},
	["Model/Weapon/1220_4/Prefabs/weapon1220_4.prefab"] = {lv=9},
	["Model/Weapon/1310_4/Prefabs/weapon1310_4.prefab"] = {lv=9},
	["Model/Weapon/1320_4/Prefabs/weapon1320_4.prefab"] = {lv=9},

	["Model/Weapon/1110_5/Prefabs/weapon1110_5.prefab"] = {lv=9},
	["Model/Weapon/1120_5/Prefabs/weapon1120_5.prefab"] = {lv=9},
	["Model/Weapon/1210_5/Prefabs/weapon1210_5.prefab"] = {lv=9},
	["Model/Weapon/1220_5/Prefabs/weapon1220_5.prefab"] = {lv=9},
	["Model/Weapon/1310_5/Prefabs/weapon1310_5.prefab"] = {lv=9},
	["Model/Weapon/1320_5/Prefabs/weapon1320_5.prefab"] = {lv=9},

	["Model/Weapon/1110_6/Prefabs/weapon1110_6.prefab"] = {lv=9},
	["Model/Weapon/1120_6/Prefabs/weapon1120_6.prefab"] = {lv=9},
	["Model/Weapon/1210_6/Prefabs/weapon1210_6.prefab"] = {lv=9},
	["Model/Weapon/1220_6/Prefabs/weapon1220_6.prefab"] = {lv=9},
	["Model/Weapon/1310_6/Prefabs/weapon1310_6.prefab"] = {lv=9},
	["Model/Weapon/1320_6/Prefabs/weapon1320_6.prefab"] = {lv=9},

	["Model/Weapon/1110_7/Prefabs/weapon1110_7.prefab"] = {lv=9},
	["Model/Weapon/1120_7/Prefabs/weapon1120_7.prefab"] = {lv=9},
	["Model/Weapon/1210_7/Prefabs/weapon1210_7.prefab"] = {lv=9},
	["Model/Weapon/1220_7/Prefabs/weapon1220_7.prefab"] = {lv=9},
	["Model/Weapon/1310_7/Prefabs/weapon1310_7.prefab"] = {lv=9},
	["Model/Weapon/1320_7/Prefabs/weapon1320_7.prefab"] = {lv=9},

	["Model/Weapon/1110_8/Prefabs/weapon1110_8.prefab"] = {lv=9},
	["Model/Weapon/1120_8/Prefabs/weapon1120_8.prefab"] = {lv=9},
	["Model/Weapon/1210_8/Prefabs/weapon1210_8.prefab"] = {lv=9},
	["Model/Weapon/1220_8/Prefabs/weapon1220_8.prefab"] = {lv=9},
	["Model/Weapon/1310_8/Prefabs/weapon1310_8.prefab"] = {lv=9},
	["Model/Weapon/1320_8/Prefabs/weapon1320_8.prefab"] = {lv=9},

	["Model/Weapon/1110_9/Prefabs/weapon1110_9.prefab"] = {lv=9},
	["Model/Weapon/1120_9/Prefabs/weapon1120_9.prefab"] = {lv=9},
	["Model/Weapon/1210_9/Prefabs/weapon1210_9.prefab"] = {lv=9},
	["Model/Weapon/1220_9/Prefabs/weapon1220_9.prefab"] = {lv=9},
	["Model/Weapon/1310_9/Prefabs/weapon1310_9.prefab"] = {lv=9},
	["Model/Weapon/1320_9/Prefabs/weapon1320_9.prefab"] = {lv=9},
}