using System;
using System.Globalization;
using System.IO;
using System.Text;

public class C {

    public static void Main(string[] args) {
       Console.WriteLine(GetHexString(args[0]));
    }

  // https://stackoverflow.com/a/2886013/180275
    static string GetHexString(string assemblyPath) {

        if (!Path.IsPathRooted(assemblyPath)) {
            assemblyPath = Path.Combine(Environment.CurrentDirectory, assemblyPath);
        }

        StringBuilder builder = new StringBuilder();
        builder.Append("0x");

        using (FileStream stream = new FileStream(assemblyPath, FileMode.Open, FileAccess.Read, FileShare.Read)) {

            int currentByte = stream.ReadByte();

            while (currentByte > -1) {
                builder.Append(currentByte.ToString("X2", CultureInfo.InvariantCulture));
                currentByte = stream.ReadByte();
            }
        }

        return builder.ToString();
    }

}
