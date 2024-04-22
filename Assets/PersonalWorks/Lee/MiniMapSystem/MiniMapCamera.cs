using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MiniMapCamera : MonoBehaviour
{
   [SerializeField] private MiniMapSetting setting;
   [SerializeField] private float camerHeghit;

   private void Awake() 
   {
        setting = GetComponentInParent<MiniMapSetting>();
        camerHeghit = transform.position.y;
   }

   void Update()
   {
        Vector3 targetPos = setting.targetFollow.transform.position;

        transform.position = new Vector3(targetPos.x,
        targetPos.y + camerHeghit, targetPos.z);

        if(setting.rotateWidthTheTarget)
        {
            Quaternion targetRotation = setting.targetFollow.transform.rotation;

            transform.rotation = Quaternion.Euler(90, targetRotation.eulerAngles.y, 0);
        }
   }
}
