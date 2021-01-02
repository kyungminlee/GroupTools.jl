using GroupTools

export AbstractRepresentation
export dimension

abstract type AbstractRepresentation end

"""
    FiniteGroupRepresentation{S}

Matrix representation of a finite group
"""
struct FiniteGroupRepresentation{S<:Number}<:AbstractRepresentation
    group::FiniteGroup
    matrices::Vector{Matrix{S}}

    @doc """
    FiniteGroupRepresentation(group, matrices; equal=isapprox)

    # Arguments
    - `group`: finite group
    - `matrices`: matrices representing the group
    - `equal`: equality for the matrix representation
    """
    function FiniteGroupRepresentation(
        group::FiniteGroup,
        matrices::AbstractVector{<:AbstractMatrix{K}};
        equal::Function=isapprox
    ) where {K<:Union{<:AbstractFloat, <:Complex{<:AbstractFloat}}}
        ishomomorphic(matrices, group; equal=equal) || throw(ArgumentError("irrep is not homomorphic to the group"))
        return new{K}(group, matrices)
    end
end

dimension(rep::FiniteGroupRepresentation) = size(first(rep.matrices), 1)

function get_irrep_iterator(rep::FiniteGroupRepresentation, d::Integer)
    return ((x, m[d,d]) for (x, m) in zip(rep.group, rep.matrices))
end
