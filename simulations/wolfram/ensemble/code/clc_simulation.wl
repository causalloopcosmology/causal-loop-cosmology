(* --- CAUSAL LOOP COSMOLOGY (CLC) SIMULATION SCRIPT --- *)
(*
  Version 1.0 - 2025-09-19
  Author: R. Fisher
  Purpose: The final, working, and validated translation of the Sage
           script, configured for a full production ensemble run.
*)

Print["--- Initializing CLC Simulation Framework (v17.1 - Production) ---"];

(* --- CONFIGURATION --- *)
config = <|
   "EnsembleSize" -> 5000,
   "ApproxN" -> 40,
   "MaxSteps" -> 2000,
   "Alpha" -> 1.0,
   "Seed" -> 42,
   "OutputDir" -> "outputs_wolfram",
   "CSVFile" -> "ensemble_N40_data.csv",
   "StatsFile" -> "ensemble_N40_summary.txt"
|>;


(* --- CORE SIMULATION FUNCTIONS --- *)
CreateVacuumGraph[approxN_Integer] := Module[
  {G, root = 0, levels = {{0}}, nodeId = 1},
  If[approxN < 3, Return[Graph[{0, 1, 2}, {0 -> 1, 1 -> 2, 2 -> 0}]]];
  G = Graph[{root}, {}];
  While[VertexCount[G] < approxN,
    Module[{currentLevel = Last[levels], nextLevel = {}},
     Do[
      Module[{numChildren = If[parent == root, 3, 2]},
       Do[
        If[VertexCount[G] >= approxN, Break[]];
        G = VertexAdd[G, nodeId];
        G = EdgeAdd[G, DirectedEdge[parent, nodeId]];
        AppendTo[nextLevel, nodeId];
        nodeId++;
        , {numChildren}]
       ],
      {parent, currentLevel}];
     If[Length[nextLevel] == 0, Break[]];
     AppendTo[levels, nextLevel];
     ]
    ];
  G
];

SeedPrimordialCycle[graph_Graph] := Module[{root = 0, thirdLayerNode},
  thirdLayerNode = First[Select[VertexList[graph], GraphDistance[graph, root, #] == 2 &], Missing[]];
  If[MissingQ[thirdLayerNode], Graph[{0 -> 1, 1 -> 2, 2 -> 0}], EdgeAdd[graph, DirectedEdge[thirdLayerNode, root]]]
];

Count3Cycles[g_Graph] := Round[Tr[MatrixPower[AdjacencyMatrix[g], 3]]/3.0];

GetOutNeighbors[graph_Graph, v_] := Cases[EdgeList[graph], DirectedEdge[v, w_] :> w];

isPermissible[graph_Graph, v_, w_, u_] := Module[{tempGraph},
  tempGraph = EdgeDelete[graph, DirectedEdge[v, w]];
  Length[FindShortestPath[tempGraph, v, u]] == 0
];

CheckThermodynamicAcceptance[graph_Graph, alpha_?NumericQ] := Module[{n = VertexCount[graph], temp, deltaF, prob},
  temp = 1.0 / Log[Max[2, n]];
  deltaF = alpha - temp;
  prob = Min[1.0, Exp[-deltaF / temp]];
  RandomReal[] < prob
];

runSingleSimulation[alpha_?NumericQ, approxN_Integer, maxSteps_Integer] := Module[
  {G, N, T, step, proposalSet},
  G = SeedPrimordialCycle[CreateVacuumGraph[approxN]];
  Do[
   proposalSet = {};
   N = VertexCount[G]; T = 1.0 / Log[Max[2, N]];
   Do[
    Do[
     Do[
      If[ u =!= v && !EdgeQ[G, DirectedEdge[u, v]],
       If[isPermissible[G, v, w, u],
        If[CheckThermodynamicAcceptance[G, alpha],
         AppendTo[proposalSet, DirectedEdge[u, v]]
         ]
        ]
       ],
      {u, GetOutNeighbors[G, w]}],
     {w, GetOutNeighbors[G, v]}],
    {v, VertexList[G]}];

   If[Length[proposalSet] == 0, Return[G]];
   G = EdgeAdd[G, DeleteDuplicates[proposalSet]];
   ,
   {step, 1, maxSteps}];
  Return[G];
];

(* --- MAIN ENSEMBLE EXECUTION (SINGLE-THREADED) --- *)
Module[{startTime, n3Results, stats, endTime, csvPath, statsPath},
  startTime = AbsoluteTime[];
  If[!DirectoryQ[config[["OutputDir"]]], CreateDirectory[config[["OutputDir"]]]];
  Print["="*80];
  Print[StringTemplate["Running Ensemble: N≈`ApproxN`, Runs=`EnsembleSize`"][config]];
  Print["="*80];
  SeedRandom[config[["Seed"]]];
  n3Results = Table[
    If[Mod[i, 100] == 0 && i > 0, Print[StringTemplate["... progress: `i`/`t`"][<|"i" -> i, "t" -> config[["EnsembleSize"]]|>]]];
    Count3Cycles[runSingleSimulation[config[["Alpha"]], config[["ApproxN"]], config[["MaxSteps"]]]],
    {i, 1, config[["EnsembleSize"]]}
  ];
  Print["\nEnsemble complete. Analyzing and saving results..."];
  stats = <|"Mean_N3" -> N[Mean[n3Results]], "Std_Dev_N3" -> N[StandardDeviation[n3Results]], "Median_N3" -> N[Median[n3Results]], "Min_N3" -> Min[n3Results], "Max_N3" -> Max[n3Results]|>;
  csvPath = FileNameJoin[{config[["OutputDir"]], config[["CSVFile"]]}];
  Export[csvPath, Prepend[Transpose[{Range[config[["EnsembleSize"]]], n3Results}], {"Run_ID", "Final_N3"}]];
  statsPath = FileNameJoin[{config[["OutputDir"]], config[["StatsFile"]]}];
  WriteString[statsPath, StringRiffle[{"="*50, StringTemplate["Ensemble Summary for N≈`ApproxN`"][config], "="*50, StringRiffle[KeyValueMap[#1 <> ": " <> ToString[#2] &, stats], "\n"], "="*50}, "\n"]];
  endTime = AbsoluteTime[];
  Print["\n" <> "="*80];
  Print["STATISTICAL ANALYSIS COMPLETE"];
  Print[StringTemplate["Total time for `EnsembleSize` runs: `time` seconds"][<|"EnsembleSize" -> config[["EnsembleSize"]], "time" -> Round[endTime - startTime, 0.01]|>]];
  Print["="*80];
  Print[StringPadRight["Metric", 20], StringPadLeft["Value", 15]];
  Print["-"*80];
  Do[Print[StringPadRight[key, 20], StringPadLeft[ToString[stats[key]], 15]], {key, Keys[stats]}];
  Print["-"*80];
  Print["Raw data saved to:      ", AbsoluteFileName[csvPath]];
  Print["Summary stats saved to: ", AbsoluteFileName[statsPath]];
  Print["="*80];
];