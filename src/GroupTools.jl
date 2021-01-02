module GroupTools

include("Operation/abstractoperation.jl")
include("Operation/identityoperation.jl")
include("Operation/productoperation.jl")
include("Operation/matrixoperation.jl")

include("Group/abstractgroup.jl")
include("Group/finitegroup.jl")
include("Group/permutation.jl")

include("Symmetry/abstractsymmetry.jl")
include("Symmetry/matrixsymmetry.jl")
include("Symmetry/directproductsymmetry.jl")
include("Symmetry/semidirectproductsymmetry.jl")

include("Representation/finitegrouprepresentation.jl")
include("Representation/symmetryrepresentation.jl")

end # module
