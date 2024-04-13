using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MiniMap_Object : MonoBehaviour
{
    [SerializeField]
    private bool follwObject = false;
    [SerializeField]
    private Sprite minimapIcon;
    
    public Sprite MiniMapIcon => minimapIcon;

    private void Start() 
    {
        MiniMap_Base.Instance.RegisterMinimapWorldObject(this, follwObject);
    }
    
    private void OnDestroy()
    {
        MiniMap_Base.Instance.RemoveMiniMapWolrdObject(this);
    }
}
