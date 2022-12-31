unit UnitAbout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Controls,
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

var
  FormAbout: TFormAbout;

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

end.

