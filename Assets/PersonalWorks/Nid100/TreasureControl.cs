using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TreasureControl : StaticSerializedMonoBehaviour<TreasureControl>
{
    //두 배열의 크기는 항상 같아야합니다.
    //
    [SerializeField] private GameObject[] Treasure;
    [SerializeField] private bool[] Treasurebools;


    protected override void Awake()
    {
        //보물획득정보를 입력받고, 획득여부에 따라서 보물을 활성 및 비활성 여부를 결정합니다.
        for (int i = 0; i < Treasurebools.Length; i++)
        {
            if (Treasurebools[i] == false)
            {
                Treasure[i].SetActive(false);
            }
        }

    }
}
