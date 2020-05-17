unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ScrollBox,
  FMX.Memo, FMX.Controls.Presentation, FMX.StdCtrls, Math,
  FMX.Objects, FMX.Edit, MLP.Neuron;

type
  TForm3 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    ButtonTrain: TButton;
    EditPergunta: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonTrainClick(Sender: TObject);
  private
    { Private declarations }
    FNeuronOutput: INeuronLayer;
    FNeuronInput: INeuronLayer;
    FOutputs: TMatrixSingle;
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

const

  FPalavras: TArray<string> = [
    '?',
    'a',
    'do',
    'vai',
    'sol',
    'para',
    'hoje',
    'qual',
    'fazer',
    'tempo',
    'vento',
    'ficar',
    'chover',
    'nublado',
    'previsão',
    'velocidade'
  ];

  FPerguntas: TArray<string> = [
    'Qual a velocidade do vento para hoje?',
    'Qual a previsão do tempo para hoje?',
    'Hoje vai chover?',
    'Hoje vai fazer sol?',
    'Hoje vai ficar nublado?'
  ];

  FExpected: TArray<TArray<Single>> = [
    [1,0,0,0,0],
    [0,1,0,0,0],
    [0,0,1,0,0],
    [0,0,0,1,0],
    [0,0,0,0,1]
  ];

implementation


{$R *.fmx}

function CompareStringsInPercent(Str1, Str2: string): Byte;
type
  TLink = array[0..1] of Byte;
var
  tmpPattern: TLink;
  PatternA, PatternB: array of TLink;
  IndexA, IndexB, LengthStr: Integer;
begin
  Result := 100;
  LengthStr := Max(Length(Str1), Length(Str2));
  for IndexA := 1 to LengthStr do
  begin
    if Length(Str1) >= IndexA then
    begin
      SetLength(PatternA, (Length(PatternA) + 1));
      PatternA[Length(PatternA) - 1][0] := Byte(Str1[IndexA]);
      PatternA[Length(PatternA) - 1][1] := IndexA;
    end;
    if Length(Str2) >= IndexA then
    begin
      SetLength(PatternB, (Length(PatternB) + 1));
      PatternB[Length(PatternB) - 1][0] := Byte(Str2[IndexA]);
      PatternB[Length(PatternB) - 1][1] := IndexA;
    end;
  end;
  IndexA := 0;
  IndexB := 0;
  while ((IndexA < (Length(PatternA) - 1)) and (IndexB < (Length(PatternB) - 1))) do
  begin
    if Length(PatternA) > IndexA then
    begin
      if PatternA[IndexA][0] < PatternA[IndexA + 1][0] then
      begin
        tmpPattern[0]           := PatternA[IndexA][0];
        tmpPattern[1]           := PatternA[IndexA][1];
        PatternA[IndexA][0]     := PatternA[IndexA + 1][0];
        PatternA[IndexA][1]     := PatternA[IndexA + 1][1];
        PatternA[IndexA + 1][0] := tmpPattern[0];
        PatternA[IndexA + 1][1] := tmpPattern[1];
        if IndexA > 0 then Dec(IndexA);
      end
      else
        Inc(IndexA);
    end;
    if Length(PatternB) > IndexB then
    begin
      if PatternB[IndexB][0] < PatternB[IndexB + 1][0] then
      begin
        tmpPattern[0]           := PatternB[IndexB][0];
        tmpPattern[1]           := PatternB[IndexB][1];
        PatternB[IndexB][0]     := PatternB[IndexB + 1][0];
        PatternB[IndexB][1]     := PatternB[IndexB + 1][1];
        PatternB[IndexB + 1][0] := tmpPattern[0];
        PatternB[IndexB + 1][1] := tmpPattern[1];
        if IndexB > 0 then Dec(IndexB);
      end
      else
        Inc(IndexB);
    end;
  end;
  LengthStr := Min(Length(PatternA), Length(PatternB));
  for IndexA := 0 to (LengthStr - 1) do
  begin
    if PatternA[IndexA][0] = PatternB[IndexA][0] then
    begin
      if Max(PatternA[IndexA][1], PatternB[IndexA][1]) - Min(PatternA[IndexA][1],
        PatternB[IndexA][1]) > 0 then Dec(Result,
        ((100 div LengthStr) div (Max(PatternA[IndexA][1], PatternB[IndexA][1]) -
          Min(PatternA[IndexA][1], PatternB[IndexA][1]))))
      else if Result < 100 then Inc(Result);
    end
    else
      Dec(Result, (100 div LengthStr))
  end;
  SetLength(PatternA, 0);
  SetLength(PatternB, 0);
end;

procedure TForm3.Button1Click(Sender: TObject);
var
  LSplitedString: TArray<string>;
  LPergunta: TArray<Single>;
  I, X: Integer;
  LStringMatch: Single;
  LWinnerValue: Single;
  LWinnerDigit: Integer;
  LActivation: IActivation;
begin

  LSplitedString := EditPergunta.Text.Trim.Replace('?', ' ?').Split([' ']);

  SetLength(LPergunta, Length(FPalavras));

  for I := Low(FPalavras) to High(FPalavras) do
  begin
    for X := Low(LSplitedString) to High(LSplitedString) do
    begin
      LStringMatch := CompareStringsInPercent(FPalavras[I], LSplitedString[X]) / 100;
      if LPergunta[I] < LStringMatch then
        LPergunta[I] := LStringMatch;
    end;
  end;

   LActivation := TSigmoidActivation.Create;

   TNeuronPredict.Create
   .SetNeuronLayer(FNeuronInput)
   .SetActivation(LActivation)
   .SetInputs(TMatrixSingle.ArrayToMatrix(LPergunta))
   .Predict(FOutputs);

   LWinnerDigit := 0;
   LWinnerValue := FOutputs.GetValue(0, 0);
   Memo1.Lines.Clear;

  FOutputs.Map(
    procedure(var AValue: Single; ARow: Integer; ACol: Integer)
    begin
      if (ACol = 0) then
      begin
        if (LWinnerValue <= AValue) then
        begin
          LWinnerDigit := ARow;
          LWinnerValue := AValue;
        end;
      end;
    end);

   if LWinnerValue>0.55 then
    Memo1.Lines.Add('Pergunta provável: '+FPerguntas[LWinnerDigit])
   else
    Memo1.Lines.Add('Não entendi muito bem! Pode refazer sua pergunta?')
end;

procedure TForm3.ButtonTrainClick(Sender: TObject);
var
  LSplitedString: TArray<string>;
  LActivation: IActivation;
  LStringMatch: Single;
  LNeuronTrainer: INeuronTrainer;
  LPergunta: TArray<Single>;
  Y, I, X, W: Integer;
begin
   LActivation := TSigmoidActivation.Create;

   LNeuronTrainer:=
   TNeuronTrainer.Create
   .SetActivation(LActivation)
   .SetLearningRate(0.1)
   .SetNeuronLayer(FNeuronInput);

  for W := 0 to 999 do
   begin
     for Y := Low(FPerguntas) to High(FPerguntas) do
     begin

       LSplitedString := FPerguntas[Y].Replace('?', ' ?').ToLower.Split([' ']);

       SetLength(LPergunta, Length(FPalavras));

       for I := Low(FPalavras) to High(FPalavras) do
       begin
         LPergunta[I]:=0;
         for X := Low(LSplitedString) to High(LSplitedString) do
         begin
           LStringMatch := CompareStringsInPercent(FPalavras[I], LSplitedString[X]) / 100;
           if (LPergunta[I] < LStringMatch) and (LStringMatch>0.5) then
             LPergunta[I] := LStringMatch;
         end;
       end;

       LNeuronTrainer
       .SetInputs(TMatrixSingle.ArrayToMatrix(LPergunta))
       .SetExpectedOutputs(TMatrixSingle.ArrayToMatrix(FExpected[Y])).Train;

     end;
   end;


end;

procedure TForm3.FormCreate(Sender: TObject);
begin
  FNeuronInput := TNeuronLayer.Create(16);
  FNeuronInput.ConnectWith(TNeuronLayer.Create(32).ConnectWith(TNeuronLayer.Create(24).ConnectWith( TNeuronLayer.Create(5))));
end;

end.
