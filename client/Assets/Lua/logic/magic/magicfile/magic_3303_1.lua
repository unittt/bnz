module(...)
--magic editor build
DATA={
	cmds={
		[1]={
			args={action_name='attack3',excutor='atkobj',},
			func_name='PlayAction',
			start_time=0,
		},
		[2]={
			args={
				alive_time=1,
				effect={
					flip=false,
					path='Effect/Magic/magic_eff_3303/Prefabs/magic_eff_3303_att.prefab',
				},
				effect_dir_pos={base_pos='vic',depth=0,relative_angle=0,relative_dis=0,},
				effect_pos={base_pos='atk',depth=0,relative_angle=0,relative_dis=0,},
				excutor='vicobj',
			},
			func_name='StandEffect',
			start_time=0,
		},
		[3]={
			args={
				alive_time=0.6,
				begin_pos={base_pos='atk',depth=0.6,relative_angle=0,relative_dis=0,},
				ease_type='Linear',
				effect={
					flip=false,
					path='Effect/Magic/magic_eff_3303/Prefabs/magic_eff_3303_fly.prefab',
				},
				end_pos={base_pos='vic',depth=0.6,relative_angle=0,relative_dis=0,},
				excutor='vicobj',
				move_time=0.6,
			},
			func_name='ShootEffect',
			start_time=0.55,
		},
		[4]={args={},func_name='FirstHit',start_time=0.95,},
		[5]={args={face_atk=true,hurt_delta=0,},func_name='VicHitInfo',start_time=1.05,},
		[6]={
			args={
				alive_time=0.5,
				effect={
					flip=false,
					path='Effect/Magic/magic_eff_3303/Prefabs/magic_eff_3303_hit.prefab',
				},
				effect_dir_pos={base_pos='atkobj',depth=0,relative_angle=0,relative_dis=0,},
				effect_pos={base_pos='vic',depth=0.5,relative_angle=0,relative_dis=0,},
				excutor='vicobj',
			},
			func_name='StandEffect',
			start_time=1.05,
		},
		[7]={args={},func_name='LastHit',start_time=1.1,},
		[8]={args={},func_name='End',start_time=1.2,},
	},
	first_hit_time=0.95,
	group_cmds={},
	last_hit_time=1.1,
	pre_load_res={},
	run_env='war',
	type=1,
}