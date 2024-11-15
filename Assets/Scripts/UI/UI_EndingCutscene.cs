using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

public class UI_EndingCutscene : StaticSerializedMonoBehaviour<UI_EndingCutscene>
{
    private PlayableDirector playable;
    private MainPlayerInputActions UI_Input;

    protected override void Awake()
    {
        base.Awake();
        playable = GetComponent<PlayableDirector>();
    }

    private void Start()
    {
        this.UI_Input = UI_InputManager.Instance.UI_Input;
    }

    public IEnumerator Cor_PlayEndingCutscene()
    {
        playable.Play();

        while (Mathf.Abs((float)(playable.time - playable.duration)) > 0.01f)
        {
            yield return new WaitUntil(() => playable.state != PlayState.Playing);

            yield return new WaitUntil(() => UI_Input.UI.Positive.IsPressed());
        }
    }

    public void PauseForTimeline()
    {
        playable.Pause();
    }
}
