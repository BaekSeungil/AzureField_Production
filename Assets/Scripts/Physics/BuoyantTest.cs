using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BuoyantTest : MonoBehaviour
{
    private void Update() {
        Debug.DrawLine(transform.position,new Vector3(transform.position.x,GlobalOceanManager.Instance.GetWaveHeight(transform.position),transform.position.z),Color.magenta);
    }
}
