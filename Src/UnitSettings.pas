unit UnitSettings;

interface

uses
  UnitType, UnitTools, UnitPackage, Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Samples.Spin,
  Vcl.ExtCtrls, Vcl.Buttons;

type
  TFormSettings = class(TForm)
    PanelMain: TPanel;
    PanelPage: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
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
    FileSaveDialog1: TFileSaveDialog;
    FileOpenDialog1: TFileOpenDialog;
    PanelList: TPanel;
    Splitter1: TSplitter;
    TreeView1: TTreeView;
    PageControl2: TPageControl;
    TabSheet5: TTabSheet;
    CheckBoxUseStartTLS: TCheckBox;
    RadioGroupUseSSL: TRadioGroup;
    EditUsername: TEdit;
    EditDisplayName: TEdit;
    EditHost: TEdit;
    EditPassword: TEdit;
    EditPort: TEdit;
    Label3: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label5: TLabel;
    ButtonLoad: TSpeedButton;
    ButtonSave: TSpeedButton;
    Label4: TLabel;
    procedure ModifySettingsData(Sender: TObject);
    procedure ModifySmtpData(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonLoadClick(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure Splitter1CanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
    procedure TreeView1Click(Sender: TObject);
  private
    { Private declarations }
    FIsModifed: Boolean;
    FPackageBase: TBase;
  public
    { Public declarations }
    procedure CreateTree;
    procedure SwitchTabSheet(ATabSheet: TTabSheet);
  end;

  TSettings = class(TInterfacedObject, IForm, IDialog)
  private
    FFormSettings: TFormSettings;
  public
    procedure Create;
    procedure Destroy; reintroduce;
    function GetObject: TObject;
    function Show: TObject;
  end;

implementation

uses
  Vcl.Imaging.pngimage, System.IniFiles, System.IOUtils;

{$R *.dfm}

procedure TFormSettings.ButtonLoadClick(Sender: TObject);
var
  LBytesStream: TBytesStream;
begin
  if FileOpenDialog1.Execute then
  begin
    if FileOpenDialog1.FileTypeIndex = 1 then
      LBytesStream := TBytesStream.Create(TFile.ReadAllBytes(FileOpenDialog1.FileName))
    else
      LBytesStream := TBytesStream.Create(TFile.ReadAllBytes(FileOpenDialog1.FileName).XORDecrypt);

    with TMemIniFile.Create(LBytesStream, TEncoding.Unicode) do
    try
      FIsModifed := False;
      EditUsername.Text := ReadString('Smtp', 'Username', '');
      EditPassword.Text := ReadString('Smtp', 'Password', '');
      EditHost.Text := ReadString('Smtp', 'Host', '');
      EditPort.Text := ReadInteger('Smtp', 'Port', 0).ToString;
      RadioGroupUseSSL.ItemIndex := (not ReadBool('SSL', 'UseSSL', False)).ToInteger;
      CheckBoxUseStartTLS.Enabled := ReadBool('SSL', 'UseSSL', False);
      CheckBoxUseStartTLS.Checked := ReadBool('SSL', 'UseStartTLS', False);
      EditDisplayName.Text := ReadString('Display', 'DisplayName', '');
      FIsModifed := True;
      ModifySmtpData(nil);
    finally
      Free;
    end;
  end;
end;

procedure TFormSettings.ButtonSaveClick(Sender: TObject);
var
  LStringStream: TStringStream;
begin
  if FileSaveDialog1.Execute then
  begin
    with FPackageBase.Base.GetSmtpData do
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
        if FileSaveDialog1.FileTypeIndex = 1 then
          TBytesStream.Create(LStringStream.Bytes).SaveToFile(FileSaveDialog1.FileName)
        else
          TBytesStream.Create(LStringStream.Bytes.XOREncrypt).SaveToFile(FileSaveDialog1.FileName);
        Free;
      end;
    end;
  end;
end;

procedure TFormSettings.CreateTree;

  procedure CreateChild(APageControl: TPageControl);
  var
    LTabSheet: TTabSheet;
    LTreeNode: TTreeNode;
    i: Integer;
  begin
    if APageControl.Parent.Name <> 'PanelPage' then
      APageControl.Tag := NativeInt(APageControl.Parent.Tag);

    for i := 0 to APageControl.PageCount - 1 do
    begin
      LTabSheet := APageControl.Pages[i];
      LTabSheet.TabVisible := False;
      LTreeNode := TreeView1.Items.AddChildObject(TTreeNode(APageControl.Tag), LTabSheet.Caption, LTabSheet);
      LTabSheet.Tag := NativeInt(LTreeNode);
    end;
    APageControl.Pages[0].Visible := True;
  end;

var
  LPageControl: TPageControl;
  i: Integer;
begin
  for i := 0 to ComponentCount - 1 do
  begin
    if not (Components[i] is TPageControl) then
      Continue;

    LPageControl := Components[i] as TPageControl;
    CreateChild(LPageControl);
  end;
end;

procedure TFormSettings.FormCreate(Sender: TObject);
var
  LPngImage: TPngImage;
begin
  FPackageBase := UnitPackage.TBase.Create;
  ComboBox1.Items.AddStrings(['Flat', 'Standard', 'UltraFlat', 'Office11']);

  CreateTree;
  TreeView1.Select(TTreeNode(FindComponent('TabSheet5').Tag));
  if TFile.Exists('.\Res\Load.png') then
  begin
    LPngImage := TPngImage.Create;
    LPngImage.LoadFromFile('.\Res\Load.png');
    ButtonLoad.Glyph.Assign(LPngImage);
    LPngImage.Free;
  end;

  if TFile.Exists('.\Res\Save.png') then
  begin
    LPngImage := TPngImage.Create;
    LPngImage.LoadFromFile('.\Res\Save.png');
    ButtonSave.Glyph.Assign(LPngImage);
    LPngImage.Free;
  end;

  FIsModifed := False;
  with FPackageBase.Base.GetSmtpData do
  begin
    EditDisplayName.Text := DisplayName;
    EditUsername.Text := Username;
    EditPassword.Text := Password;
    EditHost.Text := Host;
    EditPort.Text := Port.ToString;
    RadioGroupUseSSL.ItemIndex := (not UseSSL).ToInteger;
    CheckBoxUseStartTLS.Enabled := UseSSL;
    CheckBoxUseStartTLS.Checked := UseStartTLS;
  end;

  with FPackageBase.Base.GetSettingsData do
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
  FIsModifed := True;
end;

procedure TFormSettings.FormDestroy(Sender: TObject);
begin
  FPackageBase.Free;
end;

procedure TFormSettings.ModifySettingsData(Sender: TObject);
var
  LSettingsData: TSettingsData;
begin
  if not FIsModifed then
    Exit;

  LSettingsData := FPackageBase.Base.GetSettingsData;
  with LSettingsData do
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
  FPackageBase.Base.SetSettingsData(LSettingsData);
end;

procedure TFormSettings.ModifySmtpData(Sender: TObject);
var
  LSettingsData: TSmtpData;
begin
  if not FIsModifed then
    Exit;

  if EditPort.Text = '' then
  begin
    EditPort.Text := '0';
    EditPort.SelectAll;
  end;
  LSettingsData := FPackageBase.Base.GetSmtpData;
  with LSettingsData do
  begin
    DisplayName := EditDisplayName.Text;
    Username := EditUsername.Text;
    Password := EditPassword.Text;
    Host := EditHost.Text;
    Port := string(EditPort.Text).ToInteger;
    UseSSL := RadioGroupUseSSL.ItemIndex = 0;
    UseStartTLS := CheckBoxUseStartTLS.Checked;
    CheckBoxUseStartTLS.Enabled := UseSSL;
  end;
  FPackageBase.Base.SetSmtpData(LSettingsData);
end;

procedure TFormSettings.Splitter1CanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
begin
  Accept := Height - NewSize > 200;
end;

procedure TFormSettings.SwitchTabSheet(ATabSheet: TTabSheet);

  procedure ActiveParent(ATabSheet: TTabSheet);
  var
    LPageControl: TPageControl;
    LTabSheet: TTabSheet;
  begin
    TreeView1.MultiSelect := False;
    LTabSheet := ATabSheet;
    LPageControl := LTabSheet.Parent as TPageControl;
    LPageControl.ActivePage := LTabSheet;
    if LPageControl.Parent.Name = 'PanelPage' then
      Exit;

    LTabSheet := LPageControl.Parent as TTabSheet;
    ActiveParent(LTabSheet);
  end;

var
  LPageControl: TPageControl;
  LTabSheet: TTabSheet;
  LTreeNode: TTreeNode;
  i, j: Integer;
begin
  for i := 0 to ComponentCount - 1 do
  begin
    if not (Components[i] is TPageControl) then
      Continue;

    LPageControl := Components[i] as TPageControl;

    for j := 0 to LPageControl.PageCount - 1 do
    begin
      LTabSheet := LPageControl.Pages[j];
      if LTabSheet = ATabSheet then
      begin
        LTreeNode := TTreeNode(LTabSheet.Tag);
        if LTreeNode.HasChildren then
        begin
          //TreeView1.Select(LTreeNode.getFirstChild);
          LTabSheet := LTreeNode.getFirstChild.Data;
        end;
        ActiveParent(LTabSheet);
        Exit;
      end;
    end;
  end;
end;

procedure TFormSettings.TreeView1Click(Sender: TObject);
begin
  SwitchTabSheet(TreeView1.Selected.Data);
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

end.

