export SemidirectProductOperation
export isidentity

struct SemidirectProductOperation{A<:AbstractSymmetryOperation, B<:AbstractSymmetryOperation}<:AbstractSymmetryOperation
    rest::A
    normal::B # element of normal subgroup
    function SemidirectProductOperation(a::A, b::B) where {A<:AbstractSymmetryOperation, B<:AbstractSymmetryOperation}
        isa(a(b), B) || throw(ArgumentError("The second argument should be normal"))
        return new{A, B}(a, b)
    end
end

function Base.hash(x::P, h::UInt) where {P<:SemidirectProductOperation}
    return hash(P, hash(x.normal, hash(x.rest, h)))
end

function Base.:(==)(lhs::S, rhs::S) where {S<:SemidirectProductOperation}
    return lhs.rest == rhs.rest && lhs.normal == rhs.normal
end

function Base.:(*)(x::S, y::S) where {S<:SemidirectProductOperation}
    rest = x.rest * y.rest
    normal = inv(y.rest)(x.normal) * y.normal
    return SemidirectProductOperation(rest, normal)
end

# product: R₁ N₁ ⋅ R₂ N₂ = R₁ R₂ (R₂⁻¹ N₂ R₂) N₂
# inv: (R N)⁻¹ = N⁻¹ R⁻¹ = R⁻¹ (R N⁻¹ R⁻¹)
function Base.inv(x::SemidirectProductOperation{A, B}) where {A, B}
    irest = inv(x.rest)
    inormal = x.rest( inv(x.normal) )
    return SemidirectProduct(irest, inormal)
end