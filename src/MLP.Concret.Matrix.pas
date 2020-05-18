unit MLP.Concret.Matrix;

interface

uses
  System.SysUtils, System.Threading, System.SyncObjs;

type

  TMatrixMapCallback = reference to procedure(var AValue: Single; ARow: Integer; ACol: Integer);
  TMatrixMapValueCallback = reference to procedure(var AValue: Single);

  TMatrixSingle = record
  private
    FData: TArray<TArray<Single>>;
  public
    constructor Create(ARowsCount: Integer; AColsCount: Integer; const ARandomizeValues: Boolean = False); overload;
    constructor Create(AData: TArray<TArray<Single>>; const ARandomizeValues: Boolean = False); overload;

    class operator Add(const AMatrix1, AMatrix2: TMatrixSingle): TMatrixSingle;
    class operator Subtract(const AMatrix1, AMatrix2: TMatrixSingle): TMatrixSingle;
    class operator Multiply(const AMatrix1, AMatrix2: TMatrixSingle): TMatrixSingle;

    class function ArrayToMatrix(AArray: TArray < TArray < Single >> ): TMatrixSingle; overload; static;
    class function ArrayToMatrix(AArray: TArray<Single>): TMatrixSingle; overload; static;
    class function MatrixToArrayOfArray(AMatrix: TMatrixSingle): TArray<TArray<Single>>; static;
    class function MatrixToArray(AMatrix: TMatrixSingle): TArray<Single>; static;
    class function Map(AMatrix: TMatrixSingle; AMatrixMapCallback: TMatrixMapCallback): TMatrixSingle; overload; static;
    class function Map(AMatrix: TMatrixSingle; AMatrixMapValueCallback: TMatrixMapValueCallback): TMatrixSingle; overload; static;
    class function Transpose(AMatrix: TMatrixSingle): TMatrixSingle; static;
    class function Hadamard(const AMatrix1, AMatrix2: TMatrixSingle): TMatrixSingle; static;
    class function EscalarMultiply(const AMatrix1: TMatrixSingle; const AFactor: Single): TMatrixSingle; static;
    function Map(AMatrixMapCallback: TMatrixMapCallback): TMatrixSingle; overload;
    function Map(AMatrixMapValueCallback: TMatrixMapValueCallback): TMatrixSingle; overload;
    function RowsCount: Integer;
    function ColsCount: Integer;
    function GetValue(ARow: Integer; ACol: Integer): Single;
    procedure SetValue(ARow: Integer; ACol: Integer; AValue: Single);
    procedure RandomizeValues;
  end;

implementation

{ TMatrix }

class operator TMatrixSingle.Add(const AMatrix1, AMatrix2: TMatrixSingle): TMatrixSingle;
var
  LMatrix: TMatrixSingle;
begin
  LMatrix := TMatrixSingle.Create(AMatrix1.RowsCount, AMatrix1.ColsCount);
  LMatrix.Map(
    procedure(var AValue: Single; ARow: Integer; ACol: Integer)
    begin
      AValue := AMatrix1.GetValue(ARow, ACol) + AMatrix2.GetValue(ARow, ACol);
    end);
  Result := LMatrix;
end;

class function TMatrixSingle.ArrayToMatrix(AArray: TArray<Single>): TMatrixSingle;
var
  LMatrix: TMatrixSingle;
begin
  LMatrix := TMatrixSingle.Create(Length(AArray), 1);
  LMatrix.Map(
    procedure(var AValue: Single; ARow: Integer; ACol: Integer)
    begin
      AValue := AArray[ARow]
    end);
  Result := LMatrix;
end;

function TMatrixSingle.ColsCount: Integer;
begin
  Result := 0;
  if Length(FData) > 0 then
    Result := Length(FData[0]);
end;

function TMatrixSingle.GetValue(ARow: Integer; ACol: Integer): Single;
begin
  if ARow > Length(FData) - 1 then
    raise Exception.Create('The row is out of range');
  if ACol > Length(FData[0]) - 1 then
    raise Exception.Create('The col is out of range');

  Result := FData[ARow][ACol];
end;

class function TMatrixSingle.Hadamard(const AMatrix1, AMatrix2: TMatrixSingle): TMatrixSingle;
var
  LMatrix: TMatrixSingle;
begin
  LMatrix := TMatrixSingle.Create(AMatrix1.RowsCount, AMatrix1.ColsCount);
  LMatrix.Map(
    procedure(var AValue: Single; ARow: Integer; ACol: Integer)
    begin
      AValue := AMatrix1.GetValue(ARow, ACol) * AMatrix2.GetValue(ARow, ACol);
    end);
  Result := LMatrix;
end;

constructor TMatrixSingle.Create(AData: TArray<TArray<Single>>; const ARandomizeValues: Boolean);
begin
  FData := AData;
  if ARandomizeValues then
    RandomizeValues;
end;

class function TMatrixSingle.EscalarMultiply(const AMatrix1: TMatrixSingle; const AFactor: Single): TMatrixSingle;
var
  LMatrix: TMatrixSingle;
begin
  LMatrix := TMatrixSingle.Create(AMatrix1.RowsCount, AMatrix1.ColsCount);
  LMatrix.Map(
    procedure(var AValue: Single; ARow: Integer; ACol: Integer)
    begin
      AValue := AMatrix1.GetValue(ARow, ACol) * AFactor;
    end);
  Result := LMatrix;
end;

class function TMatrixSingle.ArrayToMatrix(AArray: TArray < TArray < Single >> ): TMatrixSingle;
begin
  Result := TMatrixSingle.Create(AArray);
end;

constructor TMatrixSingle.Create(ARowsCount: Integer; AColsCount: Integer; const ARandomizeValues: Boolean);
var
  Y: Integer;
begin
  SetLength(FData, ARowsCount);
  for Y := Low(FData) to High(FData) do
  begin
    SetLength(FData[Y], AColsCount);
  end;
  if ARandomizeValues then
    RandomizeValues;
end;

function TMatrixSingle.Map(AMatrixMapCallback: TMatrixMapCallback): TMatrixSingle;
var
  LData: TArray<TArray<Single>>;
begin
  Result := Self;
  LData := FData;
  TParallel.&For(Low(LData), High(LData),
    procedure(Y: Int64)
    var
      X: Integer;
    begin
      for X := Low(LData[Y]) to High(LData[Y]) do
        AMatrixMapCallback(LData[Y][X], Y, X);
    end);
  FData := LData;
end;

class function TMatrixSingle.Map(AMatrix: TMatrixSingle; AMatrixMapCallback: TMatrixMapCallback): TMatrixSingle;
begin
  Result := AMatrix;
  AMatrix.Map(AMatrixMapCallback);
end;

function TMatrixSingle.Map(AMatrixMapValueCallback: TMatrixMapValueCallback): TMatrixSingle;
begin
  Map(
    procedure(var AValue: Single; ARow: Integer; ACol: Integer)
    begin
      AMatrixMapValueCallback(AValue);
    end)
end;

class function TMatrixSingle.Map(AMatrix: TMatrixSingle; AMatrixMapValueCallback: TMatrixMapValueCallback): TMatrixSingle;
begin
  Result := TMatrixSingle.Map(AMatrix,
    procedure(var AValue: Single; ARow: Integer; ACol: Integer)
    begin
      AMatrixMapValueCallback(AValue);
    end);
end;

class function TMatrixSingle.MatrixToArray(AMatrix: TMatrixSingle): TArray<Single>;
var
  LArray: TArray<Single>;
begin
  SetLength(LArray, AMatrix.RowsCount * AMatrix.ColsCount);
  AMatrix.Map(
    procedure(var AValue: Single; ARow: Integer; ACol: Integer)
    begin
      LArray[ACol + (ARow * AMatrix.ColsCount)] := AValue;
    end);
  Result := LArray;
end;

procedure TMatrixSingle.RandomizeValues;
begin
  Map(
    procedure(var AValue: Single; ARow: Integer; ACol: Integer)
    begin
      AValue := (Random(1000) / 1000) * 2 - 1;
    end);
end;

function TMatrixSingle.RowsCount: Integer;
begin
  Result := Length(FData);
end;

procedure TMatrixSingle.SetValue(ARow, ACol: Integer; AValue: Single);
begin
  if ARow > Length(FData) - 1 then
    raise Exception.Create('The row is out of range');
  if ACol > Length(FData[0]) - 1 then
    raise Exception.Create('The col is out of range');

  FData[ARow][ACol] := AValue;
end;

class operator TMatrixSingle.Subtract(const AMatrix1, AMatrix2: TMatrixSingle): TMatrixSingle;
var
  LMatrix: TMatrixSingle;
begin
  LMatrix := TMatrixSingle.Create(AMatrix1.RowsCount, AMatrix1.ColsCount);
  LMatrix.Map(
    procedure(var AValue: Single; ARow: Integer; ACol: Integer)
    begin
      AValue := AMatrix1.GetValue(ARow, ACol) - AMatrix2.GetValue(ARow, ACol);
    end);
  Result := LMatrix;
end;

class function TMatrixSingle.Transpose(AMatrix: TMatrixSingle): TMatrixSingle;
var
  LMatrix: TMatrixSingle;
begin
  LMatrix := TMatrixSingle.Create(AMatrix.ColsCount, AMatrix.RowsCount);
  AMatrix.Map(
    procedure(var AValue: Single; ARow: Integer; ACol: Integer)
    begin
      LMatrix.SetValue(ACol, ARow, AValue);
    end);
  Result := LMatrix;
end;

class function TMatrixSingle.MatrixToArrayOfArray(AMatrix: TMatrixSingle): TArray<TArray<Single>>;
var
  LArray: TArray<TArray<Single>>;
begin
  SetLength(LArray, AMatrix.RowsCount);
  AMatrix.Map(
    procedure(var AValue: Single; ARow: Integer; ACol: Integer)
    begin
      if (ACol = 0) then
      begin
        SetLength(LArray[ARow], AMatrix.ColsCount);
      end;
      LArray[ARow][ACol] := AValue;
    end);
  Result := LArray;
end;

class operator TMatrixSingle.Multiply(const AMatrix1, AMatrix2: TMatrixSingle): TMatrixSingle;
var
  LMatrix: TMatrixSingle;
begin
  LMatrix := TMatrixSingle.Create(AMatrix1.RowsCount, AMatrix2.ColsCount);
  LMatrix.Map(
    procedure(var AValue: Single; ARow: Integer; ACol: Integer)
    var
      LSum: Single;
      Z: Integer;
    begin
      LSum := 0;
      for Z := 0 to AMatrix1.ColsCount - 1 do
      begin
        LSum := LSum + AMatrix1.GetValue(ARow, Z) * AMatrix2.GetValue(Z, ACol);
      end;
      AValue := LSum;
    end);
  Result := LMatrix;
end;

end.
