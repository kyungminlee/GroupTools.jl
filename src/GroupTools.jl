module GroupTools

include("Operation/abstractoperation.jl")
include("Operation/identityoperation.jl")
include("Operation/productoperation.jl")
include("Operation/matrixoperation.jl")
include("Operation/permutation.jl")

include("Group/abstractgroup.jl")
include("Group/finitegroup.jl")
include("Group/directproductgroup.jl")

include("Symmetry/abstractsymmetry.jl")
include("Symmetry/genericsymmetry.jl")

include("Symmetry/groupsymmetry.jl")
include("Symmetry/matrixsymmetry.jl")
include("Symmetry/directproductsymmetry.jl")
include("Symmetry/semidirectproductsymmetry.jl")

end # module
