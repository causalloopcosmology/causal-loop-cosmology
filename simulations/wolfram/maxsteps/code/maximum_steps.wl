(* --- CAUSAL LOOP COSMOLOGY (CLC) MAX STEPS ANALYSIS SCRIPT --- *)
(*
  Version 1.0 - 2025-09-19
  Author: R. Fisher
  Purpose: To empirically determine the natural termination step count for
           simulations across a range of graph sizes (N).
*)

Print["--- Initializing CLC Max Steps Analysis (v1.0) ---"];

(* --- CONFIGURATION --- *)
config = <|
    "NValuesToTest" -> {80, 120, 160, 200, 240, 280, 320, 400, 480, 560, 640, 800, 960, 1120, 1280, 1600, 1920, 2240, 2560},
    "RunsPerN" -> 200,
    "SimulationStepsLimit" -> 5000,
    "Alpha" -> 1.0,
    "Seed" -> 42,
    "OutputDir" -> "outputs_wolfram",
    "SummaryCSV" -> "step_limit_summary.csv",
    "PerRunPrefix" -> "step_limit_per_run_N"
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
  {G, n, T, step, proposalSet},
  G = SeedPrimordialCycle[CreateVacuumGraph[approxN]];
  Catch[
    Do[
      proposalSet = {};
      n = VertexCount[G]; T = 1.0 / Log[Max[2, n]];
      Do[Do[Do[
        If[ u =!= v && !EdgeQ[G, DirectedEdge[u, v]],
          If[isPermissible[G, v, w, u],
            If[CheckThermodynamicAcceptance[G, alpha], AppendTo[proposalSet, DirectedEdge[u, v]]];
          ]
        ],
        {u, GetOutNeighbors[G, w]}],
        {w, GetOutNeighbors[G, v]}],
      {v, VertexList[G]}];

      If[Length[proposalSet] == 0,
        Throw[{Count3Cycles[G], step}]
      ];
      
      G = EdgeAdd[G, DeleteDuplicates[proposalSet]];
    ,
    {step, 1, maxSteps}];
    {Count3Cycles[G], maxSteps}
  ]
];

(* --- MAIN EXPERIMENT EXECUTION --- *)
Module[{startTime, summaryResults = {}},
  startTime = AbsoluteTime[];
  If[!DirectoryQ[config[["OutputDir"]]], CreateDirectory[config[["OutputDir"]]]];
  Print[StringRepeat["=", 80]];
  Print["Running Experiment to Determine Maximum Step Counts (v1.3)"];
  Print[StringRepeat["=", 80]];
  SeedRandom[config[["Seed"]]];

  Do[
    Print[StringTemplate["\nTesting N ~ `1` (`2` runs)..."][nApprox, config[["RunsPerN"]]]];

    Module[{runResults, stepsList, n3List, perRunData, maxStepsObserved, meanSteps, hitLimitCount, perRunPath},
      runResults = Table[
        runSingleSimulation[config[["Alpha"]], nApprox, config[["SimulationStepsLimit"]]],
        {i, 1, config[["RunsPerN"]]}
      ];

      {n3List, stepsList} = Transpose[runResults];
      maxStepsObserved = Max[stepsList];
      meanSteps = N[Mean[stepsList]];
      hitLimitCount = Count[stepsList, config[["SimulationStepsLimit"]]];

      AppendTo[summaryResults, <|
        "N_approx" -> nApprox,
        "max_steps_observed" -> maxStepsObserved,
        "mean_steps" -> Round[meanSteps, 0.01],
        "hit_limit_count" -> hitLimitCount
      |>];

      perRunData = Table[<|"Run" -> i, "Final_N3" -> n3List[[i]], "Steps_Taken" -> stepsList[[i]]|>, {i, 1, Length[stepsList]}];
      perRunPath = FileNameJoin[{config[["OutputDir"]], StringTemplate["`prefix``N`.csv"][<|"prefix" -> config[["PerRunPrefix"]], "N" -> nApprox|>] }];
      Export[perRunPath, perRunData];
      Print[StringTemplate[" -> Max steps observed: `max`. Runs hitting limit: `hits`. Data saved."][<|"max" -> maxStepsObserved, "hits" -> hitLimitCount|>]];
    ],
    {nApprox, config[["NValuesToTest"]]}
  ];

  (* --- SAVE SUMMARY AND PRINT FINAL REPORT --- *)
  Module[{summaryPath},
    summaryPath = FileNameJoin[{config[["OutputDir"]], config[["SummaryCSV"]]}];
    Export[summaryPath, summaryResults];
    Print["\n" <> StringRepeat["=", 80]];
    Print["EXPERIMENT COMPLETE"];
    Print[StringTemplate["Total time: `time` seconds"][<|"time" -> Round[AbsoluteTime[] - startTime, 0.01]|>]];
    Print[StringRepeat["=", 80]];
    Print[StringPadRight["Graph Size (N)", 20], StringPadRight["Max Steps Observed", 25], StringPadLeft["Hit Limit Count", 20]];
    Print[StringRepeat["-", 80]];
    Do[
      Print[
        StringPadRight[ToString[row[["N_approx"]]], 20],
        StringPadRight[ToString[row[["max_steps_observed"]]], 25],
        StringPadLeft[ToString[row[["hit_limit_count"]]], 20]
      ],
      {row, summaryResults}
    ];
    Print[StringRepeat["-", 80]];
    Print["Summary report saved to: ", AbsoluteFileName[summaryPath]];
    Print[StringRepeat["=", 80]];
  ];
];