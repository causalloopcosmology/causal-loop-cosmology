#!/usr/bin/env sage
# -------------------------------------------------------------------------
# Causal Loop Cosmology — Convergence Sweep (Paper 1)
#
# Title:       Thermodynamic Graph Rewriting: A Category-Theoretic Model of Emergent Spacetime
# Author:      R. Fisher
# Affiliation: Independent Researcher
# Date:        September 14, 2025
# Version:     1.1
# DOI:         [To be assigned upon publication]
# License:     MIT
# Description: We conduct a convergence sweep to determine the minimum number
#              of ensemble runs required for statistically stable results.
#              - Outputs histogram, time-series, CSV/JSON.
# Dependencies: SageMath 10.4, NumPy 1.26.4, tqdm 4.66.5
# Outputs:     - Histogram: './outputs/figure_n3_distribution.pdf'
#              - Time-series: './outputs/inflation_time_series.pdf'
#              - CSV: './outputs/ensemble_results.csv'
#              - JSON: './outputs/simulation_metadata.json'
# Reproducibility: Seed 42; ~2s for 1000 runs (N=100) on Ryzen 5/16GB.
# -------------------------------------------------------------------------

from sage.all import DiGraph, log, exp, random, set_random_seed
import time
import csv
import json
import os
from datetime import datetime
import numpy as np
import matplotlib.pyplot as plt
try:
    from tqdm import tqdm
except ImportError:
    print("Warning: Install tqdm with 'sage -pip install tqdm' for progress bar.")
    tqdm = lambda x, **k: x

# --- CONFIGURATION ---
CONVERGENCE_CONFIG = {
    "NUM_NODES_APPROX": int(80),
    "MAX_RUNS": int(10000),
    "CHECKPOINTS": [10, 50, 100, 200, 500, 1000, 2000, 5000, 7500, 10000],
    "SIMULATION_STEPS": int(100),
    "ALPHA": 1.0,
    "SEED": int(42),
    "OUTPUT_DIR": "./outputs",
    "CSV_OUTPUT": "convergence_sweep_n80.csv",
    "PLOT_OUTPUT": "convergence_plot_n80.pdf",
    "JSON_OUTPUT": "convergence_metadata_n80.json"
}

# --- STABLE HELPER & CORE SIMULATION FUNCTIONS ---
def convert_to_python_types(obj):
    if isinstance(obj, dict): return {k: convert_to_python_types(v) for k, v in obj.items()}
    if isinstance(obj, (list, tuple)): return type(obj)(convert_to_python_types(v) for v in obj)
    if obj is None or isinstance(obj, (bool, int, float, str)): return obj
    try:
        if hasattr(obj, "is_integer") and obj.is_integer(): return int(obj)
        return float(obj)
    except (TypeError, ValueError): return str(obj)

def generate_zpi_vacuum(num_nodes_approx):
    if num_nodes_approx < 3: raise ValueError("num_nodes_approx must be at least 3")
    G = DiGraph(); root = "0"; G.add_vertex(root); levels = [[root]]; node_id = 1
    while G.order() < num_nodes_approx:
        next_level = []
        for parent in levels[-1]:
            num_children = 2 if parent != root else 3
            for _ in range(num_children):
                if G.order() >= num_nodes_approx: break
                child = str(node_id); G.add_vertex(child); G.add_edge(parent, child)
                next_level.append(child); node_id += 1
        if not next_level: break
        levels.append(next_level)
    return G, levels

def inject_energic_event(G, levels):
    if len(levels) < 3 or not levels[2]:
        from sage.graphs.graph_generators import CycleGraph
        G_new = CycleGraph(3).to_directed()
        G_new.relabel(dict(zip(G_new.vertices(sort=True), map(str, range(3)))))
        return G_new
    node_v, node_w, node_u = str(levels[0][0]), str(levels[1][0]), str(levels[2][0])
    G.add_edge(node_u, node_v)
    return G

def is_permissible(G, u, v):
    if G.has_edge(v, u): return False
    return len(set(G.neighbors_out(v)).intersection(set(G.neighbors_in(u)))) == 1

def run_single_simulation(config):
    G_acyclic, levels = generate_zpi_vacuum(config["NUM_NODES_APPROX"])
    G = inject_energic_event(G_acyclic, levels)
    N = G.order(); T = float(1.0 / log(N)) if N > 1 else 1.0
    for step in range(config["SIMULATION_STEPS"]):
        proposal_set = set()
        for v, w in G.edges(labels=False):
            for u in G.neighbors_out(w):
                if v != u and not G.has_edge(u, v) and is_permissible(G, u, v):
                    if random() < min(1.0, float(exp(-(config["ALPHA"] - T) / T))):
                        proposal_set.add((u, v))
        if not proposal_set: break
        G.add_edges(proposal_set)
    A = G.adjacency_matrix(sparse=True)
    return int(round(float((A**3).trace()) / 3.0))

# --- CONVERGENCE SWEEP LOGIC ---
def run_convergence_sweep(config):
    set_random_seed(config["SEED"])
    output_dir = config["OUTPUT_DIR"]
    if not os.path.exists(output_dir):
        os.makedirs(output_dir, exist_ok=True)
        print(f"Created output directory: {output_dir}")

    print("="*80); print(f"Running Full Convergence Sweep for N ≈ {config['NUM_NODES_APPROX']}"); print("="*80)
    
    all_n3_results = [run_single_simulation(config) for _ in tqdm(range(config['MAX_RUNS']), desc="Simulations", ncols=90)]
    print("Simulations complete. Calculating and saving statistics...")
    
    convergence_data = []
    for checkpoint in config["CHECKPOINTS"]:
        if checkpoint > len(all_n3_results) or checkpoint == 0: continue
        current_data = np.array(all_n3_results[:checkpoint])
        stats = {"runs": checkpoint, "mean_n3": np.mean(current_data), "std_n3": np.std(current_data), "sem": np.std(current_data) / np.sqrt(checkpoint)}
        convergence_data.append(stats)

    if not convergence_data:
        print("Warning: No checkpoints reached."); return

    final_data_python = convert_to_python_types(convergence_data)
    
    csv_path = os.path.join(output_dir, config["CSV_OUTPUT"])
    with open(csv_path, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=final_data_python[0].keys())
        writer.writeheader(); writer.writerows(final_data_python)
        
    metadata = {"config": config, "final_mean": final_data_python[-1]['mean_n3']}
    json_path = os.path.join(output_dir, config["JSON_OUTPUT"])
    with open(json_path, 'w') as f:
        json.dump(convert_to_python_types(metadata), f, indent=2)

    # --- PLOTTING (Final Fix: Force all inputs to be standard Python types) ---
    runs = [int(d['runs']) for d in final_data_python]
    means = [float(d['mean_n3']) for d in final_data_python]
    sems = [float(d['sem']) for d in final_data_python]

    plt.figure(figsize=(float(10), float(6)))
    plt.errorbar(
        runs,
        means,
        yerr=sems,
        fmt=str('-o'),
        capsize=int(4),
        color=str('darkslateblue')
    )

    if int(config["MAX_RUNS"]) > 100:
        plt.xscale(str('log'))

    plt.title(f'Convergence of Mean $N_3$ for N≈{int(config["NUM_NODES_APPROX"])}')
    plt.xlabel(str('Number of Ensemble Runs (log scale)'))
    plt.ylabel(str('Mean 3-Cycle Count ($N_3$) with Std. Error'))
    plt.grid(True, which=str("both"), ls=str("--"), alpha=float(0.6))

    plot_path = os.path.join(output_dir, str(config["PLOT_OUTPUT"]))
    plt.savefig(plot_path, dpi=int(300), bbox_inches=str('tight'))
    plt.close()
    
    print("\n" + "="*80); print(f"Convergence sweep complete. Plot saved to '{plot_path}'"); print("="*80)

# --- ENTRY POINT ---
if __name__ == "__main__":
    try:
        run_convergence_sweep(CONVERGENCE_CONFIG)
    except Exception as e:
        import traceback
        print(f"\nFATAL ERROR during sweep."); traceback.print_exc()