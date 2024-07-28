using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace JJS
{
    using Utils;


    public class CameraSuspension : MonoBehaviour
    {
        [SerializeField]
        private float lerpFactor = 0.14f;

        [SerializeField]
        private float accFactor = -0.14f;

        [SerializeField]
        private float accOffsetIntensity = 10f;

        [SerializeField]
        private float accOffsetHeightDeCreaseRate = 0.86f;


        private float accOffsetHeight = 0;
        private GameObject PlayerPositionProbe;
        private GameObject CameraTargetPositionProbe;

        private Transform player;

        private readonly Notifier<PlayerMovementState> playerState = new Notifier<PlayerMovementState>();

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

            playerState.OnDataChanged += PlayerState_OnDataChanged;
        }


        private void FixedUpdate()
        {
            accOffsetHeight += (playerPosition.y - PlayerPositionProbe.transform.position.y) * accOffsetIntensity;

            var nextHeight = Mathf.Lerp(CameraTargetPositionProbe.transform.position.y, PlayerPositionProbe.transform.position.y + accOffsetHeight * accFactor, lerpFactor);
            transform.position = playerPosition.MultiplyEachChannel(Mask) + Vector3.up * nextHeight;

            var offset = nextHeight - CameraTargetPositionProbe.transform.position.y;
            accOffsetHeight -= offset;

            accOffsetHeight *= accOffsetHeightDeCreaseRate;

            PlayerPositionProbe.transform.position = playerPosition;
            CameraTargetPositionProbe.transform.position = transform.position;
        }

        private void Update()
        {
            playerState.Value = PlayerCore.Instance?.CurrentPlayerState ?? PlayerMovementState.None;
        }

        private void PlayerState_OnDataChanged(PlayerMovementState state)
        {
            switch (state)
            {
                case PlayerMovementState.Sailboat:
                    lerpFactor = 0.14f;
                    accFactor = -0.14f;
                    break;

                default:
                    lerpFactor = 1f;
                    accFactor = 0f;
                    break;
            }
        }
    }
}