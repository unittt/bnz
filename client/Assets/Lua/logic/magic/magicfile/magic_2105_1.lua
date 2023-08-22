module(...)
--magic editor build
DATA={
	cmds={
		[1]={args={alive_time=0.5,},func_name='Name',start_time=0,},
		[2]={
			args={action_name='magic',bak_action_name='nil',excutor='atkobj',},
			func_name='PlayAction',
			start_time=0.5,
		},
		[3]={
			args={
				alive_time=1.1,
				effect={
					flip=false,
					path='Effect/Magic/skill_eff_1001_hit/Prefabs/skill_eff_1001_hit.prefab',
				},
				effect_cnt='one',
				effect_dir_pos={base_pos='empty',depth=0,relative_angle=0,relative_dis=0,},
				effect_pos={base_pos='atk',depth=0,relative_angle=0,relative_dis=0,},
				excutor='vicobj',
			},
			func_name='StandEffect',
			start_time=1.2,
		},
		[4]={args={},func_name='End',start_time=3,},
	},
	event={endhit=1.7,hit=1.4,hurt=1.5,},
	pre_load_res={},
	run_env='war',
	type=1,
}
