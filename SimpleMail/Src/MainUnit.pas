unit MainUnit;

interface

uses
  Types, PluginManager, System.Types, System.UITypes, System.Classes,
  System.SysUtils, FMX.Types, FMX.Controls, FMX.Forms, FMX.StdCtrls, FMX.Objects,
  FMX.Layouts, FMX.ListBox, FMX.Memo, FMX.Edit, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView, FMX.Header, FMX.Menus, FMX.ActnList,
  FMX.ImgList, FMX.Dialogs, FMX.ListView.Adapters.Base, FMX.Graphics,
  System.ImageList, System.Actions, FMX.ScrollBox, FMX.Controls.Presentation;

type
  TSend = class(TThread)
  public
    destructor Destroy; override;
    procedure Execute; override;
    procedure Update;
  end;

  TMainForm = class(TForm)
    TopLayout: TLayout;
    BottomLayout: TLayout;
    MailAddressLayout: TLayout;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    Label1: TLabel;
    Label2: TLabel;
    SubjectEdit: TEdit;
    BodyMemo: TMemo;
    IsHtmlCheckBox: TCheckBox;
    Header1: THeader;
    HeaderItem1: THeaderItem;
    HeaderItem2: THeaderItem;
    HeaderItem3: THeaderItem;
    HeaderItem4: THeaderItem;
    HeaderItem5: THeaderItem;
    SendLogListView: TListView;
    AttachmentListView: TListView;
    Header2: THeader;
    HeaderItem6: THeaderItem;
    HeaderItem7: THeaderItem;
    ImportAttachmentButton: TButton;
    ImportMailAddressButton: TButton;
    SendButton: TButton;
    MainMenuBar: TMenuBar;
    FunctionMenuItem: TMenuItem;
    ToolsMenuItem: TMenuItem;
    HelpMenuItem: TMenuItem;
    ImportMailAddressMenuItem: TMenuItem;
    ImportMailAddressFromTextMenuItem: TMenuItem;
    SettingsMenuItem: TMenuItem;
    AboutMenuItem: TMenuItem;
    MainLayout: TLayout;
    MainActionList: TActionList;
    ImportMailAddressAction: TAction;
    ImportMailAddressFromTextAction: TAction;
    ImportAttachmentAction: TAction;
    SettingsAction: TAction;
    AboutAction: TAction;
    StartSendAction: TAction;
    StopSendAction: TAction;
    DisplayActionList: TActionList;
    ClearMailAddressAction: TAction;
    DeleteSelectMailAddressAction: TAction;
    ClearAttachmentAction: TAction;
    DeleteSelectAttachmentAction: TAction;
    ClearSendLogAction: TAction;
    DeleteSelectSendLogAction: TAction;
    DisplayPopupMenu: TPopupMenu;
    ClearMenuItem: TMenuItem;
    DeleteSelectMenuItem: TMenuItem;
    SendLogRectangle: TRectangle;
    MessageRectangle: TRectangle;
    AttachmemtRectangle: TRectangle;
    ImageList: TImageList;
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;
    AttachmentRectangle2: TRectangle;
    MailAddressListBox: TListBox;
    Line7: TLine;
    Line1: TLine;
    Line2: TLine;
    Line3: TLine;
    Line4: TLine;
    StateStatusBar: TStatusBar;
    StateFlowLayout: TFlowLayout;
    SendAllLabel: TLabel;
    SendTodayLabel: TLabel;
    CountLabel: TLabel;
    StateLabel: TLabel;
    Line10: TLine;
    Line11: TLine;
    Line12: TLine;
    Line13: TLine;
    Line9: TLine;
    Line6: TLine;
    Line5: TLine;
    Line8: TLine;
    PluginsMenuItem: TMenuItem;
    procedure ModifyMailData(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
    procedure ClearMailAddressActionExecute(Sender: TObject);
    procedure DeleteSelectMailAddressActionExecute(Sender: TObject);
    procedure ClearAttachmentActionExecute(Sender: TObject);
    procedure DeleteSelectAttachmentActionExecute(Sender: TObject);
    procedure ClearSendLogActionExecute(Sender: TObject);
    procedure DeleteSelectSendLogActionExecute(Sender: TObject);
    procedure DisplayPopupMenuPopup(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StartSendActionExecute(Sender: TObject);
    procedure AboutActionExecute(Sender: TObject);
    procedure ImportMailAddressActionExecute(Sender: TObject);
    procedure SettingsActionExecute(Sender: TObject);
    procedure ImportAttachmentActionExecute(Sender: TObject);
    procedure ImportMailAddressFromTextActionExecute(Sender: TObject);
    procedure StopSendActionExecute(Sender: TObject);
    procedure MailAddressListBoxKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure ListViewKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure SendLogListViewDeletingItem(Sender: TObject; AIndex: Integer; var ACanDelete: Boolean);
    procedure SplitterPainting(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure SendLogListViewPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure HeaderRealignItem(Sender: TObject; OldIndex, NewIndex: Integer);
    procedure HeaderResize(Sender: TObject);
    procedure HeaderItemResize(Sender: TObject);
    procedure HeaderResizeItem(Sender: TObject; var NewSize: Single);
    procedure RectangleResize(Sender: TObject);
    procedure HeaderItemDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
  private
    { Private declarations }
    FPluginManager: TPluginManager;
    FSendLogs: TSendLogList;
    FAttachmentDatas: TAttachmentDataList;
    FSend: TSend;
    FIsModifed: Boolean;
    procedure LoadPlugins;
    procedure PluginOnClick(Sender: TObject);
    procedure UpdateSendLogListViewLayout;
    procedure UpdateSendLogListViewItems;
    procedure UpdateAttachmentListViewLayout;
    procedure UpdateAttachmentListViewItems;
  public
    { Public declarations }
    procedure AddMailAddress(const AMailaddress: string);
    procedure AddMailAddresss(const AMailaddresss: TStrings);
    procedure AddAttachment(const AAttachmentFileName: string);
    procedure AddAttachments(const AAttachmentFileNames: TStrings);
    procedure UpdateAddress(SetSendButtonState: Boolean = True);
    procedure PrintLog(const ASendLog: TSendLog);
    procedure PrintSendLog(const ASendData: TSendData);
    procedure PrintSystemLog(const AState, AInformation: string);
    procedure ClearLog;
    procedure AutoStop;
    procedure SetStyle;
  public
    property Send: TSend read FSend write FSend;
  end;

var
  GMainForm: TMainForm;

implementation

uses
  PluginFrame, BaseUnit, AboutUnit, ImportUnit, SettingsUnit, Winapi.Windows,
  System.IOUtils, FMX.Styles;

{$R *.fmx}

procedure TMainForm.AboutActionExecute(Sender: TObject);
begin
  with TAboutForm.Create(nil) do
  try
    Parent := Self;
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMainForm.AddAttachment(const AAttachmentFileName: string);
var
  LId: string;
  LAttachmentData, LNewAttachmentData: PAttachmentData;
begin
  if AAttachmentFileName = '' then
    Exit;
  LId := ExtractFileName(AAttachmentFileName);
  LId := LId.Remove(LId.LastIndexOf('.'));
  New(LNewAttachmentData);
  for LAttachmentData in FAttachmentDatas do
    if LAttachmentData.Id = LId then
      LId := LId + '1';
  LNewAttachmentData.Id := LId;
  LNewAttachmentData.Path := AAttachmentFileName;
  FAttachmentDatas.Add(LNewAttachmentData);

  with AttachmentListView.Items.Add.Objects do
  begin
    with LNewAttachmentData^ do
    begin
      FindObjectT<TListItemText>('Id').Text := Id;
      FindObjectT<TListItemText>('Path').Text := Path;
    end;
  end;
end;

procedure TMainForm.AddAttachments(const AAttachmentFileNames: TStrings);
var
  LString: string;
begin
  for LString in AAttachmentFileNames do
    AddAttachment(LString.Trim);
end;

procedure TMainForm.AddMailAddress(const AMailaddress: string);
var
  LItem: TListBoxItem;
begin
  if GBaseDataModule.SettingsData.FilterRepeat then
    if GBaseDataModule.SettingsData.CheckImportedList then
      if MailAddressListBox.Items.IndexOf(AMailaddress) <> -1 then
        Exit;

  LItem := TListBoxItem.Create(MailAddressListBox);
  with LItem do
  begin
    Parent := MailAddressListBox;
    StyledSettings := [TStyledSetting.Family, TStyledSetting.Size];
    TextAlign := TTextAlign.Leading;
    Text := AMailaddress;
  end;
end;

procedure TMainForm.AddMailAddresss(const AMailaddresss: TStrings);
var
  LString: string;
begin
  MailAddressListBox.BeginUpdate;
  for LString in AMailaddresss do
  begin
    Application.ProcessMessages;
    AddMailAddress(LString.Trim);
  end;
  MailAddressListBox.EndUpdate;
end;

procedure TMainForm.AutoStop;
begin
  PrintSystemLog('停止', '已达到设置最大发送数量，自动停止发送');
end;

procedure TMainForm.ClearAttachmentActionExecute(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to FAttachmentDatas.Count - 1 do
    Dispose(FAttachmentDatas[i]);

  FAttachmentDatas.Clear;
  AttachmentListView.Items.Clear;
  ModifyMailData(nil);
end;

procedure TMainForm.ClearLog;
var
  i: Integer;
begin
  for i := 0 to SendLogListView.ItemCount - 1 do
  begin
    Dispose(FSendlogs[i]);
    with SendLogListView.Items[i].Objects.DrawableByName('Image') as TListItemImage do
    begin
      Bitmap.Free;
      Bitmap := nil;
    end;
  end;

  FSendlogs.Clear;
  SendLogListView.Items.Clear;
end;

procedure TMainForm.ClearMailAddressActionExecute(Sender: TObject);
begin
  MailAddressListBox.Clear;
  UpdateAddress;
end;

procedure TMainForm.ClearSendLogActionExecute(Sender: TObject);
begin
  SendLogListView.Items.Clear;
end;

procedure TMainForm.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.DeleteSelectAttachmentActionExecute(Sender: TObject);
begin
  Dispose(FAttachmentDatas[AttachmentListView.ItemIndex]);
  FAttachmentDatas.Delete(AttachmentListView.ItemIndex);
  AttachmentListView.Items.Delete(AttachmentListView.ItemIndex);
  ModifyMailData(nil);
end;

procedure TMainForm.DeleteSelectMailAddressActionExecute(Sender: TObject);
begin
  MailAddressListBox.Items.Delete(MailAddressListBox.ItemIndex);
  UpdateAddress;
end;

procedure TMainForm.DeleteSelectSendLogActionExecute(Sender: TObject);
begin
  Dispose(FSendlogs[SendLogListView.ItemIndex]);
  with SendLogListView.Items[SendLogListView.ItemIndex].Objects.DrawableByName('Image') as TListItemImage do
  begin
    Bitmap.Free;
    Bitmap := nil;
  end;
  FSendlogs.Delete(SendLogListView.ItemIndex);
  SendLogListView.Items.Delete(SendLogListView.ItemIndex);
end;

procedure TMainForm.ImportAttachmentActionExecute(Sender: TObject);
begin
  if OpenDialog2.Execute then
  begin
    SetCurrentDir(ExtractFilePath(ParamStr(0)));
    AddAttachment(OpenDialog2.FileName);
    ModifyMailData(nil);
  end;
end;

procedure TMainForm.ImportMailAddressActionExecute(Sender: TObject);
begin
  with TImportForm.Create(nil) do
  try
    Parent := Self;
    ShowModal;
    AddMailAddresss(MailAddresss);
  finally
    Free;
  end;
  UpdateAddress;
end;

procedure TMainForm.ImportMailAddressFromTextActionExecute(Sender: TObject);
begin
  if OpenDialog1.Execute then
    with TStringList.Create do
    try
      SetCurrentDir(ExtractFilePath(ParamStr(0)));
      LoadFromFile(OpenDialog1.FileName, TEncoding.Unicode);
      with TImportForm.Create(nil) do
      try
        AddMailAddresss(AutoPostfixs(Text));
      finally
        Free;
      end;
      UpdateAddress;
    finally
      Free;
    end;
end;

procedure TMainForm.LoadPlugins;

  function FindMenu(AMenuName: string; var AMenuItem: TMenuItem): Boolean;
  var
    i: Integer;
  begin
    Result := False;
    with MainMenuBar do
      for i := 0 to ItemsCount - 1 do
      begin
        if Items[i].Text = AMenuName then
        begin
          AMenuItem := Items[i];
          Result := True;
          Break;
        end;
      end;
  end;

  function FindSubMenu(const AParentMenuItem: TMenuItem; AMenuName: string; var AMenuItem: TMenuItem): Boolean;
  var
    i: Integer;
  begin
    Result := False;
    with AParentMenuItem do
      for i := 0 to ItemsCount - 1 do
      begin
        if Items[i].Text = AMenuName then
        begin
          AMenuItem := Items[i];
          Result := True;
          Break;
        end;
      end;
  end;

  function CreateMenu(AInheriteState: TInheriteState; AMenuIndex: Integer; AMenuName: string; var AMenuItem: TMenuItem): Boolean;
  var
    LMenuItem: TMenuItem;
  begin
    LMenuItem := nil;
    case AInheriteState of
      IsIndex:
        begin
          LMenuItem := TMenuItem.Create(MainMenuBar);
          LMenuItem.Text := AMenuName;
          LMenuItem.Parent := MainMenuBar;
          if AMenuIndex < MainMenuBar.ItemsCount then
            LMenuItem.Index := AMenuIndex;
        end;
      IsName:
        begin
          if not FindMenu(AMenuName, LMenuItem) then
          begin
            LMenuItem := TMenuItem.Create(MainMenuBar);
            LMenuItem.Text := AMenuName;
            LMenuItem.Parent := MainMenuBar;
          end;
        end;
      IsTools:
        FindMenu('工具(&T)', LMenuItem);
      IsPlugins:
        FindMenu('插件(&P)', LMenuItem);
    end;
    AMenuItem := LMenuItem;
    Result := Assigned(AMenuItem);
  end;

  function CreateSubMenu(const AParentMenuItem: TMenuItem; AIsMultiLevel: Boolean; AMenuName: string; AMenuNames: TStrings; var AMenuItem: TMenuItem): Boolean;
  var
    LName: string;
    LParentMenuItem, LSubMenuItem: TMenuItem;
  begin
    Result := False;
    LSubMenuItem := nil;
    if not Assigned(AParentMenuItem) then
      Exit;

    LParentMenuItem := AParentMenuItem;
    if AIsMultiLevel then
    begin
      if not Assigned(AMenuNames) then
        Exit;

      for LName in AMenuNames do
      begin
        if not FindSubMenu(LParentMenuItem, LName, LSubMenuItem) then
        begin
          LSubMenuItem := TMenuItem.Create(MainMenuBar);
          LSubMenuItem.Text := LName;
          LSubMenuItem.Parent := LParentMenuItem;
        end;
        LParentMenuItem := LSubMenuItem;
      end;
    end
    else
    begin
      if not FindSubMenu(LParentMenuItem, AMenuName, LSubMenuItem) then
      begin
        LSubMenuItem := TMenuItem.Create(MainMenuBar);
        LSubMenuItem.Text := AMenuName;
        LSubMenuItem.Parent := LParentMenuItem;
      end;
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
    if not CreateSubMenu(LParentMenuItem, LPluginData.IsMultiLevel, LPluginData.Name, LPluginData.Names, LSubMenuItem) then
      Continue;
    LSubMenuItem.Hint := LPluginData.Hint;
    LSubMenuItem.OnClick := PluginOnClick;
    LSubMenuItem.Tag := NativeInt(LPluginObject);

    LPluginObject.Plugin.SetBaseDataModule(GBaseDataModule);
    LPluginObject.Plugin.SetMainForm(Self);

    LPluginObject.Plugin.SetMenuItem(LSubMenuItem);
    LPluginObject.PluginEvent.Execute;
  end;
end;

procedure TMainForm.MailAddressListBoxKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Assigned(MailAddressListBox.Selected) and (Key = VK_DELETE) then
  begin
    MailAddressListBox.Items.Delete(MailAddressListBox.ItemIndex);
    UpdateAddress;
  end;
end;

procedure TMainForm.ModifyMailData(Sender: TObject);
var
  LMailData: TMailData;
  LAttachmentData: PAttachmentData;
begin
  if not FIsModifed then
    Exit;

  LMailData := GBaseDataModule.MailData;
  with LMailData do
  begin
    IsHtml := IsHtmlCheckBox.IsChecked;
    Attachments := '';
    for LAttachmentData in FAttachmentDatas do
      Attachments := Attachments + LAttachmentData.Path + ';';

    Attachments := Attachments.Remove(Attachments.Length - 1);
    Subject := SubjectEdit.Text;
    Body := BodyMemo.Text;
  end;
  GBaseDataModule.SetMailData(LMailData);
end;

procedure TMainForm.PluginOnClick(Sender: TObject);
var
  LPluginObject: PPluginObject;
begin
  LPluginObject := PPluginObject((Sender as TMenuItem).Tag);
  if LPluginObject.PluginData.CanChecked then
    LPluginObject.PluginMenuEvent.OnChecked
  else
    LPluginObject.PluginMenuEvent.OnClick;
end;

procedure TMainForm.PrintLog(const ASendLog: TSendLog);
var
  LSendLog: PSendLog;
begin
  New(LSendLog);
  LSendLog^ := ASendLog;
  FSendLogs.Insert(0, LSendLog);
  with SendLogListView.Items.Insert(0).Objects do
  begin
    with LSendLog^ do
    begin
      FindObjectT<TListItemImage>('Image').Bitmap := ImageList.Bitmap(TSizeF.Create(16, 16), ImageState);
      FindObjectT<TListItemText>('Time').Text := FormatDateTime('yyyy-mm-dd nn:mm:ss', Time);
      FindObjectT<TListItemText>('Address').Text := Address;
      FindObjectT<TListItemText>('State').Text := State;
      FindObjectT<TListItemText>('Information').Text := Information;
    end;
  end;
end;

procedure TMainForm.PrintSendLog(const ASendData: TSendData);
var
  LSendLog: TSendLog;
begin
  with LSendLog do
  begin
    ImageState := Ord(ASendData.State);
    Time := ASendData.Time;
    Address := ASendData.Address;
    case ASendData.State of
      TSendState.Success:
        begin
          State := '成功';
          Information := '邮件已成功送达服务器';
        end;
      TSendState.Repeated:
        begin
          State := '重复';
          Information := '此邮箱地址在：' + FormatDateTime('yyyy-mm-dd hh:nn:ss', ASendData.Time) + '已有发送记录';
        end;
      TSendState.Error:
        begin
          State := '失败';
          Information := '错误代码：' + ASendData.ErrorCode.ToString + '，' + ASendData.ErrorText;
        end;
    else

    end;
  end;
  PrintLog(LSendLog);
end;

procedure TMainForm.PrintSystemLog(const AState, AInformation: string);
var
  LSendLog: TSendLog;
begin
  with LSendLog do
  begin
    ImageState := Ord(TSendState.System);
    Time := Now;
    Address := '系统';
    State := AState;
    Information := AInformation;
  end;
  PrintLog(LSendLog);
end;

procedure TMainForm.ListViewKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Assigned((Sender as TListView).Selected) and (Key = VK_DELETE) then
    (Sender as TListView).Items.Delete((Sender as TListView).ItemIndex);
end;

procedure TMainForm.SendLogListViewDeletingItem(Sender: TObject; AIndex: Integer; var ACanDelete: Boolean);
begin
  SendLogListView.Items[AIndex].Objects.FindObjectT<TListItemImage>('Image').Bitmap.Free;
  SendLogListView.Items[AIndex].Objects.FindObjectT<TListItemImage>('Image').Bitmap := nil;
end;

procedure TMainForm.SendLogListViewPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
var
  i: Integer;
  LRect: TRectF;
  LCur, LLast: Boolean;
begin
  if not GBaseDataModule.SettingsData.UseColor then
    Exit;

  LLast := False;
  for i := 0 to SendLogListView.Items.Count - 1 do
  begin
    LRect := SendLogListView.GetItemRect(i);
    LCur := SendLogListView.PointInObjectLocal(LRect.Left, LRect.Top) or SendLogListView.PointInObjectLocal(LRect.Left, LRect.Bottom);
    if LLast and not LCur then
      break;

    if LCur then
      with Canvas do
      begin
        case FSendLogs[i].ImageState of
          0:
            Fill.Color := TAlphaColors.Gray;
          1:
            Fill.Color := TAlphaColors.Green;
          2:
            Fill.Color := TAlphaColors.Red;
          3:
            Fill.Color := TAlphaColors.Orange;
        else
          Fill.Color := TAlphaColors.Null;
        end;
        Fill.Kind := TBrushKind.Solid;
        FillRect(LRect, 0.5);
      end;
    LLast := LCur;
  end;
end;

procedure TMainForm.RectangleResize(Sender: TObject);
begin
  if Sender = SendLogRectangle then
    UpdateSendLogListViewLayout
  else
    UpdateAttachmentListViewLayout;
end;

procedure TMainForm.SetStyle;
begin
  if GBaseDataModule.SettingsData.UseCustomTheme then
  begin
    if TFile.Exists('.\Style\' + GBaseDataModule.SettingsData.CustomTheme + '.Style') then
      TStyleManager.SetStyleFromFile('.\Style\' + GBaseDataModule.SettingsData.CustomTheme + '.Style');
  end
  else
    TStyleManager.SetStyle(nil);
end;

procedure TMainForm.SettingsActionExecute(Sender: TObject);
begin
  with TSettingsForm.Create(nil) do
  try
    Parent := Self;
    ShowModal;
  finally
    Free;
  end;
  if GBaseDataModule.SmtpData.Username.Trim <> '' then
    Caption := 'SimpleMail - ' + GBaseDataModule.SmtpData.Username
  else
    Caption := 'SimpleMail - 未登录';
  UpdateAddress(True);

  SetStyle;
end;

procedure TMainForm.SplitterPainting(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
begin
  Canvas.Fill.Color := TAlphaColors.Yellow;
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.FillRect(ARect, 0.1);
end;

procedure TMainForm.StartSendActionExecute(Sender: TObject);
begin
  FSend := TSend.Create;
end;

procedure TMainForm.StopSendActionExecute(Sender: TObject);
begin
  FSend.Terminate;
  FSend := nil;
end;

procedure TMainForm.DisplayPopupMenuPopup(Sender: TObject);
var
  LMenu: TPopupMenu;
begin
  LMenu := Sender as TPopupMenu;
  if LMenu.PopupComponent is TListBox then
  begin
    if (LMenu.PopupComponent as TListBox) = MailAddressListBox then
    begin
      LMenu.Items[0].Action := DeleteSelectMailAddressAction;
      LMenu.Items[1].Action := ClearMailAddressAction;
    end;
    LMenu.Items[0].Enabled := Assigned((LMenu.PopupComponent as TListBox).Selected);
  end
  else if LMenu.PopupComponent is TListView then
  begin
    if (LMenu.PopupComponent as TListView) = AttachmentListView then
    begin
      LMenu.Items[0].Action := DeleteSelectAttachmentAction;
      LMenu.Items[1].Action := ClearAttachmentAction;
    end
    else if (LMenu.PopupComponent as TListView) = SendLogListView then
    begin
      LMenu.Items[0].Action := DeleteSelectSendLogAction;
      LMenu.Items[1].Action := ClearSendLogAction;
    end;
    LMenu.Items[0].Enabled := Assigned((LMenu.PopupComponent as TListView).Selected);
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FSend) then
    FSend.Terminate;
  FSend := nil;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  LStrings: TStrings;
begin
  SetStyle;

  if GBaseDataModule.SmtpData.Username.Trim <> '' then
    Caption := 'SimpleMail - ' + GBaseDataModule.SmtpData.Username
  else
    Caption := 'SimpleMail - 未登录';

  FSendLogs := TSendLogList.Create;
  FAttachmentDatas := TAttachmentDataList.Create;
  FPluginManager := TPluginManager.Create('.\Plugins');
  LoadPlugins;

  FIsModifed := False;
  with GBaseDataModule.MailData do
  begin
    IsHtmlCheckBox.IsChecked := IsHtml;
    LStrings := TStringList.Create;
    LStrings.StrictDelimiter := True;
    LStrings.Delimiter := ';';
    LStrings.DelimitedText := Attachments;
    AddAttachments(LStrings);
    LStrings.Free;
    SubjectEdit.Text := Subject;
    BodyMemo.Text := Body;
  end;

  if TFile.Exists('.\Data\Backup.smmad') then
  begin
    LStrings := TStringList.Create;
    LStrings.StrictDelimiter := True;
    LStrings.LoadFromFile('.\Data\Backup.smmad', TEncoding.Unicode);
    AddMailAddresss(LStrings);
    LStrings.Free;
  end;

  UpdateAddress;
  FIsModifed := True;

//  var i: TSendLog;
//  with i do
//  begin
//    ImageState := 0;
//    Time := Now;
//    Address := '123';
//    State := '成功';
//    Information := '详细信息';
//  end;
//
//  PrintLog(i);
//  i.ImageState := 1;
//  PrintLog(i);
//  i.ImageState := 2;
//  PrintLog(i);
//  i.ImageState := 3;
//  PrintLog(i);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to FSendLogs.Count - 1 do
    Dispose(FSendLogs[i]);
  FSendLogs.Free;

  for i := 0 to FAttachmentDatas.Count - 1 do
    Dispose(FAttachmentDatas[i]);
  FAttachmentDatas.Clear;

  FPluginManager.Free;
end;

procedure TMainForm.HeaderResize(Sender: TObject);
begin
  if Sender = Header1 then
    UpdateSendLogListViewLayout
  else
    UpdateAttachmentListViewLayout;
end;

procedure TMainForm.HeaderResizeItem(Sender: TObject; var NewSize: Single);
begin
  if (Sender as THeaderItem).Parent = Header1 then
    UpdateSendLogListViewLayout
  else
    UpdateAttachmentListViewLayout;
end;

procedure TMainForm.HeaderItemDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
begin
  if (Sender as THeaderItem).Parent = Header1 then
    UpdateSendLogListViewLayout
  else
    UpdateAttachmentListViewLayout;
end;

procedure TMainForm.HeaderItemResize(Sender: TObject);
begin
  if (Sender as THeaderItem).Parent = Header1 then
    UpdateSendLogListViewLayout
  else
    UpdateAttachmentListViewLayout;
end;

procedure TMainForm.HeaderRealignItem(Sender: TObject; OldIndex, NewIndex: Integer);
begin
  if (Sender as THeaderItem).Parent = Header1 then
    UpdateSendLogListViewLayout
  else
    UpdateAttachmentListViewLayout;
end;

procedure TMainForm.UpdateAddress(SetSendButtonState: Boolean);
begin
  MailAddressListBox.Items.SaveToFile('.\Data\Backup.smmad', TEncoding.Unicode);
  SendAllLabel.Text := '已发送邮箱：' + GBaseDataModule.SendAll.ToString;
  SendTodayLabel.Text := '今日已发送邮箱：' + GBaseDataModule.SendAtDate.ToString;
  CountLabel.Text := '待发送邮箱：' + MailAddressListBox.Items.Count.ToString;
  if SetSendButtonState then
    SendButton.Enabled := MailAddressListBox.Count > 0;
end;

procedure TMainForm.UpdateSendLogListViewItems;
var
  i: Integer;
  LRect: TRectF;
  LCur, LLast: Boolean;
begin
  LLast := False;
  for i := 0 to SendLogListView.Items.Count - 1 do
  begin
    LRect := SendLogListView.GetItemRect(i);
    LCur := SendLogListView.PointInObjectLocal(LRect.Left, LRect.Top) or SendLogListView.PointInObjectLocal(LRect.Left, LRect.Bottom);
    if LLast and not LCur then
      break;

    if LCur then
      with SendLogListView.Items[i].Objects do
      begin
        FindObjectT<TListItemImage>('Image').PlaceOffset.X := (HeaderItem1.Width - 30) / 2 - 4.5;
        FindObjectT<TListItemText>('Time').PlaceOffset.X := Line1.Position.X - 5;
        FindObjectT<TListItemText>('Time').Width := HeaderItem2.Width - 5;
        FindObjectT<TListItemText>('Address').PlaceOffset.X := Line2.Position.X - 5;
        FindObjectT<TListItemText>('Address').Width := HeaderItem3.Width - 5;
        FindObjectT<TListItemText>('State').PlaceOffset.X := Line3.Position.X - 5;
        FindObjectT<TListItemText>('State').Width := HeaderItem4.Width - 5;
        FindObjectT<TListItemText>('Information').PlaceOffset.X := Line4.Position.X - 5;
        FindObjectT<TListItemText>('Information').Width := HeaderItem5.Width - 5;
      end;
    LLast := LCur;
  end;
end;

procedure TMainForm.UpdateSendLogListViewLayout;
begin
  Line1.Position.X := HeaderItem2.Position.X - 0.5;
  Line2.Position.X := HeaderItem3.Position.X - 0.5;
  Line3.Position.X := HeaderItem4.Position.X - 0.5;
  Line4.Position.X := HeaderItem5.Position.X - 0.5;
  Line5.Position.X := Header1.Width - 20.5;
  HeaderItem5.Width := Header1.Width - Line4.Position.X - 20;
  UpdateSendLogListViewItems;
end;

procedure TMainForm.UpdateAttachmentListViewItems;
var
  i: Integer;
  LRect: TRectF;
  LCur, LLast: Boolean;
begin
  LLast := False;
  for i := 0 to AttachmentListView.Items.Count - 1 do
  begin
    LRect := AttachmentListView.GetItemRect(i);
    LCur := AttachmentListView.PointInObjectLocal(LRect.Left, LRect.Top) or AttachmentListView.PointInObjectLocal(LRect.Left, LRect.Bottom);
    if LLast and not LCur then
      break;

    if LCur then
      with AttachmentListView.Items[i].Objects do
      begin
        FindObjectT<TListItemText>('Id').PlaceOffset.X := Line6.Position.X - 5;
        FindObjectT<TListItemText>('Id').Width := HeaderItem6.Width - 5;
        FindObjectT<TListItemText>('Path').PlaceOffset.X := Line7.Position.X - 5;
        FindObjectT<TListItemText>('Path').Width := HeaderItem7.Width - 5;
      end;
    LLast := LCur;
  end;
end;

procedure TMainForm.UpdateAttachmentListViewLayout;
begin
  Line6.Position.X := HeaderItem6.Position.X - 0.5;
  Line7.Position.X := HeaderItem7.Position.X - 0.5;
  Line8.Position.X := Header2.Width - 20.5;
  HeaderItem7.Width := Header2.Width - Line7.Position.X - 20;
  UpdateAttachmentListViewItems;
end;

{ TSend }

destructor TSend.Destroy;
begin
  GMainForm.Send := nil;
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
  with GMainForm do
  begin
    for var i := 0 to ComponentCount - 1 do
    begin
      if (Components[i] is TListView) or (Components[i] is TListBox) or (Components[i] is THeader) or (Components[i] is TEdit) or (Components[i] is TCheckBox) or (Components[i] is TButton) or (Components[i] is TMenuBar) then
        (Components[i] as TControl).Enabled := False;
    end;
    SendButton.Action := StopSendAction;
    SendButton.Enabled := True;
    StateLabel.Text := '状态：正在验证';
    StateLabel.TextSettings.FontColor := TAlphaColors.Blue;
    MailAddressListBox.ItemIndex := -1;
    MailAddressListBox.ScrollToItem(MailAddressListBox.ListItems[0]);
    repeat
      Application.ProcessMessages;
      if not GBaseDataModule.Login then
      begin
        PrintSystemLog('验证', '与服务器验证失败，请重试');
        Break;
      end;

      GBaseDataModule.UpdateMessage(SubjectEdit.Text, BodyMemo.Text, FAttachmentDatas);

      StateLabel.Text := '状态：正在发送';
      StateLabel.TextSettings.FontColor := TAlphaColors.Orange;
      LCount := 0;
      while MailAddressListBox.Items.Count <> 0 do
      begin
        Application.ProcessMessages;
        if Terminated then
          Break;

        if GBaseDataModule.SettingsData.AutoStop then
          if LCount >= GBaseDataModule.SettingsData.StopNumber then
          begin
            PrintSystemLog('停止', '已达到设置最大发送数量，自动停止发送');
            Break;
          end;

        LSendData := GBaseDataModule.Send(MailAddressListBox.Items[0]);
        if LSendData.State in [TSendState.Success, TSendState.Error] then
          Inc(LCount);

        PrintSendLog(LSendData);
        MailAddressListBox.Items.Delete(0);
        UpdateAddress(False);

        if GBaseDataModule.SettingsData.UseInterval then
          Sleep(GBaseDataModule.SettingsData.IntervalTime);
      end;
    until True;
    StateLabel.Text := '状态：空闲';
    StateLabel.TextSettings.FontColor := TAlphaColors.Lightslategray;
    for var i := 0 to ComponentCount - 1 do
    begin
      if (Components[i] is TListView) or (Components[i] is TListBox) or (Components[i] is THeader) or (Components[i] is TEdit) or (Components[i] is TCheckBox) or (Components[i] is TButton) or (Components[i] is TMenuBar) then
        (Components[i] as TControl).Enabled := True;
    end;
    SendButton.Action := StartSendAction;
    UpdateAddress;
  end;
end;

end.

