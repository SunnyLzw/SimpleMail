unit UnitType;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections;

type
  TAutoComplete = procedure of object;

  TSettingsData = record
    DefaultPostfix: string;
    AutoPostfix, RepeatSend, AutoWrap, FilterRepeat, CheckImportedList, UseCustomTheme, UseColor, AutoStop, UseInterval: Boolean;
    CustomTheme, StopNumber, IntervalTime: Integer;
  end;

  TSmtpData = record
    DisplayName, Username, Password, Host: string;
    Port: Integer;
    UseSSL, UseStartTLS: Boolean;
  end;

  TMailData = record
    Attachments, Subject, Body: string;
    IsHtml: Boolean;
  end;

  TState = (ssSuccess = $50, ssRepeat, ssError, ssStop);

  PSendData = ^TSendData;

  TSendData = record
    State: TState;
    DisplayName, Address: string;
    ErrorCode: Integer;
    ErrorText: string;
    Time: TDateTime;
  end;

  PSendLog = ^TSendLog;

  TSendLog = record
    Time, Address, State, Log: string;
    Data: PSendData;
  end;

  PAttachmentData = ^TAttachmentData;

  TAttachmentData = record
    Id, Path: string;
  end;

  TSendDataList = TList<TSendData>;

  TSendLogList = TList<PSendLog>;

  TAttachmentDataList = TList<PAttachmentData>;

  TByteArray = TArray<Byte>;

  IForm = interface
    ['{444C733E-795D-4B58-BF82-AFB79C6AB0ED}']
    procedure Create;
    procedure Destroy;
    function GetObject: TObject;
  end;

  IDialog = interface
    ['{3D02B1E6-44EB-4DD0-9338-8F7F5A8960EB}']
    function Show: TObject;
  end;

  ISmtp = interface
    ['{3C52642F-1EF3-42D2-B6E3-4E4A9D021544}']
    function Login: Boolean;
    procedure UpdateMessage(ASubject, ABody: string; SAttachmentDataList: TAttachmentDataList);
    function Send(Address: string; DisplayName: string = ''): TSendData;
    function GetPostfixs: TStrings;
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
  end;

  ITips = interface
    ['{1BFA1839-F9B6-414C-87E6-034AC3C6AB28}']
    procedure SetAutoComplete(AAutoComplete: TAutoComplete);
    procedure SetPostfixs(APostfixs: TStrings);
    function GetPostfix: string;
  end;

  IImport = interface
    ['{9BDB3246-7661-4729-A0E1-F4C0EE11C24D}']
    function AutoPostfixs(Str: string): TStrings;
  end;

implementation

end.

