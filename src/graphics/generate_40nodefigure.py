import pandas as pd
import matplotlib.pyplot as plt

# --- CONFIGURATION ---
RESULTS_FILE = '40node_simulation_results.csv'
OUTPUT_FIGURE = '40node_inflationary_plateau.pdf'
PLOT_X_LIMIT = 10 # Show the plateau out to 10 steps
PLOT_Y_LIMIT = 15 # Extend the y-axis to 15 for visual space

# Load the canonical data from the last successful run
data = pd.read_csv(RESULTS_FILE)

# --- DATA PREPARATION FOR PLOTTING ---
# Find the last point where the simulation was active
last_active_step = data['step'].max()
final_n3_count = data.loc[data['step'] == last_active_step, 'n3_count'].iloc[0]

# Create a new DataFrame for the extended plateau up to the new x-limit
plateau_steps = range(last_active_step + 1, PLOT_X_LIMIT + 1)
plateau_data = pd.DataFrame({
    'step': plateau_steps,
    'n3_count': [final_n3_count] * len(plateau_steps)
})

# --- PLOTTING ---
plt.style.use('seaborn-v0_8-whitegrid')
fig, ax = plt.subplots(figsize=(10, 6))

# Plot the measured, active inflationary phase
ax.plot(data['step'], data['n3_count'], marker='o', linestyle='-', color='#0033A0', label='Inflationary Phase (Measured)')

# Plot the stable plateau as a dashed line
extended_line_data = pd.concat([data.iloc[[-1]], plateau_data])
ax.plot(extended_line_data['step'], extended_line_data['n3_count'], linestyle='--', color='#0033A0', alpha=0.7, label='Stable Plateau')

# --- FORMATTING AND AXIS LIMITS ---
ax.set_title('Inflationary Geometrogenesis and Subsequent Plateau', fontsize=16)
ax.set_xlabel('Simulation Time Step (t)', fontsize=12)
ax.set_ylabel('3-Cycle Count ($N_3$)', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, which='both', linestyle='--', linewidth=0.5)

# Set the custom axis limits for the desired framing
ax.set_xlim(-2, PLOT_X_LIMIT + 1)
ax.set_ylim(0, PLOT_Y_LIMIT)
ax.set_xticks(range(-1, PLOT_X_LIMIT + 2)) # Ensure clear integer ticks

# Save the figure
plt.tight_layout()
plt.savefig(OUTPUT_FIGURE)

print(f"Final, reframed plot saved to '{OUTPUT_FIGURE}'")