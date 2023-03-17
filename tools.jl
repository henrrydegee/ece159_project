# encoder   : Dictionary encoding alphabet -> codeword
# P         : Dictionary describing probability mass function (alphabet -> probability)
expected_length(encoder, P) = sum([P[alphabet] * length(codeword) for (alphabet, codeword) in encoder])

function mcmillan_inequality(encoder)
    value = sum([ (2//1) ^ (-1 * length(codeword)) for (___, codeword) in encoder]);
    return value
end

#=
Sort by ascending Probability Mass
Input:
P_Dict  : Dictionary mapping Source Symbol => Probability Mass 

Output:
probabilities   : Sorted Vector containing probability masses
alphabets       : Sorted Vector containing source symbols corresponding to probabilities
P_sorted_dict   : Sorted Dictionary mapping Source Symbol => Probability Mass
=#
function sort_prob(P_Dict)
    # Unroll Dictionary
    probabilities = [];
    alphabets = [];
    for (alphabet, probability) in P_Dict
        # println("$(typeof(alphabet))")
        push!(probabilities, probability)
        push!(alphabets, alphabet)
    end
    probabilities, alphabets, P_sorted_dict = sort_prob(probabilities, alphabets)

    return probabilities, alphabets, P_sorted_dict
end

#=
Sort by ascending Probability Mass
Input:
probabilities   : Vector containing probability masses
alphabets       : Vector containing source symbols corresponding to probabilities

Output:
probabilities   : Sorted Vector containing probability masses
alphabets       : Sorted Vector containing source symbols corresponding to probabilities
P_sorted_dict   : Sorted Dictionary mapping Source Symbol => Probability Mass
=#
function sort_prob(probabilities::Vector, alphabets::Vector)
    sorted_idx = sortperm(probabilities);
    probabilities = probabilities[sorted_idx];
    alphabets = alphabets[sorted_idx];

    # println("$alphabets")
    # println("$probabilities")

    P_sorted_dict = Dict();
    for (idx, probability) in enumerate(probabilities)
        # println("$(alphabets[idx])")
        P_sorted_dict[ string(alphabets[idx]) ] = probability
    end
    return probabilities, alphabets, P_sorted_dict
end
# sorted_probabilities, sorted_alphabets, P_sorted_dict = sort_prob(P)