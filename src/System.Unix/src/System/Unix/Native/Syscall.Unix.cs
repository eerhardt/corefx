// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

namespace System.Unix.Native
{
    public static partial class Syscall
    {
        public static int chmod(string path, FilePermissions mode)
        {
            return Interop.Sys.ChMod(path, (int)mode);
        }
    }
}
