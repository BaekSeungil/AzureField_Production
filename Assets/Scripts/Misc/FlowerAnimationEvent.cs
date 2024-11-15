using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlowerAnimationEvent : MonoBehaviour
{
    public Interactable_GoldenCarrot carrot;

    public void OnFlowerPicked()
    {
        carrot.OnFlowerPicked();
    }

}
