unit BaseUnit;

interface

uses
  Types, System.SysUtils, System.Classes, IdSSLOpenSSL, IdTCPConnection,
  IdTCPClient, IdExplicitTLSClientServerBase, IdSMTP, IdMessage,
  FireDAC.Stan.Param, FireDAC.UI.Intf, FireDAC.Phys.SQLite, Data.DB,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Comp.UI, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Stan.Async,
  FireDAC.DApt, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait,
  IdIOHandler, IdIOHandlerStack, IdSSL, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Phys.SQLiteDef, IdIOHandlerSocket, IdComponent, IdMessageClient,
  IdSMTPBase, IdBaseComponent;

type
  TBaseDataModule = class(TDataModule)
    IdMessage1: TIdMessage;
    IdSMTP1: TIdSMTP;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    FDQuery1: TFDQuery;
    FDConnection1: TFDConnection;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    FTableName: string;
    FWaitCursor: IFDGUIxWaitCursor;
    FSettingsData: TSettingsData;
    FSmtpData: TSmtpData;
    FMailData: TMailData;
    FPostfixs: TStrings;
  public
    { Public declarations }
    function QueryBeenSend(AAddress: string; var ASendDataList: TSendDataList): Integer;
    procedure CreateDefaultTable;
    function TableIsExist: Boolean;
    procedure UpdateSettingsData;
    procedure UpdateSmtpData;
    procedure UpdateMailData;
    procedure SetSettingsData(ASettingsData: TSettingsData);
    procedure SetSmtpData(ASmtpData: TSmtpData);
    procedure SetMailData(AMailData: TMailData);
    function SendAll: Integer;
    function SendAtDate(ADate: string = ''): Integer;
    function EnumAll(var ASendDataList: TSendDataList): Integer;
    function EnumAtDate(ADate: string; var ASendDataList: TSendDataList): Integer;
    function EnumAllSuccessMailAddress: TStrings;
    function Login: Boolean;
    procedure UpdateMessage(ASubject, ABody: string; AAttachmentDataList: TAttachmentDataList);
    function Send(Address: string; DisplayName: string = ''): TSendData;
  public
    property SettingsData: TSettingsData read FSettingsData write SetSettingsData;
    property SmtpData: TSmtpData read FSmtpData write SetSmtpData;
    property MailData: TMailData read FMailData write SetMailData;
    property Postfixs: TStrings read FPostfixs;
  end;

var
  GBaseDataModule: TBaseDataModule;

const
  CDefaultPostfixs: TArray<string> = ['qq.com', '126.com', '163.com', 'sina.com', 'gmail.com', 'foxmail.com', 'hotmail.com', 'outlook.com'];

implementation

uses
  Tools, System.IniFiles, Winapi.Windows, System.IOUtils, IdMessageBuilder,
  IdReplySmtp, IdExceptionCore, FireDAC.Stan.Factory;

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TBaseDataModule.CreateDefaultTable;
begin
  if TableIsExist then
    Exit;

  with FDQuery1 do
  begin
    SQL.Text := 'Create Table If Not Exists ' + FTableName + ' (Id integer Primary Key Autoincrement Not Null,DisplayName ntext,Address ntext,Success ntext,ErrorCode int,ErrorText ntext,Time ntext)';
    ExecSQL;
  end;
end;

procedure TBaseDataModule.DataModuleCreate(Sender: TObject);
begin
  if not TDirectory.Exists('.\Data') then
    TDirectory.CreateDirectory('.\Data');

  if not TDirectory.Exists('.\Config') then
    TDirectory.CreateDirectory('.\Config');

  FPostfixs := TStringList.Create;
  if not TFile.Exists('.\Config\Postfixs.ini') then
  begin
    FPostfixs.AddStrings(CDefaultPostfixs);
    FPostfixs.SaveToFile('.\Config\Postfixs.ini', TEncoding.Unicode);
  end
  else
    FPostfixs.LoadFromFile('.\Config\Postfixs.ini', TEncoding.Unicode);

  UpdateSettingsData;
  UpdateSmtpData;
  UpdateMailData;
  if not TFile.Exists('.\Config\Settings.ini') then
    SetSettingsData(FSettingsData);

  if not TFile.Exists('.\Config\Smtp.ini') then
    SetSmtpData(FSmtpData);

  if not TFile.Exists('.\Config\Mail.ini') then
    SetMailData(FMailData);

  FDConnection1.Open;
  FDCreateInterface(IFDGUIxWaitCursor, FWaitCursor);
end;

procedure TBaseDataModule.DataModuleDestroy(Sender: TObject);
begin
  IdSMTP1.Disconnect;
  FWaitCursor := nil;
end;

function TBaseDataModule.EnumAll(var ASendDataList: TSendDataList): Integer;
var
  LFormatSettings: TFormatSettings;
  LSendData: TSendData;
begin
  LFormatSettings.LongDateFormat := 'yyyy-mm-dd';
  LFormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  LFormatSettings.DateSeparator := '-';
  LFormatSettings.LongTimeFormat := 'hh:nn:ss';
  LFormatSettings.ShortTimeFormat := 'hh:nn:ss';
  LFormatSettings.TimeSeparator := ':';

  Result := 0;
  if not TableIsExist then
    Exit;

  with FDQuery1 do
  begin
    Open('Select * From ' + FTableName);
    ASendDataList := TSendDataList.Create;
    First;
    Result := 0;
    while not Eof do
      with LSendData do
      begin
        State := ssError;
        if FieldByName('Success').AsWideString.ToBoolean then
          State := ssSuccess;
        DisplayName := FieldByName('DisplayName').AsWideString;
        Address := FieldByName('Address').AsWideString;
        ErrorCode := FieldByName('ErrorCode').AsInteger;
        ErrorText := FieldByName('ErrorText').AsWideString;
        Time := StrToDateTime(FieldByName('Time').AsWideString, LFormatSettings);
        ASendDataList.Add(LSendData);
        Inc(Result);
        Next;
      end;
    Close;
  end;
end;

function TBaseDataModule.EnumAllSuccessMailAddress: TStrings;
begin
  Result := TStringList.Create;
  if not TableIsExist then
    Exit;

  with FDQuery1 do
  begin
    Open('Select * From ' + FTableName + ' Where Success like ''True''');
    First;
    while not Eof do
    begin
      Result.Append(FieldByName('Address').AsWideString);
      Next;
    end;
    Close;
  end;
end;

function TBaseDataModule.EnumAtDate(ADate: string; var ASendDataList: TSendDataList): Integer;
var
  LFormatSettings: TFormatSettings;
  LSendData: TSendData;
begin
  LFormatSettings.LongDateFormat := 'yyyy-mm-dd';
  LFormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  LFormatSettings.DateSeparator := '-';
  LFormatSettings.LongTimeFormat := 'hh:nn:ss';
  LFormatSettings.ShortTimeFormat := 'hh:nn:ss';
  LFormatSettings.TimeSeparator := ':';

  Result := 0;
  if not TableIsExist then
    Exit;

  if ADate.Trim = '' then
    ADate := FormatDateTime('yyyy-mm-dd', Now);

  with FDQuery1 do
  begin
    Open('Select * From ' + FTableName + ' Where Time like ''' + ADate + '%''');
    ASendDataList := TSendDataList.Create;
    First;
    Result := 0;
    while not Eof do
      with LSendData do
      begin
        State := ssError;
        if FieldByName('Success').AsWideString.ToBoolean then
          State := ssSuccess;
        DisplayName := FieldByName('DisplayName').AsWideString;
        Address := FieldByName('Address').AsWideString;
        ErrorCode := FieldByName('ErrorCode').AsInteger;
        ErrorText := FieldByName('ErrorText').AsWideString;
        Time := StrToDateTime(FieldByName('Time').AsWideString, LFormatSettings);
        ASendDataList.Add(LSendData);
        Inc(Result);
        Next;
      end;
    Close;
  end;
end;

function TBaseDataModule.Login: Boolean;
begin
  try
    FWaitCursor.StartWait;
    with IdSMTP1 do
    try
      Host := FSmtpData.Host;
      Port := FSmtpData.Port;
      Username := FSmtpData.Username;
      Password := FSmtpData.Password;
      IOHandler := nil;
      if FSmtpData.UseSSL then
      begin
        IdSSLIOHandlerSocketOpenSSL1.SSLOptions.Method := sslvSSLv23;
        IOHandler := IdSSLIOHandlerSocketOpenSSL1;
        if FSmtpData.UseStartTLS then
          UseTLS := utUseRequireTLS
        else
          UseTLS := utUseImplicitTLS;
      end
      else
        UseTLS := utNoTLSSupport;

      ReadTimeout := 5000;
      Connect;

      Authenticate;
      CreateDefaultTable;
    except
      on rt: EIdReadTimeout do
        MessageBox(0, '与服务器连接超时，请重试', '', 0);

      on nc: EIdNotConnected do
        MessageBox(0, '与服务器连接失败，请重试', '', 0);

      else
        MessageBox(0, '登录失败，请重试', '', 0);
    end;
  finally
    Result := IdSMTP1.Connected;
    FWaitCursor.StopWait;
  end;
end;

function TBaseDataModule.QueryBeenSend(AAddress: string; var ASendDataList: TSendDataList): Integer;
var
  LFormatSettings: TFormatSettings;
  LSendData: TSendData;
begin
  LFormatSettings.LongDateFormat := 'yyyy-mm-dd';
  LFormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  LFormatSettings.DateSeparator := '-';
  LFormatSettings.LongTimeFormat := 'hh:nn:ss';
  LFormatSettings.ShortTimeFormat := 'hh:nn:ss';
  LFormatSettings.TimeSeparator := ':';

  Result := 0;
  if not TableIsExist then
    Exit;

  with FDQuery1 do
  begin
    Open('Select * From ' + FTableName + ' Where Address like ''%' + AAddress.Replace('@', '_') + '%''');
    ASendDataList := TSendDataList.Create;
    First;
    Result := 0;
    while not Eof do
      with LSendData do
      begin
        State := ssError;
        if FieldByName('Success').AsWideString.ToBoolean then
          State := ssSuccess;
        DisplayName := FieldByName('DisplayName').AsWideString;
        Address := FieldByName('Address').AsWideString;
        ErrorCode := FieldByName('ErrorCode').AsInteger;
        ErrorText := FieldByName('ErrorText').AsWideString;
        Time := StrToDateTime(FieldByName('Time').AsWideString, LFormatSettings);
        ASendDataList.Add(LSendData);
        Inc(Result);
        Next;
      end;
    Close;
  end;
end;

function TBaseDataModule.SendAll: Integer;
begin
  Result := 0;
  if not TableIsExist then
    Exit;

  FDQuery1.Open('Select * From ' + FTableName);
  Result := FDQuery1.RecordCount;
  FDQuery1.Close;
end;

function TBaseDataModule.Send(Address, DisplayName: string): TSendData;
var
  sdList: TSendDataList;
  ret: Boolean;
begin
  if DisplayName.Trim = '' then
    DisplayName := Address.Remove(Address.IndexOf('@'));

  Result.DisplayName := DisplayName;
  Result.Address := Address;

  with FDQuery1 do
  try
    FWaitCursor.StartWait;
    if QueryBeenSend(Address, sdList) > 0 then
    begin
      Result := sdList[sdList.Count - 1];
      if Result.State = ssSuccess then
      begin
        if not FSettingsData.RepeatSend then
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
      ret := True;
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
      Sql.Text := 'Insert Into ' + FTableName + '(DisplayName,Address,Success,ErrorCode,ErrorText,Time) Values(:DisplayName,:Address,:Success,:ErrorCode,:ErrorText,:Time)';
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
    FWaitCursor.StopWait;
  end;
end;

function TBaseDataModule.SendAtDate(ADate: string): Integer;
begin
  Result := 0;
  if not TableIsExist then
    Exit;

  if ADate.Trim = '' then
    ADate := FormatDateTime('yyyy-mm-dd', Now);

  FDQuery1.Open('Select * From ' + FTableName + ' Where Time like ''' + ADate + '%''');
  Result := FDQuery1.RecordCount;
  FDQuery1.Close;
end;

procedure TBaseDataModule.SetMailData(AMailData: TMailData);
begin
  FMailData := AMailData;
  with FMailData do
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

procedure TBaseDataModule.SetSettingsData(ASettingsData: TSettingsData);
begin
  FSettingsData := ASettingsData;
  with FSettingsData do
  begin
    with TMemIniFile.Create('.\Config\Settings.ini', TEncoding.Unicode) do
    try
      WriteBool('Send', 'RepeatSend', RepeatSend);
      WriteBool('Send', 'AutoStop', AutoStop);
      WriteInteger('Send', 'StopNumber', StopNumber);
      WriteBool('Send', 'UseInterval', UseInterval);
      WriteInteger('Send', 'IntervalTime', IntervalTime);

      WriteString('Import', 'DefaultPostfix', DefaultPostfix);
      WriteBool('Import', 'AutoPostfix', AutoPostfix);
      WriteBool('Import', 'AutoWrap', AutoWrap);
      WriteBool('Import', 'FilterRepeat', FilterRepeat);
      WriteBool('Import', 'CheckImportedList', CheckImportedList);

      WriteBool('Display', 'UseCustomTheme', UseCustomTheme);
      WriteString('Display', 'CustomTheme', CustomTheme);
      WriteBool('Display', 'UseColor', UseColor);
      UpdateFile;
    finally
      Free;
    end;
  end;
end;

procedure TBaseDataModule.SetSmtpData(ASmtpData: TSmtpData);
var
  LStringStream: TStringStream;
begin
  FSmtpData := ASmtpData;
  with FSmtpData do
  begin
    LStringStream := TStringStream.Create('', TEncoding.Unicode);
    with TMemIniFile.Create(LStringStream, TEncoding.Unicode) do
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
      LStringStream.LoadFromStream(Stream);
      TBytesStream.Create(LStringStream.Bytes.XOREncrypt).SaveToFile('.\Config\Smtp.smss');
      Free;
    end;
  end;
end;

function TBaseDataModule.TableIsExist: Boolean;
begin
  FTableName := 'BeenSend_' + StrToBin(FSmtpData.Username);
  FDQuery1.Open('Select * From sqlite_master Where tbl_name = ''' + FTableName + '''');
  Result := FDQuery1.RecordCount > 0;
  FDQuery1.Close;
end;

procedure TBaseDataModule.UpdateMessage(ASubject, ABody: string; AAttachmentDataList: TAttachmentDataList);
var
  LAttachmentData: PAttachmentData;
  LMemoryStream: TMemoryStream;
begin
  with IdMessage1 do
  begin
    Clear;
    Sender.Name := FSmtpData.DisplayName;
    Sender.Address := FSmtpData.Username;
    Recipients.Clear;
    Recipients.Add;
    Priority := mpNormal;
    Subject := ASubject;
    MessageParts.Clear;
  end;

  with TIdMessageBuilderHtml.Create do
  try
    Clear;
    if FMailData.IsHtml then
    begin
      HtmlCharSet := 'UTF-8';
      Html.Text := ABody;
    end
    else
    begin
      PlainTextCharSet := 'UTF-8';
      PlainText.Text := ABody;
    end;

    for LAttachmentData in AAttachmentDataList do
    begin
      LMemoryStream := TMemoryStream.Create;
      with LMemoryStream do
      begin
        LoadFromFile(LAttachmentData.Path);
        Attachments.Add(LMemoryStream, '', LAttachmentData.Id);
      end;
    end;
    FillMessage(IdMessage1);
  finally
    Free;
  end;
end;

procedure TBaseDataModule.UpdateMailData;
begin
  with FMailData do
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

procedure TBaseDataModule.UpdateSettingsData;
begin
  with FSettingsData do
  begin
    with TMemIniFile.Create('.\Config\Settings.ini', TEncoding.Unicode) do
    try
      RepeatSend := ReadBool('Send', 'RepeatSend', False);
      AutoStop := ReadBool('Send', 'AutoStop', True);
      StopNumber := ReadInteger('Send', 'StopNumber', 40);
      UseInterval := ReadBool('Send', 'UseInterval', False);
      IntervalTime := ReadInteger('Send', 'IntervalTime', 10);

      DefaultPostfix := ReadString('Import', 'DefaultPostfix', 'qq.com');
      AutoPostfix := ReadBool('Import', 'AutoPostfix', True);
      AutoWrap := ReadBool('Import', 'AutoWrap', True);
      FilterRepeat := ReadBool('Import', 'FilterRepeat', True);
      CheckImportedList := ReadBool('Add', 'CheckImportedList', True);

      UseCustomTheme := ReadBool('Display', 'UseCustomTheme', False);
      CustomTheme := ReadString('Display', 'CustomTheme', '');
      UseColor := ReadBool('Display', 'UseColor', True);
    finally
      Free;
    end;
  end;
end;

procedure TBaseDataModule.UpdateSmtpData;
var
  LBytesStream: TBytesStream;
begin
  with FSmtpData do
  begin
    if not TFile.Exists('.\Config\Smtp.smss') then
      TFile.Create('.\Config\Smtp.smss').Free;

    LBytesStream := TBytesStream.Create(TFile.ReadAllBytes('.\Config\Smtp.smss').XORDecrypt);
    with TMemIniFile.Create(LBytesStream, TEncoding.Unicode) do
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

