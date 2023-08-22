using UnityEngine;
using System.Collections;
using Pathfinding;

public class GridMapBuildChecker : MonoBehaviour
{
    public Collider2D[] _gridMapBuild = new Collider2D[1];
    private Vector3 _lastPos;
    private Transform _mTrans;
    private Seeker _seeker;
    // Use this for initialization
    void Start()
    {
        _mTrans = this.transform;
        _seeker = this.GetComponent<Seeker>();
        if (_seeker != null)
            _seeker.traversableTags = -3;
    }

    void OnGUI()
    {
        if (_seeker != null)
        {
            bool flyable = _seeker.traversableTags == -1;
            if (GUILayout.Button(flyable ? "行走" : "飞行", GUILayout.Height(20f)))
            {
                _seeker.traversableTags = flyable ? -3 : -1;
            }
        }
    }

    void Update()
    {
        if (_lastPos != _mTrans.position)
        {
            _lastPos = _mTrans.position;
            OnPosChange();
        }
    }

    public void OnPosChange()
    {
        var lastBuild = _gridMapBuild[0];
        int LayerId_GridMapBuild = LayerMask.NameToLayer("GridMapBuild");

        var ret = Physics2D.OverlapPointNonAlloc(_mTrans.position, _gridMapBuild, 1 << LayerId_GridMapBuild);
        if (ret > 0)
        {
            if (lastBuild != _gridMapBuild[0])
            {
                var sprite = _gridMapBuild[0].GetComponent<SpriteRenderer>();
                sprite.color = new Color(1f, 1f, 1f, 0.5f);
            }
        }
        else
        {
            //清空建筑遮罩碰撞体
            _gridMapBuild[0] = null;
            if (lastBuild != null)
            {
                var sprite = lastBuild.GetComponent<SpriteRenderer>();
                sprite.color = Color.white;
            }
        }
    }

    //void OnDrawGizmosSelected()
    //{
    //    NNConstraint nnCon = NNConstraint.Default;
    //    nnCon.tags = 1;
    //    var info = AstarPath.active.GetNearest(_lastPos, nnCon);
    //    info.UpdateInfo();
    //    Gizmos.DrawSphere(info.clampedPosition, 0.1f);
    //}
}
