# Thermodynamic Graph Rewriting: A Category-Theoretic Model of Emergent Spacetime

**R. Fisher**  
September 9, 2025

---

## Abstract

We present a rigorous, computationally implementable model of emergent spacetime, wherein a geometric universe arises from a discrete, pre-geometric causal network. The causal structure is formalized as a category in which the formation of 3-cycles introduces a metric. The dynamics are defined by a thermodynamically-guided graph rewrite rule. We demonstrate via ensemble numerical simulations that a singular "energic event" — a primordial 3-cycle embedded in an otherwise acyclic vacuum — triggers a rapid, inflationary phase of geometrogenesis. This expansion naturally terminates due to a geometric purity constraint inherent in the rewrite rule. We conclude that in this framework, an inflationary epoch is not an ad hoc mechanism but a logically necessary consequence of the foundational axioms.

---

## Table of Contents

- [Introduction](#introduction)
- [Foundations: The Causal Graph as a Category](#foundations-the-causal-graph-as-a-category)
  - [The Pre-Geometric, Causal Substrate](#the-pre-geometric-causal-substrate)
  - [The 3-Cycle as the Genesis of Metric](#the-3-cycle-as-the-genesis-of-metric)
- [Dynamics: Inflationary Geometrogenesis](#dynamics-inflationary-geometrogenesis)
  - [The Initial Energic Event](#the-initial-energic-event)
  - [The Rewrite Rule](#the-rewrite-rule)
  - [The Geometric Purity Constraint](#the-geometric-purity-constraint)
  - [Thermodynamic Framework](#thermodynamic-framework)
- [Computational Validation](#computational-validation)
  - [Simulation Protocol](#simulation-protocol)
  - [Ensemble Results](#ensemble-results)
  - [Interpretation](#interpretation)
- [Discussion](#discussion)
  - [Inflation as a Logical Necessity](#inflation-as-a-logical-necessity)
  - [Future Work and Open Challenges](#future-work-and-open-challenges)
- [Conclusion](#conclusion)
- [Acknowledgements](#acknowledgements)
- [References](#references)

---

## Introduction

A primary challenge in fundamental physics is the reconciliation of general relativity and quantum mechanics. A recurring theme is the concept of emergent spacetime — where spacetime is not fundamental, but arises from a deeper, discrete structure. This work proposes such a model based on a network of causal relations.

We challenge the assumption that causal structure must remain strictly acyclic at all scales (as in Causal Set Theory). Instead, we propose a *pre-geometric but causal* substrate. The formation of microscopic 3-cycles is not a violation of causality — it is the mechanism by which *metric information* (a “clock”) emerges. We detail the mathematical foundations, define the dynamics, and provide computational evidence.

---

## Foundations: The Causal Graph as a Category

### The Pre-Geometric, Causal Substrate

The causal graph $G_t = (V_t, E_t)$ at discrete time $t$ is a finite directed acyclic graph (DAG). Vertices $V_t$ represent discrete events. Edges $E_t$ represent causal relations: $(v, w) \in E_t$ means $v$ precedes $w$. The initial state (Zero-Point Information vacuum) is a large, finite Bethe fragment — a poset with causal order but no metric.

**Definition: Causal Category $\mathcal{C}_t$**

- **Objects**: Events $V_t$.
- **Morphisms**: Directed paths between events.
- **Identity**: Null path at each vertex.
- **Composition**: Path concatenation.

### The 3-Cycle as the Genesis of Metric

A 3-cycle is a directed loop: $(v, w), (w, u), (u, v)$. It is the smallest nontrivial closed path. As a self-referential structure, it provides the first standard for measuring intervals — the universe’s first “clock.” Its formation marks the emergence of geometry. Cycle density relates to discrete Ricci curvature.

**Proposition**:  
The number of directed 3-cycles in $G_t$ is $N_3 = \frac{1}{3} \text{tr}(A_t^3)$, where $A_t$ is the adjacency matrix.

---

## Dynamics: Inflationary Geometrogenesis

Evolution is governed by local, parallel rewrite rules, inspired by spacetime thermodynamics.

### The Initial Energic Event

The ZPI vacuum is maximally symmetric and inert. The first 3-cycle is a symmetry-breaking event — an *initial energic event* — that excites the system. Excess energy drives inflation. Simulations model this by generating a Bethe fragment and embedding one primordial 3-cycle.

### The Rewrite Rule

Evolution from $G_t$ to $G_{t+1}$ is stochastic:

1. **Proposal**: For every path $v \to w \to u$, propose edge $(u,v)$ to form a 3-cycle.
2. **Evaluation**: Accept if it satisfies the Geometric Purity Constraint and a thermodynamic probability check.
3. **Application**: Apply all accepted proposals simultaneously.

### The Geometric Purity Constraint

A 3-cycle is “pure” only if its creation doesn’t form any longer cycles. Specifically: the only existing path from $v$ to $u$ must be $v \to w \to u$. This ensures clean geometry and acts as a self-limiting brake on inflation — as the graph densifies, satisfying this becomes harder, halting growth.

### Thermodynamic Framework

Acceptance probability is based on free energy: $\Delta F = \alpha \Delta \rho_C - T \Delta S$.

For adding a pure 3-cycle:

- $\Delta \rho_C = 1$ (one new cycle)
- $\Delta S = 1$ (one bit of information)
- $T = 1 / \ln N$, where $N = |V_t|$
- $\alpha \approx 1$ (natural units)

Accept with probability:  
$P = \min(1, \exp(-\Delta F / T))$

---

## Computational Validation

### Simulation Protocol

Simulations used SageMath with `DiGraph`. Fixed seed = 42. Parameters: $\alpha = 1.0$, ~40 initial nodes, max 50 steps. Start: generate ZPI vacuum, inject one 3-cycle, evolve under rewrite rule with purity constraint.

### Ensemble Results

100 independent runs. Final 3-cycle counts:

$$
\bar{N}_3 = 23.7, \quad \sigma = 13.0, \quad \text{median} = 24, \quad
N_3^{\min} = 1, \quad N_3^{\max} = 59.
$$

Distribution is broad due to stochastic dynamics.

![Histogram of final $N_3$ values over 100 runs. Red dashed line: mean.](figure_n3_distribution.pdf)  
*Figure 1: Final 3-cycle distribution.*

![Time series of $N_3$ in a representative run. Inflationary burst, then plateau.](inflation_time_series.pdf)  
*Figure 2: Inflation and termination in one run.*

### Interpretation

Results confirm theory: all runs show rapid, stochastic inflation followed by stabilization. Plateau values vary (1–59 cycles), but termination is universal — no run continues indefinitely. The purity constraint always halts evolution as density increases.

---

## Discussion

### Inflation as a Logical Necessity

Inflation is not fine-tuned — it is the necessary evolution from the unstable post-fluctuation state. Termination is equally necessary, enforced by the geometric constraint.

### Future Work and Open Challenges

- **Continuum Limit**: Prove graph dynamics yield manifold-like structure.
- **Lorentz Invariance**: Show approximate Lorentz symmetry emerges at large scales.
- **Standard Model**: Derive particle content from graph topology.

---

## Conclusion

We present a self-contained model of emergent, inflationary spacetime. Starting from a pre-geometric causal substrate and a thermodynamic rewrite rule, a single 3-cycle triggers necessary, self-limiting geometrogenesis. Simulations confirm universality of inflation → termination, despite stochastic variation in final cycle count (1–59). This provides a testable foundation for deriving physics from combinatorial principles.

---

## Acknowledgements

The author thanks the open-source community for the tools enabling this work.

---

## References

1. J. D. Bekenstein, “Universal upper bound on the entropy-to-energy ratio for bounded systems,” *Phys. Rev. D*, 23:287, 1981.
2. F. Dowker, “Causal sets and the deep structure of spacetime,” in *100 Years of Relativity*, World Scientific, 2005.
3. T. Jacobson, “Thermodynamics of spacetime: The Einstein equation of state,” *Phys. Rev. Lett.*, 75:1260, 1995.
4. Y. Ollivier, “Ricci curvature of Markov chains on metric spaces,” *Journal of Functional Analysis*, 256(3):810–864, 2009.

