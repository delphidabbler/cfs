{
 * UViewers.pas
 *
 * Implements singleton Viewers object that supports IViewers interface that
 * provides access to list of registered viewers and IViewRegistrar that enables
 * viewers to be registered. Also provides an implementation of IViewerList.
 *
 * v1.0 of 11 Mar 2008  - Original version.
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
 * The Original Code is UViewers.pas.
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


unit UViewers;


interface


uses
  // Project
  IntfViewers;


function Viewers: IViewers;
  {Gets reference to global list of registered viewers.
    @return Reference to viewer list.
  }

function ViewerRegistrar: IViewRegistrar;
  {Gets reference to object used to register viewers with the global list.
    @return Reference to registrar object.
  }


implementation


uses
  // Delphi
  SysUtils, Classes;


type

  {
  TViewers:
    Maintains a list of reqistered viewers and interogates the list to find
    which viewers support which clipboard formats.
  }
  TViewers = class(TInterfacedObject, IViewers, IViewRegistrar)
  private
    fList: TInterfaceList;
      {Stores list of viewer objects}
    function GetViewer(const Idx: Integer): IViewer;
      {Gets a registered viewer by index.
        @param Idx [in] Index of registered viewer.
        @return Reference to require viewer.
      }
  protected
    { IViewers }
    function GetViewerList(const Fmt: Word): IViewerList;
      {Gets a list of viewers that support a clipboard format.
        @param Fmt [in] ID of clipboard format.
        @return List of matching viewers.
      }
    { IViewRegistrar }
    procedure RegisterViewer(const Viewer: IViewer);
      {Registers a viewer with the program. This method should be called once
      for each available viewer.
        @param Viewer [in] Viewer to be registered.
      }
  public
    constructor Create;
      {Class constructor. Sets up object.
      }
    destructor Destroy; override;
      {Class destructor. Tears down object.
      }
  end;

  {
  TViewerList:
    Maintains an imutable list of viewer objects.
  }
  TViewerList = class(TInterfacedObject, IViewerList)
  private
    fList: TInterfaceList;
      {Maintains list of selected viewer objects}
  protected
    { IViewerList }
    function Count: Integer;
      {Gets number of viewers in list.
        @return Required number of viewers.
      }
    function GetItem(Idx: Integer): IViewer;
      {Gets a viewer from the viewer list.
        @param Idx [in] Index of required viewer in list.
        @return Reference to requested viewer object.
      }
  public
    constructor Create(const List: TInterfaceList);
      {Class constructor. Creates list of viewers from given list.
        @param List [in] List of viewers to store in list.
      }
    destructor Destroy; override;
      {Class destructor. Tears down object.
      }
  end;

var
  // Reference to global viewer list
  pvtViewers: IViewers;

function Viewers: IViewers;
  {Gets reference to global list of registered viewers.
    @return Reference to viewer list.
  }
begin
  Result := pvtViewers as IViewers;
end;

function ViewerRegistrar: IViewRegistrar;
  {Gets reference to object used to register viewers with the global list.
    @return Reference to registrar object.
  }
begin
  Result := pvtViewers as IViewRegistrar;
end;

{ TViewers }

constructor TViewers.Create;
  {Class constructor. Sets up object.
  }
begin
  inherited Create;
  fList := TInterfaceList.Create;
end;

destructor TViewers.Destroy;
  {Class destructor. Tears down object.
  }
begin
  FreeAndNil(fList);
  inherited;
end;

function TViewers.GetViewer(const Idx: Integer): IViewer;
  {Gets a registered viewer by index.
    @param Idx [in] Index of registered viewer.
    @return Reference to require viewer.
  }
begin
  Result := fList[Idx] as IViewer;
end;

function TViewers.GetViewerList(const Fmt: Word): IViewerList;
  {Gets a list of viewers that support a clipboard format.
    @param Fmt [in] ID of clipboard format.
    @return List of matching viewers.
  }
var
  Idx: Integer;               // loops through registered viewers
  Viewer: IViewer;            // reference to a registered viewer
  ViewerList: TInterfaceList; // used to build list of found viewers
begin
  ViewerList := TInterfaceList.Create;
  try
    for Idx := 0 to Pred(fList.Count) do
    begin
      Viewer := GetViewer(Idx);
      if Viewer.SupportsFormat(Fmt) then
        ViewerList.Add(Viewer);
    end;
    Result := TViewerList.Create(ViewerList);
  finally
    FreeAndNil(ViewerList);
  end;
end;

procedure TViewers.RegisterViewer(const Viewer: IViewer);
  {Registers a viewer with the program. This method should be called once for
  each available viewer.
    @param Viewer [in] Viewer to be registered.
  }
begin
  if fList.IndexOf(Viewer) = -1 then
    fList.Add(Viewer);
end;

{ TViewerList }

function TViewerList.Count: Integer;
  {Gets number of viewers in list.
    @return Required number of viewers.
  }
begin
  Result := fList.Count;
end;

constructor TViewerList.Create(const List: TInterfaceList);
  {Class constructor. Creates list of viewers from given list.
    @param List [in] List of viewers to store in list. Each item in list must
      support IViewer.
  }
var
  Idx: Integer; // loops through provided list
begin
  inherited Create;
  fList := TInterfaceList.Create;
  for Idx := 0 to Pred(List.Count) do
  begin
    Assert(Supports(List[Idx], IViewer));
    fList.Add(List[Idx]);
  end;
end;

destructor TViewerList.Destroy;
  {Class destructor. Tears down object.
  }
begin
  FreeAndNil(fList);
  inherited;
end;

function TViewerList.GetItem(Idx: Integer): IViewer;
  {Gets a viewer from the viewer list.
    @param Idx [in] Index of required viewer in list.
    @return Reference to requested viewer object.
  }
begin
  Result := fList[Idx] as IViewer;
end;


initialization

// Create global viewer list
pvtViewers := TViewers.Create;


finalization

// Release global viewer list
pvtViewers := nil;

end.

