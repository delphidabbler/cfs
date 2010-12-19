object ShellNameViewerFrame: TShellNameViewerFrame
  Left = 0
  Top = 0
  Width = 320
  Height = 240
  TabOrder = 0
  object pnlView: TPanel
    Left = 0
    Top = 0
    Width = 320
    Height = 240
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      320
      240)
    object lblName: TLabel
      Left = 8
      Top = 20
      Width = 3
      Height = 13
    end
    object edName: TEdit
      Left = 72
      Top = 16
      Width = 241
      Height = 21
      TabStop = False
      Anchors = [akLeft, akTop, akRight]
      ParentColor = True
      PopupMenu = mnuView
      ReadOnly = True
      TabOrder = 0
    end
    object btnGo: TButton
      Left = 72
      Top = 48
      Width = 75
      Height = 25
      Action = actExec
      TabOrder = 1
    end
  end
  object alView: TActionList
    Left = 8
    Top = 80
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
    object actExec: TAction
      Caption = 'actExec'
      OnUpdate = actExecUpdate
    end
  end
  object mnuView: TPopupMenu
    Left = 40
    Top = 80
    object miCopy: TMenuItem
      Action = actCopy
    end
    object miSelectAll: TMenuItem
      Action = actSelectAll
    end
  end
end
