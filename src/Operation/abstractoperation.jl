export AbstractSymmetryOperation

"""
    AbstractSymmetryOperation

Abstract symmetry operation type.
"""
abstract type AbstractSymmetryOperation end

Base.IteratorSize(::Type{T}) where {T<:AbstractSymmetryOperation} = Base.HasShape{0}()
Base.size(::AbstractSymmetryOperation) = ()
Base.length(::AbstractSymmetryOperation) = 1
Base.iterate(x::AbstractSymmetryOperation, ::Integer=1) = (x, nothing)
Base.iterate(::AbstractSymmetryOperation, ::Nothing) = nothing
Base.eltype(::Type{T}) where {T<:AbstractSymmetryOperation} = T


function Base.:(^)(lhs::AbstractSymmetryOperation, p::Integer)
    if p < 0
        pow = inv(lhs)
        p = -p
    else
        pow = lhs
    end

    # smallest nonzero power
    while (p & 0x1) == 0
        pow = pow * pow
        p = p >> 1
    end

    out = pow
    p = p >> 1
    while p > 0
        pow = pow * pow
        if (p & 0b1) != 0
            out = out * pow
        end
        p = p >> 1
    end
    return out
end
