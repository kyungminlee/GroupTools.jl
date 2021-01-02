export DirectProductSymmetry
export elements

import LinearAlgebra

struct DirectProductSymmetry{E<:DirectProductOperation, S<:Tuple{Vararg{AbstractSymmetry}}}<:AbstractSymmetry
    symmetries::S
    function DirectProductSymmetry(sym::AbstractSymmetry...)
        E = DirectProductOperation{Tuple{eltype.(sym)...}}
        S = typeof(sym)
        return new{E, S}(sym)
    end
end

LinearAlgebra.cross(sym::AbstractSymmetry...) = DirectProductSymmetry(sym...)

Base.eltype(::Type{DirectProductSymmetry{E, S}}) where {E, S} = E
Base.valtype(::Type{DirectProductSymmetry{E, S}}) where {E, S} = E
Base.valtype(::DirectProductSymmetry{E, S}) where {E, S} = E

function Base.IteratorSize(::Type{<:DirectProductSymmetry{E, <:NTuple{N, <:Any}}}) where {E, N}
    return Base.HasShape{N}()
end

Base.length(x::DirectProductSymmetry) = prod(length.(x.symmetries))
Base.size(x::DirectProductSymmetry) = length.(x.symmetries)
Base.keys(x::DirectProductSymmetry) = CartesianIndices(size(x))
Base.firstindex(::DirectProductSymmetry) = 1
Base.lastindex(x::DirectProductSymmetry) = length(x)

function Base.getindex(x::DirectProductSymmetry{E, <:Tuple{Vararg{Any, N}}}, s::CartesianIndex{N}) where {E, N}
    return DirectProductOperation([Base.getindex(sym, j) for (sym, j) in zip(x.symmetries, s.I)]...)
end
function Base.getindex(x::DirectProductSymmetry, i::Integer)
    s = CartesianIndices(length.(x.symmetries))[i]
    return x[s]
end
Base.getindex(x::DirectProductSymmetry, i::AbstractVector) = [x[j] for j in i]
function Base.getindex(x::DirectProductSymmetry{E, <:Tuple{Vararg{Any, N}}}, s::Vararg{<:Integer, N}) where {E, N}
    return DirectProductOperation([Base.getindex(sym, j) for (sym, j) in zip(x.symmetries, s)]...)
end

function Base.iterate(x::DirectProductSymmetry, i::Integer=1)
    return (0 < i <= length(x)) ? (x[i], i+1) : nothing
end

function elements(x::DirectProductSymmetry)
    return [DirectProductOperation(y...) for y in Iterators.product(x.symmetries...)]
end

function Base.:(==)(lhs::S, rhs::S) where {S<:DirectProductSymmetry}
    return lhs.symmetries == rhs.symmetries
end

function group(m::DirectProductSymmetry)
    tsub = (x -> group_multiplication_table(group(x))).(m.symmetries)
    nsub = size.(tsub, 1)
    n = prod(nsub)
    t = Matrix{Int}(undef, (n, n))
    range_sub = tuple([1:x for x in nsub]...)
    ind = LinearIndices(range_sub)

    D = length(nsub)
    for (i1, s1) in enumerate(CartesianIndices(range_sub))
        for (i2, s2) in enumerate(CartesianIndices(range_sub))
            s3 = CartesianIndex([ti[s1i, s2i] for (ti, s1i, s2i) in zip(tsub, s1.I, s2.I)]...)
            t[ind[s1], ind[s2]] = ind[s3]
        end
    end
    return FiniteGroup(t)
end
