using System;
using System.Collections.Generic;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using Microsoft.Deployment.WindowsInstaller;

namespace CustomAction
{
    public class CustomActions
    {
        [CustomAction]
        public static ActionResult InitCookieValue(Session session)
        {
            try
            {
                byte[] buffer = new byte[16];
                RandomNumberGenerator rng = RNGCryptoServiceProvider.Create();
                rng.GetBytes(buffer);
                session["COOKIEVALUE"] = BitConverter.ToString(buffer).Replace("-", String.Empty);
            }
            catch (Exception ex)
            {
                session.Log("ERROR in custom action InitCookieValue {0}",
                      ex.ToString());
                return ActionResult.Failure;
            }

            return ActionResult.Success;
        }
        [CustomAction]
        public static ActionResult WriteAdminIniFile(Session session)
        {
            try
            {
                if (!File.Exists(session.CustomActionData["ADMINCONFIGFILE"]))
                {
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

        [CustomAction]
        public static ActionResult WriteCookieToVmArgs(Session session)
        {
            try
            {
                string VMARGSFILE = Path.Combine(session.CustomActionData["ETCDIR"], "vm.args");
                if (File.Exists(VMARGSFILE))
                {
                    session.Log("Patching erlang cookie in existing vm.args file");
                    PatchErlangCookie(session, VMARGSFILE);
                }

                string VMFile = Path.Combine(session.CustomActionData["ETCDIR"], "vm.args.dist");
                byte[] VMBuffer = File.ReadAllBytes(VMFile);
                string VMText = Regex.Replace(Encoding.UTF8.GetString(VMBuffer), @"# -setcookie", $"-setcookie {session.CustomActionData["COOKIEVALUE"]}");
                File.WriteAllBytes(VMFile, Encoding.UTF8.GetBytes(VMText));
            }
            catch (Exception ex)
            {
                session.Log("ERROR in custom action WriteCookieToVmArgs {0}",
                      ex.ToString());
                return ActionResult.Failure;
            }

            return ActionResult.Success;
        }

        private static void PatchErlangCookie(Session session, string file)
        {
            //Patching erlang cookie
            byte[] VMBuffer = File.ReadAllBytes(file);
            string VMText = Regex.Replace(Encoding.UTF8.GetString(VMBuffer), @"-setcookie \S*", $"-setcookie {session.CustomActionData["COOKIEVALUE"]}");
            File.WriteAllBytes(file, Encoding.UTF8.GetBytes(VMText));
        }

        private static void PatchErlangInterface(Session session, string file)
        {
            byte[] VMBuffer = File.ReadAllBytes(file);

            //Patching erlang interface
            string pattern = @"-kernel inet_dist_use_interface";
            string input = Encoding.UTF8.GetString(VMBuffer);
            Match m = Regex.Match(input, pattern, RegexOptions.IgnoreCase);
            if (!m.Success)
            {
                session.Log("Pattern \"inet_dist_use_interface\" not found, appending fix.");

                using (StreamWriter sw = File.AppendText(file))
                {
                    sw.WriteLine();
                    sw.WriteLine("# Which interfaces should the node listen on?");
                    sw.WriteLine("-kernel inet_dist_use_interface {127,0,0,1}");
                    sw.Close();
                }
            }
            else
            {
                session.Log("Pattern \"inet_dist_use_interface\" found, skipping.");
            }
        }

        [CustomAction]
        public static ActionResult MaybeCopyIniFiles(Session session)
        {
            try
            {
                string[] files = new string[2];
                files[0] = "vm.args";
                files[1] = "local.ini";

                string VMARGSFILE = Path.Combine(session.CustomActionData["ETCDIR"], files[0]);

                if (File.Exists(VMARGSFILE))
                {
                    session.Log("Patching erlang interface in existing vm.args file");
                    PatchErlangInterface(session, VMARGSFILE);
                }

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

        [CustomAction]
        public static ActionResult MaybeRemoveUserConfig(Session session)
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
                SHA256CryptoServiceProvider sha = new SHA256CryptoServiceProvider();
                byte[] checksum = sha.ComputeHash(stream);
                return BitConverter.ToString(checksum).Replace("-", String.Empty);
            }
        }
    }
}
