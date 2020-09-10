export UnitaryOperation

import LinearAlgebra

struct UnitaryOperation{D, R<:Number} <: AbstractSymmetryOperation
    matrix::Matrix{R}

    function UnitaryOperation{D, R}(matrix::AbstractMatrix) where {D, R}
        size(matrix) != (D, D) && throw(ArgumentError("dimensions must be ($D,$D) != $(size(matrix))"))
        !isapprox(matrix * adjoint(matrix), LinearAlgebra.I) && throw(ArgumentError("matrix not unitary"))
        return new{D, R}(matrix)
    end

    function UnitaryOperation{R}(matrix::AbstractMatrix) where {R}
        D, D2 = size(matrix)
        D != D2 && throw(ArgumentError("dimensions must be square, not ($D,$D2)"))
        !isapprox(matrix * adjoint(matrix), LinearAlgebra.I) && throw(ArgumentError("matrix not unitary"))
        return new{D, R}(matrix)
    end

    function UnitaryOperation(matrix::AbstractMatrix{R}) where {R}
        D, D2 = size(matrix)
        D != D2 && throw(ArgumentError("dimensions must be square, not ($D,$D2)"))
        !isapprox(matrix * adjoint(matrix), LinearAlgebra.I) && throw(ArgumentError("matrix not unitary"))
        return new{D, R}(matrix)
    end

    function UnitaryOperation(value::R) where {R}
        !isone(abs(value)) && throw(ArgumentError("value not unit length ($(abs(value)))"))
        return new{1, R}(ones(R, (1,1))*value)
    end

    function UnitaryOperation{R}(value::Number) where {R}
        !isone(abs(value)) && throw(ArgumentError("value not unit length ($(abs(value)))"))
        return new{1, R}(ones(R, (1,1))*value)
    end

    function UnitaryOperation{D, R}(value::R) where {D, R}
        !isone(abs(value)) && throw(ArgumentError("value not unit length ($(abs(value)))"))
        return new{D, R}(Matrix(LinearAlgebra.I, (D, D))*value)
    end
end

Base.:(*)(lhs::U, rhs::U) where {U<:UnitaryOperation} = U(lhs.matrix * rhs.matrix)
Base.:(*)(lhs::U, rhs::Number) where {U<:UnitaryOperation} = U(lhs.matrix * rhs)
Base.:(*)(lhs::Number, rhs::U) where {U<:UnitaryOperation} = U(lhs * rhs.matrix)
Base.:(^)(lhs::U, rhs::Integer) where {U<:UnitaryOperation} = U(lhs.matrix^rhs)
Base.inv(arg::U) where {U<:UnitaryOperation} = U(adjoint(arg.matrix))
Base.:(==)(lhs::U, rhs::U) where {U<:UnitaryOperation} = lhs.matrix == rhs.matrix
Base.conj(arg::U) where {U<:UnitaryOperation} = U(conj(arg.matrix))
Base.transpose(arg::U) where {U<:UnitaryOperation} = U(transpose(arg.matrix))
Base.adjoint(arg::U) where {U<:UnitaryOperation} = U(adjoint(arg.matrix))

isidentity(arg::UnitaryOperation) = arg.matrix == LinearAlgebra.I

function Base.convert(::Type{UnitaryOperation{D, R}}, obj::UnitaryOperation{D, R2}) where {D, R, R2}
    return UnitaryOperation{D, R}(obj.matrix)
end

function Base.isapprox(lhs::UnitaryOperation{D, R}, rhs::UnitaryOperation{D, R}; atol::Real=0, rtol::Real=Base.rtoldefault(R)) where {D, R}
    return isapprox(lhs.matrix, rhs.matrix; atol=atol, rtol=rtol)
end
