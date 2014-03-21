{
 * ULocale.pas
 *
 * Gets information about a locale in an operating system safe way. Works around
 * bugs in various different OSs.
 *
 * $Rev$
 * $Date$
 *
 * ***** BEGIN LICENSE BLOCK *****
 *
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * The Original Code is ULocale.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2008-2014 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s): None
 *
 * ***** END LICENSE BLOCK *****
}


unit ULocale;


interface


uses
  // Delphi
  Windows;


function GetLocaleData(const LocaleID: LCID; const InfoType: LCTYPE;
  out Info: string): Integer;
  {Query the OS for information for a specified locale. Use in preference to
  calling the GetLocaleInfo function directly since it accommodates various bugs
  in the GetLocaleInfo API function.
    @param LocaleID [in] ID of locale being queried.
    @param InfoType [in] Type of information required. Must be one of LOCALE_
      LCTYPE flags.
    @param Info [out] Required information as a string. If one of the LOCALE_I*
      flags was specified, this is a hex value. If LocaleID or InfoType are
      unsupported then sUnknown, defined in SysConst, is returned.
    @return 0 on success or Windows error code on failure.
  }


implementation


uses
  // Delphi
  SysUtils, SysConst;


const
  // LCTYPE defined in Windows Vista and later
  LOCALE_SNAME = $0000005C; // locale name (eg: en-us)


type
  {
  TGetLocaleInfoEx:
    Type of GetLocaleInfoEx function in Kernel32. Retrieves information about a
    locale specified by name. Should be used in preference to GetLocaleInfo on
    Windows Vista and later since GetLocaleInfo can be buggy on these OSs.
      @param lpLocaleName [in] Name of locale based on language tagging
        conventions of RFC 4646.
      @param LCType [in] Type of locale information to retrieve.
      @param lpLCData [in] Pointer to buffer to receive information. May be nil
        if cchData is 0.
      @param cchData [in] Size, in WideChars, of the data buffer pointed to by
        lpLCData. Can be 0 to get required buffer size.
      @return Number of WideChars stored in lpLCData if cchData is non-zero,
        size of data buffer required if cchData is zero and 0 if function fails.
  }
  TGetLocaleInfoEx = function(lpLocaleName: PWideChar; LCType: LCTYPE;
    lpLCData: PWideChar; cchData: Integer): Integer; stdcall;

var
  GetLocaleInfoEx: TGetLocaleInfoEx = nil;
    {Pointer to GetLocaleInfoEx function in Kernel32. Nil if the function is
    not supported}


function GetLocaleDataW(const LocaleID: LCID; const InfoType: LCTYPE;
  out Info: string): Integer;
  {Query the OS for information for a specified locale. Unicode version.
  According to SysUtils, this is needed to works correctly on Asian WinNT.
    @param LocaleID [in] ID of locale being queried.
    @param InfoType [in] Type of information required. Must be one of LOCALE_
      LCTYPE flags.
    @param Info [out] Required information as a string. If one of the LOCALE_I*
      flags was specified, this is a hex value. If LocaleID or InfoType are
      unsupported then sUnknown, defined in SysConst, is returned.
    @return 0 on success or Windows error code on failure.
  }
var
  Data: array[0..1023] of WideChar; // receives information from OS
begin
  Data[0] := #0;
  if GetLocaleInfoW(
    LocaleID, InfoType, Data, SizeOf(Data) div SizeOf(WideChar)
  ) <> 0 then
  begin
    Result := 0;
    Info := Data; // silently converts to string
  end
  else
  begin
    Result := GetLastError;
    Info := SysConst.sUnknown;
  end;
end;

function GetLocaleDataA(const LocaleID: LCID; const InfoType: LCTYPE;
  out Info: string): Integer;
  {Query the OS for information for a specified locale. ANSI version. According
  to SysUtils, this is needed to works correctly on Asian Win95.
    @param LocaleID [in] ID of locale being queried.
    @param InfoType [in] Type of information required. Must be one of LOCALE_
      LCTYPE flags.
    @param Info [out] Required information as a string. If one of the LOCALE_I*
      flags was specified, this is a hex value. If LocaleID or InfoType are
      unsupported then sUnknown, defined in SysConst, is returned.
    @return 0 on success or Windows error code on failure.
  }
var
  Data: array[0..1023] of AnsiChar; // receives information from OS
  DataSize: Integer;                // size of data returned from OS
begin
  Data[0] := #0;
  DataSize := GetLocaleInfoA(LocaleID, InfoType, Data, SizeOf(Data));
  if DataSize <> 0 then
  begin
    Result := 0;
    SetString(Info, Data, DataSize - 1)
  end
  else
  begin
    Result := GetLastError;
    Info := SysConst.sUnknown;
  end;
end;

function GetLocaleDataEx(const LocaleID: LCID; const InfoType: LCTYPE;
  out Info: string): Integer;
  {Query the OS for information for a specified locale by name. According to
  MSDN this method is preferred on Vista or later since GetLocaleInfo() API
  function can provide erroneous information on Vista.
    @param LocaleID [in] ID of locale being queried.
    @param InfoType [in] Type of information required. Must be one of LOCALE_
      LCTYPE flags.
    @param Info [out] Required information as a string. If one of the LOCALE_I*
      flags was specified, this is a hex value. If LocaleID or InfoType are
      unsupported then sUnknown, defined in SysConst, is returned.
    @return 0 on success or Windows error code on failure.
  }
var
  Data: array[0..1023] of WideChar; // receives information from OS
  LocaleName: string;               // name of locale
begin
  // Get locale name: using LOCALE_SNAME using GetLocaleInfo() (via
  // GetLocaleDataW) is safe on Vista according to MSDN.
  GetLocaleDataW(LocaleID, LOCALE_SNAME, LocaleName);
  // Having locale name we can use the new GetLocaleInfoEx() API function
  if GetLocaleInfoEx(
    PWideChar(WideString(LocaleName)),
    InfoType,
    Data,
    SizeOf(Data) div SizeOf(WideChar)
  ) <> 0 then
  begin
    Result := 0;
    Info := Data; // silently converts to string
  end
  else
  begin
    Result := GetLastError;
    Info := SysConst.sUnknown;
  end;
end;

function GetLocaleData(const LocaleID: LCID; const InfoType: LCTYPE;
  out Info: string): Integer;
  {Query the OS for information for a specified locale. Use in preference to
  calling the GetLocaleInfo function directly since it accommodates various bugs
  in the GetLocaleInfo API function.
    @param LocaleID [in] ID of locale being queried.
    @param InfoType [in] Type of information required. Must be one of LOCALE_
      LCTYPE flags.
    @param Info [out] Required information as a string. If one of the LOCALE_I*
      flags was specified, this is a hex value. If LocaleID or InfoType are
      unsupported then sUnknown, defined in SysConst, is returned.
    @return 0 on success or Windows error code on failure.
  }
begin
  if Assigned(GetLocaleInfoEx) then
    // GetLocaleInfoEx() is available so use it: Vista and later
    Result := GetLocaleDataEx(LocaleID, InfoType, Info)
  else if Win32Platform = VER_PLATFORM_WIN32_NT then
    // Use Unicode version of GetLocaleInfo(): NT platform
    Result := GetLocaleDataW(LocaleID, InfoType, Info)
  else
    // Use ANSI version of GetLocaleInfo(): Win9x platform
    Result := GetLocaleDataA(LocaleID, InfoType, Info);
end;


initialization

// Try to load GetLocaleInfoEx function (Vista and later)
@GetLocaleInfoEx := GetProcAddress(
  GetModuleHandle('kernel32.dll'), 'GetLocaleInfoEx'
);


end.

