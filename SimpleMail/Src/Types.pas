unit Types;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections;

type
  TAutoComplete = procedure of object;

  TSettingsData = record
    DefaultPostfix: string;
    AutoPostfix, RepeatSend, AutoWrap, FilterRepeat, CheckImportedList, UseCustomTheme, UseColor, AutoStop, UseInterval: Boolean;
    CustomTheme: string;
    StopNumber, IntervalTime: Integer;
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

  TSendState = (System, Success, Error, Repeated);

  PSendData = ^TSendData;

  TSendData = record
    State: TSendState;
    DisplayName, Address: string;
    ErrorCode: Integer;
    ErrorText: string;
    Time: TDateTime;
  end;

  PSendLog = ^TSendLog;

  TSendLog = record
    ImageState: Integer;
    Time: TDateTime;
    Address, State, Information: string;
  end;

  PAttachmentData = ^TAttachmentData;

  TAttachmentData = record
    Id, Path: string;
  end;

  PSendDataList = ^TSendDataList;

  TSendDataList = TList<TSendData>;

  TSendLogList = TList<PSendLog>;

  TAttachmentDataList = TList<PAttachmentData>;

  TByteArray = TArray<Byte>;

  IBase = interface
    ['{3C52642F-1EF3-42D2-B6E3-4E4A9D021544}']
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
    function EnumAllSuccessMailAddress: TStrings;
  end;

  ISmtp = interface
    ['{B01FB75A-0399-439F-AAE6-2F2EDA3C90FF}']
    function Login: Boolean;
    procedure UpdateMessage(ASubject, ABody: string; SAttachmentDataList: TAttachmentDataList);
    function Send(Address: string; DisplayName: string = ''): TSendData;
  end;

implementation

end.

