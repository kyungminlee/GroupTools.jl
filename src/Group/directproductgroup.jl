export directproduct

function directproduct(groups::FiniteGroup...)
    lengths = group_order.(groups) 
    indices = CartesianIndices(tuple([1:n for n in lengths]...))
    elements = reshape([index.I for index in indices], length(indices))
    products = group_product.(groups)
    function product(lhs::Tuple{Vararg{Int}}, rhs::Tuple{Vararg{Int}})
        tuple([p(l, r) for (p, l, r) in zip(products, lhs, rhs)]...)
    end
    mtab = generate_multiplication_table(elements; product=product)
    return FiniteGroup(mtab)
end
