object FormLogin: TFormLogin
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #30331#24405
  ClientHeight = 258
  ClientWidth = 243
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
    Width = 225
    Height = 241
    BevelKind = bkFlat
    BevelOuter = bvNone
    TabOrder = 0
    object Label5: TLabel
      Left = 8
      Top = 131
      Width = 52
      Height = 15
      Caption = #26174#31034#21517#65306
    end
    object Label4: TLabel
      Left = 21
      Top = 102
      Width = 39
      Height = 15
      Caption = #31471#21475#65306
    end
    object Label3: TLabel
      Left = 8
      Top = 73
      Width = 52
      Height = 15
      Caption = #26381#21153#22120#65306
    end
    object Label2: TLabel
      Left = 21
      Top = 44
      Width = 39
      Height = 15
      Caption = #23494#30721#65306
    end
    object Label1: TLabel
      Left = 21
      Top = 15
      Width = 39
      Height = 15
      Caption = #36134#21495#65306
    end
    object ButtonSave: TSpeedButton
      Left = 186
      Top = 214
      Width = 24
      Height = 24
      Hint = #20445#23384'Smtp'#37197#32622#25991#20214
      ParentShowHint = False
      ShowHint = True
      OnClick = ButtonSaveClick
    end
    object ButtonLoad: TSpeedButton
      Left = 162
      Top = 214
      Width = 24
      Height = 24
      Hint = #21152#36733'Smtp'#37197#32622#25991#20214
      ParentShowHint = False
      ShowHint = True
      OnClick = ButtonLoadClick
    end
    object EditDisplayName: TEdit
      Left = 66
      Top = 128
      Width = 145
      Height = 23
      TabOrder = 1
      OnChange = ModifySmtpData
    end
    object EditHost: TEdit
      Left = 66
      Top = 41
      Width = 145
      Height = 23
      TabOrder = 2
      OnChange = ModifySmtpData
    end
    object EditPassword: TEdit
      Left = 66
      Top = 70
      Width = 145
      Height = 23
      PasswordChar = '*'
      TabOrder = 3
      OnChange = ModifySmtpData
    end
    object EditPort: TEdit
      Left = 66
      Top = 99
      Width = 145
      Height = 23
      NumbersOnly = True
      TabOrder = 4
      OnChange = ModifySmtpData
    end
    object EditUsername: TEdit
      Left = 66
      Top = 12
      Width = 145
      Height = 23
      TabOrder = 5
      OnChange = ModifySmtpData
    end
    object RadioGroupUseSSL: TRadioGroup
      Left = 8
      Top = 157
      Width = 121
      Height = 44
      Caption = #20351#29992'SSL'#21152#23494#39564#35777
      Columns = 2
      Items.Strings = (
        #26159
        #21542)
      TabOrder = 6
      OnClick = ModifySmtpData
    end
    object CheckBoxUseStartTLS: TCheckBox
      Left = 8
      Top = 207
      Width = 121
      Height = 17
      Caption = #20248#20808#20351#29992'StartTLS'
      TabOrder = 7
      OnClick = ModifySmtpData
    end
    object ButtonLogin: TButton
      Left = 135
      Top = 157
      Width = 75
      Height = 25
      Caption = #30331#24405
      TabOrder = 0
      OnClick = ButtonLoginClick
    end
    object ButtonCanel: TButton
      Left = 135
      Top = 188
      Width = 75
      Height = 25
      Caption = #21462#28040
      TabOrder = 8
      OnClick = ButtonCanelClick
    end
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
    Left = 176
    Top = 104
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
    Left = 104
    Top = 104
  end
end
