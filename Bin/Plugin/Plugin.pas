unit Plugin;

interface

type
  PPluginData = ^TPluginData;

  TPluginData = record
    ParentIndex: Integer;
    ParentName: string;
    Name: string;
  end;

  TGetPlugin = function: PPluginData; stdcall;

  TSetPlugin = procedure(APluginData: PPluginData); stdcall;

  TExecute = procedure; stdcall;

implementation

end.

