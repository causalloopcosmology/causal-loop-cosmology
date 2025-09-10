# -----------------------------------------------------------------------------
# Causal Loop Cosmology - Model A Simulation
#
# Author:      [R. Fisher]
# Date:        September 10, 2025
#
# Description: This script implements the "Inflationary Geometrogenesis" model
#              (Model A). It simulates the evolution of a causal network from
#              a perturbed ZPI vacuum, demonstrating a phase of rapid 3-cycle
#              nucleation followed by a stable plateau. The dynamics are
#              governed by a cycle-closing rule under a geometric purity
#              constraint.
#
# Dependencies: networkx, numpy
# -----------------------------------------------------------------------------

import networkx as nx
import numpy as np
import random
import math
import time
import csv
from typing import List, Tuple, Dict, Any

# --- CONFIGURATION ---
# Centralize all parameters for clarity and reproducibility.
SIMULATION_CONFIG = {
    "NUM_NODES_APPROX": 40,
    "SIMULATION_STEPS": 50,
    "ALPHA": 1.0,
    "RANDOM_SEED": 42,
    "OUTPUT_FILENAME": "40node_simulation_results.csv"
}

def generate_zpi_vacuum(num_nodes_approx: int) -> nx.DiGraph:
    """
    Generates the pristine ZPI vacuum state: a finite, acyclic, and
    highly symmetric Bethe fragment (directed tree).

    Args:
        num_nodes_approx: The approximate number of nodes for the graph.

    Returns:
        A NetworkX DiGraph representing the acyclic causal substrate.
    """
    G = nx.DiGraph()
    root = 0
    G.add_node(root)
    levels = [[root]]
    node_id = 1

    while len(G.nodes) < num_nodes_approx:
        next_level = []
        for parent in levels[-1]:
            num_children = 2 if parent != root else 3
            for _ in range(num_children):
                child = node_id
                G.add_node(child)
                G.add_edge(parent, child)
                next_level.append(child)
                node_id += 1
        if not next_level:
            break
        levels.append(next_level)
        
    return G, levels

def inject_energic_event(G: nx.DiGraph, levels: List[List[int]]) -> nx.DiGraph:
    """
    Injects a single primordial 3-cycle into the ZPI vacuum, serving as the
    initial energic event that breaks symmetry and initiates geometrogenesis.

    Args:
        G: The acyclic graph (ZPI vacuum).
        levels: The level structure of the tree graph.

    Returns:
        The graph with one embedded 3-cycle.
    """
    if len(levels) > 2 and len(levels[2]) > 0:
        node_v, node_w, node_u = levels[0][0], levels[1][0], levels[2][0]
        G.add_edge(node_u, node_v)
        print(f"  - Injected energic event: created 3-cycle {node_v} -> {node_w} -> {node_u} -> {node_v}.")
    else:
        # Fallback for graphs too small to perform the standard injection
        G = nx.cycle_graph(3, create_using=nx.DiGraph)
    return G

def is_permissible(G: nx.DiGraph, u: int, v: int) -> bool:
    """
    Applies the Geometric Quantum Formation constraint via path-finding.
    A move to add edge (u,v) is permissible iff the ONLY path that exists
    from v to u in the current graph is a single path of length 2. This
    ensures the creation of a "pure" 3-cycle with no longer cycles.

    Args:
        G: The current graph state.
        u: The source node of the proposed new edge.
        v: The target node of the proposed new edge.

    Returns:
        True if the move is permissible, False otherwise.
    """
    paths = list(nx.all_simple_paths(G, source=v, target=u))
    # A path [v, w, u] has length 2 (3 nodes).
    return len(paths) == 1 and len(paths[0]) == 3

def run_simulation(config: Dict[str, Any]) -> List[Dict[str, Any]]:
    """
    Executes the core simulation loop.

    Args:
        config: A dictionary containing all simulation parameters.

    Returns:
        A list of dictionaries, where each dictionary records the state
        of the system at each time step.
    """
    random.seed(config["RANDOM_SEED"])
    
    # 1. Generate Initial State
    G_acyclic, levels = generate_zpi_vacuum(config["NUM_NODES_APPROX"])
    G = inject_energic_event(G_acyclic, levels)
    
    N = G.number_of_nodes()
    T = 1.0 / math.log(N) if N > 1 else 1.0

    # 2. Log Initial State
    A_initial = nx.to_numpy_array(G)
    n3_initial = np.trace(np.linalg.matrix_power(A_initial, 3)) / 3.0
    
    print("\n" + "="*80)
    print("Starting Model A Simulation: Inflationary Geometrogenesis")
    print(f"Parameters: N={N}, Steps={config['SIMULATION_STEPS']}, α={config['ALPHA']:.2f}, T={T:.3f}")
    print(f"Initial State: {G.number_of_edges()} edges, {n3_initial:.0f} 3-cycles (N₃)")
    print("="*80 + "\n")
    
    history = [{
        "step": -1,
        "n3_count": n3_initial,
        "edge_count": G.number_of_edges(),
        "new_edges_added": 0
    }]

    # 3. Main Simulation Loop
    for step in range(config["SIMULATION_STEPS"]):
        proposal_list = []
        for v, w in G.edges():
            for u in G.successors(w):
                if v != u and not G.has_edge(u, v):
                    if is_permissible(G, u, v):
                        delta_F = config["ALPHA"] - T
                        P = min(1.0, math.exp(-delta_F / T))
                        if random.random() < P:
                            proposal_list.append((u, v))
        
        proposal_list = list(set(proposal_list))

        if not proposal_list:
            print(f"Step {step:02d}: System has reached a stable plateau. No valid moves found.")
            break
            
        G.add_edges_from(proposal_list)
        
        A_current = nx.to_numpy_array(G)
        n3_current = np.trace(np.linalg.matrix_power(A_current, 3)) / 3.0
        
        print(f"Step {step:02d}: N₃ = {n3_current:<5.0f} | Edges = {G.number_of_edges():<5} | New Edges Added: {len(proposal_list)}")
        
        history.append({
            "step": step,
            "n3_count": n3_current,
            "edge_count": G.number_of_edges(),
            "new_edges_added": len(proposal_list)
        })

    return history

def save_results_to_csv(history: List[Dict[str, Any]], filename: str):
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
    print("Causal Loop Cosmology — Publication-Grade Simulation Script")
    print("=" * 60)
    
    start_time = time.time()
    simulation_history = run_simulation(SIMULATION_CONFIG)
    end_time = time.time()

    print("\n" + "="*80)
    print("SIMULATION COMPLETE")
    print(f"Total time: {end_time - start_time:.2f} seconds")
    
    final_state = simulation_history[-1]
    print(f"Final State: {final_state['n3_count']:.0f} 3-cycles, {final_state['edge_count']} edges.")
    print("="*80)
    
    save_results_to_csv(simulation_history, SIMULATION_CONFIG["OUTPUT_FILENAME"])