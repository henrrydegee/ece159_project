#=

Input:
block_symbols   : Vector containing all possible (partitioned) block symbols
                    Ex. [ ["a", "a"],  ["a", "b"], ["b", "a"], ["b", "b"]]
                        instead of ["aa", "ab", "ba", "bb"]
side_info_dict  : Dictionary mapping symbol => side information symbol
                    Ex. [a, b, c, γ, ϕ] => [e, e, e, g, g]
                        where e: English letters, g: Greek letters
Output:
side_informations   : Dictionary mapping block symbols => side information block symbol
                    Ex. "abγ" => "eeg"
=#
function create_side_information_codebook(block_symbols, side_info_dict)
    side_informations = Dict();

    for block_symbol in block_symbols
        side_info = "";
        for symbol in block_symbol
            side_info *= side_info_dict[string(symbol)]
        end
        side_informations[ prod(block_symbol) ] = side_info;
    end

    return side_informations
end

# Creates Dictionary of Lists with defined keys
dict_list(key_list::Vector) = Dict([(key, []) for key in key_list]);

#=
Input:
block_symbols               : Vector containing block symbols
probabilities               : Vector containing corresponding probabilities of block symbols
side_information_mapping    : Dictionary mapping block symbols => side information block symbols

Output:
side_2_block    : Dictionary mapping 
                    side information block symbols => Vector containing Block Symbols
side_2_prob     : Dictionary mapping
                     side information block symbols => Vector containing corresponding normalized probabilities
=#
function side_information_table(block_symbols, probabilities, side_information_mapping)
    unique_side_info2 = unique!([value for (key, value) in side_information_mapping])
    side_2_block = dict_list(unique_side_info2)
    side_2_prob = dict_list(unique_side_info2)
    for (idx, source_block) in enumerate(block_symbols)
        side_info = side_information_mapping[source_block]
        # println("Now collecting: $source_block -> $(probabilities[idx]) for $side_info")
        push!(side_2_block[side_info], string(source_block))
        push!(side_2_prob[side_info], probabilities[idx])
    end

    renormalization(probabilities::Vector) = probabilities ./ sum(probabilities); 

    # Renormalization based on given side information
    for (side_info, probabilities) in side_2_prob
        side_2_prob[side_info] = renormalization(probabilities)
    end

    return side_2_block, side_2_prob
end

#=
side_2_encoder : Dictionary mapping
                    Side information block symbols => Codeblock Encoder given Side Information
=#
function unroll_side_info_encoders(side_2_encoder)
    encoder_side_info = Dict();
    for (side_info, encoder) in side_2_encoder
        merge!(encoder_side_info, encoder)
    end

    return encoder_side_info
end