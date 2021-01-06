# export DirectProductSymmetryRepresentation

# struct DirectProductSymmetryRepresentation{S<:DirectProductSymmetry, K<:Number}<:AbstractRepresentation
#     symmetry::S
#     matrices::Array{Matrix{K}}
    
#     function DirectProductSymmetryRepresentation(reps::AbstractRepresentation...)
#         symmetries_flat = [r.symmetry for r in reps]
#         symmetry = DirectProductSymmetry(symmetries_flat...)
#         indices = CartesianIndices(symmetry)
#         matrices_flat = [r.group_representation.matrices for r in reps]
#         matrices = [
#             kron([matrices[i] for (matrices, i) in zip(matrices_flat, index.I)]...)
#                 for index in indices
#         ]
#         S = typeof(symmetry)
#         K = eltype(first(matrices))
#         @show S
#         @show K
#         return new{S, K}(symmetry, matrices)
#     end
# end