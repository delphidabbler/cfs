{
 * UWindowSettings.pas
 *
 * Implements a static class that stores and retrieves window state settings.
 *
 * This unit requires the following DelphiDabbler components:
 *   - TPJUserWdwState Release 5.3 or later
 *
 * v1.0 of 09 Mar 2008  - Original version.
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
 * The Original Code is UWindowSettings.pas
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


unit UWindowSettings;


interface


uses
  // DelphiDabbler library
  PJWdwState;


type

  {
  TWindowSettings:
    Static class that stores and retrieves window state settings.
  }
  TWindowSettings = class(TObject)
  public
    class procedure Write(const WdwName: string; const Data: TPJWdwStateData);
      {Stores window state settings.
        @param WdwName [in] Name of window for which settings are being stored.
        @param Data [in] Window state data to store.
      }
    class procedure Read(const WdwName: string; var Data: TPJWdwStateData);
      {Reads window state settings.
        @param WdwName [in] Name of window for which settings required.
        @param Data [in/out] Set to window state data read from settings.
      }
  end;


implementation


uses
  // Project
  UGlobals, USettings;


{ TWindowSettings }

class procedure TWindowSettings.Read(const WdwName: string;
  var Data: TPJWdwStateData);
  {Reads window state settings.
    @param WdwName [in] Name of window for which settings required.
    @param Data [in/out] Set to window state data read from settings.
  }
var
  SettingsSection: ISettingsSection;  // settings section to save read from
begin
  SettingsSection := Settings.OpenSection(cWdwStateRegSubKey);
  SettingsSection.ReadBin(WdwName, Data, SizeOf(Data));
end;

class procedure TWindowSettings.Write(const WdwName: string;
  const Data: TPJWdwStateData);
  {Stores window state settings.
    @param WdwName [in] Name of window for which settings are being stored.
    @param Data [in] Window state data to store.
  }
var
  SettingsSection: ISettingsSection;  // settings section to save to
begin
  SettingsSection := Settings.OpenSection(cWdwStateRegSubKey);
  SettingsSection.WriteBin(WdwName, Data, SizeOf(Data));
end;

end.
