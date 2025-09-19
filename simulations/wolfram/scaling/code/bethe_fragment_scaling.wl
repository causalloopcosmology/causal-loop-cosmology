(* --- CAUSAL LOOP COSMOLOGY (CLC) BETHE FRAGMENT ANALYSIS --- *)
(*
  Version 1.0 - 2025-09-19
  Author: R. Fisher
  Purpose: To generate Bethe fragments and analyze their structural properties.
*)

Print["--- Initializing Bethe Fragment Analysis (v1.0) ---"];

(* --- CORE FUNCTIONS --- *)

generateBetheFragmentMetrics[depth_Integer, b_Integer] := Module[
  {g, root = 0, nodeId = 1, levels, allDegrees, regularNodeCount, fracBRegular},
  If[depth < 1 || b < 3, Return[<||>]];
  g = Graph[{}, {}, DirectedEdges -> False];
  g = VertexAdd[g, root];
  levels = {{root}};
  Do[
    Module[{currentLevel = Last[levels], nextLevel = {}},
      Do[
        Module[{numChildren = If[parent == root, b, b - 1]},
          Do[
            g = VertexAdd[g, nodeId];
            g = EdgeAdd[g, UndirectedEdge[parent, nodeId]];
            AppendTo[nextLevel, nodeId];
            nodeId++;
          , {numChildren}]
        ],
        {parent, currentLevel}];
      If[Length[nextLevel] == 0, Break[]];
      AppendTo[levels, nextLevel];
    ],
    {d, 1, depth}
  ];
  
  allDegrees = VertexDegree[g];
  regularNodeCount = Count[allDegrees, b];
  fracBRegular = If[VertexCount[g] > 0, N[regularNodeCount / VertexCount[g]], 0];

  <|
    "Depth" -> depth,
    "Coord" -> b,
    "Nodes" -> VertexCount[g],
    "Girth" -> Infinity,
    "b_Regular_Fraction" -> fracBRegular,
    "Theoretical_Limit" -> N[1.0 / (b - 1)]
  |>
];

(* --- MAIN EXECUTION --- *)
Module[{configsToTest, results = {}, csvPath, metrics, girthStr, fracStr, limitStr},
  Print[StringRepeat["=", 80]];
  Print["Running Bethe Fragment Scaling Analysis..."];
  Print[StringRepeat["=", 80]];

  configsToTest = Join[
    Table[<|"depth" -> d, "b" -> 3|>, {d, 3, 12}],
    Table[<|"depth" -> 5, "b" -> bval|>, {bval, {4, 5, 6}}]
  ];

  Do[
    metrics = generateBetheFragmentMetrics[config[["depth"]], config[["b"]]];
    AppendTo[results, metrics];
    Print[StringTemplate[" -> Completed: d=`Depth`, b=`Coord`. Found `Nodes` nodes."][metrics]];
  ,
  {config, configsToTest}];

  If[!DirectoryQ["outputs_wolfram"], CreateDirectory["outputs_wolfram"]];
  csvPath = FileNameJoin[{"outputs_wolfram", "bethe_scaling_results.csv"}];
  Export[csvPath, results];
  Print[StringTemplate["\nAnalysis complete. Full data saved to: `path`"][<|"path" -> AbsoluteFileName[csvPath]|>]];

  Print["\n" <> StringRepeat["=", 80]];
  Print["Table 2: Structural Properties and Convergence of Generated Bethe Fragments."];
  Print[StringRepeat["=", 80]];
  Print[
    StringPadRight["Depth (d)", 12],
    StringPadRight["Coord. (b)", 12],
    StringPadRight["Nodes", 10],
    StringPadRight["Girth", 10],
    StringPadRight["b-Regular Fraction", 22],
    "Theoretical Limit (1/(b-1))"
  ];
  Print[StringRepeat["-", 90]];

  Do[
    girthStr = If[row[["Girth"]] === Infinity, "Infinity", ToString[row[["Girth"]]]];
    fracStr = ToString[NumberForm[100 * row[["b_Regular_Fraction"]], {4, 2}]] <> "%";
    limitStr = ToString[NumberForm[100 * row[["Theoretical_Limit"]], {4, 2}]] <> "%";
    Print[
      StringPadRight[ToString[row[["Depth"]]], 12],
      StringPadRight[ToString[row[["Coord"]]], 12],
      StringPadRight[ToString[row[["Nodes"]]], 10],
      StringPadRight[girthStr, 10],
      StringPadRight[fracStr, 22],
      limitStr
    ],
    {row, results}
  ];
  Print[StringRepeat["-", 90]];
];