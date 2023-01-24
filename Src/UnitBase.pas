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
  FireDAC.VCLUI.Wait, IdComponent, IdIOHandler;

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

var
  GDataModuleBase: TDataModuleBase;
  GReferenceCount: Integer;

implementation

uses
  System.IOUtils, IdMessageBuilder, IdReplySmtp, IdExceptionCore,
  FireDAC.Stan.Factory;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDataModuleBase.CreateDefaultTable;
begin
  if TableIsExist then
    Exit;

  with FDQuery1 do
  begin
    SQL.Text := 'Create Table If Not Exists ' + FTableName + ' (Id integer Primary Key Autoincrement Not Null,DisplayName ntext,Address ntext,Success ntext,ErrorCode int,ErrorText ntext,Time ntext)';
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

  FPostfixs := TStringList.Create;
  if not TFile.Exists('.\Config\FPostfixs.ini') then
  begin
    FPostfixs.AddStrings(DefaultPostfixs);
    FPostfixs.SaveToFile('.\Config\FPostfixs.ini', TEncoding.Unicode);
  end
  else
    FPostfixs.LoadFromFile('.\Config\FPostfixs.ini', TEncoding.Unicode);

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

procedure TDataModuleBase.DataModuleDestroy(Sender: TObject);
begin
  FSmtp := nil;
  IdSMTP1.Disconnect;
  FWaitCursor := nil;
end;

function TDataModuleBase.EnumAll(var ASendDataList: TSendDataList): Integer;
var
  LFormatSettings: TFormatSettings;
  LSendData: TSendData;
begin
  LFormatSettings.LongDateFormat := 'yyyy-mm-dd';
  LFormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  LFormatSettings.DateSeparator := '-';
  LFormatSettings.LongTimeFormat := 'hh:nn:LStringStream';
  LFormatSettings.ShortTimeFormat := 'hh:nn:LStringStream';
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

function TDataModuleBase.EnumAllSuccessMailAddress: TStrings;
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

function TDataModuleBase.EnumAtDate(ADate: string; var ASendDataList: TSendDataList): Integer;
var
  LFormatSettings: TFormatSettings;
  LSendData: TSendData;
begin
  LFormatSettings.LongDateFormat := 'yyyy-mm-dd';
  LFormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  LFormatSettings.DateSeparator := '-';
  LFormatSettings.LongTimeFormat := 'hh:nn:LStringStream';
  LFormatSettings.ShortTimeFormat := 'hh:nn:LStringStream';
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

function TDataModuleBase.GetMailData: TMailData;
begin
  Result := FMailData;
end;

function TDataModuleBase.GetPostfixs: TStrings;
begin
  Result := FPostfixs;
end;

function TDataModuleBase.GetSettingsData: TSettingsData;
begin
  Result := FSettingsData;
end;

function TDataModuleBase.GetSmtpData: TSmtpData;
begin
  Result := FSmtpData;
end;

function TDataModuleBase.QueryBeenSend(AAddress: string; var ASendDataList: TSendDataList): Integer;
var
  LFormatSettings: TFormatSettings;
  LSendData: TSendData;
begin
  LFormatSettings.LongDateFormat := 'yyyy-mm-dd';
  LFormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  LFormatSettings.DateSeparator := '-';
  LFormatSettings.LongTimeFormat := 'hh:nn:LStringStream';
  LFormatSettings.ShortTimeFormat := 'hh:nn:LStringStream';
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

function TDataModuleBase.SendAll: Integer;
begin
  Result := 0;
  if not TableIsExist then
    Exit;

  FDQuery1.Open('Select * From ' + FTableName);
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

  FDQuery1.Open('Select * From ' + FTableName + ' Where Time like ''' + ADate + '%''');
  Result := FDQuery1.RecordCount;
  FDQuery1.Close;
end;

procedure TDataModuleBase.SetMailData(AMailData: TMailData);
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

procedure TDataModuleBase.SetSettingsData(ASettingsData: TSettingsData);
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

function TDataModuleBase.TableIsExist: Boolean;
begin
  FTableName := 'BeenSend_' + StrToBin(FSmtpData.Username);
  FDQuery1.SQL.Text := 'Select * From sqlite_master Where tbl_name = ''' + FTableName + '''';
  Result := FDQuery1.RecordCount > 0;
end;

procedure TDataModuleBase.UpdateMailData;
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

procedure TDataModuleBase.UpdateSettingsData;
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
      CustomTheme := ReadInteger('Display', 'CustomTheme', 2);
      UseColor := ReadBool('Display', 'UseColor', True);
    finally
      Free;
    end;
  end;
end;

procedure TDataModuleBase.UpdateSmtpData;
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

{ TBase }

procedure TBase.Create;
begin
  if not Assigned(GDataModuleBase) then
  begin
    GReferenceCount := 0;
    Application.CreateForm(TDataModuleBase, GDataModuleBase);
  end;

  Supports(GDataModuleBase, StringToGUID('{3C52642F-1EF3-42D2-B6E3-4E4A9D021544}'), FBase);
  Supports(GDataModuleBase, StringToGUID('{B01FB75A-0399-439F-AAE6-2F2EDA3C90FF}'), FSmtp);
  Inc(GReferenceCount);
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

      for var i in SAttachmentDataList do
      begin
        var LBytesStream := TMemoryStream.Create;
        with LBytesStream do
        begin
          LoadFromFile(i.Path);
          Attachments.Add(LBytesStream, '', i.Id);
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
        Sql.Text := 'Insert Into ' + FTableName + '(DisplayName,Address,Success,ErrorCode,ErrorText,Time) Values(:DisplayName,:Address,:Success,:ErrorCode,:ErrorText,:Time)';
        ParamByName('DisplayName').AsWideString := DisplayName;
        ParamByName('Address').AsWideString := Address;
        ParamByName('Success').AsWideString := ret.ToString(TUseBoolStrs.True);
        ParamByName('ErrorCode').AsInteger := ErrorCode;
        ParamByName('ErrorText').AsWideString := ErrorText;
        ParamByName('Time').AsWideString := FormatDateTime('yyyy-mm-dd hh:nn:LStringStream', Time);
        ExecSQL;
      end;
    finally
      Close;
      FWaitCursor.StopWait;
    end;
  end;
end;

end.

