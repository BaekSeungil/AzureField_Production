using JJS.Utils;
using UnityEngine;


public class CameraSuspension : MonoBehaviour
{
    [SerializeField]
    private float lerpFactor = 0.14f;

    [SerializeField]
    private float accFactor = 0.014f;


    private float accOffsetHeight = 0;
    private GameObject PlayerPositionProbe;
    private GameObject CameraTargetPositionProbe;

    private Transform player;

    private Vector3 playerPosition { get => player.position + Offset; }
    private Vector3 Mask = Vector3.right + Vector3.forward;
    private Vector3 Offset = Vector3.zero;

    private void Awake()
    {
        player = transform.parent;
        Offset = transform.localPosition;

        PlayerPositionProbe = new GameObject(nameof(PlayerPositionProbe));
        PlayerPositionProbe.transform.position = playerPosition;

        CameraTargetPositionProbe = new GameObject(nameof(CameraTargetPositionProbe));
        CameraTargetPositionProbe.transform.position = transform.position;
    }


    private void FixedUpdate()
    {
        accOffsetHeight += playerPosition.y - PlayerPositionProbe.transform.position.y;

        var nextHeight = Mathf.Lerp(CameraTargetPositionProbe.transform.position.y, PlayerPositionProbe.transform.position.y + accOffsetHeight * accFactor, lerpFactor);
        transform.position = playerPosition.MultiplyEachChannel(Mask) + Vector3.up * nextHeight;

        var offset = nextHeight - CameraTargetPositionProbe.transform.position.y;
        accOffsetHeight -= offset;

        PlayerPositionProbe.transform.position = playerPosition;
        CameraTargetPositionProbe.transform.position = transform.position;
    }
}
