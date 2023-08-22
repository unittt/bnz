using System;
using System.Collections.Generic;
using UnityEngine;

public class UpdateManager
{
    public interface ILateUpdateObj
    {
        void CustomLateUpdate();
        LinkedListNode<ILateUpdateObj> node { get; set; }
    }

    private static readonly LinkedList<ILateUpdateObj> lateUpdateList = new LinkedList<ILateUpdateObj>();
    private static readonly LinkedList<ILateUpdateObj> unUseList = new LinkedList<ILateUpdateObj>();
    private static LinkedListNode<ILateUpdateObj> curLinkedNode = null;

    public static void CallLateUpdate()
    {
        curLinkedNode = lateUpdateList.First;
        while (curLinkedNode != null)
        {
            try
            {
                LinkedListNode<ILateUpdateObj> node = curLinkedNode; 
                curLinkedNode = curLinkedNode.Next;
                node.Value.CustomLateUpdate();
            }
            catch (Exception e)
            {
                GameDebug.LogError(e.ToString());
            }
        }
    }

    public static void Add(ILateUpdateObj nodeValue)
    {
        LinkedListNode<ILateUpdateObj> node = unUseList.Last;
        if (node != null)
        {
            node.Value = nodeValue;
            unUseList.Remove(node);
        }
        else
        {
            node = new LinkedListNode<ILateUpdateObj>(nodeValue);
        }
        lateUpdateList.AddLast(node);
        nodeValue.node = node;
    }

    public static void Remove(ILateUpdateObj nodeValue)
    {
        if (nodeValue.node != null && nodeValue.node.List == lateUpdateList)
        {
            if (curLinkedNode == nodeValue.node)
            {
                curLinkedNode = nodeValue.node.Previous;
            }
            nodeValue.node.List.Remove(nodeValue);
            nodeValue.node.Value = null;
            unUseList.AddLast(nodeValue.node);
            nodeValue.node = null;
        }
    }
     
}
