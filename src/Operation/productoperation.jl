export DirectProductOperation
export isidentity
import LinearAlgebra.×

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

Base.:(*)(lhs::P, rhs::P) where {P<:DirectProductOperation} = DirectProductOperation(lhs.operations .* rhs.operations)
Base.:(^)(obj::DirectProductOperation, n::Integer) = DirectProductOperation(obj.operations.^n)
Base.inv(obj::DirectProductOperation) = DirectProductOperation(Base.inv.(obj.operations))
Base.:(==)(lhs::P, rhs::P) where {P<:DirectProductOperation} = all(lhs.operations .== rhs.operations)

function Base.isapprox(lhs::P, rhs::P; atol::Real=0, rtol::Real=Base.rtoldefault(Float64)) where {P<:DirectProductOperation}
    return all(isapprox.(lhs.operations, rhs.operations; atol=atol, rtol=rtol))
end

isidentity(obj::DirectProductOperation) = all(isidentity, obj.operations)

function apply_operation(arg::DirectProductOperation, tgt)
    return foldr(apply_operation, args.operations; init=tgt)
end

function (arg::DirectProductOperation)(tgt)
    return foldr(apply_operation, args.operations; init=tgt)
end


# struct DirectProductOperation{E1<:AbstractSymmetryOperation, E2<:AbstractSymmetryOperation} <: AbstractSymmetryOperation
#     left::E1
#     right::E2

#     function DirectProductOperation(left::E1, right::E2) where {E1<:AbstractSymmetryOperation, E2<:AbstractSymmetryOperation}
#         return new{E1, E2}(left, right)
#     end
# end

# function ×(lhs::AbstractSymmetryOperation, rhs::AbstractSymmetryOperation)
#     return DirectProductOperation(lhs, rhs)
# end

# function Base.convert(::Type{E1}, obj::DirectProductOperation{E1, E2}) where {E1, E2}
#     !isidentity(obj.right) && throw(ArgumentError("cannot convert $obj to type $E1"))
#     return obj.left
# end

# function Base.convert(::Type{E2}, obj::DirectProductOperation{E1, E2}) where {E1, E2}
#     !isidentity(obj.left) && throw(ArgumentError("cannot convert $obj to type $E2"))
#     return obj.right
# end

# function isidentity(obj::DirectProductOperation)
#     return isidentity(obj.left) && isidentity(obj.right)
# end


# function Base.:(*)(lhs::P, rhs::P) where {P<:DirectProductOperation}
#     return DirectProductOperation(lhs.left * rhs.left, lhs.right * rhs.right)
# end

# function Base.:(^)(obj::DirectProductOperation, n::Integer)
#     return DirectProductOperation(obj.left^n, obj.right^n)
# end

# function Base.inv(obj::DirectProductOperation)
#     return DirectProductOperation(Base.inv(obj.left), Base.inv(obj.right))
# end

# function Base.:(==)(lhs::P, rhs::P) where {P<:DirectProductOperation}
#     return (lhs.left == rhs.left) && (lhs.right == rhs.right)
# end

# function apply_operation(arg::DirectProductOperation, tgt)
#     return apply_operation(arg.left, apply_operation(arg.right, tgt))
# end

# function (arg::DirectProductOperation)(tgt)
#     return apply_operation(arg.left, apply_operation(arg.right, tgt))
# end

# function Base.isapprox(lhs::P, rhs::P; atol::Real=0, rtol::Real=Base.rtoldefault(Float64)) where {P<:DirectProductOperation}
#     return isapprox(lhs.left, rhs.left; atol=atol, rtol=rtol) && isapprox(lhs.right, rhs.right; atol=atol, rtol=rtol)
# end
