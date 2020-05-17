unit MLP.Neuron;

interface

uses

  MLP.Contract.Activation, MLP.Contract.Neuron, MLP.Contract.NeuronPredict, MLP.Contract.NeuronTrainer, MLP.Concret.Activations, MLP.Concret.Matrix,
  MLP.Concret.Neuron, MLP.Concret.NeuronPredict, MLP.Concret.NeuronTrainer;

type

  IActivation = MLP.Contract.Activation.IActivation;
  INeuronLayer = MLP.Contract.Neuron.INeuronLayer;
  INeuronPredict = MLP.Contract.NeuronPredict.INeuronPredict;
  INeuronTrainer = MLP.Contract.NeuronTrainer.INeuronTrainer;
  TSigmoidActivation = MLP.Concret.Activations.TSigmoidActivation;
  TFastSigmoidActivation = MLP.Concret.Activations.TFastSigmoidActivation;
  TIntegralActivation = MLP.Concret.Activations.TIntegralActivation;
  TMatrixMapCallback = MLP.Concret.Matrix.TMatrixMapCallback;
  TMatrixMapValueCallback = MLP.Concret.Matrix.TMatrixMapValueCallback;
  TMatrixSingle = MLP.Concret.Matrix.TMatrixSingle;
  TNeuronLayer = MLP.Concret.Neuron.TNeuronLayer;
  TNeuronPredict = MLP.Concret.NeuronPredict.TNeuronPredict;
  TNeuronTrainer = MLP.Concret.NeuronTrainer.TNeuronTrainer;

implementation

end.
