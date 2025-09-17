#!/usr/bin/env sage
# causal_loop_symmetry_analysis.sage
# v2.2 - Multi-N scaling (N=46,94,190,382), 1000 trials, 20 steps, ANOVA for growth

from sage.all import Graph, floor
import time
import csv
import os
import random
import numpy as np
from scipy import stats
from math import log2, exp

try:
    from tqdm import tqdm
except ImportError:
    print("Warning: tqdm not found. For a progress bar, run: sage -pip install tqdm")
    tqdm = lambda x, **kwargs: x

def generate_bethe_fragment(depth=5):
    """
    Generates a finite Bethe fragment of degree 3.
    """
    G = Graph(multiedges=False, loops=False)
    if depth < 1:
        raise ValueError("Depth must be at least 1")

    node_id = 0
    root = node_id
    node_id += 1
    G.add_vertex(root)
    levels = [[root]]

    for d in range(depth):
        next_level = []
        for parent in levels[-1]:
            num_children = 3 if parent == root else 2
            for _ in range(num_children):
                child = node_id
                node_id += 1
                G.add_vertex(child)
                G.add_edge(parent, child)
                next_level.append(child)
        if next_level:
            levels.append(next_level)

    total_nodes = G.order()
    if total_nodes == 0:
        return G, 0, 0, 0

    regular_count = sum(1 for v in G.vertices() if G.degree(v) == 3)
    regularity_fraction = regular_count / total_nodes
    boundary_nodes = len(levels[-1])
    analytical_fraction = (total_nodes - boundary_nodes) / total_nodes

    return G, total_nodes, regularity_fraction, analytical_fraction

def _apply_simplified_rewrite(G, vertices_to_update):
    """Helper function for the simplified rewrite rule (max_degree=3, uniform selection)."""
    edges_to_add = []
    for v in vertices_to_update:
        if G.degree(v) < 3:
            potential_neighbors = [u for u in G.vertices() if u != v and not G.has_edge(v, u)]
            if potential_neighbors:
                new_neighbor = random.choice(potential_neighbors)
                edges_to_add.append((v, new_neighbor))
    G.add_edges(edges_to_add)

def simulate_scheduler_variance(G0, scheduler_type='parallel', num_steps=20, num_trials=1000, seed=43):
    """
    Simulates degree variance under different schedulers across N.
    """
    random.seed(int(seed))
    np.random.seed(int(seed))
    
    all_trial_variances = []
    for _ in range(num_trials):
        G = G0.copy()
        trial_variances = []
        for _ in range(num_steps):
            vertices = list(G.vertices())
            
            if scheduler_type == 'parallel':
                _apply_simplified_rewrite(G, vertices)
            elif scheduler_type == 'serial':
                random.shuffle(vertices)
                for v in vertices:
                    _apply_simplified_rewrite(G, [v])
            elif scheduler_type == 'partial':
                random.shuffle(vertices)
                block_size = floor(len(vertices) / 2)
                block1 = vertices[:block_size]
                block2 = vertices[block_size:]
                _apply_simplified_rewrite(G, block1)
                _apply_simplified_rewrite(G, block2)

            degrees = G.degree_sequence()
            var = np.var(degrees)
            trial_variances.append(var)
        all_trial_variances.append(trial_variances)
        
    return all_trial_variances

def main():
    print("Causal Loop Cosmology — Computational Symmetry Analysis (v2.2 - Multi-N Scaling)")
    print("=" * 70)
    
    CONFIG = {
        "DEPTHS_TO_TEST": [4, 5, 6, 7],
        "NUM_TRIALS": 1000,
        "NUM_STEPS": 20,
        "SEED": 43,
        "OUTPUT_DIR": "outputs",
        "SYMMETRY_CSV": "symmetry_results_v2.2.csv",
        "SCHEDULER_CSV": "scheduler_variances_v2.2.csv"
    }
    
    os.makedirs(CONFIG["OUTPUT_DIR"], exist_ok=True)
    
    # --- Part 1: Bethe Fragment Analysis ---
    print("Analyzing Bethe fragments (depths 4-7)...")
    symmetry_results = []
    for depth in CONFIG["DEPTHS_TO_TEST"]:
        start_time = time.time()
        G, n_nodes, reg_frac, an_frac = generate_bethe_fragment(depth)
        runtime = time.time() - start_time
        
        symmetry_results.append({
            'Graph_Type': f'Bethe Fragment (d={depth})',
            'Is_Acyclic': G.is_forest(),
            'Nodes': n_nodes,
            'Edges': G.size(),
            'Frac_3_Regular': float(reg_frac),
            'Frac_3_Regular_Analytical': float(an_frac),
            'Runtime_s': runtime
        })

    # --- Export symmetry results ---
    symmetry_csv_path = os.path.join(CONFIG["OUTPUT_DIR"], CONFIG["SYMMETRY_CSV"])
    with open(symmetry_csv_path, 'w', newline='') as f:
        fieldnames = symmetry_results[0].keys()
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(symmetry_results)
    print(f"Symmetry data saved to '{symmetry_csv_path}'")

    # --- Part 2: Scheduler Variance Analysis ---
    print("\nRunning scheduler variance simulations (N=46,94,190,382)...")
    scheduler_results = []
    
    for depth in CONFIG["DEPTHS_TO_TEST"]:
        G0, n_nodes, _, _ = generate_bethe_fragment(depth)
        print(f"\n--- Processing Depth={depth} (N={n_nodes}) ---")
        
        for sched in tqdm(['parallel', 'serial', 'partial'], desc=f"Schedulers (N={n_nodes})"):
            all_vars = simulate_scheduler_variance(G0, scheduler_type=sched, 
                                                  num_steps=CONFIG["NUM_STEPS"], 
                                                  num_trials=CONFIG["NUM_TRIALS"], 
                                                  seed=CONFIG["SEED"])
            mean_vars_per_step = [np.mean(step_vars) for step_vars in zip(*all_vars)]
            std_errs = [np.std(step_vars) / np.sqrt(CONFIG["NUM_TRIALS"]) for step_vars in zip(*all_vars)]
            ci_95 = [1.96 * se for se in std_errs]
            
            for step, mean_var, ci in zip(range(CONFIG["NUM_STEPS"]), mean_vars_per_step, ci_95):
                scheduler_results.append({
                    'Depth': depth,
                    'Nodes': n_nodes,
                    'Scheduler': sched,
                    'Step': step + 1,
                    'Mean_Variance': mean_var,
                    'CI_Lower': mean_var - ci,
                    'CI_Upper': mean_var + ci
                })

    # --- Export scheduler results ---
    scheduler_csv_path = os.path.join(CONFIG["OUTPUT_DIR"], CONFIG["SCHEDULER_CSV"])
    with open(scheduler_csv_path, 'w', newline='') as f:
        fieldnames = scheduler_results[0].keys()
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(scheduler_results)
    print(f"Scheduler data saved to '{scheduler_csv_path}'")

    # --- Statistical Analysis ---
    print("\nStatistical Analysis (Step 20)")
    final_step_data = [res for res in scheduler_results if res['Step'] == CONFIG["NUM_STEPS"]]
    for scheduler in ['parallel', 'serial', 'partial']:
        scheduler_data = [d for d in final_step_data if d['Scheduler'] == scheduler]
        nodes = [d['Nodes'] for d in scheduler_data]
        variances = [d['Mean_Variance'] for d in scheduler_data]
        print(f"\n{scheduler.capitalize()} Variances (Step 20):")
        for n, v in zip(nodes, variances):
            print(f"  N={n}: {v:.4f}")
        
        # Regression: Variance vs. log N
        log_nodes = [log2(n) for n in nodes]
        slope, intercept, r_value, p_value, _ = stats.linregress(log_nodes, variances)
        print(f"Regression ({scheduler}, Variance vs. log2 N): slope={slope:.3f}, R²={r_value**2:.3f}, p={p_value:.4e}")

    # ANOVA across schedulers at final step
    parallel_final = [d['Mean_Variance'] for d in final_step_data if d['Scheduler'] == 'parallel']
    serial_final = [d['Mean_Variance'] for d in final_step_data if d['Scheduler'] == 'serial']
    partial_final = [d['Mean_Variance'] for d in final_step_data if d['Scheduler'] == 'partial']
    if parallel_final and serial_final and partial_final:
        f_stat, p_value = stats.f_oneway(parallel_final, serial_final, partial_final)
        print(f"\nANOVA (Step 20, across schedulers): F={f_stat:.4f}, p={p_value:.4e} (significant if p<0.05)")

    # --- Print Summaries ---
    print("\n" + "="*80)
    print("BETHE FRAGMENT SYMMETRY AND REGULARITY ANALYSIS")
    print("="*80)
    print(f"{'Graph Type':<20} {'Nodes':<8} {'3-Reg Frac':<12} {'Analytical Frac':<18} {'Runtime (s)':<10}")
    print("-"*80)
    for row in symmetry_results:
        print(f"{row['Graph_Type']:<20} {row['Nodes']:<8} {row['Frac_3_Regular']:.2%}{'':<5} {row['Frac_3_Regular_Analytical']:.2%}{'':<9} {row['Runtime_s']:.2f}")
    print("-"*80)

    print("\nSCHEDULER VARIANCE SUMMARY (Final Mean Variance after 20 Steps)")
    print("="*50)
    for scheduler in ['parallel', 'serial', 'partial']:
        scheduler_data = [d for d in final_step_data if d['Scheduler'] == scheduler]
        for d in scheduler_data:
            print(f"  {scheduler.capitalize():<10} (N={d['Nodes']}): {d['Mean_Variance']:.4f} (CI: {d['CI_Lower']:.4f}–{d['CI_Upper']:.4f})")
    print("="*50)

if __name__ == "__main__":
    main()