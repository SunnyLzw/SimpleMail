program SimpleMail;
{$STRONGLINKTYPES ON}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}

uses
  Vcl.Forms,
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  {$IFDEF DEBUG}
  UnitMain,
  {$ENDIF }
  UnitType,
  UnitPackage,
  UnitBase in 'Src\UnitBase.pas' {DataModuleBase: TDataModule};

{$R *.res}

var
  GMutex: THandle;

begin
  GMutex := CreateMutex(nil, True, '{04262155-48E5-4D75-94C0-9EC0BA6B5E2D}');
  if GetLastError <> ERROR_ALREADY_EXISTS then
  begin
    Application.Initialize;
    Application.Title := 'SimpleMail';
    Application.MainFormOnTaskbar := True;
    with UnitPackage.TBase.Create do
    try
      with UnitPackage.TForm.Create('Main') do
      try
        Application.Run;
      finally
        Free;
      end;
    finally
      Free;
    end;
  end;
  ReleaseMutex(GMutex);
end.

