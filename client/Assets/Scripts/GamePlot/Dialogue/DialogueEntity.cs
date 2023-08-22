using UnityEngine;
using System.Collections.Generic;
#if UNITY_EDITOR
#endif

namespace GamePlot
{
	public class DialogueEntity:PlotEntity
	{
		// public int modelId;
		// public string content;
		public List<DialogueMsgAction> msgActionList = new List<DialogueMsgAction>();

#if UNITY_EDITOR
		public override string GetOptionName(){
			return "场景对话";
		}

		protected override void DrawProperty(){
			base.DrawProperty();
			if (GUILayout.Button("添加对话信息", GUILayout.Width(100f), GUILayout.Height(40f)))
            {
                var action = new DialogueMsgAction();
                allActionList.Add(action);
            }
		}

		public override void RebuildActionList()
        {
            this.msgActionList.Clear();

            for (int i = 0, imax = this.allActionList.Count; i < imax; ++i)
            {
                PlotAction action = this.allActionList[i];
                if (action is DialogueMsgAction)
                    this.msgActionList.Add(action as DialogueMsgAction);
            }
        }
#endif
	}
}