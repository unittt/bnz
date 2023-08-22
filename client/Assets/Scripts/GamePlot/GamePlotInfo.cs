﻿using System.Collections.Generic;

namespace GamePlot
{
	public class GamePlotInfo
	{
		public int plotId;				//剧情ID
		public int sceneId;				//发生剧情的场景Id
		public float plotTime = 10f;	//剧情总时长
		public int nextPlot;			//衔接剧情

		public List<CharacterEntity> characterList = new List<CharacterEntity>();
		public List<SceneEffectEntity> sceneEffectList = new List<SceneEffectEntity>();
		public List<CameraEntity> cameraList = new List<CameraEntity>();
		public List<DialogueEntity> dialogueList = new List<DialogueEntity>();

		//全局类动作
		public List<PlayAudioAction> audioActionList = new List<PlayAudioAction>();
		public List<ScreenMaskAction> screenMaskActionList = new List<ScreenMaskAction>();
		public List<ScreenPresureAction> screenPresureActionList = new List<ScreenPresureAction>();
		public List<MinGameAction> minGameActionList = new List<MinGameAction>();
		public List<PlotUIEffectEntity> uiEffectList = new List<PlotUIEffectEntity>();
	}
}
