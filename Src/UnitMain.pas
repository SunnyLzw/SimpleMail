unit UnitMain;

interface

uses
  UnitType, UnitPluginManager, Winapi.Windows, System.IOUtils, Winapi.Messages,
  System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Menus, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.ActnList, Vcl.Dialogs,
  Vcl.ExtDlgs, Vcl.ImgList, System.ImageList, System.Actions;

type
  TSend = class(TThread)
    procedure Execute; override;
    procedure Update;
  end;

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
    NImportMailAddress: TMenuItem;
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
    procedure WMGetMaxInfo(var Msg: TWMGetMinMaxInfo); message WM_GETMinMAXINFO;
    procedure PluginOnClick(Sender: TObject);
  public
    { Public declarations }
    PluginManager: TPluginManager;
    LogList: TSendLogList;
    AttachmentList: TAttachmentDataList;
    Send: TSend;
    IsModifed: Boolean;
    procedure AddMailAddress(AMailaddress: string);
    procedure AddMailAddresss(AMailaddresss: TStrings);
    procedure AddAttachment(AFileName: string);
    procedure AddAttachments(AFileNames: TStrings);
    procedure UpdateAddress(SetSendButtonState: Boolean = True);
    procedure StopSend;
  end;

var
  FormMain: TFormMain;

implementation

uses
  Vcl.Imaging.pngimage, UnitSmtp, UnitImport, UnitSettings, UnitAbout, UnitPluginFrame;
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
  var log: PSendLog;
  New(log);
  LogList.Add(log);
  with log^ do
  begin
    Time := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);
    Address := '系统';
    New(Data);
    Data.State := ssStop;
    State := '重复';
    log := '已达到设置最大发送数量，自动停止发送';
  end;
  ListView1.Items.Count := ListView1.Items.Count + 1;
  ListView1.Items[0].MakeVisible(False);
  ListView1.UpdateItems(ListView1.TopItem.Index, ListView1.Items.Count - 1);
end;

procedure TFormMain.ModifyMailData(Sender: TObject);
begin
  if not IsModifed then
    Exit;

  with DataModuleSmtp.MailData do
  begin
    IsHtml := CheckBoxIsHtml.Checked;
    Attachments := '';
    for var i in AttachmentList do
      Attachments := Attachments + i.Path + ',';

    Attachments := Attachments.Remove(Attachments.Length - 1);
    Subject := EditSubject.Text;
    Body := MemoBody.Text;
  end;
  DataModuleSmtp.ModifyMailData;
end;

procedure TFormMain.ActionAboutExecute(Sender: TObject);
begin
  FormAbout := TFormAbout.Create(nil);
  FormAbout.ShowModal;
  FormAbout.Free;
  FormAbout := nil;
end;

procedure TFormMain.ActionClearAttachmentExecute(Sender: TObject);
begin
  ListView2.Clear;
  ModifyMailData(nil);
end;

procedure TFormMain.ActionClearMailAddressExecute(Sender: TObject);
begin
  ListBoxMailAddress.Items.Clear;
  ListBoxMailAddress.Items.SaveToFile('.\Backup.txt', TEncoding.Unicode);
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
  ListBoxMailAddress.Items.SaveToFile('.\Backup.txt', TEncoding.Unicode);
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
  FormImport := TFormImport.Create(nil);
  FormImport.ShowModal;
  AddMailAddresss(FormImport.MailAddresss);
  FormImport.Free;
  FormImport := nil;
  ListBoxMailAddress.Items.SaveToFile('.\Backup.txt', TEncoding.Unicode);
  UpdateAddress;
end;

procedure TFormMain.ActionImportFromTextExecute(Sender: TObject);
begin
  if OpenTextFileDialog1.Execute then
    with TStringList.Create do
    try
      SetCurrentDir(ExtractFilePath(Application.ExeName));
      LoadFromFile(OpenTextFileDialog1.FileName, OpenTextFileDialog1.Encodings.Objects[OpenTextFileDialog1.EncodingIndex] as TEncoding);
      AddMailAddresss(FormImport.AutoPostfixs(Text));
      ListBoxMailAddress.Items.SaveToFile('.\Backup.txt', TEncoding.Unicode);
      UpdateAddress;
    finally
      Free;
    end;
end;

procedure TFormMain.ActionSendStartExecute(Sender: TObject);
begin
  Send := TSend.Create;
end;

procedure TFormMain.ActionSendStopExecute(Sender: TObject);
begin
  Send.Terminate;
end;

procedure TFormMain.ActionSettingsExecute(Sender: TObject);
begin
  FormSettings := TFormSettings.Create(nil);
  FormSettings.ShowModal;
  FormSettings.Free;
  FormSettings := nil;
  Caption := DataModuleSmtp.SmtpData.Username;
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
  if DataModuleSmtp.SettingsData.FilterRepeat then
    if DataModuleSmtp.SettingsData.CheckImportedList then
      if ListBoxMailAddress.Items.IndexOf(AMailaddress) <> -1 then
        Exit;

  ListBoxMailAddress.Items.Add(AMailaddress);
end;

procedure TFormMain.AddMailAddresss(AMailaddresss: TStrings);
begin
  for var i in AMailaddresss do
    if i.Trim <> '' then
      AddMailAddress(i);
end;

procedure TFormMain.ListBoxMailAddressKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
  begin
    ListBoxMailAddress.DeleteSelected;
    ListBoxMailAddress.Items.SaveToFile('.\Backup.txt', TEncoding.Unicode);
    UpdateAddress;
  end;
end;

procedure TFormMain.ListView1CustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  with Item do
  begin
    if not Assigned(Data) then
      Exit;

    var sd: PSendData := Data;
    case sd.State of
      ssSuccess:
        Sender.Canvas.Brush.Color := clWebYellowGreen;
      ssRepeat:
        Sender.Canvas.Brush.Color := clWebGold;
      ssError:
        Sender.Canvas.Brush.Color := clRed;
      ssStop:
        Sender.Canvas.Brush.Color := clGray;
    else

    end;
  end;

  if not DataModuleSmtp.SettingsData.UseColor then
    Sender.Canvas.Brush.Color := (Item.ListView as TListView).Color;
end;

procedure TFormMain.ListView1Data(Sender: TObject; Item: TListItem);
begin
  var i := LogList.Count - Item.Index - 1;
  var log := LogList[i];
  with log^ do
  begin
    Item.SubItems.Add(Time);
    Item.SubItems.Add(Address);
    Item.SubItems.Add(State);
    Item.SubItems.Add(log);
    Item.Data := Data;
    case Data.State of
      ssSuccess:
        Item.StateIndex := 0;
      ssRepeat:
        Item.StateIndex := 1;
      ssError:
        Item.StateIndex := 2;
      ssStop:
        Item.StateIndex := 3;
    else

    end;
  end;
end;

procedure TFormMain.ListView1Deletion(Sender: TObject; Item: TListItem);
begin
  var i := LogList.Count - Item.Index - 1;
  Dispose(LogList[i].Data);
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
  item: TPluginObject;
  mi, pmi, nmi: TMenuItem;
begin
  Caption := DataModuleSmtp.SmtpData.Username;
  LogList := TSendLogList.Create;
  AttachmentList := TAttachmentDataList.Create;
  PluginManager := TPluginManager.Create;
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

    repeat
      nmi := TMenuItem.Create(MainMenu);
      MainMenu.Items[MainMenu.Items.IndexOf(pmi)].Add(nmi);
      if item.PluginData.GroupName.Trim = '' then
        Break;

      nmi.Caption := item.PluginData.GroupName;
      mi := nmi;
      nmi := TMenuItem.Create(MainMenu);
      pmi.Items[MainMenu.Items[MainMenu.Items.IndexOf(pmi)].IndexOf(mi)].Add(nmi);
    until True;

    nmi.Caption := item.PluginData.Name;
    nmi.Hint := item.PluginData.Hint;
    nmi.OnClick := PluginOnClick;
    nmi.Tag := NativeInt(item.PluginInterface);

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
  with DataModuleSmtp.MailData do
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
  IsModifed := True;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  for var i in LogList do
  begin
    Dispose(i.Data);
    Dispose(i);
  end;
  LogList.Free;

  for var i in AttachmentList do
  begin
    Dispose(i);
  end;
  AttachmentList.Free;

  PluginManager.Free;
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  ListView1.OnResize := ListView1Resize;
  ListView2.OnResize := ListView2Resize;
end;

procedure TFormMain.UpdateAddress(SetSendButtonState: Boolean);
begin
  ListBoxMailAddress.TopIndex := 0;
  StatusBarState.Panels[0].Text := '已发送邮箱：' + DataModuleSmtp.SendAll.ToString;
  StatusBarState.Panels[1].Text := '今日已发送邮箱：' + DataModuleSmtp.SendAtToday.ToString;
  StatusBarState.Panels[2].Text := '待发送邮箱：' + ListBoxMailAddress.Items.Count.ToString;
  if SetSendButtonState then
    ButtonSendMail.Enabled := ListBoxMailAddress.Count > 0;
end;

procedure TFormMain.WMGetMaxInfo(var Msg: TWMGetMinMaxInfo);
begin
  with Msg.MinMaxInfo^ do
  begin
    ptMinTrackSize.X := 800;
    ptMinTrackSize.Y := 600;
  end;
  Msg.Result := 0;
  inherited;
end;

{ TSend }

procedure TSend.Execute;
begin
  inherited;
  FreeOnTerminate := True;
  Synchronize(Update);
end;

procedure TSend.Update;
begin
  with FormMain do
  begin
    ButtonSendMail.Action := ActionSendStop;
    PanelMailAddress.Enabled := False;
    PanelMessage.Enabled := False;
    ButtonImport.Enabled := False;
    StatusBarState.Panels[3].Text := '状态：正在验证';

    DataModuleSmtp.Login;
    DataModuleSmtp.UpdateMessage(EditSubject.Text, MemoBody.Text, AttachmentList);

    var i: Integer := 0;
    while ListBoxMailAddress.Items.Count <> 0 do
    begin
      if Terminated then
        Break;

      Application.ProcessMessages;
      StatusBarState.Panels[3].Text := '状态：正在发送';

      var log: PSendLog;
      New(log);
      with log^ do
      begin
        Time := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);
        var addr := ListBoxMailAddress.Items[0].Trim;
        Address := addr;

        var sd := DataModuleSmtp.Send(addr);
        New(Data);
        Data^ := sd;
        case sd.State of
          ssSuccess:
            begin
              State := '成功';
              log := '邮件已成功送达服务器';
            end;
          ssRepeat:
            begin
              State := '重复';
              log := '此邮箱地址在：' + FormatDateTime('yyyy-mm-dd hh:nn:ss', sd.Time) + '已有发送记录';
            end;
          ssError:
            begin
              State := '失败';
              log := '错误代码：' + sd.ErrorCode.ToString + '，' + sd.ErrorText;
            end;
        else

        end;

        if Data.State = ssSuccess then
          Inc(i);
      end;

      LogList.Add(log);
      ListView1.Items.Count := ListView1.Items.Count + 1;
      ListView1.Items[0].MakeVisible(False);
      ListView1.UpdateItems(ListView1.TopItem.Index, ListView1.Items.Count - 1);

      ListBoxMailAddress.Items.Delete(0);
      ListBoxMailAddress.Items.SaveToFile('.\Backup.txt', TEncoding.Unicode);
      UpdateAddress(False);

      if DataModuleSmtp.SettingsData.AutoStop then
        if i >= DataModuleSmtp.SettingsData.StopNumber then
        begin
          StopSend;
          Break;
        end;

      if DataModuleSmtp.SettingsData.UseInterval then
        Sleep(DataModuleSmtp.SettingsData.IntervalTime);
    end;

    StatusBarState.Panels[3].Text := '状态：空闲';
    UpdateAddress;
    ButtonImport.Enabled := True;
    ListBoxMailAddress.Enabled := True;
    Caption := DataModuleSmtp.SmtpData.Username;
    PanelMessage.Enabled := True;
    PanelMailAddress.Enabled := True;
    ButtonSendMail.Action := ActionSendStart;
    FormMain.Send := nil;
  end;
end;

end.

