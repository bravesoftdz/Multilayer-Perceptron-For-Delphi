unit MLP.Concret.NeuronTrainer;

interface

uses
  MLP.Contract.NeuronTrainer, MLP.Concret.Matrix, MLP.Contract.Neuron,
  MLP.Contract.Activation;

type

  TNeuronTrainer = class(TInterfacedObject, INeuronTrainer)
  private
    { private declarations }
    FLearningRate: Single;
    [weak]
    FActivation: IActivation;
    FFirstNeuronLayer: INeuronLayer;
    FLastNeuronLayer: INeuronLayer;
    FInputs: TMatrixSingle;
    FExpectedOutputs: TMatrixSingle;
  protected
    { protected declarations }
    procedure Activation(var AValue: Single);
    procedure DerivativeSigmoid(var AValue: Single);
  public
    { public declarations }
    function SetLearningRate(ALearningRate: Single): INeuronTrainer;
    function SetActivation(AActivation: IActivation): INeuronTrainer;
    function SetNeuronLayer(ANeuronLayer: INeuronLayer): INeuronTrainer;
    function SetInputs(AInputs: TMatrixSingle): INeuronTrainer;
    function SetExpectedOutputs(AExpectedOutputs: TMatrixSingle): INeuronTrainer;
    function Train: INeuronTrainer;
  end;

implementation

uses
  MLP.Concret.Neuron, System.SysUtils, MLP.Concret.NeuronPredict;

{ TNeuronTrainer }

procedure TNeuronTrainer.Activation(var AValue: Single);
begin
  FActivation.Activation(AValue);
end;

procedure TNeuronTrainer.DerivativeSigmoid(var AValue: Single);
begin
  AValue := AValue * (1 - AValue);
end;

function TNeuronTrainer.SetActivation(AActivation: IActivation): INeuronTrainer;
begin
  Result := Self;
  FActivation := AActivation;
end;

function TNeuronTrainer.SetExpectedOutputs(AExpectedOutputs: TMatrixSingle): INeuronTrainer;
begin
  Result := Self;
  FExpectedOutputs := AExpectedOutputs;
end;

function TNeuronTrainer.SetInputs(AInputs: TMatrixSingle): INeuronTrainer;
begin
  Result := Self;
  FInputs := AInputs;
end;

function TNeuronTrainer.SetLearningRate(ALearningRate: Single): INeuronTrainer;
begin
  Result := Self;
  FLearningRate := ALearningRate;
end;

function TNeuronTrainer.SetNeuronLayer(ANeuronLayer: INeuronLayer): INeuronTrainer;
var
  LNeuronLayerNavigator: INeuronLayerNavigator;
begin
  Result := Self;
  if Supports(ANeuronLayer, INeuronLayerNavigator, LNeuronLayerNavigator) then
  begin
    FFirstNeuronLayer := LNeuronLayerNavigator.First;
    FLastNeuronLayer := LNeuronLayerNavigator.Last;
  end;
end;

function TNeuronTrainer.Train: INeuronTrainer;
var
  LNeuronLayerNavigator: INeuronLayerNavigator;
  LCurrentNeuronLayerHack: INeuronLayerHack;

  LPriorNeuronLayer: INeuronLayer;
  LPriorNeuronLayerHack: INeuronLayerHack;

  LOutputs: TMatrixSingle;
  LCurrentOutputs: TMatrixSingle;
  LPriorOutputs: TMatrixSingle;
  LLastOutputError: TMatrixSingle;
  LDerivative: TMatrixSingle;
  LTransposed: TMatrixSingle;
  LGradient: TMatrixSingle;
  LDeltas: TMatrixSingle;

  LCurrentWeights: TMatrixSingle;

  LPriorWeights: TMatrixSingle;
  LPriorBias: TMatrixSingle;

begin

  if Supports(FLastNeuronLayer, INeuronLayerNavigator, LNeuronLayerNavigator) then
  begin
    TNeuronPredict.Create.SetNeuronLayer(FFirstNeuronLayer).SetActivation(FActivation).SetInputs(FInputs).Predict(LOutputs);

    while LNeuronLayerNavigator.HasPrior do
    begin
      LPriorNeuronLayer := LNeuronLayerNavigator.Prior;
      if Supports(LPriorNeuronLayer, INeuronLayerHack, LPriorNeuronLayerHack) then
      begin
        if Supports(LNeuronLayerNavigator, INeuronLayerHack, LCurrentNeuronLayerHack) then
        begin

          if not LNeuronLayerNavigator.HasNext then
          begin
            LLastOutputError := FExpectedOutputs - LOutputs;
          end
          else
          begin
            LCurrentNeuronLayerHack.GetWeights(LCurrentWeights);
            LLastOutputError := TMatrixSingle.Transpose(LCurrentWeights) * LLastOutputError;
          end;

          LCurrentNeuronLayerHack.GetOutputs(LCurrentOutputs);
          LPriorNeuronLayerHack.GetOutputs(LPriorOutputs);

          LDerivative := TMatrixSingle.Map(LCurrentOutputs, DerivativeSigmoid);
          LTransposed := TMatrixSingle.Transpose(LPriorOutputs);
          if (LTransposed.RowsCount = 0) and (LTransposed.ColsCount = 0) then
            LTransposed := TMatrixSingle.Transpose(FInputs);
          LGradient := TMatrixSingle.Hadamard(LDerivative, LLastOutputError);
          LGradient := TMatrixSingle.EscalarMultiply(LGradient, FLearningRate);

          LPriorNeuronLayerHack.GetWeights(LPriorWeights).GetBias(LPriorBias);
          LPriorBias := LPriorBias + LGradient;
          LDeltas := LGradient * LTransposed;
          LPriorWeights := LPriorWeights + LDeltas;
          LPriorNeuronLayerHack.SetWeights(LPriorWeights).SetBias(LPriorBias);

          if not Supports(LPriorNeuronLayerHack, INeuronLayerNavigator, LNeuronLayerNavigator) then
            Break;
        end;
      end;
    end;

  end;

end;

end.
