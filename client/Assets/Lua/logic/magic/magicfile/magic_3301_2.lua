module(...)
--magic editor build
DATA={
	cmds={
		[1]={args={action_name='run',excutor='atkobj',},func_name='PlayAction',start_time=0,},
		[2]={
			args={
				begin_type='current',
				calc_face=true,
				ease_type='Linear',
				end_relative={base_pos='vic',depth=0,relative_angle=0,relative_dis=1.2,},
				end_type='end_relative',
				excutor='atkobj',
				move_time=0.85,
				move_type='line',
			},
			func_name='Move',
			start_time=0,
		},
		[3]={
			args={
				alive_time=0.84,
				effect={
					flip=false,
					path='Effect/Magic/magic_eff_3301/Prefabs/magic_eff_3301_att.prefab',
				},
				effect_dir_pos={base_pos='atk',depth=0,relative_angle=0,relative_dis=1,},
				effect_pos={base_pos='atk',depth=0,relative_angle=0,relative_dis=0,},
				excutor='vicobj',
			},
			func_name='StandEffect',
			start_time=0.85,
		},
		[4]={
			args={action_name='attack1',excutor='atkobj',},
			func_name='PlayAction',
			start_time=0.85,
		},
		[5]={
			args={
				alive_time=0.5,
				effect={
					flip=false,
					path='Effect/Magic/magic_eff_3301/Prefabs/magic_eff_3301_hit.prefab',
				},
				effect_dir_pos={base_pos='vic',depth=0.6,relative_angle=0,relative_dis=1,},
				effect_pos={base_pos='vic',depth=0.6,relative_angle=0,relative_dis=0,},
				excutor='vicobj',
			},
			func_name='StandEffect',
			start_time=1,
		},
		[6]={args={face_atk=true,hurt_delta=0,},func_name='VicHitInfo',start_time=1.03,},
		[7]={args={},func_name='FirstHit',start_time=1.03,},
		[8]={
			args={
				alive_time=0.5,
				effect={
					flip=false,
					path='Effect/Magic/magic_eff_3301/Prefabs/magic_eff_3301_hit.prefab',
				},
				effect_dir_pos={base_pos='vic',depth=0.6,relative_angle=0,relative_dis=1,},
				effect_pos={base_pos='vic',depth=0.6,relative_angle=0,relative_dis=0,},
				excutor='vicobj',
			},
			func_name='StandEffect',
			start_time=1.4,
		},
		[9]={args={face_atk=true,hurt_delta=0,},func_name='VicHitInfo',start_time=1.42,},
		[10]={args={},func_name='LastHit',start_time=1.42,},
		[11]={args={},func_name='End',start_time=1.88,},
	},
	first_hit_time=1.03,
	group_cmds={},
	last_hit_time=1.42,
	pre_load_res={},
	run_env='war',
	type=1,
}