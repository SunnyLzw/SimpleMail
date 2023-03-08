program SimpleMail;

uses
  System.StartUpCopy,
  FMX.Forms,
  MainUnit in 'Src\MainUnit.pas' {MainForm},
  BaseUnit in 'Src\BaseUnit.pas' {BaseDataModule: TDataModule},
  AboutUnit in 'Src\AboutUnit.pas' {AboutForm},
  ImportUnit in 'Src\ImportUnit.pas' {ImportForm},
  SettingsUnit in 'Src\SettingsUnit.pas' {SettingsForm},
  TipsUnit in 'Src\TipsUnit.pas' {TipsForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TBaseDataModule, GBaseDataModule);
  Application.CreateForm(TMainForm, GMainForm);
  Application.Run;
end.

