object LocaleViewerFrame: TLocaleViewerFrame
  Left = 0
  Top = 0
  Width = 454
  Height = 308
  TabOrder = 0
  object pnlView: TPanel
    Left = 0
    Top = 0
    Width = 454
    Height = 308
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object sbView: TScrollBox
      Left = 0
      Top = 0
      Width = 454
      Height = 308
      Align = alClient
      BorderStyle = bsNone
      TabOrder = 0
      object lblLangID: TLabel
        Left = 8
        Top = 36
        Width = 91
        Height = 13
        Caption = 'Language Identifier'
      end
      object lblLangName: TLabel
        Left = 8
        Top = 60
        Width = 79
        Height = 13
        Caption = 'Language Name'
      end
      object lblEngLangName: TLabel
        Left = 8
        Top = 84
        Width = 133
        Height = 13
        Caption = 'Language Name (in English)'
      end
      object lblAbbrevLangName: TLabel
        Left = 8
        Top = 108
        Width = 139
        Height = 13
        Caption = 'Abbreviated Language Name'
      end
      object lblCountryCode: TLabel
        Left = 8
        Top = 156
        Width = 64
        Height = 13
        Caption = 'Country Code'
      end
      object lblCountryName: TLabel
        Left = 8
        Top = 180
        Width = 67
        Height = 13
        Caption = 'Country Name'
      end
      object lblEngCountryName: TLabel
        Left = 8
        Top = 204
        Width = 121
        Height = 13
        Caption = 'Country Name (in English)'
      end
      object lblAbbrevCountryName: TLabel
        Left = 8
        Top = 228
        Width = 127
        Height = 13
        Caption = 'Abbreviated Country Name'
      end
      object lblDefCodePage: TLabel
        Left = 8
        Top = 252
        Width = 90
        Height = 13
        Caption = 'Default Code Page'
      end
      object lblLanguage: TLabel
        Left = 8
        Top = 8
        Width = 124
        Height = 13
        Caption = 'Language Information'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblCountry: TLabel
        Left = 8
        Top = 136
        Width = 111
        Height = 13
        Caption = 'Country Information'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object edLangID: TEdit
        Left = 156
        Top = 32
        Width = 45
        Height = 21
        TabStop = False
        ParentColor = True
        PopupMenu = mnuView
        ReadOnly = True
        TabOrder = 0
      end
      object edLangName: TEdit
        Left = 156
        Top = 56
        Width = 217
        Height = 21
        TabStop = False
        ParentColor = True
        PopupMenu = mnuView
        ReadOnly = True
        TabOrder = 1
      end
      object edISOLangName: TEdit
        Left = 156
        Top = 80
        Width = 217
        Height = 21
        TabStop = False
        ParentColor = True
        PopupMenu = mnuView
        ReadOnly = True
        TabOrder = 2
      end
      object edAbbrevLangName: TEdit
        Left = 156
        Top = 104
        Width = 45
        Height = 21
        TabStop = False
        ParentColor = True
        PopupMenu = mnuView
        ReadOnly = True
        TabOrder = 3
      end
      object edCountryCode: TEdit
        Left = 156
        Top = 152
        Width = 45
        Height = 21
        TabStop = False
        ParentColor = True
        PopupMenu = mnuView
        ReadOnly = True
        TabOrder = 4
      end
      object edCountryName: TEdit
        Left = 156
        Top = 176
        Width = 217
        Height = 21
        TabStop = False
        ParentColor = True
        PopupMenu = mnuView
        ReadOnly = True
        TabOrder = 5
      end
      object edEngCountryName: TEdit
        Left = 156
        Top = 200
        Width = 217
        Height = 21
        TabStop = False
        ParentColor = True
        PopupMenu = mnuView
        ReadOnly = True
        TabOrder = 6
      end
      object edAbbrevCountryName: TEdit
        Left = 156
        Top = 224
        Width = 45
        Height = 21
        TabStop = False
        ParentColor = True
        PopupMenu = mnuView
        ReadOnly = True
        TabOrder = 7
      end
      object edDefCodePage: TEdit
        Left = 156
        Top = 248
        Width = 45
        Height = 21
        TabStop = False
        ParentColor = True
        PopupMenu = mnuView
        ReadOnly = True
        TabOrder = 8
      end
    end
  end
  object alView: TActionList
    Left = 368
    Top = 8
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
  end
  object mnuView: TPopupMenu
    Left = 400
    Top = 8
    object miCopy: TMenuItem
      Action = actCopy
    end
    object miSelectAll: TMenuItem
      Action = actSelectAll
    end
  end
end
