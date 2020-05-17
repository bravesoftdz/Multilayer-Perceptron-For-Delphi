unit MLP.Concret.Neuron;

interface

uses

  MLP.Contract.Neuron, MLP.Concret.Matrix, System.SysUtils;

type

  TNeuronLayer = class(TInterfacedObject, INeuronLayer, INeuronLayerAcceptConnection, INeuronLayerNavigator, INeuronLayerHack)
  private
    { private declarations }
    FNeuronCount: Integer;
    FConnectedLayer: INeuronLayer;
    [weak]
    FConnectionOwnerLayer: INeuronLayer;
    FOutputs: TMatrixSingle;
    FWeights: TMatrixSingle;
    FBias: TMatrixSingle;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(ANeuronCount: Integer);
    function ConnectWith(ALayer: INeuronLayer): INeuronLayer; overload;
    function ConnectWith(ALayer: INeuronLayer; AWeights: TMatrixSingle; ABias: TMatrixSingle): INeuronLayer; overload;
    function ConnectionOwnerLayer(AConnectionOwnerLayer: INeuronLayer): INeuronLayer; overload;

    function HasNext(AHasCallback: THasCallback): INeuronLayerNavigator; overload;
    function HasNext: Boolean; overload;
    function Next(out ALayer: INeuronLayer): INeuronLayerNavigator; overload;
    function Next: INeuronLayer; overload;

    function HasPrior(AHasCallback: THasCallback): INeuronLayerNavigator; overload;
    function HasPrior: Boolean; overload;
    function Prior(out ALayer: INeuronLayer): INeuronLayerNavigator; overload;
    function Prior: INeuronLayer; overload;

    function First: INeuronLayer; overload;
    function Last: INeuronLayer; overload;

    function SetOutputs(AOutputs: TMatrixSingle): INeuronLayerHack;
    function SetWeights(AWeights: TMatrixSingle): INeuronLayerHack;
    function SetBias(ABias: TMatrixSingle): INeuronLayerHack;
    function GetOutputs(out AOutputs: TMatrixSingle): INeuronLayerHack;
    function GetNeuronCount(out ANeuronCount: Integer): INeuronLayerHack;
    function GetWeights(out AWeights: TMatrixSingle): INeuronLayerHack;
    function GetBias(out ABias: TMatrixSingle): INeuronLayerHack;

  end;

implementation

{ TNeuronLayer }

function TNeuronLayer.ConnectionOwnerLayer(AConnectionOwnerLayer: INeuronLayer): INeuronLayer;
begin
  Result := Self;
  FConnectionOwnerLayer := AConnectionOwnerLayer;
end;

function TNeuronLayer.ConnectWith(ALayer: INeuronLayer; AWeights, ABias: TMatrixSingle): INeuronLayer;
var
  LNextNeuronCount: Integer;
begin
  Result := Self;

  TNeuronLayer(ALayer).GetNeuronCount(LNextNeuronCount);

  if AWeights.RowsCount <> LNextNeuronCount then
    raise Exception.Create('The RowsCount of the weights differs from the neuron count of the next layer');

  if AWeights.ColsCount <> FNeuronCount then
    raise Exception.Create('The ColsCount of the weights differs from the neuron count');

  if ABias.RowsCount <> LNextNeuronCount then
    raise Exception.Create('The RowsCount of the bias differs from the neuron count of the next layer');

  if ABias.ColsCount <> 1 then
    raise Exception.Create('The ColsCount of the bias it has to be 1');

  FWeights := AWeights;
  FBias := ABias;

  ConnectWith(ALayer);

end;

function TNeuronLayer.ConnectWith(ALayer: INeuronLayer): INeuronLayer;
var
  LNextNeuronCount: Integer;
  LNeuronLayerAcceptConnection: INeuronLayerAcceptConnection;
begin
  Result := Self;
  TNeuronLayer(ALayer).GetNeuronCount(LNextNeuronCount);
  FConnectedLayer := ALayer;
  if (FWeights.RowsCount = 0) and (FWeights.ColsCount = 0) then
    FWeights := TMatrixSingle.Create(LNextNeuronCount, FNeuronCount, True);
  if (FBias.RowsCount = 0) and (FBias.ColsCount = 0) then
    FBias := TMatrixSingle.Create(LNextNeuronCount, 1, True);
  if Supports(ALayer, INeuronLayerAcceptConnection, LNeuronLayerAcceptConnection) then
    LNeuronLayerAcceptConnection.ConnectionOwnerLayer(Self);

end;

constructor TNeuronLayer.Create(ANeuronCount: Integer);
begin
  FNeuronCount := ANeuronCount;
end;

function TNeuronLayer.First: INeuronLayer;
var
  LNeuronLayerNavigator: INeuronLayerNavigator;
begin
  Result := Self;
  if Supports(Result, INeuronLayerNavigator, LNeuronLayerNavigator) then
  begin
    while LNeuronLayerNavigator.HasPrior do
    begin
      Result := LNeuronLayerNavigator.Prior;
      if not Supports(Result, INeuronLayerNavigator, LNeuronLayerNavigator) then
        break;
    end;
  end;
end;

function TNeuronLayer.GetBias(out ABias: TMatrixSingle): INeuronLayerHack;
begin
  Result := Self;
  ABias := FBias;
end;

function TNeuronLayer.GetOutputs(out AOutputs: TMatrixSingle): INeuronLayerHack;
begin
  Result := Self;
  AOutputs := FOutputs;
end;

function TNeuronLayer.GetNeuronCount(out ANeuronCount: Integer): INeuronLayerHack;
begin
  Result := Self;
  ANeuronCount := FNeuronCount;
end;

function TNeuronLayer.GetWeights(out AWeights: TMatrixSingle): INeuronLayerHack;
begin
  Result := Self;
  AWeights := FWeights;
end;

function TNeuronLayer.HasNext(AHasCallback: THasCallback): INeuronLayerNavigator;
begin
  Result := Self;
  AHasCallback(HasNext, Next);
end;

function TNeuronLayer.HasNext: Boolean;
begin
  Result := FConnectedLayer <> nil;
end;

function TNeuronLayer.HasPrior(AHasCallback: THasCallback): INeuronLayerNavigator;
begin
  Result := Self;
  AHasCallback(HasPrior, Prior);
end;

function TNeuronLayer.HasPrior: Boolean;
begin
  Result := FConnectionOwnerLayer <> nil;
end;

function TNeuronLayer.Last: INeuronLayer;
var
  LNeuronLayerNavigator: INeuronLayerNavigator;
begin
  Result := Self;
  if Supports(Result, INeuronLayerNavigator, LNeuronLayerNavigator) then
  begin
    while LNeuronLayerNavigator.HasNext do
    begin
      Result := LNeuronLayerNavigator.Next;
      if not Supports(Result, INeuronLayerNavigator, LNeuronLayerNavigator) then
        break;
    end;
  end;
end;

function TNeuronLayer.Next(out ALayer: INeuronLayer): INeuronLayerNavigator;
begin
  Result := Self;
  ALayer := Next;
end;

function TNeuronLayer.Next: INeuronLayer;
begin
  Result := FConnectedLayer;
end;

function TNeuronLayer.Prior(out ALayer: INeuronLayer): INeuronLayerNavigator;
begin
  Result := Self;
  ALayer := Prior;
end;

function TNeuronLayer.Prior: INeuronLayer;
begin
  Result := FConnectionOwnerLayer;
end;

function TNeuronLayer.SetBias(ABias: TMatrixSingle): INeuronLayerHack;
begin
  Result := Self;
  FBias := ABias;
end;

function TNeuronLayer.SetOutputs(AOutputs: TMatrixSingle): INeuronLayerHack;
begin
  Result := Self;
  FOutputs := AOutputs;
end;

function TNeuronLayer.SetWeights(AWeights: TMatrixSingle): INeuronLayerHack;
begin
  Result := Self;
  FWeights := AWeights;
end;

end.
