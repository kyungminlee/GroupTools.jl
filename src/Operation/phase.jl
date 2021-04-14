export Phase

struct Phase{T<:Real} <: Number
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

Base.:(*)(x::Phase, y::Phase) = Phase(x.fraction + y.fraction)
Base.:(/)(x::Phase, y::Phase) = Phase(x.fraction - y.fraction)
Base.:(^)(x::Phase, y::Integer) = Phase(x.fraction * y)
Base.inv(x::Phase) = Phase(-x.fraction)
Base.conj(x::Phase) = Phase(-x.fraction)


function Base.convert(::Type{Complex{R}}, phase::Phase) where {R<:AbstractFloat}
    r = cospi(2*phase.fraction)
    i = sinpi(2*phase.fraction)
    return Complex{R}(r, i)
    #return convert(Complex{R}, cis(2*pi*phase.fraction))
end

function Base.convert(::Type{R}, phase::Phase) where {R<:AbstractFloat}
    iszero(mod(phase.fraction * 2, one(R))) || throw(InexactError(Symbol("$R"), R, phase))
    return convert(R, cospi(2*phase.fraction))
end

function Base.convert(::Type{R}, phase::Phase{T}) where {R<:Integer, T}
    if iszero(phase.fraction)
        return one(R)
    elseif isone(phase.fraction * 2)
        return -one(R)
    end
    throw(InexactError(Symbol("$R"), R, phase))
end

function Base.convert(::Type{Complex{R}}, phase::Phase{T}) where {R<:Integer, T}
    if phase.fraction == zero(T)
        return one(Complex{R})
    elseif phase.fraction * 2 == one(T)
        return -one(Complex{R})
    end
    throw(InexactError(Symbol("$(Complex{R})"), Complex{R}, phase))
end

Base.angle(x::Phase{T}) where {T} = pi*(mod(2*x.fraction+one(T), 2*one(T)) - one(T))
Base.real(phase::Phase) = cospi(2*phase.fraction)
Base.imag(phase::Phase) = sinpi(2*phase.fraction)

# Independent of type
Base.hash(p::Phase, h::UInt) = hash(Phase, hash(p.fraction, h))