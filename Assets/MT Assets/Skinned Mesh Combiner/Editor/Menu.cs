﻿using UnityEngine;
using UnityEditor;
using System.IO;

namespace MTAssets.SkinnedMeshCombiner.Editor
{

    /*
     * This class is responsible for creating the menu for this asset. 
     */

    public class Menu : MonoBehaviour
    {
        //Menu items

        [MenuItem("Tools/MT Assets/Skinned Mesh Combiner/View Changelog", false, 10)]
        static void OpenChangeLog()
        {
            string filePath = Greetings.pathForThisAsset + "/List Of Changes.txt";

            if (File.Exists(filePath) == true)
                AssetDatabase.OpenAsset(AssetDatabase.LoadAssetAtPath(filePath, typeof(TextAsset)));

            if (File.Exists(filePath) == false)
                EditorUtility.DisplayDialog(
                    "Error",
                    "Unable to open file. The file has been deleted, or moved. Please, to correct this problem and avoid future problems with this tool, remove the directory from this asset and install it again.",
                    "Ok");
        }

        [MenuItem("Tools/MT Assets/Skinned Mesh Combiner/Read Documentation", false, 30)]
        static void ReadDocumentation()
        {
            EditorUtility.DisplayDialog(
                  "Read Documentation",
                  "The Documentation HTML file will open in your default application.",
                  "Cool!");

            string filePath = Greetings.pathForThisAsset + Greetings.pathForThisAssetDocumentation;

            if (File.Exists(filePath) == true)
                AssetDatabase.OpenAsset(AssetDatabase.LoadAssetAtPath(filePath, typeof(TextAsset)));

            if (File.Exists(filePath) == false)
                EditorUtility.DisplayDialog(
                    "Error",
                    "Unable to open file. The file has been deleted, or moved. Please, to correct this problem and avoid future problems with this tool, remove the directory from this asset and install it again.",
                    "Ok");
        }

        [MenuItem("Tools/MT Assets/Skinned Mesh Combiner/More Assets", false, 30)]
        static void MoreAssets()
        {
            Help.BrowseURL(Greetings.linkForAssetStorePage);
        }

        [MenuItem("Tools/MT Assets/Skinned Mesh Combiner/Get Support", false, 30)]
        static void GetSupport()
        {
            EditorUtility.DisplayDialog(
                "Support",
                "If you have any questions, problems or want to contact me, just contact me by email (mtassets@windsoft.xyz).",
                "Got it!");
        }

        [MenuItem("Tools/MT Assets Community/Join MT Assets Community on Discord", false, 10)]
        static void JoinTheCommunity()
        {
            Help.BrowseURL(Greetings.linkForDiscordCommunity);
        }
    }
}