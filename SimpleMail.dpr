program SimpleMail;
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  UnitType,
  UnitPackage,
{$IFDEF DEBUG}
  UnitSmtp,
  UnitLogin,
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
    with UnitPackage.TSmtp.Create do
    try
      Application.Initialize;
      Application.Title := 'µÇÂ¼';
      with UnitPackage.TDialog.Create('Login') do
      try
        if Assigned(Dialog.Show) then
        begin
          Application.Title := 'SimpleMail';
          Application.MainFormOnTaskbar := True;
          with UnitPackage.TForm.Create('Main') do
          try
            Application.Run;
          finally
            Free;
          end;
        end;
      finally
        Free;
      end;
    finally
      Free;
    end;
  ReleaseMutex(GMutex);
end.

