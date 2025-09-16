#!/usr/bin/env sage
# -----------------------------------------------------------------------------
# Title:        Thermodynamic Graph Rewriting: A Category-Theoretic Model of Emergent Spacetime
# Subject:      Statistical Ensemble Analysis at N=640
# Author:       R. Fisher
# Affiliation:  Independent Researcher
# Date:         September 16, 2025
# Version:      1.0
# DOI:          [To be assigned upon publication]
# License:      MIT
# Description:  This script runs a large ensemble of simulations for a Causal
#               Loop Cosmology model at a fixed system size to
#               gather statistics on the final geometric state (N3 count).
# Dependencies: SageMath 10.4+, NumPy, tqdm
# Outputs:      - A CSV file containing the final N3 count for each run.
#               - A summary text file with key statistics.
#               - A PDF histogram visualizing the distribution of final N3 counts.
# Reproducibility: Seed 42; ~710s for 5000 runs on Ryzen 5/16GB.
# -----------------------------------------------------------------------------

from sage.all import DiGraph, log, exp, random, set_random_seed, Infinity, histogram, line
import time
import csv
import os
import numpy as np

try:
    from tqdm import tqdm
except ImportError:
    print("Warning: Install tqdm with 'sage -pip install tqdm' for progress bar.")
    tqdm = lambda x, **k: x

# --- CONFIGURATION ---
ENSEMBLE_CONFIG = {
    "NUM_RUNS": 5000,
    "NUM_NODES_APPROX": 640,
    "SIMULATION_STEPS": 2000,
    "ALPHA": 1.0,
    "SEED": 42,
    "VERSION_CHECK": "1.0",
    "OUTPUT_DIR": "./outputs",
    "CSV_OUTPUT": "ensemble_N640_data.csv",
    "STATS_OUTPUT": "ensemble_N640_summary.txt",
    "PLOT_OUTPUT": "ensemble_N640_histogram.pdf",
}

# --- CORE SIMULATION FUNCTIONS ---

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

def is_permissible(G, u, v, w):
    G.delete_edge(v, w)
    has_other_path = (G.distance(v, u) != Infinity)
    G.add_edge(v, w)
    return not has_other_path

def run_single_simulation(config):
    G_acyclic, levels = generate_zpi_vacuum(config["NUM_NODES_APPROX"])
    G = inject_energic_event(G_acyclic, levels)
    N = G.order()
    T = float(1.0 / log(N)) if N > 1 else 1.0

    for step in range(config["SIMULATION_STEPS"]):
        proposal_set = set()
        for v in G.vertices(sort=False):
            for w in G.neighbors_out(v):
                for u in G.neighbors_out(w):
                    if v == u or G.has_edge(u, v):
                        continue
                    if is_permissible(G, u, v, w):
                        delta_F = config["ALPHA"] - T
                        P = min(1.0, float(exp(-delta_F / T)))
                        if random() < P:
                            proposal_set.add((u, v))
        if not proposal_set:
            break
        G.add_edges(proposal_set)

    A = G.adjacency_matrix(sparse=True)
    trace_val = (A**3).trace()
    n3_val = int(round(float(trace_val) / 3.0))
    return n3_val

# --- MAIN ENSEMBLE RUNNER ---
def run_ensemble(config):
    set_random_seed(config["SEED"])
    output_dir = config["OUTPUT_DIR"]
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    print("="*80)
    print(f"Running Ensemble Analysis (v{config.get('VERSION_CHECK', 'unknown')})")
    print(f"Configuration: N≈{config['NUM_NODES_APPROX']}, Runs={config['NUM_RUNS']}, Max Steps={config['SIMULATION_STEPS']}")
    print("="*80)

    final_n3_counts = []
    for _ in tqdm(range(config['NUM_RUNS']), desc="Simulations", ncols=90):
        n3 = run_single_simulation(config)
        final_n3_counts.append(n3)

    print("\nEnsemble complete. Analyzing and saving results...")

    # --- SAVE RAW DATA ---
    csv_path = os.path.join(output_dir, config["CSV_OUTPUT"])
    with open(csv_path, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(["Run_ID", "Final_N3"])
        for i, count in enumerate(final_n3_counts):
            writer.writerow([i + 1, count])

    # --- CALCULATE STATISTICS ---
    n3_array = np.array(final_n3_counts, dtype=int)
    stats = {
        "Mean_N3": np.mean(n3_array),
        "Std_Dev_N3": np.std(n3_array),
        "SEM_N3": np.std(n3_array) / np.sqrt(len(n3_array)),
        "Median_N3": np.median(n3_array),
        "Min_N3": np.min(n3_array),
        "Max_N3": np.max(n3_array),
    }

    # --- SAVE SUMMARY STATS ---
    stats_path = os.path.join(output_dir, config["STATS_OUTPUT"])
    with open(stats_path, 'w') as f:
        f.write("="*50 + "\n")
        f.write(f"Ensemble Summary for N≈{config['NUM_NODES_APPROX']}\n")
        f.write("="*50 + "\n")
        for key, value in stats.items():
            f.write(f"{key:<15}: {value:.4f}\n")
        f.write("="*50 + "\n")

    # --- GENERATE AND SAVE PLOT ---
    # 1. Pre-calculate histogram data with NumPy to find the true max height
    hist_counts, _ = np.histogram(n3_array, bins='auto', density=True)
    mean_line_y_max = np.max(hist_counts) * 1.05 # Add 5% padding

    # 2. Create the plot using Sage's native functions
    hist_plot = histogram(
        n3_array,
        bins='auto',
        density=True,
        label='N3 Distribution',
        title=f"Distribution of Final N3 for N≈{config['NUM_NODES_APPROX']} ({config['NUM_RUNS']} Runs)",
        axes_labels=["Final 3-Cycle Count ($N_3$)", "Probability Density"],
        frame=True,
        gridlines=True
    )

    mean_line = line(
        [(stats["Mean_N3"], 0), (stats["Mean_N3"], mean_line_y_max)],
        color='red',
        linestyle='--',
        legend_label=f'Mean = {stats["Mean_N3"]:.2f}',
        thickness=2
    )

    final_plot = hist_plot + mean_line

    # 3. Save using your proven, reliable method
    plot_path = os.path.join(output_dir, config["PLOT_OUTPUT"])
    fig = final_plot.matplotlib()
    fig.savefig(plot_path, dpi=300, bbox_inches='tight')

    return stats, csv_path, stats_path, plot_path


if __name__ == "__main__":
    start_time = time.time()
    final_stats, csv_p, stats_p, plot_p = run_ensemble(ENSEMBLE_CONFIG)
    end_time = time.time()

    print("\n" + "="*80)
    print("STATISTICAL ANALYSIS COMPLETE")
    print(f"Total time for {ENSEMBLE_CONFIG['NUM_RUNS']} runs: {end_time - start_time:.2f} seconds")
    print("="*80)
    print(f"{'Metric':<20} {'Value':>15}")
    print("-"*80)
    for key, value in final_stats.items():
        print(f"{key:<20} {value:>15.4f}")
    print("-"*80)
    print(f"Raw data saved to:      {csv_p}")
    print(f"Summary stats saved to: {stats_p}")
    print(f"Histogram saved to:     {plot_p}")
    print("="*80)