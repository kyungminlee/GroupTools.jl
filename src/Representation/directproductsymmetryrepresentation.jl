export DirectProductSymmetryRepresentation

struct DirectProductSymmetryRepresentation{S<:DirectProductSymmetry, K<:Number, R<:Tuple{Vararg{AbstractRepresentation}}}<:AbstractRepresentation
    representations::R

    function DirectProductSymmetryRepresentation(reps::AbstractRepresentation...)
        E = DirectProductOperation{Tuple{[eltype(symmetrytype(typeof(r))) for r in reps]...}}
        S = DirectProductSymmetry{E, Tuple{[symmetrytype(typeof(r)) for r in reps]...}}
        K = promote_type(scalartype.(reps)...)
        R = typeof(reps)
        return new{S, K, R}(reps)
    end
end

scalartype(::Type{DirectProductSymmetryRepresentation{S, K, R}}) where {S, K, R} = K
symmetrytype(::Type{DirectProductSymmetryRepresentation{S, K, R}}) where {S, K, R} = S

function symmetry(rep::DirectProductSymmetryRepresentation{S,K,R})::S where {S, K, R}
    return DirectProductSymmetry([symmetry(r) for r in rep.representations]...)
end

dimension(rep::DirectProductSymmetryRepresentation) = prod(dimension.(rep.representations))
ismonomial(rep::DirectProductSymmetryRepresentation) = all(ismonomial, rep.representations)





Base.eltype(::Type{DirectProductSymmetryRepresentation{S, K, R}}) where {S, K, R} = Matrix{K}
Base.valtype(::Type{DirectProductSymmetryRepresentation{S, K, R}}) where {S, K, R} = Matrix{K}
Base.valtype(::DirectProductSymmetryRepresentation{S, K, R}) where {S, K, R} = Matrix{K}

function Base.IteratorSize(::Type{<:DirectProductSymmetryRepresentation{S, K, <:NTuple{N, <:Any}}}) where {S, K, N}
    return Base.HasShape{N}()
end

Base.length(x::DirectProductSymmetryRepresentation) = prod(length.(x.representations))
Base.size(x::DirectProductSymmetryRepresentation) = length.(x.representations)
Base.keys(x::DirectProductSymmetryRepresentation) = CartesianIndices(size(x))
Base.firstindex(::DirectProductSymmetryRepresentation) = 1
Base.lastindex(x::DirectProductSymmetryRepresentation) = length(x)

function Base.getindex(x::DirectProductSymmetryRepresentation{S, K, <:Tuple{Vararg{Any, N}}}, s::CartesianIndex{N}) where {S, K, N}
    return kron([Base.getindex(rep, j) for (rep, j) in zip(x.representations, s.I)]...)
end
function Base.getindex(x::DirectProductSymmetryRepresentation, i::Integer)
    s = CartesianIndices(length.(x.representations))[i]
    return x[s]
end
Base.getindex(x::DirectProductSymmetryRepresentation, i::AbstractVector) = [x[j] for j in i]
function Base.getindex(x::DirectProductSymmetryRepresentation{S, K, <:Tuple{Vararg{Any, N}}}, s::Vararg{<:Integer, N}) where {S, K, N}
    return kron([Base.getindex(rep, j) for (rep, j) in zip(x.representations, s)]...)
end

function Base.iterate(x::DirectProductSymmetryRepresentation, i::Integer=1)
    return (0 < i <= length(x)) ? (x[i], i+1) : nothing
end


# export DirectProductSymmetryRepresentation

# struct DirectProductSymmetryRepresentation{S<:DirectProductSymmetry, K<:Number}<:AbstractRepresentation
#     symmetry::S
#     matrices::Array{Matrix{K}}
    
#     function DirectProductSymmetryRepresentation(reps::AbstractRepresentation...)
#         symmetries_flat = [r.symmetry for r in reps]
#         symmetry = DirectProductSymmetry(symmetries_flat...)
#         indices = CartesianIndices(symmetry)
#         matrices_flat = [r.group_representation.matrices for r in reps]
#         matrices = [
#             kron([matrices[i] for (matrices, i) in zip(matrices_flat, index.I)]...)
#                 for index in indices
#         ]
#         S = typeof(symmetry)
#         K = eltype(first(matrices))
#         @show S
#         @show K
#         return new{S, K}(symmetry, matrices)
#     end
# end

# export DirectProductSymmetryRepresentation

# struct DirectProductSymmetryRepresentation{S<:Tuple{Vararg{AbstractRepresentation}}, K<:Number}<:AbstractRepresentation
#     representations::S
    
#     function DirectProductSymmetryRepresentation(reps::AbstractRepresentation...)
#         S = typeof(reps)
#         K = promote_type(scalartype.(reps)...)
#         return new{S, K}(reps)
#     end
# end

# function blah()
#     symmetries_flat = [r.symmetry for r in reps]
#     symmetry = DirectProductSymmetry(symmetries_flat...)
#     indices = CartesianIndices(symmetry)
#     matrices_flat = [r.group_representation.matrices for r in reps]
#     matrices = [
#         kron([matrices[i] for (matrices, i) in zip(matrices_flat, index.I)]...)
#             for index in indices
#     ]
#     S = typeof(symmetry)
#     K = eltype(first(matrices))
#     @show S
#     @show K
#     return new{S, K}(symmetry, matrices)
# end