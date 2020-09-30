export DirectProductSymmetry

struct DirectProductSymmetry{E<:AbstractSymmetryOperation, S<:Tuple{Vararg{AbstractSymmetry}}}<:AbstractSymmetry
    symmetries::S
    function DirectProductSymmetry(sym::AbstractSymmetry...)
        E = DirectProductOperation{Tuple{eltype.(sym)...}}
        S = typeof(sym)
        return new{E, S}(sym)
    end
end

Base.eltype(::Type{DirectProductSymmetry{E, S}}) where {E, S} = E
Base.valtype(::Type{DirectProductSymmetry{E, S}}) where {E, S} = E

Base.length(x::DirectProductSymmetry) = prod(length.(x.symmetries))
Base.size(x::DirectProductSymmetry) = length.(x.symmetries)
Base.keys(x::DirectProductSymmetry) = CartesianIndices(size(x))

function Base.getindex(x::DirectProductSymmetry, i::Integer)
    s = CartesianIndices(length.(x.symmetries))[i]
    return DirectProductOperation([Base.getindex(sym, j) for (sym, j) in zip(x.symmetries, s.I)]...)
end

function Base.getindex(x::DirectProductSymmetry, i::AbstractVector{<:Integer})
    return [Base.getindex(x, j) for j in i]
end

function Base.getindex(x::DirectProductSymmetry, s::Vararg{<:Integer})
    return DirectProductOperation([Base.getindex(sym, j) for (sym, j) in zip(x.symmetries, s)]...)
end

function Base.getindex(x::DirectProductSymmetry, s::CartesianIndex)
    return DirectProductOperation([Base.getindex(sym, j) for (sym, j) in zip(x.symmetries, s.I)]...)
end

function Base.iterate(x::DirectProductSymmetry, i::Integer=1)
    i > length(x) && return nothing
    return (x[i], i+1)
end

function elements(x::DirectProductSymmetry)
    return [DirectProductOperation(y...) for y in Iterators.product(x.symmetries...)]
end

function Base.IteratorSize(::Type{<:DirectProductSymmetry{E, <:NTuple{N, <:Any}}}) where {E, N}
    return Base.HasShape{N}()
end
