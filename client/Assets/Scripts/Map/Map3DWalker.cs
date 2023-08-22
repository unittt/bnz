using System;
using System.Collections.Generic;
using Pathfinding;
using LuaInterface;
using UnityEngine;


public class Map3DWalker : MonoBehaviour
{
    public Map3DWalker followWalker;
    private Seeker pathSeeker;
    private Path abPath;
    private int pathIndex;
    private bool isPathing;
    private bool isFollowing;
    private float followDis;
    private float followRate = 1.0f;
    private List<Vector3> linePath = new List<Vector3>();
    private List<Renderer> rendererList;
    public int onMapID = 0;

    public Transform moveTransform;
    public Transform rotateTransform;
    public bool moveable = true;
    public float moveSpeed = 3.0f;
    public float rotateSpeed = 10.0f;
    private float moveNextDist = 0.5f;
    private float alpha = 1.0f;

    public float modelAlpha
    {
        get
        {
            return alpha;
        }
        set
        {
            SetTransparent(value);
        }
    }

    private LuaFunction luaEndCallback;
    private LuaFunction luaStartCallback;

    public void Awake()
    {
        pathSeeker = gameObject.GetMissingComponent<Seeker>();
        SimpleSmoothModifier simpleModifier = gameObject.GetMissingComponent<SimpleSmoothModifier>();
        simpleModifier.maxSegmentLength = 0.7f;
        simpleModifier.iterations = 2;
        simpleModifier.smoothType = SimpleSmoothModifier.SmoothType.OffsetSimple;
        SetPathMode(0);
    }

    public void OnDestroy()
    {
        moveTransform = null;
        rotateTransform = null;
        followWalker = null;
        if (isFollowing)
        {
            isFollowing = false;
            StopAllCoroutines();
        }
        if (luaEndCallback != null)
        {
            luaEndCallback.Dispose();
            luaEndCallback = null;
        }
        if (luaStartCallback != null)
        {
            luaStartCallback.Dispose();
            luaStartCallback = null;
        }
    }

    public void OnEnable()
    {
        pathSeeker.pathCallback = OnAstarPathCallback;
    }

    public void OnDisable()
    {
        ClearPath();
        pathSeeker.pathCallback = null;
    }

    public void Update()
    {
        if (!moveable)
        {
            return;
        }

        if (isPathing)
        {
            Vector3 pos = GetNextPos(Time.deltaTime);
            if (pos != Vector3.zero)
            {
                Move(pos);
            }
            else
            {
                isPathing = false;
                if (luaEndCallback != null)
                {
                    luaEndCallback.Call();
                }
                ClearPath();
            }
        }

        CheckTransparent();
    }

    public void SetPathMode(int mode)
    {
        if (mode == 0)
        {
            pathSeeker.traversableTags = 1 << AstarPathManager.LayerGround;
        }
        else if (mode == 1)
        {
            pathSeeker.traversableTags = 1 << AstarPathManager.LayerGround | 1 << AstarPathManager.LayerSky;
        }
    }


    public void SetMapID(int mapid)
    {
        onMapID = mapid;
    }

    private void CheckTransparent()
    {
        if (Map2D.CurrentMap != null && Map2D.CurrentMap.mapId == onMapID)
        {
            if (Map2D.CurrentMap.IsTransparent(moveTransform.position.x, moveTransform.position.y))
            {
                SetTransparent(0.6f);
            }
            else
            {
                SetTransparent(1f);
            }
        }
    }

    private Vector3 GetNextPos(float time)
    {
        List<Vector3> path = GetPath();
        if (path == null || path.Count == 0)
        {
            return Vector3.zero;
        }
        if (pathIndex >= path.Count)
        {
            pathIndex = path.Count - 1;
        }
        if (pathIndex < 0)
        {
            pathIndex = 0;
        }

        float movement = moveSpeed * time;
        if (followWalker != null)
        {
            movement = movement * followRate;
        }

		Vector3 curPos = moveTransform.position;
		Vector3 xzPos = new Vector3(curPos.x, 0, curPos.z);
        Vector3 dir = Vector3.zero;
        Vector3 waypoint = path[pathIndex];
		waypoint.y = 0f;
        if (pathIndex == path.Count - 1)
        {
			dir = waypoint - xzPos;
            float magn = dir.magnitude;
            float newmagn = 0;
            if (magn > 0.01)
            {
                newmagn = Mathf.Min(magn, movement);
                dir *= newmagn / magn;
				var newPos = xzPos + dir;
				dir.y = Map3D.CurrentMap.GetHeight(newPos.x, newPos.z) - curPos.y;
                return dir;
            }
            else
            {
                return Vector3.zero;
            }
        }
        else
        {
            while (pathIndex != path.Count - 1 && (curPos - waypoint).sqrMagnitude < moveNextDist * moveNextDist)
            {
                pathIndex++;
                waypoint = path[pathIndex];
            }
			dir = waypoint - xzPos;
            float magn = dir.magnitude;
            float newmagn = 0;
            if (magn > 0)
            {
                newmagn = Mathf.Min(magn, movement);
                dir *= newmagn / magn;
            }
			var newPos = xzPos + dir;
			dir.y = Map3D.CurrentMap.GetHeight(newPos.x, newPos.z) - curPos.y;
            return dir;
        }
    }

    public void WalkTo(float x, float z, bool useLine)
    {
        ClearPath();
        Vector3 endPos = new Vector3(x, 0, z);
        Vector3 startPos = moveTransform.position;
        if (useLine && GetLinePath(startPos, endPos))
        {
            OnLinePathCallback();
        }
        else
        {
            pathSeeker.StartPath(startPos, endPos);
        }
    }

    public void StopWalk()
    {
        ClearPath();
    }


    public List<Vector3> GetPath()
    {
        if (linePath != null && linePath.Count != 0)
            return linePath;

        if (abPath != null)
            return abPath.vectorPath;

        return null;
    }
    
    private bool GetLinePath(Vector3 startPos, Vector3 endPos)
    {
        linePath.Clear();
        if (Map3D.CurrentMap != null && Map3D.CurrentMap.mapid == onMapID && Map3D.CurrentMap.IsLinePath(startPos, endPos))
        {
            linePath.Add(endPos);
            return true;
        }
        return false;
    }

    private void OnLinePathCallback()
    {
        pathIndex = 0;
        isPathing = true;
        if (luaStartCallback != null)
        {
            luaStartCallback.Call();
        }
    }

    private void OnAstarPathCallback(Path p)
    {
        ABPath path = p as ABPath;
        if (path == null)
        {
            return;
        }
        path.Claim(this);
        if (path.error)
        {
            path.Release(this);
            return;
        }
        abPath = path;
        pathIndex = 0;
        isPathing = true;
        if (luaStartCallback != null)
        {
            luaStartCallback.Call();
        }

        //List<Vector3> lst = GetPath();
        //for (int i = 0; i < lst.Count; i++)
        //{
        //    Debug.Log(i + " " + lst[i]);
        //}
    }

    //private void CancelPath()
    //{
    //    if (pathSeeker != null && !pathSeeker.IsDone())
    //    {
    //        pathSeeker.GetCurrentPath().Error();
    //    }
    //}

    private void ClearPath()
    {
        if (abPath != null)
        {
            abPath.Release(this);
            abPath = null;
        }
        pathIndex = 0;
        isPathing = false;
        linePath.Clear();
    }

    private void Move(Vector3 pos)
    {
        //位置
        moveTransform.Translate(pos, Space.World);

        //方向
        if (pos.sqrMagnitude < 0.00001)
            return;

        Quaternion oldRotation = rotateTransform.localRotation;
        Quaternion newRotation = Quaternion.LookRotation(pos);
        Vector3 angle = Quaternion.Slerp(oldRotation, newRotation, rotateSpeed * Time.deltaTime).eulerAngles;
        rotateTransform.localRotation = Quaternion.Euler(angle);
    }


    public Vector3 GetWayPoint()
    {
        List<Vector3> path = GetPath();
        if (path != null)
        {
            if (pathIndex >= 0 && pathIndex < path.Count)
            {
                return path[pathIndex];
            }
        }
        return Vector3.zero;
    }

    public int GetWayPointIndex()
    {
        return pathIndex;
    }

    public void Follow(Map3DWalker walker, float distance)
    {
        if (followWalker != null)
            ClearPath();

        followWalker = walker;
        followDis = distance;
        if (followWalker == null)
        {
            isFollowing = false;
            StopAllCoroutines();
        }
        else if (!isFollowing)
        {
            isFollowing = true;
            StartCoroutine(UpdateFollowWalker(0.1f));
        }
    }

    private System.Collections.IEnumerator UpdateFollowWalker(float intervalTime)
    {
        while (isFollowing)
        {
            yield return new WaitForSeconds(intervalTime);
            if (followWalker == null)
            {
                continue;
            }
            Vector3 selfPos = moveTransform.position;
            selfPos.z = 0;
            Vector3 targetPos = followWalker.moveTransform.position;
            targetPos.z = 0;
            Vector3 pos = targetPos - followWalker.rotateTransform.forward * followDis;
            pos.z = 0;
            float distance = Vector3.Distance(selfPos, targetPos);
            if (distance <= followDis)
            {
                continue;
            }
            if (Vector3.Distance(selfPos, pos) < 0.1)
            {
                continue;
            }
            followRate = 0.5f + Mathf.Lerp(0f, 0.8f, (distance - followDis) / followDis);
            FollowTo(pos);
        }
    }

    public void FollowTo(Vector3 endPos)
    {
        linePath.Clear();
        linePath.Add(endPos);
        OnLinePathCallback();
    }

    public void SetWalkEndCallback(LuaFunction callback)
    {
        if (this.luaEndCallback != null)
        {
            this.luaEndCallback.Dispose();
            this.luaEndCallback = null;
        }
        this.luaEndCallback = callback;
    }

    public void SetWalkStartCallback(LuaFunction callback)
    {
        if (this.luaStartCallback != null)
        {
            this.luaStartCallback.Dispose();
            this.luaStartCallback = null;
        }
        this.luaStartCallback = callback;
    }

    private static int _ColorAlpha;

    private static int ColorAlpha
    {
        get
        {
            if (_ColorAlpha == 0)
            {
                _ColorAlpha = Shader.PropertyToID("_ColorAlpha");
            }
            return _ColorAlpha;
        }
    }

    public void SetTransparent(float alpha)
    {
        if (gameObject == null)
            return;

        if (this.alpha == alpha)
            return;

        this.alpha = alpha;
        if (rendererList == null)
        {
            var renderers = gameObject.GetComponentsInChildren<Renderer>(true);
            rendererList = new List<Renderer>(renderers.Length);
            for (int i = 0; i < renderers.Length; i++)
            {
                var r = renderers[i];
                if (r.sharedMaterial == null) continue;
                if (r is SkinnedMeshRenderer || r is MeshRenderer)
                {
                    rendererList.Add(r);
                }
            }
        }

        for (int i = 0; i < rendererList.Count; i++)
        {
            var r = rendererList[i];
            if (r != null)
            {
                r.material.SetColor(ColorAlpha, new Color(1f, 1f, 1f, alpha));
            }
        }
    }

    public void SetTraversableTags(int tags)
    {
        if (pathSeeker != null)
        {
            pathSeeker.traversableTags = tags;
        }
    }

}
