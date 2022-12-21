unit UnitSmtp;

interface

uses
  UnitType, System.IniFiles, Winapi.Windows, System.SysUtils, System.Classes,
  FireDAC.UI.Intf, FireDAC.Stan.Param, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, IdBaseComponent, IdSSLOpenSSL, FireDAC.Phys.SQLite,
  FireDAC.Comp.UI, IdMessage, IdTCPConnection, IdTCPClient,
  IdExplicitTLSClientServerBase, IdMessageClient, IdSMTP, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait, IdSMTPBase, IdComponent,
  IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL;

type
  TDataModuleSmtp = class(TDataModule)
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    IdSMTP1: TIdSMTP;
    IdMessage1: TIdMessage;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    procedure CreateDefaultTable;
    procedure UpdateSettingsData;
    procedure UpdateSmtpData;
    procedure UpdateMailData;
  public
    { Public declarations }
    TableName: string;
    IWait: IFDGUIxWaitCursor;
    SettingsData: TSettingsData;
    SmtpData: TSmtpData;
    MailData: TMailData;
    function Login: Boolean;
    function Send(Address: string; DisplayName: string = ''): TSendData;
    procedure UpdateMessage(ASubject, ABody: string; SAttachmentDataList: TAttachmentDataList);
    procedure ModifySettingsData;
    procedure ModifySmtpData;
    procedure ModifyMailData;
    function Find(AAddress: string; var ASendDataList: TSendDataList): Integer;
    function SendAll: Integer;
    function SendAtToday: Integer;
  end;

var
  DataModuleSmtp: TDataModuleSmtp;

implementation

uses
  System.IOUtils, IdMessageBuilder, IdReplySmtp, IdExceptionCore,
  FireDAC.Stan.Factory, UnitEncrypt;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDataModuleSmtp.CreateDefaultTable;
begin
  with FDQuery1 do
  begin
    TableName := 'BeenSend_' + StrToBin(SmtpData.Username);
    SQL.Text := 'Create Table If Not Exists ' + TableName + ' (Id integer Primary Key Autoincrement Not Null,DisplayName ntext,Address ntext,Success ntext,ErrorCode int,ErrorText ntext,Time ntext)';
    ExecSQL;
  end;
end;

procedure TDataModuleSmtp.DataModuleCreate(Sender: TObject);
begin
  if not TDirectory.Exists('.\Data') then
    TDirectory.CreateDirectory('.\Data');

  if not TDirectory.Exists('.\Config') then
    TDirectory.CreateDirectory('.\Config');

  if not TDirectory.Exists('.\Res') then
    TDirectory.CreateDirectory('.\Res');

  UpdateSettingsData;
  UpdateSmtpData;
  UpdateMailData;
  if not TFile.Exists('.\Config\Settings.ini') then
    ModifySettingsData;

  if not TFile.Exists('.\Config\Smtp.ini') then
    ModifySmtpData;

  if not TFile.Exists('.\Config\Mail.ini') then
    ModifyMailData;

  FDConnection1.Open;
  FDCreateInterface(IFDGUIxWaitCursor, IWait);
end;

procedure TDataModuleSmtp.DataModuleDestroy(Sender: TObject);
begin
  IdSMTP1.Disconnect;
end;

function TDataModuleSmtp.Find(AAddress: string; var ASendDataList: TSendDataList): Integer;
var
  fs: TFormatSettings;
  sd: TSendData;
begin
  fs.LongDateFormat := 'yyyy-mm-dd';
  fs.ShortDateFormat := 'yyyy-mm-dd';
  fs.DateSeparator := '-';
  fs.LongTimeFormat := 'hh:nn:ss';
  fs.ShortTimeFormat := 'hh:nn:ss';
  fs.TimeSeparator := ':';
  with FDQuery1 do
  begin
    Open('Select * From ''' + TableName + ''' Where Address like ''' + AAddress.Replace('@', '_') + '''');
    ASendDataList := TSendDataList.Create;
    ASendDataList.Count := RecordCount;
    First;
    Result := 0;
    while not Eof do
      with sd do
      begin
        State := ssError;
        if FieldByName('Success').AsWideString.ToBoolean then
          State := ssSuccess;
        DisplayName := FieldByName('DisplayName').AsWideString;
        Address := FieldByName('Address').AsWideString;
        ErrorCode := FieldByName('ErrorCode').AsInteger;
        ErrorText := FieldByName('ErrorText').AsWideString;
        Time := StrToDateTime(FieldByName('Time').AsWideString, fs);
        ASendDataList.Add(sd);
        Inc(Result);
        Next;
      end;
    Close;
  end;
end;

procedure TDataModuleSmtp.UpdateMessage(ASubject, ABody: string; SAttachmentDataList: TAttachmentDataList);
begin
  if Assigned(IdMessage1) then
    IdMessage1.Free;

  IdMessage1 := TIdMessage.Create(nil);
  with IdMessage1 do
  begin
    Clear;
    Sender.Name := SmtpData.DisplayName;
    Sender.Address := SmtpData.Username;
    Recipients.Clear;
    Recipients.Add;
    Priority := mpNormal;
    Subject := ASubject;
    MessageParts.Clear;
  end;

  with TIdMessageBuilderHtml.Create do
  try
    Clear;
    if MailData.IsHtml then
    begin
      HtmlCharSet := 'UTF-8';
      Html.Text := ABody;
    end
    else
    begin
      PlainTextCharSet := 'UTF-8';
      PlainText.Text := ABody;
    end;

    for var i in SAttachmentDataList do
    begin
      var bs := TMemoryStream.Create;
      with bs do
      begin
        LoadFromFile(i.Path);
        Attachments.Add(bs, '', i.Id);
      end;
    end;
    FillMessage(IdMessage1);
  finally
    Free;
  end;
end;

function TDataModuleSmtp.Login: Boolean;
begin
  IWait.StartWait;

  try
    IdSMTP1 := TIdSmtp.Create(nil);
    IdSSLIOHandlerSocketOpenSSL1 := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    with IdSMTP1 do
    try
      Host := SmtpData.Host;
      Port := SmtpData.Port;
      Username := SmtpData.Username;
      Password := SmtpData.Password;
      if SmtpData.UseSSL then
      begin
        IdSSLIOHandlerSocketOpenSSL1.SSLOptions.Method := sslvSSLv23;
        IOHandler := IdSSLIOHandlerSocketOpenSSL1;
        if SmtpData.UseStartTLS then
          UseTLS := utUseRequireTLS
        else
          UseTLS := utUseImplicitTLS;
      end
      else
        UseTLS := utNoTLSSupport;

      ReadTimeout := 5000;
      try
        Connect;
      except
        on rt: EIdReadTimeout do
          MessageBox(0, 'µÇÂ½³¬Ê±£¬ÇëÖØÆôÈí¼þÖØÊÔ', '', 0);
      end;

      Authenticate;
    except

    end;
  finally
    CreateDefaultTable;
    Result := IdSMTP1.Connected;
    IWait.StopWait;
  end;
end;

procedure TDataModuleSmtp.ModifyMailData;
begin
  with MailData do
  begin
    with TMemIniFile.Create('.\Config\Mail.ini', TEncoding.Unicode) do
    try
      WriteBool('Mail', 'IsHtml', IsHtml);
      WriteString('Mail', 'Attachments', Attachments);
      WriteString('Mail', 'Subject', Subject);
      WriteString('Mail', 'Body', StrToBin(Body, TEncoding.Unicode));
      UpdateFile;
    finally
      Free;
    end;
  end;
end;

procedure TDataModuleSmtp.ModifySettingsData;
begin
  with SettingsData do
  begin
    with TMemIniFile.Create('.\Config\Settings.ini', TEncoding.Unicode) do
    try
      WriteBool('Send', 'RepeatSend', RepeatSend);
      WriteBool('Send', 'AutoStop', AutoStop);
      WriteInteger('Send', 'StopNumber', StopNumber);
      WriteBool('Send', 'UseInterval', UseInterval);
      WriteInteger('Send', 'IntervalTime', IntervalTime);

      WriteString('Add', 'DefaultPostfix', DefaultPostfix);
      WriteBool('Add', 'AutoPostfix', AutoPostfix);
      WriteBool('Add', 'AutoWrap', AutoWrap);
      WriteBool('Add', 'FilterRepeat', FilterRepeat);
      WriteBool('Add', 'CheckImportedList', CheckImportedList);

      WriteBool('Display', 'UseCustomTheme', UseCustomTheme);
      WriteInteger('Display', 'CustomTheme', CustomTheme);
      WriteBool('Display', 'UseColor', UseColor);
      UpdateFile;
    finally
      Free;
    end;
  end;
end;

procedure TDataModuleSmtp.ModifySmtpData;
var
  ss: TStringStream;
begin
  with SmtpData do
  begin
    ss := TStringStream.Create('', TEncoding.Unicode);
    with TMemIniFile.Create(ss, TEncoding.Unicode) do
    try
      WriteString('Smtp', 'Username', Username);
      WriteString('Smtp', 'Password', Password);
      WriteString('Smtp', 'Host', Host);
      WriteInteger('Smtp', 'Port', Port);
      WriteBool('SSL', 'UseSSL', UseSSL);
      WriteBool('SSL', 'UseStartTLS', UseStartTLS);
      WriteString('Display', 'DisplayName', DisplayName);
      UpdateFile;
    finally
      ss.LoadFromStream(Stream);
      TBytesStream.Create(ss.Bytes.XOREncrypt).SaveToFile('.\Config\Smtp.smss');
      Free;
    end;
  end;
end;

function TDataModuleSmtp.Send(Address, DisplayName: string): TSendData;
var
  sdList: TSendDataList;
begin
  if DisplayName.Trim = '' then
    DisplayName := Address.Remove(Address.IndexOf('@'));

  Result.DisplayName := DisplayName;
  Result.Address := Address;

  with FDQuery1 do
  try
    IWait.StartWait;
    if Find(Address, sdList) > 0 then
    begin
      Result := sdList[sdList.Count - 1];
      if Result.State = ssSuccess then
      begin
        if not SettingsData.RepeatSend then
        begin
          Result.State := ssRepeat;
          Exit;
        end;
      end;
    end;

    with IdMessage1 do
    begin
      Recipients[0].Address := Result.Address;
      Recipients[0].Name := Result.DisplayName;
    end;

    with Result do
    begin
      var ret := True;
      try
        ErrorCode := 250;
        ErrorText := '';
        IdSMTP1.Send(IdMessage1);
      except
        on E: EIdSMTPReplyError do
        begin
          ErrorCode := E.ErrorCode;
          ErrorText := E.Message;
          ret := False;
        end;
      end;

      if ret then
        State := ssSuccess
      else
        State := ssError;
      Time := Now;
      Sql.Text := 'Insert Into ' + TableName + '(DisplayName,Address,Success,ErrorCode,ErrorText,Time) Values(:DisplayName,:Address,:Success,:ErrorCode,:ErrorText,:Time)';
      ParamByName('DisplayName').AsWideString := DisplayName;
      ParamByName('Address').AsWideString := Address;
      ParamByName('Success').AsWideString := ret.ToString(TUseBoolStrs.True);
      ParamByName('ErrorCode').AsInteger := ErrorCode;
      ParamByName('ErrorText').AsWideString := ErrorText;
      ParamByName('Time').AsWideString := FormatDateTime('yyyy-mm-dd hh:nn:ss', Time);
      ExecSQL;
    end;
  finally
    Close;
    IWait.StopWait;
  end;
end;

function TDataModuleSmtp.SendAll: Integer;
begin
  FDQuery1.Open('Select * From ' + TableName);
  Result := FDQuery1.RecordCount;
  FDQuery1.Close;
end;

function TDataModuleSmtp.SendAtToday: Integer;
begin
  FDQuery1.Open('Select * From ' + TableName + ' Where Time like ''' + FormatDateTime('yyyy-mm-dd', Now) + '%''');
  Result := FDQuery1.RecordCount;
  FDQuery1.Close;
end;

procedure TDataModuleSmtp.UpdateMailData;
begin
  with MailData do
  begin
    with TMemIniFile.Create('.\Config\Mail.ini', TEncoding.Unicode) do
    try
      IsHtml := ReadBool('Mail', 'IsHtml', False);
      Attachments := ReadString('Mail', 'Attachments', '');
      Subject := ReadString('Mail', 'Subject', '');
      Body := BinToStr(ReadString('Mail', 'Body', ''), TEncoding.Unicode);
    finally
      Free;
    end;
  end;
end;

procedure TDataModuleSmtp.UpdateSettingsData;
begin
  with SettingsData do
  begin
    with TMemIniFile.Create('.\Config\Settings.ini', TEncoding.Unicode) do
    try
      RepeatSend := ReadBool('Send', 'RepeatSend', False);
      AutoStop := ReadBool('Send', 'AutoStop', True);
      StopNumber := ReadInteger('Send', 'StopNumber', 40);
      UseInterval := ReadBool('Send', 'UseInterval', False);
      IntervalTime := ReadInteger('Send', 'IntervalTime', 10);

      DefaultPostfix := ReadString('Add', 'DefaultPostfix', 'qq.com');
      AutoPostfix := ReadBool('Add', 'AutoPostfix', True);
      AutoWrap := ReadBool('Add', 'AutoWrap', True);
      FilterRepeat := ReadBool('Add', 'FilterRepeat', True);
      CheckImportedList := ReadBool('Add', 'CheckImportedList', True);

      UseCustomTheme := ReadBool('Display', 'UseCustomTheme', False);
      CustomTheme := ReadInteger('Display', 'CustomTheme', 2);
      UseColor := ReadBool('Display', 'UseColor', True);
    finally
      Free;
    end;
  end;
end;

procedure TDataModuleSmtp.UpdateSmtpData;
var
  bs: TBytesStream;
begin
  with SmtpData do
  begin
    if not TFile.Exists('.\Config\Smtp.smss') then
      TFile.Create('.\Config\Smtp.smss').Free;

    bs := TBytesStream.Create(TFile.ReadAllBytes('.\Config\Smtp.smss').XORDecrypt);
    with TMemIniFile.Create(bs, TEncoding.Unicode) do
    try
      Username := ReadString('Smtp', 'Username', '');
      Password := ReadString('Smtp', 'Password', '');
      Host := ReadString('Smtp', 'Host', '');
      Port := ReadInteger('Smtp', 'Port', 0);
      UseSSL := ReadBool('SSL', 'UseSSL', False);
      UseStartTLS := ReadBool('SSL', 'UseStartTLS', False);
      DisplayName := ReadString('Display', 'DisplayName', '');
    finally
      Free;
    end;
  end;
end;

end.

