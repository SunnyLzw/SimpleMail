unit UnitSettings;

interface

uses
  UnitType, UnitPackage, Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Samples.Spin, Vcl.ExtCtrls;

type
  TFormSettings = class(TForm)
    PanelMain: TPanel;
    Splitter1: TSplitter;
    PanelList: TPanel;
    TreeView1: TTreeView;
    PanelPage: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    ButtonQuit: TButton;
    ButtonSwitch: TButton;
    TabSheet2: TTabSheet;
    CheckBoxRepeatSend: TCheckBox;
    CheckBoxAutoStop: TCheckBox;
    CheckBoxUseInterval: TCheckBox;
    SpinEditStopNumber: TSpinEdit;
    SpinEditIntervalTime: TSpinEdit;
    TabSheet3: TTabSheet;
    CheckBoxAutoPostfix: TCheckBox;
    EditDefaultPostfix: TEdit;
    CheckBoxAutoWrap: TCheckBox;
    CheckBoxFilterRepeat: TCheckBox;
    CheckBoxCheckImportedList: TCheckBox;
    TabSheet4: TTabSheet;
    CheckBoxUseCustomTheme: TCheckBox;
    CheckBoxUseColor: TCheckBox;
    ComboBox1: TComboBox;
    procedure ModifySettingsData(Sender: TObject);
    procedure ButtonSwitchClick(Sender: TObject);
    procedure ButtonQuitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure Splitter1CanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    IsModifed: Boolean;
    FPackageSmtp: TSmtp;
  public
    { Public declarations }
  end;

  TSettings = class(TInterfacedPersistent, IForm, IDialog)
  private
    FFormSettings: TFormSettings;
  public
    procedure Create;
    procedure Destroy; reintroduce;
    function GetObject: TObject;
    function Show: TObject;
  end;

implementation
{$IFDEF DEBUG}

uses
  UnitSmtp, UnitLogin;
{$ENDIF}

{$R *.dfm}

procedure TFormSettings.ButtonQuitClick(Sender: TObject);
begin
  Close;
  Application.Terminate;
end;

procedure TFormSettings.ButtonSwitchClick(Sender: TObject);
begin
  Close;
  with TDialog.Create('Login') do
  try
    Dialog.Show;
  finally
    Free;
  end;
end;

procedure TFormSettings.FormCreate(Sender: TObject);
begin
  FPackageSmtp := UnitPackage.TSmtp.Create;

  for var i := 0 to PageControl1.PageCount - 1 do
  begin
    TreeView1.Items.Add(nil, PageControl1.Pages[i].Caption);
    PageControl1.Pages[i].TabVisible := False;
  end;
  ComboBox1.Items.AddStrings(['Flat', 'Standard', 'UltraFlat', 'Office11']);

  IsModifed := False;
  with FPackageSmtp.Smtp.GetSettingsData do
  begin
    EditDefaultPostfix.Text := DefaultPostfix;
    CheckBoxAutoPostfix.Checked := AutoPostfix;
    EditDefaultPostfix.Enabled := AutoPostfix;
    CheckBoxRepeatSend.Checked := RepeatSend;
    CheckBoxAutoWrap.Checked := AutoWrap;
    CheckBoxFilterRepeat.Checked := FilterRepeat;
    CheckBoxCheckImportedList.Checked := CheckImportedList;
    CheckBoxCheckImportedList.Enabled := FilterRepeat;
    CheckBoxUseColor.Checked := UseColor;
    CheckBoxUseCustomTheme.Checked := UseCustomTheme;
    ComboBox1.ItemIndex := CustomTheme;
    ComboBox1.Enabled := UseCustomTheme;
    CheckBoxAutoStop.Checked := AutoStop;
    SpinEditStopNumber.Value := StopNumber;
    SpinEditStopNumber.Enabled := AutoStop;
    CheckBoxUseInterval.Checked := UseInterval;
    SpinEditIntervalTime.Value := IntervalTime;
    SpinEditIntervalTime.Enabled := UseInterval;
  end;
  IsModifed := True;
end;

procedure TFormSettings.FormDestroy(Sender: TObject);
begin
  FPackageSmtp.Free;
end;

procedure TFormSettings.ModifySettingsData(Sender: TObject);
var
  sd: TSettingsData;
begin
  if not IsModifed then
    Exit;

  sd := FPackageSmtp.Smtp.GetSettingsData;
  with sd do
  begin
    DefaultPostfix := EditDefaultPostfix.Text;
    AutoPostfix := CheckBoxAutoPostfix.Checked;
    EditDefaultPostfix.Enabled := AutoPostfix;
    RepeatSend := CheckBoxRepeatSend.Checked;
    AutoWrap := CheckBoxAutoWrap.Checked;
    FilterRepeat := CheckBoxFilterRepeat.Checked;
    CheckImportedList := CheckBoxCheckImportedList.Checked;
    UseColor := CheckBoxUseColor.Checked;
    UseCustomTheme := CheckBoxUseCustomTheme.Checked;
    CustomTheme := ComboBox1.ItemIndex;
    ComboBox1.Enabled := UseCustomTheme;
    AutoStop := CheckBoxAutoStop.Checked;
    StopNumber := SpinEditStopNumber.Value;
    SpinEditStopNumber.Enabled := AutoStop;
    UseInterval := CheckBoxUseInterval.Checked;
    IntervalTime := SpinEditIntervalTime.Value;
    SpinEditIntervalTime.Enabled := UseInterval;
  end;
  FPackageSmtp.Smtp.SetSettingsData(sd);
end;

procedure TFormSettings.Splitter1CanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
begin
  Accept := Width - NewSize > 200;
end;

procedure TFormSettings.TreeView1Change(Sender: TObject; Node: TTreeNode);
begin
  PageControl1.ActivePageIndex := TreeView1.Selected.Index;
end;

{ TSettings }

procedure TSettings.Create;
begin
  FFormSettings := TFormSettings.Create(Application);
end;

procedure TSettings.Destroy;
begin
  FFormSettings.Free;
  FFormSettings := nil;
end;

function TSettings.GetObject: TObject;
begin
  Result := FFormSettings;
end;

function TSettings.Show: TObject;
begin
  FFormSettings.ShowModal;
  Result := TObject(FFormSettings.ModalResult = mrOk);
end;

initialization
  RegisterClass(TSettings);


finalization
  UnRegisterClass(TSettings);

end.

