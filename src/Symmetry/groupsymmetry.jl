export GroupElement
export symmetryelements

struct GroupElement{P<:Function, I<:Function}
    value::Int
    product::P
    inverse::I
    function GroupElement(value::Integer, product::P, inverse::I) where {P<:Function, I<:Function}
        return new{P, I}(value, product, inverse)
    end

    function GroupElement{P, I}(value::Integer, product::P, inverse::I) where {P<:Function, I<:Function}
        return new{P, I}(value, product, inverse)
    end
end

function symmetryelements(group::FiniteGroup)
    p = group_product(group)
    i = group_inverse(group)
    return [GroupElement(x, p, i) for x in 1:group_order(group)]
end

function Base.:(*)(lhs::GroupElement{P, I}, rhs::GroupElement{P, I}) where {P, I}
    @boundscheck begin
        if lhs.product !== rhs.product || lhs.inverse !== rhs.inverse
            throw(ArgumentError("lhs and rhs do not have same product or inverse"))
        end
    end
    return GroupElement(lhs.product(lhs.value, rhs.value), lhs.product, lhs.inverse)
end
Base.:(==)(lhs::GroupElement{P, I}, rhs::GroupElement{P, I}) where {P, I} = lhs.value == rhs.value && lhs.product === rhs.product && lhs.inverse === rhs.inverse
Base.inv(lhs::GroupElement{P, I}) where {P, I} = GroupElement{P, I}(lhs.inverse(lhs.value), lhs.product, lhs.inverse)

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

