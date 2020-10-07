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

Base.eltype(::Type{SemidirectProductSymmetry{E, S1, S2}}) where {E, S1, S2} = E
Base.valtype(::Type{SemidirectProductSymmetry{E, S1, S2}}) where {E, S1, S2} = E

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

function elements(arg::SemidirectProductSymmetry)
    return [x*y for x in arg.normal, y in arg.rest]
end

group(m::SemidirectProductSymmetry) = m.group
