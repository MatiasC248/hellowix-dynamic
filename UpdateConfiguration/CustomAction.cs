using Microsoft.Deployment.WindowsInstaller;
using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace UpdateConfiguration
{
    public class CustomActions
    {
        [CustomAction]
        public static ActionResult UpdateConfig(Session session) //, string fileName, string word, string replacement, string saveFileName)
        {
            string directory = "C:\\Users\\mcastorina\\source\\repos\\HelloWix\\HelloWix\\redist\\";
            string fileName = "config.txt";
            string word = "IDNUM=0";
            string replacement = "IDNUM=1";
            string saveFileName = "config2.txt";
            session.Log("Begin UpdateConfig");
            StreamReader reader = new StreamReader(directory + fileName);
            string input = reader.ReadToEnd();

            using (StreamWriter writer = new StreamWriter(directory + saveFileName, true))
            {
                {
                    string output = input.Replace(word, replacement);
                    writer.Write(output);
                }
                writer.Close();
            }
            return ActionResult.Success;
        }
    }
}
