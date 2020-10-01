export MatrixSymmetry

export elements
export group

struct MatrixSymmetry{M<:MatrixOperation}<:AbstractSymmetry
    elements::Vector{M}
    group::FiniteGroup
    function MatrixSymmetry(matrices::AbstractVector{<:AbstractMatrix{S}}) where {S}
        D = size(matrices[1], 1)
        elements = MatrixOperation.(matrices)
        group = FiniteGroup(generate_multiplication_table(elements))
        return new{MatrixOperation{D, S}}(elements, group)
    end
    function MatrixSymmetry(elements::AbstractVector{M}) where {M<:MatrixOperation}
        group = FiniteGroup(generate_multiplication_table(elements))
        return new{M}(elements, group)
    end
end

Base.eltype(::Type{MatrixSymmetry{M}}) where M = M
Base.valtype(::Type{MatrixSymmetry{M}}) where M = M

Base.length(x::MatrixSymmetry) = length(x.elements)
Base.size(x::MatrixSymmetry) = (length(x.elements),)
Base.keys(x::MatrixSymmetry) = Base.OneTo(length(x))

Base.getindex(x::MatrixSymmetry, i) = Base.getindex(x.elements, i)

Base.iterate(x::MatrixSymmetry) = Base.iterate(x.elements)
Base.iterate(x::MatrixSymmetry, i) = Base.iterate(x.elements, i)

elements(m::MatrixSymmetry) = m.elements
group(m::MatrixSymmetry) = m.group
