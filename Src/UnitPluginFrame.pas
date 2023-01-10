unit UnitPluginFrame;

interface

uses
  Vcl.Menus, System.Classes;

type
  {$Align 4}
  TPluginData = record
    CanChecked: Boolean;
    ParentIndex: Integer;
    ParentName: string;
    GroupName: string;
    Name: string;
    Hint: string;
  end;

  IPlugin = interface
    ['{353D65E4-FAC1-4EB0-9CAF-E54911BB83CA}']
    function GetPluginData: TPluginData;
    procedure SetPluginData(APluginData: TPluginData);
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
    FMenuItem: TMenuItem;
  public
    function GetPluginData: TPluginData; virtual;
    procedure SetPluginData(APluginData: TPluginData); virtual;
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

procedure TPlugin.SetMenuItem(AMenuItem: TMenuItem);
begin
  FMenuItem := AMenuItem;
end;

procedure TPlugin.SetPluginData(APluginData: TPluginData);
begin
  FPluginData := APluginData;
end;

end.

