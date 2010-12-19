inherited HTMLClipViewerFrame: THTMLClipViewerFrame
  Width = 338
  inherited pnlHost: TPanel
    Top = 97
    Width = 338
    Height = 143
    inherited wbView: TWebBrowser
      Width = 338
      Height = 143
      ControlData = {
        4C00000013210000CE1800000000000000000000000000000000000000000000
        000000004C000000000000000000000001000000E0D057007335CF11AE690800
        2B2E126208000000000000004C0000000114020000000000C000000000000046
        8000000000000000000000000000000000000000000000000000000000000000
        00000000000000000100000000000000000000000000000000000000}
    end
  end
  object pnlProperties: TPanel [1]
    Left = 0
    Top = 0
    Width = 338
    Height = 97
    Align = alTop
    TabOrder = 1
    DesignSize = (
      338
      97)
    object lblVersionCaption: TLabel
      Left = 8
      Top = 8
      Width = 55
      Height = 13
      Caption = 'Clip Version'
    end
    object lblContextCaption: TLabel
      Left = 8
      Top = 24
      Width = 36
      Height = 13
      Caption = 'Context'
    end
    object lblFragment: TLabel
      Left = 104
      Top = 40
      Width = 227
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
    end
    object lblVersion: TLabel
      Left = 104
      Top = 8
      Width = 227
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
    end
    object lblContext: TLabel
      Left = 104
      Top = 24
      Width = 227
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
    end
    object lblFragmentCaption: TLabel
      Left = 8
      Top = 40
      Width = 44
      Height = 13
      Caption = 'Fragment'
    end
    object lblSelection: TLabel
      Left = 104
      Top = 56
      Width = 227
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
    end
    object lblSelectionCaption: TLabel
      Left = 8
      Top = 56
      Width = 44
      Height = 13
      Caption = 'Selection'
    end
    object lblURLCaption: TLabel
      Left = 8
      Top = 72
      Width = 59
      Height = 13
      Caption = 'Source URL'
    end
    object lblURL: TLabel
      Left = 104
      Top = 72
      Width = 227
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
    end
  end
  inherited mnuView: TPopupMenu
    Left = 128
  end
end
