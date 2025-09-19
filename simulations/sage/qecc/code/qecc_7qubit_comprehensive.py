# qecc_7qubit_comprehensive.py (v1.1)
# Corrected stabilizer syntax for the 7-qubit Steane code test.

from qiskit.quantum_info import Pauli
import pandas as pd
import os

def get_algebraic_syndrome(error_pauli, stabilizers):
    """
    Calculates the syndrome by checking for anti-commutation.
    """
    syndrome = ""
    for stabilizer in stabilizers:
        # Syndrome bit is '1' if they anti-commute, '0' if they commute.
        syndrome_bit = '0' if stabilizer.commutes(error_pauli) else '1'
        syndrome += syndrome_bit
    return syndrome

def main():
    """
    Runs the comprehensive test for the 7-qubit Steane code.
    """
    print("Running comprehensive algebraic test of the 7-qubit Steane code (v1.1)...")

    # The 7-qubit Steane code stabilizers.
    # The first 3 detect phase-flip (Z) errors; the last 3 detect bit-flip (X) errors.
    # Qiskit's Pauli strings are read from right-to-left (index 0 is the right-most char).
    # FIX: Removed invalid spaces from the Pauli strings.
    stabilizers = [
        Pauli("IIIXXXX"),
        Pauli("IXXIIXX"),
        Pauli("XIXIXIX"),
        Pauli("IIIZZZZ"),
        Pauli("IZZIIZZ"),
        Pauli("ZIZIZIZ")
    ]
    
    qubits = range(7)
    pauli_errors = ['X', 'Y', 'Z']
    results = []

    # Test the null case (no error)
    identity = Pauli('I' * 7)
    results.append({'Error_Type': 'I', 'Qubit_Index': '-', 'Syndrome (s6..s1)': get_algebraic_syndrome(identity, stabilizers)})

    # Loop through all 21 possible single-qubit errors
    for q_idx in qubits:
        for pauli_char in pauli_errors:
            error_str = ['I'] * 7
            error_str[q_idx] = pauli_char
            error_pauli = Pauli("".join(error_str))
            
            syndrome = get_algebraic_syndrome(error_pauli, stabilizers)
            results.append({'Error_Type': pauli_char, 'Qubit_Index': q_idx, 'Syndrome (s6..s1)': syndrome})

    df = pd.DataFrame(results)
    
    # --- Save Results to CSV ---
    output_dir = "outputs"
    os.makedirs(output_dir, exist_ok=True)
    csv_path = os.path.join(output_dir, "qecc_7qubit_syndrome_table.csv")
    df.to_csv(csv_path, index=False)
    
    print("\n--- Syndrome Lookup Table (7-Qubit Steane Code) ---")
    print(df.to_string())

    # --- Verification ---
    syndromes = df['Syndrome (s6..s1)'].tolist()
    unique_syndromes = set(syndromes)
    no_error_syndrome = syndromes[0]

    print("\n--- Verification ---")
    print(f"Syndrome table saved to: {csv_path}")
    print(f"Total non-trivial errors tested: {len(syndromes) - 1}")
    print(f"Unique syndromes generated: {len(unique_syndromes)}")
    print(f"Syndrome for no error: '{no_error_syndrome}' (should be 000000)")

    is_successful = (
        len(unique_syndromes) == len(syndromes) and
        no_error_syndrome == '000000' and
        '000000' not in syndromes[1:]
    )
    
    if is_successful:
        print("\nSUCCESS: Each single-qubit Pauli error produces a unique, non-zero syndrome.")
    else:
        print("\nFAILURE: The code did not perform as expected.")

if __name__ == "__main__":
    main()