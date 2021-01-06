export SymmetryRepresentation
export SymmetryRepresentation1D

struct SymmetryRepresentation{S<:AbstractSymmetry, K<:Number}<:AbstractRepresentation
    symmetry::S
    matrices::Vector{Matrix{K}}

    function SymmetryRepresentation(
        symmetry::S,
        matrices::AbstractVector{<:AbstractMatrix{K}},
    ) where {S<:AbstractSymmetry, K<:Number}
        G = group(symmetry)
        rep = FiniteGroupRepresentation(G, matrices)
        return new{S, K}(symmetry, rep.matrices)
    end

    function SymmetryRepresentation(
        symmetry::S,
        matrices::AbstractVector{K},
    ) where {S<:AbstractSymmetry, K<:Number}
        G = group(symmetry)
        rep = FiniteGroupRepresentation(G, matrices) # check for representation
        return new{S, K}(symmetry, rep.matrices)
    end
end

group(rep::SymmetryRepresentation) = rep.group
symmetry(rep::SymmetryRepresentation) = rep.symmetry
#dimension(rep::SymmetryRepresentation) = dimension(rep.group_representation)
dimension(rep::SymmetryRepresentation) = size(first(rep.matrices), 1)

# ismonomial(rep::SymmetryRepresentation) = ismonomial(rep.group_representation)
function ismonomial(rep::SymmetryRepresentation)
    return all(abs(x) ≈ 0 || abs(x) ≈ 1 for m in rep.matrices for x in m)
end

function get_irrep_iterator(rep::SymmetryRepresentation, d::Integer)
    return ((x, m[d,d]) for (x, m) in zip(rep.symmetry, rep.matrices))
end

# function slice(rep::SymmetryRepresentation{S, K}, d::Integer) where {S, K}
#     elems = [
#         (x, m[d,d])
#             for (x, m) in zip(rep.symmetry, rep.matrices)
#                 if !isapprox(m[d,d], zero(K); atol=Base.rtoldefault(K))
#     ]
# end


# struct SymmetryRepresentation1D{K<:Number, S<:AbstractSymmetry}<:AbstractRepresentation
#     symmetry::S
#     coefficients::Vector{K}
#     function SymmetryRepresentation1D(
#         symmetry::S,
#         coefficients::AbstractVector{K},
#     ) where {K<:Union{<:AbstractFloat, <:Complex{<:AbstractFloat}}, S<:AbstractSymmetry}
#         G = group(symmetry)
#         ishomomorphic(coefficients, G; equal=isapprox) || throw(ArgumentError("rep is not homomorphic to the group"))
#         return new{K, S}(symmetry, coefficients)
#     end
#     function SymmetryRepresentation1D(
#         symmetry::S,
#         coefficients::AbstractVector{K},
#     ) where {K<:Union{<:Integer, <:Complex{<:Integer}, <:Rational, <:Complex{<:Rational}}, S<:AbstractSymmetry}
#         G = group(symmetry)
#         ishomomorphic(coefficients, G) || throw(ArgumentError("rep is not homomorphic to the group"))
#         return new{K, S}(symmetry, coefficients)
#     end
# end
