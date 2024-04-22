using Mono.Cecil.Cil;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
public class MiniMapSetting : MonoBehaviour
{
    public Transform targetFollow;
    public bool rotateWidthTheTarget = true;
    [SerializeField] public GameObject minimap;

    private bool SetMinimap = false;
    private void Update() 
    {
        if(Keyboard.current[Key.M].wasPressedThisFrame)
        {
            if(SetMinimap)
            {
                Outmap();
            }
            else
            {
                Setmap();
            }
        }
    }


    public void Setmap()
    {
        minimap.SetActive(true);
        SetMinimap = true;
    }

    public void Outmap()
    {
        minimap.SetActive(false);
        SetMinimap = false;
    }
}
