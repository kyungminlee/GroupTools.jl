export FiniteGroup

export group_order
export period_length
export group_product
export group_inverse

export generate_subgroup
export issubgroup
export isnormalsubgroup
export isabelian
export minimal_generating_set
export group_multiplication_table
export generate_multiplication_table

export generate_group_elements

export element, elements
export element_name, element_names

export group_isomorphism
export ishomomorphic


"""
    FiniteGroup

Finite group, with elements {1, 2, 3,..., n}. The identity element is always 1.
Can be constructed using `FiniteGroup(multiplication_table)`

# Fields
* `multiplication_table::Matrix{Int}`: multiplication table
* `period_lengths::Vector{Int}`: period length (order) of every element
* `inverses::Vector{Int}`: inverse of every element
* `conjugacy_classes::Vector{Vector{Int}}`: conjugacy classes

# Examples
```jldoctest
julia> using GroupTools

julia> FiniteGroup([1 2; 2 1])
FiniteGroup([1 2; 2 1], [1, 2], [1, 2], [[1], [2]])
```
"""
struct FiniteGroup <: AbstractGroup
    multiplication_table::Matrix{Int}

    period_lengths::Vector{Int}
    inverses::Vector{Int}
    conjugacy_classes::Vector{Vector{Int}}

    @doc """
        FiniteGroup(multiplication_table)
    """
    function FiniteGroup(mtab::AbstractMatrix{<:Integer})
        n_elem = size(mtab, 1)
        if size(mtab, 2) != n_elem
            throw(ArgumentError("Multiplication table should be a square matrix"))
        end
        # check identity and closure
        if (mtab[:,1] != 1:n_elem) || (mtab[1,:] != 1:n_elem)
            throw(ArgumentError("Element 1 should be identity"))
        end
        elements = BitSet(1:n_elem)
        # check closure and inverse (sudoku)
        for i in 2:n_elem
            if (BitSet(mtab[:,i]) != elements) || (BitSet(mtab[i,:]) != elements)
                throw(ArgumentError("Multiplication not a group"))
            end
        end
        # check associativity
        for i in 1:n_elem, j in 1:n_elem, k in 1:n_elem
            if mtab[mtab[i, j], k] != mtab[i, mtab[j, k]]
                throw(ArgumentError("Multiplication not associative"))
            end
        end
        # compute cycles
        period_lengths = zeros(Int, n_elem)
        for idx in 1:n_elem
            jdx = idx
            for i in 1:n_elem
                if jdx == 1
                    period_lengths[idx] = i
                    break
                end
                jdx = mtab[jdx, idx]
            end
        end
        # compute inverses
        inverses = zeros(Int, n_elem)
        for i in 1:n_elem
            for j in i:n_elem
                if mtab[i,j] == 1
                    inverses[i] = j
                    inverses[j] = i
                    break
                end
            end
        end
        # compute conjugacy classes
        conjugacy_classes = Vector{Int}[]
        let
            adjacency = [Int[] for i in 1:n_elem]
            for i in 1:n_elem, j in 1:n_elem
                k = mtab[ mtab[j,i], inverses[j] ]
                push!(adjacency[i], k)
                push!(adjacency[k], i)
            end
            for i in eachindex(adjacency)
                sort!(adjacency[i])
                unique!(adjacency[i])
            end
            visited = falses(n_elem)
            for i in 1:n_elem
                visited[i] && continue
                visited[adjacency[i]] .= true
                push!(conjugacy_classes, adjacency[i])
            end
        end

        @assert all(
            period_lengths[first(cc)] == period_lengths[i]
            for cc in conjugacy_classes for i in cc
        )

        new(mtab, period_lengths, inverses, conjugacy_classes)
    end
end


function Base.:(==)(lhs::FiniteGroup, rhs::FiniteGroup)
    return (lhs.multiplication_table == rhs.multiplication_table)
end

Base.eltype(::Type{FiniteGroup}) = Int
Base.valtype(::Type{FiniteGroup}) = Int
Base.valtype(::FiniteGroup) = Int

Base.length(group::FiniteGroup) = size(group.multiplication_table, 1)
Base.keys(group::FiniteGroup) = Base.OneTo(group_order(group))
Base.iterate(group::FiniteGroup, i::Integer=1) = 0 < i <= group_order(group) ? (i, i+1) : nothing
Base.getindex(group::FiniteGroup, idx...) = Base.OneTo(group_order(group))[idx...]
Base.firstindex(::FiniteGroup) = 1
Base.lastindex(group::FiniteGroup) = group_order(group)

"""
    element(group, idx)

Return the element of index `idx`. For `FiniteGroup`, this is somewhat meaningless
since the `idx`th element is `idx`. The sole purpose of this function is the bounds checking.
"""
element(group::FiniteGroup, idx) = Base.OneTo(group_order(group))[idx]

"""
    elements(group)

Return the elements of the group.
"""
elements(group::FiniteGroup) = Base.OneTo(group_order(group))


"""
    element_name(group, idx)

Return the name of element at index `idx`, which is just the string of `idx`.
"""
element_name(group::FiniteGroup, idx) = string.(element(group, idx))


"""
    element_names(group)

Return the names of element.
"""
element_names(group::FiniteGroup) = string.(elements(group))


"""
    group_order(group)

Order of group (i.e. number of elements)
"""
group_order(group::FiniteGroup) = size(group.multiplication_table, 1)


"""
    group_order(group, g)

Order of group element (i.e. period length)
"""
group_order(group::FiniteGroup, g) = group.period_lengths[g]


"""
    period_length(group, g)

Order of group element (i.e. period length)
"""
period_length(group::FiniteGroup, g) = group.period_lengths[g]


"""
    group_multiplication_table(group)

Return multiplcation table of the group.
"""
group_multiplication_table(group::FiniteGroup) = group.multiplication_table


"""
    isabelian(group)

Check if the group is abelian.
"""
function isabelian(group::FiniteGroup)
    return group.multiplication_table == transpose(group.multiplication_table)
end


"""
    group_product(group)

Return a function which computes the group product.
"""
function group_product(group::FiniteGroup) # a bit like currying
    function product(lhs::Integer, rhs::Integer)
        return group.multiplication_table[lhs, rhs]
    end
    function product(lhs::Integer, rhs::AbstractSet{<:Integer})
        return BitSet([group.multiplication_table[lhs, x] for x in rhs])
    end
    function product(lhs::AbstractSet{<:Integer}, rhs::Integer)
        return BitSet([group.multiplication_table[x, rhs] for x in lhs])
    end
    function product(lhs::AbstractSet{<:Integer}, rhs::AbstractSet{<:Integer})
        return BitSet([group.multiplication_table[x, y] for x in lhs for y in rhs])
    end
    return product
end


"""
    group_product(group, lhs, rhs)

Return the result of group multiplication of `lhs` and `rhs`.
If both `lhs` and `rhs` are integers, return an integer.
If either of them is a set (`AbstractSet`) of integers, then return a `BitSet`.
"""
function group_product(group::FiniteGroup, lhs::Integer, rhs::Integer)
    return group.multiplication_table[lhs, rhs]
end


function group_product(group::FiniteGroup, lhs::AbstractSet{<:Integer}, rhs::Integer)
    return BitSet([group_product(group, x, rhs) for x in lhs])
end


function group_product(group::FiniteGroup, lhs::Integer, rhs::AbstractSet{<:Integer})
    return BitSet([group_product(group, lhs, x) for x in rhs])
end


function group_product(
    group::FiniteGroup,
    lhs::AbstractSet{<:Integer},
    rhs::AbstractSet{<:Integer},
)
    return BitSet([group_product(group, x, y) for x in lhs for y in rhs])
end


"""
    group_inverse(group)

Get a function which gives inverse.
"""
function group_inverse(group::FiniteGroup)
    inverse(idx::Integer) = group.inverses[idx]
    inverse(idx::AbstractVector{<:Integer}) = group.inverses[idx]
    return inverse
end


"""
    group_inverse(group, g)

Get inverse of element/elements `g`.
"""
group_inverse(group::FiniteGroup, g::Integer) = group.inverses[g]
group_inverse(group::FiniteGroup, g::AbstractVector{<:Integer}) = group.inverses[g]


"""
    conjugacy_class(group::FiniteGroup, i::Integer)

Conjugacy class of the element `i`.
"""
function conjugacy_class(group::FiniteGroup, i::Integer)
    return findfirst(
        c -> let j = searchsortedfirst(c, i)
            j <= length(c) && c[j] == i
        end,
        group.conjugacy_classes
    )
end


"""
    generate_subgroup(group::FiniteGroup, idx::Integer)

subgroup generated by `generators`. ⟨ {`idx`} ⟩
"""
function generate_subgroup(group::FiniteGroup, idx::Integer)
    out = BitSet()
    sizehint!(out, group_order(group, idx))
    jdx = 1
    for i in 1:group_order(group, idx)
        push!(out, jdx)
        jdx = group_product(group, jdx, idx)
    end
    @assert jdx == 1
    return out
end


"""
    generate_subgroup(group::FiniteGroup, generators)

subgroup generated by `generators`. ⟨ S ⟩
"""
function generate_subgroup(
    group::FiniteGroup,
    generators::G
) where {G<:Union{<:AbstractSet{<:Integer}, <:AbstractVector{<:Integer}}}
    change = true
    subgroup = BitSet(generators)
    push!(subgroup, 1)
    while change
        change = false
        for g1 in generators, g2 in subgroup
            g3 = group_product(group, g1, g2)
            if !(g3 in subgroup)
                change = true
                push!(subgroup, g3)
            end
        end
    end
    return subgroup
end


# COV_EXCL_START
"""
    issubgroup(group, subset)

Check whether the given subset is a subgroup of `group`.
"""
function issubgroup(group::FiniteGroup, subset::AbstractSet{<:Integer})
    @warn "deprecated issubgroup(group, subset). Use issubgroup(subset, group) instead."
    return all(group_product(group, x, y) in subset for x in subset for y in subset)
end
# COV_EXCL_STOP


"""
    issubgroup(subset, group)

Check whether the given subset is a subgroup of `group`.

# Arguments
- `subset`: Either a set or a vector. A vector is converted into a set.
- `group`
"""
function issubgroup(subset::AbstractSet{<:Integer}, group::FiniteGroup)
    return all(group_product(group, x, y) in subset for x in subset for y in subset)
end

issubgroup(subset::AbstractVector{<:Integer}, group::FiniteGroup) = issubgroup(Set(subset), group)


# COV_EXCL_START
"""
    isnormalsubgroup(group, subset::AbstractSet{<:Integer})

Check whether the given subset is a normal subgroup of `group`.
"""
function isnormalsubgroup(group::FiniteGroup, subset::AbstractSet{<:Integer})
    @warn "deprecated isnormalsubgroup(group, subset). Use isnormalsubgroup(subset, group) instead."
    issubgroup(subset, group) || return false
    ∘ = group_product(group)
    ginv = group_inverse(group)
    return all((y ∘ x ∘ ginv(y) in subset) for x in subset, y in elements(group))
end
# COV_EXCL_STOP


"""
    isnormalsubgroup(subset, group)

Check whether the given subset is a normal subgroup of `group`.
"""
function isnormalsubgroup(subset::AbstractSet{<:Integer}, group::FiniteGroup)
    issubgroup(subset, group) || return false
    ∘ = group_product(group)
    ginv = group_inverse(group)
    return all((y ∘ x ∘ ginv(y) in subset) for x in subset, y in elements(group))
end

isnormalsubgroup(subset::AbstractVector{<:Integer}, group::FiniteGroup) = isnormalsubgroup(Set(subset), group)



"""
    minimal_generating_set(group)

Get minimally generating set of the finite group.
"""
function minimal_generating_set(group::FiniteGroup)
    ord_group::Int = group_order(group)
    element_queue::Vector{Tuple{Int, Int}} = collect(enumerate(group.period_lengths))
    sort!(element_queue, by=item->(-item[2], item[1]))

    queue_begin = 1
    span = BitSet([1])
    generators = Int[]
    while queue_begin <= ord_group && length(span) < ord_group
        next_index = queue_begin
        next_elem = element_queue[queue_begin][1]
        next_span = generate_subgroup(group, group_product(group, span, next_elem))
        for i in (queue_begin+1):ord_group
            (g, _) = element_queue[i]
            new_span = generate_subgroup(group, group_product(group, span, g))
            if length(new_span) > length(next_span)
                next_index = i
                next_elem = g
                next_span = new_span
            end
        end
        queue_begin = next_index + 1
        span = next_span
        push!(generators, next_elem)
    end
    return generators
end


"""
    group_isomorphism(group1, group2)

Find the isomorphism ϕ: G₁ → G₂. Return nothing if not isomorphic.
"""
function group_isomorphism(group1::FiniteGroup, group2::FiniteGroup)
    group_order(group1) != group_order(group2) && return nothing
    sort(group1.period_lengths) != sort(group2.period_lengths) && return nothing
    let cl1 = sort(length.(group1.conjugacy_classes)),
        cl2 = sort(length.(group1.conjugacy_classes))
        cl1 != cl2 && return nothing
    end
    ord_group = group_order(group1)

    pl1_list = group1.period_lengths
    pl2_list = group2.period_lengths
    cci1_list = zeros(Int, ord_group)

    for (cc_index, cc) in enumerate(group1.conjugacy_classes), i in cc
        cci1_list[i] = cc_index
    end

    element_map = zeros(Int, ord_group)
    class_map = zeros(Int, length(group1.conjugacy_classes))

    function suggest(i::Integer)
        # @assert element_map[i] == 0
        cci1 = cci1_list[i]
        cc1 = group1.conjugacy_classes[cci1]
        if class_map[cci1] != 0
            return (j for j in group2.conjugacy_classes[class_map[cci1]]
                    if !(j in element_map) && (pl2_list[j] == pl1_list[i]))
        else
            return (j for (icc2, cc2) in enumerate(group2.conjugacy_classes)
                          if length(cc2) == length(cc1)
                      for j in cc2
                          if !(j in element_map) && (pl2_list[j] == pl1_list[i]))
        end
    end

    function dfs(i::Integer)
        i > ord_group && return true
        element_map[i] != 0 && return dfs(i+1)
        for j in suggest(i)
            cset = class_map[cci1_list[i]] == 0
            element_map[i] = j
            class_map[cci1_list[i]] = conjugacy_class(group2, j)
            if dfs(i+1)
                return true
            else
                element_map[i] = 0
                if cset
                    class_map[cci1_list[i]] = 0
                end
            end
        end
        return false
    end

    if dfs(1)
        return element_map
    else
        return nothing
    end
end


"""
    generate_multiplication_table(elements, product=(*))

Generate a multiplication table from elements with product.
"""
function generate_multiplication_table(
    elements::AbstractVector{ElementType};
    product::Function=Base.:(*),
    normalize::Function=Base.identity
) where {ElementType}
    element_lookup = Dict(normalize(k)=>i for (i, k) in enumerate(elements))
    ord_group = length(elements)
    length(element_lookup) != ord_group && throw(ArgumentError("elements not unique"))
    mtab = zeros(Int, (ord_group, ord_group))
    for i in 1:ord_group, j in 1:ord_group
        mtab[i,j] = element_lookup[ normalize(product(elements[i], elements[j])) ]
    end
    return mtab
end


# COV_EXCL_START
"""
    ishomomorphic(group, representation; product=(*), equal=(==))

Check whether `representation` is homomorphic to `group` under `product` and `equal`,
order preserved.
"""
function ishomomorphic(
    group::FiniteGroup,
    representation::AbstractVector;
    product::Function=Base.:(*),
    equal::Function=Base.:(==)
)
    @warn "deprecated signature of ishomomorphic. Use ishomomorphic(representation, group) instead."
    ord_group = group_order(group)
    if length(representation) != ord_group
        return false
    end
    for i in 1:ord_group, j in 1:ord_group
        if !equal(
            product(representation[i], representation[j]),
            representation[ group_product(group, i, j)]
        )
            return false
        end
    end
    return true
end
# COV_EXCL_STOP

function ishomomorphic(
    representation::AbstractVector,
    group::FiniteGroup;
    product::Function=Base.:(*),
    equal::Function=Base.:(==)
)
    ord_group = group_order(group)
    length(representation) != ord_group && return false
    for i in 1:ord_group, j in 1:ord_group
        if !equal(
            product(representation[i], representation[j]),
            representation[ group_product(group, i, j)]
        )
            return false
        end
    end
    return true
end


# function generate_group_elements_generating_order(
#     generators::E...;
#     product::Function=(*),
#     max_order::Integer=4096
# ) where E
#     change = true
#     element_set = Set{E}([generators...])
#     while change
#         change = false
#         for g1 in generators, g2 in element_set
#             g3 = g1 * g2
#             if !(g3 in element_set)
#                 change = true
#                 push!(element_set, g3)
#             end
#             length(element_set) > 4096 && throw(OverflowError("number of elements larger than max_order $max_order"))
#         end
#     end
#     element_list = collect(element_set)
#     # reorder elements
#     # 1. find identity
#     identity_index = 0
#     n = length(element_list)
#     mtab = generate_multiplication_table(element_list)
#     @show mtab
#     for i in 1:n
#         if mtab[i,:] == 1:n && mtab[:,i] == 1:n
#             identity_index = i
#             break
#         end
#     end
#     identity_index == 0 && throw(ArgumentError("identity element not found"))
#     # 2. and then generators
#     generator_indices = Int[]
#     for g in generators
#         i = findfirst(x -> x == g, element_list)
#         @assert !isnothing(i)
#         push!(generator_indices, i)
#     end
#     # 3. and then the rest
#     included = falses(n)
#     included[identity_index] = true
#     included[generator_indices] .= true
#     ordered_element_list = [element_list[identity_index], element_list[generator_indices]...]
#     sizehint!(ordered_element_list, n)
#     for i in 1:n
#         included[i] && continue
#         push!(ordered_element_list, element_list[i])
#     end
#     @assert length(ordered_element_list) == n
#     return ordered_element_list
# end


"""
    generate_group_elements(g1[, g2, ...]; product=(*), max_order=4096)

Generate a list of group elements, ordered by their order (period length).
The identity element in the first spot.
"""
function generate_group_elements(
    generators::AbstractVector{E};
    product::Function=(*),
    max_order::Integer=4096
) where E
    # Generate all elements
    element_list = let
        element_set = Set{E}([generators...])
        change = true
        while change
            change = false
            for g1 in generators, g2 in element_set
                g3 = product(g1, g2)
                if !(g3 in element_set)
                    change = true
                    push!(element_set, g3)
                    break
                end
            end
            if length(element_set) > max_order
                throw(OverflowError("number of elements larger than max_order $max_order"))
            end
        end
        collect(element_set)
    end
    n = length(element_list)
    # Reorder elements by element order. Generators comes before other elements with the same order.
    mtab = generate_multiplication_table(element_list; product=product)
    priority_list = Vector{Tuple{Int, Int}}(undef, n) # [(l, b) | l is order, b is "bonus"]
    fill!(priority_list, (0, n))
    for (ig, g) in enumerate(generators)
        i = findfirst(x -> x == g, element_list)
        @assert !isnothing(i)
        priority_list[i][2] != n && continue
        priority_list[i] = (0, ig-1)
    end
    for i in 1:n
        k = i
        for j in 1:n
            k = mtab[i, k]
            if k == i
                priority_list[i] = (j, priority_list[i][2])
                break
            end
        end
    end
    @assert all(x -> x[1] > 0, priority_list)
    idx = sortperm(priority_list)
    return element_list[idx]
end


# function group_isomorphism_naive(group1::FiniteGroup, group2::FiniteGroup)
#     group_order(group1) != group_order(group2) && return nothing
#     sort(group1.period_lengths) != sort(group2.period_lengths) && return nothing
#
#     ord_group = group_order(group1)
#     element_groups1 = Dict{Tuple{Int, Int}, Vector{Int}}() # group by period lengths and conjugacy class size
#     element_groups2 = Dict{Tuple{Int, Int}, Vector{Int}}() # group by period lengths
#
#     for i in 1:group_order(group1)
#         pl = group1.period_lengths[i]
#         cc = length(group1.conjugacy_classes[conjugacy_class(group1, i)])
#         if !haskey(element_groups1, (pl, cc))
#             element_groups1[(pl, cc)] = Int[]
#         end
#         push!(element_groups1[(pl, cc)], i)
#     end
#
#     for i in 1:group_order(group2)
#         pl = group2.period_lengths[i]
#         cc = length(group2.conjugacy_classes[conjugacy_class(group2, i)])
#         if !haskey(element_groups2, (pl, cc))
#             element_groups2[(pl, cc)] = Int[]
#         end
#         push!(element_groups2[(pl, cc)], i)
#     end
#
#     #q = sort([(pl, i) for (pl, els) in element_groups1 for i in els], rev=true)
#     plccs = sort(collect(keys(element_groups1)))
#     mapping = zeros(Int, ord_group)
#     for perm_set in Iterators.product([
#             permutations(1:length(element_groups1[plcc]), length(element_groups1[plcc]))
#             for plcc in plccs
#         ]...)
#         #@assert length(pls) == length(perm_set)
#         for (ipl, (plcc, perm)) in enumerate(zip(plccs, perm_set))
#             elg1, elg2 = element_groups1[plcc], element_groups2[plcc]
#             for j in 1:length(perm)
#                 mapping[ element_groups1[plcc][j] ] = element_groups2[plcc][ perm[j] ]
#             end
#         end
#         #mtab1p = zeros(Int, (ord_group, ord_group))
#         isiso = true
#         for i in 1:ord_group, j in 1:ord_group
#             #mtab1p[mapping[i], mapping[j]] = mapping[group1.multiplication_table[i, j]]
#             if group2.multiplication_table[mapping[i], mapping[j]] != mapping[group1.multiplication_table[i, j]]
#                 isiso = false
#                 break
#             end
#         end
#         isiso && return mapping
#         #!isiso && continue
#         #mtab1p == group2.multiplication_table && return mapping
#     end
#     return nothing
# end
