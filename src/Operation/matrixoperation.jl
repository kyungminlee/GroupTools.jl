export MatrixOperation

import LinearAlgebra
import MathExpr

struct MatrixOperation{D, R<:Number} <: AbstractSymmetryOperation
    matrix::Matrix{R}

    function MatrixOperation{D, R}(matrix::AbstractMatrix) where {D, R}
        size(matrix) != (D, D) && throw(ArgumentError("dimensions must be ($D,$D) != $(size(matrix))"))
        return new{D, R}(matrix)
    end

    function MatrixOperation{R}(matrix::AbstractMatrix) where {R}
        D, D2 = size(matrix)
        D != D2 && throw(ArgumentError("dimensions must be square, not ($D,$D2)"))
        return new{D, R}(matrix)
    end

    function MatrixOperation(matrix::AbstractMatrix{R}) where {R}
        D, D2 = size(matrix)
        D != D2 && throw(ArgumentError("dimensions must be square, not ($D,$D2)"))
        return new{D, R}(matrix)
    end

    function MatrixOperation(value::R) where {R}
        iszero(value) && throw(ArgumentError("value cannot be zero $(value)"))
        return new{1, R}(ones(R, (1,1))*value)
    end

    function MatrixOperation{R}(value::Number) where {R}
        iszero(value) && throw(ArgumentError("value cannot be zero $(value)"))
        return new{1, R}(ones(R, (1,1))*value)
    end

    function MatrixOperation{D, R}(value::R) where {D, R}
        iszero(value) && throw(ArgumentError("value cannot be zero $(value)"))
        return new{D, R}(Matrix(LinearAlgebra.I, (D, D))*value)
    end
end

Base.:(*)(lhs::U, rhs::U) where {U<:MatrixOperation} = U(lhs.matrix * rhs.matrix)
Base.:(*)(lhs::U, rhs::Number) where {U<:MatrixOperation} = U(lhs.matrix * rhs)
Base.:(*)(lhs::Number, rhs::U) where {U<:MatrixOperation} = U(lhs * rhs.matrix)
function Base.:(^)(lhs::U, rhs::Integer) where {U<:MatrixOperation}
    if rhs >= 0
        return U(lhs.matrix^rhs)
    else
        minv = MathExpr.inverse(lhs.matrix)
        return U(minv^(-rhs))
    end
end


Base.:(==)(lhs::U, rhs::U) where {U<:MatrixOperation} = lhs.matrix == rhs.matrix

Base.inv(arg::U) where {U<:MatrixOperation} = U(MathExpr.inverse(arg.matrix))
Base.conj(arg::U) where {U<:MatrixOperation} = U(conj(arg.matrix))
Base.transpose(arg::U) where {U<:MatrixOperation} = U(transpose(arg.matrix))
Base.adjoint(arg::U) where {U<:MatrixOperation} = U(adjoint(arg.matrix))

isidentity(arg::MatrixOperation) = arg.matrix == LinearAlgebra.I

function Base.isapprox(
    lhs::MatrixOperation{D, R},
    rhs::MatrixOperation{D, R};
    atol::Real=0,
    rtol::Real=Base.rtoldefault(real(R))
) where {D, R}
    return isapprox(lhs.matrix, rhs.matrix; atol=atol, rtol=rtol)
end
