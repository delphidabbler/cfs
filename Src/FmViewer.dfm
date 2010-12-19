object ViewerDlg: TViewerDlg
  Left = 360
  Top = 207
  Width = 721
  Height = 447
  Caption = 'Clipboard Viewer'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object pnlView: TPanel
    Left = 0
    Top = 0
    Width = 705
    Height = 378
    Align = alClient
    BevelOuter = bvNone
    Color = clAppWorkSpace
    TabOrder = 0
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 378
    Width = 705
    Height = 33
    Align = alBottom
    TabOrder = 1
    DesignSize = (
      705
      33)
    object btnClose: TButton
      Left = 626
      Top = 5
      Width = 75
      Height = 25
      Action = actClose
      Anchors = [akTop, akRight]
      Cancel = True
      TabOrder = 1
    end
    object btnHelp: TButton
      Left = 543
      Top = 5
      Width = 75
      Height = 25
      Action = actHelp
      Anchors = [akTop, akRight]
      TabOrder = 0
    end
  end
  object alMain: TActionList
    Left = 8
    Top = 8
    object actHelp: TAction
      Caption = 'Help'
      ShortCut = 112
      OnExecute = actHelpExecute
    end
    object actClose: TAction
      Caption = 'Close'
      ShortCut = 27
      OnExecute = actCloseExecute
    end
  end
  object wsViewer: TPJUserWdwState
    AutoSaveRestore = True
    Options = [woFitWorkArea]
    OnReadData = wsViewerReadData
    OnSaveData = wsViewerSaveData
    Left = 37
    Top = 8
  end
end
