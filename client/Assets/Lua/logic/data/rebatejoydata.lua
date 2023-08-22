module(...)
--auto generate data
CONFIG={
	reward_new={
		group_key=[[reward_new]],
		mode_id=1001,
		open_time=3,
		reward_mail=2073,
		rplgoldcoin_mail=2072,
		shop_id=202,
	},
	reward_old={
		group_key=[[reward_old]],
		mode_id=1002,
		open_time=3,
		reward_mail=2073,
		rplgoldcoin_mail=2072,
		shop_id=201,
	},
}

REWARDNEW={
	[1]={expense=2000,id=1,multiple=1.5,reward_id=1001,},
	[2]={expense=5000,id=2,multiple=1.8,reward_id=1002,},
}

REWARDOLD={
	[1]={expense=2000,id=1,multiple=1.5,reward_id=2001,},
	[2]={expense=5000,id=2,multiple=1.8,reward_id=2002,},
}

TEXT={}
