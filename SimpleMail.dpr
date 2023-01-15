program SimpleMail;
{$IFDEF DEBUG}
  {$STRONGLINKTYPES ON}
{$ELSE}
  {$IF CompilerVersion >= 21.0}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
  {$ENDIF}
{$ENDIF}

uses
  UnitType,
  UnitTools,
{$IFDEF DEBUG}
  UnitBase,
  UnitMain,
{$ENDIF}
  Vcl.Forms,
  Winapi.Windows,
  System.SysUtils,
  System.Classes;

{$R *.res}

var
  GMutex: THandle;

begin
  GMutex := CreateMutex(nil, True, '{04262155-48E5-4D75-94C0-9EC0BA6B5E2D}');
  if GetLastError <> ERROR_ALREADY_EXISTS then
    with UnitTools.TBase.Create do
    try
      Application.Initialize;
      Application.Title := 'SimpleMail';
      Application.MainFormOnTaskbar := True;
      with UnitTools.TForm.Create('Main') do
      try
        Application.Run;
      finally
        Free;
      end;
    finally
      Free;
    end;
  ReleaseMutex(GMutex);
end.

