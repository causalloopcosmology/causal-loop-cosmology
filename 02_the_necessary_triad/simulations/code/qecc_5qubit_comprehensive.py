# qecc_5qubit_comprehensive.py (v3.1)
# A robust, algebraic test of the 5-qubit perfect error-correcting code.
# This script applies every possible single-qubit Pauli error to each qubit,
# measures the resulting syndrome, and presents the results in a lookup table.
# Now includes CSV export of the final syndrome table.

from qiskit.circuit import QuantumCircuit
from qiskit.compiler import transpile
from qiskit_aer import Aer
from qiskit.quantum_info import Pauli
import pandas as pd
import os

# The simulator is now initialized once globally
simulator = Aer.get_backend('aer_simulator')

def get_algebraic_syndrome(error_pauli, stabilizers):
    """
    Calculates the syndrome by checking for anti-commutation between the error and stabilizers.
    """
    syndrome = ""
    for stabilizer in stabilizers:
        # The syndrome bit is 1 if they anti-commute, 0 if they commute.
        commutes = stabilizer.commutes(error_pauli)
        syndrome_bit = '0' if commutes else '1'
        syndrome += syndrome_bit
    return syndrome

def main():
    """
    Main function to run the comprehensive algebraic test and display results.
    """
    print("Running comprehensive algebraic test of the 5-qubit perfect code (v3.1)...")

    # Define the four stabilizers as Pauli objects
    stabilizers = [
        Pauli("XZZXI"),
        Pauli("IXZZX"),
        Pauli("XIXZZ"),
        Pauli("ZXIXZ")
    ]

    qubits = range(5)
    pauli_errors = ['X', 'Y', 'Z']
    results = []

    # Test the null case (no error)
    identity = Pauli('I' * 5)
    results.append({'Error_Type': 'I', 'Qubit_Index': '-', 'Syndrome': get_algebraic_syndrome(identity, stabilizers)})

    # Loop through all 15 possible single-qubit errors
    for q_idx in qubits:
        for pauli_char in pauli_errors:
            error_str = ['I'] * 5
            error_str[q_idx] = pauli_char
            error_pauli = Pauli("".join(error_str))
            
            syndrome = get_algebraic_syndrome(error_pauli, stabilizers)
            results.append({'Error_Type': pauli_char, 'Qubit_Index': q_idx, 'Syndrome': syndrome})

    df = pd.DataFrame(results)
    
    # --- Save Results to CSV ---
    output_dir = "outputs"
    os.makedirs(output_dir, exist_ok=True)
    csv_path = os.path.join(output_dir, "qecc_5qubit_syndrome_table.csv")
    df.to_csv(csv_path, index=False)
    
    print("\n--- Syndrome Lookup Table ---")
    print(df.to_string())

    syndromes = df['Syndrome'].tolist()
    unique_syndromes = set(syndromes)
    no_error_syndrome = syndromes[0]

    print("\n--- Verification ---")
    print(f"Syndrome table saved to: {csv_path}")
    print(f"Total non-trivial errors tested: {len(syndromes) - 1}")
    print(f"Unique syndromes generated: {len(unique_syndromes)}")
    print(f"Syndrome for no error: '{no_error_syndrome}' (should be 0000)")

    is_successful = (
        len(unique_syndromes) == len(syndromes) and
        no_error_syndrome == '0000' and
        '0000' not in syndromes[1:]
    )
    
    if is_successful:
        print("\nSUCCESS: Each single-qubit Pauli error produces a unique, non-zero syndrome.")
    else:
        print("\nFAILURE: The code did not perform as expected. Check for duplicate or zero syndromes.")

if __name__ == "__main__":
    main()