unit UnitLogin;

interface

uses
  UnitType, UnitTools, UnitPackage, Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, System.ImageList,
  Vcl.ImgList, Vcl.Buttons;

type
  TFormLogin = class(TForm)
    PanelMain: TPanel;
    Label5: TLabel;
    Label4: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    Label1: TLabel;
    EditDisplayName: TEdit;
    EditHost: TEdit;
    EditPassword: TEdit;
    EditPort: TEdit;
    EditUsername: TEdit;
    RadioGroupUseSSL: TRadioGroup;
    CheckBoxUseStartTLS: TCheckBox;
    ButtonLogin: TButton;
    ButtonCanel: TButton;
    ButtonSave: TSpeedButton;
    ButtonLoad: TSpeedButton;
    FileOpenDialog1: TFileOpenDialog;
    FileSaveDialog1: TFileSaveDialog;
    procedure ModifySmtpData(Sender: TObject);
    procedure ButtonLoginClick(Sender: TObject);
    procedure ButtonCanelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonLoadClick(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    IsModifed: Boolean;
    FPackageSmtp: TSmtp;
  public
    { Public declarations }
  end;

  TLogin = class(TInterfacedPersistent, IForm, IDialog)
  private
    FFormLogin: TFormLogin;
  public
    procedure Create;
    procedure Destroy; reintroduce;
    function GetObject: TObject;
    function Show: TObject;
  end;

implementation

uses
  {$IFDEF DEBUG}
  UnitSmtp, {$ENDIF}Vcl.Imaging.pngimage, System.IniFiles, System.IOUtils;

{$R *.dfm}

procedure TFormLogin.ButtonLoadClick(Sender: TObject);
var
  bs: TBytesStream;
begin
  if FileOpenDialog1.Execute then
  begin
    with FPackageSmtp.Smtp.GetSmtpData do
    begin
      if FileOpenDialog1.FileTypeIndex = 1 then
        bs := TBytesStream.Create(TFile.ReadAllBytes(FileOpenDialog1.FileName))
      else
        bs := TBytesStream.Create(TFile.ReadAllBytes(FileOpenDialog1.FileName).XORDecrypt);
      with TMemIniFile.Create(bs, TEncoding.Unicode) do
      try
        IsModifed := False;
        EditUsername.Text := ReadString('Smtp', 'Username', '');
        EditPassword.Text := ReadString('Smtp', 'Password', '');
        EditHost.Text := ReadString('Smtp', 'Host', '');
        EditPort.Text := ReadInteger('Smtp', 'Port', 0).ToString;
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
  ButtonLogin.SetFocus;
end;

procedure TFormLogin.ButtonLoginClick(Sender: TObject);
var
  str: string;
begin
  str := EditUsername.Text;
  if str.Trim = '' then
  begin
    ShowMessage('用户名不能为空');
    Exit;
  end;

  str := EditPassword.Text;
  if str.Trim = '' then
  begin
    ShowMessage('密码不能为空');
    Exit;
  end;

  str := EditHost.Text;
  if str.Trim = '' then
  begin
    ShowMessage('服务器不能为空');
    Exit;
  end;

  try
    ModalResult := mrCancel;
    if FPackageSmtp.Smtp.Login then
      ModalResult := mrOk;
  except
    ShowMessage('登陆失败，请重启软件重试');
    Exit;
  end;
end;

procedure TFormLogin.ButtonSaveClick(Sender: TObject);
var
  ss: TStringStream;
begin
  if FileSaveDialog1.Execute then
  begin
    with FPackageSmtp.Smtp.GetSmtpData do
    begin
      ss := TStringStream.Create('', TEncoding.Unicode);
      with TMemIniFile.Create(ss, TEncoding.Unicode) do
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
        ss.LoadFromStream(Stream);
        if FileSaveDialog1.FileTypeIndex = 1 then
          TBytesStream.Create(ss.Bytes).SaveToFile(FileSaveDialog1.FileName)
        else
          TBytesStream.Create(ss.Bytes.XOREncrypt).SaveToFile(FileSaveDialog1.FileName);
        Free;
      end;
    end;
  end;
  ButtonLogin.SetFocus;
end;

procedure TFormLogin.FormCreate(Sender: TObject);
begin
  FPackageSmtp := UnitPackage.TSmtp.Create;

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

  ModalResult := mrCancel;
  IsModifed := False;
  with FPackageSmtp.Smtp.GetSmtpData do
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
  IsModifed := True;
end;

procedure TFormLogin.FormDestroy(Sender: TObject);
begin
  FPackageSmtp.Free;
end;

procedure TFormLogin.ButtonCanelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TFormLogin.ModifySmtpData(Sender: TObject);
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
  sd := FPackageSmtp.Smtp.GetSmtpData;
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
  FPackageSmtp.Smtp.SetSmtpData(sd);
end;

{ TLogin }

procedure TLogin.Create;
begin
  FFormLogin := TFormLogin.Create(Application);
end;

procedure TLogin.Destroy;
begin
  FFormLogin.Free;
  FFormLogin := nil;
end;

function TLogin.GetObject: TObject;
begin
  Result := FFormLogin;
end;

function TLogin.Show: TObject;
begin
  FFormLogin.ShowModal;
  Result := TObject(FFormLogin.ModalResult = mrOk);
end;

initialization
  RegisterClass(TLogin);


finalization
  UnRegisterClass(TLogin);

end.

