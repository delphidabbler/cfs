{
 * IntfViewers.pas
 *
 * Interfaces, class references and exception used in implementing clipboard
 * viewer objects, list of such object and regsitration of clipboard viewer with
 * the program.
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
 * The Original Code is IntfViewers.pas.
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


unit IntfViewers;


interface


{
  Implementation note:

  To add a new clipboard viewer do the following:
    + Create a class that supports IInterface and IViewer.
    + Create a frame that is used to display the view and return its class
      reference from IViewer.UIFrameClass.
    + Render a data copy of the view in IViewer.RenderClipData and persist this
      data until IViewer.ReleaseClipData is called.
    + Pass the data to the frame when IViewer.RenderView is called. The class of
      the frame passed to this method will be the one returned from
      IViewer.UIFrameClass.
    + IViewer.SupportsFormat should return true when the viewer supports a
      specified format and false otherwise.
    + IViewer.IsPrimaryViewer should return true if this viewer is the primary
      viewer for this format. Return false if the viewer is secondary viewer.
      Never register a viewer as primary for a clipboard format that already has
      a primary viewer.
    + IViewer.MenuText should return the text to display in menus used to
      display the viewer. This text may be format dependent.
    + Register the viewer by calling IViewRegistrar.RegisterViewer in the viewer
      unit's initialization section.
    + The is no need to implement any other interfaces in this unit.
}


uses
  // Delphi
  SysUtils, Forms;


type

  {
  TFrameClass:
    Class reference to TFrame and descendants.
  }
  TFrameClass = class of TFrame;

  {
  IViewer:
    Interface supported by object that can render a view of a clipboard and
    display it in a frame.
  }
  IViewer = interface(IInterface)
    ['{C3821CC1-60BB-4417-97D5-6D7C0C0AF5FE}']
    function SupportsFormat(const FmtID: Word): Boolean;
      {Checks whethe viewer supports a clipboard format. Note: if this method
      returns true no other methods of this interface are queried.
        @param FmtID [in] ID of required clipboard format.
        @return True if format is supported, False if not.
      }
    function IsPrimaryViewer(const FmtID: Word): Boolean;
      {Checks if the viewer is the "primary" viewer for a clipboard format.
        @param FmtID [in] ID of required clipboard format.
        @return True if the viewer is a primary viewer, False if it is a 2ndary
          viewer.
      }
    function MenuText(const FmtID: Word): string;
      {Gets text to display in viewer menu for a specified clipboard format.
        @param FmtID [in] ID of required clipboard format.
        @return Required menu text.
      }
    procedure RenderClipData(const FmtID: Word);
      {Instructs viewer to read data for a specified format from the clipboard
      and render the data in a format suitable for display. The formatted data
      must remain available until ReleaseClipData is called.
        @param FmtID [in] ID of clipboard format to be rendered.
      }
    procedure ReleaseClipData;
      {Instructs viewer that it can free the data rendered when RenderClipData
      was last called. Note: There must always be a call to ReleaseClipData for
      every call to RenderClipData once the rendered data is no longer needed.
      }
    procedure RenderView(const Frame: TFrame);
      {Instructs viewer to display the rendered clipboard data in a frame. The
      data to be displayed will be that rendered when RenderClipData was last
      called. The caller must guarantee to call RenderClipData before calling
      RenderView. The view should be rendered in such a way that the rendered
      data may be destroyed: i.e. the view must not require access to the
      rendered data once this method has returned.
        @param Frame [in] Frame in which to display the data.
      }
    function UIFrameClass: TFrameClass;
      {Gets the class type of the viewer frame used by the viewer to display
      rendered data. The class type must be a TFrame descendant and must have a
      standard constructor.
        @return Required frame class.
      }
  end;

  {
  IViewerList:
    Interface to list of clipboard viewer objects.
  }
  IViewerList = interface(IInterface)
    ['{83E11DE7-57F5-4879-95C5-3C931996B56B}']
    function Count: Integer;
      {Gets number of viewers in list.
        @return Required number of viewers.
      }
    function GetItem(Idx: Integer): IViewer;
      {Gets a viewer from the viewer list.
        @param Idx [in] Index of required viewer in list.
        @return Reference to requested viewer object.
      }
    property Items[Idx: Integer]: IViewer read GetItem; default;
      {Indexed list of viewers}
  end;

  {
  IViewers:
    Interface to objects that can query the list of registered clipboard
    viewers.
  }
  IViewers = interface(IInterface)
    ['{4EE9FF36-A573-4615-8A32-CDEEAE2E6175}']
    function GetViewerList(const FmtID: Word): IViewerList;
      {Gets a list of viewers that support a clipboard format. Viewers must have
      been registered via IViewRegistrar.RegisterViewer.
        @param FmtID [in] ID of clipboard format.
        @return List of matching viewers.
      }
  end;

  {
  IViewRegistrar:
    Interface to object that can register a clipboard viewer.
  }
  IViewRegistrar = interface(IInterface)
    ['{D3CE64E2-ACC9-496D-947D-556415F41115}']
    procedure RegisterViewer(const Viewer: IViewer);
      {Registers a viewer with the program. This method should be called once
      for each available viewer.
        @param Viewer [in] Viewer to be registered.
      }
  end;

  {
  EViewer:
    Class of exception raised by viewer objects.
  }
  EViewer = class(Exception);


implementation

end.

