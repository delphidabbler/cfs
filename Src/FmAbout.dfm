inherited AboutBox: TAboutBox
  Left = 212
  Top = 108
  ActiveControl = btnButton
  BorderStyle = bsDialog
  Caption = 'About'
  ClientHeight = 183
  ClientWidth = 293
  OldCreateOrder = True
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 8
    Top = 8
    Width = 277
    Height = 134
    BevelInner = bvRaised
    BevelOuter = bvLowered
    ParentColor = True
    TabOrder = 0
    object imgIcon: TImage
      Left = 8
      Top = 8
      Width = 32
      Height = 32
      Picture.Data = {
        055449636F6E0000010001002020100000000000E80200001600000028000000
        2000000040000000010004000000000080020000000000000000000000000000
        0000000000000000000080000080000000808000800000008000800080800000
        C0C0C000808080000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000
        FFFFFF0000000000000000000000000000000000000000000000000000000000
        000100000000000000000000000000000011100000000F7F7F7F7F7F7F7F0000
        01110000000007F7F7F7F7F7F7F700001110000000000F000F000F7001111101
        11000000000007F7F7F7F7F7111111111000000000000F0000700F0111FF0111
        00000000000007F7F7F7F7111FFF0B111000000000000F7F7F7F7F11FFFF0BB1
        10000000000007FCCCF7F711FFFF0BB11000000000000F7CCC7F7F11FFFF0BB1
        10000000000007FCCCF7F2111AFF0B111000000000000F7F7F7F7F2111FF0111
        00000000000007F7F7F997F2111111100000000000000F7F7F99997F71111100
        00000000000007F7F7F997F7F7F700000000000000000F7F7F7F7F7F7F7F0000
        00000000000007F7F7F7F7F7F7F700000000000000000F00007F0000700F0000
        00000000000007F7F7F7F7F7F7F700000000000000000F000F7000007F7F0000
        00000000000007F7F7F7F7F7F7F700000000000000000F007000000F000F0000
        00000000000007F7F7F7F7F7F7F700000000000000000F7F700000007F7F0000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000000000000000F0000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000FFFFFFFFFFFFFFEFF00007C7F000078FF000071FF000023FF000007F
        F00000FFF000007FF000007FF000007FF000007FF000007FF00000FFF00001FF
        F00003FFF00007FFF00007FFF00007FFF00007FFF00007FFF00007FFF00007FF
        F00007FFF00007FFF00007FFF00007FFFF007FFFFF007FFFFFE3FFFFFFE3FFFF
        FFFFFFFF}
      Stretch = True
      IsControl = True
    end
    object lblProductName: TLabel
      Left = 48
      Top = 8
      Width = 112
      Height = 16
      Caption = 'lblProductName'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      IsControl = True
    end
    object lblVersion: TLabel
      Left = 48
      Top = 27
      Width = 45
      Height = 13
      Caption = 'lblVersion'
      IsControl = True
    end
    object lblCopyright: TLabel
      Left = 8
      Top = 56
      Width = 54
      Height = 13
      Caption = 'lblCopyright'
      IsControl = True
    end
    object lblComments: TLabel
      Left = 8
      Top = 80
      Width = 226
      Height = 13
      Caption = 'This software is released under an open source '
      IsControl = True
    end
    object hlblWebsite: TPJHotLabel
      Left = 157
      Top = 113
      Width = 113
      Height = 13
      Caption = 'www.delphidabbler.com'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsUnderline]
      CaptionIsURL = False
      HighlightFont.Charset = DEFAULT_CHARSET
      HighlightFont.Color = clRed
      HighlightFont.Height = -11
      HighlightFont.Name = 'MS Sans Serif'
      HighlightFont.Style = [fsUnderline]
      URL = 'http://www.delphidabbler.com/'
    end
    object lblLicense: TLabel
      Left = 234
      Top = 80
      Width = 33
      Height = 13
      Cursor = crHandPoint
      Caption = 'license'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsUnderline]
      ParentFont = False
      OnClick = lblLicenseClick
    end
    object lblCommentsEnd: TLabel
      Left = 267
      Top = 80
      Width = 3
      Height = 13
      Caption = '.'
    end
  end
  object btnButton: TButton
    Left = 111
    Top = 150
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object viMain: TPJVersionInfo
    Left = 8
    Top = 152
  end
end
