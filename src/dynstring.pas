unit dynstring;

{$mode objfpc}{$H+}

interface



uses
  Classes, SysUtils;


type
//==============================================================================
// The TDynString Class Declaration


  TDynString = class
  protected
    sdata: String;
    ilength: Cardinal;
    icapacity: Integer;
    pcstart: PChar;
    pcposition: PChar;
    pcend: PChar;
    ismallgrowfactor: Cardinal;
    ibiggrowfactor: Cardinal;
    procedure Init(const ssource: String);
    procedure Grow(iminimumcapacity: Integer = -1);
    procedure SetPosition(iposition: Cardinal);
    procedure SetDataLength(idatalength: Cardinal);
    procedure SetDataCapacity(idatacapacity: Cardinal);
    function GetPosition: Cardinal;
  public
    constructor Create; overload;
    constructor Create(const ssource: String); overload;
    procedure AddString(const ssource: String);
    procedure SetString(const ssource: String);
    procedure AddChar(const schar: Char);
    procedure AddByte(const ibyte: Byte);
    property Data: String read sdata write SetString;
    property StartPointer: PChar read pcstart;
    property EndPointer: PChar read pcend;
    property Position: Cardinal read GetPosition write SetPosition;
    property Length: Cardinal read ilength write SetDataLength;
    property Capacity: Cardinal read icapacity write SetDataCapacity;
  end;


implementation
//==============================================================================
// The TDynString Class Implementation




//----------------------------------------------------------------------------
//Constructors


constructor TDynString.Create; overload;
begin
  Self.Init('');
end;

constructor TDynString.Create(const ssource: String); overload;
begin
  Self.Init(ssource);
end;



//----------------------------------------------------------------------------
//Administration Methods


procedure TDynString.Init(const ssource: String);
begin
  Self.sdata := ssource;
  Self.ilength := Length(ssource);
  Self.icapacity := -1;

  Self.ismallgrowfactor := 2;
  Self.ibiggrowfactor := 8192;

  Self.pcstart := Nil;
  Self.pcposition := Nil;
  Self.pcend := Nil;

  Self.Grow(Self.ilength);
end;

procedure TDynString.SetPosition(iposition: Cardinal);
begin
  Self.pcposition := Self.pcstart + iposition;

  if Self.pcposition > Self.pcend then
    Self.pcposition := Self.pcend;

end;

procedure TDynString.SetDataLength(idatalength: Cardinal);
var
  ifllcnt: Cardinal;
begin
  if istringlength > Self.icapacity then
    Self.Grow(istringlength);

  if istringlength > Self.ilength then
  begin
    ifllcnt := istringlength - Self.ilength;
  end;
end;

procedure TDynString.SetDataCapacity(idatacapacity: Cardinal);
var
  ips: Cardinal;
begin
  if istringcapacity > Self.icapacity then
    Self.Grow(istringcapacity)
  else  //The New Capacity is fewer than the Actual Capacity
  begin
    if Self.pcposition <> Nil then
      ips := Self.pcposition - Self.pcstart
    else
      ips := Self.ilength;

    if ips > istringcapacity then
    begin
      ips := istringcapacity;
      Self.ilength := istringcapacity;
    end;

    //Set the strict Capacity
    Self.icapacity := istringcapacity;

    //Truncate the String
    SetLength(Self.sdata, Self.icapacity);

    Self.pcstart := PChar(Self.sdata);
    Self.pcend := Self.pcstart + Self.icapacity;
    Self.pcposition := Self.pcstart + ips;
  end;  //if istringcapacity > Self.icapacity then
end;

procedure TDynString.Grow(iminimumcapacity: Integer = -1);
var
  ips: Cardinal;
begin
  if Self.pcposition <> Nil then
    ips := Self.pcposition - Self.pcstart
  else
    ips := Self.ilength;

  if (iminimumcapacity <> -1)
    or (Self.icapacity < 1) then
  begin
    if iminimumcapacity < Self.ibiggrowfactor then
    begin
      //Align the Capacity to the Small Grow Factor
      Self.icapacity := (iminimumcapacity DIV Self.ismallgrowfactor) * Self.ismallgrowfactor;

      SetLength(Self.sdata, Self.icapacity);
    end
    else  //Big Size Capacity
    begin
      //Align the Capacity to the Big Grow Factor
      Self.icapacity := (iminimumcapacity DIV Self.ibiggrowfactor) * Self.ibiggrowfactor;

      SetLength(Self.sdata, Self.icapacity);
    end;  //if Self.ilength < Self.ibiggrowfactor then
  end
  else  //No Minimum Capacity given
  begin
    if Self.icapacity < Self.ibiggrowfactor then
    begin
      //Grow according to the Small Grow Factor
      Self.icapacity := Self.icapacity * Self.ismallgrowfactor;

      SetLength(Self.sdata, Self.icapacity);
    end
    else  //Big Size Capacity
    begin
      //Align the Capacity to the Small Grow Factor
      Self.icapacity := Self.icapacity + Self.ibiggrowfactor;

      SetLength(Self.sdata, Self.icapacity);
    end;  //if Self.ilength < Self.ibiggrowfactor then
  end;  //if (iminimumcapacity <> -1) or (Self.icapacity < 1) then

  Self.pcstart := PChar(Self.sdata);
  Self.pcend := Self.pcstart + Self.icapacity;
  Self.pcposition := Self.pcstart + ips;
end;

procedure TDynString.AddString(const ssource: String);
var
  psrc: PChar;
  isrclng, idtalng: Cardinal;
begin
  psrc := PChar(ssource);
  isrclng := Length(ssource);
  idtalng := Self.ilength + isrclng;

  if idtalng >= Self.icapacity then
  begin
    if idtalng < (Self.icapacity * Self.ismallgrowfactor) then
      //Normal Growth
      Self.Grow
    else
      //Fast Growth
      Self.Grow(Self.ilength + isrclng);

  end;  //if idtalng >= Self.icapacity then

  //Copy the Source Data into the Buffer
  Move(psrc^, Self.pcposition^, isrclng);

  inc(Self.pcposition, isrclng);

  Self.ilength := idtalng;
end;

procedure TDynString.SetString(const ssource: String);
begin
  Self.sdata := ssource;
  Self.ilength := Length(ssource);
  Self.icapacity := -1;

  Self.pcstart := Nil;
  Self.pcposition := Nil;
  Self.pcend := Nil;

  Self.Grow(Self.ilength);
end;

procedure TDynString.AddChar(const schar: Char);
begin
  if Self.ilength + 1 >= Self.icapacity then
    //Normal Growth
    Self.Grow

  //Set the Character at the Buffer Position
  Self.pcposition^ := schar;

  inc(Self.pcposition);
  inc(Self.ilength);
end;

procedure TDynString.AddByte(const ibyte: Byte);
begin
  if Self.ilength + 1 >= Self.icapacity then
    //Normal Growth
    Self.Grow

  //Set the Character of the Byte at the Buffer Position
  Self.pcposition^ := chr(ibyte);

  inc(Self.pcposition);
  inc(Self.ilength);
end;



//----------------------------------------------------------------------------
//Consultation Methods

function TDynString.GetPosition: Cardinal;
begin
  Result := Self.pcposition - Self.pcstart;
end;


end.

