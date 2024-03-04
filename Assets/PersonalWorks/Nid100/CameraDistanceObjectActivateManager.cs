using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
///  카메라와 오브젝트의 거리에 따라서 오브젝트를 활성화/비활성화하는 스크립트입니다.
/// </summary>
public class CameraDistanceObjectActivateManager : MonoBehaviour
{

    #region Properties
    [SerializeField] private float cameraObjectActivateDistance = 1000.0f;            //오브젝트가 활성화/비활성화 되는 거리



    #endregion

    public GameObject mCamera;                                                         //카메라 오브젝트
    public GameObject[] enemyObject;                                                  //거리에 따라서 활성화/비활성화될 오브젝트
    private float Dist;


    private void Awake()
    {


    }

    private void Update()
    {
        ObjectActive();
        ObjectDisabled();
    }


    /// <summary>
    /// 카메라와 오브젝트의 거리를 게산하는 함수
    /// <summary>
    public float DistanceComparison(int num) 
    {
        Dist = Vector3.Distance(mCamera.transform.position, enemyObject[num].transform.position);
        //Debug.Log("Dist : " + Dist);
        return Dist;
        
    }

    /// <summary>
    /// 카메라와 오브젝트의 거리에 따른 오브젝트 비활성화
    /// <summary>
    public void ObjectDisabled()
    {
        for (int i = 0; i < enemyObject.Length; i++)
        {
            if (DistanceComparison(i) > cameraObjectActivateDistance)
            {
                enemyObject[i].SetActive(false);
            }
        }
    }

    /// <summary>
    /// 카메라와 오브젝트의 거리에 따른 오브젝트 활성화
    /// <summary>
    public void ObjectActive() 
    {
        for (int i = 0; i < enemyObject.Length; i++)
        {
            if (DistanceComparison(i) < cameraObjectActivateDistance)
            {
                enemyObject[i].SetActive(true);
            }
        }
    }

}
