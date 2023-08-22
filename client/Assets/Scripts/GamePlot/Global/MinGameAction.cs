using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace GamePlot
{
	public class MinGameAction:PlotAction
	{
		public bool pause = true;
		public int gameId;
		public string gameReward;
#if UNITY_EDITOR
		public override string GetOptionName(){
			return "小游戏";
		}

		protected override void DrawProperty(){
			base.DrawProperty();
			this.pause = EditorGUILayout.Toggle("是否暂停剧情：",this.pause,GUILayout.Width(100f));
			EditorGUI.BeginDisabledGroup(!this.pause);
			this.gameId = EditorGUILayout.IntField("QTE_ID：",this.gameId);
			this.gameReward = EditorGUILayout.TextField("QTE选项ID：",this.gameReward);
		}
#endif
	}
}
