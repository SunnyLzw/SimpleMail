program SimpleMail;
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  UnitSmtp,
  UnitLogin,
  UnitMain,
  Vcl.Forms,
  Winapi.Windows;

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

