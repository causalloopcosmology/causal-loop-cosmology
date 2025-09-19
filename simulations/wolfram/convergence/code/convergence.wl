(* --- CAUSAL LOOP COSMOLOGY (CLC) CONVERGENCE ANALYSIS SCRIPT --- *)
(*
  Version 1.0 - 2025-09-19
  Purpose: A faithful Wolfram Language translation of the Sage convergence
           analysis script. It runs simulations in accumulating batches
           to analyze the convergence of statistical moments.
*)

Print["--- Initializing CLC Convergence Analysis (v1.0) ---"];

(* --- CONFIGURATION --- *)
config = <|
   "ApproxN" -> 800,
   "TotalRuns" -> 10240,
   "BatchSizes" -> {40, 80, 160, 320, 640, 1280, 2560, 5120},
   "MaxSteps" -> 2000,
   "Alpha" -> 1.0,
   "Seed" -> 42,
   "OutputDir" -> "outputs_wolfram",
   "CSVFile" -> "convergence_N800.csv",
   "PlotFile" -> "convergence_N800.pdf"
|>;


(* --- CORE SIMULATION FUNCTIONS (Validated) --- *)
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

(* Adapted to return {N3 count, steps taken} *)
runSingleSimulation[alpha_?NumericQ, approxN_Integer, maxSteps_Integer] := Module[
  {G, N, T, step, proposalSet},
  G = SeedPrimordialCycle[CreateVacuumGraph[approxN]];
  Do[
   proposalSet = {};
   N = VertexCount[G]; T = 1.0 / Log[Max[2, N]];
   Do[Do[Do[
      If[ u =!= v && !EdgeQ[G, DirectedEdge[u, v]],
       If[isPermissible[G, v, w, u],
        If[CheckThermodynamicAcceptance[G, alpha], AppendTo[proposalSet, DirectedEdge[u, v]]];
        ]
       ],
      {u, GetOutNeighbors[G, w]}],
     {w, GetOutNeighbors[G, v]}],
    {v, VertexList[G]}];
   If[Length[proposalSet] == 0, Return[{Count3Cycles[G], step}]];
   G = EdgeAdd[G, DeleteDuplicates[proposalSet]];
   ,
   {step, 1, maxSteps}];
  Return[{Count3Cycles[G], maxSteps}];
];


(* --- MAIN CONVERGENCE ANALYSIS --- *)
Module[{startTime, allN3 = {}, cumulativeStats = {}, stats, endTime, csvPath, plotPath, runIndex = 1},
  startTime = AbsoluteTime[];
  If[!DirectoryQ[config[["OutputDir"]]], CreateDirectory[config[["OutputDir"]]]];
  Print["="*80];
  Print[StringTemplate["Running Convergence Analysis: N≈`ApproxN`, Total Runs=`TotalRuns`"][config]];
  Print["="*80];
  SeedRandom[config[["Seed"]]];
  
  Scan[
    Function[batchSize,
      If[runIndex > config[["TotalRuns"]], Return[]];
      Print[StringTemplate["\nRunning batch of `1` runs (starting at run `2`)..."][batchSize, runIndex]];
      
      (* Run the batch of simulations *)
      Module[{batchN3},
        batchN3 = Table[
            runSingleSimulation[config[["Alpha"]], config[["ApproxN"]], config[["MaxSteps"]]][[1]],
            {i, 1, batchSize}
        ];
        
        (* Append batch results to the master list *)
        allN3 = Join[allN3, batchN3];
        
        (* Calculate cumulative statistics *)
        Module[{currentTotal, currentMean, currentStd, currentStdErr},
            currentTotal = Length[allN3];
            currentMean = N[Mean[allN3]];
            currentStd = N[StandardDeviation[allN3]];
            currentStdErr = currentStd / Sqrt[currentTotal];
            
            AppendTo[cumulativeStats, <|
                "total_runs" -> currentTotal,
                "mean_n3" -> currentMean,
                "std_n3" -> currentStd,
                "stderr_n3" -> currentStdErr
            |>];
            Print[StringTemplate[" \[RightArrow] Cumulative after `1` runs: mean=`2`, std=`3`, SE=`4`"][
                currentTotal,
                Round[currentMean, 0.01],
                Round[currentStd, 0.01],
                Round[currentStdErr, 0.001]
            ]];
        ];
        runIndex += batchSize;
      ];
    ],
    config[["BatchSizes"]]
  ];
  
  (* --- SAVE AND PLOT RESULTS --- *)
  Print["\n" <> "="*80];
  Print["Convergence analysis complete."];
  
  (* Save data to CSV *)
  csvPath = FileNameJoin[{config[["OutputDir"]], config[["CSVFile"]]}];
  Export[csvPath, cumulativeStats];
  Print[StringTemplate["Data saved to: `1`"][AbsoluteFileName[csvPath]]];
  
  (* Extract data for plotting *)
  Module[{totals, means, stderrs, upperBounds, lowerBounds, meanPlot, errorBandPlot, finalPlot},
    totals = cumulativeStats[[All, "total_runs"]];
    means = cumulativeStats[[All, "mean_n3"]];
    stderrs = cumulativeStats[[All, "stderr_n3"]];
    upperBounds = means + stderrs;
    lowerBounds = means - stderrs;
    
    (* Create the plot for the mean *)
    meanPlot = ListLogLogPlot[Transpose[{totals, means}],
        PlotStyle -> {Blue, Thick}, Joined -> True,
        PlotLegends -> {"Mean Final N₃"}
    ];
    
    (* Create the plot for the standard error band *)
    errorBandPlot = ListLogLogPlot[
        {Transpose[{totals, upperBounds}], Transpose[{totals, lowerBounds}]},
        PlotStyle -> {Red, Dashed}, Filling -> {1 -> {2}}, FillingStyle -> Opacity[0.1, Red]
    ];
    
    (* Combine and style the final plot *)
    finalPlot = Show[errorBandPlot, meanPlot,
        PlotTheme -> "Scientific", GridLines -> True,
        PlotLabel -> StringTemplate["Convergence of Mean N₃ at N≈`1`"][config[["ApproxN"]]],
        AxesLabel -> {"Number of Runs (Cumulative)", "Mean Final N₃"}
    ];
    
    (* Export the final plot to PDF *)
    plotPath = FileNameJoin[{config[["OutputDir"]], config[["PlotFile"]]}];
    Export[plotPath, finalPlot];
    Print[StringTemplate["Plot saved to: `1`"][AbsoluteFileName[plotPath]]];
  ];
  Print["="*80];
];