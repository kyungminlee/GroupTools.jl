export GeneralizedPermutation

struct GeneralizedPermutation{AngleScalar<:Union{<:Integer, <:Rational}}<:AbstractSymmetryOperation
    map::Vector{Int}
    phase::Vector{Phase{AngleScalar}}
    order::Int

    function GeneralizedPermutation{T}(map, phase, order) where {T}
        return new{T}(map, phase, order)
    end

    function GeneralizedPermutation(
        map::AbstractVector{<:Integer},
        phase::AbstractVector{Phase{A}};
        maxorder::Integer=2048
    ) where {A}
        n = length(map)
        if n != length(phase)
            throw(ArgumentError("map and phase must be of the same length ($(length(map)) != $(length(phase))"))
        end
        let duplicates = Set{Int}()  # check for duplicates
            for j in map
                if !(1 <= j <= n)
                    throw(ArgumentError("argument not a proper permutation (target != universe)"))
                elseif j in duplicates
                    throw(ArgumentError("argument not a proper permutation (contains duplicates)"))
                end
                push!(duplicates, j)
            end
        end
        order = 1
        let # compute cycle length
            current_map = Vector{Int}(map)
            current_phase = Vector{Phase{A}}(phase)
            while order <= maxorder && !(current_map == 1:n && all(isone, current_phase))
                current_phase = phase[current_map] .* current_phase
                current_map = map[current_map]
                order += 1
            end
            if order > maxorder
                throw(OverflowError("cycle length exceeds maximum value (max = $maxorder)"))
            end
        end

        return new{A}(map, phase, order)

        # if all(iszero, phase)
        #     return new{T, Int}(map, phase, order)
        # elseif all(x -> iszero(2*x), phase)
        #     return new{T, Float64}(map, phase, order)
        # else
        #     return new{T, ComplexF64}(map, phase, order)
        # end
    end

    function GeneralizedPermutation(perms; maxorder::Integer=2048)
        map = [x[1] for x in perms]
        phase = [x[2] for x in perms]
        return GeneralizedPermutation(map, phase; maxorder=maxorder)
    end
end

function Base.:(==)(x::GeneralizedPermutation, y::GeneralizedPermutation)
    return x.order == y.order && x.map == y.map && x.phase == y.phase
end


function Base.Matrix{T}(gp::GeneralizedPermutation) where {T<:Number}
    n = length(gp.map)
    out = zeros(T, (n, n))
    for (j, (i, ϕ)) in enumerate(zip(gp.map, gp.phase))
        out[i, j] = convert(T, ϕ)
    end
    return out
end

Base.Matrix(gp::GeneralizedPermutation) = Base.Matrix{ComplexF64}(gp)


"""
Permutation:
    y: 𝐚 ↦ 𝐛
    x: 𝐛 ↦ 𝐜
    x * y : 𝐚 ↦ 𝐜

    b[ x[i] ] = a[ i ]
    c[ y[i] ] = b[ i ]
    ----------------
    c[ x[y[i]] ] = a[ i ]

GeneralizedPermutation:

    b[ y[i] ] = ϕy[ i ] * a[ i ] 
    c[ x[i] ] = ϕx[ i ] * b[ i ] 
    -------------------------
    c[ x[y[i]] ] = ϕx[y[i]] * ϕy[i] * a[i]

"""
function Base.:(*)(x::GeneralizedPermutation, y::GeneralizedPermutation)
    n = length(x.map)
    if n != length(y.map)
        throw(ArgumentError("The two GeneralizedPermutations should have the same length: ($n != $(length(y.map)))"))
    end
    map = x.map[y.map]
    phase = x.phase[y.map] .* y.phase
    return GeneralizedPermutation(map, phase)
end


function Base.inv(p::GeneralizedPermutation{A}) where {A}
    n = length(p.map)
    outmap = Vector{Int}(undef, n)
    outphase = Vector{Phase{A}}(undef, n)
    for (i, (x, ϕ)) in enumerate(zip(p.map, p.phase))
        outmap[x] = i
        outphase[x] = inv(ϕ)
    end
    return GeneralizedPermutation(outmap, outphase)
end

function Base.conj(p::GeneralizedPermutation{A}) where {A}
    return GeneralizedPermutation{A}(p.map, conj.(p.phase), p.order)
end

function isidentity(p::GeneralizedPermutation)
    return p.map == 1:length(p.map) && all(isone, p.phase)
end


function Base.hash(p::GeneralizedPermutation, h::UInt)
    h = hash(p.map, h)
    h = hash(p.phase, h)
    h = hash(GeneralizedPermutation, h)
    return h
end


function Base.isless(p1::GeneralizedPermutation, p2::GeneralizedPermutation)
    p1.order < p2.order && return true
    p2.order < p1.order && return false
    isless(p1.map,   p2.map)   && return true
    isless(p2.map,   p1.map)   && return false
    isless(p1.phase, p2.phase) && return true
    # isless(p2.phase, p1.phase) && return false
    return false
end


function (p::GeneralizedPermutation)(v::AbstractVector{T}) where {T<:Number}
    n = length(p.map)
    if n != length(v)
        throw(DimensionMismatch("GeneralizedPermutation has length $(length(p.map)), and v has $(length(v))"))
    end
    out = Vector{ComplexF64}(undef, n)
    for (j, (i, ϕ)) in enumerate(zip(p.map, p.phase))
        out[i] = v[j] * ϕ
    end
    return out
end

function (p::GeneralizedPermutation)(i::Integer, a::Number)
    return (p.map[i], p.phase[i] * a)
end


function (p::GeneralizedPermutation)(ia::Tuple{<:Integer, <:Number})
    i, a = ia
    return (p.map[i], p.phase[i] * a)
end