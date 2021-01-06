export SymmetryRepresentation
export SymmetryRepresentation1D
export scalartype, symmetrytype
export get_irrep_iterator
export symmetry

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

scalartype(rep::SymmetryRepresentation{S, K}) where {S, K} = K
symmetrytype(rep::SymmetryRepresentation{S, K}) where {S, K} = S
scalartype(rep::Type{SymmetryRepresentation{S, K}}) where {S, K} = K
symmetrytype(rep::Type{SymmetryRepresentation{S, K}}) where {S, K} = S

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

function get_irrep_iterator(rep::SymmetryRepresentation)
    return zip(rep.symmetry, rep.matrices)
end

Base.IteratorSize(::Type{<:SymmetryRepresentation}) = Base.HasShape{1}()

Base.eltype(::Type{SymmetryRepresentation{S, K}}) where {S, K} = Matrix{K}
Base.valtype(::Type{SymmetryRepresentation{S, K}}) where {S, K} = Matrix{K}
Base.valtype(::SymmetryRepresentation{S, K}) where {S, K} = Matrix{K}

Base.length(x::SymmetryRepresentation) = length(x.matrices)
Base.size(x::SymmetryRepresentation) = (length(x.matrices),)
Base.keys(x::SymmetryRepresentation) = Base.OneTo(length(x))
Base.firstindex(::SymmetryRepresentation) = 1
Base.lastindex(x::SymmetryRepresentation) = length(x.matrices)

Base.getindex(x::SymmetryRepresentation, i) = Base.getindex(x.matrices, i)

Base.iterate(x::SymmetryRepresentation) = Base.iterate(x.matrices)
Base.iterate(x::SymmetryRepresentation, i) = Base.iterate(x.matrices, i)


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
