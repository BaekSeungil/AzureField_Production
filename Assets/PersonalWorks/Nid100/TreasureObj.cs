using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TreasureObj : MonoBehaviour
{
    [SerializeField] private string _ID;
    public string ID { get { return _ID; } }
    [SerializeField, LabelText("유물 데이터")] private ItemData carrotItem;
}
