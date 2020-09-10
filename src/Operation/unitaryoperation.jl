import LinearAlgebra

struct UnitaryOperation{R<:Number} <: AbstractSymmetryOperation
    matrix::Matrix{R}
    function UnitaryOperation{R}(matrix::AbstractMatrix) where {R}
        if !isapprox(matrix * adjoint(matrix), LinearAlgebra.I)
            throw(ArgumentError("matrix not unitary"))
        end
        return new{R}(matrix)
    end
    function UnitaryOperation(matrix::AbstractMatrix{R}) where {R}
        if !isapprox(matrix * adjoint(matrix), LinearAlgebra.I)
            throw(ArgumentError("matrix not unitary"))
        end
        return new{R}(matrix)
    end
end

function Base.:(*)(lhs::U, rhs::U) where {U<:UnitaryOperation}
    return U(lhs.matrix * rhs.matrix)
end

function Base.:(^)(lhs::U, rhs::Integer) where {U<:UnitaryOperation}
    return U(lhs.matrix^rhs)
end

function Base.inv(arg::U) where {U<:UnitaryOperation}
    return U(adjoint(arg.matrix))
end

function isidentity(arg::UnitaryOperation)
    return arg.matrix == LinearAlgebra.I
end
