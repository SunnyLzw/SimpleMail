object FormSettings: TFormSettings
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #35774#32622
  ClientHeight = 281
  ClientWidth = 256
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object PanelMain: TPanel
    Left = 8
    Top = 8
    Width = 240
    Height = 265
    BevelKind = bkFlat
    BevelOuter = bvNone
    TabOrder = 0
    object PanelPage: TPanel
      Left = 0
      Top = 0
      Width = 236
      Height = 261
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object PageControl1: TPageControl
        Left = 0
        Top = 0
        Width = 236
        Height = 261
        ActivePage = TabSheet1
        Align = alClient
        TabOrder = 0
        object TabSheet1: TTabSheet
          Caption = #37197#32622
          object Label2: TLabel
            Left = 21
            Top = 43
            Width = 39
            Height = 15
            Caption = #23494#30721#65306
          end
          object Label1: TLabel
            Left = 21
            Top = 14
            Width = 39
            Height = 15
            Caption = #36134#21495#65306
          end
          object Label3: TLabel
            Left = 8
            Top = 72
            Width = 52
            Height = 15
            Caption = #26381#21153#22120#65306
          end
          object Label5: TLabel
            Left = 8
            Top = 130
            Width = 52
            Height = 15
            Caption = #26174#31034#21517#65306
          end
          object Label4: TLabel
            Left = 21
            Top = 101
            Width = 39
            Height = 15
            Caption = #31471#21475#65306
          end
          object ButtonSave: TSpeedButton
            Left = 186
            Top = 168
            Width = 32
            Height = 32
            Hint = #20445#23384'Smtp'#37197#32622#25991#20214
            ParentShowHint = False
            ShowHint = True
            OnClick = ButtonSaveClick
          end
          object ButtonLoad: TSpeedButton
            Left = 150
            Top = 168
            Width = 32
            Height = 32
            Hint = #21152#36733'Smtp'#37197#32622#25991#20214
            ParentShowHint = False
            ShowHint = True
            OnClick = ButtonLoadClick
          end
          object EditUsername: TEdit
            Left = 66
            Top = 11
            Width = 152
            Height = 23
            TabOrder = 0
            OnChange = ModifySmtpData
          end
          object RadioGroupUseSSL: TRadioGroup
            Left = 8
            Top = 156
            Width = 121
            Height = 44
            Caption = #20351#29992'SSL'#21152#23494#39564#35777
            Columns = 2
            Items.Strings = (
              #26159
              #21542)
            TabOrder = 5
            OnClick = ModifySmtpData
          end
          object CheckBoxUseStartTLS: TCheckBox
            Left = 8
            Top = 206
            Width = 210
            Height = 17
            Caption = #20248#20808#20351#29992'StartTLS'#65288#21462#20915#20110#26381#21153#22120#65289
            TabOrder = 6
            OnClick = ModifySmtpData
          end
          object EditDisplayName: TEdit
            Left = 66
            Top = 123
            Width = 152
            Height = 23
            TabOrder = 4
            OnChange = ModifySmtpData
          end
          object EditPort: TEdit
            Left = 66
            Top = 95
            Width = 152
            Height = 23
            NumbersOnly = True
            TabOrder = 3
            OnChange = ModifySmtpData
          end
          object EditPassword: TEdit
            Left = 66
            Top = 39
            Width = 152
            Height = 23
            PasswordChar = '*'
            TabOrder = 1
            OnChange = ModifySmtpData
          end
          object EditHost: TEdit
            Left = 66
            Top = 67
            Width = 152
            Height = 23
            TabOrder = 2
            OnChange = ModifySmtpData
          end
        end
        object TabSheet2: TTabSheet
          Caption = #21457#36865
          ImageIndex = 1
          object CheckBoxRepeatSend: TCheckBox
            Left = 19
            Top = 16
            Width = 81
            Height = 17
            Caption = #37325#22797#21457#36865
            TabOrder = 0
            OnClick = ModifySettingsData
          end
          object CheckBoxAutoStop: TCheckBox
            Left = 19
            Top = 39
            Width = 168
            Height = 17
            Caption = #21040#36798#25351#23450#25968#37327#21518#20572#27490#21457#36865
            TabOrder = 1
            OnClick = ModifySettingsData
          end
          object CheckBoxUseInterval: TCheckBox
            Left = 19
            Top = 92
            Width = 81
            Height = 17
            Caption = #21457#36865#38388#38548
            TabOrder = 3
            OnClick = ModifySettingsData
          end
          object SpinEditStopNumber: TSpinEdit
            Left = 59
            Top = 62
            Width = 121
            Height = 24
            Increment = 5
            MaxValue = 100
            MinValue = 5
            TabOrder = 2
            Value = 5
            OnChange = ModifySettingsData
          end
          object SpinEditIntervalTime: TSpinEdit
            Left = 59
            Top = 115
            Width = 121
            Height = 24
            Increment = 10
            MaxValue = 1000
            MinValue = 10
            TabOrder = 4
            Value = 10
            OnChange = ModifySettingsData
          end
        end
        object TabSheet3: TTabSheet
          Caption = #23548#20837
          ImageIndex = 2
          object CheckBoxAutoPostfix: TCheckBox
            Left = 19
            Top = 15
            Width = 105
            Height = 17
            Caption = #33258#21160#34917#20840#21518#32512
            TabOrder = 0
            OnClick = ModifySettingsData
          end
          object EditDefaultPostfix: TEdit
            Left = 59
            Top = 38
            Width = 121
            Height = 23
            TabOrder = 1
            OnChange = ModifySettingsData
          end
          object CheckBoxAutoWrap: TCheckBox
            Left = 19
            Top = 63
            Width = 137
            Height = 17
            Caption = #22320#22336#34917#20840#21518#33258#21160#25442#34892
            TabOrder = 2
            OnClick = ModifySettingsData
          end
          object CheckBoxFilterRepeat: TCheckBox
            Left = 19
            Top = 86
            Width = 129
            Height = 17
            Caption = #36807#28388#37325#22797#37038#31665#22320#22336
            TabOrder = 3
            OnClick = ModifySettingsData
          end
          object CheckBoxCheckImportedList: TCheckBox
            Left = 34
            Top = 109
            Width = 153
            Height = 17
            Caption = #21516#26102#26816#26597#24050#23548#20837#30340#21015#34920
            TabOrder = 4
            OnClick = ModifySettingsData
          end
        end
        object TabSheet4: TTabSheet
          Caption = #26174#31034
          ImageIndex = 3
          object CheckBoxUseCustomTheme: TCheckBox
            Left = 19
            Top = 16
            Width = 145
            Height = 17
            Caption = #20351#29992#33258#23450#20041#31383#21475#26679#24335
            TabOrder = 0
            OnClick = ModifySettingsData
          end
          object CheckBoxUseColor: TCheckBox
            Left = 19
            Top = 64
            Width = 153
            Height = 17
            Caption = #26085#24535#20351#29992#19981#21516#39068#33394#26631#35760
            TabOrder = 2
            OnClick = ModifySettingsData
          end
          object ComboBox1: TComboBox
            Left = 59
            Top = 39
            Width = 121
            Height = 23
            TabOrder = 1
            OnSelect = ModifySettingsData
          end
        end
      end
    end
  end
  object FileSaveDialog1: TFileSaveDialog
    DefaultExtension = '.sms'
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Smtp'#37197#32622#25991#20214
        FileMask = '*.sms'
      end
      item
        DisplayName = 'Smtp'#21152#23494#37197#32622#25991#20214
        FileMask = '*.smss'
      end>
    Options = []
    Title = #20445#23384'Smtp'#37197#32622#25991#20214
    Left = 112
    Top = 128
  end
  object FileOpenDialog1: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Smtp'#37197#32622#25991#20214
        FileMask = '*.sms'
      end
      item
        DisplayName = 'Smtp'#21152#23494#37197#32622#25991#20214
        FileMask = '*.smss'
      end>
    Options = []
    Title = #21152#36733'Smtp'#37197#32622#25991#20214
    Left = 152
    Top = 136
  end
end
