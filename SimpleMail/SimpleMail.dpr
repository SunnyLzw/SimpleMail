program SimpleMail;
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  Vcl.Forms,
  Winapi.Windows,
  UnitAbout in 'Src\UnitAbout.pas' {FormAbout},
  UnitEncrypt in 'Src\UnitEncrypt.pas',
  UnitImport in 'Src\UnitImport.pas' {FormImport},
  UnitLogin in 'Src\UnitLogin.pas' {FormLogin},
  UnitMain in 'Src\UnitMain.pas' {FormMain},
  UnitPlugin in 'Src\UnitPlugin.pas',
  UnitSettings in 'Src\UnitSettings.pas' {FormSettings},
  UnitSmtp in 'Src\UnitSmtp.pas' {DataModuleSmtp: TDataModule},
  UnitTips in 'Src\UnitTips.pas' {FormTips},
  UnitType in 'Src\UnitType.pas';

{$R *.res}

var
  Mutex: THandle;

begin
  Mutex := CreateMutex(nil, True, '{04262155-48E5-4D75-94C0-9EC0BA6B5E2D}');
  if GetLastError <> ERROR_ALREADY_EXISTS then
  begin
    Application.Initialize;
    Application.CreateForm(TDataModuleSmtp, DataModuleSmtp);
    Application.Title := 'µÇÂ¼';
    if ShowLoginDialog then
    begin
      Application.Title := 'SimpleMail';
      Application.MainFormOnTaskbar := True;
      Application.CreateForm(TFormMain, FormMain);
      Application.Run;
    end;
  end;
  ReleaseMutex(Mutex);
end.

