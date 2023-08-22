using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace GamePlot
{
    public class PlotTransformAction : PlotAction
    {
        public enum TweenType
        {
            NavMove,
            PosMove,
            Rotate3D,
            Rotate2D,
            Scale,
            Mount,
        }
        public TweenType tweenType;
        public Vector3 endValue;
        public PlotEntity.Orientation orient;
        public float speed;
        public int mountId;
        public bool mountState;
        public bool isWalk;
        public PlotTransformAction()
        {

        }

#if UNITY_EDITOR

        public PlotTransformAction(TweenType tweenType)
        {
            this.tweenType = tweenType;
        }

        public override string GetOptionName()
        {
            if (tweenType == TweenType.NavMove)
                return "寻路移动";
            if (tweenType == TweenType.Rotate3D)
                return "旋转3D";
            if (tweenType == TweenType.Rotate2D)
                return "旋转2D";
            if (tweenType == TweenType.Scale)
                return "缩放";
            if (tweenType == TweenType.PosMove)
                return "平移";
            if (tweenType == TweenType.Mount)
                return "坐骑";
            return "PlotTransformAction";
        }

        public override bool IsPoint()
        {
            if (tweenType == TweenType.NavMove || tweenType == TweenType.Mount)
                return true;

            return false;
        }

        protected override void DrawProperty()
        {
            base.DrawProperty();
            this.tweenType = (TweenType)EditorGUILayout.EnumPopup("类型：", this.tweenType, GUILayout.MaxWidth(250f));

            if (this.tweenType == TweenType.Mount)
            {
                EditorGUILayout.LabelField("注意:坐骑ID为0或者坐骑表没有这个坐骑数据,就会下坐骑.");
                this.mountId = EditorGUILayout.IntField("坐骑ID：", this.mountId);
                this.mountState = EditorGUILayout.Toggle("是否骑乘：", this.mountState, GUILayout.Width(100f));
            }
            else
            {
                if (tweenType == TweenType.Rotate2D)
                {
                    this.orient = PlotEntity.OrientationField("朝向：", this.orient);
                }
                else
                {
                    this.endValue = PlotEntity.Vector3Field("目标值：", this.endValue, (int)tweenType);
                }

                this.speed = Mathf.Max(EditorGUILayout.FloatField("移动速度：", this.speed), 0f);
                this.isWalk = EditorGUILayout.Toggle("是否步行：", this.isWalk, GUILayout.Width(100f));
            }

        }
#endif
    }
}