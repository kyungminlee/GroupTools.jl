using Test
using GroupTools

@testset "MatrixSymmetry" begin
    sym1 = MatrixSymmetry([[1 0; 0 1], [-1 0; 0 -1], [0 -1; 1 0], [0 1; -1 0]])
    sym2 = MatrixSymmetry([[1 0; 0 1], [0 -1; 1 -1], [-1 1; -1 0]])
    sym3 = DirectProductSymmetry(sym1, sym2)

    @test length(sym1) == 4
    @test length(sym2) == 3
    @test length(sym3) == 12

    @test size(sym1) == (4,)
    @test size(sym2) == (3,)
    @test size(sym3) == (4, 3)

    @test Base.IteratorSize(sym3) == Base.HasShape{2}()
    sym3_collect1 = [sym3[i] for i in 1:length(sym3)]
    sym3_collect2 = [sym3[i] for i in eachindex(sym3)]
    sym3_collect3 = elements(sym3)

    # @show sym3_collect1 |> typeof
    # @show sym3_collect2 |> typeof
    # @show sym3_collect3 |> typeof

    # @show collect(Iterators.flatten(sym3_collect2))
    # @show eltype(Iterators.flatten(sym3_collect2))
    # @show eltype(sym3_collect2)

    # @show @code_lowered collect(Iterators.flatten(sym3_collect1))
    # @show Base.IteratorSize(sym3_collect2)
    # @show Base.IteratorEltype(sym3_collect2)
    # @show eltype(sym3_collect2)

    # @show Base._collect(1:1, sym3_collect2, Base.HasEltype(), Base.HasShape{2}())


    @test sym3_collect1 != sym3_collect2
    # @test collect(Iterators.flatten(sym3_collect1)) != collect(Iterators.flatten(sym3_collect2))
    @test sym3_collect2 == sym3_collect3

    # @show keys(sym3)
    @test size( [x for x in sym3] ) == (4,3)

    # @show eltype(typeof(Iterators.flatten(sym3_collect2)))
    # # @show @code_lowered eltype(typeof(Iterators.flatten(sym3_collect2)))
    # @show eltype(Iterators.flatten(sym3_collect2))
    # @show eltype(sym3_collect2)
    # @show [x for x in sym3] |> size
    # for i in 1:length(sym3)
    #     @show sym3[i]
    # end

    # @show eachindex(sym3)
    # for x in sym3
    #     @show x
    # end
    # @show elements(sym3)

    # sym3[1,2]
end
