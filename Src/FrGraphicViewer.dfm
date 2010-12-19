object GraphicViewerFrame: TGraphicViewerFrame
  Left = 0
  Top = 0
  Width = 320
  Height = 240
  TabOrder = 0
  OnResize = FrameResize
  object sbView: TScrollBox
    Left = 0
    Top = 0
    Width = 320
    Height = 240
    AutoSize = True
    BorderStyle = bsNone
    TabOrder = 0
    object imgView: TImage
      Left = 0
      Top = 0
      Width = 320
      Height = 240
      PopupMenu = mnuView
    end
  end
  object alView: TActionList
    Left = 24
    Top = 24
    object actCopy: TAction
      Caption = 'Copy'
      ShortCut = 16451
      OnExecute = actCopyExecute
    end
  end
  object mnuView: TPopupMenu
    Left = 64
    Top = 24
    object miCopy: TMenuItem
      Action = actCopy
    end
  end
end
