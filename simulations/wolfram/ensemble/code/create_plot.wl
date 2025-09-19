(* --- Visualization Script for CLC Data --- *)
(*
  Purpose: Loads the CSV data from the main simulation and generates
           a publication-quality histogram.
*)

Print["--- Generating Histogram from Simulation Data ---"];

(* 1. Define file paths *)
dataDir = "outputs_wolfram";
dataFile = FileNameJoin[{dataDir, "ensemble_N40_data.csv"}];
plotFile = FileNameJoin[{dataDir, "ensemble_N40_histogram.pdf"}];

(* 2. Import the data, skipping the header row and taking the second column *)
If[!FileExistsQ[dataFile], 
  Print["Error: Data file not found at ", dataFile]; Exit[]
];
data = Import[dataFile, "Data"][[2 ;;, 2]];

(* 3. Calculate the mean for the plot legend *)
meanN3 = N[Mean[data]];

(* 4. Generate a high-quality histogram *)
plot = Histogram[data, Automatic, "PDF",
  PlotTheme -> "Scientific",
  ChartStyle -> EdgeForm[GrayLevel[0.3]],
  GridLines -> {Automatic, None},
  PlotLabel -> Style["Distribution of Final N3 (N≈40, 5000 Runs)", 16],
  AxesLabel -> {"Final 3-Cycle Count (N₃)", "Probability Density"},
  Epilog -> {Red, Dashed, Thick, Line[{{meanN3, 0}, {meanN3, Automatic}}]},
  PlotLegends -> PointLegend[{Red}, {StringTemplate["Mean = ``"][Round[meanN3, 0.01]]}, LegendMarkerSize -> 0]
];

(* 5. Export the plot to a PDF file *)
Export[plotFile, plot];
Print["Success! Histogram exported to: ", AbsoluteFileName[plotFile]];