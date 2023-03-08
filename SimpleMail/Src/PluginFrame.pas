unit PluginFrame;

interface

uses
  FMX.Forms, FMX.Menus, System.Classes;

type
  TInheriteState = (IsDefault, IsIndex, IsName);

  {$Align 4}
  TPluginData = record
    CanChecked: Boolean;
    IsMultiLevel: Boolean;
    InheriteState: TInheriteState;
    ParentIndex: Integer;
    ParentName: string;
    Name: string;
    Names: TStrings;
    Hint: string;
  end;

  IPlugin = interface
    ['{353D65E4-FAC1-4EB0-9CAF-E54911BB83CA}']
    function GetPluginData: TPluginData;
    procedure SetPluginData(APluginData: TPluginData);
    function GetBaseDataModule: TDataModule;
    procedure SetBaseDataModule(const ABaseDataModule: TDataModule);
    function GetMainForm: TForm;
    procedure SetMainForm(const AMainForm: TForm);
    function GetMenuItem: TMenuItem;
    procedure SetMenuItem(const AMenuItem: TMenuItem);
    function GetChecked: Boolean;
    procedure SetChecked(State: Boolean);
  end;

  IPluginEvent = interface
    ['{8AEB9497-6C87-426B-A253-A518E45F9395}']
    procedure OnLoad;
    procedure OnUnLoad;
    procedure Execute;
  end;

  IPluginMenuEvent = interface
    ['{3CC5ADD0-4192-4256-92E2-590754B945E4}']
    procedure OnClick;
    procedure OnChecked;
  end;

  TPlugin = class(TInterfacedObject, IPlugin, IPluginEvent, IPluginMenuEvent)
  protected
    FPluginData: TPluginData;
    FBaseDataModule: TDataModule;
    FMainForm: TForm;
    FMenuItem: TMenuItem;
  protected
    procedure OnLoad; virtual;
    procedure OnUnLoad; virtual;
    procedure Execute; virtual;
    procedure OnClick; virtual;
    procedure OnChecked; virtual;
  public
    function GetPluginData: TPluginData; virtual;
    procedure SetPluginData(APluginData: TPluginData); virtual;
    function GetBaseDataModule: TDataModule; virtual;
    procedure SetBaseDataModule(const ABaseDataModule: TDataModule); virtual;
    function GetMainForm: TForm; virtual;
    procedure SetMainForm(const AMainForm: TForm); virtual;
    function GetMenuItem: TMenuItem; virtual;
    procedure SetMenuItem(const AMenuItem: TMenuItem); virtual;
    function GetChecked: Boolean; virtual;
    procedure SetChecked(State: Boolean); virtual;
  public
    property PluginData: TPluginData read GetPluginData write SetPluginData;
  end;

implementation

{ TPlugin }

procedure TPlugin.Execute;
begin

end;

function TPlugin.GetBaseDataModule: TDataModule;
begin
  Result := FBaseDataModule;
end;

function TPlugin.GetChecked: Boolean;
begin
  Result := False;
  if not Assigned(FMenuItem) then
    Exit;

  Result := FMenuItem.IsChecked;
end;

function TPlugin.GetMainForm: TForm;
begin
  Result := FMainForm;
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

procedure TPlugin.SetBaseDataModule(const ABaseDataModule: TDataModule);
begin
  FBaseDataModule := ABaseDataModule;
end;

procedure TPlugin.SetChecked(State: Boolean);
begin
  if not Assigned(FMenuItem) then
    Exit;

  FMenuItem.IsChecked := State;
end;

procedure TPlugin.SetMainForm(const AMainForm: TForm);
begin
  FMainForm := AMainForm;
end;

procedure TPlugin.SetMenuItem(const AMenuItem: TMenuItem);
begin
  FMenuItem := AMenuItem;
end;

procedure TPlugin.SetPluginData(APluginData: TPluginData);
begin
  FPluginData := APluginData;
end;

end.

