unit MLP.Contract.NeuronTrainer;

interface

uses
  MLP.Contract.Neuron, MLP.Concret.Matrix, MLP.Contract.Activation;

type

  INeuronTrainer = interface
    ['{9E56BF8F-A276-4E0C-B53A-3E651F977A6C}']
    function SetLearningRate(ALearningRate: Single): INeuronTrainer;
    function SetActivation(AActivation: IActivation): INeuronTrainer;
    function SetNeuronLayer(ANeuronLayer: INeuronLayer): INeuronTrainer;
    function SetInputs(AInputs: TMatrixSingle): INeuronTrainer;
    function SetExpectedOutputs(AExpectedOutputs: TMatrixSingle): INeuronTrainer;
    function Train: INeuronTrainer;
  end;

implementation

end.
