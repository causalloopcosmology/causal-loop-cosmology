#!/usr/bin/env sage
# -----------------------------------------------------------------------------
# Causal Loop Cosmology - Statistical Ensemble Analysis
#
# Author:      [R. Fisher]
# Date:        September 9, 2025
# -----------------------------------------------------------------------------

from sage.all import DiGraph, log, exp, random, set_random_seed, Integer, histogram, line, show
import time
import csv
import math
import numpy as np
import os

# --- CONFIGURATION ---
ENSEMBLE_CONFIG = {
    "NUM_RUNS": 100,  # Set for a full, statistically significant run.
    "NUM_NODES_APPROX": 40,
    "SIMULATION_STEPS": 50,
    "ALPHA": 1.0,
    "OUTPUT_FIGURE": "figure_n3_distribution.pdf",
    "TIME_SERIES_FIGURE": "inflation_time_series.pdf"  # Simplified to current dir
}

# --- CORE SIMULATION LOGIC ---

def generate_zpi_vacuum(num_nodes_approx):
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
    if len(levels) > 2 and len(levels[2]) > 0:
        node_v, node_w, node_u = levels[0][0], levels[1][0], levels[2][0]
        G.add_edge(node_u, node_v)
        print(f"  - Injected energic event: created 3-cycle {node_v} -> {node_w} -> {node_u} -> {node_v}.")
    else:
        from sage.graphs.graph_generators import CycleGraph
        G = CycleGraph(3).to_directed()
    return G

def is_permissible(G, u, v):
    paths = list(G.all_simple_paths([v], [u]))
    return len(paths) == 1 and len(paths[0]) == 3

def run_single_simulation(config):
    G_acyclic, levels = generate_zpi_vacuum(config["NUM_NODES_APPROX"])
    G = inject_energic_event(G_acyclic, levels)
    N = G.order()
    T = float(1.0 / log(N)) if N > 1 else 1.0
    for step in range(config["SIMULATION_STEPS"]):
        proposal_list = []
        for v, w in G.edges(labels=False):
            for u in G.neighbors_out(w):
                if v != u and not G.has_edge(u, v):
                    if is_permissible(G, u, v):
                        delta_F = config["ALPHA"] - T
                        P = min(1.0, math.exp(-delta_F / T))
                        if random() < P:
                            proposal_list.append((u, v))
        proposal_list = list(set(proposal_list))
        if not proposal_list:
            break
        G.add_edges(proposal_list)
    A_final = G.adjacency_matrix()
    return int((A_final**3).trace() / 3)

# --- ENSEMBLE EXECUTION AND ANALYSIS ---

def run_ensemble(config):
    print("="*80)
    print(f"Running Statistical Ensemble of {config['NUM_RUNS']} Simulations")
    print("="*80)
    final_n3_counts = []
    for i in range(config['NUM_RUNS']):
        print(f"\r  - Running simulation {i + 1}/{config['NUM_RUNS']}...", end="")
        final_n3 = run_single_simulation(config)
        final_n3_counts.append(final_n3)
    print("\nEnsemble run complete.")
    
    # Statistical analysis using NumPy
    avg_n3 = np.mean(final_n3_counts)
    std_dev_n3 = np.std(final_n3_counts)
    median_n3 = np.median(final_n3_counts)
    min_n3 = np.min(final_n3_counts)
    max_n3 = np.max(final_n3_counts)
    
    # Histogram of final N3 counts
    heights, bins = np.histogram(final_n3_counts, bins='auto', density=True)
    max_y = np.max(heights)
    h = histogram(final_n3_counts, bins='auto', density=True,
                  title=f"Distribution of Final $N_3$ ({config['NUM_RUNS']} Runs)",
                  axes_labels=['Final 3-Cycle Count ($N_3$)', 'Probability Density'])
    mean_line = line([(avg_n3, 0), (avg_n3, max_y)], color='red', linestyle='--', thickness=2, 
                     legend_label=f'Mean = {avg_n3:.2f}')
    plot = h + mean_line
    plot.save(config['OUTPUT_FIGURE'])
    
    # Time-series plot (simplified to single run for now)
    G_acyclic, levels = generate_zpi_vacuum(config["NUM_NODES_APPROX"])
    G = inject_energic_event(G_acyclic, levels)
    N = G.order()
    T = float(1.0 / log(N)) if N > 1 else 1.0
    n3_history = []
    for step in range(config["SIMULATION_STEPS"]):
        n3_history.append(int((G.adjacency_matrix()**3).trace() / 3))
        proposal_list = []
        for v, w in G.edges(labels=False):
            for u in G.neighbors_out(w):
                if v != u and not G.has_edge(u, v):
                    if is_permissible(G, u, v):
                        delta_F = config["ALPHA"] - T
                        P = min(1.0, math.exp(-delta_F / T))
                        if random() < P:
                            proposal_list.append((u, v))
        proposal_list = list(set(proposal_list))
        if not proposal_list:
            break
        G.add_edges(proposal_list)
    steps = range(len(n3_history))
    line_plot = line(zip(steps, n3_history), title="3-Cycle Growth (Single Run)", 
                     axes_labels=['Step', 'N₃'])
    line_plot.save(config['TIME_SERIES_FIGURE'])
    
    return final_n3_counts

if __name__ == "__main__":
    start_time = time.time()
    results = run_ensemble(ENSEMBLE_CONFIG)
    end_time = time.time()

    print("\n" + "="*80)
    print("STATISTICAL ANALYSIS OF FINAL 3-CYCLE COUNT (N₃)")
    print(f"Total time for {ENSEMBLE_CONFIG['NUM_RUNS']} runs: {end_time - start_time:.2f} seconds")
    print("="*80)
    print(f"  Mean               : {np.mean(results):.2f}")
    print(f"  Standard Deviation : {np.std(results):.2f}")
    print(f"  Median             : {np.median(results):.0f}")
    print(f"  Minimum            : {np.min(results)}")
    print(f"  Maximum            : {np.max(results)}")
    print("="*80)
    print(f"\nHistogram plot saved to '{ENSEMBLE_CONFIG['OUTPUT_FIGURE']}'")
    print(f"Time-series plot saved to '{ENSEMBLE_CONFIG['TIME_SERIES_FIGURE']}'")