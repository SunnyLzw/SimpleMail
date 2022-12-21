unit UnitSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Samples.Spin,


  Vcl.ExtCtrls;

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
  private
    { Private declarations }
  public
    { Public declarations }
    IsModifed: Boolean;
  end;

var
  FormSettings: TFormSettings;

implementation

uses
  UnitType, UnitSmtp, UnitLogin;
{$R *.dfm}

procedure TFormSettings.ButtonQuitClick(Sender: TObject);
begin
  Close;
  Application.Terminate;
end;

procedure TFormSettings.ButtonSwitchClick(Sender: TObject);
begin
  Close;
  ShowLoginDialog;
end;

procedure TFormSettings.FormCreate(Sender: TObject);
begin
  for var i := 0 to PageControl1.PageCount - 1 do
  begin
    TreeView1.Items.Add(nil, PageControl1.Pages[i].Caption);
    PageControl1.Pages[i].TabVisible := False;
  end;
  ComboBox1.Items.AddStrings(['Flat', 'Standard', 'UltraFlat', 'Office11']);

  IsModifed := False;
  with DataModuleSmtp.SettingsData do
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

procedure TFormSettings.ModifySettingsData(Sender: TObject);
begin
  if not IsModifed then
    Exit;

  with DataModuleSmtp.SettingsData do
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
  DataModuleSmtp.ModifySettingsData;
end;

procedure TFormSettings.Splitter1CanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
begin
  Accept := Width - NewSize > 200;
end;

procedure TFormSettings.TreeView1Change(Sender: TObject; Node: TTreeNode);
begin
  PageControl1.ActivePageIndex := TreeView1.Selected.Index;
end;

end.

