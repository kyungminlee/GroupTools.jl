export AbstractSymmetryOperation

abstract type AbstractSymmetryOperation end

Base.iterate(x::AbstractSymmetryOperation, ::Integer=1) = (x, nothing)
Base.iterate(::AbstractSymmetryOperation, ::Nothing) = nothing
Base.eltype(::Type{T}) where {T<:AbstractSymmetryOperation} = T
