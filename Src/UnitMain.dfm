object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = #26410#30331#24405
  ClientHeight = 539
  ClientWidth = 888
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    888
    539)
  TextHeight = 14
  object PanelMain: TPanel
    Left = 8
    Top = 8
    Width = 872
    Height = 510
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 0
      Top = 220
      Width = 872
      Height = 3
      Cursor = crVSplit
      Align = alTop
      AutoSnap = False
      MinSize = 100
      OnCanResize = SplitterCanResize
      ExplicitWidth = 293
    end
    object PanelPrint: TPanel
      Left = 0
      Top = 0
      Width = 872
      Height = 220
      Align = alTop
      BevelKind = bkFlat
      BevelOuter = bvNone
      ParentBackground = False
      TabOrder = 0
      ExplicitWidth = 860
      object Splitter2: TSplitter
        Left = 150
        Top = 0
        Height = 216
        AutoSnap = False
        MinSize = 100
        OnCanResize = SplitterCanResize
        ExplicitLeft = 0
        ExplicitTop = 213
        ExplicitHeight = 764
      end
      object PanelMailAddress: TPanel
        Left = 0
        Top = 0
        Width = 150
        Height = 216
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 0
        object ListBoxMailAddress: TListBox
          Left = 0
          Top = 0
          Width = 150
          Height = 216
          Align = alClient
          ItemHeight = 14
          MultiSelect = True
          PopupMenu = PopupMenu1
          TabOrder = 0
          OnKeyDown = ListBoxMailAddressKeyDown
        end
      end
      object PanelLog: TPanel
        Left = 153
        Top = 0
        Width = 715
        Height = 216
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        ExplicitWidth = 703
        object ListView1: TListView
          Left = 0
          Top = 0
          Width = 715
          Height = 216
          Align = alClient
          Columns = <
            item
              Width = 24
            end
            item
              Caption = #26102#38388
              Width = 140
            end
            item
              Caption = #22320#22336
              Width = 150
            end
            item
              Caption = #29366#24577
              Width = 40
            end
            item
              Caption = #35814#32454#20449#24687
              Width = 400
            end>
          GridLines = True
          MultiSelect = True
          OwnerData = True
          StateImages = ImageList1
          TabOrder = 0
          ViewStyle = vsReport
          OnCustomDrawItem = ListView1CustomDrawItem
          OnData = ListView1Data
          OnDeletion = ListView1Deletion
          ExplicitWidth = 707
        end
      end
    end
    object PanelMessage: TPanel
      Left = 0
      Top = 223
      Width = 872
      Height = 287
      Align = alClient
      BevelKind = bkFlat
      BevelOuter = bvNone
      TabOrder = 1
      ExplicitWidth = 860
      ExplicitHeight = 286
      object Splitter3: TSplitter
        Left = 525
        Top = 0
        Height = 283
        Align = alRight
        AutoSnap = False
        MinSize = 300
        OnCanResize = SplitterCanResize
        ExplicitLeft = 0
        ExplicitTop = 240
        ExplicitHeight = 100
      end
      object PanelBody: TPanel
        Left = 0
        Top = 0
        Width = 525
        Height = 283
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        ExplicitWidth = 513
        ExplicitHeight = 282
        DesignSize = (
          525
          283)
        object Label1: TLabel
          Left = 0
          Top = 7
          Width = 36
          Height = 14
          Caption = #20027#39064#65306
        end
        object Label2: TLabel
          Left = 0
          Top = 32
          Width = 36
          Height = 14
          Caption = #20869#23481#65306
        end
        object EditSubject: TEdit
          Left = 38
          Top = 4
          Width = 378
          Height = 22
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
          OnChange = ModifyMailData
        end
        object MemoBody: TMemo
          Left = 38
          Top = 32
          Width = 481
          Height = 238
          Anchors = [akLeft, akTop, akRight, akBottom]
          ScrollBars = ssBoth
          TabOrder = 1
          WantTabs = True
          WordWrap = False
          OnChange = ModifyMailData
          ExplicitWidth = 469
          ExplicitHeight = 237
        end
        object CheckBoxIsHtml: TCheckBox
          Left = 422
          Top = 7
          Width = 97
          Height = 17
          Anchors = [akTop, akRight]
          Caption = #26159#21542'Html'#26684#24335
          TabOrder = 2
          OnClick = ModifyMailData
        end
      end
      object PanelAttachment: TPanel
        Left = 528
        Top = 0
        Width = 340
        Height = 283
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 1
        ExplicitLeft = 516
        ExplicitHeight = 282
        DesignSize = (
          340
          283)
        object ListView2: TListView
          Left = 0
          Top = 0
          Width = 340
          Height = 234
          Align = alTop
          Anchors = [akLeft, akTop, akRight, akBottom]
          Columns = <
            item
              Caption = #21517#31216
              Width = 100
            end
            item
              Caption = #36335#24452
              Width = 250
            end>
          GridLines = True
          MultiSelect = True
          OwnerData = True
          RowSelect = True
          PopupMenu = PopupMenu2
          TabOrder = 3
          ViewStyle = vsReport
          OnData = ListView2Data
          OnDeletion = ListView2Deletion
        end
        object ButtonImportAttachment: TButton
          Left = -2
          Top = 248
          Width = 75
          Height = 25
          Action = ActionImportAttachment
          Anchors = [akLeft, akBottom]
          TabOrder = 2
          ExplicitTop = 247
        end
        object ButtonImport: TButton
          Left = 182
          Top = 248
          Width = 75
          Height = 25
          Action = ActionImport
          Anchors = [akRight, akBottom]
          TabOrder = 1
          ExplicitTop = 247
        end
        object ButtonSendMail: TButton
          Left = 263
          Top = 248
          Width = 75
          Height = 25
          Action = ActionSendStart
          Anchors = [akRight, akBottom]
          TabOrder = 0
          ExplicitTop = 247
        end
      end
    end
  end
  object StatusBarState: TStatusBar
    Left = 0
    Top = 520
    Width = 888
    Height = 19
    Panels = <
      item
        Text = #24050#21457#36865#37038#31665#65306
        Width = 132
      end
      item
        Text = #20170#26085#24050#21457#36865#37038#31665#65306
        Width = 160
      end
      item
        Text = #24453#21457#36865#37038#31665#65306
        Width = 132
      end
      item
        Style = psOwnerDraw
        Text = #29366#24577#65306#31354#38386
        Width = 50
      end>
    OnDrawPanel = StatusBarStateDrawPanel
    ExplicitTop = 519
    ExplicitWidth = 884
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 82
    Top = 70
    object MenuItemDeleteSelectMailAddress: TMenuItem
      Action = ActionDeleteSelectMailAddress
    end
    object MenuItemClearMailAddress: TMenuItem
      Action = ActionClearMailAddress
    end
  end
  object MainMenu: TMainMenu
    Left = 146
    Top = 446
    object NFunction: TMenuItem
      Caption = #21151#33021'(&F)'
      object NImport: TMenuItem
        Action = ActionImport
      end
      object NImportFromText: TMenuItem
        Action = ActionImportFromText
      end
    end
    object NTools: TMenuItem
      Caption = #24037#20855'(&T)'
      object NSettings: TMenuItem
        Action = ActionSettings
      end
    end
    object NHelp: TMenuItem
      Caption = #24110#21161'(&H)'
      object AAbout: TMenuItem
        Action = ActionAbout
      end
    end
  end
  object ActionListMenu: TActionList
    Left = 250
    Top = 446
    object ActionDeleteSelectMailAddress: TAction
      Caption = #21024#38500#25152#36873'(&D)'
      OnExecute = ActionDeleteSelectMailAddressExecute
    end
    object ActionClearMailAddress: TAction
      Caption = #28165#31354#21015#34920'(&C)'
      OnExecute = ActionClearMailAddressExecute
    end
    object ActionSettings: TAction
      Caption = #35774#32622'(&S)'
      OnExecute = ActionSettingsExecute
    end
    object ActionDeleteSelectAttachment: TAction
      Caption = #21024#38500#25152#36873'(&D)'
      OnExecute = ActionDeleteSelectAttachmentExecute
    end
    object ActionClearAttachment: TAction
      Caption = #28165#31354#21015#34920'(&C)'
      OnExecute = ActionClearAttachmentExecute
    end
    object ActionAbout: TAction
      Caption = #20851#20110'(&A)'
      OnExecute = ActionAboutExecute
    end
  end
  object ActionListMain: TActionList
    Left = 354
    Top = 446
    object ActionImport: TAction
      Caption = #23548#20837'(&I)'
      OnExecute = ActionImportExecute
    end
    object ActionSendStart: TAction
      Caption = #21457#36865'(&S)'
      OnExecute = ActionSendStartExecute
    end
    object ActionImportFromText: TAction
      Caption = #20174#25991#26723#23548#20837'(&T)'
      OnExecute = ActionImportFromTextExecute
    end
    object ActionSendStop: TAction
      Caption = #20572#27490'(&S)'
      OnExecute = ActionSendStopExecute
    end
    object ActionImportAttachment: TAction
      Caption = #23548#20837#38468#20214'(&F)'
      OnExecute = ActionImportAttachmentExecute
    end
  end
  object OpenTextFileDialog1: TOpenTextFileDialog
    DefaultExt = '*.txt'
    Filter = #25991#26412#25991#26723'(*.txt)|*.txt|'#20840#37096#25991#20214'(*.*)|*.*'
    FilterIndex = 0
    InitialDir = '.'
    Title = #20174#25991#26723#23548#20837
    Left = 298
    Top = 398
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '*.*'
    Filter = #20840#37096#25991#20214'(*.*)|*.*'
    InitialDir = '.'
    Title = #23548#20837#38468#20214
    Left = 392
    Top = 370
  end
  object PopupMenu2: TPopupMenu
    OnPopup = PopupMenu2Popup
    Left = 130
    Top = 134
    object MenuItemDeleteSelectAttachment: TMenuItem
      Action = ActionDeleteSelectAttachment
    end
    object MenuItemClearAttachment: TMenuItem
      Action = ActionClearAttachment
    end
  end
  object ImageList1: TImageList
    ColorDepth = cd32Bit
    Left = 425
    Top = 184
  end
end
