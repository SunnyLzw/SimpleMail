unit UnitPlugin;

interface

uses
  Winapi.Windows, System.SysUtils, System.Generics.Collections, System.IOUtils,
  Plugin;

type
  TPluginManager = class(TObject)
  protected
    FPlugins: TList<TPair<HMODULE, PPluginData>>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure EnumPlugin(APluginPath: string);
  end;

implementation

{ TPluginManager }

constructor TPluginManager.Create;
begin
  EnumPlugin('.\Plugins');
end;

destructor TPluginManager.Destroy;
begin
  for var i in FPlugins do
    CloseHandle(i.Key);

  FPlugins.Free;
  inherited;
end;

procedure TPluginManager.EnumPlugin(APluginPath: string);
begin
  FPlugins := TList<TPair<HMODULE, PPluginData>>.Create;
  if not DirectoryExists(APluginPath) then
    Exit;

  var fs := TDirectory.GetFiles(APluginPath, '*.dll|*.bpl');
  for var i in fs do
  begin
    var p: TPair<HMODULE, PPluginData>;
    p.Key := LoadLibrary(PChar(i));
    if p.Key <= 0 then
      Continue;

    var proc := GetProcAddress(p.Key, 'GetPlugin');
    if Assigned(proc) then
    begin
      CloseHandle(p.Key);
      Continue;
    end;

    p.Value := TGetPlugin(proc);
    if Assigned(p.Value) then
    begin
      CloseHandle(p.Key);
      Continue;
    end;

    FPlugins.Add(p);
  end;
end;

end.

