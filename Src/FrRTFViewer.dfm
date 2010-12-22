object RTFViewerFrame: TRTFViewerFrame
  Left = 0
  Top = 0
  Width = 320
  Height = 240
  TabOrder = 0
  object reView: TRichEdit
    Left = 0
    Top = 0
    Width = 320
    Height = 240
    TabStop = False
    Align = alClient
    BorderStyle = bsNone
    ParentFont = False
    PopupMenu = mnuView
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
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
