using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestAdditemZone : MonoBehaviour
{

    [SerializeField,LabelText("보상아이템")] ItemData Item;
    [SerializeField,LabelText("보상지급 수량")] int ItemCount;
    
    PlayerInventoryContainer InventoryContainer;
    // Start is called before the first frame update
    void Start()
    {
        InventoryContainer = FindObjectOfType<PlayerInventoryContainer>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    private void OnTriggerEnter(Collider other) 
    {
        if(other.gameObject.layer == 6)
        {
            InventoryContainer.AddItem(Item, ItemCount);
        }
    }
}
