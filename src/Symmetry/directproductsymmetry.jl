export DirectProductSymmetry
export elements

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
