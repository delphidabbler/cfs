{
 * CFS.dpr
 *
 * Main project file for Clipboard Format Spy.
 *
 * v1.0 of 08 Mar 1997  - Original version, named CBInfo.dpr
 * v1.1 of 21 Jul 1997  - Added program title.
 * v2.0 of 07 Jul 1998  - Added Option_f, Opts, CBUtils, WdwOpts and WdwState
 *                        units.
 *                      - Renamed CBInfoFm unit as Main_f.
 *                      - Included Version.res resource.
 * v3.0 of 07 Dec 1999  - Removed WdwState, WdwOpts, Option_f and Opts units.
 *                      - Removed Version.res resource. Now automatically
 *                        include version information from project file.
 * v4.0 of 24 Mar 2008  - Renamed this file from CBInfo.dpr to CFS.dpr.
 *                      - Renamed Main_f unit as FmMain and CBUtils unit as
 *                        UCBUtils.
 *                      - Removed code that set application's help file.
 *                      - Prevented project automatically adding application
 *                        icon and version information to executable and
 *                        replaced with explicitly included Version.res and
 *                        Resources.res resource files.
 *                      - Added new FmAbout, FrBinaryViewer,
 *                        FrFileGroupDescViewer, FrFileListViewer,
 *                        FrFileNameViewer, FrGraphicViewer, FrHTMLClipViewer,
 *                        FrHTMLViewer, FrLocaleViewer, FrObjDescViewer,
 *                        FrRTFViewer, FrShellNameViewer, FrTextViewer,
 *                        FrURLViewer, FmViewer, IntfUIHandlers, IntfViewers,
 *                        UBaseTextViewer, UBinaryViewer, UBmpViewer,
 *                        UClipboardLVMgr, UClipFmt, UDataBuffer, UDIBViewer,
 *                        UFileGroupDescAdapter, UFileGroupDescViewer,
 *                        UFileLists, UFileNameViewer, UGlobalMemViewer,
 *                        UGlobals, UGraphicViewer, UHDROPViewer, UHelpManager,
 *                        UHTMLClip, UHTMLClipViewer, UHTMLDocViewer, UHTMLHelp,
 *                        UIDListViewer, UIntfObjects, ULocaleViewer,
 *                        UMessageBox, UMetafileViewer, UNulDropTarget,
 *                        UNulUIHandler, UObjDescAdapter, UObjDescViewer,
 *                        UOleClientSite, UProcessUtils, URTFViewer, USettings,
 *                        UShellNameViewer, UStatusBarMgr, UTextTypeSniffer,
 *                        UTextViewer, UURLViewer, UUtils, UViewerMenuMgr,
 *                        UViewers, UWBController and UWindowSettings units.
 *                      - Added third party IDLUtils unit.
 *                      - Added reference to TODO list.
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
 * The Original Code is CFS.dpr.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 1997-2008 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK *****
}


program CFS;

{%ToDo 'CFS.todo'}

uses
  Forms,
  FmAbout in 'FmAbout.pas' {AboutBox},
  FmMain in 'FmMain.pas' {MainForm},
  FmViewer in 'FmViewer.pas' {ViewerDlg},
  FrBinaryViewer in 'FrBinaryViewer.pas' {BinaryViewerFrame: TFrame},
  FrFileGroupDescViewer in 'FrFileGroupDescViewer.pas' {FileGroupDescViewerFrame: TFrame},
  FrFileListViewer in 'FrFileListViewer.pas' {FileListViewerFrame: TFrame},
  FrFileNameViewer in 'FrFileNameViewer.pas' {FileNameViewerFrame: TFrame},
  FrGraphicViewer in 'FrGraphicViewer.pas' {GraphicViewerFrame: TFrame},
  FrHTMLClipViewer in 'FrHTMLClipViewer.pas' {HTMLClipViewerFrame: TFrame},
  FrHTMLViewer in 'FrHTMLViewer.pas' {HTMLViewerFrame: TFrame},
  FrLocaleViewer in 'FrLocaleViewer.pas' {LocaleViewerFrame: TFrame},
  FrObjDescViewer in 'FrObjDescViewer.pas' {ObjDescViewerFrame: TFrame},
  FrRTFViewer in 'FrRTFViewer.pas' {RTFViewerFrame: TFrame},
  FrShellNameViewer in 'FrShellNameViewer.pas' {ShellNameViewerFrame: TFrame},
  FrTextViewer in 'FrTextViewer.pas' {TextViewerFrame: TFrame},
  FrURLViewer in 'FrURLViewer.pas' {URLViewerFrame: TFrame},
  IDLUtils in '3rdParty\IDLUtils.pas',
  IntfUIHandlers in 'IntfUIHandlers.pas',
  IntfViewers in 'IntfViewers.pas',
  UBaseTextViewer in 'UBaseTextViewer.pas',
  UBinaryViewer in 'UBinaryViewer.pas',
  UBmpViewer in 'UBmpViewer.pas',
  UCBUtils in 'UCBUtils.pas',
  UClipboardLVMgr in 'UClipboardLVMgr.pas',
  UClipFmt in 'UClipFmt.pas',
  UDataBuffer in 'UDataBuffer.pas',
  UDIBViewer in 'UDIBViewer.pas',
  UFileGroupDescAdapter in 'UFileGroupDescAdapter.pas',
  UFileGroupDescViewer in 'UFileGroupDescViewer.pas',
  UFileLists in 'UFileLists.pas',
  UFileNameViewer in 'UFileNameViewer.pas',
  UGlobalMemViewer in 'UGlobalMemViewer.pas',
  UGlobals in 'UGlobals.pas',
  UGraphicViewer in 'UGraphicViewer.pas',
  UHDROPViewer in 'UHDROPViewer.pas',
  UHelpManager in 'UHelpManager.pas',
  UHTMLClip in 'UHTMLClip.pas',
  UHTMLClipViewer in 'UHTMLClipViewer.pas',
  UHTMLDocViewer in 'UHTMLDocViewer.pas',
  UHTMLHelp in 'UHTMLHelp.pas',
  UIDListViewer in 'UIDListViewer.pas',
  UIntfObjects in 'UIntfObjects.pas',
  ULocaleViewer in 'ULocaleViewer.pas',
  UMessageBox in 'UMessageBox.pas',
  UMetafileViewer in 'UMetafileViewer.pas',
  UNulDropTarget in 'UNulDropTarget.pas',
  UNulUIHandler in 'UNulUIHandler.pas',
  UObjDescAdapter in 'UObjDescAdapter.pas',
  UObjDescViewer in 'UObjDescViewer.pas',
  UOleClientSite in 'UOleClientSite.pas',
  UProcessUtils in 'UProcessUtils.pas',
  URTFViewer in 'URTFViewer.pas',
  USettings in 'USettings.pas',
  UShellNameViewer in 'UShellNameViewer.pas',
  UStatusBarMgr in 'UStatusBarMgr.pas',
  UTextTypeSniffer in 'UTextTypeSniffer.pas',
  UTextViewer in 'UTextViewer.pas',
  UURLViewer in 'UURLViewer.pas',
  UUtils in 'UUtils.pas',
  UViewerMenuMgr in 'UViewerMenuMgr.pas',
  UViewers in 'UViewers.pas',
  UWBController in 'UWBController.pas',
  UWindowSettings in 'UWindowSettings.pas';

{$RESOURCE Resources.res}
{$RESOURCE Version.res}

begin
  Application.Title := 'Clipboard Format Spy';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

