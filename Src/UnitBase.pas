unit UnitBase;

interface

uses
  UnitType, UnitTools, System.IniFiles, Winapi.Windows, Vcl.Forms,
  System.SysUtils, System.Classes, FireDAC.UI.Intf, FireDAC.Stan.Param, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, IdBaseComponent, IdSSLOpenSSL,
  FireDAC.Phys.SQLite, FireDAC.Comp.UI, IdMessage, IdTCPConnection, IdTCPClient,
  IdExplicitTLSClientServerBase, IdMessageClient, IdSMTP, IdSMTPBase,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait, IdComponent, IdIOHandler;

type
  TSmtp = class;

  TDataModuleBase = class(TDataModule, IBase, ISmtp)
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    IdMessage1: TIdMessage;
    IdSMTP1: TIdSMTP;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    FSmtp: ISmtp;
    TableName: string;
    IWait: IFDGUIxWaitCursor;
    SettingsData: TSettingsData;
    SmtpData: TSmtpData;
    MailData: TMailData;
    Postfixs: TStrings;
  public
    { Public declarations }
    function QueryBeenSend(AAddress: string): TSendDataList; overload;
    function QueryBeenSend(AAddress: string; var ASendDataList: TSendDataList): Integer; overload;
    procedure CreateDefaultTable;
    function TableIsExist: Boolean;
    function GetPostfixs: TStrings;
    procedure UpdateSettingsData;
    procedure UpdateSmtpData;
    procedure UpdateMailData;
    function GetSettingsData: TSettingsData;
    function GetSmtpData: TSmtpData;
    function GetMailData: TMailData;
    procedure SetSettingsData(ASettingsData: TSettingsData);
    procedure SetSmtpData(ASmtpData: TSmtpData);
    procedure SetMailData(AMailData: TMailData);
    function SendAll: Integer;
    function SendAtDate(ADate: string = ''): Integer;
    function EnumAll(var ASendDataList: TSendDataList): Integer;
    function EnumAtDate(ADate: string; var ASendDataList: TSendDataList): Integer;
    function EnumAllSuccessMailAddress: TStrings;
  public
    property Smtp: ISmtp read FSmtp implements ISmtp;
  end;

  TSmtp = class(TInterfacedObject, ISmtp)
  private
    FBase: TDataModuleBase;
  public
    constructor Create(ADataModuleBase: TDataModuleBase);
    destructor Destroy; override;
    function Login: Boolean;
    procedure UpdateMessage(ASubject, ABody: string; SAttachmentDataList: TAttachmentDataList);
    function Send(Address: string; DisplayName: string = ''): TSendData;
  end;

  TBase = class(TInterfacedObject, IForm, IBase, ISmtp)
  private
    FBase: IBase;
    FSmtp: ISmtp;
  public
    procedure Create;
    procedure Destroy; reintroduce;
    function GetObject: TObject;
  public
    property Base: IBase read FBase implements IBase;
    property Smtp: ISmtp read FSmtp implements ISmtp;
  end;

const
  DefaultPostfixs: TArray<string> = ['qq.com', '126.com', '163.com', 'sina.com', 'gmail.com', 'foxmail.com', 'hotmail.com', 'outlook.com'];

implementation

uses
  System.IOUtils, IdMessageBuilder, IdReplySmtp, IdExceptionCore,
  FireDAC.Stan.Factory;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

var
  GDataModuleBase: TDataModuleBase;
  GReferenceCount: Integer;

procedure TDataModuleBase.CreateDefaultTable;
begin
  if TableIsExist then
    Exit;

  with FDQuery1 do
  begin
    SQL.Text := 'Create Table If Not Exists ' + TableName + ' (Id integer Primary Key Autoincrement Not Null,DisplayName ntext,Address ntext,Success ntext,ErrorCode int,ErrorText ntext,Time ntext)';
    ExecSQL;
  end;
end;

procedure TDataModuleBase.DataModuleCreate(Sender: TObject);
begin
  Supports(TSmtp.Create(Self), StringToGUID('{B01FB75A-0399-439F-AAE6-2F2EDA3C90FF}'), FSmtp);
  if not TDirectory.Exists('.\Data') then
    TDirectory.CreateDirectory('.\Data');

  if not TDirectory.Exists('.\Config') then
    TDirectory.CreateDirectory('.\Config');

  if not TDirectory.Exists('.\Res') then
    TDirectory.CreateDirectory('.\Res');

  Postfixs := TStringList.Create;
  if not TFile.Exists('.\Config\Postfixs.ini') then
  begin
    Postfixs.AddStrings(DefaultPostfixs);
    Postfixs.SaveToFile('.\Config\Postfixs.ini', TEncoding.Unicode);
  end
  else
    Postfixs.LoadFromFile('.\Config\Postfixs.ini', TEncoding.Unicode);

  UpdateSettingsData;
  UpdateSmtpData;
  UpdateMailData;
  if not TFile.Exists('.\Config\Settings.ini') then
    SetSettingsData(SettingsData);

  if not TFile.Exists('.\Config\Smtp.ini') then
    SetSmtpData(SmtpData);

  if not TFile.Exists('.\Config\Mail.ini') then
    SetMailData(MailData);

  FDConnection1.Open;
  FDCreateInterface(IFDGUIxWaitCursor, IWait);
end;

procedure TDataModuleBase.DataModuleDestroy(Sender: TObject);
begin
  FSmtp := nil;
  IdSMTP1.Disconnect;
  IWait := nil;
end;

function TDataModuleBase.EnumAll(var ASendDataList: TSendDataList): Integer;
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

  Result := 0;
  if not TableIsExist then
    Exit;

  with FDQuery1 do
  begin
    Open('Select * From ' + TableName);
    ASendDataList := TSendDataList.Create;
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

function TDataModuleBase.EnumAllSuccessMailAddress: TStrings;
begin
  Result := TStringList.Create;
  if not TableIsExist then
    Exit;

  with FDQuery1 do
  begin
    Open('Select * From ' + TableName + ' Where Success like ''True''');
    First;
    while not Eof do
    begin
      Result.Append(FieldByName('Address').AsWideString);
      Next;
    end;
    Close;
  end;
end;

function TDataModuleBase.EnumAtDate(ADate: string; var ASendDataList: TSendDataList): Integer;
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

  Result := 0;
  if not TableIsExist then
    Exit;

  if ADate.Trim = '' then
    ADate := FormatDateTime('yyyy-mm-dd', Now);

  with FDQuery1 do
  begin
    Open('Select * From ' + TableName + ' Where Time like ''' + ADate + '%''');
    ASendDataList := TSendDataList.Create;
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

function TDataModuleBase.GetMailData: TMailData;
begin
  Result := MailData;
end;

function TDataModuleBase.GetPostfixs: TStrings;
begin
  Result := Postfixs;
end;

function TDataModuleBase.GetSettingsData: TSettingsData;
begin
  Result := SettingsData;
end;

function TDataModuleBase.GetSmtpData: TSmtpData;
begin
  Result := SmtpData;
end;

function TDataModuleBase.QueryBeenSend(AAddress: string; var ASendDataList: TSendDataList): Integer;
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

  Result := 0;
  if not TableIsExist then
    Exit;

  with FDQuery1 do
  begin
    Open('Select * From ' + TableName + ' Where Address like ''%' + AAddress.Replace('@', '_') + '%''');
    ASendDataList := TSendDataList.Create;
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

function TDataModuleBase.QueryBeenSend(AAddress: string): TSendDataList;
begin
  Result := nil;
  QueryBeenSend(AAddress, Result);
end;

function TDataModuleBase.SendAll: Integer;
begin
  Result := 0;
  if not TableIsExist then
    Exit;

  FDQuery1.Open('Select * From ' + TableName);
  Result := FDQuery1.RecordCount;
  FDQuery1.Close;
end;

function TDataModuleBase.SendAtDate(ADate: string): Integer;
begin
  Result := 0;
  if not TableIsExist then
    Exit;

  if ADate.Trim = '' then
    ADate := FormatDateTime('yyyy-mm-dd', Now);

  FDQuery1.Open('Select * From ' + TableName + ' Where Time like ''' + ADate + '%''');
  Result := FDQuery1.RecordCount;
  FDQuery1.Close;
end;

procedure TDataModuleBase.SetMailData(AMailData: TMailData);
begin
  MailData := AMailData;
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

procedure TDataModuleBase.SetSettingsData(ASettingsData: TSettingsData);
begin
  SettingsData := ASettingsData;
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

procedure TDataModuleBase.SetSmtpData(ASmtpData: TSmtpData);
var
  ss: TStringStream;
begin
  SmtpData := ASmtpData;
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

function TDataModuleBase.TableIsExist: Boolean;
begin
  TableName := 'BeenSend_' + StrToBin(SmtpData.Username);
  FDQuery1.SQL.Text := 'Select * From sqlite_master Where tbl_name = ''' + TableName + '''';
  Result := FDQuery1.RecordCount > 0;
end;

procedure TDataModuleBase.UpdateMailData;
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

procedure TDataModuleBase.UpdateSettingsData;
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

procedure TDataModuleBase.UpdateSmtpData;
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

{ TBase }

procedure TBase.Create;
begin
  if not Assigned(GDataModuleBase) then
  begin
    GDataModuleBase := TDataModuleBase.Create(Application);
    GReferenceCount := 0;
  end;

  Inc(GReferenceCount);
  Supports(GDataModuleBase, StringToGUID('{3C52642F-1EF3-42D2-B6E3-4E4A9D021544}'), FBase);
  Supports(GDataModuleBase, StringToGUID('{B01FB75A-0399-439F-AAE6-2F2EDA3C90FF}'), FSmtp);
end;

procedure TBase.Destroy;
begin
  FSmtp := nil;
  FBase := nil;
  Dec(GReferenceCount);

  if GReferenceCount = 0 then
  begin
    GDataModuleBase.Free;
    GDataModuleBase := nil;
  end;
end;

function TBase.GetObject: TObject;
begin
  Result := GDataModuleBase;
end;

{ TSmtp }

procedure TSmtp.UpdateMessage(ASubject, ABody: string; SAttachmentDataList: TAttachmentDataList);
begin
  with FBase do
  begin
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
end;

constructor TSmtp.Create(ADataModuleBase: TDataModuleBase);
begin
  FBase := ADataModuleBase;
end;

destructor TSmtp.Destroy;
begin
  FBase := nil;
  inherited;
end;

function TSmtp.Login: Boolean;
begin
  with FBase do
  try
    IWait.StartWait;
    with IdSMTP1 do
    try
      Host := SmtpData.Host;
      Port := SmtpData.Port;
      Username := SmtpData.Username;
      Password := SmtpData.Password;
      IOHandler := nil;
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
    IWait.StopWait;
  end;
end;

function TSmtp.Send(Address, DisplayName: string): TSendData;
var
  sdList: TSendDataList;
begin
  with FBase do
  begin
    if DisplayName.Trim = '' then
      DisplayName := Address.Remove(Address.IndexOf('@'));

    Result.DisplayName := DisplayName;
    Result.Address := Address;

    with FDQuery1 do
    try
      IWait.StartWait;
      if QueryBeenSend(Address, sdList) > 0 then
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
end;

end.

