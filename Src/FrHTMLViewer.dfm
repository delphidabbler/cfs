object HTMLViewerFrame: THTMLViewerFrame
  Left = 0
  Top = 0
  Width = 320
  Height = 240
  HelpContext = 4
  TabOrder = 0
  object pnlHost: TPanel
    Left = 0
    Top = 0
    Width = 320
    Height = 240
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object wbView: TWebBrowser
      Left = 0
      Top = 0
      Width = 320
      Height = 240
      TabStop = False
      Align = alClient
      TabOrder = 0
      ControlData = {
        4C00000013210000CE1800000000000000000000000000000000000000000000
        000000004C000000000000000000000001000000E0D057007335CF11AE690800
        2B2E126208000000000000004C0000000114020000000000C000000000000046
        8000000000000000000000000000000000000000000000000000000000000000
        00000000000000000100000000000000000000000000000000000000}
    end
  end
  object mnuView: TPopupMenu
    AutoHotkeys = maManual
    AutoPopup = False
    Left = 16
    Top = 16
    object miCopy: TMenuItem
      Action = actCopy
    end
    object miSelectAll: TMenuItem
      Action = actSelectAll
    end
  end
  object alView: TActionList
    Left = 96
    Top = 16
    object actCopy: TAction
      Caption = 'Copy'
      ShortCut = 16451
      OnExecute = actCopyExecute
      OnUpdate = actCopyUpdate
    end
    object actSelectAll: TAction
      Caption = 'Select All'
      ShortCut = 16449
      OnExecute = actSelectAllExecute
      OnUpdate = actSelectAllUpdate
    end
  end
end
