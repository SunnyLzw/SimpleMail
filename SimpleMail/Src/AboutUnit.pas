unit AboutUnit;

interface

uses
  System.Classes, FMX.Types, FMX.Forms, FMX.Objects, FMX.StdCtrls, FMX.Layouts,
  FMX.Controls, FMX.Controls.Presentation;

type
  TAboutForm = class(TForm)
    Image1: TImage;
    MainLayout: TLayout;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Rectangle1: TRectangle;
    Label6: TLabel;
    Label7: TLabel;
    Button1: TButton;
    procedure LinkLabelClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
  Winapi.ShellAPI;

{$R *.fmx}

procedure TAboutForm.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TAboutForm.LinkLabelClick(Sender: TObject);
begin
  ShellExecute(0, nil, PChar((Sender as TLabel).Text), nil, nil, 1);
end;

end.

