unit SettingsUnit;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.Forms,
  FMX.Dialogs, FMX.TabControl, FMX.Layouts, FMX.ListBox, FMX.StdCtrls,
  FMX.Objects, FMX.Edit, FMX.ImgList, FMX.TreeView, FMX.Controls.Presentation,
  System.ImageList;

type
  TSettingsForm = class(TForm)
    MainRectangle: TRectangle;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    TabItem4: TTabItem;
    TabControl2: TTabControl;
    TabItem5: TTabItem;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    UsernameEdit: TEdit;
    PasswordEdit: TEdit;
    HostEdit: TEdit;
    PortEdit: TEdit;
    DisplayNameEdit: TEdit;
    GroupBox1: TGroupBox;
    UseSSLRadioButton: TRadioButton;
    NotUseSSLRadioButton: TRadioButton;
    UseStartTLSCheckBox: TCheckBox;
    LoadSpeedButton: TSpeedButton;
    ImageList1: TImageList;
    SaveSpeedButton: TSpeedButton;
    RepeatSendCheckBox: TCheckBox;
    AutoStopCheckBox: TCheckBox;
    UseIntervalCheckBox: TCheckBox;
    StopNumberEdit: TEdit;
    IntervalTimeEdit: TEdit;
    SpinEditButton1: TSpinEditButton;
    SpinEditButton2: TSpinEditButton;
    AutoPostfixCheckBox: TCheckBox;
    AutoWrapCheckBox: TCheckBox;
    FilterRepeatCheckBox: TCheckBox;
    CheckImportedListCheckBox: TCheckBox;
    DefaultPostfixEdit: TEdit;
    UseCustomThemeCheckBox: TCheckBox;
    UseColorCheckBox: TCheckBox;
    TreeView1: TTreeView;
    ComboBox1: TComboBox;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    MainLayout: TLayout;
    procedure ModifySettingsData(Sender: TObject);
    procedure ModifySmtpData(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TreeView1Change(Sender: TObject);
    procedure SpinEditButtonDownClick(Sender: TObject);
    procedure SpinEditButtonUpClick(Sender: TObject);
    procedure NumberEditKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure LoadSpeedButtonClick(Sender: TObject);
    procedure SaveSpeedButtonClick(Sender: TObject);
  private
    { Private declarations }
    FIsModifed: Boolean;
  public
    { Public declarations }
    procedure CreateTree;
    procedure SwitchTabSheet(ATabItem: TTabItem);
  end;

implementation

uses
  Types, Tools, BaseUnit, System.IOUtils, System.IniFiles;

{$R *.fmx}

{ TSettingsForm }

procedure TSettingsForm.CreateTree;

  procedure CreateChild(ATabControl: TTabControl);
  var
    LTabItem: TTabItem;
    LTreeViewItem: TTreeViewItem;
    i: Integer;
  begin
    ATabControl.TagObject := TreeView1;
    if ATabControl.Parent.Name <> 'MainRectangle' then
      ATabControl.TagObject := ATabControl.Parent.Parent.TagObject;

    for i := 0 to ATabControl.TabCount - 1 do
    begin
      LTabItem := ATabControl.Tabs[i];
      LTreeViewItem := TTreeViewItem.Create(Self);
      LTreeViewItem.Parent := ATabControl.TagObject as TFmxObject;
      LTreeViewItem.Text := LTabItem.Text;
      LTreeViewItem.TagObject := LTabItem;
      LTabItem.TagObject := LTreeViewItem;
    end;
  end;

var
  LTabControl: TTabControl;
  i: Integer;
begin
  for i := 0 to ComponentCount - 1 do
  begin
    if not (Components[i] is TTabControl) then
      Continue;

    LTabControl := Components[i] as TTabControl;
    LTabControl.TabPosition := TTabPosition.None;
    CreateChild(LTabControl);
  end;
end;

procedure TSettingsForm.FormCreate(Sender: TObject);
var
  LStyle: string;
  LStyles: TArray<string>;
begin
  if TDirectory.Exists('.\Style') then
  begin
    LStyles := TDirectory.GetFiles('.\Style', '*.Style');
    for LStyle in LStyles do
      ComboBox1.Items.Add(ChangeFileExt(ExtractFileName(LStyle), ''));
  end;

  CreateTree;
  TreeView1.Selected := TabItem5.TagObject as TTreeViewItem;

  FIsModifed := False;
  with GBaseDataModule.SmtpData do
  begin
    DisplayNameEdit.Text := DisplayName;
    UsernameEdit.Text := Username;
    PasswordEdit.Text := Password;
    HostEdit.Text := Host;
    PortEdit.Text := Port.ToString;
    UseSSLRadioButton.IsChecked := UseSSL;
    NotUseSSLRadioButton.IsChecked := not UseSSL;
    UseStartTLSCheckBox.Enabled := UseSSL;
    UseStartTLSCheckBox.IsChecked := UseStartTLS;
  end;

  if StopNumberEdit.Text = '' then
    StopNumberEdit.Text := '0';
  if IntervalTimeEdit.Text = '' then
    IntervalTimeEdit.Text := '0';

  with GBaseDataModule.SettingsData do
  begin
    DefaultPostfixEdit.Text := DefaultPostfix;
    AutoPostfixCheckBox.IsChecked := AutoPostfix;
    DefaultPostfixEdit.Enabled := AutoPostfix;
    RepeatSendCheckBox.IsChecked := RepeatSend;
    AutoWrapCheckBox.IsChecked := AutoWrap;
    FilterRepeatCheckBox.IsChecked := FilterRepeat;
    CheckImportedListCheckBox.IsChecked := CheckImportedList;
    CheckImportedListCheckBox.Enabled := FilterRepeat;
    UseColorCheckBox.IsChecked := UseColor;
    UseCustomThemeCheckBox.IsChecked := UseCustomTheme;
    ComboBox1.ItemIndex := ComboBox1.Items.IndexOf(CustomTheme);
    if ComboBox1.ItemIndex = -1 then
    begin
      if ComboBox1.Items.Count > 0 then
        ComboBox1.ItemIndex := 0
      else
        UseCustomThemeCheckBox.IsChecked := False;
    end;
    ComboBox1.Enabled := UseCustomTheme;
    AutoStopCheckBox.IsChecked := AutoStop;
    StopNumberEdit.Text := StopNumber.ToString;
    StopNumberEdit.Enabled := AutoStop;
    UseIntervalCheckBox.IsChecked := UseInterval;
    IntervalTimeEdit.Text := IntervalTime.ToString;
    IntervalTimeEdit.Enabled := UseInterval;
  end;
  Self.Resize;
  FIsModifed := True;
end;

procedure TSettingsForm.LoadSpeedButtonClick(Sender: TObject);
var
  LBytesStream: TBytesStream;
begin
  if OpenDialog1.Execute then
  begin
    SetCurrentDir(ExtractFilePath(ParamStr(0)));
    if OpenDialog1.FilterIndex = 1 then
      LBytesStream := TBytesStream.Create(TFile.ReadAllBytes(OpenDialog1.FileName))
    else
      LBytesStream := TBytesStream.Create(TFile.ReadAllBytes(OpenDialog1.FileName).XORDecrypt);

    with TMemIniFile.Create(LBytesStream, TEncoding.Unicode) do
    try
      FIsModifed := False;
      UsernameEdit.Text := ReadString('Smtp', 'Username', '');
      PasswordEdit.Text := ReadString('Smtp', 'Password', '');
      HostEdit.Text := ReadString('Smtp', 'Host', '');
      PortEdit.Text := ReadInteger('Smtp', 'Port', 0).ToString;
      UseSSLRadioButton.IsChecked := ReadBool('SSL', 'UseSSL', False);
      UseStartTLSCheckBox.Enabled := ReadBool('SSL', 'UseSSL', False);
      UseStartTLSCheckBox.IsChecked := ReadBool('SSL', 'UseStartTLS', False);
      DisplayNameEdit.Text := ReadString('Display', 'DisplayName', '');
      FIsModifed := True;
      ModifySmtpData(nil);
    finally
      Free;
    end;
  end;
end;

procedure TSettingsForm.ModifySettingsData(Sender: TObject);
var
  LSettingsData: TSettingsData;
begin
  if not FIsModifed then
    Exit;

  if StopNumberEdit.Text = '' then
    StopNumberEdit.Text := '1'
  else if StopNumberEdit.Text.ToInteger > 500 then
    StopNumberEdit.Text := '500'
  else if StopNumberEdit.Text.ToInteger < 1 then
    StopNumberEdit.Text := '1';

  if IntervalTimeEdit.Text = '' then
    IntervalTimeEdit.Text := '1'
  else if IntervalTimeEdit.Text.ToInteger > 5000 then
    IntervalTimeEdit.Text := '5000'
  else if IntervalTimeEdit.Text.ToInteger < 1 then
    IntervalTimeEdit.Text := '1';

  LSettingsData := GBaseDataModule.SettingsData;
  with LSettingsData do
  begin
    DefaultPostfix := DefaultPostfixEdit.Text;
    AutoPostfix := AutoPostfixCheckBox.IsChecked;
    DefaultPostfixEdit.Enabled := AutoPostfix;
    RepeatSend := RepeatSendCheckBox.IsChecked;
    AutoWrap := AutoWrapCheckBox.IsChecked;
    FilterRepeat := FilterRepeatCheckBox.IsChecked;
    CheckImportedList := CheckImportedListCheckBox.IsChecked;
    UseColor := UseColorCheckBox.IsChecked;
    UseCustomTheme := UseCustomThemeCheckBox.IsChecked;
    CustomTheme := '';
    if Assigned(ComboBox1.Selected) then
      CustomTheme := ComboBox1.Selected.Text
    else
      UseCustomTheme := False;
    ComboBox1.Enabled := UseCustomTheme;
    AutoStop := AutoStopCheckBox.IsChecked;
    StopNumber := StopNumberEdit.Text.ToInteger;
    StopNumberEdit.Enabled := AutoStop;
    UseInterval := UseIntervalCheckBox.IsChecked;
    IntervalTime := IntervalTimeEdit.Text.ToInteger;
    IntervalTimeEdit.Enabled := UseInterval;
  end;
  GBaseDataModule.SetSettingsData(LSettingsData);
end;

procedure TSettingsForm.ModifySmtpData(Sender: TObject);
var
  LSettingsData: TSmtpData;
begin
  if not FIsModifed then
    Exit;

  if PortEdit.Text = '' then
    PortEdit.Text := '0';

  LSettingsData := GBaseDataModule.SmtpData;
  with LSettingsData do
  begin
    DisplayName := DisplayNameEdit.Text;
    Username := UsernameEdit.Text;
    Password := PasswordEdit.Text;
    Host := HostEdit.Text;
    Port := string(PortEdit.Text).ToInteger;
    UseSSL := UseSSLRadioButton.IsChecked;
    UseStartTLS := UseStartTLSCheckBox.IsChecked;
    UseStartTLSCheckBox.Enabled := UseSSL;
  end;
  GBaseDataModule.SetSmtpData(LSettingsData);
end;

procedure TSettingsForm.NumberEditKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if KeyChar = #0 then
    Exit;

  if CharInSet(KeyChar, ['0'..'9']) then
  begin
    if (Sender as TEdit).Text = '0' then
    begin
      (Sender as TEdit).Text := KeyChar;
      KeyChar := #0;
    end;
    Exit;
  end;

  KeyChar := #0;
end;

procedure TSettingsForm.SaveSpeedButtonClick(Sender: TObject);
var
  LStringStream: TStringStream;
begin
  if SaveDialog1.Execute then
  begin
    with GBaseDataModule.SmtpData do
    begin
      LStringStream := TStringStream.Create('', TEncoding.Unicode);
      with TMemIniFile.Create(LStringStream, TEncoding.Unicode) do
      try
        WriteString('Smtp', 'Username', Username);
        WriteString('Smtp', 'Password', Password);
        WriteString('Smtp', 'Host', Host);
        WriteInteger('Smtp', 'Port', Port);
        WriteBool('SSL', 'UseSSL', UseSSL);
        WriteBool('SSL', 'UseStartTLS', UseStartTLS);
        WriteString('Display', 'DisplayName', DisplayName);
        UpdateFile;
      finally
        LStringStream.LoadFromStream(Stream);
        if SaveDialog1.FilterIndex = 1 then
          TBytesStream.Create(LStringStream.Bytes).SaveToFile(SaveDialog1.FileName)
        else
          TBytesStream.Create(LStringStream.Bytes.XOREncrypt).SaveToFile(SaveDialog1.FileName);
        Free;
      end;
    end;
  end;
end;

procedure TSettingsForm.SpinEditButtonDownClick(Sender: TObject);
var
  i: Integer;
begin
  if Sender = SpinEditButton1 then
  begin
    i := string(StopNumberEdit.Text).ToInteger;
    Dec(i, 5);
    StopNumberEdit.Text := i.ToString;
  end
  else
  begin
    i := string(IntervalTimeEdit.Text).ToInteger;
    Dec(i, 10);
    IntervalTimeEdit.Text := i.ToString;
  end;
end;

procedure TSettingsForm.SpinEditButtonUpClick(Sender: TObject);
var
  i: Integer;
begin
  if Sender = SpinEditButton1 then
  begin
    i := string(StopNumberEdit.Text).ToInteger;
    Inc(i, 5);
    StopNumberEdit.Text := i.ToString;
  end
  else
  begin
    i := string(IntervalTimeEdit.Text).ToInteger;
    Inc(i, 10);
    IntervalTimeEdit.Text := i.ToString;
  end;
end;

procedure TSettingsForm.SwitchTabSheet(ATabItem: TTabItem);

  procedure ActiveParent(ATabItem: TTabItem);
  var
    LTabControl: TTabControl;
    LTabItem: TTabItem;
  begin
    LTabItem := ATabItem;
    LTabControl := LTabItem.Parent.Parent as TTabControl;
    LTabControl.ActiveTab := LTabItem;
    if LTabControl.Parent.Name = 'MainRectangle' then
      Exit;

    LTabItem := LTabControl.Parent.Parent as TTabItem;
    ActiveParent(LTabItem);
  end;

var
  LTabControl: TTabControl;
  LTabItem: TTabItem;
  LTreeViewItem: TTreeViewItem;
  i, j: Integer;
begin
  for i := 0 to ComponentCount - 1 do
  begin
    if not (Components[i] is TTabControl) then
      Continue;

    LTabControl := Components[i] as TTabControl;

    for j := 0 to LTabControl.TabCount - 1 do
    begin
      LTabItem := LTabControl.Tabs[j];
      if LTabItem = ATabItem then
      begin
        LTreeViewItem := LTabItem.TagObject as TTreeViewItem;
        if LTreeViewItem.Count > 0 then
        begin
          LTabItem := LTreeViewItem.Items[0].TagObject as TTabItem;
        end;
        ActiveParent(LTabItem);
        Exit;
      end;
    end;
  end;
end;

procedure TSettingsForm.TreeView1Change(Sender: TObject);
begin
  SwitchTabSheet(TreeView1.Selected.TagObject as TTabItem);
end;

end.

