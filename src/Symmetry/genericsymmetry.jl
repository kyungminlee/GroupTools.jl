export GenericSymmetry

struct GenericSymmetry{ElementType}<:AbstractSymmetry
    elements::Vector{ElementType}
    group::FiniteGroup
    product::Function

    function GenericSymmetry(elements::AbstractVector{E}; product::Function=Base.:(*), hash::Function=Base.hash) where {E}
        group = FiniteGroup(generate_multiplication_table(elements; product=product, hash=hash))
        return new{E}(elements, group, product)
    end

    function GenericSymmetry{E}(elements::AbstractVector; product::Function=Base.:(*)) where {E}
        elements_vec::Vector{E} = elements
        group = FiniteGroup(generate_multiplication_table(elements_vec; product=product, hash=hash))
        return new{E}(elements, group, product)
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