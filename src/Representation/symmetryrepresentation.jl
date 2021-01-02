export SymmetryRepresentation
export SymmetryRepresentation1D

struct SymmetryRepresentation{S<:AbstractSymmetry, K<:Number}<:AbstractRepresentation
    symmetry::S
    group_representation::FiniteGroupRepresentation{K}

    function SymmetryRepresentation(
        symmetry::S,
        matrices::AbstractVector{<:AbstractMatrix{K}},
    ) where {
        S<:AbstractSymmetry,
        K<:Number
    }
        G = group(symmetry)
        rep = FiniteGroupRepresentation(G, matrices)
        return new{S, K}(symmetry, rep)
    end

    function SymmetryRepresentation(
        symmetry::S,
        matrices::AbstractVector{K},
    ) where {
        S<:AbstractSymmetry,
        K<:Number
    }
        G = group(symmetry)
        rep = FiniteGroupRepresentation(G, matrices)
        return new{S, K}(symmetry, rep)
    end
end


symmetry(rep::SymmetryRepresentation) = rep.symmetry
dimension(rep::SymmetryRepresentation) = dimension(rep.group_representation)
ismonomial(rep::SymmetryRepresentation) = ismonomial(rep.group_representation)

function get_irrep_iterator(rep::SymmetryRepresentation, d::Integer)
    return ((x, m[d,d]) for (x, m) in zip(rep.symmetry, rep.group_representation.matrices))
end

# function slice(rep::SymmetryRepresentation{K, S}, d::Integer) where {K, S}
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

# struct DirectProductSymmetryRepresentation{K<:Number, S<:DirectProductSymmetry}<:AbstractRepresentation
#     function DirectProductSymmetryRepresentation(
#         reps::AbstractRepresentation...
#     )
#         psym = DirectProductSymmetry([symmetry(r) for r in reps]...)

#         return new{K, S}(symmetry, matrices)
#     end
# end
