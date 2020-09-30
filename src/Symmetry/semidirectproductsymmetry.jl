export SemidirectProductSymmetry

struct SemidirectProductSymmetry{E, S1<:AbstractSymmetry, S2<:AbstractSymmetry}<:AbstractSymmetry
    function SemidirectProduct(normal::S1, rest::S2) where {S1<:AbstractSymmetry, S2<:AbstractSymmetry}
        E1 = eltype(S1)
        E2 = eltype(S2)
        E = promote_type(S1, S2)

        # check normality
        for g in group_generators(rest)
            g_inv = inv(g)
            for h in group_generators(normal)
                if g * h * inv_g ∉ normal
                    throw(ArgumentError("Symmetry $normal not a normal subgroup"))
                end
            end
        end
        return new{E, S1, S2}(normal, rest)
    end
end
