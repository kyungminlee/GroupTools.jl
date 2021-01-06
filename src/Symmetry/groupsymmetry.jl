export GroupElement
export symmetryelements

struct GroupElement{P<:Function}
    value::Int
    product::P
    function GroupElement(value::Integer, product::P) where {P<:Function}
        return new{P}(value, product)
    end
end

function symmetryelements(group::FiniteGroup)
    p = group_product(group)
    return [GroupElement(x, p) for x in 1:grouo_order(group)]
end

Base.:(*)(lhs::E, rhs::E) where {E<:GroupElement} = lhs.product(lhs.value, rhs.value)
Base.:(==)(lhs::E, rhs::E) where {E<:GroupElement} = lhs.value == rhs.value

"""
    finitegroupsymmetry

Group multiplication table as a symmetry.
"""
function finitegroupsymmetry(multiplicationtable::AbstractMatrix{<:Integer})
    return finitegroupsymmetry(FiniteGroup(multiplicationtable))
end

function finitegroupsymmetry(group::FiniteGroup)
    elems = symmetryelements(group)
    return new{typeof(first(elems))}(elems, group)
end

