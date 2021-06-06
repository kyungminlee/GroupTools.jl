export ProductOperation
export isidentity

"""
    ProductOperation{Ops}

product of symmetry operations.
math```
  g = g_1 * g_2 * \\ldots
```
"""
struct ProductOperation{Ops<:Tuple{Vararg{AbstractSymmetryOperation}}}<:AbstractSymmetryOperation
    operations::Ops
    function ProductOperation(ops::Vararg{AbstractSymmetryOperation})
        T = typeof(ops)
        return new{T}(ops)
    end
    function ProductOperation(ops::T) where {T<:Tuple{Vararg{AbstractSymmetryOperation}}}
        return new{T}(ops)
    end
end

Base.hash(x::P, h::UInt) where {P<:ProductOperation} = Base.hash(P, Base.hash(x.operations, h))

# These two functions need to be custom-implemented
# Base.:(*)(lhs::P, rhs::P) where {P<:ProductOperation} = ProductOperation(lhs.operations .* rhs.operations)
# Base.inv(obj::ProductOperation) = ProductOperation(Base.inv.(obj.operations))

Base.:(^)(obj::ProductOperation, n::Integer) = ProductOperation(obj.operations.^n)
Base.:(==)(lhs::P, rhs::P) where {P<:ProductOperation} = all(lhs.operations .== rhs.operations)

function Base.isapprox(lhs::P, rhs::P; atol::Real=0, rtol::Real=Base.rtoldefault(Float64)) where {P<:ProductOperation}
    return all(isapprox.(lhs.operations, rhs.operations; atol=atol, rtol=rtol))
end

Base.one(obj::ProductOperation) = ProductOperation(one.(obj.operations))
Base.isone(obj::ProductOperation) = all(isone, obj.operations)
isidentity(obj::ProductOperation) = all(isidentity, obj.operations)
