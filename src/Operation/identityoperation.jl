# Trivial Symmetry Operation
export IdentityOperation

export apply_operation
export domaintype
export isidentity, istranslation, ispoint

"""
    IdentityOperation <: AbstractSymmetryOperation{S}

Represents identity operation
"""
struct IdentityOperation <: AbstractSymmetryOperation end

Base.one(x::IdentityOperation) = x
Base.one(::Type{IdentityOperation}) = IdentityOperation()

## properties

## operators
Base.:(==)(::IdentityOperation, ::IdentityOperation) = true
Base.isapprox(::IdentityOperation, ::IdentityOperation; atol::Real=0, rtol::Real=0) = true
Base.:(*)(lhs::IdentityOperation, ::IdentityOperation) = lhs
Base.:(*)(lhs::AbstractSymmetryOperation, ::IdentityOperation) = lhs
Base.:(*)(::IdentityOperation, rhs::AbstractSymmetryOperation) = rhs
Base.:(^)(::IdentityOperation, ::Integer) = IdentityOperation()

Base.inv(::IdentityOperation) = IdentityOperation()

"""
    isidentity(arg::IdentityOperation)

Check whether the argument is an identity. Always `true`.
"""
isidentity(arg::IdentityOperation) = true

## apply is about representation, not group. But identity is special.
apply_operation(::IdentityOperation, tgt) = tgt
(symop::IdentityOperation)(tgt) = tgt
