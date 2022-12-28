unit Plugin;

interface

uses
  Vcl.Forms, Vcl.Menus, System.Classes;

type
  {$Align 4}
  TPluginData = record
    CanChecked: Boolean;
    ParentIndex: Integer;
    ParentName: string;
    GroupName: string;
    Name: string;
    Hint: string;
    HasWindow: Boolean;
  end;

  IPlugin = interface
    ['{353D65E4-FAC1-4EB0-9CAF-E54911BB83CA}']
    function GetPluginData: TPluginData;
    procedure SetPluginData(APluginData: TPluginData);
    function GetMainForm: TCustomForm;
    procedure SetMainForm(AMainForm: TCustomForm);
    function GetMainMenu: TMainMenu;
    procedure SetMainMenu(AMainForm: TMainMenu);
    function GetMenuItem: TMenuItem;
    procedure SetMenuItem(AMenuItem: TMenuItem);
    function GetChecked: Boolean;
    procedure SetChecked(State: Boolean);
    procedure OnLoad;
    procedure OnUnLoad;
    procedure Execute;
    procedure OnClick;
    procedure OnChecked;
  end;

  TPlugin = class(TInterfacedPersistent, IPlugin)
  protected
    FPluginData: TPluginData;
    FMainForm: TCustomForm;
    FMainMenu: TMainMenu;
    FMenuItem: TMenuItem;
  public
    function GetPluginData: TPluginData; virtual;
    procedure SetPluginData(APluginData: TPluginData); virtual;
    function GetMainForm: TCustomForm; virtual;
    procedure SetMainForm(AMainForm: TCustomForm); virtual;
    function GetMainMenu: TMainMenu; virtual;
    procedure SetMainMenu(AMainMenu: TMainMenu); virtual;
    function GetMenuItem: TMenuItem; virtual;
    procedure SetMenuItem(AMenuItem: TMenuItem); virtual;
    function GetChecked: Boolean; virtual;
    procedure SetChecked(State: Boolean); virtual;
    procedure OnLoad; virtual;
    procedure OnUnLoad; virtual;
    procedure Execute; virtual;
    procedure OnClick; virtual;
    procedure OnChecked; virtual;
  public
    property PluginData: TPluginData read GetPluginData write SetPluginData;
    property MainForm: TCustomForm read GetMainForm write SetMainForm;
  end;

implementation

{ TPlugin }

procedure TPlugin.Execute;
begin

end;

function TPlugin.GetChecked: Boolean;
begin
  Result := False;
  if not Assigned(FMenuItem) then
    Exit;

  Result := FMenuItem.Checked;
end;

function TPlugin.GetMainForm: TCustomForm;
begin
  Result := FMainForm;
end;

function TPlugin.GetMainMenu: TMainMenu;
begin
  Result := FMainMenu;
end;

function TPlugin.GetMenuItem: TMenuItem;
begin
  Result := FMenuItem;
end;

function TPlugin.GetPluginData: TPluginData;
begin
  Result := FPluginData;
end;

procedure TPlugin.OnChecked;
begin
  if not Assigned(FMenuItem) then
    Exit;

  SetChecked(not GetChecked);
end;

procedure TPlugin.OnClick;
begin
  if not Assigned(FMenuItem) then
    Exit;

  if FPluginData.CanChecked then
    OnChecked;
end;

procedure TPlugin.OnLoad;
begin

end;

procedure TPlugin.OnUnLoad;
begin

end;

procedure TPlugin.SetChecked(State: Boolean);
begin
  if not Assigned(FMenuItem) then
    Exit;

  FMenuItem.Checked := State;
end;

procedure TPlugin.SetMainForm(AMainForm: TCustomForm);
begin
  FMainForm := AMainForm;
end;

procedure TPlugin.SetMainMenu(AMainMenu: TMainMenu);
begin
  FMainMenu := AMainMenu;
end;

procedure TPlugin.SetMenuItem(AMenuItem: TMenuItem);
begin
  FMenuItem := AMenuItem;
end;

procedure TPlugin.SetPluginData(APluginData: TPluginData);
begin
  FPluginData := APluginData;
end;

end.

