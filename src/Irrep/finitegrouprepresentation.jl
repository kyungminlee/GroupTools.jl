using GroupTools

export AbstractRepresentation
export dimension

export FiniteGroupRepresentation
export get_irrep_iterator

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
    ) where {K<:Number}
        ishomomorphic(matrices, group; equal=equal) || throw(ArgumentError("irrep is not homomorphic to the group"))
        return new{K}(group, matrices)
    end

    function FiniteGroupRepresentation(
        group::FiniteGroup,
        reps::AbstractVector{K};
        equal::Function=isapprox
    ) where {K<:Number}
        matrices = [x * ones(K, (1,1)) for x in reps]
        return FiniteGroupRepresentation(group, matrices; equal=equal)
    end
end

dimension(rep::FiniteGroupRepresentation) = size(first(rep.matrices), 1)

"""
    get_irrep_iterator(rep, d)

Get an iterator for the finite group representation.
Returns an iterator of the form, e.g. `[(1, 1.0), (2, 0.5), ...]`.
The first element of the tuple is the element of the group (which is an integer),
which may seem redundant, but it is in accordance with the convention for the
`get_irrep_iterator` for symmetry representations, which should return the symmetry
operation.
"""
function get_irrep_iterator(rep::FiniteGroupRepresentation, d::Integer)
    return ((x, m[d,d]) for (x, m) in zip(rep.group, rep.matrices))
end
