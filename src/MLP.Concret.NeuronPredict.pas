unit MLP.Concret.NeuronPredict;

interface

uses
  MLP.Contract.NeuronPredict, MLP.Contract.Neuron, MLP.Contract.Activation,
  MLP.Concret.Matrix, System.SysUtils;

type

  TNeuronPredict = class(TInterfacedObject, INeuronPredict)
  private
    { private declarations }
    FNeuronLayer: INeuronLayer;
    [weak]
    FActivation: IActivation;
    FInputs: TMatrixSingle;
    FOutputs: TMatrixSingle;
  protected
    { protected declarations }
    procedure Activation(var AValue: Single);
    function CalcOutputs(AInputs: TMatrixSingle; ALayer: INeuronLayer): TMatrixSingle;
  public
    { public declarations }
    function SetNeuronLayer(ANeuronLayer: INeuronLayer): INeuronPredict;
    function SetActivation(AActivation: IActivation): INeuronPredict;
    function SetInputs(AInputs: TMatrixSingle): INeuronPredict;
    function Predict(out AOutputs: TMatrixSingle): INeuronPredict;
  end;

implementation

uses
  MLP.Concret.Neuron;

{ TNeuronPredict }

procedure TNeuronPredict.Activation(var AValue: Single);
begin
  FActivation.Activation(AValue);
end;

function TNeuronPredict.CalcOutputs(AInputs: TMatrixSingle; ALayer: INeuronLayer): TMatrixSingle;
var
  LWeigths: TMatrixSingle;
  LBias: TMatrixSingle;
  LCurrentNeuronLayerHack: INeuronLayerHack;
  LNextNeuronLayerHack: INeuronLayerHack;
  LNeuronLayerNavigator: INeuronLayerNavigator;
  LNextNeuronLayer: INeuronLayer;
  LNextNeuronLayerNavigator: INeuronLayerNavigator;
begin
  if Supports(ALayer, INeuronLayerHack, LCurrentNeuronLayerHack) then
  begin
    if Supports(ALayer, INeuronLayerNavigator, LNeuronLayerNavigator) then
    begin
      LCurrentNeuronLayerHack.GetWeights(LWeigths).GetBias(LBias);
      FOutputs := LWeigths * AInputs;
      FOutputs := FOutputs + LBias;
      FOutputs.Map(Activation);
      if LNeuronLayerNavigator.HasNext then
      begin
        LNextNeuronLayer := LNeuronLayerNavigator.Next;
        if Supports(LNextNeuronLayer,INeuronLayerHack,LNextNeuronLayerHack) then
        begin
          LNextNeuronLayerHack.SetOutputs(FOutputs)
        end;
        if Supports(LNextNeuronLayer, INeuronLayerNavigator, LNextNeuronLayerNavigator) then
        begin
          if LNextNeuronLayerNavigator.HasNext then
            CalcOutputs(FOutputs, LNextNeuronLayer);
        end;
      end;
    end;
  end;
end;

function TNeuronPredict.Predict(out AOutputs: TMatrixSingle): INeuronPredict;
begin
  Result := Self;
  CalcOutputs(FInputs, FNeuronLayer);
  AOutputs := FOutputs;
end;

function TNeuronPredict.SetActivation(AActivation: IActivation): INeuronPredict;
begin
  Result := Self;
  FActivation := AActivation;
end;

function TNeuronPredict.SetInputs(AInputs: TMatrixSingle): INeuronPredict;
begin
  Result := Self;
  FInputs := AInputs;
end;

function TNeuronPredict.SetNeuronLayer(ANeuronLayer: INeuronLayer): INeuronPredict;
begin
  Result := Self;
  FNeuronLayer := ANeuronLayer;
end;

end.
