object BinaryViewerFrame: TBinaryViewerFrame
  Left = 0
  Top = 0
  Width = 342
  Height = 264
  TabOrder = 0
  object sbView: TScrollBox
    Left = 0
    Top = 0
    Width = 342
    Height = 264
    HorzScrollBar.Tracking = True
    VertScrollBar.Tracking = True
    Align = alClient
    BorderStyle = bsNone
    Color = clWindow
    ParentColor = False
    TabOrder = 0
    TabStop = True
    OnResize = sbViewResize
    object pbView: TPaintBox
      Left = 0
      Top = 0
      Width = 600
      Height = 264
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      OnPaint = pbViewPaint
    end
  end
  object alView: TActionList
    Left = 56
    Top = 32
    object actPgUp: TAction
      Caption = 'actPgUp'
      ShortCut = 33
      OnExecute = actPgUpExecute
    end
    object actPgDn: TAction
      Caption = 'actPgDn'
      ShortCut = 34
      OnExecute = actPgDnExecute
    end
    object actUp: TAction
      Caption = 'actUp'
      ShortCut = 38
      OnExecute = actUpExecute
    end
    object actDown: TAction
      Caption = 'actDown'
      ShortCut = 40
      OnExecute = actDownExecute
    end
    object actDocHome: TAction
      Caption = 'actDocHome'
      ShortCut = 16420
      OnExecute = actDocHomeExecute
    end
    object actDocEnd: TAction
      Caption = 'actDocEnd'
      ShortCut = 16419
      OnExecute = actDocEndExecute
    end
    object actLineHome: TAction
      Caption = 'actLineHome'
      ShortCut = 36
      OnExecute = actLineHomeExecute
    end
    object actLineEnd: TAction
      Caption = 'actLineEnd'
      ShortCut = 35
      OnExecute = actLineEndExecute
    end
    object actRight: TAction
      Caption = 'actRight'
      ShortCut = 39
      OnExecute = actRightExecute
    end
    object actLeft: TAction
      Caption = 'actLeft'
      ShortCut = 37
      OnExecute = actLeftExecute
    end
  end
end
