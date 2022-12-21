object FormSettings: TFormSettings
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #35774#32622
  ClientHeight = 193
  ClientWidth = 322
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  TextHeight = 15
  object PanelMain: TPanel
    Left = 8
    Top = 8
    Width = 306
    Height = 177
    BevelKind = bkFlat
    BevelOuter = bvNone
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 120
      Top = 0
      Height = 173
      AutoSnap = False
      MinSize = 70
      OnCanResize = Splitter1CanResize
      ExplicitLeft = 0
      ExplicitTop = 32
      ExplicitHeight = 100
    end
    object PanelList: TPanel
      Left = 0
      Top = 0
      Width = 120
      Height = 173
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      ExplicitLeft = 9
      ExplicitTop = 9
      ExplicitHeight = 175
      object TreeView1: TTreeView
        Left = 0
        Top = 0
        Width = 120
        Height = 173
        Align = alClient
        Indent = 19
        ReadOnly = True
        TabOrder = 0
        OnChange = TreeView1Change
        ExplicitLeft = 8
        ExplicitTop = 8
        ExplicitWidth = 122
        ExplicitHeight = 182
      end
    end
    object PanelPage: TPanel
      Left = 123
      Top = 0
      Width = 179
      Height = 173
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      ExplicitLeft = 132
      ExplicitTop = 9
      ExplicitWidth = 181
      ExplicitHeight = 175
      object PageControl1: TPageControl
        Left = 0
        Top = 0
        Width = 179
        Height = 173
        ActivePage = TabSheet1
        Align = alClient
        TabOrder = 0
        object TabSheet1: TTabSheet
          Caption = #36830#25509
          object ButtonQuit: TButton
            Left = 48
            Top = 95
            Width = 75
            Height = 25
            Caption = #36864#20986#30331#24405
            TabOrder = 0
            OnClick = ButtonQuitClick
          end
          object ButtonSwitch: TButton
            Left = 48
            Top = 64
            Width = 75
            Height = 25
            Caption = #20999#25442#36134#21495
            TabOrder = 1
            OnClick = ButtonSwitchClick
          end
        end
        object TabSheet2: TTabSheet
          Caption = #21457#36865
          ImageIndex = 1
          object CheckBoxRepeatSend: TCheckBox
            Left = 3
            Top = 16
            Width = 81
            Height = 17
            Caption = #37325#22797#21457#36865
            TabOrder = 0
            OnClick = ModifySettingsData
          end
          object CheckBoxAutoStop: TCheckBox
            Left = 3
            Top = 39
            Width = 168
            Height = 17
            Caption = #21040#36798#25351#23450#25968#37327#21518#20572#27490#21457#36865
            TabOrder = 1
            OnClick = ModifySettingsData
          end
          object CheckBoxUseInterval: TCheckBox
            Left = 3
            Top = 92
            Width = 81
            Height = 17
            Caption = #21457#36865#38388#38548
            TabOrder = 2
            OnClick = ModifySettingsData
          end
          object SpinEditStopNumber: TSpinEdit
            Left = 43
            Top = 62
            Width = 121
            Height = 24
            Increment = 5
            MaxValue = 100
            MinValue = 5
            TabOrder = 3
            Value = 5
            OnChange = ModifySettingsData
          end
          object SpinEditIntervalTime: TSpinEdit
            Left = 43
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
            Left = 3
            Top = 16
            Width = 105
            Height = 17
            Caption = #33258#21160#34917#20840#21518#32512
            TabOrder = 0
            OnClick = ModifySettingsData
          end
          object EditDefaultPostfix: TEdit
            Left = 43
            Top = 39
            Width = 121
            Height = 23
            TabOrder = 1
            OnChange = ModifySettingsData
          end
          object CheckBoxAutoWrap: TCheckBox
            Left = 3
            Top = 64
            Width = 137
            Height = 17
            Caption = #22320#22336#34917#20840#21518#33258#21160#25442#34892
            TabOrder = 2
            OnClick = ModifySettingsData
          end
          object CheckBoxFilterRepeat: TCheckBox
            Left = 3
            Top = 87
            Width = 129
            Height = 17
            Caption = #36807#28388#37325#22797#37038#31665#22320#22336
            TabOrder = 3
            OnClick = ModifySettingsData
          end
          object CheckBoxCheckImportedList: TCheckBox
            Left = 18
            Top = 110
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
            Left = 3
            Top = 16
            Width = 145
            Height = 17
            Caption = #20351#29992#33258#23450#20041#31383#21475#26679#24335
            TabOrder = 0
            OnClick = ModifySettingsData
          end
          object CheckBoxUseColor: TCheckBox
            Left = 3
            Top = 64
            Width = 153
            Height = 17
            Caption = #26085#24535#20351#29992#19981#21516#39068#33394#26631#35760
            TabOrder = 1
            OnClick = ModifySettingsData
          end
          object ComboBox1: TComboBox
            Left = 43
            Top = 39
            Width = 121
            Height = 23
            TabOrder = 2
            OnSelect = ModifySettingsData
          end
        end
      end
    end
  end
end
