using System;
using System.Collections.Generic;
using UnityEngine;

public class Hud : MonoBehaviour
{
    public Transform target;
    public Camera gameCamera;
    public Camera uiCamera;
    public bool isAutoUpdate;
    private Transform cacheTrans;

    private static List<Hud> hudList = new List<Hud>();

    public static void CallUpdateAll()
    {
        for (int i = 0; i < hudList.Count; i++)
        {
            hudList[i].CheckShow();
        }
    }

    public void Awake()
    {
        isAutoUpdate = true;
    }

    public void Start()
    {
        cacheTrans = gameObject.transform;
        hudList.Add(this);
        CheckShow();
    }

    public void OnDestroy()
    {
        if (hudList.Contains(this))
        {
            hudList.Remove(this);
        }
        target = null;
        gameCamera = null;
        uiCamera = null;
        cacheTrans = null;
    }

    public void CheckShow()
    {
        if (isAutoUpdate == false || gameObject == null || target == null || gameCamera == null || uiCamera == null)
        {
            return;
        }

        Vector3 pos = gameCamera.WorldToViewportPoint(target.position);
        pos.x = pos.x * gameCamera.rect.size.x + gameCamera.rect.position.x;
        pos.y = pos.y * gameCamera.rect.size.y + gameCamera.rect.position.y;
		bool isVisible = pos.x >= 0f && pos.x <= 1f && pos.y >= 0f && pos.y <= 1f && pos.z >= 0 && gameCamera.enabled && ((gameCamera.cullingMask & (1 << target.gameObject.layer)) != 0);
        if (isVisible)
        {
            gameObject.SetActive(true);
            cacheTrans.position = uiCamera.ViewportToWorldPoint(pos);
            cacheTrans.localPosition = new Vector3(cacheTrans.localPosition.x, cacheTrans.localPosition.y, 0f);
        }
        else
        {
            gameObject.SetActive(false);
        }
    }

}
