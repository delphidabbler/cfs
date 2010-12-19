object ObjDescViewerFrame: TObjDescViewerFrame
  Left = 0
  Top = 0
  Width = 463
  Height = 161
  TabOrder = 0
  object pnlView: TPanel
    Left = 0
    Top = 0
    Width = 463
    Height = 161
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object sbView: TScrollBox
      Left = 0
      Top = 0
      Width = 463
      Height = 161
      Align = alClient
      BorderStyle = bsNone
      TabOrder = 0
      DesignSize = (
        463
        161)
      object lblClassID: TLabel
        Left = 8
        Top = 12
        Width = 31
        Height = 13
        Caption = 'CLSID'
      end
      object lblDrawAspect: TLabel
        Left = 8
        Top = 36
        Width = 61
        Height = 13
        Caption = 'Draw Aspect'
      end
      object lblSize: TLabel
        Left = 8
        Top = 60
        Width = 54
        Height = 13
        Caption = 'Object Size'
      end
      object lblStatus: TLabel
        Left = 8
        Top = 84
        Width = 58
        Height = 13
        Caption = 'Status Flags'
      end
      object lblFullUserTypeName: TLabel
        Left = 8
        Top = 108
        Width = 99
        Height = 13
        Caption = 'Full User Type Name'
      end
      object lblSrcOfCopy: TLabel
        Left = 8
        Top = 132
        Width = 75
        Height = 13
        Caption = 'Source Of Copy'
      end
      object edCLSID: TEdit
        Left = 116
        Top = 8
        Width = 229
        Height = 21
        TabStop = False
        ParentColor = True
        PopupMenu = mnuView
        ReadOnly = True
        TabOrder = 0
      end
      object edDrawAspect: TEdit
        Left = 116
        Top = 32
        Width = 229
        Height = 21
        TabStop = False
        ParentColor = True
        PopupMenu = mnuView
        ReadOnly = True
        TabOrder = 1
      end
      object edSize: TEdit
        Left = 116
        Top = 56
        Width = 229
        Height = 21
        TabStop = False
        ParentColor = True
        PopupMenu = mnuView
        ReadOnly = True
        TabOrder = 2
      end
      object edStatus: TEdit
        Left = 116
        Top = 80
        Width = 37
        Height = 21
        TabStop = False
        ParentColor = True
        PopupMenu = mnuView
        ReadOnly = True
        TabOrder = 3
      end
      object edFullUserTypeName: TEdit
        Left = 116
        Top = 104
        Width = 341
        Height = 21
        TabStop = False
        Anchors = [akLeft, akTop, akRight]
        ParentColor = True
        PopupMenu = mnuView
        ReadOnly = True
        TabOrder = 4
      end
      object edSrcOfCopy: TEdit
        Left = 116
        Top = 128
        Width = 341
        Height = 21
        TabStop = False
        Anchors = [akLeft, akTop, akRight]
        ParentColor = True
        PopupMenu = mnuView
        ReadOnly = True
        TabOrder = 5
      end
    end
  end
  object alView: TActionList
    Left = 368
    Top = 8
    object actCopy: TEditCopy
      Category = 'Edit'
      Caption = 'Copy'
      ShortCut = 16451
    end
    object actSelectAll: TEditSelectAll
      Category = 'Edit'
      Caption = 'Select All'
      ShortCut = 16449
    end
  end
  object mnuView: TPopupMenu
    Left = 400
    Top = 8
    object miCopy: TMenuItem
      Action = actCopy
    end
    object miSelectAll: TMenuItem
      Action = actSelectAll
    end
  end
end
