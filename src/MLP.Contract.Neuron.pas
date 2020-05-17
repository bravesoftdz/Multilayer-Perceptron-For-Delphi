unit MLP.Contract.Neuron;

interface

uses
  MLP.Contract.Activation, MLP.Concret.Matrix;

type

  INeuronLayer = interface;

  THasCallback = procedure(AHasLayer: Boolean; ALayer: INeuronLayer);

  INeuronLayer = interface
    ['{82BBA5AA-CF71-444A-A283-836B2D4204E5}']
    function ConnectWith(ALayer: INeuronLayer): INeuronLayer; overload;
    function ConnectWith(ALayer: INeuronLayer; AWeights: TMatrixSingle; ABias: TMatrixSingle): INeuronLayer; overload;
  end;

  INeuronLayerAcceptConnection = interface
    ['{3BF0F82D-853B-4517-AA5F-AA9403559DB4}']
    function ConnectionOwnerLayer(AConnectionOwnerLayer: INeuronLayer): INeuronLayer; overload;
  end;

  INeuronLayerNavigator = interface
    ['{F1336002-C968-46BF-89CF-CC303974C5DC}']
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
  end;

  INeuronLayerHack = interface
    ['{D2330CE6-BF3E-4B66-9F79-C1855B51AB9A}']
    function SetOutputs(AOutputs: TMatrixSingle): INeuronLayerHack;
    function SetWeights(AWeights: TMatrixSingle): INeuronLayerHack;
    function SetBias(ABias: TMatrixSingle): INeuronLayerHack;
    function GetOutputs(out AOutputs: TMatrixSingle): INeuronLayerHack;
    function GetNeuronCount(out ANeuronCount: Integer): INeuronLayerHack;
    function GetWeights(out AWeights: TMatrixSingle): INeuronLayerHack;
    function GetBias(out ABias: TMatrixSingle): INeuronLayerHack;
  end;

implementation

end.
