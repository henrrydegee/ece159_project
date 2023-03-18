#=
huffman_node is a Binary Tree to represent the Huffman Compression

Data:
symbol      : Source Symbol Representation
probability : Probability of Source Symbol
left        : Left Child of the Binary Tree
right       : Right Child of the Binary Tree
=#
mutable struct huffman_node{A, B}
    symbol::A
    probability::B
    left::Union{Nothing, huffman_node}
    right::Union{Nothing, huffman_node}
end

# Note: Using Multiple Dispatch
# For Huffman Leaf Construction:
huffman_node(x::A, y::B) where A where B = huffman_node{A, B}(x, y, nothing, nothing)

#=
construct_huffman_tree() constructs the Huffman Tree given the
probability mass function (pmf) of the source Symbol

Input:
P_sorted_dict   : Dictionary mapping <source symbol> => <pmf>

Output:
Huffman Tree (::huffman_node) starting from the parent/root
=#
function construct_huffman_tree(P_sorted_dict)
    trees = [huffman_node( symbol, probability) for (symbol, probability) in P_sorted_dict];
    while length(trees) > 1
        sort!(trees, lt = (x, y) -> x.probability < y.probability);
        smallest = popfirst!(trees);
        next_smallest = popfirst!(trees);
        tree = huffman_node("", smallest.probability + next_smallest.probability);
        tree.left = smallest;
        tree.right = next_smallest;
        push!(trees, tree );
    end
    return trees[1]
end

#=
build_encoder() recursively traverse thru the binary tree to
create a dictionary that maps the source symbol to a codeword ∈ [0, 1]

Example usage:
encoder = Dict();
build_encoder(huffman_tree, "", encoder)
println(encoder)

Input:
node    : Root of the binary tree
code    : Use "" such that it can recursively build the encoder
encoder : Dictionary to map source symbol => codeword

# Note: Using hash after the tree is built will yield better performance
        if pmf does not change
=#
function build_encoder(node, code, encoder)
    code *= "0";
    if ~(isnothing(node.left))
        build_encoder(node.left, code, encoder);
    end
    code = code[1:end-1];

    code *= "1";
    if ~(isnothing(node.right))
        build_encoder(node.right, code, encoder);
    end
    code = code[1:end-1];
    encoder[node.symbol] = code;

    delete!(encoder, "");
end

#=
decode_huffman decodes the codeword string given
the huffman_tree used for encoding

Input:
huffman_tree    : Huffman Tree that encoded the source symbol
codeword        : String containing Binary digits to be decoded

Output:
Decoded Message based on huffman_tree
=#
function decode_huffman(huffman_tree, codeword)
    ans = ""
    curr = huffman_tree

    is_leaf(node) = isnothing(node.left) && isnothing(node.right)
    for idx in eachindex(codeword) # Parsing each bin/char of codeword string
        if string(codeword[idx]) == "0" && ~( is_leaf(curr) )
            println("Going left")
            curr = curr.left;
        elseif string(codeword[idx]) == "1" && ~( is_leaf(curr) )
            println("Going Right")
            curr = curr.right;
        end

        if is_leaf(curr)
            println("Successfuly Decoded: $(curr.symbol)")
            ans *= curr.symbol;
            curr = huffman_tree;
        end
    end

    return ans * "\0"
end

