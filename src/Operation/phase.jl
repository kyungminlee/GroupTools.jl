export Phase

struct Phase{T<:Real} <: AbstractSymmetryOperation
    fraction::T
    Phase(::I) where {I<:Integer} = new{I}(zero(I))
    Phase(f::T) where {T<:Real} = new{T}(mod(f, one(T)))
    Phase{T}(f) where {T<:Real} = new{T}(mod(f, one(T)))
end

Base.promote_rule(::Type{Phase{T1}}, ::Type{Phase{T2}}) where {T1, T2} = Phase{promote_type(T1, T2)}
Base.convert(::Type{Phase{T}}, x::Phase) where {T} = Phase(convert(T, x.fraction))

Base.promote_rule(::Type{Complex{R}}, ::Type{<:Phase}) where {R<:AbstractFloat} = Complex{R}
Base.promote_rule(::Type{R}, ::Type{<:Phase}) where {R<:AbstractFloat} = Complex{R}

Base.promote_rule(::Type{Complex{R}}, ::Type{<:Phase}) where {R<:Real} = ComplexF64
Base.promote_rule(::Type{R}, ::Type{<:Phase}) where {R<:Real} = ComplexF64

# Need this when scalar types are different
Base.:(==)(x::Phase, y::Phase) = x.fraction == y.fraction

Base.one(::Phase{T}) where {T} = Phase{T}(zero(T))
Base.one(::Type{Phase{T}}) where {T} = Phase{T}(zero(T))
Base.isone(p::Phase) = iszero(p.fraction)

function Base.convert(::Type{Complex{R}}, phase::Phase) where {R<:AbstractFloat}
    @warn "Conversion from Phase to Number type is deprecated" maxlog=1
    r = cospi(2*phase.fraction)
    i = sinpi(2*phase.fraction)
    return Complex{R}(r, i)
    #return convert(Complex{R}, cis(2*pi*phase.fraction))
end

function Base.convert(::Type{R}, phase::Phase) where {R<:AbstractFloat}
    @warn "Conversion from Phase to Number type is deprecated" maxlog=1
    iszero(mod(phase.fraction * 2, one(R))) || throw(InexactError(:convert, R, phase))
    return convert(R, cospi(2*phase.fraction))
end

function Base.convert(::Type{R}, phase::Phase{T}) where {R<:Integer, T}
    @warn "Conversion from Phase to Number type is deprecated" maxlog=1
    if iszero(phase.fraction)
        return one(R)
    elseif isone(phase.fraction * 2)
        return -one(R)
    end
    throw(InexactError(:convert, R, phase))
end

function Base.convert(::Type{Complex{R}}, phase::Phase{T}) where {R<:Integer, T}
    @warn "Conversion from Phase to Number type is deprecated" maxlog=1
    f4 = phase.fraction * 4
    if iszero(f4)
        return Complex{R}(one(R), zero(R))
    elseif f4 == 1
        return Complex{R}(zero(R), one(R))
    elseif f4 == 2
        return Complex{R}(-one(R), zero(R))
    elseif f4 == 3
        return Complex{R}(zero(R), -one(R))
    else
        throw(InexactError(:convert, Complex{R}, phase))
    end
end

Base.:(*)(x::Phase, y::Phase) = Phase(x.fraction + y.fraction)
Base.:(/)(x::Phase, y::Phase) = Phase(x.fraction - y.fraction)
Base.:(\)(x::Phase, y::Phase) = Phase(y.fraction - x.fraction)
function Base.:(//)(x::Phase{<:Union{<:Integer, <:Rational{<:Integer}}}, y::Phase{<:Union{<:Integer, <:Rational{<:Integer}}})
    return Phase(x.fraction - y.fraction)
end
Base.:(^)(x::Phase, y::Integer) = Phase(x.fraction * y)
Base.inv(x::Phase) = Phase(-x.fraction)
Base.conj(x::Phase) = Phase(-x.fraction)

Base.angle(x::Phase{T}) where {T} = pi*(mod(2*x.fraction+one(T), 2*one(T)) - one(T))
Base.real(phase::Phase) = cospi(2*phase.fraction)
Base.imag(phase::Phase) = sinpi(2*phase.fraction)

# Independent of type
Base.hash(p::Phase, h::UInt) = hash(Phase, hash(p.fraction, h))


function (x::Phase)(y::S) where {S<:Number}
    f4 = x.fraction * 4
    if iszero(f4)
        return y
    elseif f4 == 1
        return im * y
    elseif f4 == 2
        return -y
    elseif f4 == 3
        return -im * y
    else
        r = cospi(2*x.fraction)
        i = sinpi(2*x.fraction)
        return Complex(r, i) * y
    end
end
