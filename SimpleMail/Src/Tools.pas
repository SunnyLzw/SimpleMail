unit Tools;

interface

uses
  System.Classes, System.SysUtils, Types;

type
  TByteArrayHelper = record Helper for TByteArray
    class function Create(AString: string): TByteArray; overload;
    class function Create(AString: string; AEncoding: TENcoding): TByteArray; overload;
    class function XOREncrypt(AData: TByteArray; AKey: Byte = $55): TByteArray; overload;
    class function XOREncrypt(AKey: Byte = $55): TByteArray; overload;
    class function XORDecrypt(AData: TByteArray; AKey: Byte = $55): TByteArray; overload;
    class function XORDecrypt(AKey: Byte = $55): TByteArray; overload;
    class function ToString(AData: TByteArray): string; overload;
    class function ToString(AData: TByteArray; AEncoding: TENcoding): string; overload;
    class function ToString: string; overload;
    class function ToString(AEncoding: TENcoding): string; overload;
  end;

  TXOREncrypt = class(TObject)
  protected
    FData: TByteArray;
    FKey: Byte;
  public
    constructor Create(AData: TByteArray; AKey: Byte = $55); overload;
    constructor Create(AData: string; AKey: Byte = $55); overload;
    function Encrypt: TByteArray;
    function Decrypt: TByteArray;
  public
    property Data: TByteArray read FData write FData;
    property Key: Byte read FKey write FKey;
  end;

function StrToBin(AStr: string): string; overload;

function StrToBin(AStr: string; AEncoding: TEncoding): string; overload;

function BinToStr(ABin: string): string; overload;

function BinToStr(ABin: string; AEncoding: TEncoding): string; overload;

implementation

function StrToBin(AStr: string): string;
begin
  Result := StrToBin(AStr, TEncoding.Default);
end;

function StrToBin(AStr: string; AEncoding: TEncoding): string;
var
  b: Byte;
  ss: TStringStream;
begin
  ss := TStringStream.Create(AStr, AEncoding);
  for b in ss.Bytes do
    Result := Result + b.ToHexString(2);
end;

function BinToStr(ABin: string): string;
begin
  Result := BinToStr(ABin, TEncoding.Default);
end;

function BinToStr(ABin: string; AEncoding: TEncoding): string;
var
  LStringStream: TStringStream;
  LBytesStream: TBytesStream;
  i: Int64;
  c: array[0..1] of Char;
  b: Byte;
begin
  LStringStream := TStringStream.Create(ABin, AEncoding);
  LBytesStream := TBytesStream.Create;
  LBytesStream.SetSize(Trunc(LStringStream.Size / 2));
  for i := 0 to LBytesStream.Size - 1 do
  begin
    LStringStream.Read(c, 4);
    b := ('$' + string(c)).ToInteger;
    LBytesStream.Write(b, 1);
  end;
  LStringStream.LoadFromStream(LBytesStream);
  Result := LStringStream.DataString;
end;

{ TByteArrayHelper }

class function TByteArrayHelper.Create(AString: string): TByteArray;
begin
  Result := Create(AString, TEncoding.Default);
end;

class function TByteArrayHelper.XORDecrypt(AData: TByteArray; AKey: Byte): TByteArray;
begin
  Result := TXOREncrypt.Create(AData, AKey).Decrypt;
end;

class function TByteArrayHelper.Create(AString: string; AEncoding: TENcoding): TByteArray;
begin
  Result := TStringStream.Create(AString, AEncoding).Bytes;
end;

class function TByteArrayHelper.ToString(AEncoding: TENcoding): string;
begin
  Result := ToString(Self, AEncoding);
end;

class function TByteArrayHelper.ToString(AData: TByteArray; AEncoding: TENcoding): string;
var
  LStringStream: TStringStream;
begin
  LStringStream := TStringStream.Create('', AEncoding);
  LStringStream.LoadFromStream(TBytesStream.Create(AData));
  Result := LStringStream.DataString;
end;

class function TByteArrayHelper.XORDecrypt(AKey: Byte): TByteArray;
begin
  Result := XORDecrypt(Self, AKey);
end;

class function TByteArrayHelper.XOREncrypt(AKey: Byte): TByteArray;
begin
  Result := XOREncrypt(Self, AKey);
end;

class function TByteArrayHelper.XOREncrypt(AData: TByteArray; AKey: Byte): TByteArray;
begin
  Result := TXOREncrypt.Create(AData, AKey).Encrypt;
end;

class function TByteArrayHelper.ToString: string;
begin
  Result := ToString(Self, TEncoding.Default);
end;

class function TByteArrayHelper.ToString(AData: TByteArray): string;
begin
  Result := ToString(AData, TEncoding.Default);
end;

{ TXOREncrypt }

constructor TXOREncrypt.Create(AData: TByteArray; AKey: Byte);
begin
  FData := AData;
  FKey := AKey;
end;

function TXOREncrypt.Decrypt: TByteArray;
var
  i: Integer;
begin
  SetLength(Result, Length(FData));
  for i := Low(FData) to High(FData) do
  begin
    Result[i] := FData[i] xor FKey;
  end;
end;

function TXOREncrypt.Encrypt: TByteArray;
begin
  Result := Decrypt;
end;

constructor TXOREncrypt.Create(AData: string; AKey: Byte);
begin
  Create(TStringStream.Create(AData).Bytes, AKey);
end;

end.

