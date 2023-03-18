#=
Viterbi decodes the Hidden State Sequence given the Observation sequence
using a Trellis-Tree

Input:
Y_sequence      : Observed Coding Sequence
θ_transition    : Transition Matrix of Hidden States
Y_emission      : Emission Matrix from Hidden State -> Observation State
Y_states        : Vector containing all possible Observation States (Y)
θ_states        : Vector containing all possible Hidden States (θ)
θ_0             : (Vector containing probabilities) Initial Condition of Hidden States
θ_reset         : Transition Matrix of Hidden States that resets back to Initial Condition
n               : Time step to trigger θ_reset & Y_delete

Output:
x               : Decoded MAP sequence given observation "Y_sequence"
T1              : Matrix describing Trellis Tree of Viterbi Decoder
T2              : Matrix describing Pointers for the Optimal Hidden State (based on MAP)
=#
function Viterbi(Y_sequence = Z_sequence, θ_transition = θ, Y_emission = transition_matrix,
    Y_states=alphabets, θ_states = alphabets, θ_0 = probabilities,
    θ_reset = reset_transition_matrix, n = 6)
    T1 = Matrix(undef, size(θ_states, 1), size(Y_sequence, 1)); # Collect Values (Trellis)
    T2 = Matrix(undef, size(θ_states, 1), size(Y_sequence, 1)); # Track Hidden States (Pointers)
    Y_indexes = Dict([(Y_state, idx) for (idx, Y_state) in enumerate(Y_states)])
    # println(Y_emission)

    # Initialization of Markov Chain
    for (θ_idx, θ_state) in enumerate(θ_states)
        Y_idx = Y_indexes[ Y_sequence[1] ];
        T1[θ_idx, 1] = θ_0[θ_idx] * Y_emission[θ_idx, Y_idx]
        T2[θ_idx, 1] = 0;
    end
    
    θ_trans = θ_transition;
    Y_emiss = Y_emission;
    # Collect the MAPs
    for t = 2:size(T1, 2)
        Y_idx = Y_indexes[ Y_sequence[t] ];

        # Trigger Condition (Reset Hidden States)
        if t == n+1; # Julia start indexing at 1
            θ_trans = θ_reset;
        else
            θ_trans = θ_transition;
        end

        # Find MAP given the present state θ_(t) by looking at θ_(t-1)
        for (θ_idx, θ_state) in enumerate(θ_states)
            # Construct π(θ) function for Maximization
            compare = [];
            for state in 1:size(T1, 1)
                value = T1[state, t-1] * θ_trans[state, θ_idx] * Y_emiss[θ_idx, Y_idx];
                push!(compare, value)
            end
            T1[θ_idx, t], T2[θ_idx, t] = findmax( compare );
        end
    end

    # Backtrack on finding the Hidden State Sequence
    # |- Traversing thru constructed Trellis Tree
    z = argmax(T1[:, size(Y_sequence, 1)]);
    x = Vector(undef, size(Y_sequence, 1)); # Best path
    x[end] = θ_states[z] ;
    for k = size(T1, 2):-1:2
    z = T2[z, k];
    x[k-1] = θ_states[z];
    end

    return x, T1, T2
end

