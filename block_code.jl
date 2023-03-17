#=
values  : Vector containing all values to permute thru
k       : Number of Permutations to go
=#
function permutation_with_repetition(values, k::Int)
    x = vec(collect(Base.Iterators.product(Base.Iterators.repeated(values, k)...)))
    y = [];
    for tup in x # Vector of Tuples
        dummy = [];
        for (idx, value) in enumerate(tup)
            append!(dummy, value);
        end
        push!(y, dummy)
    end

    return y
end


#=
sorted_symbols      : Sorted Source Symbols according to its probabilities
sorted_probabilities: Sorted Probabilities corresponding to source symbols
block_length        : Length of Block on blocking symbols (Ex. aa -> 2)

Output:
blocks              : Vector containing all possible block codes using the defined source symbols
prob_blocks         : Corresponding Probabilities of the block codes
=#
function create_block_coding(sorted_symbols, sorted_probabilities, block_length=2)
    possibilites = collect(permutation_with_repetition(sorted_symbols, block_length))
    blocks = [prod(block_alphabets) for block_alphabets in possibilites]
    prob = collect(permutation_with_repetition(sorted_probabilities, block_length))
    
    prob_blocks = [prod(block_prob) for block_prob in prob]
    # println("possibilites: $possibilites")
    # println("prob: $prob")
    

    return blocks, prob_blocks
end
