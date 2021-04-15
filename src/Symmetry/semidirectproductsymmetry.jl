export SemidirectProductSymmetry
export elements
export ⋊

struct SemidirectProductSymmetry{E<:AbstractSymmetryOperation, S1<:AbstractSymmetry, S2<:AbstractSymmetry}<:AbstractSymmetry{E}
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

function ⋊(normal::S1, rest::S2) where {S1<:AbstractSymmetry, S2<:AbstractSymmetry}
    return SemidirectProductSymmetry(normal, rest)
end

function ⋉(rest::S2, normal::S1) where {S1<:AbstractSymmetry, S2<:AbstractSymmetry}
    return SemidirectProductSymmetry(normal, rest)
end

# == BEGIN Iterator stuff ==
Base.eltype(::Type{SemidirectProductSymmetry{E, S1, S2}}) where {E, S1, S2} = E
Base.valtype(::Type{SemidirectProductSymmetry{E, S1, S2}}) where {E, S1, S2} = E
Base.valtype(::SemidirectProductSymmetry{E, S1, S2}) where {E, S1, S2} = E

# iterate over elements
Base.IteratorSize(::SemidirectProductSymmetry) = Base.HasShape{2}()
Base.length(x::SemidirectProductSymmetry) = length(x.normal) * length(x.rest)
Base.size(x::SemidirectProductSymmetry) = (length(x.normal), length(x.rest))
Base.firstindex(::SemidirectProductSymmetry) = 1
Base.lastindex(x::SemidirectProductSymmetry) = length(x)

Base.getindex(sym::SemidirectProductSymmetry, s::CartesianIndex{2}) = sym.normal[s[1]] * sym.rest[s[2]]
Base.getindex(sym::SemidirectProductSymmetry, s1::Integer, s2::Integer) = sym.normal[s1] * sym.rest[s2]
Base.getindex(sym::SemidirectProductSymmetry, i::Integer) = sym[CartesianIndices((length(sym.normal), length(sym.rest)))[i]]
Base.getindex(sym::SemidirectProductSymmetry, i::AbstractVector) = [sym[j] for j in i]
Base.iterate(sym::SemidirectProductSymmetry, i::Integer=1) = (0 < i <= length(sym)) ? (sym[i], i+1) : nothing
# == END Iterator stuff ==

function Base.:(==)(lhs::S, rhs::S) where {S<:SemidirectProductSymmetry}
    return lhs.normal == rhs.normal && lhs.rest == rhs.rest
end

function elements(arg::SemidirectProductSymmetry)
    return [x*y for x in arg.normal, y in arg.rest]
end

function group(m::SemidirectProductSymmetry)
    tn = group_multiplication_table(group(m.normal))
    tr = group_multiplication_table(group(m.rest))

    nn = length(m.normal)
    nr = length(m.rest)
    t = Matrix{Int}(undef, (nn*nr, nn*nr))
    ind = LinearIndices((1:nn, 1:nr))
    for (i1, s1) in enumerate(CartesianIndices((1:nn, 1:nr)))
        for (i2, s2) in enumerate(CartesianIndices((1:nn, 1:nr)))
            s3 = CartesianIndex(tn[s1[1], s2[1]], tr[s1[2], s2[2]])
            t[ind[s1], ind[s2]] = ind[s3]
        end
    end
    return FiniteGroup(t)
end
