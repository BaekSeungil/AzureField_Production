using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Localization;
using UnityEngine.Localization.Settings;
using TMPro;
using UnityEditor;

public class LocalizeDropdown : MonoBehaviour
{
    [SerializeField] private List<LocalizedString> dropdownOptions;
    private TMP_Dropdown _tmpDropdown;

    private void Awake()
    {
        if (_tmpDropdown == null)
            _tmpDropdown = GetComponent<TMP_Dropdown>();

        LocalizationSettings.SelectedLocaleChanged += ChangedLocale;
    }

    private void ChangedLocale(Locale newLocale)
    {
        List<TMP_Dropdown.OptionData> tmpDropdownOptions = new List<TMP_Dropdown.OptionData>();
        foreach (var dropdownOption in dropdownOptions)
        {
            tmpDropdownOptions.Add(new TMP_Dropdown.OptionData(dropdownOption.GetLocalizedString()));
        }
        _tmpDropdown.options = tmpDropdownOptions;
    }
}

public abstract class AddLocalizeDropdown
{
    [MenuItem("CONTEXT/TMP_Dropdown/Localize", false, 1)]
    private static void AddLocalizeComponent()
    {
        // add localize dropdown component to selected gameobject
        GameObject selected = Selection.activeGameObject;
        if (selected != null)
        {
            selected.AddComponent<LocalizeDropdown>();
        }
    }
}