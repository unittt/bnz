module(...)
--magic editor build
DATA={
	cmds={
		[1]={
			args={alive_time=5.2,color={a=0,b=255,g=255,r=255,},excutor='enemy_nv',fade_time=1,},
			func_name='ActorColor',
			start_time=0,
		},
		[2]={
			args={alive_time=5.2,color={a=0,b=255,g=255,r=255,},excutor='ally_na',fade_time=1,},
			func_name='ActorColor',
			start_time=0,
		},
		[3]={args={time=5.2,},func_name='HideUI',start_time=0,},
		[4]={args={player_swipe=false,},func_name='CameraLock',start_time=0,},
		[5]={
			args={condition_name='ally',false_group='e',group_type='condition',true_group='a',},
			func_name='GroupCmd',
			start_time=0,
		},
		[6]={
			args={
				camera_pos={base_pos='atk',depth=1,relative_angle=0,relative_dis=4,},
				excutor='atkobj',
				move_time=1,
				move_type='cam',
			},
			func_name='CameraTarget',
			start_time=0.1,
		},
		[7]={
			args={
				excutor='camobj',
				face_to='fixed_pos',
				pos={base_pos='atk',depth=0.5,relative_angle=0,relative_dis=0,},
				time=1,
			},
			func_name='FaceTo',
			start_time=0.1,
		},
		[8]={
			args={
				alive_time=1.95,
				effect={
					flip=false,
					path='Effect/Magic/magic_eff_3305/Prefabs/magic_eff_3305_att.prefab',
				},
				effect_dir_pos={base_pos='vic',depth=0,relative_angle=0,relative_dis=1,},
				effect_pos={base_pos='atk',depth=0,relative_angle=0,relative_dis=0,},
				excutor='vicobj',
			},
			func_name='StandEffect',
			start_time=0.75,
		},
		[9]={
			args={action_name='attack5',action_time=2,excutor='atkobj',},
			func_name='PlayAction',
			start_time=0.75,
		},
		[10]={
			args={color={a=255,b=0,g=0,r=0,},fade_time=2.55,},
			func_name='CameraColor',
			start_time=0.75,
		},
		[11]={
			args={excutor='camobj',face_to='lerp_pos',h_dis=0,time=0.5,v_dis=55,},
			func_name='FaceTo',
			start_time=1.8,
		},
		[12]={
			args={end_val=65,fade_time=0.5,start_val=26,},
			func_name='CameraFieldOfView',
			start_time=1.9,
		},
		[13]={
			args={end_val=26,fade_time=0.3,start_val=55,},
			func_name='CameraFieldOfView',
			start_time=2.42,
		},
		[14]={
			args={alive_time=2.55,color={a=0,b=255,g=255,r=255,},excutor='allys',fade_time=0.05,},
			func_name='ActorColor',
			start_time=2.65,
		},
		[15]={
			args={
				alive_time=1.01,
				bind_type='empty',
				effect={
					flip=false,
					path='Effect/Magic/magic_eff_3305/Prefabs/magic_eff_3305_fly.prefab',
				},
				excutor='camobj',
				height=0,
			},
			func_name='BodyEffect',
			start_time=2.69,
		},
		[16]={
			args={dir='local_forward',excutor='camobj',move_time=0,speed=55,},
			func_name='MoveDir',
			start_time=2.7,
		},
		[17]={
			args={end_val=7,fade_time=0.98,start_val=26,},
			func_name='CameraFieldOfView',
			start_time=2.71,
		},
		[18]={
			args={
				alive_time=1.55,
				effect={
					flip=false,
					path='Effect/Magic/magic_eff_3305/Prefabs/magic_eff_3305_hit.prefab',
				},
				effect_dir_pos={base_pos='vic',depth=0,relative_angle=0,relative_dis=1,},
				effect_pos={base_pos='vic_team_center',depth=0,relative_angle=0,relative_dis=0,},
				excutor='vicobj',
			},
			func_name='StandEffect',
			start_time=3.65,
		},
		[19]={
			args={alive_time=1.52,color={a=255,b=0,g=0,r=0,},excutor='vicobjs',fade_time=0.01,},
			func_name='ActorColor',
			start_time=3.68,
		},
		[20]={
			args={end_val=26,fade_time=0.02,start_val=15,},
			func_name='CameraFieldOfView',
			start_time=3.72,
		},
		[21]={
			args={color={a=255,b=0,g=0,r=255,},fade_time=0.05,restore_time=0.83,},
			func_name='CameraColor',
			start_time=3.75,
		},
		[22]={
			args={action_name='hitFloat',action_time=0.2,excutor='vicobjs',},
			func_name='PlayAction',
			start_time=4,
		},
		[23]={
			args={action_name='hitFloat',action_time=0.2,excutor='vicobjs',},
			func_name='PlayAction',
			start_time=4.2,
		},
		[24]={
			args={action_name='hitFloat',action_time=0.2,excutor='vicobjs',},
			func_name='PlayAction',
			start_time=4.4,
		},
		[25]={
			args={action_name='idleWar',excutor='vicobjs',},
			func_name='PlayAction',
			start_time=4.58,
		},
		[26]={
			args={color={a=255,b=255,g=255,r=255,},fade_time=0.05,restore_time=0.6,},
			func_name='CameraColor',
			start_time=4.6,
		},
		[27]={args={face_atk=true,hurt_delta=0,},func_name='VicHitInfo',start_time=4.6,},
		[28]={
			args={action_name='idleWar',excutor='vicobj',},
			func_name='PlayAction',
			start_time=5.2,
		},
		[29]={args={player_swipe=true,},func_name='CameraLock',start_time=5.2,},
		[30]={args={},func_name='End',start_time=6,},
	},
	group_cmds={
		a={
			[1]={
				args={
					begin_prepare='3305_01',
					begin_type='begin_prepare',
					calc_face=true,
					ease_type='Linear',
					end_type='empty',
					excutor='camobj',
					move_time=0,
					move_type='line',
				},
				func_name='Move',
				start_time=2.69,
			},
			[2]={
				args={
					begin_prepare='3305_02',
					begin_type='begin_prepare',
					calc_face=true,
					ease_type='Linear',
					end_type='empty',
					excutor='camobj',
					move_time=0,
					move_type='line',
				},
				func_name='Move',
				start_time=3.75,
			},
		},
		e={
			[1]={
				args={
					begin_prepare='3305_01_2',
					begin_type='begin_prepare',
					calc_face=true,
					ease_type='Linear',
					end_type='empty',
					excutor='camobj',
					move_time=0,
					move_type='line',
				},
				func_name='Move',
				start_time=2.69,
			},
			[2]={
				args={
					begin_prepare='3305_02_2',
					begin_type='begin_prepare',
					calc_face=true,
					ease_type='Linear',
					end_type='empty',
					excutor='camobj',
					move_time=0,
					move_type='line',
				},
				func_name='Move',
				start_time=3.75,
			},
		},
	},
	pre_load_res={},
	run_env='war',
	type=1,
}
