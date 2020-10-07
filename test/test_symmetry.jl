using Test
using GroupTools

@testset "MatrixSymmetry" begin
    # C4 group (Abelian)
    sym1 = MatrixSymmetry([[1 0; 0 1], [-1 0; 0 -1], [0 -1; 1 0], [0 1; -1 0]])
    @testset "type traits" begin
        @test eltype(sym1) <: MatrixOperation{2, Int}
        @test valtype(typeof(sym1)) <: MatrixOperation{2, Int}
        sym2 = MatrixSymmetry([[1.0 0.0; 0 1], [-1 0; 0 -1], [0.0 -1.0; 1.0 0.0], [0 1; -1 0]])
        @test eltype(sym2) <: MatrixOperation{2, Float64}
    end
    @testset "iterator properties" begin
        @test Base.IteratorSize(sym1) == Base.HasShape{1}()
        @test length(sym1) == 4
        @test size(sym1) == (4,)
        @test keys(sym1) == 1:4
    end
    @testset "element access" begin
        @test sym1[1] == MatrixOperation([1 0; 0 1])
        @test sym1[2] == MatrixOperation([-1 0; 0 -1])
        @test sym1[3] == MatrixOperation([0 -1; 1 0])
        @test sym1[4] == MatrixOperation([0 1; -1 0])
        @test_throws BoundsError sym1[-1]
        @test_throws BoundsError sym1[0]
        @test_throws BoundsError sym1[5]
        sym1_collect1 = [sym1[i] for i in 1:length(sym1)]
        sym1_collect2 = [sym1[i] for i in eachindex(sym1)]
        sym1_collect3 = elements(sym1)
        @test sym1_collect1 == sym1_collect2 == sym1_collect3
        @test length(sym1_collect1) == length(sym1)
        @test isa(sym1_collect1, Vector{MatrixOperation{2, Int}})
    end
    @testset "group" begin
        @test group(sym1) == FiniteGroup([
            1 2 3 4;
            2 1 4 3;
            3 4 2 1;
            4 3 1 2
        ])
    end
end

@testset "DirectProductSymmetry" begin
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

    @test size([x for x in sym3]) == (4, 3)
end

@testset "SemidirectProductSymmetry" begin
    # 4/m (C₄ₕ) = 4 ⋊ -1
    sym1 = MatrixSymmetry([
        [1 0 0; 0 1 0; 0 0 1],
        [0 -1 0; 1 0 0; 0 0 1],
        [-1 0 0; 0 -1 0; 0 0 1],
        [0 1 0; -1 0 0; 0 0 1]
    ])
    sym2 = MatrixSymmetry([
        [1 0 0; 0 1 0; 0 0 1],
        [-1 0 0; 0 -1 0; 0 0 -1],
    ])
    symp = sym1 ⋊ sym2
    # @show collect(symp)
    els1 = collect(symp)
    @test size(els1) == (4,2)
    @test length(els1) == 8
    els2 = [
        MatrixOperation{3,Int64}([1 0 0; 0 1 0; 0 0 1])
        MatrixOperation{3,Int64}([0 -1 0; 1 0 0; 0 0 1])
        MatrixOperation{3,Int64}([-1 0 0; 0 -1 0; 0 0 1])
        MatrixOperation{3,Int64}([0 1 0; -1 0 0; 0 0 1])
        MatrixOperation{3,Int64}([-1 0 0; 0 -1 0; 0 0 -1])
        MatrixOperation{3,Int64}([0 1 0; -1 0 0; 0 0 -1])
        MatrixOperation{3,Int64}([1 0 0; 0 1 0; 0 0 -1])
        MatrixOperation{3,Int64}([0 -1 0; 1 0 0; 0 0 -1])
    ]
    @test vcat(els1...) == els2

    G = FiniteGroup([
        1  2  3  4  5  6  7  8;
        2  1  4  3  6  5  8  7;
        3  4  2  1  7  8  6  5;
        4  3  1  2  8  7  5  6;
        5  6  7  8  1  2  3  4;
        6  5  8  7  2  1  4  3;
        7  8  6  5  3  4  2  1;
        8  7  5  6  4  3  1  2
    ])
    @test !isnothing(group_isomorphism(group(symp), G))

    sym3 = MatrixSymmetry([ones(Int, (1,1)), -ones(Int, (1,1))])

    sym4 = cross(symp, sym3, sym3)
    @test size(sym4) == (8, 2, 2)
    @test length(sym4) == 32

    # test order of elements of sym4
    @test collect(sym4) == [DirectProductOperation(x,y,z) for z in sym3 for y in sym3 for x in symp]
end
