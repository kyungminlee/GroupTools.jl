export DirectProductOperation
export isidentity
import LinearAlgebra.×

"""
    DirectProductOperation{Ops}

Direct product of symmetry operations.
math```
  g = (g_1, g_2, \\ldots)
```
"""
struct DirectProductOperation{Ops<:Tuple{Vararg{AbstractSymmetryOperation}}}<:AbstractSymmetryOperation
    operations::Ops
    function DirectProductOperation(ops::Vararg{AbstractSymmetryOperation})
        T = typeof(ops)
        return new{T}(ops)
    end
    function DirectProductOperation(ops::T) where {T<:Tuple{Vararg{AbstractSymmetryOperation}}}
        return new{T}(ops)
    end
end

×(lhs::AbstractSymmetryOperation, rhs::AbstractSymmetryOperation) = DirectProductOperation(lhs, rhs)
×(lhs::DirectProductOperation, rhs::AbstractSymmetryOperation) = DirectProductOperation(lhs.operations..., rhs)
×(lhs::AbstractSymmetryOperation, rhs::DirectProductOperation) = DirectProductOperation(lhs, rhs.operations...)
×(lhs::DirectProductOperation, rhs::DirectProductOperation) = DirectProductOperation(lhs.operations..., rhs.operations...)

Base.hash(x::P, h::UInt) where {P<:DirectProductOperation} = Base.hash(P, Base.hash(x.operations, h))

Base.:(*)(lhs::P, rhs::P) where {P<:DirectProductOperation} = DirectProductOperation(lhs.operations .* rhs.operations)
Base.:(^)(obj::DirectProductOperation, n::Integer) = DirectProductOperation(obj.operations.^n)
Base.:(==)(lhs::P, rhs::P) where {P<:DirectProductOperation} = all(lhs.operations .== rhs.operations)

Base.inv(obj::DirectProductOperation) = DirectProductOperation(Base.inv.(obj.operations))

function Base.isapprox(lhs::P, rhs::P; atol::Real=0, rtol::Real=Base.rtoldefault(Float64)) where {P<:DirectProductOperation}
    return all(isapprox.(lhs.operations, rhs.operations; atol=atol, rtol=rtol))
end

isidentity(obj::DirectProductOperation) = all(isidentity, obj.operations)
