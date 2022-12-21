unit UnitType;

interface

uses
  System.Generics.Collections;

type
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

  TSendLogList = TList<PSendLog>;

  TAttachmentDataList = TList<PAttachmentData>;

implementation

end.

