unit UnitAbout;

interface

uses
  UnitType, System.Classes, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Controls,
  Vcl.Imaging.pngimage;

type
  TFormAbout = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Button1: TButton;
    Label4: TLabel;
    LinkLabel2: TLinkLabel;
    Label5: TLabel;
    LinkLabel1: TLinkLabel;
    procedure Button1Click(Sender: TObject);
    procedure LinkLabelLinkClick(Sender: TObject; const Link: string; LinkType: TSysLinkType);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TAbout = class(TInterfacedObject, IForm, IDialog)
  private
    FFormAbout: TFormAbout;
  public
    procedure Create;
    procedure Destroy; reintroduce;
    function GetObject: TObject;
    function Show: TObject;
  end;

implementation

uses
  Winapi.ShellAPI;

{$R *.dfm}

procedure TFormAbout.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TFormAbout.LinkLabelLinkClick(Sender: TObject; const Link: string; LinkType: TSysLinkType);
begin
  ShellExecute(0, nil, PChar(Link), nil, nil, 1);
end;

{ TAbout }

procedure TAbout.Create;
begin
  FFormAbout := TFormAbout.Create(Application);
end;

procedure TAbout.Destroy;
begin
  FFormAbout.Free;
  FFormAbout := nil;
end;

function TAbout.GetObject: TObject;
begin
  Result := FFormAbout;
end;

function TAbout.Show: TObject;
begin
  FFormAbout.ShowModal;
  Result := TObject(FFormAbout.ModalResult = mrOk);
end;

end.

