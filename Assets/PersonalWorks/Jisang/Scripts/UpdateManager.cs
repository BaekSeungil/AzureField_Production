using System;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEngine.LowLevel;

namespace Utils
{
    public static class PlayerLoopManager 
    {
        [RuntimeInitializeOnLoadMethod]
        private static void RunTimeInitialize()
        {
            PlayerLoopSystem playerLoop = PlayerLoop.GetCurrentPlayerLoop();

            for (int i = 0; i < playerLoop.subSystemList.Length; i++)
            {
                var subsystem = playerLoop.subSystemList[i];

                if (subsystem.subSystemList == null)
                    continue;

                var subSystemList = new List<PlayerLoopSystem>(subsystem.subSystemList);
                var loopSystem = new PlayerLoopSystem
                {
                    type = typeof(PlayerLoopManager),
                    updateDelegate = GetUpdateMethod(subsystem.type.Name)
                };
                subSystemList.Insert(0, loopSystem);
                subsystem.subSystemList = subSystemList.ToArray();
                playerLoop.subSystemList[i] = subsystem;
            }

            PlayerLoop.SetPlayerLoop(playerLoop);
        }
        private static PlayerLoopSystem.UpdateFunction GetUpdateMethod(string methodName)
        {
            MethodInfo methodInfo = typeof(PlayerLoopManager).GetMethod(methodName, BindingFlags.NonPublic | BindingFlags.Static);
            if (methodInfo == null)
            {
                Debug.LogWarning($"Method {methodName} not found.");
                return null;
            }

            try
            {
                return (PlayerLoopSystem.UpdateFunction)Delegate.CreateDelegate(typeof(PlayerLoopSystem.UpdateFunction), methodInfo);
            }
            catch (ArgumentNullException ex)
            {
                Debug.LogError($"ArgumentNullException: {ex.Message}");
            }
            catch (ArgumentException ex)
            {
                Debug.LogError($"ArgumentException: The delegate type or method signature is not valid for {methodName}: {ex.Message}");
            }
            catch (MethodAccessException ex)
            {
                Debug.LogError($"MethodAccessException: The caller does not have access to method {methodName}: {ex.Message}");
            }
            catch (MissingMethodException ex)
            {
                Debug.LogError($"MissingMethodException: No method found named {methodName}: {ex.Message}");
            }
            catch (InvalidOperationException ex)
            {
                Debug.LogError($"InvalidOperationException: The method {methodName} cannot be bound to the delegate type: {ex.Message}");
            }
            return null;
        }

        public static event Action OnTimeUpdate;
        public static event Action OnInitialization;
        public static event Action OnEarlyUpdate;
        public static event Action OnPreUpdate;
        public static event Action OnPreLateUpdate;
        public static event Action OnPostLateUpdate;

        private static void TimeUpdate() => OnTimeUpdate?.Invoke();
        private static void Initialization() => OnInitialization?.Invoke();
        private static void EarlyUpdate() => OnEarlyUpdate?.Invoke();
        private static void PreUpdate() => OnPreUpdate?.Invoke();
        private static void PreLateUpdate() => OnPreLateUpdate?.Invoke();
        private static void PostLateUpdate() => OnPostLateUpdate?.Invoke();
    }
}