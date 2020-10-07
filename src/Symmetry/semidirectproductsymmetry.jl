export SemidirectProductSymmetry
export elements

struct SemidirectProductSymmetry{E, S1<:AbstractSymmetry, S2<:AbstractSymmetry}<:AbstractSymmetry
    normal::S1
    rest::S2

    function SemidirectProductSymmetry(normal::S1, rest::S2) where {S1<:AbstractSymmetry, S2<:AbstractSymmetry}
        E1 = eltype(S1)
        E2 = eltype(S2)
        E = promote_type(E1, E2)
        # check normality
        for g in rest
            g_inv = inv(g)
            for h in normal
                if !(g * h * g_inv in normal)
                    throw(ArgumentError("Symmetry $normal not a normal subgroup"))
                end
            end
        end
        return new{E, S1, S2}(normal, rest)
    end
end

# == BEGIN Iterator stuff ==

Base.eltype(::Type{SemidirectProductSymmetry{E, S1, S2}}) where {E, S1, S2} = E
Base.valtype(::Type{SemidirectProductSymmetry{E, S1, S2}}) where {E, S1, S2} = E
Base.valtype(::SemidirectProductSymmetry{E, S1, S2}) where {E, S1, S2} = E

Base.IteratorSize(::SemidirectProductSymmetry) = Base.HasShape{2}()
Base.length(x::SemidirectProductSymmetry) = length(x.normal) * length(x.rest)
Base.size(x::SemidirectProductSymmetry) = (length(x.normal), length(x.rest))
Base.firstindex(::SemidirectProductSymmetry) = 1
Base.lastindex(x::SemidirectProductSymmetry) = length(x)

function Base.getindex(sym::SemidirectProductSymmetry, i::Integer)
    s = CartesianIndices((length(sym.normal), length(sym.rest)))[i]
    return sym.normal[s[1]] * sym.rest[s[2]]
end

function Base.getindex(sym::SemidirectProductSymmetry, i::AbstractVector{<:Integer})
    return [Base.getindex(sym, j) for j in i]
end

function Base.getindex(sym::SemidirectProductSymmetry, s1::Integer, s2::Integer)
    return sym.normal[s1] * sym.rest[s2]
end

function Base.iterate(sym::SemidirectProductSymmetry, i::Integer=1)
    return (0 < i <= length(sym)) ? (sym[i], i+1) : nothing
end

# == END Iterator stuff ==

function elements(arg::SemidirectProductSymmetry)
    return [x*y for x in arg.normal, y in arg.rest]
end

function group(m::SemidirectProductSymmetry)
    tn = group_multiplication_table(group(m.normal))
    tr = group_multiplication_table(group(m.rest))

    nn = size(tn, 1)
    nr = size(tr, 1)
    t = Matrix{Int}(undef, (nn*nr, nn*nr))
    ind = LinearIndices((1:n1, 1:n2))
    for (i1, s1) in enumerate(CartesianIndices((1:n1, 1:n2)))
        for (i2, s2) in enumerate(CartesianIndices((1:n1, 1:n2)))
            s3 = CartesianIndex(tn[s1[1], s2[1]], tr[s1[2], s2[2]])
            t[ind[s1], ind[s2]] = ind[s3]
        end
    end
    return FiniteGroup(t)
end
