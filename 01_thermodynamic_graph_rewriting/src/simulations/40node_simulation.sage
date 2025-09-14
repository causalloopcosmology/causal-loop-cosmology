#!/usr/bin/env sage
# -----------------------------------------------------------------------------
# Causal Loop Cosmology — Statistical Ensemble Analysis (Paper 1)
#
# Title:       Thermodynamic Graph Rewriting: A Category-Theoretic Model of Emergent Spacetime
# Author:      R. Fisher
# Affiliation: Independent Researcher
# Date:        September 12, 2025
# Version:     1.6
# DOI:         [To be assigned upon publication]
# License:     MIT
# Description: Simulates geometrogenesis via thermodynamic 3-cycle formation in a 
#              statistical ensemble of directed graphs. Validates inflationary phase 
#              transition from an acyclic zero-point information (ZPI) vacuum. 
#              Generates a histogram of final 3-cycle counts ($N_3$), a time-series 
#              of 3-cycle growth, and CSV/JSON outputs for reproducibility, supporting 
#              Section 4: Computational Validation of the manuscript.
# Dependencies: SageMath 10.4+, NumPy, tqdm (for progress bar)
# Outputs:     - Histogram: './outputs/figure_n3_distribution.pdf'
#              - Time-series: './outputs/inflation_time_series.pdf'
#              - CSV: './outputs/ensemble_results.csv' (N_3 counts and runtimes per run)
#              - JSON: './outputs/simulation_metadata.json' (config, versions, stats)
# Reproducibility Checklist:
#   - Seed: 42
#   - Software: SageMath 10.4+, NumPy 1.26+, tqdm 4.66+
#   - Hardware: Intel i7-12700, 16GB RAM (or equivalent)
#   - Runtime: ~2.5 minutes for 1000 runs (N=40)
# -----------------------------------------------------------------------------

from sage.all import DiGraph, log, exp, random, set_random_seed, Integer, histogram, line
import time
import csv
import json
import math
import numpy as np
import os
from datetime import datetime
try:
    from tqdm import tqdm
except ImportError:
    print("Warning: tqdm not found. Install with 'sage -pip install tqdm' for progress bar.")
    tqdm = lambda x: x  # Fallback to no progress bar

# --- CONFIGURATION ---
# Academic Note: Parameters model a depth-4 Bethe fragment as the ZPI vacuum.
#                NUM_RUNS set to 1000 for higher statistical precision.
ENSEMBLE_CONFIG = {
    "NUM_RUNS": 1000,          # Number of independent simulation runs
    "NUM_NODES_APPROX": 40,    # Target nodes (approximates depth-4 Bethe lattice)
    "SIMULATION_STEPS": 50,    # Maximum steps for graph evolution
    "ALPHA": 1.0,              # Free energy scaling constant (ΔF = α·Δρ_C - T·ΔS)
    "SEED": 42,                # Random seed for reproducibility
    "OUTPUT_FIGURE": "./outputs/figure_n3_distribution.pdf",      # Histogram output file
    "TIME_SERIES_FIGURE": "./outputs/inflation_time_series.pdf",  # Time-series output file
    "CSV_OUTPUT": "./outputs/ensemble_results.csv",               # CSV for N_3 and runtimes
    "JSON_OUTPUT": "./outputs/simulation_metadata.json"           # JSON for metadata
}

def validate_config(config):
    """Validate configuration parameters to ensure robustness."""
    if not isinstance(config["NUM_RUNS"], int) or config["NUM_RUNS"] <= 0:
        raise ValueError("NUM_RUNS must be a positive integer")
    if not isinstance(config["NUM_NODES_APPROX"], int) or config["NUM_NODES_APPROX"] < 3:
        raise ValueError("NUM_NODES_APPROX must be at least 3")
    if not isinstance(config["SIMULATION_STEPS"], int) or config["SIMULATION_STEPS"] <= 0:
        raise ValueError("SIMULATION_STEPS must be a positive integer")
    if config["ALPHA"] < 0:
        raise ValueError("ALPHA must be non-negative")
    # Ensure output directory exists
    output_dir = os.path.dirname(config["CSV_OUTPUT"])
    if output_dir and not os.path.exists(output_dir):
        os.makedirs(output_dir)

def generate_zpi_vacuum(num_nodes_approx):
    """
    Generate a Zero-Point Information (ZPI) vacuum as a directed Bethe fragment.

    Constructs a finite, acyclic, directed graph approximating a 3-regular Bethe
    lattice, serving as the pre-geometric substrate for geometrogenesis.

    Args:
        num_nodes_approx (int): Target number of nodes (actual may vary).

    Returns:
        tuple: (G, levels)
            - G (DiGraph): Acyclic directed graph (ZPI vacuum).
            - levels (list of lists): Nodes grouped by depth for event injection.

    Raises:
        ValueError: If num_nodes_approx is too small to form a valid graph.
    """
    if num_nodes_approx < 3:
        raise ValueError("num_nodes_approx must be at least 3 for a valid ZPI vacuum")
    
    G = DiGraph()
    root = 0
    G.add_vertex(root)
    levels = [[root]]
    node_id = 1
    
    while G.order() < num_nodes_approx:
        next_level = []
        for parent in levels[-1]:
            num_children = 2 if parent != root else 3
            for _ in range(num_children):
                if G.order() >= num_nodes_approx:
                    break
                child = node_id
                G.add_vertex(child)
                G.add_edge(parent, child)
                next_level.append(child)
                node_id += 1
        if not next_level:
            break
        levels.append(next_level)
    
    return G, levels

def inject_energic_event(G, levels):
    """
    Inject a primordial 3-cycle into the ZPI vacuum to initiate geometrogenesis.

    Forms a 3-cycle between the root, its child, and grandchild, breaking acyclicity.

    Args:
        G (DiGraph): Acyclic ZPI vacuum graph.
        levels (list of lists): Nodes grouped by depth.

    Returns:
        DiGraph: Graph with primordial 3-cycle added.

    Raises:
        ValueError: If graph is too small to form a 3-cycle.
    """
    if len(levels) < 3 or not levels[2]:
        from sage.graphs.graph_generators import CycleGraph
        return CycleGraph(3).to_directed()
    
    node_v, node_w, node_u = levels[0][0], levels[1][0], levels[2][0]
    G.add_edge(node_u, node_v)
    return G

def is_permissible(G, u, v):
    """
    Check if adding edge (u, v) forms a geometrically pure 3-cycle.

    A pure 3-cycle requires exactly one 2-path from v to u and no longer paths.

    Args:
        G (DiGraph): Current causal graph.
        u (int): Target node for new edge.
        v (int): Source node for new edge.

    Returns:
        bool: True if edge (u, v) forms a pure 3-cycle, False otherwise.
    """
    paths = list(G.all_simple_paths(v, u, max_length=3))
    return len(paths) == 1 and len(paths[0]) == 3

def run_single_simulation(config):
    """
    Simulate geometrogenesis from a ZPI vacuum using thermodynamic rewriting.

    Applies the rewrite rule for SIMULATION_STEPS steps, counting final 3-cycles ($N_3$).

    Args:
        config (dict): Configuration dictionary with NUM_NODES_APPROX, SIMULATION_STEPS, ALPHA.

    Returns:
        int: Final number of 3-cycles ($N_3$).

    Raises:
        ValueError: If graph size leads to invalid temperature computation.
    """
    G_acyclic, levels = generate_zpi_vacuum(config["NUM_NODES_APPROX"])
    G = inject_energic_event(G_acyclic, levels)
    N = G.order()
    
    # Avoid log(1) or negative values
    T = float(1.0 / log(N)) if N > 1 else 1.0
    
    for step in range(config["SIMULATION_STEPS"]):
        proposal_set = set()
        for v, w in G.edges(labels=False):
            for u in G.neighbors_out(w):
                if v != u and (u, v) not in G.edges(labels=False):
                    if is_permissible(G, u, v):
                        delta_F = config["ALPHA"] - T
                        P = min(1.0, float(exp(-delta_F / T)))
                        if random() < P:
                            proposal_set.add((u, v))
        if not proposal_set:
            break
        G.add_edges(proposal_set)
    
    # Compute N_3 = (1/3) * tr(A^3)
    A = G.adjacency_matrix()
    return Integer((A**3).trace() / 3)

def run_ensemble(config):
    """
    Run a statistical ensemble of geometrogenesis simulations.

    Executes NUM_RUNS simulations, collects final $N_3$ counts, and generates:
    - Histogram of $N_3$ distribution
    - Time-series of $N_3$ growth (single representative run)
    - CSV file with $N_3$ results and runtimes
    - JSON file with metadata (software versions, config, stats)

    Args:
        config (dict): Configuration dictionary.

    Returns:
        tuple: (final_n3_counts, stats)
            - final_n3_counts (list): Final $N_3$ counts for all runs.
            - stats (dict): Statistical metrics (Mean, StdDev, Median, Min, Max).

    Raises:
        ValueError: If configuration is invalid.
        IOError: If file writing fails.
    """
    validate_config(config)
    set_random_seed(config["SEED"])
    
    print("="*80)
    print(f"Running Statistical Ensemble of {config['NUM_RUNS']} Simulations")
    print("="*80)
    
    final_n3_counts = []
    run_times = []
    for i in tqdm(range(config['NUM_RUNS']), desc="Simulations", ncols=80):
        start_run = time.time()
        n3 = run_single_simulation(config)
        end_run = time.time()
        run_times.append(end_run - start_run)
        final_n3_counts.append(n3)
    print("Ensemble run complete.")
    
    # Save results to CSV
    try:
        with open(config["CSV_OUTPUT"], 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(["Run", "Final_N3", "Runtime_sec"])
            for i, (n3, rt) in enumerate(zip(final_n3_counts, run_times), 1):
                writer.writerow([i, n3, f"{rt:.3f}"])
    except IOError as e:
        print(f"Error writing CSV file: {e}")
        raise
    
    # Statistical analysis
    stats = {
        "Mean": np.mean(final_n3_counts),
        "StdDev": np.std(final_n3_counts),
        "Median": np.median(final_n3_counts),
        "Min": np.min(final_n3_counts),
        "Max": np.max(final_n3_counts)
    }
    
    # Save metadata to JSON
    try:
        metadata = {
            "metadata_version": "1.0",
            "timestamp": datetime.now().isoformat(),
            "software": {
                "sage_version": sage.version.version,
                "numpy_version": np.__version__,
                "tqdm_version": getattr(tqdm, '__version__', "unknown")
            },
            "config": config,
            "results": stats,
            "runtime_seconds": sum(run_times)
        }
        with open(config["JSON_OUTPUT"], 'w') as f:
            json.dump(metadata, f, indent=2)
    except IOError as e:
        print(f"Error writing JSON file: {e}")
        raise
    
    # Histogram plot
    heights, bins = np.histogram(final_n3_counts, bins='auto', density=True)
    max_y = np.max(heights)
    h = histogram(final_n3_counts, bins='auto', density=True,
                 title=f"Distribution of Final $N_3$ ({config['NUM_RUNS']} Runs)",
                 axes_labels=['Final 3-Cycle Count ($N_3$)', 'Probability Density'],
                 fontsize=12, grid=True)
    mean_line = line([(stats["Mean"], 0), (stats["Mean"], max_y)], 
                     color='red', linestyle='--', thickness=2, 
                     legend_label=f'Mean = {stats["Mean"]:.2f}')
    plot = h + mean_line
    plot.save(config['OUTPUT_FIGURE'], dpi=300, bbox_inches='tight')
    
    # Time-series plot (single run)
    G_acyclic, levels = generate_zpi_vacuum(config["NUM_NODES_APPROX"])
    G = inject_energic_event(G_acyclic, levels)
    N = G.order()
    T = float(1.0 / log(N)) if N > 1 else 1.0
    n3_history = []
    
    for step in range(config["SIMULATION_STEPS"]):
        A = G.adjacency_matrix()
        n3_history.append(Integer((A**3).trace() / 3))
        proposal_set = set()
        for v, w in G.edges(labels=False):
            for u in G.neighbors_out(w):
                if v != u and (u, v) not in G.edges(labels=False):
                    if is_permissible(G, u, v):
                        delta_F = config["ALPHA"] - T
                        P = min(1.0, float(exp(-delta_F / T)))
                        if random() < P:
                            proposal_set.add((u, v))
        if not proposal_set:
            break
        G.add_edges(proposal_set)
    
    steps = range(len(n3_history))
    line_plot = line(list(zip(steps, n3_history)), 
                     title="3-Cycle Growth (Representative Run)",
                     axes_labels=['Step', '$N_3$'],
                     fontsize=12, grid=True, frame=True)
    line_plot.save(config['TIME_SERIES_FIGURE'], dpi=300, bbox_inches='tight')
    
    return final_n3_counts, stats

if __name__ == "__main__":
    try:
        start_time = time.time()
        n3_counts, stats = run_ensemble(ENSEMBLE_CONFIG)
        end_time = time.time()
        
        print("\n" + "="*80)
        print("STATISTICAL ANALYSIS OF FINAL 3-CYCLE COUNT ($N_3$)")
        print(f"Total time for {ENSEMBLE_CONFIG['NUM_RUNS']} runs: {end_time - start_time:.2f} seconds")
        print("="*80)
        print(f"{'Metric':<20} {'Value':>10}")
        print("-"*80)
        for key, value in stats.items():
            print(f"{key:<20} {value:>10.2f}")
        print("-"*80)
        print(f"\nHistogram plot saved to '{ENSEMBLE_CONFIG['OUTPUT_FIGURE']}'")
        print(f"Time-series plot saved to '{ENSEMBLE_CONFIG['TIME_SERIES_FIGURE']}'")
        print(f"Ensemble results saved to '{ENSEMBLE_CONFIG['CSV_OUTPUT']}'")
        print(f"Metadata saved to '{ENSEMBLE_CONFIG['JSON_OUTPUT']}'")
        
    except Exception as e:
        print(f"Error during ensemble execution: {e}")
        raise