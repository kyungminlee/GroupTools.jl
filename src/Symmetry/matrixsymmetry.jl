export matrixsymmetry

export elements
export group

_digits(::Type{Float32}) = 24
_digits(::Type{Float64}) = 53

function _default_normalize(::Type{T}) where {T<:AbstractFloat}
    d::Int = _digits(T) ÷ 2
    function normalize(x::T)
        y = round(x; digits=d, base=2)
        return iszero(y) ? zero(T) : y
    end
    normalize(x::AbstractArray{T}) = normalize.(x)
    return normalize
end

function _default_normalize(::Type{Complex{T}}) where {T<:AbstractFloat}
    d::Int = _digits(T) ÷ 2
    function normalize(x::Complex{T})
        y = round(x; digits=d, base=2)
        ry = iszero(real(y)) ? zero(T) : real(y)
        iy = iszero(imag(y)) ? zero(T) : imag(y)
        return Complex{T}(ry, iy)
    end
    normalize(x::AbstractArray{ComplexF64}) = normalize.(x)
    return normalize
end

function _default_normalize(::Type{T}) where {T<:Union{<:Integer, <:Rational, <:Complex{<:Integer}, <:Complex{<:Rational}}}
    normalize(x::T) = x
    normalize(x::AbstractArray{T}) = x
    return normalize
end

function matrixsymmetry(
    elements::AbstractVector{MatrixOperation{D, S}};
    normalize::Function=_default_normalize(S)
) where {D, S}
    return GenericSymmetry(elements; hash=(x::MatrixOperation)->hash(normalize(x.matrix)))
end

function matrixsymmetry(
    matrices::AbstractVector{<:AbstractMatrix{S}};
    normalize::Function=_default_normalize(S)
) where {S}
    elements = MatrixOperation.(matrices)
    return GenericSymmetry(elements; hash=(x::MatrixOperation)->hash(normalize(x.matrix)))
end

function matrixsymmetry(
    matrices::AbstractVector{S};
    normalize::Function=_default_normalize(S)
) where {S}
    elements = MatrixOperation.(matrices)
    return GenericSymmetry(elements; hash=(x::MatrixOperation)->hash(normalize(x.matrix)))
end
