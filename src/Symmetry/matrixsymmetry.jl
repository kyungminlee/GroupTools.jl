export MatrixSymmetry

export elements
export group

function default_normalize(::Type{Float64})
    function normalize(x::Float64)
        y = round(x; digits=8)
        return (y == -0.0) ? 0.0 : y
    end
    normalize(x::AbstractArray{Float64}) = normalize.(x)
    normalize(x::MatrixOperation{D, Float64}) where D = MatrixOperation{D, Float64}(normalize(x.matrix))
    return normalize
end

function default_normalize(::Type{ComplexF64})
    function _normalize(x::ComplexF64)
        y = round(x; digits=8)
        ry = (real(y) == -0.0) ? 0.0 : real(y)
        iy = (imag(y) == -0.0) ? 0.0 : imag(y)
        return ComplexF64(ry, iy)
    end
    normalize(x::AbstractArray{ComplexF64}) = _normalize.(x)
    normalize(x::MatrixOperation{D, ComplexF64}) where D = MatrixOperation{D, ComplexF64}(normalize(x.matrix))
    return normalize
end

function default_normalize(::Type{T}) where {T<:Union{<:Integer, <:Rational, <:Complex{<:Integer}, <:Complex{<:Rational}}}
    normalize(x::T) = x
    normalize(x::AbstractArray{T}) = x
    normalize(x::MatrixOperation{D, T}) where D = x
    return normalize
end

struct MatrixSymmetry{M<:MatrixOperation}<:AbstractSymmetry
    elements::Vector{M}
    group::FiniteGroup

    function MatrixSymmetry(matrices::AbstractVector{<:AbstractMatrix{S}}; normalize::Function=default_normalize(S)) where {S}
        D = size(matrices[1], 1)
        elements = MatrixOperation.(matrices)
        group = FiniteGroup(generate_multiplication_table(elements; hash=x->hash(normalize(x))))
        return new{MatrixOperation{D, S}}(elements, group)
    end

    function MatrixSymmetry(elements::AbstractVector{MatrixOperation{D, S}}; normalize::Function=default_normalize(S)) where {D, S}
        # elements_normal = normalize.(elements)
        # group = FiniteGroup(generate_multiplication_table(elements_normal, (x, y) -> normalize(x*y)))
        # return new{MatrixOperation{D, S}}(elements_normal, group)
        group = FiniteGroup(generate_multiplication_table(elements;
        hash=(x)->hash(normalize(x))
        ))
        return new{MatrixOperation{D, S}}(elements, group)        
    end
end

Base.IteratorSize(::Type{<:MatrixSymmetry}) = Base.HasShape{1}()

Base.eltype(::Type{MatrixSymmetry{M}}) where M = M
Base.valtype(::Type{MatrixSymmetry{M}}) where M = M
Base.valtype(::MatrixSymmetry{M}) where M = M

Base.length(x::MatrixSymmetry) = length(x.elements)
Base.size(x::MatrixSymmetry) = (length(x.elements),)
Base.keys(x::MatrixSymmetry) = Base.OneTo(length(x))
Base.firstindex(::MatrixSymmetry) = 1
Base.lastindex(x::MatrixSymmetry) = length(x.elements)

Base.getindex(x::MatrixSymmetry, i) = Base.getindex(x.elements, i)

Base.iterate(x::MatrixSymmetry) = Base.iterate(x.elements)
Base.iterate(x::MatrixSymmetry, i) = Base.iterate(x.elements, i)

function Base.:(==)(lhs::MS, rhs::MS) where {MS<:MatrixSymmetry}
    return lhs.elements == rhs.elements && lhs.group == rhs.group
end

elements(m::MatrixSymmetry) = m.elements
group(m::MatrixSymmetry) = m.group
