using System.Collections;
using System.Collections.Generic;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.Localization.Reporting;
using UnityEditor.Localization;
using UnityEditor.Localization.Plugins.Google;
#endif

public class LocalizationUtil : MonoBehaviour
{
#if UNITY_EDITOR
    [MenuItem("Localization/��Ʈ�� ��Ʈ ������Ʈ")]

    public static void PullAllExtensions()
    {
        // Get every String Table Collection
        var stringTableCollections = LocalizationEditorSettings.GetStringTableCollections();

        foreach (var collection in stringTableCollections)
        {
            // Its possible a String Table Collection may have more than one GoogleSheetsExtension.
            // For example if each Locale we pushed/pulled from a different sheet.
            foreach (var extension in collection.Extensions)
            {
                if (extension is GoogleSheetsExtension googleExtension)
                {
                    PullExtension(googleExtension);
                }
            }
        }
    }

    static void PullExtension(GoogleSheetsExtension googleExtension)
    {
        // Setup the connection to Google
        var googleSheets = new GoogleSheets(googleExtension.SheetsServiceProvider);
        googleSheets.SpreadSheetId = googleExtension.SpreadsheetId;

        // Now update the collection. We can pass in an optional ProgressBarReporter so that we can updates in the Editor.
        googleSheets.PullIntoStringTableCollection(googleExtension.SheetId, googleExtension.TargetCollection as StringTableCollection, googleExtension.Columns, reporter: new ProgressBarReporter());
    }
#endif
}

