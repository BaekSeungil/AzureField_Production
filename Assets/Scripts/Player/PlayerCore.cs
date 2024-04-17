using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using Sirenix.OdinInspector;
using UnityEngine.Animations.Rigging;
using FMODUnity;
using UnityEngine.Rendering.LookDev;
using System.Linq;
using System.Runtime.CompilerServices;


public class PlayerCore : StaticSerializedMonoBehaviour<PlayerCore>
{
    //============================================
    //
    // [싱글턴 오브젝트]
    // 플레이어 캐릭터에 관한 핵심 코드들입니다.
    // 플레이어의 움직임 상태는 State패턴에 의해 관리되고 있습니다. 자세한 정보는 프로그래머 매뉴얼을 참고해주세요 
    //
    //============================================

    #region ================ Properties ================
    [Title("ControlProperties")]
    [SerializeField] private float moveSpeed = 1.0f;                               // 이동 속도
    [SerializeField] private float sprintSpeedMult = 2.0f;                             // 달리기 속도
    [SerializeField] private float swimSpeed = 1.0f;                               // 수영시 속도
    [SerializeField] private float jumpPower = 1.0f;                               // 점프시 수직 파워  
    [SerializeField] private float holdingMoveSpeedMult = 0.5f;                    // 무언가를 들고있을 시 속도감소 (곱연산)

    [Title("Physics")]
    [SerializeField, Range(0f, 1f)] private float horizontalDrag = 0.5f;            // 키 입력이 없을 때 수평 이동 마찰력
    [SerializeField, Range(20f, 70f)] private float maxClimbSlope = 60f;            // 최고 이동가능 경사면
    [SerializeField] private float groundCastDistance = 0.1f;                       // 바닥 인식 거리
    [SerializeField] private LayerMask groundIgnore;                                // 바닥 인식 제외 레이어
    [SerializeField, Range(0f, 0.8f)] private float waterWalkDragging = 0.5f;       // 물에서 걸을 때 받는 항력
    [SerializeField] private float swimRigidbodyDrag = 10.0f;                       // 수영모드 시 변경되는 리지드바디 Drag 값
    [SerializeField] private float swimUpforce = 1.0f;                              // 수영시 적용되는 추가 부력
    [SerializeField, ReadOnly] private bool grounding = false;                      // 디버그 : 바닥 체크
    [SerializeField, ReadOnly] private Vector3 groundNormal = Vector3.up;           // 디버그 : 바닥 법선

    [Title("SailboatProperties")]
    [SerializeField] private float sailboatByouancy = 1.0f;                         // 조각배 기본 부력
    [SerializeField] private float sailboatGravity = 1.0f;                          // 조각배 중력
    [SerializeField] private float sailboatAccelerationForce = 50f;                 // 조각배 가속력
    [SerializeField] private float sailboatSlopeInfluenceForce = 20f;               // 조각배 수면 각도 영향력
    [SerializeField] private float sailboatNearsurf = 0.5f;                         // 조각배 저공비행 취급 높이
    [SerializeField] private float sailboatNearsurfBoost = 1.2f;                    // 조각배 저공비행 추가속도
    [SerializeField] private float sailboatFullDrag = 10.0f;                        // 조각배 완전 침수시 마찰력
    [SerializeField] private float sailboatScratchDrag = 1.0f;                      // 조각배 살짝 침수시 마찰력
    [SerializeField] private float sailboatMinimumDrag = 0.0f;                      // 조각배 최소 마찰력
    [SerializeField] private float sailboatVerticalControl = 10.0f;                 // 조각배 상하컨트롤 추가 힘
    [SerializeField] private float sailboatGliding = 1.0f;                          // 조각배 활공력
    [SerializeField] private float gustStartVelocity = 10.0f;                       // 바람소리 시작 속도
    [SerializeField] private float gustMaxVelocity = 50.0f;                         // 바람소리 최고 속도

    [Title("Audios")]
    [SerializeField] private EventReference sound_splash;                           // 첨벙이는 소리

    [Title("Others")]
    [SerializeField] private float interestDistance = 10.0f;                        // 캐릭터 시선 타겟 유지 거리


#if UNITY_EDITOR
#pragma warning disable CS0414

    [Title("Info")]
    [SerializeField, ReadOnly, LabelText("PlayerControl enabled")] private bool control_disabled_debug;
    [SerializeField, ReadOnly, LabelText("Currentmove")] private string current_move_debug = "";
    [SerializeField, ReadOnly, LabelText("Velocity")] private Vector3 velocity_debug;
    [SerializeField, ReadOnly, LabelText("Velocity magnitude")] private float velocity_mag_debug;
    [SerializeField, ReadOnly, LabelText("Horizontal velocity magnitude")] private float velocity_hor_debug;
    [SerializeField, ReadOnly, LabelText("Current holding item")] private string current_holding_item_debug;
#pragma warning restore CS0414
#endif

    [SerializeField, Required, FoldoutGroup("ChildReferences")] private Animator animator;
    [SerializeField, Required, FoldoutGroup("ChildReferences")] private BuoyantBehavior buoyant;
    [SerializeField, Required, FoldoutGroup("ChildReferences")] private Transform RCO_foot;
    [SerializeField, Required, FoldoutGroup("ChildReferences")] new private CapsuleCollider collider;
    [SerializeField, Required, FoldoutGroup("ChildReferences")] private SailboatBehavior sailboat;
    [SerializeField, Required, FoldoutGroup("ChildReferences")] private Transform sailboasModelPivot;
    [SerializeField, Required, FoldoutGroup("ChildReferences")] private ParticleSystem sailingSplashEffect;
    [SerializeField, Required, FoldoutGroup("ChildReferences")] private ParticleSystem sailingSprayEffect;
    [SerializeField, Required, FoldoutGroup("ChildReferences")] private ParticleSystem sailingSwooshEffect;
    [SerializeField, Required, FoldoutGroup("ChildReferences")] private Transform headTarget;
    [SerializeField, Required, FoldoutGroup("ChildReferences")] private Transform leftHandTarget;
    [SerializeField, Required, FoldoutGroup("ChildReferences")] private Transform rightHandTarget;
    [SerializeField, Required, FoldoutGroup("ChildReferences")] private Transform holdingItemTarget;
    [SerializeField, Required, FoldoutGroup("ChildReferences")] private Rig headRig;
    [SerializeField, Required, FoldoutGroup("ChildReferences")] private Rig sailboatFootRig;
    [SerializeField, Required, FoldoutGroup("ChildReferences")] private Rig handRig;
    [SerializeField, Required, FoldoutGroup("ChildReferences")] private Rig holdObjectRig;
    [SerializeField, Required, FoldoutGroup("ChildReferences")] private StudioEventEmitter gustSound;
    [SerializeField, Required, FoldoutGroup("ChildReferences")] private StudioEventEmitter waterScratchSound;

    #endregion

    private Rigidbody rBody;
    private StudioEventEmitter sound;
    private Transform interestPoint;
    private Interactable_Holding currentHoldingItem;
    private Vector3 previousVelocity;
    /// <summary>
    /// 현재 플레이어가 무언가를 들고 있는지 확인합니다.
    /// </summary>
    public bool IsHoldingSomething { get { return currentHoldingItem != null; } }

    private MainPlayerInputActions input;
    public MainPlayerInputActions Input { get { return input; } }

    private bool sprinting = false;
    /// <summary>
    /// // 현재 플레이어가 땅을 딛고 있는지 확인합니다.
    /// </summary>
    public bool Grounding { get { return grounding; } }

    private const float slopeBoostForce = 100f;

    private float initialRigidbodyDrag = 0f;

    Vector3 headRigForward;

    int layerIndex_Swim;
    int layerIndex_Boarding;

    private MovementState currentMovement_hidden;
    public MovementState CurrentMovement
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

    #region ================ PlayerAbilityAttributes ================

    public enum AbilityAttribute
    {
        MoveSpeed,
        SwimSpeed,
        JumpPower,
        SailboatAcceleration,
        SailboatGliding
    }

    public class AbilityAttributeUnit
    {
        public AbilityAttribute attribute;
        public float value = 1.0f;
        public float time = 0f;
        public string ID = string.Empty;

    }

    [ShowInInspector, ReadOnly] private List<AbilityAttributeUnit> permenentAttributes;
    [ShowInInspector, ReadOnly] private List<AbilityAttributeUnit> timeAttributes;
    [ShowInInspector, ReadOnly] private List<AbilityAttributeUnit> IDAttributes;

    public float FinalMoveSpeed
    {
        get
        {
            float result = moveSpeed;

            for (int i = 0; i < permenentAttributes.Count; i++) 
            {
                if (permenentAttributes[i].attribute == AbilityAttribute.MoveSpeed)
                    result *= permenentAttributes[i].value;
            }
            for (int i = 0; i < timeAttributes.Count; i++)
            {
                if (timeAttributes[i].attribute == AbilityAttribute.MoveSpeed)
                    result *= timeAttributes[i].value;
            }
            for (int i = 0; i < IDAttributes.Count; i++)
            {
                if (IDAttributes[i].attribute == AbilityAttribute.MoveSpeed)
                    result *= IDAttributes[i].value;
            }
            return result;
        }
    }

    public float FinalSwimSpeed
    {
        get
        {
            float result = swimSpeed;

            for (int i = 0; i < permenentAttributes.Count; i++)
            {
                if (permenentAttributes[i].attribute == AbilityAttribute.SwimSpeed)
                    result *= permenentAttributes[i].value;
            }
            for (int i = 0; i < timeAttributes.Count; i++)
            {
                if (timeAttributes[i].attribute == AbilityAttribute.SwimSpeed)
                    result *= timeAttributes[i].value;
            }
            for (int i = 0; i < IDAttributes.Count; i++)
            {
                if (IDAttributes[i].attribute == AbilityAttribute.SwimSpeed)
                    result *= IDAttributes[i].value;
            }
            return result;
        }
    }

    public float FinalJumpPower
    {
        get
        {
            float result = jumpPower;

            for (int i = 0; i < permenentAttributes.Count; i++)
            {
                if (permenentAttributes[i].attribute == AbilityAttribute.JumpPower)
                    result *= permenentAttributes[i].value;
            }
            for (int i = 0; i < timeAttributes.Count; i++)
            {
                if (timeAttributes[i].attribute == AbilityAttribute.JumpPower)
                    result *= timeAttributes[i].value;
            }
            for (int i = 0; i < IDAttributes.Count; i++)
            {
                if (IDAttributes[i].attribute == AbilityAttribute.JumpPower)
                    result *= IDAttributes[i].value;
            }
            return result;
        }
    }

    public float FinalSailboatAcceleration
    {
        get
        {
            float result = sailboatAccelerationForce;

            for (int i = 0; i < permenentAttributes.Count; i++)
            {
                if (permenentAttributes[i].attribute == AbilityAttribute.SailboatAcceleration)
                    result *= permenentAttributes[i].value;
            }
            for (int i = 0; i < timeAttributes.Count; i++)
            {
                if (timeAttributes[i].attribute == AbilityAttribute.SailboatAcceleration)
                    result *= timeAttributes[i].value;
            }
            for (int i = 0; i < IDAttributes.Count; i++)
            {
                if (IDAttributes[i].attribute == AbilityAttribute.SailboatAcceleration)
                    result *= IDAttributes[i].value;
            }
            return result;
        }
    }

    public float FinalSailboatGliding
    {
        get
        {
            float result = sailboatGliding;

            for (int i = 0; i < permenentAttributes.Count; i++)
            {
                if (permenentAttributes[i].attribute == AbilityAttribute.SailboatGliding)
                    result *= permenentAttributes[i].value;
            }
            for (int i = 0; i < timeAttributes.Count; i++)
            {
                if (timeAttributes[i].attribute == AbilityAttribute.SailboatGliding)
                    result *= timeAttributes[i].value;
            }
            for (int i = 0; i < IDAttributes.Count; i++)
            {
                if (IDAttributes[i].attribute == AbilityAttribute.SailboatGliding)
                    result *= IDAttributes[i].value;
            }
            return result;
        }
    }


    /// <summary>
    /// 영구적인 플레이어 속성 값을 더합니다.
    /// </summary>
    /// <param name="attr">속성</param>
    public void AddPermernentAttribute(AbilityAttribute ability, float value)
    {
        for(int i = 0; i < permenentAttributes.Count;i++) 
        {
            if (permenentAttributes[i].attribute == ability)
            {
                permenentAttributes[i].value += value;
                return;
            }
        }

        AbilityAttributeUnit newAttr = new AbilityAttributeUnit();
        newAttr.attribute = ability; newAttr.value = value;
        permenentAttributes.Add(newAttr);
    }

    /// <summary>
    /// 일시적으로 플레이어 수치를 적용합니다.(곱연산)
    /// </summary>
    /// <param name="attr">속성</param>
    /// <param name="time">시간</param>
    public void SetTempoaryAttribute(AbilityAttribute ability, float value ,float time)
    {
        AbilityAttributeUnit newAttr = new AbilityAttributeUnit();
        newAttr.attribute = ability; newAttr.value = value; newAttr.time = time;
        timeAttributes.Add(newAttr);
    }

    /// <summary>
    /// 일시적으로 플레이어 속성을 ID를 붙여 적용합니다.(곱연산) 이미 있는 ID에 값을 적용할 경우 기존 값을 바꿉니다.
    /// </summary>
    /// <param name="attr">속성</param>
    /// <param name="ID"></param>
    public void SetAttributeWithID(AbilityAttribute ability,float value, string ID)
    {
        for(int i = 0; i < IDAttributes.Count;i++) 
        {
            if (IDAttributes[i].ID.Equals(ID))
            {
                IDAttributes[i].value = value;
                return;
            }
        }

        AbilityAttributeUnit newAttr = new AbilityAttributeUnit();
        newAttr.attribute = ability; newAttr.value = value; newAttr.ID = ID;
        IDAttributes.Add(newAttr);
    }


    /// <summary>
    ///  ID가 붙어있는 플레이어 속성을 해제합니다.
    /// </summary>
    /// <param name="ID"></param>
    public void CancelAttributeWithID(string ID)
    {
        for(int i =  0; i < IDAttributes.Count; i++)
        {
            if (IDAttributes[i].ID == ID)
            {
                IDAttributes.RemoveAt(i);
                return;
            }
        }

        Debug.LogWarning("ATTRIBUTE ID를 찾을 수 없었습니다 :" + ID);
    }

    #endregion

    public void SailboatQuit()
    {
        CurrentMovement = new Movement_Ground();
    }

    protected override void Awake()
    {
        base.Awake();

        rBody = GetComponent<Rigidbody>();
        sound = GetComponent<StudioEventEmitter>();

        input = new MainPlayerInputActions();
        input.Player.Enable();
        input.Player.Sprint.performed += OnSprint;
        input.Player.Sprint.canceled += OnSprintEnd;
        input.Player.Jump.performed += OnJump;
        input.Player.ToggleSailboat.performed += OnToggleSailboat;

        permenentAttributes = new List<AbilityAttributeUnit>();
        timeAttributes = new List<AbilityAttributeUnit>();
        IDAttributes = new List<AbilityAttributeUnit>();

        CurrentMovement = new Movement_Ground();

    }

    private void OnEnable()
    {
        var em = sailingSwooshEffect.emission;
        em.rateOverTimeMultiplier = 0f;
    }

    private void Start()
    {
        initialRigidbodyDrag = rBody.drag;
        headRigForward = headTarget.localPosition;
        previousVelocity = rBody.velocity;

        layerIndex_Swim = animator.GetLayerIndex("SwimLayer");
        layerIndex_Boarding = animator.GetLayerIndex("BoardingLayer");
    }

    private float headRigTarget = 0.7f;

    private void FixedUpdate()
    {
        // =================== CURRENT MOVEMENT FIXED UPDATE =========================
        CurrentMovement.OnFixedUpdate(this);
        // =================== CURRENT MOVEMENT FIXED UPDATE =========================

        if (interestPoint == null)
        {
            headTarget.parent = transform;
            headRig.weight = Mathf.Lerp(headRig.weight, 0f, 0.05f);
            headTarget.localPosition = Vector3.Lerp(headTarget.localPosition, headRigForward, 0.05f);
        }
        else
        {
            headTarget.parent = null;
            headRig.weight = Mathf.Lerp(headRig.weight, headRigTarget, 0.05f);
            headTarget.position = Vector3.Lerp(headTarget.position, interestPoint.position, 0.05f);


            if (Vector3.Distance(transform.position, interestPoint.position) > interestDistance)
                interestPoint = null;
        }


        //이전 프레임의 플레이어 속도
        Vector3 currentVelocity = rBody.velocity;

        // 이전 프레임과 현재 프레임의 속도를 비교하여 속도의 변화를 확인합니다.
        Vector3 velocityChange = currentVelocity - previousVelocity;

        // 1프레임 전의 속도를 출력합니다.
        //Debug.Log("1프레임 전의 속도: " + previousVelocity.magnitude);

        // 현재 프레임의 속도를 이전 프레임의 속도로 업데이트합니다.
        previousVelocity = currentVelocity;
    }

    private void Update()
    {
        // Raycast process
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

        // Movement state change condition
        if (buoyant.SubmergeRateZeroClamped < -0.1f)
        {

            if (CurrentMovement.GetType() == typeof(Movement_Ground) && !grounding)
            {
                if (rBody.velocity.y < -0.5f) RuntimeManager.PlayOneShot(sound_splash);
                CurrentMovement = new Movement_Swimming();
            }
        }
        if (buoyant.SubmergeRateZeroClamped >= -0.1f)
        {
            if (CurrentMovement.GetType() == typeof(Movement_Swimming))
            {
                CurrentMovement = new Movement_Ground();
            }
        }

        // =================== CURRENT MOVEMENT UPDATE =========================
        CurrentMovement.OnUpdate(this);
        // =================== CURRENT MOVEMENT UPDATE =========================

        // Time ability attribute update
        for (int ta = 0; ta < timeAttributes.Count; ta++)
        {
            timeAttributes[ta].time -= Time.deltaTime;
            if (timeAttributes[ta].time < 0)
            {
                timeAttributes.RemoveAt(ta);
                ta--;
            }
        }


        // animation & audio controls
        if (CurrentMovement.GetType() == typeof(Movement_Swimming))
            animator.SetLayerWeight(layerIndex_Swim, Mathf.Lerp(animator.GetLayerWeight(layerIndex_Swim), 1.0f, 0.2f));
        else
            animator.SetLayerWeight(layerIndex_Swim, Mathf.Lerp(animator.GetLayerWeight(layerIndex_Swim), 0.0f, 0.2f));

        if (CurrentMovement.GetType() == typeof(Movement_Sailboat))
            animator.SetLayerWeight(layerIndex_Boarding, Mathf.Lerp(animator.GetLayerWeight(layerIndex_Boarding), 1.0f, 0.2f));
        else
        {
            animator.SetLayerWeight(layerIndex_Boarding, Mathf.Lerp(animator.GetLayerWeight(layerIndex_Boarding), 0.0f, 0.2f));

            float f;
            gustSound.EventInstance.getParameterByName("Speed", out f);
            gustSound.EventInstance.setParameterByName("Speed", Mathf.Lerp(f, 0f, 0.1f));
            waterScratchSound.EventInstance.getParameterByName("BoardWaterScratch", out f);
            waterScratchSound.EventInstance.setParameterByName("BoardWaterScratch", Mathf.Lerp(f, 0f, 0.1f));
        }

        // etc.


        if (Input.Player.Interact.WasPressedThisFrame())
        {
            ReleaseHoldingItem();
        }


        // info update
#if UNITY_EDITOR
        if (CurrentMovement.GetType() == typeof(Movement_Ground)) current_move_debug = "GROUND";
        else if (CurrentMovement.GetType() == typeof(Movement_Swimming)) current_move_debug = "SWIMMING";
        else if (CurrentMovement.GetType() == typeof(Movement_Sailboat)) current_move_debug = "SAILBOAT";

        if (input.Player.enabled) control_disabled_debug = true;
        else control_disabled_debug = false;

        velocity_hor_debug = Vector3.ProjectOnPlane(rBody.velocity, Vector3.up).magnitude;
        if (currentHoldingItem != null)
            current_holding_item_debug = currentHoldingItem.gameObject.name;
        else
            current_holding_item_debug = "NULL";

#endif


    }

    private void LateUpdate()
    {
#if UNITY_EDITOR
        velocity_debug = rBody.velocity;
        velocity_mag_debug = rBody.velocity.magnitude;
#endif
    }


    #region ================ MovementStates ================

    //============================================
    //
    // MovementStates는 플레이어의 현재 행동을 나타내는 state패턴의 클래스들 입니다.
    // CurrentMovement를 통해 현재 플레이어의 움직임 state를 변경할 수 있습니다.
    // CurrentMovement가 바뀌면 이전 state의 OnMovementExit가 호출되고 바뀔 state의 OnMovementEnter가 호출됩니다.
    //
    //============================================

    public class MovementState
    {
        /// <summary>
        /// 해당 state로 들어올 때 이 함수가 호출됩니다.
        /// </summary>
        /// <param name="player"> 플레이어 인스턴스 </param>
        public virtual void OnMovementEnter(PlayerCore @player) { }
        /// <summary>
        /// Update 루프 때 이 함수가 호출됩니다
        /// </summary>
        /// <param name="player"></param>
        public virtual void OnUpdate(PlayerCore @player) { }
        /// <summary>
        /// FixedUpdate 루프 때 이 함수가 호출됩니다.
        /// </summary>
        /// <param name="player"></param>
        public virtual void OnFixedUpdate(PlayerCore @player) { }
        /// <summary>
        /// 해당 state에서 나가라 때 이 함수가 호출됩니다.
        /// </summary>
        /// <param name="player"></param>
        public virtual void OnMovementExit(PlayerCore @player) { }
    }

/// <summary>
/// 플레이어가 땅 위를 뛰어다니는 상태일 때
/// </summary>
    protected class Movement_Ground : MovementState
    {
        public override void OnFixedUpdate(PlayerCore player)
        {
            base.OnFixedUpdate(player);

            if (player.buoyant.SubmergeRateZeroClamped < 0)
            {
                player.rBody.AddForce(Vector3.up * player.swimUpforce, ForceMode.Acceleration);
            }

            if (player.input.Player.Move.IsPressed())
            {
                //forward velocity
                Vector3 lookTransformedVector = player.GetLookMoveVector(player.input.Player.Move.ReadValue<Vector2>(), Vector3.up);

                float adjuestedScale = (player.sprinting && player.grounding) ? player.FinalMoveSpeed * player.sprintSpeedMult : player.FinalMoveSpeed;
                Vector3 slopedMoveVelocity = Vector3.ProjectOnPlane(lookTransformedVector, player.groundNormal) * adjuestedScale;

                Vector3 finalVelocity = slopedMoveVelocity * ((player.currentHoldingItem == null)?1.0f:player.holdingMoveSpeedMult);
                if (player.buoyant.WaterDetected)
                {
                    finalVelocity = finalVelocity * (1f - Mathf.Lerp(0.5f, 0f, player.buoyant.SubmergeRate) * player.waterWalkDragging);
                }

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

                if (player.buoyant.WaterDetected)
                    player.animator.speed = 1f - Mathf.Lerp(0.5f, 0f, player.buoyant.SubmergeRate) * player.waterWalkDragging;
                else 
                    player.animator.speed = 1.0f;

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
            if (player.sprinting) player.animator.SetFloat("RunBlend", 1f, 0.1f, Time.deltaTime);
            else player.animator.SetFloat("RunBlend", 0f, 0.1f, Time.deltaTime);
        }

        public override void OnMovementExit(PlayerCore player)
        {
            base.OnMovementExit(player);
            player.ReleaseHoldingItem();
        }
    }

/// <summary>
/// 플레이어가 수영중인 상황일 때
/// </summary>
    protected class Movement_Swimming : MovementState
    {
        public override void OnMovementEnter(PlayerCore player)
        {
            player.rBody.drag = player.swimRigidbodyDrag;
            base.OnMovementEnter(player);
            player.animator.SetBool("Swimming", true);
            player.animator.SetTrigger("SwimmingEnter");
        }

        public override void OnFixedUpdate(PlayerCore player)
        {
            base.OnFixedUpdate(player);

            if (player.buoyant.SubmergeRateZeroClamped < 0)
            {
                player.rBody.AddForce(Vector3.up * player.swimUpforce * (0.5f + Mathf.Sin(Time.time) / 2f));
            }

            if (player.input.Player.Move.IsPressed())
            {
                Vector3 lookTransformedVector = player.GetLookMoveVector(player.input.Player.Move.ReadValue<Vector2>(), Vector3.up);

                Vector3 finalVelocity = lookTransformedVector * player.FinalSwimSpeed;
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

/// <summary>
/// 플레이어가 조각배를 타는 상황일 때
/// </summary>
    protected class Movement_Sailboat : MovementState
    {
        public override void OnMovementEnter(PlayerCore player)
        {
            base.OnMovementEnter(player);
            player.sailboat.gameObject.SetActive(true);
            player.sailboatFootRig.weight = 1.0f;
            player.buoyant.enabled = false;
            player.rBody.useGravity = false;
            player.animator.SetBool("Boarding", true);
            player.animator.SetTrigger("BoardingEnter");
            player.animator.SetFloat("BoardBlend", 0.0f);
        }

        Vector3 directionCache = Vector3.forward;
        float GustAmount = 0.0f;
        bool enterFlag = false;

        public override void OnFixedUpdate(PlayerCore player)
        {
            base.OnFixedUpdate(player);

            SailboatBehavior sailboat = player.sailboat;
            GustAmount = Mathf.InverseLerp(player.gustStartVelocity, player.gustMaxVelocity, Vector3.ProjectOnPlane(player.rBody.velocity, Vector3.up).magnitude);

            float ns_boost = sailboat.SubmergeRate < player.sailboatNearsurf && sailboat.SubmergeRate > -0.1f ? player.sailboatNearsurfBoost : 1.0f;

            if (player.sailboat.SubmergeRate < -0.5f)
            {
                player.rBody.drag = player.sailboatFullDrag;
                player.rBody.AddForce(Vector3.up * -Mathf.Clamp(sailboat.SubmergeRate, -1.0f, 0.0f) * player.sailboatByouancy, ForceMode.Acceleration);

                if (player.input.Player.Move.IsPressed())
                {
                    Vector3 lookTransformedVector = player.GetLookMoveVector(player.input.Player.Move.ReadValue<Vector2>(), Vector3.up);
                    player.rBody.AddForce(lookTransformedVector * player.FinalSailboatAcceleration);
                }
            }
            else if (player.sailboat.SubmergeRate < 0.01f)
            {
                player.rBody.drag = player.sailboatScratchDrag;
                player.rBody.AddForce(Vector3.up * -sailboat.SubmergeRate * player.sailboatByouancy, ForceMode.Acceleration);
                player.rBody.AddForce(Vector3.ProjectOnPlane(sailboat.SurfacePlane.normal, Vector3.up) * player.sailboatSlopeInfluenceForce, ForceMode.Acceleration);

                if (player.input.Player.Move.IsPressed())
                {
                    Vector3 lookTransformedVector = player.GetLookMoveVector(player.input.Player.Move.ReadValue<Vector2>(), sailboat.SurfacePlane.normal);
                    player.rBody.AddForce(lookTransformedVector * player.FinalSailboatAcceleration * ns_boost, ForceMode.Acceleration);
                }

                if (!enterFlag)
                {
                    enterFlag = true;
                    if (player.rBody.velocity.y < -1f)
                    {
                        RuntimeManager.PlayOneShot(player.sound_splash);

                        player.sailingSplashEffect.Emit(5);
                    }
                }
            }
            else
            {
                enterFlag = false;

                if (!player.Grounding)
                {
                    player.rBody.drag = player.sailboatMinimumDrag;
                    if (player.input.Player.Move.IsPressed())
                    {
                        Vector3 lookTransformedVector = player.GetLookMoveVector(player.input.Player.Move.ReadValue<Vector2>(), Vector3.up);
                        player.rBody.AddForce(lookTransformedVector * player.FinalSailboatAcceleration * ns_boost, ForceMode.Acceleration);
                    }
                }

                player.rBody.AddForce(Vector3.up * -Mathf.Clamp(sailboat.SubmergeRate, 0f, 1f) * player.sailboatGravity, ForceMode.Acceleration);
            }

            if (Vector3.ProjectOnPlane(player.rBody.velocity, Vector3.up).magnitude > 2.0f)
            {
                Vector3 euler = player.sailboasModelPivot.localRotation.eulerAngles;

                if (player.input.Player.SailboatForward.IsPressed())
                {
                    player.rBody.AddForce(Vector3.up * player.sailboatVerticalControl * player.FinalSailboatGliding);

                    player.sailboasModelPivot.localRotation = Quaternion.Slerp(player.sailboasModelPivot.localRotation,
                    Quaternion.Euler(-10f, euler.y, euler.z), 0.05f);
                }
                else if (player.input.Player.SailboatBackward.IsPressed())
                {
                    player.rBody.AddForce(Vector3.down * player.sailboatVerticalControl);

                    player.sailboasModelPivot.localRotation = Quaternion.Slerp(player.sailboasModelPivot.localRotation,
                    Quaternion.Euler(10f, euler.y, euler.z), 0.1f);
                }
                else
                {
                    player.sailboasModelPivot.localRotation = Quaternion.Slerp(player.sailboasModelPivot.localRotation,
                    Quaternion.Euler(0f, euler.y, euler.z), 0.1f);
                }

                euler = player.sailboasModelPivot.localRotation.eulerAngles;

                if (player.input.Player.Move.IsPressed())
                {
                    sailboat.transform.rotation = Quaternion.Slerp(sailboat.transform.rotation,
                        Quaternion.LookRotation(player.rBody.velocity, sailboat.SurfacePlane.normal),
                        0.4f);

                    Vector3 lookTransformedVector = player.GetLookMoveVector(player.input.Player.Move.ReadValue<Vector2>(), Vector3.up);
                    float lean = Vector3.Dot(lookTransformedVector, player.transform.right);
                    player.sailboasModelPivot.localRotation = Quaternion.Slerp(player.sailboasModelPivot.localRotation,
                    Quaternion.Euler(euler.x, euler.y, -lean * 30f), 0.05f);

                    directionCache = Vector3.ProjectOnPlane(player.rBody.velocity, Vector3.up);
                }
            }
            else
            {
                sailboat.transform.rotation = Quaternion.Slerp(sailboat.transform.rotation,
                    Quaternion.LookRotation(directionCache, sailboat.SurfacePlane.normal),
                    0.4f);
            }

            if( sailboat.SubmergeRate < player.sailboatNearsurf && sailboat.SubmergeRate > -0.1f)
            {
                if (Vector3.ProjectOnPlane(player.rBody.velocity, Vector3.up).magnitude > 13f)
                {
                    player.sailingSprayEffect.Play();
                }
                else
                {
                    player.sailingSprayEffect.Stop();
                }
            }

            player.transform.forward = Vector3.ProjectOnPlane(sailboat.transform.forward, Vector3.up);

            player.animator.SetFloat("BoardBlend", player.rBody.velocity.y);

            if( player.input.Player.Move.IsPressed())
            {
                player.animator.SetFloat("BoardPropellingBlend", 1f, 1f, Time.fixedDeltaTime);
            }
            else
            {
                player.animator.SetFloat("BoardPropellingBlend", 0f, 1f, Time.fixedDeltaTime);
            }

            player.waterScratchSound.EventInstance.setParameterByName("BoardWaterScratch", Mathf.InverseLerp(0.5f, -0.5f, player.sailboat.SubmergeRate) * GustAmount * 1.5f);

            var em = player.sailingSwooshEffect.emission;
            em.rateOverTimeMultiplier = GustAmount * 3f;

            player.gustSound.EventInstance.setParameterByName("Speed", GustAmount);
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
            player.animator.SetFloat("BoardPropellingBlend", 0f);

            var em = player.sailingSwooshEffect.emission;
            em.rateOverTimeMultiplier = 0f;
        }
    }

    #endregion

    #region ================ InputCallbacks ================
    // InputSystem 입력 이벤트

    private void OnToggleSailboat(InputAction.CallbackContext context)
    // @ "조각배소환" 버튼
    {
        if (CurrentMovement.GetType() != typeof(Movement_Sailboat))
        {
            if (buoyant.WaterDetected && buoyant.SubmergeRate < 0.5f)
                CurrentMovement = new Movement_Sailboat();
        }
        else
        {
            CurrentMovement = new Movement_Ground();
        }
    }

    private void OnJump(InputAction.CallbackContext context)
    // @ "점프" 버튼
    {
        if (CurrentMovement.GetType() == typeof(Movement_Ground) && grounding)
        {
            if (Vector3.Angle(groundNormal, Vector3.up) < maxClimbSlope)
            {
                rBody.velocity += Vector3.up * FinalJumpPower;
                animator.SetFloat("AirboneBlend", 0f);
                PlayFootstepSound();
            }
        }
    }

    private void OnSprint(InputAction.CallbackContext context)
    // @ "달리기" 버튼
    {
        sprinting = true;

    }

    private void OnSprintEnd(InputAction.CallbackContext context)
    {
        sprinting = false;
    }

    #endregion

/// <summary>
/// 플레이어가 얼굴을 향하는 방향을 target으로 맞춥니다.
/// </summary>
/// <param name="target"></param>
    public void SetInterestPoint(Transform target)
    {
        interestPoint = target;
    }

    bool holdItemCoroutineFlag = false;

/// <summary>
///     //Interactable_Holding과 함께 사용합니다. 아이템을 듭니다.
/// </summary>
/// <param name="leftHand"> 왼손 짚는 위치 </param>
/// <param name="rightHand"> 오른손 짚는 위치 </param>
/// <param name="holdingItem"> 잡는 아이템 </param>
/// <returns></returns>
    public bool HoldItem(Transform leftHand, Transform rightHand,Interactable_Holding holdingItem)
    {
        if (holdItemCoroutineFlag) return false;
        if (currentHoldingItem != null) { ReleaseHoldingItem(); return false; }
        else
        {
            StartCoroutine(Cor_HoldItem(leftHand, rightHand, holdingItem));
            return true;
        }
    }

    float holdItemAnimTime = 1.0f;


    private IEnumerator Cor_HoldItem(Transform leftHand, Transform rightHand, Interactable_Holding holdingItem)
    {
        animator.SetTrigger("ItemPickup");
        bool inputWasEnabled = Input.Player.enabled;
        Input.Player.Disable();
        holdItemCoroutineFlag = true;

        yield return new WaitForSeconds(holdItemAnimTime / 2f);

        leftHandTarget.SetParent(leftHand, false);
        rightHandTarget.SetParent(rightHand, false);
        holdingItem.transform.parent = holdingItemTarget;
        handRig.weight = 1.0f;

        for (float t = 0; t < holdItemAnimTime / 2f; t += Time.deltaTime)
        {
            holdingItem.transform.localPosition = Vector3.Lerp(holdingItem.transform.localPosition, Vector3.zero, 0.4f);
            holdingItem.transform.localRotation = Quaternion.Lerp(holdingItem.transform.localRotation, Quaternion.Euler(Vector3.zero), 0.4f);
            holdObjectRig.weight = Mathf.InverseLerp(0,holdItemAnimTime*0.45f,t);
            yield return null;
        }

        if (inputWasEnabled)
            Input.Player.Enable();
        holdObjectRig.weight = 0.9f;

        holdItemCoroutineFlag = false;
        currentHoldingItem = holdingItem;
    }

/// <summary>
/// 현재 들고있는 아이템이 있으면 즉시 놓습니다.
/// </summary>
    public void ReleaseHoldingItem()
    {
        if (currentHoldingItem == null) return;

        currentHoldingItem.transform.parent = null;
        currentHoldingItem.Release();
        currentHoldingItem = null;
        handRig.weight = 0.0f;
        holdObjectRig.weight = 0.0f;
    }


/// <summary>
///  시퀀스 시작시 플레이어의 조작을 비활성화하기 위한 함수.
/// </summary>
    public void DisableForSequence()
    {
        input.Player.Disable();
        Cinemachine.CinemachineInputProvider cameraInputProvider = FindFirstObjectByType<Cinemachine.CinemachineInputProvider>();
        if(cameraInputProvider != null) { cameraInputProvider.enabled = false; }
    }

/// <summary>
/// 시퀀스 종료시 플레이어의 조작을 활성화하기 위한 함수.
/// </summary>
    public void EnableForSequence()
    {
        input.Player.Enable();
        Cinemachine.CinemachineInputProvider cameraInputProvider = FindFirstObjectByType<Cinemachine.CinemachineInputProvider>();
        if (cameraInputProvider != null) { cameraInputProvider.enabled = true; }
    }

/// <summary>
/// @ 애니메이션 용 이벤트 함수 : 플레이어가 발을 딛을 때 호출되는 함수.
/// </summary>
    public void FootstepEvent()
    {
        if (CurrentMovement.GetType() == typeof(Movement_Ground))
            PlayFootstepSound();
    }

    private Vector3 GetLookMoveVector(Vector2 input, Vector3 up)
    {
        Vector3 lookTransformedVector = Camera.main.transform.TransformDirection(new Vector3(input.x, 0f, input.y));
        lookTransformedVector = Vector3.ProjectOnPlane(lookTransformedVector, up).normalized;
        return lookTransformedVector;
    }

    private void OnGroundingEnter()
    {

    }

    private void PlayFootstepSound()
    {
        RaycastHit hit;
        Ray ray = new Ray(RCO_foot.position, Vector3.down);
        if (Physics.Raycast(RCO_foot.position, -groundNormal, out hit, groundCastDistance, ~groundIgnore))
        {
            SoundMaterialBehavior soundMaterialComp;
            SoundMaterial soundMaterial = SoundMaterial.Default;

            sound.EventInstance.setParameterByNameWithLabel("GroundMaterial", "Default");

            if (hit.collider.TryGetComponent(out soundMaterialComp))
            {
                soundMaterial = soundMaterialComp.GetSoundMaterial(RCO_foot.position);

                switch (soundMaterial)
                {
                    case SoundMaterial.Default:
                        sound.EventInstance.setParameterByNameWithLabel("GroundMaterial", "Default");
                        break;
                    case SoundMaterial.Sand:
                        sound.EventInstance.setParameterByNameWithLabel("GroundMaterial", "Sand");
                        break;
                    case SoundMaterial.Water:
                        sound.EventInstance.setParameterByNameWithLabel("GroundMaterial", "Water");
                        break;
                    case SoundMaterial.Grass:
                        sound.EventInstance.setParameterByNameWithLabel("GroundMaterial", "Grass");
                        break;
                    case SoundMaterial.Wood:
                        sound.EventInstance.setParameterByNameWithLabel("GroundMaterial", "Wood");
                        break;

                    default:
                        sound.EventInstance.setParameterByNameWithLabel("GroundMaterial", "Default");
                        break;
                }
           
                if(buoyant.SubmergeRate < 1.0f && buoyant.SubmergeRate > 0.5f)
                {
                    sound.EventInstance.setParameterByNameWithLabel("GroundMaterial", "Water");
                }
                else if(buoyant.SubmergeRate <= 0.5f)
                {
                    sound.EventInstance.setParameterByNameWithLabel("GroundMaterial", "WaterSplash");
                }
            }

            sound.Play();
        }
    }

    /// <summary>
    /// DropItemCrash가 플레이어 변수에 접근하기 위한 함수
    /// </summary>>
    public void DropItemCrash(float addMoveSpeed, float addSprintSpeed, float addSwimSpeed, float addJumpPower, float addBoatSpeed)
    {
        moveSpeed += addMoveSpeed;
        sprintSpeedMult += addSprintSpeed;
        swimSpeed += addSwimSpeed;
        jumpPower += addJumpPower;
        sailboatAccelerationForce += addBoatSpeed;


    }

    /// <summary>
    /// 플레이어가 조각배 탑승 중에 암초에 충돌할 경우
    /// </summary>
    IEnumerator ReefCrash()
    {
        DisableForSequence();

        animator.SetTrigger("BoardingColided");

        yield return new WaitForSeconds(1.0f);

        SailboatQuit();
        EnableForSequence();
    }


    private float reefCrashDelta = 7.0f;
    private float reboundForce = 10f;
    /// <summary>
    /// 충돌감지
    /// </summary>
    private void OnCollisionEnter(Collision collision)
    {
        if (collision.collider.gameObject.CompareTag("Reef"))
        {
            ///<summary>
            ///암초충돌감지
            /// </summary>
            if (previousVelocity.magnitude - rBody.velocity.magnitude > reefCrashDelta)
            {
                Debug.Log(previousVelocity.magnitude + ", " + rBody.velocity.magnitude);
                Debug.Log("암초 대충돌!");
                rBody.AddForce(Vector3.ProjectOnPlane(-previousVelocity,Vector3.up).normalized * reboundForce,ForceMode.Impulse);
                StartCoroutine(ReefCrash());
            }

        }
    }
}
