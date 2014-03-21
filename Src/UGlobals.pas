{
 * UGlobals.pas
 *
 * Defines constants used throughout the application.
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
 * The Original Code is UGlobals.pas.
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


unit UGlobals;


interface


uses
  // Delphi
  Windows;


const
  // DelphiDabbler web address
  cWebAddress = 'http://www.delphidabbler.com/';

  // Registry keys
  // root key for settings
  cRegRootKey = HKEY_CURRENT_USER;
  // sub key under which all settings are recorded
  cRegKey = '\Software\DelphiDabbler\CFS\4';
  // relative key under which window states are saved
  cWdwStateRegSubKey = 'WindowSettings';


implementation

end.

