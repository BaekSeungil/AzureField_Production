using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MiniMapCamera : MonoBehaviour
{
    [SerializeField] private Vector2 offset;
    [SerializeField] private float cameraHeight;
    [SerializeField] private float cameraDepth;

    Camera minimapView;

    private void Awake()
    {
        minimapView = GetComponent<Camera>();
    }

    private void OnEnable()
    {
        minimapView.farClipPlane = cameraDepth;
    }

    private void Update()
    {
        if(PlayerCore.IsInstanceValid)
        {
            PlayerCore player = PlayerCore.Instance;
            transform.position = new Vector3(player.transform.position.x + offset.x, cameraHeight, player.transform.position.z + offset.y);
        }
            
    }


}
