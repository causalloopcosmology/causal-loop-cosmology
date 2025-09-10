#!/usr/bin/env sage
# -----------------------------------------------------------------------------
# Causal Loop Cosmology - Model A Simulation (Corrected SageMath Version)
#
# Author:      [Author Name]
# Date:        September 10, 2025
#
# Description: This script implements the "Inflationary Geometrogenesis" model
#              (Model A). It leverages SageMath's optimized libraries for
#              performance and scalability.
# -----------------------------------------------------------------------------

from sage.all import DiGraph, log, exp, random, set_random_seed
import time
import csv

# --- CONFIGURATION ---
SIMULATION_CONFIG = {
    "NUM_NODES_APPROX": 40,
    "SIMULATION_STEPS": 50,
    "ALPHA": 1.0,
    "RANDOM_SEED": 42,
    "OUTPUT_FILENAME": "simulation_results_sage.csv"
}

def generate_zpi_vacuum(num_nodes_approx):
    """Generates the pristine ZPI vacuum state using Sage's DiGraph."""
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
    """Injects a single primordial 3-cycle into the ZPI vacuum."""
    if len(levels) > 2 and len(levels[2]) > 0:
        node_v, node_w, node_u = levels[0][0], levels[1][0], levels[2][0]
        G.add_edge(node_u, node_v)
        print(f"  - Injected energic event: created 3-cycle {node_v} -> {node_w} -> {node_u} -> {node_v}.")
    else:
        from sage.graphs.graph_generators import CycleGraph
        G = CycleGraph(3).to_directed()
    return G

def is_permissible(G, u, v):
    """Applies the Geometric Purity Constraint using Sage's efficient path-finding."""
    paths = list(G.all_simple_paths(v, u))
    return len(paths) == 1 and len(paths[0]) == 3

def run_simulation(config):
    """Executes the core simulation loop using Sage objects and functions."""
    set_random_seed(config["RANDOM_SEED"])
    
    G_acyclic, levels = generate_zpi_vacuum(config["NUM_NODES_APPROX"])
    G = inject_energic_event(G_acyclic, levels)
    
    N = G.order()
    # CORRECTED LINE: Convert Sage's symbolic expression to a standard float
    T = float(1.0 / log(N)) if N > 1 else 1.0

    A_initial = G.adjacency_matrix()
    n3_initial = (A_initial**3).trace() / 3

    print("\n" + "="*80)
    print("Starting Model A Simulation: Inflationary Geometrogenesis (SageMath)")
    print(f"Parameters: N={N}, Steps={config['SIMULATION_STEPS']}, α={config['ALPHA']:.2f}, T={T:.3f}")
    print(f"Initial State: {G.size()} edges, {n3_initial} 3-cycles (N₃)")
    print("="*80 + "\n")
    
    history = [{
        "step": -1,
        "n3_count": n3_initial,
        "edge_count": G.size(),
        "new_edges_added": 0
    }]

    for step in range(config["SIMULATION_STEPS"]):
        proposal_list = []
        for v, w in G.edges(labels=False):
            for u in G.successors(w):
                if v != u and not G.has_edge(u, v):
                    if is_permissible(G, u, v):
                        delta_F = config["ALPHA"] - T
                        P = min(1.0, exp(-delta_F / T))
                        if random() < P:
                            proposal_list.append((u, v))
        
        proposal_list = list(set(proposal_list))

        if not proposal_list:
            print(f"Step {step:02d}: System has reached a stable plateau. No valid moves found.")
            break
            
        G.add_edges(proposal_list)
        
        A_current = G.adjacency_matrix()
        n3_current = (A_current**3).trace() / 3
        
        print(f"Step {step:02d}: N₃ = {n3_current:<5} | Edges = {G.size():<5} | New Edges Added: {len(proposal_list)}")
        
        history.append({
            "step": step,
            "n3_count": n3_current,
            "edge_count": G.size(),
            "new_edges_added": len(proposal_list)
        })

    return history

def save_results_to_csv(history, filename):
    """Saves the simulation history to a CSV file."""
    if not history:
        return
    keys = history[0].keys()
    with open(filename, 'w', newline='') as output_file:
        dict_writer = csv.DictWriter(output_file, fieldnames=keys)
        dict_writer.writeheader()
        dict_writer.writerows(history)
    print(f"\nFull simulation data saved to '{filename}'")

if __name__ == "__main__":
    print("Causal Loop Cosmology — SageMath Simulation Script")
    print("=" * 60)
    
    start_time = time.time()
    simulation_history = run_simulation(SIMULATION_CONFIG)
    end_time = time.time()

    print("\n" + "="*80)
    print("SIMULATION COMPLETE")
    print(f"Total time: {end_time - start_time:.2f} seconds")
    
    final_state = simulation_history[-1]
    print(f"Final State: {final_state['n3_count']} 3-cycles, {final_state['edge_count']} edges.")
    print("="*80)
    
    save_results_to_csv(simulation_history, SIMULATION_CONFIG["OUTPUT_FILENAME"])