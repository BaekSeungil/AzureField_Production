using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.PlayerLoop;
using UnityEngine.LowLevel;

namespace JJS.Utils
{
    public interface INotifiable<T>
    {
        public T Value { get; }

        //call when Update
        public event Action OnChanged;
        public event Action<T> OnDataChanged;
        public event Action<T> OnDataChangedOnce;
        public event Action<T, T> OnDataChangedDelta;
    }

    [Serializable]
    public class Notifier<T> : INotifiable<T>
    {
        [SerializeField]
        private T value;

        public T Value
        {
            get => value;
            set => Set(value, true);
        }


        private static EqualityComparer<T> defaultComparer = EqualityComparer<T>.Default;

        private EqualityComparer<T> overrideComparer = null;
        private EqualityComparer<T> OverrideComparer { get => overrideComparer ?? defaultComparer; }


        public virtual void Set(in T value, bool notify = true)
        {
            if (!OverrideComparer.Equals(this.value, value))
            {
                var lastData = this.value;
                this.value = value;

                if (notify)
                {
                    OnChanged?.Invoke();
                    OnDataChanged?.Invoke(this.value);
                    OnDataChangedOnce?.Invoke(this.value);
                    OnDataChangedDelta?.Invoke(lastData, this.value);
                    OnDataChangedOnce = null;
                }
            }
        }

        //call when Update
        public event Action OnChanged;
        public event Action<T> OnDataChanged;
        public event Action<T> OnDataChangedOnce;
        public event Action<T, T> OnDataChangedDelta;


        public bool IsSubscribed => (OnDataChanged != null && OnDataChanged.GetInvocationList().Length > 0) || (OnDataChangedOnce != null && OnDataChangedOnce.GetInvocationList().Length > 0);
        public virtual bool IsDirty { get; protected set; }

        public Notifier(in Action onChanged = null, in Action<T> changed = null)
        {
            OnChanged = onChanged;
            OnDataChanged = changed;
            OnDataChanged += SetDirty;

            void SetDirty(T next)
            {
                IsDirty = true;
            }
        }

        public Notifier(in T value) : this()
        {
            this.value = value;
        }

        public Notifier(in T value, in EqualityComparer<T> overrideComparer) : this(value)
        {
            this.overrideComparer = overrideComparer;
        }

        public bool GetDirtyValue(out T value)
        {
            value = this.value;
            return IsDirty;
        }

        public void SetPristine()
        {
            IsDirty = false;
        }

        public override string ToString() => value.ToString();
    }

    public static class NotifierExtension
    {
        public static bool GetDirtyAndClear<T>(this Notifier<T> notifier, out T value)
        {
            var isDirty = notifier.GetDirtyValue(out value);
            notifier.SetPristine();

            return isDirty;
        }
    }

}