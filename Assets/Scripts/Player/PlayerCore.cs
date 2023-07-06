using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using Sirenix.OdinInspector;
using UnityEngine.Animations.Rigging;
using UnityEditor.Searcher;
using System.Globalization;

public class PlayerCore : SerializedMonoBehaviour
{
    #region Properties

    [Title("ControlProperties")]
    [SerializeField] private float moveSpeed = 1.0f;                               // 이동 속도
    [SerializeField] private float sprintSpeed = 2.0f;                             // 달리기 속도
    [SerializeField] private float swimSpeed = 1.0f;                               // 수영시 속도
    [SerializeField] private float jumpPower = 1.0f;                               // 점프시 수직 속도

    [Title("Physics")]
    [SerializeField, Range(0f, 1f)] private float horizontalDrag = 0.5f;            // 키 입력이 없을 때 수평 이동 마찰력
    [SerializeField, Range(20f, 70f)] private float maxClimbSlope = 60f;            // 최고 이동가능 경사면
    [SerializeField] private float groundCastDistance = 0.1f;                       // 바닥 인식 거리
    [SerializeField] private LayerMask groundIgnore;                                // 바닥 인식 제외 레이어
    [SerializeField, Range(0f, 0.8f)] private float WaterWalkDragging = 0.5f;       // 물에서 걸을 때 받는 항력
    [SerializeField] private float WaterRigidbodyDrag = 10.0f;                      // 수영모드 시 변경되는 리지드바디 Drag 값
    [SerializeField] private float swimUpforce = 1.0f;                              // 수영시 적용되는 추가 부력
    [SerializeField, ReadOnly] private bool grounding = false;                      // 디버그 : 바닥 체크
    [SerializeField, ReadOnly] private Vector3 groundNormal = Vector3.up;           // 디버그 : 바닥 법선

    [Title("SailboatProperties")]
    [SerializeField] private float sailboatByouancy = 1.0f;                         // 조각배 기본 부력
    [SerializeField] private float sailboatGravity = 1.0f;                          // 조각배 중력
    [SerializeField] private float sailboatAccelerationForce = 50f;                 // 조각배 가속력
    [SerializeField] private float sailboatSlopeInfluenceForce = 20f;               // 조각배 수면 각도 영향력
    [SerializeField] private float sailboatFullDrag = 10.0f;                        // 조각배 완전 침수시 마찰력
    [SerializeField] private float sailboatMinimumDrag = 0.0f;                      // 조각배 최소 마찰력
    [SerializeField] private float sailboatRotateControl = 1.0f;                    // 조각배 앞뒤 회전 컨트롤 수치

#if UNITY_EDITOR
    [SerializeField, ReadOnly, LabelText("CurrentMove")] private string current_move_debug = "";

#endif

    [Title("ChildReferences")]
    [SerializeField, Required] private Animator animator;
    [SerializeField, Required] private BuoyantBehavior buoyant;
    [SerializeField, Required] private Transform RCO_foot;
    [SerializeField, Required] new private CapsuleCollider collider;
    [SerializeField, Required] private SailboatBehavior sailboat;
    [SerializeField, Required] private Rig sailboatFootRig;

    #endregion

    private Rigidbody rBody;
    private MainPlayerInputActions input;

    private bool sprinting = false;
    public bool Grounding { get { return grounding; } }

    private const float slopeBoostForce = 100f;

    private float initialRigidbodyDrag = 0f;

    private MovementState currentMovement_hidden;
    private MovementState CurrentMovement
    {
        get { return currentMovement_hidden; }
        set
        {
            if (currentMovement_hidden == null) currentMovement_hidden = value;
            else
            {
                if (currentMovement_hidden.GetType() == value.GetType()) return;
                currentMovement_hidden.OnMovementExit(this);
                currentMovement_hidden = value;
                currentMovement_hidden.OnMovementEnter(this);
            }
        }
    }


    private void Awake()
    {
        rBody = GetComponent<Rigidbody>();

        input = new MainPlayerInputActions();
        input.Player.Enable();
        input.Player.Sprint.performed += OnSprint;
        input.Player.Sprint.canceled += OnSprintEnd;
        input.Player.Jump.performed += OnJump;
        input.Player.ToggleSailboat.performed += OnToggleSailboat;

        CurrentMovement = new Movement_Ground();

    }

    private void Start()
    {
        initialRigidbodyDrag = rBody.drag;
    }

    private void Update()
    {

        RaycastHit groundHit;

        if (Physics.Raycast(RCO_foot.position, -groundNormal, out groundHit, groundCastDistance, ~groundIgnore))
        {
            grounding = true;
            groundNormal = groundHit.normal;

            animator.SetBool("Grounding", true);
        }
        else
        {
            if (grounding) OnGroundingEnter();

            grounding = false;
            groundNormal = Vector3.up;

            animator.SetBool("Grounding", false);
            if (rBody.velocity.y > 0) animator.SetFloat("AirboneBlend", 0f, 0.5f, Time.deltaTime);
            else animator.SetFloat("AirboneBlend", 1f, 0.5f, Time.deltaTime);
        }

        if (buoyant.SubmergeRate < -0.1f)
        {
            if (CurrentMovement.GetType() == typeof(Movement_Ground) && !grounding)
            {
                CurrentMovement = new Movement_Swimming();
            }
        }
        if (buoyant.SubmergeRate >= -0.1f)
        {
            if (CurrentMovement.GetType() == typeof(Movement_Swimming))
            {
                CurrentMovement = new Movement_Ground();
            }
        }

        // =================== CURRENT MOVEMENT UPDATE =========================
        CurrentMovement.OnUpdate(this);
        // =================== CURRENT MOVEMENT UPDATE =========================

#if UNITY_EDITOR
        if (CurrentMovement.GetType() == typeof(Movement_Ground)) current_move_debug = "GROUND";
        else if (CurrentMovement.GetType() == typeof(Movement_Swimming)) current_move_debug = "SWIMMING";
        else if (CurrentMovement.GetType() == typeof(Movement_Board)) current_move_debug = "SAILBOAT";
#endif
    }

    private void FixedUpdate()
    {
        // =================== CURRENT MOVEMENT FIXED UPDATE =========================
        CurrentMovement.OnFixedUpdate(this);
        // =================== CURRENT MOVEMENT FIXED UPDATE =========================
    }

    #region MovementStates

    protected class MovementState
    {
        public virtual void OnMovementEnter(PlayerCore @player) { }
        public virtual void OnUpdate(PlayerCore @player) { }
        public virtual void OnFixedUpdate(PlayerCore @player) { }
        public virtual void OnMovementExit(PlayerCore @player) { }
    }

    protected class Movement_Ground : MovementState
    {
        public override void OnFixedUpdate(PlayerCore player)
        {
            base.OnFixedUpdate(player);

            if (player.buoyant.SubmergeRate < 0)
            {
                player.rBody.AddForce(Vector3.up * player.swimUpforce, ForceMode.Acceleration);
            }

            if (player.input.Player.Move.IsPressed())
            {
                //forward velocity
                Vector3 lookTransformedVector = player.GetLookMoveVector(player.input.Player.Move.ReadValue<Vector2>(), Vector3.up);

                float adjuestedScale = (player.sprinting && player.grounding) ? player.sprintSpeed : player.moveSpeed;
                Vector3 slopedMoveVelocity = Vector3.ProjectOnPlane(lookTransformedVector, player.groundNormal) * adjuestedScale;

                Vector3 finalVelocity = (1f - player.buoyant.SubmergeRate * player.WaterWalkDragging) * slopedMoveVelocity;
                player.rBody.velocity = new Vector3(finalVelocity.x, player.rBody.velocity.y, finalVelocity.z);

                //slope boost
                float upSloping = Vector3.Dot(player.groundNormal, player.transform.forward) < 0f &&
                                Vector3.Angle(player.groundNormal, Vector3.up) < player.maxClimbSlope
                                ? 1.0f : 0.0f;

                player.rBody.AddForce(Vector3.up * (1f - Vector3.Dot(Vector3.up, player.groundNormal)) * slopeBoostForce * upSloping);

                //rotation
                bool LargeTurn = Quaternion.Angle(player.transform.rotation, Quaternion.LookRotation(lookTransformedVector, Vector3.up)) > 60f;

                player.transform.rotation = Quaternion.RotateTowards(
                    player.transform.rotation,
                    Quaternion.LookRotation(lookTransformedVector, Vector3.up),
                    LargeTurn ? 30f : 10f
                );

                player.animator.SetBool("MovementInput", true);
            }
            else
            {
                player.rBody.velocity = Vector3.Lerp(player.rBody.velocity, new Vector3(0f, player.rBody.velocity.y, 0f), player.horizontalDrag / 0.2f);
                player.animator.SetBool("MovementInput", false);
            }
        }

        public override void OnUpdate(PlayerCore player)
        {
            base.OnUpdate(player);
            if (player.sprinting) player.animator.SetFloat("RunBlend", 1f, 0.5f, Time.deltaTime);
            else player.animator.SetFloat("RunBlend", 0f, 0.5f, Time.deltaTime);
        }
    }

    protected class Movement_Swimming : MovementState
    {
        public override void OnMovementEnter(PlayerCore player)
        {
            player.rBody.drag = player.WaterRigidbodyDrag;
            base.OnMovementEnter(player);
            player.animator.SetBool("Swimming",true);
            player.animator.SetTrigger("SwimmingEnter");
        }

        public override void OnFixedUpdate(PlayerCore player)
        {
            base.OnFixedUpdate(player);

            if (player.buoyant.SubmergeRate < 0)
            {
                player.rBody.AddForce(Vector3.up * player.swimUpforce * (0.5f + Mathf.Sin(Time.time) * 3f));
            }

            if (player.input.Player.Move.IsPressed())
            {
                Vector3 lookTransformedVector = player.GetLookMoveVector(player.input.Player.Move.ReadValue<Vector2>(), Vector3.up);

                Vector3 finalVelocity = lookTransformedVector * player.swimSpeed;
                player.rBody.velocity = new Vector3(finalVelocity.x, player.rBody.velocity.y, finalVelocity.z);

                player.transform.rotation = Quaternion.RotateTowards(
                    player.transform.rotation,
                    Quaternion.LookRotation(lookTransformedVector, Vector3.up),
                    5f
                );
                player.animator.SetBool("Swimming_Move", true);
            }
            else
            {
                player.rBody.velocity = Vector3.Lerp(player.rBody.velocity, new Vector3(0, player.rBody.velocity.y, 0f), player.horizontalDrag);
                player.animator.SetBool("Swimming_Move", false);
            }
        }

        public override void OnMovementExit(PlayerCore player)
        {
            player.animator.SetBool("Swimming", false);
            player.rBody.drag = player.initialRigidbodyDrag;
            base.OnMovementExit(player);
        }
    }

    protected class Movement_Board : MovementState
    {
        public override void OnMovementEnter(PlayerCore player)
        {
            base.OnMovementEnter(player);
            player.sailboat.gameObject.SetActive(true);
            player.sailboatFootRig.weight = 1.0f;
            player.buoyant.enabled = false;
            player.rBody.useGravity = false;
            player.animator.SetBool("Boarding",true);
            player.animator.SetTrigger("BoardingEnter");
            player.animator.SetFloat("BoardBlend", 0.0f);
        }

        Vector3 directionCache = Vector3.forward;

        public override void OnFixedUpdate(PlayerCore player)
        {
            base.OnFixedUpdate(player);

            SailboatBehavior sailboat = player.sailboat;

            if (player.sailboat.SubmergeRate < -0.5f)
            {
                player.rBody.drag = player.sailboatFullDrag;
                player.rBody.AddForce(Vector3.up * -Mathf.Clamp(sailboat.SubmergeRate, -5.0f, -0.5f) * player.sailboatByouancy, ForceMode.Acceleration);

                if (player.input.Player.Move.IsPressed())
                {
                    Vector3 lookTransformedVector = player.GetLookMoveVector(player.input.Player.Move.ReadValue<Vector2>(), Vector3.up);
                    player.rBody.AddForce(lookTransformedVector * player.sailboatAccelerationForce);
                }
            }
            else if (player.sailboat.SubmergeRate < 0.01f)
            {
                player.rBody.drag = player.sailboatMinimumDrag;
                player.rBody.AddForce(Vector3.up * -sailboat.SubmergeRate * player.sailboatByouancy, ForceMode.Acceleration);
                player.rBody.AddForce(Vector3.ProjectOnPlane(sailboat.SurfacePlane.normal, Vector3.up) * player.sailboatSlopeInfluenceForce, ForceMode.Acceleration);

                if (player.input.Player.Move.IsPressed())
                {
                    Vector3 lookTransformedVector = player.GetLookMoveVector(player.input.Player.Move.ReadValue<Vector2>(), sailboat.SurfacePlane.normal);
                    player.rBody.AddForce(lookTransformedVector * player.sailboatAccelerationForce, ForceMode.Acceleration);
                }
            }
            else
            {
                player.rBody.drag = player.sailboatMinimumDrag;
                player.rBody.AddForce(Vector3.up * -Mathf.Clamp(sailboat.SubmergeRate,0f,1f) * player.sailboatGravity, ForceMode.Acceleration);
                if (player.input.Player.Move.IsPressed())
                {
                    Vector3 lookTransformedVector = player.GetLookMoveVector(player.input.Player.Move.ReadValue<Vector2>(), Vector3.up);
                    player.rBody.AddForce(lookTransformedVector * player.sailboatAccelerationForce, ForceMode.Acceleration);
                }
            }

            if (player.input.Player.Move.IsPressed() && Vector3.ProjectOnPlane(player.rBody.velocity,Vector3.up).magnitude > 2.0f)
            {
                sailboat.transform.rotation = Quaternion.RotateTowards(
                    sailboat.transform.rotation,
                    Quaternion.LookRotation(player.rBody.velocity, sailboat.SurfacePlane.normal),
                    5f);

                directionCache = Vector3.ProjectOnPlane(player.rBody.velocity, Vector3.up);
            }
            else
            {
                sailboat.transform.rotation = Quaternion.RotateTowards(
                    sailboat.transform.rotation,
                    Quaternion.LookRotation(directionCache, sailboat.SurfacePlane.normal),
                    3.0f
                    );
            }

            player.transform.forward = Vector3.ProjectOnPlane(sailboat.transform.forward, Vector3.up);

            player.animator.SetFloat("BoardBlend", player.rBody.velocity.y);
        }

        public override void OnMovementExit(PlayerCore player)
        {
            base.OnMovementExit(player);
            player.sailboat.gameObject.SetActive(false);
            player.sailboatFootRig.weight = 0.0f;
            player.buoyant.enabled = true;
            player.rBody.useGravity = true;
            player.rBody.drag = player.initialRigidbodyDrag;
            player.animator.SetBool("Boarding", false);
        }
    }

    #endregion 


    #region InputCallbacks

    private void OnToggleSailboat(InputAction.CallbackContext context)
    {
        if(CurrentMovement.GetType() != typeof(Movement_Board))
        {
            if(buoyant.WaterDetected)
            CurrentMovement = new Movement_Board();
        }
        else
        {
            CurrentMovement = new Movement_Ground();
        }
    }

    private void OnJump(InputAction.CallbackContext context)
    {
        if (CurrentMovement.GetType() == typeof(Movement_Ground) && grounding)
        {
            if (Vector3.Angle(groundNormal, Vector3.up) < maxClimbSlope)
            {
                rBody.velocity += Vector3.up * jumpPower;
                animator.SetFloat("AirboneBlend", 0f);
            }
        }
    }

    private void OnSprint(InputAction.CallbackContext context)
    {
        sprinting = true;

    }

    private void OnSprintEnd(InputAction.CallbackContext context)
    {
        sprinting = false;
    }

    #endregion

    private Vector3 GetLookMoveVector(Vector2 input, Vector3 up)
    {
        Vector3 lookTransformedVector = Camera.main.transform.TransformDirection(new Vector3(input.x, 0f, input.y));
        lookTransformedVector = Vector3.ProjectOnPlane(lookTransformedVector, up).normalized;
        return lookTransformedVector;
    }

    private void OnGroundingEnter()
    {

    }
}
