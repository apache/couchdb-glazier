using System;
using System.Collections.Generic;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using Microsoft.Deployment.WindowsInstaller;

namespace CustomAction
{
   public class CustomActions
   {
      [CustomAction] public static ActionResult WriteAdminIniFile(Session session)
      {
         try
         {
            if (!File.Exists(session.CustomActionData["ADMINCONFIGFILE"])) {
               using (StreamWriter writer = new StreamWriter(session.CustomActionData["ADMINCONFIGFILE"]))
               {
                  writer.WriteLine("; CouchDB Windows installer-generated admin user");
                  writer.WriteLine("[admins]");
                  writer.WriteLine($"{session.CustomActionData["ADMINUSER"]} = {session.CustomActionData["ADMINPASSWORD"]}");
               }
            }
         }
         catch (Exception ex)
         {
            session.Log("ERROR in custom action WriteAdminIniFile {0}",
                  ex.ToString());
            return ActionResult.Failure;
         }

         return ActionResult.Success;
      }

      [CustomAction] public static ActionResult MaybeCopyIniFiles(Session session)
      {
         try
         {
            string[] files = new string[2];
            files[0] = "vm.args";
            files[1] = "local.ini";

            foreach (string file in files)
            {
               if (!File.Exists(Path.Combine(session.CustomActionData["ETCDIR"], file)))
               {
                  File.Copy(
                        Path.Combine(session.CustomActionData["ETCDIR"], file + ".dist"),
                        Path.Combine(session.CustomActionData["ETCDIR"], file)
                        );
               }
            }
         }
         catch (Exception ex)
         {
            session.Log("ERROR in custom action MaybeCopyIniFiles {0}",
                  ex.ToString());
            return ActionResult.Failure;
         }
         return ActionResult.Success;
      }

      [CustomAction] public static ActionResult MaybeRemoveUserConfig(Session session)
      {
         try
         {
            string[] files = new string[2];
            files[0] = "vm.args";
            files[1] = "local.ini";

            foreach (string file in files)
            {
               if (File.Exists(Path.Combine(session.CustomActionData["ETCDIR"], file)) &&
                     File.Exists(Path.Combine(session.CustomActionData["ETCDIR"], file + ".dist")))
               {
                  if (GetChecksum(Path.Combine(session.CustomActionData["ETCDIR"], file)) ==
                        GetChecksum(Path.Combine(session.CustomActionData["ETCDIR"], file + ".dist")))
                  {
                     File.Delete(Path.Combine(session.CustomActionData["ETCDIR"], file));
                  }
               }
            }
         }
         catch (Exception ex)
         {
            session.Log("ERROR in custom action MaybeRemoveUserConfig {0}",
                  ex.ToString());
            return ActionResult.Failure;
         }
         return ActionResult.Success;
      }

      private static string GetChecksum(string file)
      {
         using (FileStream stream = File.OpenRead(file))
         {
            SHA256Managed sha = new SHA256Managed();
            byte[] checksum = sha.ComputeHash(stream);
            return BitConverter.ToString(checksum).Replace("-", String.Empty);
         }
      }
   }
}
