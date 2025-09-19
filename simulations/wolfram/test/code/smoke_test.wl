(* --- CAUSAL LOOP COSMOLOGY (CLC) SMOKE TEST SCRIPT --- *)
(* Version 1.8 - 2025-09-19 *)
(* Author: R. Fisher *)
(* Purpose: Smoke test for CLC simulation components, fixing numChildren and Test 5 expectation. *)

Print["--- Running CLC Smoke Test Suite (v1.8) ---"];

(* --- CONFIGURATION --- *)
config = <|
   "ApproxN" -> 40,
   "MaxSteps" -> 2000,
   "Alpha" -> 1.0,
   "Seed" -> 42,
   "OutputDir" -> "outputs_wolfram",
   "CSVFile" -> "smoke_test_data.csv",
   "StatsFile" -> "smoke_test_summary.txt"
|>;

(* --- CORE UTILITY FUNCTIONS --- *)
CreateVacuumGraph[approxN_Integer] := Module[
  {G, root = 1, levels = {{1}}, currentLevel, nextLevel, nodeId = 2},
  If[approxN < 3, Return[Graph[{1, 2, 3}, {1 -> 2, 2 -> 3, 3 -> 1}]]];
  G = Graph[{root}, {}];
  While[VertexCount[G] < approxN,
    currentLevel = Last[levels];
    nextLevel = {};
    Do[
      numChildren = If[parent == 1, 3, 2];
      Print["Debug: parent = ", parent, ", numChildren = ", numChildren];
      If[!IntegerQ[numChildren] || numChildren < 1,
        Print["Error: Invalid numChildren = ", numChildren];
        Break[]
      ];
      Do[
        If[VertexCount[G] >= approxN, Break[]];
        G = VertexAdd[G, nodeId];
        G = EdgeAdd[G, DirectedEdge[parent, nodeId]];
        AppendTo[nextLevel, nodeId];
        Print["Debug: Added vertex ", nodeId, ", edge ", parent, "->", nodeId];
        nodeId++;
      , {i, 1, numChildren}];
    , {parent, currentLevel}];
    If[nextLevel == {}, Break[]];
    AppendTo[levels, nextLevel];
    Print["Debug: New level added, vertices = ", VertexCount[G]];
  ];
  Print["Debug: CreateVacuumGraph produced ", VertexCount[G], " vertices, ", EdgeCount[G], " edges"];
  If[!GraphQ[G], Print["Error: Invalid graph produced"]];
  G
];

SeedPrimordialCycle[graph_Graph] := Module[
  {root = 1, thirdLayerNode, level2Exists},
  level2Exists = VertexCount[graph] >= 3 && AnyTrue[VertexList[graph], GraphDistance[graph, root, #] == 2 &];
  Print["Debug: SeedPrimordialCycle, level2Exists = ", level2Exists, ", VertexCount = ", VertexCount[graph]];
  If[!level2Exists,
    Return[Graph[{1 -> 2, 2 -> 3, 3 -> 1}]],
    thirdLayerNode = First[Select[VertexList[graph], GraphDistance[graph, root, #] == 2 &]];
    Print["Debug: Adding back-edge ", thirdLayerNode, "->", root];
    Return[EdgeAdd[graph, DirectedEdge[thirdLayerNode, root]]]
  ]
];

isPermissible[G_Graph, u_, v_, w_] := Module[
  {edgeExists, tempG, hasOtherPath},
  edgeExists = EdgeQ[G, DirectedEdge[v, w]];
  If[!edgeExists,
    Print["Debug: No edge ", v, "->", w];
    Return[False]
  ];
  tempG = EdgeDelete[G, DirectedEdge[v, w]];
  Print["Debug: tempG vertices: ", VertexList[tempG], ", edges: ", EdgeList[tempG]];
  hasOtherPath = GraphDistance[tempG, v, u] =!= Infinity;
  Print["Debug: isPermissible(", u, ",", v, ",", w, ") -> hasOtherPath = ", hasOtherPath];
  Print["Debug: GraphDistance from v=", v, " to u=", u, " = ", GraphDistance[tempG, v, u]];
  !hasOtherPath
];

Count3Cycles[g_Graph] := Module[
  {A, traceVal},
  If[!GraphQ[g], Return[0]];
  A = AdjacencyMatrix[g];
  traceVal = Tr[MatrixPower[A, 3]];
  Round[N[traceVal / 3.0]]
];

(* --- SMOKE TEST FUNCTIONS --- *)
Test[description_, actual_, expected_, testNumber_] := Module[
  {},
  Print["Test ", testNumber, ": ", description];
  If[MatchQ[actual, expected] || (NumberQ[actual] && NumberQ[expected] && Abs[actual - expected] < 10^-6),
    Print["PASS"],
    Print["FAIL: Expected ", expected, ", got ", actual]
  ];
  Print[""]
];

(* Test 1: Graph Creation (Empty Graph) *)
Test1[] := Module[
  {G},
  G = Graph[{1}, {}];
  Test["Create empty graph with one vertex", VertexCount[G], 1, 1]
];

(* Test 2: Graph Creation (Small Tree) *)
Test2[] := Module[
  {G, vertexCount, edgeCount},
  G = CreateVacuumGraph[5];
  vertexCount = VertexCount[G];
  edgeCount = EdgeCount[G];
  Test["Create small tree (5 nodes)", {vertexCount, edgeCount}, {5, 4}, 2]
];

(* Test 3: Graph Creation (Full Size) *)
Test3[] := Module[
  {G, vertexCount},
  G = CreateVacuumGraph[config["ApproxN"]];
  vertexCount = VertexCount[G];
  Test["Create full-size graph (~40 nodes)", Between[vertexCount, {38, 42}], True, 3]
];

(* Test 4: Primordial Cycle Injection *)
Test4[] := Module[
  {G, GPrimed, n3, vertexCount},
  G = CreateVacuumGraph[5];
  vertexCount = VertexCount[G];
  GPrimed = SeedPrimordialCycle[G];
  n3 = Count3Cycles[GPrimed];
  Test["Inject primordial cycle (N=5)", {vertexCount, n3}, {5, 1}, 4]
];

(* Test 5: Permissible Check *)
Test5[] := Module[
  {G, result},
  G = Graph[{1 -> 2, 2 -> 3, 3 -> 1}];
  result = isPermissible[G, 2, 3, 1];
  Test["Permissible check on 3-cycle (no alternative path)", result, True, 5]
];

(* Test 6: 3-Cycle Counting *)
Test6[] := Module[
  {G, n3},
  G = Graph[{1 -> 2, 2 -> 3, 3 -> 1}];
  n3 = Count3Cycles[G];
  Test["Count 3-cycles in a 3-cycle", n3, 1, 6]
];

(* Test 7: Thermodynamic Probability *)
Test7[] := Module[
  {alpha, N, T, deltaF, prob, expected},
  alpha = config["Alpha"];
  N = 40;
  T = 1.0 / Log[Max[2, N]];
  deltaF = alpha - T;
  prob = Min[1.0, Exp[-deltaF / T]];
  expected = Min[1.0, Exp[- (1.0 - 1/Log[40])/ (1/Log[40])]];
  Test["Thermodynamic probability calculation", prob, expected, 7]
];

(* Test 8: Single Simulation Step *)
Test8[] := Module[
  {G, proposalSet, v, w, u},
  G = Graph[{1 -> 2, 2 -> 3, 3 -> 1}];
  proposalSet = {};
  Do[
    Do[
      Do[
        If[u =!= v && !EdgeQ[G, DirectedEdge[u, v]],
          If[isPermissible[G, u, v, w],
            AppendTo[proposalSet, DirectedEdge[u, v]]
          ]
        ],
      {u, AdjacencyList[G, w]}],
    {w, AdjacencyList[G, v]}],
  {v, VertexList[G]}];
  Test["Single simulation step proposals", Length[proposalSet], 0, 8]
];

(* Test 9: Random Seed Reproducibility *)
Test9[] := Module[
  {r1, r2},
  SeedRandom[config["Seed"]];
  r1 = RandomReal[];
  SeedRandom[config["Seed"]];
  r2 = RandomReal[];
  Test["Random seed reproducibility", r1 == r2, True, 9]
];

(* Test 10: Output Formatting *)
Test10[] := Module[
  {csvPath, statsPath, n3Results, stats, summaryText},
  n3Results = {23, 25, 27};
  stats = <|
    "Mean_N3" -> N[Mean[n3Results]],
    "Std_Dev_N3" -> N[StandardDeviation[n3Results]]
  |>;
  csvPath = FileNameJoin[{config["OutputDir"], config["CSVFile"]}];
  If[!DirectoryQ[config["OutputDir"]], CreateDirectory[config["OutputDir"]]];
  Export[csvPath, Prepend[Transpose[{Range[Length[n3Results]], n3Results}], {"Run_ID", "Final_N3"}], "CSV"];
  statsPath = FileNameJoin[{config["OutputDir"], config["StatsFile"]}];
  summaryText = StringJoin[
    StringRepeat["=", 50], "\n",
    "Test Summary\n",
    StringRepeat["=", 50], "\n",
    StringRiffle[KeyValueMap[#1 <> ": " <> ToString[N[#2, 4]] &, stats], "\n"], "\n",
    StringRepeat["=", 50]];
  Export[statsPath, summaryText, "Text"];
  Test["Output formatting (CSV and stats)", FileExistsQ[csvPath] && FileExistsQ[statsPath], True, 10]
];

(* --- RUN ALL TESTS --- *)
Module[
  {},
  Print[StringRepeat["=", 80]];
  Print["Starting Smoke Tests"];
  Print[StringRepeat["=", 80]];
  Test1[];
  Test2[];
  Test3[];
  Test4[];
  Test5[];
  Test6[];
  Test7[];
  Test8[];
  Test9[];
  Test10[];
  Print[StringRepeat["=", 80]];
  Print["Smoke Tests Complete"];
  Print[StringRepeat["=", 80]]
];