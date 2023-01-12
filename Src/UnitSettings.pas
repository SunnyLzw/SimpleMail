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
    IsModifed: Boolean;
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
  {$IFDEF DEBUG}
  UnitBase, {$ENDIF}Vcl.Imaging.pngimage, System.IniFiles, System.IOUtils;

{$R *.dfm}

procedure TFormSettings.ButtonLoadClick(Sender: TObject);
var
  bs: TBytesStream;
begin
  if FileOpenDialog1.Execute then
  begin
    with FPackageBase.Base.GetSmtpData do
    begin
      if FileOpenDialog1.FileTypeIndex = 1 then
        bs := TBytesStream.Create(TFile.ReadAllBytes(FileOpenDialog1.FileName))
      else
        bs := TBytesStream.Create(TFile.ReadAllBytes(FileOpenDialog1.FileName).XORDecrypt);
      with TMemIniFile.Create(bs, TEncoding.Unicode) do
      try
        IsModifed := False;
        EditUsername.Text := ReadString('Base', 'Username', '');
        EditPassword.Text := ReadString('Base', 'Password', '');
        EditHost.Text := ReadString('Base', 'Host', '');
        EditPort.Text := ReadInteger('Base', 'Port', 0).ToString;
        RadioGroupUseSSL.ItemIndex := (not ReadBool('SSL', 'UseSSL', False)).ToInteger;
        CheckBoxUseStartTLS.Enabled := ReadBool('SSL', 'UseSSL', False);
        CheckBoxUseStartTLS.Checked := ReadBool('SSL', 'UseStartTLS', False);
        EditDisplayName.Text := ReadString('Display', 'DisplayName', '');
        IsModifed := True;
        ModifySmtpData(nil);
      finally
        Free;
      end;
    end;
  end;
end;

procedure TFormSettings.ButtonSaveClick(Sender: TObject);
var
  ss: TStringStream;
begin
  if FileSaveDialog1.Execute then
  begin
    with FPackageBase.Base.GetSmtpData do
    begin
      ss := TStringStream.Create('', TEncoding.Unicode);
      with TMemIniFile.Create(ss, TEncoding.Unicode) do
      try
        WriteString('Base', 'Username', Username);
        WriteString('Base', 'Password', Password);
        WriteString('Base', 'Host', Host);
        WriteInteger('Base', 'Port', Port);
        WriteBool('SSL', 'UseSSL', UseSSL);
        WriteBool('SSL', 'UseStartTLS', UseStartTLS);
        WriteString('Display', 'DisplayName', DisplayName);
        UpdateFile;
      finally
        ss.LoadFromStream(Stream);
        if FileSaveDialog1.FileTypeIndex = 1 then
          TBytesStream.Create(ss.Bytes).SaveToFile(FileSaveDialog1.FileName)
        else
          TBytesStream.Create(ss.Bytes.XOREncrypt).SaveToFile(FileSaveDialog1.FileName);
        Free;
      end;
    end;
  end;
end;

procedure TFormSettings.CreateTree;

  procedure CreateChild(APageControl: TPageControl);
  var
    ts: TTabSheet;
    tn: TTreeNode;
  begin
    if APageControl.Parent.Name <> 'PanelPage' then
      APageControl.Tag := NativeInt(APageControl.Parent.Tag);

    for var i := 0 to APageControl.PageCount - 1 do
    begin
      ts := APageControl.Pages[i];
      ts.TabVisible := False;
      tn := TreeView1.Items.AddChildObject(TTreeNode(APageControl.Tag), ts.Caption, ts);
      ts.Tag := NativeInt(tn);
    end;
    APageControl.Pages[0].Visible := True;
  end;

var
  pc: TPageControl;
begin
  for var i := 0 to ComponentCount - 1 do
  begin
    if not (Components[i] is TPageControl) then
      Continue;

    pc := Components[i] as TPageControl;
    CreateChild(pc);
  end;
end;

procedure TFormSettings.FormCreate(Sender: TObject);
begin
  FPackageBase := UnitPackage.TBase.Create;
  ComboBox1.Items.AddStrings(['Flat', 'Standard', 'UltraFlat', 'Office11']);

  CreateTree;
  TreeView1.Select(TTreeNode(FindComponent('TabSheet5').Tag));
  if TFile.Exists('.\Res\Load.png') then
  begin
    var png: TPngImage;
    png := TPngImage.Create;
    png.LoadFromFile('.\Res\Load.png');
    ButtonLoad.Glyph.Assign(png);
    png.Free;
  end;

  if TFile.Exists('.\Res\Save.png') then
  begin
    var png: TPngImage;
    png := TPngImage.Create;
    png.LoadFromFile('.\Res\Save.png');
    ButtonSave.Glyph.Assign(png);
    png.Free;
  end;

  IsModifed := False;
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
  IsModifed := True;
end;

procedure TFormSettings.FormDestroy(Sender: TObject);
begin
  FPackageBase.Free;
end;

procedure TFormSettings.ModifySettingsData(Sender: TObject);
var
  sd: TSettingsData;
begin
  if not IsModifed then
    Exit;

  sd := FPackageBase.Base.GetSettingsData;
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
  FPackageBase.Base.SetSettingsData(sd);
end;

procedure TFormSettings.ModifySmtpData(Sender: TObject);
var
  sd: TSmtpData;
begin
  if not IsModifed then
    Exit;

  if EditPort.Text = '' then
  begin
    EditPort.Text := '0';
    EditPort.SelectAll;
  end;
  sd := FPackageBase.Base.GetSmtpData;
  with sd do
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
  FPackageBase.Base.SetSmtpData(sd);
end;

procedure TFormSettings.Splitter1CanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
begin
  Accept := Height - NewSize > 200;
end;

procedure TFormSettings.SwitchTabSheet(ATabSheet: TTabSheet);

  procedure ActiveParent(ATabSheet: TTabSheet);
  var
    pc: TPageControl;
    ts: TTabSheet;
  begin
    TreeView1.MultiSelect := False;
    ts := ATabSheet;
    pc := ts.Parent as TPageControl;
    pc.ActivePage := ts;
    if pc.Parent.Name = 'PanelPage' then
      Exit;

    ts := pc.Parent as TTabSheet;
    ActiveParent(ts);
  end;

var
  pc: TPageControl;
  ts: TTabSheet;
  tn: TTreeNode;
begin
  for var i := 0 to ComponentCount - 1 do
  begin
    if not (Components[i] is TPageControl) then
      Continue;

    pc := Components[i] as TPageControl;

    for var j := 0 to pc.PageCount - 1 do
    begin
      ts := pc.Pages[j];
      if ts = ATabSheet then
      begin
        tn := TTreeNode(ts.Tag);
        if tn.HasChildren then
        begin
          //TreeView1.Select(tn.getFirstChild);
          ts := tn.getFirstChild.Data;
        end;
        ActiveParent(ts);
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

