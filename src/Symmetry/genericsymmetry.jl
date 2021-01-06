export GenericSymmetry
export finitegroupsymmetry

struct GenericSymmetry{ElementType}<:AbstractSymmetry
    elements::Vector{ElementType}
    group::FiniteGroup

    function GenericSymmetry{ElementType}(elements::AbstractVector, group::FiniteGroup) where {ElementType}
        #TODO: should I check for isomorphism between product and group_product?
        return new{ElementType}(elements, group)
    end

    function GenericSymmetry(elements::AbstractVector{E}; normalize::Function=Base.identity) where {E}
        group = FiniteGroup(generate_multiplication_table(elements; normalize=normalize))
        return new{E}(elements, group)
    end

    function GenericSymmetry{E}(elements::AbstractVector; normalize::Function=Base.identity) where {E}
        elements_vec::Vector{E} = elements
        group = FiniteGroup(generate_multiplication_table(elements_vec; normalize=normalize))
        return new{E}(elements, group)
    end
end

Base.IteratorSize(::Type{<:GenericSymmetry}) = Base.HasShape{1}()

Base.eltype(::Type{GenericSymmetry{E}}) where E = E
Base.valtype(::Type{GenericSymmetry{E}}) where E = E
Base.valtype(::GenericSymmetry{E}) where E = E

Base.length(x::GenericSymmetry) = length(x.elements)
Base.size(x::GenericSymmetry) = (length(x.elements),)
Base.keys(x::GenericSymmetry) = Base.OneTo(length(x))
Base.firstindex(::GenericSymmetry) = 1
Base.lastindex(x::GenericSymmetry) = length(x.elements)

Base.getindex(x::GenericSymmetry, i) = Base.getindex(x.elements, i)

Base.iterate(x::GenericSymmetry) = Base.iterate(x.elements)
Base.iterate(x::GenericSymmetry, i) = Base.iterate(x.elements, i)

function Base.:(==)(lhs::MS, rhs::MS) where {MS<:GenericSymmetry}
    return lhs.elements == rhs.elements && lhs.group == rhs.group
end

elements(m::GenericSymmetry) = m.elements
group(m::GenericSymmetry) = m.group
