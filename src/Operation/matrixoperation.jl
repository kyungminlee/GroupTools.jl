export MatrixOperation

import LinearAlgebra
import LinearAlgebraX
import MathExpr

"""
    MatrixOperation{D, R<:Number}<:AbstractSymmetryOperation

Matrix as a symmetry operation.
"""
struct MatrixOperation{D, R<:Number}<:AbstractSymmetryOperation
    matrix::Matrix{R}

    function MatrixOperation{D, R}(matrix::AbstractMatrix) where {D, R<:Number}
        size(matrix) != (D, D) && throw(DimensionMismatch("matrix dimensions are not ($D,$D): dimensions are $(size(matrix))"))
        return new{D, R}(matrix)
    end

    function MatrixOperation{R}(matrix::AbstractMatrix) where {R<:Number}
        D = LinearAlgebra.checksquare(matrix)
        return new{D, R}(matrix)
    end

    function MatrixOperation(matrix::AbstractMatrix{R}) where {R<:Number}
        D = LinearAlgebra.checksquare(matrix)
        return new{D, R}(matrix)
    end

    function MatrixOperation(value::R) where {R}
        iszero(value) && throw(DomainError("value cannot be zero $(value)"))
        return new{1, R}(ones(R, (1,1))*value)
    end

    function MatrixOperation{R}(value::Number) where {R}
        iszero(value) && throw(DomainError("value cannot be zero $(value)"))
        return new{1, R}(ones(R, (1,1))*value)
    end

    function MatrixOperation{D, R}(value::Number) where {D, R}
        iszero(value) && throw(DomainError("value cannot be zero $(value)"))
        return new{D, R}(Matrix(LinearAlgebra.I, (D, D))*R(value))
    end
end

Base.hash(x::M, h::UInt) where {M<:MatrixOperation} = Base.hash(M, Base.hash(x.matrix, h))

Base.:(==)(lhs::U, rhs::U) where {U<:MatrixOperation} = lhs.matrix == rhs.matrix

Base.inv(arg::MatrixOperation{D, I}) where {D, I<:Union{<:Integer, <:Rational, <:Complex{<:Integer}, <:Complex{<:Rational}}} = MatrixOperation{D, I}(LinearAlgebraX.invx(arg.matrix))
Base.inv(arg::MatrixOperation{D, F}) where {D, F<:Union{<:AbstractFloat, <:Complex{<:AbstractFloat}}} = MatrixOperation{D, F}(LinearAlgebra.inv(arg.matrix))
Base.conj(arg::U) where {U<:MatrixOperation} = U(conj(arg.matrix))
Base.transpose(arg::U) where {U<:MatrixOperation} = U(transpose(arg.matrix))
Base.adjoint(arg::U) where {U<:MatrixOperation} = U(adjoint(arg.matrix))

Base.:(*)(lhs::U, rhs::U) where {U<:MatrixOperation} = U(lhs.matrix * rhs.matrix)
Base.:(*)(lhs::U, rhs::Number) where {U<:MatrixOperation} = U(lhs.matrix * rhs)
Base.:(*)(lhs::Number, rhs::U) where {U<:MatrixOperation} = U(lhs * rhs.matrix)
function Base.:(^)(lhs::U, rhs::Integer) where {U<:MatrixOperation}
    if rhs >= 0
        return U(lhs.matrix^rhs)
    else
        minv = LinearAlgebraX.invx(lhs.matrix)
        return U(minv^(-rhs))
    end
end


isidentity(arg::MatrixOperation) = arg.matrix == LinearAlgebra.I

function Base.isapprox(
    lhs::MatrixOperation{D, R1},
    rhs::MatrixOperation{D, R2};
    atol::Real=0,
    rtol::Real=Base.rtoldefault(real(R1), real(R2), atol)
) where {D, R1, R2}
    return isapprox(lhs.matrix, rhs.matrix; atol=atol, rtol=rtol)
end
