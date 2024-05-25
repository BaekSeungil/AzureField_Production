using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TempLoadingStarter : MonoBehaviour
{
    private void Start()
    {
        AlphaSceneloader.Instance.LoadNewScene(1);
    }
}
