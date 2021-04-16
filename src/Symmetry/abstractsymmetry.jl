export AbstractSymmetry
export elementname
export elementnames

abstract type AbstractSymmetry{O} end

# Base.eltype(::Type{<:AbstractSymmetry}) = error("Not implemented")
# Base.valtype(::Type{<:AbstractSymmetry}) = error("Not implemented")
# Base.valtype(::AbstractSymmetry) = error("Not implemented")

# Base.IteratorSize(::Type{<:AbstractSymmetry}) = error("Not implemented")
# Base.length(x::AbstractSymmetry) = error("Not implemented")
# Base.size(x::AbstractSymmetry) = error("Not implemented")
# Base.keys(x::AbstractSymmetry) = error("Not implemented")
# Base.firstindex(::AbstractSymmetry) = 1
# Base.lastindex(x::AbstractSymmetry) = length(x)

# Base.getindex(x::AbstractSymmetry, i::Integer) = error("Not implemented")
# Base.getindex(x::AbstractSymmetry, i::AbstractVector{<:Integer}) = error("Not implemented")
# Base.getindex(x::AbstractSymmetry, i::AbstractVector{<:Bool}) = error("Not implemented")
# Base.getindex(x::AbstractSymmetry, s::Vararg{<:Integer}) = error("Not implemented")
# Base.getindex(x::AbstractSymmetry, s::CartesianIndex) = error("Not implemented")
# Base.iterate(x::AbstractSymmetry, i::Integer=1) = error("Not implemented")
# elements(x::AbstractSymmetry) = error("Not implemented")
# elementnames(x::AbstractSymmetry) = error("Not implemented")
# elementname(x::AbstractSymmetry, i) = error("Not implemented")

elementnames(x::AbstractSymmetry) = string.(x)
elementname(x::AbstractSymmetry, idx) = string.(x[idx])