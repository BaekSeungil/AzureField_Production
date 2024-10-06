using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Noa_Store : MonoBehaviour
{
    [Header("상점 설정")]
    [SerializeField,LabelText("메인메뉴")] private GameObject MainMenu;
    [SerializeField,LabelText("업그레이드메뉴")] private GameObject UpGradeMenu;
    [SerializeField,LabelText("상점 메뉴")] private GameObject StoreMenu;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void OnStoreButton()
    {
        StoreMenu.SetActive(true);
        UpGradeMenu.SetActive(false);
        MainMenu.SetActive(false);
    }

    public void OnUpgradeButton()
    {
        UpGradeMenu.SetActive(true);
        StoreMenu.SetActive(false);
        MainMenu.SetActive(false);

    }
}
