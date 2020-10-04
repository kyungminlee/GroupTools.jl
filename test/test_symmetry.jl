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

    @test sym3_collect1 != sym3_collect2
    @test collect(Iterators.flatten(sym3_collect1)) == collect(Iterators.flatten(sym3_collect2))
    @test sym3_collect2 == sym3_collect3

    @test size( [x for x in sym3] ) == (4,3)
end
