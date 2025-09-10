import networkx as nx
import numpy as np
import matplotlib.pyplot as plt

G = nx.DiGraph([(1, 2), (1, 3), (1, 4), (2, 5), (2, 6), (3, 7), (3, 8), (4, 9), (4, 10), (5, 1), (6, 2), (7, 3), (8, 4), (9, 5)])
print("Initial graph edges:", list(G.edges()))

def rewrite_rule(G):
    G_new = G.copy()
    for u, w in G.edges():
        for w, v in G.edges():
            if (u, v) not in G.edges() and (v, u) not in G.edges():
                G_new.add_edge(u, v)
    return G_new

traces = []
for _ in range(100):
    A = nx.adjacency_matrix(G).todense()
    trace = np.trace(A @ A @ A) / 3
    traces.append(trace)
    G = rewrite_rule(G)

plt.plot(range(100), traces, label="3-cycle count")
plt.xlabel("Iteration")
plt.ylabel("tr(A^3)/3")
plt.title("3-Cycle Growth")
plt.legend()
plt.savefig("assets/3cycle_plot.png")
print(f"Final 3-cycle count: {traces[-1]}")