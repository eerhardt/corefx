// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

namespace System.Text
{
    // This is the enumeration for Normalization Forms
#if INTERNAL_GLOBALIZATION_EXTENSIONS
    internal
#else
    public
#endif
    enum NormalizationForm
    {
        FormC = 1,
        FormD = 2,
        FormKC = 5,
        FormKD = 6
    }
}
