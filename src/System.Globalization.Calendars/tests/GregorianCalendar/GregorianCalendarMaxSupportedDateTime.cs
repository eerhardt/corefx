// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

using System;
using System.Globalization;
using Xunit;

namespace System.Globalization.CalendarTests
{
    // GregorianCalendar.MaxSupportedDateTime
    public class GregorianCalendarMaxSupportedDateTime
    {
        #region Positive tests        
        [Fact]
        public void PosTest1()
        {
            PosTest(GregorianCalendarTypes.Arabic);
        }

        [Fact]
        public void PosTest2()
        {
            PosTest(GregorianCalendarTypes.Localized);
        }

        [Fact]
        public void PosTest3()
        {
            PosTest(GregorianCalendarTypes.MiddleEastFrench);
        }

        [Fact]
        public void PosTest4()
        {
            PosTest(GregorianCalendarTypes.TransliteratedEnglish);
        }

        [Fact]
        public void PosTest5()
        {
            PosTest(GregorianCalendarTypes.TransliteratedFrench);
        }

        [Fact]
        public void PosTest6()
        {
            PosTest(GregorianCalendarTypes.USEnglish);
        }


        // PosTest: Get the MaxSupportedDateTime of Gregorian calendar
        private void PosTest(GregorianCalendarTypes calendarType)
        {
            System.Globalization.Calendar myCalendar = new GregorianCalendar(calendarType);
            DateTime expectedTime, actualTime;
            expectedTime = DateTime.MaxValue;
            actualTime = myCalendar.MaxSupportedDateTime;
            Assert.Equal(expectedTime, actualTime);
        }
        #endregion
    }
}
