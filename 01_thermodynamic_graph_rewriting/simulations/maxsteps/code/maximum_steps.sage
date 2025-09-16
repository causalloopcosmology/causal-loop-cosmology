#!/usr/bin/env sage
# -----------------------------------------------------------------------------
# Title:       Thermodynamic Graph Rewriting: A Category-Theoretic Model of Emergent Spacetime
# Subject:     Step Limit Finding Experiment
# Author:      R. Fisher
# Affiliation: Independent Researcher
# Date:        September 12, 2025
# Version:     1.0
# DOI:         [To be assigned upon publication]
# License:     MIT
# Description: This script empirically determines the true maximum steps
#              required for simulations to naturally terminate for various
#              graph sizes by using an intentionally excessive step limit.
# Dependencies: SageMath 10.4+, NumPy, tqdm (for progress bar)
# Outputs:     
# Reproducibility Checklist:
# -----------------------------------------------------------------------------


from sage.all import DiGraph, log, exp, random, set_random_seed, Infinity
import time
import csv
import os
from datetime import datetime
import numpy as np

try:
    from tqdm import tqdm
except ImportError:
    print("Warning: Install tqdm with 'sage -pip install tqdm' for progress bar.")
    tqdm = lambda x, **k: x

# --- CONFIGURATION ---
EXPERIMENT_CONFIG = {
    "N_VALUES_TO_TEST": [80, 120, 160, 200, 240, 280, 320, 400, 480, 560, 640, 800, 960, 1120, 1280, 1600, 1920, 2240, 2560],
    "RUNS_PER_N": 200,
    "SIMULATION_STEPS_LIMIT": 5000,
    "ALPHA": 1.0,
    "SEED": 42,
    "OUTPUT_DIR": "./outputs",
    "SUMMARY_CSV": "step_limit_summary_granular.csv",
    "PER_RUN_PREFIX": "step_limit_per_run_N",
}

# --- CORE SIMULATION FUNCTIONS ---

def generate_zpi_vacuum(num_nodes_approx):
    if num_nodes_approx < 3:
        raise ValueError("num_nodes_approx must be at least 3")
    G = DiGraph()
    root = "0"
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
                child = str(node_id)
                G.add_vertex(child)
                G.add_edge(parent, child)
                next_level.append(child)
                node_id += 1
        if not next_level:
            break
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

def is_permissible_corrected(G, u, v, w):
    G.delete_edge(v, w)
    has_other_path = (G.distance(v, u) != Infinity)
    G.add_edge(v, w)
    return not has_other_path

def run_single_simulation(config):
    G_acyclic, levels = generate_zpi_vacuum(config["NUM_NODES_APPROX"])
    G = inject_energic_event(G_acyclic, levels)
    N = G.order()
    T = float(1.0 / log(N)) if N > 1 else 1.0

    for step in range(config["SIMULATION_STEPS_LIMIT"]):
        proposal_set = set()
        for v in G.vertices(sort=False):
            for w in G.neighbors_out(v):
                for u in G.neighbors_out(w):
                    if v == u or G.has_edge(u, v):
                        continue
                    if is_permissible_corrected(G, u, v, w):
                        delta_F = config["ALPHA"] - T
                        P = min(1.0, float(exp(-delta_F / T)))
                        if random() < P:
                            proposal_set.add((u, v))
        if not proposal_set:
            A = G.adjacency_matrix(sparse=True)
            n3_val = int(round(float((A**3).trace()) / 3.0))
            return n3_val, step + 1

        G.add_edges(proposal_set)

    A = G.adjacency_matrix(sparse=True)
    n3_val = int(round(float((A**3).trace()) / 3.0))
    return n3_val, config["SIMULATION_STEPS_LIMIT"]

# --- EXPERIMENT LOGIC ---

def run_experiment(config):
    set_random_seed(config["SEED"])
    output_dir = config["OUTPUT_DIR"]
    if not os.path.exists(output_dir):
        os.makedirs(output_dir, exist_ok=True)

    print("="*80)
    print("Running Granular Experiment to Determine Maximum Step Counts")
    print("="*80)

    summary_results = []

    for n_approx in config["N_VALUES_TO_TEST"]:
        print(f"\nTesting N ≈ {n_approx} ({config['RUNS_PER_N']} runs)...")

        mini_config = {
            "NUM_NODES_APPROX": n_approx,
            "SIMULATION_STEPS_LIMIT": config["SIMULATION_STEPS_LIMIT"],
            "ALPHA": config["ALPHA"]
        }

        steps_list = []
        n3_list = []
        per_run_data = []

        for run_idx in tqdm(range(1, config["RUNS_PER_N"] + 1), desc=f"N={n_approx}", ncols=90):
            n3, steps = run_single_simulation(mini_config)
            n3_list.append(n3)
            steps_list.append(steps)
            per_run_data.append({
                "Run": run_idx,
                "Final_N3": n3,
                "Steps_Taken": steps
            })

        max_steps_observed = int(np.max(steps_list))
        mean_steps = float(np.mean(steps_list))
        hit_limit_count = sum(1 for s in steps_list if s == config["SIMULATION_STEPS_LIMIT"])

        summary_results.append({
            "N_approx": n_approx,
            "max_steps_observed": max_steps_observed,
            "mean_steps": mean_steps,
            "hit_limit_count": hit_limit_count
        })

        per_run_filename = f"{config['PER_RUN_PREFIX']}{n_approx}.csv"
        per_run_path = os.path.join(output_dir, per_run_filename)
        with open(per_run_path, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=["Run", "Final_N3", "Steps_Taken"])
            writer.writeheader()
            writer.writerows(per_run_data)

    summary_path = os.path.join(output_dir, config["SUMMARY_CSV"])
    with open(summary_path, 'w', newline='') as f:
        fieldnames = ["N_approx", "max_steps_observed", "mean_steps", "hit_limit_count"]
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(summary_results)

    print("\n" + "="*80)
    print("Experiment complete.")
    print("="*80)
    return summary_results

# --- ENTRY POINT ---

if __name__ == "__main__":
    try:
        results = run_experiment(EXPERIMENT_CONFIG)
        print("\n--- Experiment Summary ---")
        print(f"{'Graph Size (N)':<20} {'Max Steps Observed':<25} {'Hit Limit Count':<15}")
        print("-" * 70)
        for r in results:
            print(f"{r['N_approx']:<20} {r['max_steps_observed']:<25} {r['hit_limit_count']:<15}")
    except Exception as e:
        import traceback
        print(f"\nFATAL ERROR during experiment.")
        traceback.print_exc()