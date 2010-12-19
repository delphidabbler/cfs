object TextViewerFrame: TTextViewerFrame
  Left = 0
  Top = 0
  Width = 320
  Height = 240
  TabOrder = 0
  object edView: TMemo
    Left = 0
    Top = 0
    Width = 320
    Height = 207
    TabStop = False
    Align = alClient
    BorderStyle = bsNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    PopupMenu = mnuView
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
  end
  object pnlControl: TPanel
    Left = 0
    Top = 207
    Width = 320
    Height = 33
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object chkWordWrap: TCheckBox
      Left = 8
      Top = 8
      Width = 97
      Height = 17
      Caption = '&Word Wrap'
      TabOrder = 0
      OnClick = chkWordWrapClick
    end
  end
  object mnuView: TPopupMenu
    AutoHotkeys = maManual
    Left = 40
    Top = 16
    object miCopy: TMenuItem
      Action = actCopy
    end
    object miSelectAll: TMenuItem
      Action = actSelectAll
    end
  end
  object alView: TActionList
    Left = 72
    Top = 16
    object actCopy: TEditCopy
      Category = 'Edit'
      Caption = 'Copy'
      ImageIndex = 1
      ShortCut = 16451
    end
    object actSelectAll: TEditSelectAll
      Category = 'Edit'
      Caption = 'Select All'
      ShortCut = 16449
    end
  end
end
