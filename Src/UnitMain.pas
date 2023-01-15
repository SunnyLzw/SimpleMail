unit UnitMain;

interface

uses
  UnitType, UnitTools, UnitPluginManager, Winapi.Windows, System.IOUtils,
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
    PluginManager: TPluginManager;
    LogList: TSendLogList;
    AttachmentList: TAttachmentDataList;
    Send: TSend;
    IsModifed: Boolean;
    procedure StopSend;
    procedure WMGetMaxInfo(var Msg: TWMGetMinMaxInfo); message WM_GETMinMAXINFO;
    procedure PluginOnClick(Sender: TObject);
  public
    { Public declarations }
    procedure AddMailAddress(AMailaddress: string);
    procedure AddMailAddresss(AMailaddresss: TStrings);
    procedure AddAttachment(AFileName: string);
    procedure AddAttachments(AFileNames: TStrings);
    procedure UpdateAddress(SetSendButtonState: Boolean = True);
    procedure PrintLog(ASendLog: TSendLog);
    procedure PrintSendLog(ASendData: TSendData);
    procedure PrintSystemLog(AState, AInformation: string);
    procedure ClearLog;
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
  UnitBase, UnitSettings, UnitAbout, UnitImport,
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
  sl: PSendLog;
begin
  New(sl);
  sl^ := ASendLog;

  LogList.Add(sl);
  ListView1.Items.Count := ListView1.Items.Count + 1;
  ListView1.Items[0].MakeVisible(False);
  ListView1.UpdateItems(ListView1.TopItem.Index, ListView1.Items.Count - 1);
end;

procedure TFormMain.PrintSendLog(ASendData: TSendData);
var
  sl: TSendLog;
begin
  with sl do
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
  PrintLog(sl);
end;

procedure TFormMain.PrintSystemLog(AState, AInformation: string);
var
  sl: TSendLog;
begin
  with sl do
  begin
    ImageState := Ord(ssSystem) - $50;
    Time := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);
    Address := '系统';
    State := AState;
    Information := AInformation;
  end;
  PrintLog(sl);
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
  md: TMailData;
begin
  if not IsModifed then
    Exit;

  md := FPackageBase.Base.GetMailData;
  with md do
  begin
    IsHtml := CheckBoxIsHtml.Checked;
    Attachments := '';
    for var i in AttachmentList do
      Attachments := Attachments + i.Path + ',';

    Attachments := Attachments.Remove(Attachments.Length - 1);
    Subject := EditSubject.Text;
    Body := MemoBody.Text;
  end;
  FPackageBase.Base.SetMailData(md);
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
  with UnitTools.TImport.Create do
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
      with UnitTools.TImport.Create do
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
  Send := TSend.Create(Self);
end;

procedure TFormMain.ActionSendStopExecute(Sender: TObject);
begin
  Send.Terminate;
  Send := nil;
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

procedure TFormMain.AddAttachment(AFileName: string);
begin
  var filename := ExtractFileName(AFileName);
  var id := filename.Remove(filename.LastIndexOf('.'));
  var ad: PAttachmentData;
  New(ad);
  for var i in AttachmentList do
    if i.Id = id then
      id := id + '1';
  ad.Id := id;
  ad.Path := AFileName;
  AttachmentList.Add(ad);

  ListView2.Items.Count := ListView2.Items.Count + 1;
  ListView2.Items[ListView2.Items.Count - 1].MakeVisible(False);
  ListView2.UpdateItems(ListView2.TopItem.Index, ListView2.Items.Count - 1);
end;

procedure TFormMain.AddAttachments(AFileNames: TStrings);
begin
  for var i in AFileNames do
    if i.Trim <> '' then
      AddAttachment(i);
end;

procedure TFormMain.AddMailAddress(AMailaddress: string);
begin
  if FPackageBase.Base.GetSettingsData.FilterRepeat then
    if FPackageBase.Base.GetSettingsData.CheckImportedList then
      if ListBoxMailAddress.Items.IndexOf(AMailaddress) <> -1 then
        Exit;

  Application.ProcessMessages;
  ListBoxMailAddress.Items.Add(AMailaddress);
end;

procedure TFormMain.AddMailAddresss(AMailaddresss: TStrings);
begin
  for var i in AMailaddresss do
    if i.Trim <> '' then
      AddMailAddress(i);
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
begin
  var i := LogList.Count - Item.Index - 1;
  with LogList[i]^ do
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
begin
  var i := LogList.Count - Item.Index - 1;
  var sl := LogList[i];
  with sl^ do
  begin
    Item.StateIndex := ImageState;
    Item.SubItems.Add(Time);
    Item.SubItems.Add(Address);
    Item.SubItems.Add(State);
    Item.SubItems.Add(Information);
    Item.Data := sl;
  end;
end;

procedure TFormMain.ListView1Deletion(Sender: TObject; Item: TListItem);
begin
  var i := LogList.Count - Item.Index - 1;
  Dispose(LogList[i]);
  LogList.Delete(i);
  ListView1.Items.Count := ListView1.Items.Count - 1;
end;

procedure TFormMain.ListView1Resize(Sender: TObject);
begin
  var w := 0;
  for var i := 0 to 3 do
    Inc(w, ListView1.Column[i].Width);
  ListView1.Column[4].Width := ListView1.Width - w + 50;
end;

procedure TFormMain.ListView2Data(Sender: TObject; Item: TListItem);
begin
  var i := Item.Index;
  var ad := AttachmentList[i];
  with ad^ do
  begin
    Item.Caption := ad.Id;
    Item.SubItems.Add(ad.Path);
  end;
end;

procedure TFormMain.ListView2Deletion(Sender: TObject; Item: TListItem);
begin
  var i := Item.Index;
  Dispose(AttachmentList[i]);
  AttachmentList.Delete(i);
  ListView2.Items.Count := ListView2.Items.Count - 1;
end;

procedure TFormMain.ListView2Resize(Sender: TObject);
begin
  ListView2.Column[1].Width := ListView2.Width - ListView2.Column[0].Width + 100;
end;

procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(Send) then
    Send.Terminate;
end;

procedure TFormMain.PluginOnClick(Sender: TObject);
begin
  var pi := IPlugin((Sender as TMenuItem).Tag);
  if pi.GetPluginData.CanChecked then
    pi.OnChecked
  else
    pi.OnClick;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  item: PPluginObject;
  mi, gmi, pmi, nmi: TMenuItem;
begin
  FPackageBase := UnitTools.TBase.Create;
  Caption := FPackageBase.Base.GetSmtpData.Username;
  LogList := TSendLogList.Create;
  AttachmentList := TAttachmentDataList.Create;
  PluginManager := TPluginManager.Create('.\Plugins');
  for item in PluginManager.Plugins do
  begin
    pmi := nil;

    if item.PluginData.ParentIndex > 0 then
    begin
      if item.PluginData.ParentIndex < MainMenu.Items.Count then
      begin
        if item.PluginData.ParentName.Trim = '' then
          pmi := MainMenu.Items[item.PluginData.ParentIndex]
        else
        begin
          pmi := TMenuItem.Create(MainMenu);
          pmi.Caption := item.PluginData.ParentName;
          MainMenu.Items.Insert(item.PluginData.ParentIndex, pmi);
        end;
      end;
    end
    else
    begin
      for mi in MainMenu.Items do
      begin
        if mi.Caption = item.PluginData.ParentName then
        begin
          pmi := mi;
          Break;
        end;
      end;
    end;

    if not Assigned(pmi) then
    begin
      if item.PluginData.ParentName.Trim = '' then
      begin
        for mi in MainMenu.Items do
        begin
          if mi.Caption = '插件(&P)' then
            pmi := mi;
        end;

        if not Assigned(pmi) then
        begin
          pmi := TMenuItem.Create(MainMenu);
          pmi.Caption := '插件(&P)';
          MainMenu.Items.Insert(2, pmi);
        end;
      end
      else
      begin
        pmi := TMenuItem.Create(MainMenu);
        pmi.Caption := item.PluginData.ParentName;
        MainMenu.Items.Add(pmi);
      end;
    end;

    gmi := nil;
    nmi := TMenuItem.Create(MainMenu);
    if item.PluginData.GroupName.Trim <> '' then
    begin
      for mi in MainMenu.Items[MainMenu.Items.IndexOf(pmi)] do
      begin
        if mi.Caption = item.PluginData.GroupName then
        begin
          gmi := mi;
          Break;
        end;
      end;

      if not Assigned(gmi) then
      begin
        gmi := TMenuItem.Create(MainMenu);
        gmi.Caption := item.PluginData.GroupName;
        MainMenu.Items[MainMenu.Items.IndexOf(pmi)].Add(gmi);
      end;

      pmi.Items[MainMenu.Items[MainMenu.Items.IndexOf(pmi)].IndexOf(gmi)].Add(nmi);
    end
    else
      MainMenu.Items[MainMenu.Items.IndexOf(pmi)].Add(nmi);

    nmi.Caption := item.PluginData.Name;
    nmi.Hint := item.PluginData.Hint;
    nmi.OnClick := PluginOnClick;
    nmi.Tag := NativeInt(item.PluginInterface);

    item.PluginInterface.SetMenuItem(nmi);
    item.PluginInterface.Execute;
  end;

  if TFile.Exists('.\Res\State.png') then
  begin
    var png: TPngImage;
    png := TPngImage.Create;
    png.LoadFromFile('.\Res\State.png');
    var bmp: TBitmap;
    bmp := TBitmap.Create;
    bmp.Assign(png);
    ImageList1.Add(bmp, nil);
    bmp.Free;
    png.Free;
  end;

  IsModifed := False;
  with FPackageBase.Base.GetMailData do
  begin
    CheckBoxIsHtml.Checked := IsHtml;
    var sl := TStringList.Create;
    sl.Delimiter := ';';
    sl.DelimitedText := Attachments;
    AddAttachments(sl);
    EditSubject.Text := Subject;
    MemoBody.Text := Body;
  end;

  if TFile.Exists('.\Backup.txt') then
  begin
    var sl := TStringList.Create;
    sl.LoadFromFile('.\Backup.txt', TEncoding.Unicode);
    AddMailAddresss(sl);
  end;

  UpdateAddress;
  OpenTextFileDialog1.EncodingIndex := 2;
  IsModifed := True;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  for var i in LogList do
    Dispose(i);
  LogList.Free;

  for var i in AttachmentList do
  begin
    Dispose(i);
  end;
  AttachmentList.Free;

  PluginManager.Free;
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

      FPackageBase.Smtp.UpdateMessage(EditSubject.Text, MemoBody.Text, AttachmentList);

      var i: Integer := 0;
      while ListBoxMailAddress.Items.Count <> 0 do
      begin
        if Terminated then
          Break;

        Application.ProcessMessages;
        StatusBarState.Panels[3].Text := '状态：正在发送';

        var sd := FPackageBase.Smtp.Send(ListBoxMailAddress.Items[0].Trim);
        if sd.State = ssSuccess then
          Inc(i);

        PrintSendLog(sd);
        ListBoxMailAddress.Items.Delete(0);
        UpdateAddress(False);

        if FPackageBase.Base.GetSettingsData.AutoStop then
          if i >= FPackageBase.Base.GetSettingsData.StopNumber then
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

