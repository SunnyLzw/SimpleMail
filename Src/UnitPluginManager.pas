unit UnitPluginManager;

interface

uses
  System.Classes, Winapi.Windows, System.SysUtils, System.Generics.Collections,
  System.IOUtils, UnitPluginFrame;

type
  PPluginObject = ^TPluginObject;

  TPluginObject = record
    ModuleHandle: HMODULE;
    PluginInterface: IPlugin;
    PluginData: TPluginData;
  end;

  TPluginManager = class(TObject)
  protected
    FPlugins: TList<PPluginObject>;
  public
    constructor Create(APluginPath: string);
    destructor Destroy; override;
    procedure EnumPlugin(APluginPath: string);
  public
    property Plugins: TList<PPluginObject> read FPlugins;
  end;

implementation

{ TPluginManager }

constructor TPluginManager.Create(APluginPath: string);
begin
  EnumPlugin(APluginPath);
end;

destructor TPluginManager.Destroy;
begin
  for var i in FPlugins do
  begin
    i.PluginInterface.OnUnLoad;
    i.PluginInterface := nil;
    UnloadPackage(i.ModuleHandle);
    Dispose(i);
  end;

  FPlugins.Free;
  inherited;
end;

procedure TPluginManager.EnumPlugin(APluginPath: string);
begin
  FPlugins := TList<PPluginObject>.Create;
  if not DirectoryExists(APluginPath) then
    Exit;

  var fs := TDirectory.GetFiles(APluginPath, '*.bpl');
  for var i in fs do
  begin
    var po: PPluginObject;
    New(po);
    po.ModuleHandle := LoadPackage(i);
    if po.ModuleHandle <= 0 then
      Continue;

    var str := ExtractFileName(i);
    str := 'TPlugin' + str.Remove(str.IndexOf('.'));
    var c := FindClass(str);
    if not Assigned(c) then
    begin
      UnloadPackage(po.ModuleHandle);
      Continue;
    end;

    Supports(TPlugin(c.Create), StringToGUID('{353D65E4-FAC1-4EB0-9CAF-E54911BB83CA}'), po.PluginInterface);
    if not Assigned(po.PluginInterface) then
    begin
      UnloadPackage(po.ModuleHandle);
      Continue;
    end;

    po.PluginInterface.OnLoad;
    po.PluginData := po.PluginInterface.GetPluginData;
    FPlugins.Add(po);
  end;
end;

end.

