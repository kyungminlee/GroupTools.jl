export Phase

struct Phase{T<:Real} <: Number
    fraction::T
    Phase(::I) where {I<:Integer} = new{I}(zero(I))
    Phase(f::T) where {T<:Real} = new{T}(mod(f, one(T)))
    Phase{T}(f) where {T<:Real} = new{T}(mod(f, one(T)))
end

Base.promote_rule(::Type{Phase{T1}}, ::Type{Phase{T2}}) where {T1, T2} = Phase{promote_type(T1, T2)}
Base.convert(::Type{Phase{T}}, x::Phase) where {T} = Phase(convert(T, x.fraction))

Base.promote_rule(::Type{C}, ::Type{<:Phase}) where {C<:Complex} = C
Base.promote_rule(::Type{R}, ::Type{<:Phase}) where {R<:Real} = R

# Need this when scalar types are different
Base.:(==)(x::Phase, y::Phase) = x.fraction == y.fraction

Base.:(*)(x::Phase, y::Phase) = Phase(x.fraction + y.fraction)
Base.:(/)(x::Phase, y::Phase) = Phase(x.fraction - y.fraction)
Base.:(^)(x::Phase, y::Integer) = Phase(x.fraction * y)
Base.inv(x::Phase) = Phase(-x.fraction)


function Base.convert(::Type{Complex{R}}, phase::Phase) where {R<:AbstractFloat}
    return convert(Complex{R}, cis(2*pi*phase.fraction))
end

function Base.convert(::Type{R}, phase::Phase) where {R<:AbstractFloat}
    iszero(mod(phase.fraction * 2, one(R))) || throw(InexactError(Symbol("$R"), R, phase))
    return convert(R, cos(2*pi*phase.fraction))
end

function Base.convert(::Type{R}, phase::Phase{T}) where {R<:Integer, T}
    if phase.fraction == zero(T)
        return one(R)
    elseif phase.fraction * 2 == one(T)
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
Base.real(phase::Phase) = cos(2*pi*phase.fraction)
Base.imag(phase::Phase) = sin(2*pi*phase.fraction)

