export PermutationSymmetry

struct PermutationSymmetry<:AbstractSymmetry
    elements::Vector{Permutation}
    group::FiniteGroup
    function PermutationSymmetry(elements::AbstractVector{Permutation})
        group = FiniteGroup(generate_multiplication_table(elements))
        return new(elements, group)
    end
end

Base.IteratorSize(::Type{<:PermutationSymmetry}) = Base.HasShape{1}()

Base.eltype(::Type{PermutationSymmetry}) = Permutation
Base.valtype(::Type{PermutationSymmetry}) = Permutation
Base.valtype(::PermutationSymmetry) = Permutation

Base.length(x::PermutationSymmetry) = length(x.elements)
Base.size(x::PermutationSymmetry) = (length(x.elements),)
Base.keys(x::PermutationSymmetry) = Base.OneTo(length(x))
Base.firstindex(::PermutationSymmetry) = 1
Base.lastindex(x::PermutationSymmetry) = length(x.elements)

Base.getindex(x::PermutationSymmetry, i) = Base.getindex(x.elements, i)

Base.iterate(x::PermutationSymmetry) = Base.iterate(x.elements)
Base.iterate(x::PermutationSymmetry, i) = Base.iterate(x.elements, i)

function Base.:(==)(lhs::MS, rhs::MS) where {MS<:PermutationSymmetry}
    return lhs.elements == rhs.elements && lhs.group == rhs.group
end

elements(m::PermutationSymmetry) = m.elements
group(m::PermutationSymmetry) = m.group
