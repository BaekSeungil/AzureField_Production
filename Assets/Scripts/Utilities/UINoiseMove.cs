using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UINoiseMove : MonoBehaviour
{
    [SerializeField] private float scale = 10f;
    [SerializeField] private float speed = 1f;
    [SerializeField] private Vector2 noiseOffset;

    private void FixedUpdate()
    {
        transform.localPosition = new Vector3((Mathf.PerlinNoise(Time.time * speed + noiseOffset.x, 0f)-0.5f)*2f * scale, (Mathf.PerlinNoise(0f, Time.time * speed + noiseOffset.y)- 0.5f)*2f * scale, 0f);
    }

}
