unit MLP.Contract.NeuronPredict;

interface

uses
  MLP.Contract.Activation, MLP.Contract.Neuron, MLP.Concret.Matrix;

type

  INeuronPredict = interface
    ['{BA6828A1-2B74-4E5D-B938-ABD58D368B11}']
    function SetNeuronLayer(ANeuronLayer: INeuronLayer): INeuronPredict;
    function SetActivation(AActivation: IActivation): INeuronPredict;
    function SetInputs(AInputs: TMatrixSingle): INeuronPredict;
    function Predict(out AOutputs: TMatrixSingle): INeuronPredict;
  end;

implementation

end.
