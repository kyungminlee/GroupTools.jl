export Permutation
export generate_group
export isidentity


"""
    Permutation(perms; max_order=2048)

Create a permutation of integers from 1 to n.
`perms` should be a permutation of `1:n`.

# Arguments
- `perms`: an integer vector containing a permutation of integers from 1 to n
- `max_order`: maximum order

# Note
The convention for the permutation is that map[i] gets mapped to i.
In other words, map tells you where each element is from.
"""
struct Permutation<:AbstractSymmetryOperation
    map::Vector{Int}
    order::Int
    function Permutation(perms::AbstractVector{<:Integer}; max_order=2048)
        n = length(perms)
        map = Vector{Int}(perms)
        let duplicates = Set{Int}()  # check for duplicates
            for j in perms
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
            current = Int[map[x] for x in 1:n]
            while !issorted(current) && order <= max_order
                current = Int[map[x] for x in current]
                order += 1
            end
            if order > max_order
                throw(OverflowError("cycle length exceeds maximum value (max = $max_order)"))
            end
        end
        return new(map, order)
    end
end

Base.one(p::Permutation) = Permutation(1:length(p.map))

Base.:(==)(p1::Permutation, p2::Permutation) = p1.map == p2.map

(p::Permutation)(i::Integer) = p.map[i]

function (p::Permutation)(v::AbstractVector{T}) where {T}
    n = length(v)
    if n != length(p.map)
        throw(ArgumentError("permutation needs $(length(p.map)) elements"))
    end
    w = Vector{T}(undef, n)
    for i in 1:n
        w[p.map[i]] = v[i]
    end
    return w
end


function Base.Matrix{T}(p::Permutation) where {T<:Number}
    n = length(p.map)
    out = zeros(T, (n, n))
    for (j, i) in enumerate(p.map)
        out[i, j] = one(T)
    end
    return out
end

Base.Matrix(p::Permutation) = Base.Matrix{Bool}(p)


"""
    *(p1 ::Permutation, p2 ::Permutation)

Multiply the two permutation.
NOT THIS: (Return `[p2.map[x] for x in p1.map]`.)
BUT THIS: (Return `[p1.map[x] for x in p2.map]`.)

# Examples
```jldoctest
julia> using GroupTools

julia> Permutation([2,1,3]) * Permutation([1,3,2])
Permutation([2, 3, 1], 3)

julia> Permutation([1,3,2]) * Permutation([2,1,3])
Permutation([3, 1, 2], 3)
```
"""
function Base.:(*)(p1 ::Permutation, p2 ::Permutation)
    if length(p1.map) != length(p2.map)
        throw(ArgumentError("permutations of different universes"))
    end
    #  return Permutation(Int[p2.map[x] for x in p1.map]) original version
    return Permutation(p1.map[p2.map])
end


"""
    ^(perm ::Permutation, pow ::Integer)

Exponentiate the permutation.

# Examples
```jldoctest
julia> using GroupTools

julia> Permutation([2,3,4,1])^2
Permutation([3, 4, 1, 2], 2)
```
"""
function Base.:(^)(perm::Permutation, pow::Integer)
    p = mod(pow, perm.order)
    out = collect(1:length(perm.map))
    for i in 1:p
        out = collect(perm.map[x] for x in out)
    end
    return Permutation(out)
end


function Base.inv(perm::Permutation)
    out = zeros(Int, length(perm.map))
    for (i, x) in enumerate(perm.map)
        out[x] = i
    end
    return Permutation(out)
end


function Base.isless(p1 ::Permutation, p2::Permutation)
    return Base.isless(p1.order, p2.order) || ((p1.order == p2.order) && Base.isless(p1.map, p2.map))
end


function Base.hash(p::Permutation, h::UInt)
    return Base.hash(Permutation, hash(p.map, h))
end

"""
    generate_group(generators...)

Return a FiniteGroup generated by the `generators`.

# Arguments
* `generators::Permutation...`: generating permutations
"""
function generate_group(generators::Permutation...)
    change = true
    group = Set{Permutation}([generators...])
    while change
        change = false
        for g1 in generators, g2 in group
            g3 = g1 * g2
            if !(g3 in group)
                change = true
                push!(group, g3)
            end
        end
    end
    return group
end


"""
    isidentity(perm::Permutation)

Test whether the permutation is an identity.
"""
isidentity(perm::Permutation) = perm.map == 1:length(perm.map)
