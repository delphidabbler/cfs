{
 * FrHTMLClipViewer.pas
 *
 * Implements a viewer frame that displays HTML clips, including information
 * about the clip and the clip's properties.
 *
 * v1.0 of 10 Mar 2008  - Original version.
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
 * The Original Code is FrHTMLClipViewer.pas.
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


unit FrHTMLClipViewer;


interface


uses
  // Delphi
  Controls, StdCtrls, Classes, ActnList, Menus, OleCtrls, SHDocVw, ExtCtrls,
  // Project
  FrHTMLViewer, UHTMLClip;


type

  {
  THTMLClipViewerFrame:
    Viewer frame that displays HTML clips, including information about the clip
    and the clip's properties. Uses a default style sheet loaded from resources
    when displaying HTML. Supports selecting and copying of selections of
    HTML document to clipboard as text, HTML and rich text.
  }
  THTMLClipViewerFrame = class(THTMLViewerFrame)
    pnlProperties: TPanel;
    lblVersionCaption: TLabel;
    lblContextCaption: TLabel;
    lblFragment: TLabel;
    lblVersion: TLabel;
    lblContext: TLabel;
    lblFragmentCaption: TLabel;
    lblSelection: TLabel;
    lblSelectionCaption: TLabel;
    lblURLCaption: TLabel;
    lblURL: TLabel;
  public
    procedure Display(const Clip: THTMLClip);
      {Displays information about an HTML clip, including the clip's properties
      and contained HTML.
        @param Clip [in] Object containing details of the clip's properties and
          HTML.
      }
  end;


implementation


uses
  // Project
  SysUtils;


{$R *.dfm}

{ THTMLClipViewerFrame }

procedure THTMLClipViewerFrame.Display(const Clip: THTMLClip);
  {Displays information about an HTML clip, including the clip's properties and
  contained HTML.
    @param Clip [in] Object containing details of the clip's properties and
      HTML.
  }
resourcestring
  // Messages displayed in properties pane
  sNoProperty = 'Not specified';
  sSectionInfo = 'Offset %0:d, Length %0.d';
begin
  // Display clip properties
  // version: always present
  lblVersion.Caption := Clip.Version;
  // context: may be missing
  if Clip.Context.IsPresent then
    lblContext.Caption := Format(
      sSectionInfo, [Clip.Context.StartPos, Clip.Context.Size]
    )
  else
    lblContext.Caption := sNoProperty;
  // fragment: always present
  lblFragment.Caption := Format(
    sSectionInfo, [Clip.Fragment.StartPos, Clip.Fragment.Size]
  );
  // selection: may be missing
  if Clip.Selection.IsPresent then
    lblSelection.Caption := Format(
      sSectionInfo, [Clip.Selection.StartPos, Clip.Selection.Size]
    )
  else
    lblSelection.Caption := sNoProperty;
  // source url: may be missing
  if Clip.SourceURL <> '' then
    lblURL.Caption := Clip.SourceURL
  else
    lblURL.Caption := sNoProperty;
  // Display HTML
  inherited Display(Clip.DisplayHTML);
end;

end.

