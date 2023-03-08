unit HookMutexW;

interface

procedure Hook(APath: PChar); stdcall;

implementation

uses
  System.SysUtils, Winapi.Windows, WeChatMultiOpenerUnit, Sunny.Debugger;

var
  Debug: TDebugger;

procedure cbUnInit;
begin
  Debug.UnInit;
  Debug.Free;
  Debug := nil;
end;

procedure cbCreateMutexW;
var
  ct: TContext;
  p: PByte;
  guid: TGUID;
  lpName: string;
  len: NativeUInt;
  buf: Pointer;
begin
  // ��ȡ�߳�������
  ct.ContextFlags := 65543;
  GetThreadContext(Debug.ProcessInformation.hThread, ct);

  // ��ȡջ��ָ��
  p := PByte(ct.Esp);

  // ESP+0xC
  // CreateMutexW����lpName
  Inc(p, $C);

  // Ϊ�˷�ֹ���������Ƴ����ظ���ʹ��GUID
  CreateGUID(guid);
  lpName := guid.ToString;

  // +1���ַ�����ֹ��
  // �ϰ汾�ַ���Ĭ�ϱ�����Ansi��
  len := (lpName.Length + 1) * SizeOf(Char);

  // �����ڴ����ַ���
  buf := nil;
  Debug.Memory.Alloc(len, buf);

  // ���ַ������Ƶ�������ڴ���
  Debug.Memory.Write(buf, PChar(lpName), len);

  // ��CreateMutexW����lpNameָ���޸�Ϊ������ڴ��ַ
  Debug.Memory.Write(Pointer(p), @buf, 4);

  Debug.CreateThreadCallBack := cbUnInit;
end;

procedure cbEntry;
var
  hMod: THandle;
  pApi: Pointer;
begin
  hMod := LoadLibrary('kernel32.dll');
  pApi := GetProcAddress(hMod, 'CreateMutexW');
  Debug.SetBreakPoint(pApi, cbCreateMutexW);
end;

procedure Hook(APath: PChar);
begin
  Debug := TDebugger.Create;
  with Debug do
  try
    EntryPointCallBack := cbEntry;
    KillOnExit := False;
    Init(APath);
    Loop;
  finally
    Free;
  end;
end;

end.

