{
 * UPlatform.pas
 *
 * Provides OS platform specific information and customisations.
 *
 * v1.0 of 19 Jun 2008  - Original version.
 *
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
 * The Original Code is UPlatform.pas
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2008 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s): None
 *
 * ***** END LICENSE BLOCK *****
}


unit UPlatform;


interface


function IsVistaOrLater: Boolean;
  {Checks if the underlying operating system is Windows Vista or later. Ignores
  any OS emulation.
    @return True if OS is Vista or later or False if not.
  }

function IsXPOrLater: Boolean;
  {Checks if the underlying operating system is Windows XP or later. Ignores
  any OS emulation.
    @return True if OS is XP or later or False if not.
  }

implementation


uses
  // Delphi
  Windows;


function CheckForKernelFn(const FnName: string): Boolean;
  {Checks if a specified function exists in OSs kernel.
    @param FnName [in] Name of required function.
    @return True if function is present in kernel, false if not.
  }
const
  cKernelDLL = 'kernel32.dll';  // name of kernel DLL
var
  PFunction: Pointer; // pointer to required function if exists
begin
  // Try to load GetProductInfo func from Kernel32: present if Vista
  PFunction := GetProcAddress(GetModuleHandle(cKernelDLL), PChar(FnName));
  Result := Assigned(PFunction);
end;

function IsVistaOrLater: Boolean;
  {Checks if the underlying operating system is Windows Vista or later. Ignores
  any OS emulation.
    @return True if OS is Vista or later or False if not.
  }
begin
  // The "GetProductInfo" API function only exists in the kernel of Vista and
  // Win 2008 server and later
  Result := CheckForKernelFn('GetProductInfo');
end;

function IsXPOrLater: Boolean;
  {Checks if the underlying operating system is Windows XP or later. Ignores
  any OS emulation.
    @return True if OS is XP or later or False if not.
  }
begin
  // The "ActivateActCtx" API function only exists in the kernel of XP and Win
  // 2003 server and later
  Result := CheckForKernelFn('ActivateActCtx');
end;

end.

