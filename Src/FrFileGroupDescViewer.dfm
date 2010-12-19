object FileGroupDescViewerFrame: TFileGroupDescViewerFrame
  Left = 0
  Top = 0
  Width = 320
  Height = 240
  TabOrder = 0
  object tvView: TTreeView
    Left = 0
    Top = 0
    Width = 320
    Height = 240
    Align = alClient
    BorderStyle = bsNone
    Indent = 19
    PopupMenu = mnuView
    ReadOnly = True
    TabOrder = 0
    TabStop = False
  end
  object mnuView: TPopupMenu
    AutoHotkeys = maManual
    Left = 56
    Top = 24
    object miCopy: TMenuItem
      Action = actCopy
    end
  end
  object alView: TActionList
    Left = 88
    Top = 24
    object actCopy: TAction
      Caption = 'Copy File Names'
      ShortCut = 16451
      OnExecute = actCopyExecute
      OnUpdate = actCopyUpdate
    end
  end
end
