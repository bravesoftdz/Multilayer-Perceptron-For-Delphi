unit MLP.Concret.Activations;

interface

uses
  MLP.Contract.Activation, System.Math;

type

  TSigmoidActivation = class(TInterfacedObject, IActivation)
  public
    { public declarations }
    procedure Activation(var AValue: Single);
  end;

  TFastSigmoidActivation = class(TInterfacedObject, IActivation)
  public
    { public declarations }
    procedure Activation(var AValue: Single);
  end;

  TIntegralActivation = class(TInterfacedObject, IActivation)
  public
    { public declarations }
    procedure Activation(var AValue: Single);
  end;

implementation

{ TSigmoidActivation }

procedure TSigmoidActivation.Activation(var AValue: Single);
var
  LAlpha: Single;
begin
  LAlpha := 1;
  AValue := 1 / (1 + exp(-AValue * LAlpha));
end;

{ TFastSigmoidActivation }

procedure TFastSigmoidActivation.Activation(var AValue: Single);
var
  LAlpha: Single;
begin
  LAlpha := 1;
  AValue := 0.5 * (AValue * LAlpha / (1 + abs(AValue * LAlpha))) + 0.5;
end;

{ TIntegralActivation }

procedure TIntegralActivation.Activation(var AValue: Single);
begin
  AValue := (AValue) / Sqrt(1 + Power((AValue), 2));
end;

end.
