unit UnitMain;

interface

uses
  UnitType, UnitPackage, UnitPluginManager, Winapi.Windows, System.IOUtils,
  Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Menus, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.ActnList,
  Vcl.Dialogs, Vcl.ExtDlgs, Vcl.ImgList, System.ImageList, System.Actions;

type
  TSend = class;

  TFormMain = class(TForm)
    PopupMenu1: TPopupMenu;
    MainMenu: TMainMenu;
    NTools: TMenuItem;
    NSettings: TMenuItem;
    ActionListMenu: TActionList;
    ActionDeleteSelectMailAddress: TAction;
    ActionClearMailAddress: TAction;
    MenuItemDeleteSelectMailAddress: TMenuItem;
    MenuItemClearMailAddress: TMenuItem;
    ActionSettings: TAction;
    ActionListMain: TActionList;
    ActionImport: TAction;
    ActionSendStart: TAction;
    NFunction: TMenuItem;
    NImport: TMenuItem;
    NImportFromText: TMenuItem;
    ActionImportFromText: TAction;
    OpenTextFileDialog1: TOpenTextFileDialog;
    PanelMain: TPanel;
    PanelPrint: TPanel;
    PanelMailAddress: TPanel;
    PanelMessage: TPanel;
    PanelLog: TPanel;
    ActionSendStop: TAction;
    PanelBody: TPanel;
    PanelAttachment: TPanel;
    OpenDialog1: TOpenDialog;
    ActionImportAttachment: TAction;
    ActionDeleteSelectAttachment: TAction;
    ActionClearAttachment: TAction;
    PopupMenu2: TPopupMenu;
    MenuItemDeleteSelectAttachment: TMenuItem;
    MenuItemClearAttachment: TMenuItem;
    ListBoxMailAddress: TListBox;
    ListView1: TListView;
    Label1: TLabel;
    Label2: TLabel;
    EditSubject: TEdit;
    MemoBody: TMemo;
    ListView2: TListView;
    ButtonImportAttachment: TButton;
    ButtonImport: TButton;
    ButtonSendMail: TButton;
    CheckBoxIsHtml: TCheckBox;
    StatusBarState: TStatusBar;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    ImageList1: TImageList;
    NHelp: TMenuItem;
    AAbout: TMenuItem;
    ActionAbout: TAction;
    procedure PopupMenu1Popup(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ModifyMailData(Sender: TObject);
    procedure ListView1CustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ActionClearMailAddressExecute(Sender: TObject);
    procedure ActionDeleteSelectMailAddressExecute(Sender: TObject);
    procedure ActionSettingsExecute(Sender: TObject);
    procedure ActionSendStartExecute(Sender: TObject);
    procedure ActionImportExecute(Sender: TObject);
    procedure ActionImportFromTextExecute(Sender: TObject);
    procedure ListView1Deletion(Sender: TObject; Item: TListItem);
    procedure ListView1Data(Sender: TObject; Item: TListItem);
    procedure FormDestroy(Sender: TObject);
    procedure SplitterCanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
    procedure ListView1Resize(Sender: TObject);
    procedure ActionSendStopExecute(Sender: TObject);
    procedure ListView2Resize(Sender: TObject);
    procedure ActionImportAttachmentExecute(Sender: TObject);
    procedure ListView2Data(Sender: TObject; Item: TListItem);
    procedure ListView2Deletion(Sender: TObject; Item: TListItem);
    procedure ActionDeleteSelectAttachmentExecute(Sender: TObject);
    procedure ActionClearAttachmentExecute(Sender: TObject);
    procedure PopupMenu2Popup(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure StatusBarStateDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
    procedure ListBoxMailAddressKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ActionAboutExecute(Sender: TObject);
  private
    { Private declarations }
    FPackageBase: TBase;
    FPluginManager: TPluginManager;
    FSendLogList: TSendLogList;
    FAttachmenDatatList: TAttachmentDataList;
    FSend: TSend;
    FIsModifed: Boolean;
    procedure StopSend;
    procedure WMGetMaxInfo(var Msg: TWMGetMinMaxInfo); message WM_GETMinMAXINFO;
    procedure LoadPlugins;
    procedure PluginOnClick(Sender: TObject);
  public
    { Public declarations }
    procedure AddMailAddress(AMailaddress: string);
    procedure AddMailAddresss(AMailaddresss: TStrings);
    procedure AddAttachment(AAttachmentFileName: string);
    procedure AddAttachments(AAttachmentFileNames: TStrings);
    procedure UpdateAddress(SetSendButtonState: Boolean = True);
    procedure PrintLog(ASendLog: TSendLog);
    procedure PrintSendLog(ASendData: TSendData);
    procedure PrintSystemLog(AState, AInformation: string);
    procedure ClearLog;
  public
    property Send: TSend read FSend write FSend;
  end;

  TSend = class(TThread)
  private
    FFormMain: TFormMain;
  public
    constructor Create(AFormMain: TFormMain);
    destructor Destroy; override;
    procedure Execute; override;
    procedure Update;
  end;

  TMain = class(TInterfacedObject, IForm)
  private
    FFormMain: TFormMain;
  public
    procedure Create;
    procedure Destroy; reintroduce;
    function GetObject: TObject;
  end;

implementation

uses
{$IFDEF DEBUG}
  UnitSettings, UnitAbout, UnitImport,
{$ENDIF}
  UnitPluginFrame, Vcl.Imaging.pngimage;
{$R *.dfm}

procedure TFormMain.PopupMenu1Popup(Sender: TObject);
begin
  if ListBoxMailAddress.SelCount > 0 then
    PopupMenu1.Items[0].Enabled := True
  else
    PopupMenu1.Items[0].Enabled := False;
end;

procedure TFormMain.PopupMenu2Popup(Sender: TObject);
begin
  if ListView2.SelCount > 0 then
    PopupMenu2.Items[0].Enabled := True
  else
    PopupMenu2.Items[0].Enabled := False;
end;

procedure TFormMain.PrintLog(ASendLog: TSendLog);
var
  LSendLog: PSendLog;
begin
  New(LSendLog);
  LSendLog^ := ASendLog;

  FSendLogList.Add(LSendLog);
  ListView1.Items.Count := ListView1.Items.Count + 1;
  ListView1.Items[0].MakeVisible(False);
  ListView1.UpdateItems(ListView1.TopItem.Index, ListView1.Items.Count - 1);
end;

procedure TFormMain.PrintSendLog(ASendData: TSendData);
var
  LSendLog: TSendLog;
begin
  with LSendLog do
  begin
    ImageState := Ord(ASendData.State) - $50;
    Time := FormatDateTime('yyyy-mm-dd hh:nn:ss', ASendData.Time);
    Address := ASendData.Address;
    case ASendData.State of
      ssSuccess:
        begin
          State := '成功';
          Information := '邮件已成功送达服务器';
        end;
      ssRepeat:
        begin
          State := '重复';
          Information := '此邮箱地址在：' + FormatDateTime('yyyy-mm-dd hh:nn:ss', ASendData.Time) + '已有发送记录';
        end;
      ssError:
        begin
          State := '失败';
          Information := '错误代码：' + ASendData.ErrorCode.ToString + '，' + ASendData.ErrorText;
        end;
    else


    end;
  end;
  PrintLog(LSendLog);
end;

procedure TFormMain.PrintSystemLog(AState, AInformation: string);
var
  LSendLog: TSendLog;
begin
  with LSendLog do
  begin
    ImageState := Ord(ssSystem) - $50;
    Time := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);
    Address := '系统';
    State := AState;
    Information := AInformation;
  end;
  PrintLog(LSendLog);
end;

procedure TFormMain.SplitterCanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
begin
  if (Sender as TSplitter) = Splitter1 then
    Accept := Width - NewSize > 500
  else if (Sender as TSplitter) = Splitter2 then
    Accept := Height - NewSize > 300
  else if (Sender as TSplitter) = Splitter3 then
    Accept := Width - NewSize > 400;
end;

procedure TFormMain.StatusBarStateDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
begin
  if Panel = StatusBar.Panels[3] then
  begin
    if Panel.Text = '状态：空闲' then
      StatusBar.Canvas.Font.Color := StatusBar.Font.Color
    else if Panel.Text = '状态：正在验证' then
      StatusBar.Canvas.Font.Color := clGray
    else if Panel.Text = '状态：正在发送' then
      StatusBar.Canvas.Font.Color := clGreen;

    StatusBar.Canvas.TextRect(Rect, Rect.Left, Rect.Top, Panel.Text);
  end;
end;

procedure TFormMain.StopSend;
begin
  PrintSystemLog('停止', '已达到设置最大发送数量，自动停止发送');
end;

procedure TFormMain.ModifyMailData(Sender: TObject);
var
  LMailData: TMailData;
  LAttachmentData: PAttachmentData;
begin
  if not FIsModifed then
    Exit;

  LMailData := FPackageBase.Base.GetMailData;
  with LMailData do
  begin
    IsHtml := CheckBoxIsHtml.Checked;
    Attachments := '';
    for LAttachmentData in FAttachmenDatatList do
      Attachments := Attachments + LAttachmentData.Path + ',';

    Attachments := Attachments.Remove(Attachments.Length - 1);
    Subject := EditSubject.Text;
    Body := MemoBody.Text;
  end;
  FPackageBase.Base.SetMailData(LMailData);
end;

procedure TFormMain.ActionAboutExecute(Sender: TObject);
begin
  with TDialog.Create('About') do
  try
    Dialog.Show;
  finally
    Free;
  end;
end;

procedure TFormMain.ActionClearAttachmentExecute(Sender: TObject);
begin
  ListView2.Clear;
  ModifyMailData(nil);
end;

procedure TFormMain.ActionClearMailAddressExecute(Sender: TObject);
begin
  ListBoxMailAddress.Items.Clear;
  UpdateAddress;
end;

procedure TFormMain.ActionDeleteSelectAttachmentExecute(Sender: TObject);
begin
  ListView2.DeleteSelected;
  ModifyMailData(nil);
end;

procedure TFormMain.ActionDeleteSelectMailAddressExecute(Sender: TObject);
begin
  ListBoxMailAddress.DeleteSelected;
  UpdateAddress;
end;

procedure TFormMain.ActionImportAttachmentExecute(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    SetCurrentDir(ExtractFilePath(Application.ExeName));
    AddAttachment(OpenDialog1.FileName);
    ModifyMailData(nil);
  end;
end;

procedure TFormMain.ActionImportExecute(Sender: TObject);
begin
  with UnitPackage.TImport.Create do
  try
    AddMailAddresss(TStrings(Dialog.Show));
  finally
    Free;
  end;
  UpdateAddress;
end;

procedure TFormMain.ActionImportFromTextExecute(Sender: TObject);
begin
  if OpenTextFileDialog1.Execute then
    with TStringList.Create do
    try
      SetCurrentDir(ExtractFilePath(Application.ExeName));
      LoadFromFile(OpenTextFileDialog1.FileName, OpenTextFileDialog1.Encodings.Objects[OpenTextFileDialog1.EncodingIndex] as TEncoding);
      with UnitPackage.TImport.Create do
      try
        AddMailAddresss(Import.AutoPostfixs(Text));
      finally
        Free;
      end;
      UpdateAddress;
    finally
      Free;
    end;
end;

procedure TFormMain.ActionSendStartExecute(Sender: TObject);
begin
  FSend := TSend.Create(Self);
end;

procedure TFormMain.ActionSendStopExecute(Sender: TObject);
begin
  FSend.Terminate;
  FSend := nil;
end;

procedure TFormMain.ActionSettingsExecute(Sender: TObject);
begin
  with TDialog.Create('Settings') do
  try
    Dialog.Show;
  finally
    Free;
  end;
  Caption := FPackageBase.Base.GetSmtpData.Username;
  UpdateAddress(True);

  if ListView1.Items.Count > 0 then
    ListView1.UpdateItems(ListView1.TopItem.Index, ListView1.Items.Count - 1);
end;

procedure TFormMain.AddAttachment(AAttachmentFileName: string);
var
  LAttachmentFileName, id: string;
  LAttachmentData, LNewAttachmentData: PAttachmentData;
begin
  LAttachmentFileName := ExtractFileName(AAttachmentFileName.Trim);
  id := LAttachmentFileName.Remove(LAttachmentFileName.LastIndexOf('.'));
  New(LNewAttachmentData);
  for LAttachmentData in FAttachmenDatatList do
    if LAttachmentData.Id = id then
      id := id + '1';
  LNewAttachmentData.Id := id;
  LNewAttachmentData.Path := AAttachmentFileName;
  FAttachmenDatatList.Add(LNewAttachmentData);

  ListView2.Items.Count := ListView2.Items.Count + 1;
  ListView2.Items[ListView2.Items.Count - 1].MakeVisible(False);
  ListView2.UpdateItems(ListView2.TopItem.Index, ListView2.Items.Count - 1);
end;

procedure TFormMain.AddAttachments(AAttachmentFileNames: TStrings);
var
  LString: string;
begin
  for LString in AAttachmentFileNames do
    AddAttachment(LString);
end;

procedure TFormMain.AddMailAddress(AMailaddress: string);
begin
  if FPackageBase.Base.GetSettingsData.FilterRepeat then
    if FPackageBase.Base.GetSettingsData.CheckImportedList then
      if ListBoxMailAddress.Items.IndexOf(AMailaddress.Trim) <> -1 then
        Exit;

  Application.ProcessMessages;
  ListBoxMailAddress.Items.Add(AMailaddress.Trim);
end;

procedure TFormMain.AddMailAddresss(AMailaddresss: TStrings);
var
  LString: string;
begin
  for LString in AMailaddresss do
    AddMailAddress(LString);
end;

procedure TFormMain.ClearLog;
begin
  ListView1.Clear;
end;

procedure TFormMain.ListBoxMailAddressKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
  begin
    ListBoxMailAddress.DeleteSelected;
    UpdateAddress;
  end;
end;

procedure TFormMain.ListView1CustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
var
  LIndex: Integer;
begin
  LIndex := FSendLogList.Count - Item.Index - 1;
  with FSendLogList[LIndex]^ do
  begin
    case TState(ImageState + $50) of
      ssSuccess:
        Sender.Canvas.Brush.Color := clWebYellowGreen;
      ssRepeat:
        Sender.Canvas.Brush.Color := clWebGold;
      ssError:
        Sender.Canvas.Brush.Color := clRed;
      ssSystem:
        Sender.Canvas.Brush.Color := clGray;
    else


    end;
  end;

  if not FPackageBase.Base.GetSettingsData.UseColor then
    Sender.Canvas.Brush.Color := (Item.ListView as TListView).Color;
end;

procedure TFormMain.ListView1Data(Sender: TObject; Item: TListItem);
var
  LIndex: Integer;
  LSendLog: PSendLog;
begin
  LIndex := FSendLogList.Count - Item.Index - 1;
  LSendLog := FSendLogList[LIndex];
  with LSendLog^ do
  begin
    Item.StateIndex := ImageState;
    Item.SubItems.Add(Time);
    Item.SubItems.Add(Address);
    Item.SubItems.Add(State);
    Item.SubItems.Add(Information);
    Item.Data := LSendLog;
  end;
end;

procedure TFormMain.ListView1Deletion(Sender: TObject; Item: TListItem);
var
  LIndex: Integer;
begin
  LIndex := FSendLogList.Count - Item.Index - 1;
  Dispose(FSendLogList[LIndex]);
  FSendLogList.Delete(LIndex);
  ListView1.Items.Count := ListView1.Items.Count - 1;
end;

procedure TFormMain.ListView1Resize(Sender: TObject);
var
  LWidth, LIndex: Integer;
begin
  LWidth := 0;
  for LIndex := 0 to 3 do
    Inc(LWidth, ListView1.Column[LIndex].Width);
  ListView1.Column[4].Width := ListView1.Width - LWidth + 50;
end;

procedure TFormMain.ListView2Data(Sender: TObject; Item: TListItem);
var
  LIndex: Integer;
  LAttachmentData: PAttachmentData;
begin
  LIndex := Item.Index;
  LAttachmentData := FAttachmenDatatList[LIndex];
  with LAttachmentData^ do
  begin
    Item.Caption := LAttachmentData.Id;
    Item.SubItems.Add(LAttachmentData.Path);
  end;
end;

procedure TFormMain.ListView2Deletion(Sender: TObject; Item: TListItem);
var
  LIndex: Integer;
begin
  LIndex := Item.Index;
  Dispose(FAttachmenDatatList[LIndex]);
  FAttachmenDatatList.Delete(LIndex);
  ListView2.Items.Count := ListView2.Items.Count - 1;
end;

procedure TFormMain.ListView2Resize(Sender: TObject);
begin
  ListView2.Column[1].Width := ListView2.Width - ListView2.Column[0].Width + 100;
end;

procedure TFormMain.LoadPlugins;

  function FindMenu(AMenuName: string; var AMenuItem: TMenuItem): Boolean;
  var
    LMenuItem: TMenuItem;
  begin
    Result := False;
    for LMenuItem in MainMenu.Items do
    begin
      if LMenuItem.Caption = AMenuName then
      begin
        AMenuItem := LMenuItem;
        Result := True;
        Break;
      end;
    end;
  end;

  function CreateMenu(AInheriteState: TInheriteState; AMenuIndex: Integer; AMenuName: string; var AMenuItem: TMenuItem): Boolean;
  var
    mi: TMenuItem;
  begin
    mi := nil;
    case AInheriteState of
      IsDefault:
        begin
          if not FindMenu('插件(&P)', mi) then
          begin
            mi := TMenuItem.Create(MainMenu);
            mi.Caption := '插件(&P)';
            MainMenu.Items.Insert(2, mi);
          end;
        end;
      IsIndex:
        begin
          mi := TMenuItem.Create(MainMenu);
          mi.Caption := AMenuName;
          if AMenuIndex < MainMenu.Items.Count then
            MainMenu.Items.Insert(AMenuIndex, mi)
          else
            MainMenu.Items.Add(mi);
        end;
      IsName:
        begin
          if not FindMenu(AMenuName, mi) then
          begin
            mi := TMenuItem.Create(MainMenu);
            mi.Caption := AMenuName;
            MainMenu.Items.Add(mi);
          end;
        end;
    end;
    AMenuItem := mi;
    Result := Assigned(AMenuItem);
  end;

  function CreateSubMenu(AParentMenuItem: TMenuItem; AHasMultiLevel: Boolean; AMenuName: string; AMenuNames: TStrings; var AMenuItem: TMenuItem): Boolean;
  var
    LName: string;
    LParentMenuItem, LSubMenuItem: TMenuItem;
  begin
    Result := False;
    LSubMenuItem := nil;
    if not Assigned(AParentMenuItem) then
      Exit;

    LParentMenuItem := AParentMenuItem;
    if AHasMultiLevel then
    begin
      if not Assigned(AMenuNames) then
        Exit;

      for LName in AMenuNames do
      begin
        LSubMenuItem := TMenuItem.Create(MainMenu);
        LSubMenuItem.Caption := LName;
        LParentMenuItem.Add(LSubMenuItem);
        LParentMenuItem := LSubMenuItem;
      end;
    end
    else
    begin
      LSubMenuItem := TMenuItem.Create(MainMenu);
      LSubMenuItem.Caption := AMenuName;
      LParentMenuItem.Add(LSubMenuItem);
    end;

    AMenuItem := LSubMenuItem;
    Result := Assigned(AMenuItem);
  end;

var
  LPluginObject: PPluginObject;
  LPluginData: TPluginData;
  LParentMenuItem, LSubMenuItem: TMenuItem;
begin
  for LPluginObject in FPluginManager.PluginObjectList do
  begin
    LPluginData := LPluginObject.PluginData;
    if not CreateMenu(LPluginData.InheriteState, LPluginData.ParentIndex, LPluginData.ParentName, LParentMenuItem) then
      Continue;
    if not CreateSubMenu(LParentMenuItem, LPluginData.HasMultiLevel, LPluginData.Name, LPluginData.Names, LSubMenuItem) then
      Continue;
    LSubMenuItem.Hint := LPluginData.Hint;
    LSubMenuItem.OnClick := PluginOnClick;
    LSubMenuItem.Tag := NativeInt(LPluginObject);

    if LPluginData.HasWindow then
      LPluginObject.Plugin.SetMainForm(Self);

    LPluginObject.Plugin.SetMenuItem(LSubMenuItem);
    LPluginObject.PluginEvent.Execute;
  end;
end;

procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FSend) then
    FSend.Terminate;
end;

procedure TFormMain.PluginOnClick(Sender: TObject);
var
  LPluginObject: PPluginObject;
begin
  LPluginObject := PPluginObject((Sender as TMenuItem).Tag);
  if LPluginObject.PluginData.CanChecked then
    LPluginObject.PluginMenuEvent.OnChecked
  else
    LPluginObject.PluginMenuEvent.OnClick;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  LPngImage: TPngImage;
  LBitmap: TBitmap;
  LStrings: TStrings;
begin
  FPackageBase := UnitPackage.TBase.Create;
  Caption := FPackageBase.Base.GetSmtpData.Username;
  FSendLogList := TSendLogList.Create;
  FAttachmenDatatList := TAttachmentDataList.Create;
  FPluginManager := TPluginManager.Create('.\Plugins');
  LoadPlugins;

  if TFile.Exists('.\Res\State.png') then
  begin
    LPngImage := TPngImage.Create;
    LPngImage.LoadFromFile('.\Res\State.png');
    LBitmap := TBitmap.Create;
    LBitmap.Assign(LPngImage);
    ImageList1.Add(LBitmap, nil);
    LBitmap.Free;
    LPngImage.Free;
  end;

  FIsModifed := False;
  with FPackageBase.Base.GetMailData do
  begin
    CheckBoxIsHtml.Checked := IsHtml;
    LStrings := TStringList.Create;
    LStrings.StrictDelimiter := True;
    LStrings.Delimiter := ';';
    LStrings.DelimitedText := Attachments;
    AddAttachments(LStrings);
    LStrings.Free;
    EditSubject.Text := Subject;
    MemoBody.Text := Body;
  end;

  if TFile.Exists('.\Backup.txt') then
  begin
    LStrings := TStringList.Create;
    LStrings.StrictDelimiter := True;
    LStrings.LoadFromFile('.\Backup.txt', TEncoding.Unicode);
    AddMailAddresss(LStrings);
    LStrings.Free;
  end;

  UpdateAddress;
  OpenTextFileDialog1.EncodingIndex := 2;
  FIsModifed := True;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
var
  LSendlog: PSendLog;
  LAttachmentData: PAttachmentData;
begin
  for LSendlog in FSendLogList do
    Dispose(LSendlog);
  FSendLogList.Free;

  for LAttachmentData in FAttachmenDatatList do
  begin
    Dispose(LAttachmentData);
  end;
  FAttachmenDatatList.Free;

  FPluginManager.Free;
  FPackageBase.Free;
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  ListView1.OnResize := ListView1Resize;
  ListView2.OnResize := ListView2Resize;
end;

procedure TFormMain.UpdateAddress(SetSendButtonState: Boolean);
begin
  ListBoxMailAddress.Items.SaveToFile('.\Backup.txt', TEncoding.Unicode);
  ListBoxMailAddress.TopIndex := 0;
  StatusBarState.Panels[0].Text := '已发送邮箱：' + FPackageBase.Base.SendAll.ToString;
  StatusBarState.Panels[1].Text := '今日已发送邮箱：' + FPackageBase.Base.SendAtDate.ToString;
  StatusBarState.Panels[2].Text := '待发送邮箱：' + ListBoxMailAddress.Items.Count.ToString;
  if SetSendButtonState then
    ButtonSendMail.Enabled := ListBoxMailAddress.Count > 0;
end;

procedure TFormMain.WMGetMaxInfo(var Msg: TWMGetMinMaxInfo);
begin
  with Msg.MinMaxInfo^ do
  begin
    ptMinTrackSize.X := 900;
    ptMinTrackSize.Y := 600;
  end;
  Msg.Result := 0;
  inherited;
end;

{ TSend }

constructor TSend.Create(AFormMain: TFormMain);
begin
  FFormMain := AFormMain;
  inherited Create;
end;

destructor TSend.Destroy;
begin
  FFormMain.Send := nil;
  FFormMain := nil;
  inherited;
end;

procedure TSend.Execute;
begin
  inherited;
  FreeOnTerminate := True;
  Synchronize(Update);
end;

procedure TSend.Update;
var
  LCount: Integer;
  LSendData: TSendData;
begin
  with FFormMain do
  begin
    ButtonSendMail.Action := ActionSendStop;
    PanelMailAddress.Enabled := False;
    PanelMessage.Enabled := False;
    ButtonImport.Enabled := False;
    StatusBarState.Panels[3].Text := '状态：正在验证';

    repeat
      if not FPackageBase.Smtp.Login then
      begin
        PrintSystemLog('验证', '与服务器验证失败，请重试');
        Break;
      end;

      FPackageBase.Smtp.UpdateMessage(EditSubject.Text, MemoBody.Text, FAttachmenDatatList);

      LCount := 0;
      while ListBoxMailAddress.Items.Count <> 0 do
      begin
        if Terminated then
          Break;

        Application.ProcessMessages;
        StatusBarState.Panels[3].Text := '状态：正在发送';

        LSendData := FPackageBase.Smtp.Send(ListBoxMailAddress.Items[0].Trim);
        if LSendData.State = ssSuccess then
          Inc(LCount);

        PrintSendLog(LSendData);
        ListBoxMailAddress.Items.Delete(0);
        UpdateAddress(False);

        if FPackageBase.Base.GetSettingsData.AutoStop then
          if LCount >= FPackageBase.Base.GetSettingsData.StopNumber then
          begin
            StopSend;
            Break;
          end;

        if FPackageBase.Base.GetSettingsData.UseInterval then
          Sleep(FPackageBase.Base.GetSettingsData.IntervalTime);
      end;

      StatusBarState.Panels[3].Text := '状态：空闲';
      UpdateAddress;
      ButtonImport.Enabled := True;
      ListBoxMailAddress.Enabled := True;
      Caption := FPackageBase.Base.GetSmtpData.Username;
      PanelMessage.Enabled := True;
      PanelMailAddress.Enabled := True;
      ButtonSendMail.Action := ActionSendStart;
    until True;
  end;
end;

{ TMain }

procedure TMain.Create;
begin
  Application.CreateForm(TFormMain, FFormMain);
end;

procedure TMain.Destroy;
begin
  FFormMain.Free;
  FFormMain := nil;
end;

function TMain.GetObject: TObject;
begin
  Result := FFormMain;
end;

end.

