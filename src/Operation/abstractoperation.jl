export AbstractSymmetryOperation

"""
    AbstractSymmetryOperation
"""
abstract type AbstractSymmetryOperation end

Base.IteratorSize(::Type{T}) where {T<:AbstractSymmetryOperation} = Base.HasShape{0}()
Base.size(::AbstractSymmetryOperation) = ()
Base.length(::AbstractSymmetryOperation) = 1
Base.iterate(x::AbstractSymmetryOperation, ::Integer=1) = (x, nothing)
Base.iterate(::AbstractSymmetryOperation, ::Nothing) = nothing
Base.eltype(::Type{T}) where {T<:AbstractSymmetryOperation} = T
