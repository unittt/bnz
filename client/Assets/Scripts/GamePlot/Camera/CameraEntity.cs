using UnityEngine;
using System.Collections.Generic;

#if UNITY_EDITOR

#endif

namespace GamePlot
{
    //剧情镜头实体
    public class CameraEntity : PlotEntity
    {
        public Vector3 originPos;
        //public Vector3 originRotation;
        //public List<CameraPathAction> camPathActionList = new List<CameraPathAction>();
        public List<CameraShakeAction> shakeActionList = new List<CameraShakeAction>();
        public List<PlotTransformAction> tweenActionList = new List<PlotTransformAction>();
        public List<CameraSizeAction> sizeActionList = new List<CameraSizeAction>();

#if UNITY_EDITOR
        protected override void DrawProperty()
        {
            base.DrawProperty();

            this.originPos = PlotEntity.Vector3Field("起始位置：", this.originPos, 0);
            //this.originRotation = PlotEntity.Vector3Field("起始朝向：",this.originRotation,1);

            //if (GUILayout.Button("添加路径动画指令", GUILayout.Width(100f), GUILayout.Height(40f)))
            //{
            //    var action = new CameraPathAction();
            //    allActionList.Add(action);
            //}

            if (GUILayout.Button("添加震屏指令", GUILayout.Width(100f), GUILayout.Height(40f)))
            {
                var action = new CameraShakeAction();
                allActionList.Add(action);
            }

            if (GUILayout.Button("添加(平移●旋转●缩放)指令", GUILayout.Width(100f), GUILayout.Height(40f)))
            {
                var action = new PlotTransformAction();
                allActionList.Add(action);
            }
            if (GUILayout.Button("大小(2D相机)", GUILayout.Width(100f), GUILayout.Height(40f)))
            {
                var action = new CameraSizeAction();
                allActionList.Add(action);
            }
        }

        public override string GetOptionName()
        {
            return "Camera";
        }

        public override void RebuildActionList()
        {
            //this.camPathActionList.Clear();
            this.shakeActionList.Clear();
            this.tweenActionList.Clear();
            this.sizeActionList.Clear();

            for (int i = 0, imax = this.allActionList.Count; i < imax; ++i)
            {
                PlotAction action = this.allActionList[i];
                //if (action is CameraPathAction)
                //    this.camPathActionList.Add(action as CameraPathAction);
                if (action is CameraShakeAction)
                    this.shakeActionList.Add(action as CameraShakeAction);
                else if (action is PlotTransformAction)
                    this.tweenActionList.Add(action as PlotTransformAction);
                else if (action is CameraSizeAction)
                    this.sizeActionList.Add(action as CameraSizeAction);
            }
        }
#endif
    }
}
