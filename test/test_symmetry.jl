using Test
using LinearAlgebra
using GroupTools

@testset "MatrixSymmetry" begin
    @testset "Int" begin
        # C4 group (Abelian)
        sym1 = MatrixSymmetry([[1 0; 0 1], [-1 0; 0 -1], [0 -1; 1 0], [0 1; -1 0]])
        @testset "constructor" begin
            sym1p = MatrixSymmetry(
                MatrixOperation.([[1 0; 0 1], [-1 0; 0 -1], [0 -1; 1 0], [0 1; -1 0]])
            )
            @test sym1 == sym1p
        end
        @testset "type traits" begin
            @test eltype(sym1) <: MatrixOperation{2, Int}
            @test eltype(typeof(sym1)) <: MatrixOperation{2, Int}
            @test valtype(sym1) <: MatrixOperation{2, Int}
            @test valtype(typeof(sym1)) <: MatrixOperation{2, Int}
            sym2 = MatrixSymmetry([[1.0 0.0; 0 1], [-1 0; 0 -1], [0.0 -1.0; 1.0 0.0], [0 1; -1 0]])
            @test eltype(sym2) <: MatrixOperation{2, Float64}
        end
        @testset "iterator properties" begin
            S = sym1
            @test Base.IteratorSize(S) == Base.HasShape{1}()
            @test length(S) == 4
            @test size(S) == (4,)
            @test keys(S) == 1:4
            @test collect(S) == MatrixOperation.([[1 0; 0 1], [-1 0; 0 -1], [0 -1; 1 0], [0 1; -1 0]])
            @test S[3] == MatrixOperation([0 -1; 1 0])
            @test_throws BoundsError S[10]
            @test S[2:end] == MatrixOperation.([[-1 0; 0 -1], [0 -1; 1 0], [0 1; -1 0]])
            @test S[:] == MatrixOperation.([[1 0; 0 1], [-1 0; 0 -1], [0 -1; 1 0], [0 1; -1 0]])
            @test first(S) == MatrixOperation([1 0; 0 1])
            @test last(S) == MatrixOperation([0 1; -1 0])
            @test firstindex(S) == 1
            @test lastindex(S) == 4
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

    @testset "Float64" begin
        sym1 = MatrixSymmetry([[1.0 0; 0 1], [-1 0; 0 -1], [0 -1; 1 0], [0 1; -1 0]])
        @testset "constructor" begin
            sym1p = MatrixSymmetry(
                MatrixOperation.([[1.0 0; 0 1], [-1 0; 0 -1], [0 -1; 1 0], [0 1; -1 0]])
            )
            @test sym1 == sym1p
        end
        @testset "type traits" begin
            @test eltype(sym1) <: MatrixOperation{2, Float64}
            @test eltype(typeof(sym1)) <: MatrixOperation{2, Float64}
            @test valtype(sym1) <: MatrixOperation{2, Float64}
            @test valtype(typeof(sym1)) <: MatrixOperation{2, Float64}
        end
    end

    @testset "ComplexF64" begin
        sym1 = MatrixSymmetry([[1.0+0im 0; 0 1], [-1 0; 0 -1], [0 -1; 1 0], [0 1; -1 0]])
        @testset "constructor" begin
            sym1p = MatrixSymmetry(
                MatrixOperation.([[1.0 0; 0 1], [-1 0; 0 -1], [0 -1; 1 0], [0 1; -1 0]])
            )
            @test sym1 != sym1p  # RHS float

            # the elements are different...
            sym1p = MatrixSymmetry(
                MatrixOperation.([[1.0+1E-12im 0.0; 0 1], [-1 0; 0 -1], [0 -1; 1 0], [0 1; -1 0]])
            )
            @test sym1 != sym1p
        end
        @testset "type traits" begin
            @test eltype(sym1) <: MatrixOperation{2, ComplexF64}
            @test eltype(typeof(sym1)) <: MatrixOperation{2, ComplexF64}
            @test valtype(sym1) <: MatrixOperation{2, ComplexF64}
            @test valtype(typeof(sym1)) <: MatrixOperation{2, ComplexF64}
        end
    end
end # @testset "MatrixSymmetry"

@testset "DirectProductSymmetry" begin
    sym1 = MatrixSymmetry([[1 0; 0 1], [-1 0; 0 -1], [0 -1; 1 0], [0 1; -1 0]])
    sym2 = MatrixSymmetry([[1 0; 0 1], [0 -1; 1 -1], [-1 1; -1 0]])
    sym3 = DirectProductSymmetry(sym1, sym2)

    @testset "type traits" begin
        E = DirectProductOperation{Tuple{MatrixOperation{2, Int}, MatrixOperation{2, Int}}}
        @test eltype(sym3) == E
        @test eltype(typeof(sym3)) == E
        @test valtype(sym3) == E
        @test valtype(typeof(sym3)) == E
    end

    @testset "equality" begin
        sym1p = MatrixSymmetry([[1 0; 0 1], [-1 0; 0 -1], [0 -1; 1 0], [0 1; -1 0]])
        sym2p = MatrixSymmetry([[1 0; 0 1], [0 -1; 1 -1], [-1 1; -1 0]])
        @test sym3 == DirectProductSymmetry(sym1, sym2)
        @test sym3 != DirectProductSymmetry(sym2, sym1)
    end

    @testset "iterator" begin
        @test Base.IteratorSize(sym3) == Base.HasShape{2}()

        @test length(sym3) == 12
        @test size(sym3) == (4, 3)
        @test firstindex(sym3) == 1
        @test lastindex(sym3) == 12

        sym3_collect1 = [sym3[i] for i in 1:length(sym3)]
        sym3_collect2 = [sym3[i] for i in eachindex(sym3)]
        sym3_collect3 = elements(sym3)

        @test sym3_collect1 != sym3_collect2
        @test collect(Iterators.flatten(sym3_collect1)) == collect(Iterators.flatten(sym3_collect2))
        @test sym3_collect2 == sym3_collect3

        @test size([x for x in sym3]) == (4, 3)
        for i in 1:4, j in 1:3
            @test sym3[i, j] == DirectProductOperation(sym1[i], sym2[j])
        end
        @test sym3[2:4] == sym3_collect1[2:4]
    end

    @testset "4×Z₂" begin
        sym_c4 = MatrixSymmetry([
            [1 0 0; 0 1 0; 0 0 1],
            [0 -1 0; 1 0 0; 0 0 1],
            [-1 0 0; 0 -1 0; 0 0 1],
            [0 1 0; -1 0 0; 0 0 1]
        ])
        sym_z2 = MatrixSymmetry([
            ones(Int, (1,1)),
            -ones(Int, (1,1)),
        ])
        sym = sym_c4 × sym_z2
        G = FiniteGroup([
            1  2  3  4  5  6  7  8;
            2  3  4  1  6  7  8  5;
            3  4  1  2  7  8  5  6;
            4  1  2  3  8  5  6  7;
            5  6  7  8  1  2  3  4;
            6  7  8  5  2  3  4  1;
            7  8  5  6  3  4  1  2;
            8  5  6  7  4  1  2  3
        ])
        @test !isnothing(group_isomorphism(group(sym), G))
    end
end # @testset "DirectProductSymmetry"

@testset "SemidirectProductSymmetry" begin
    @testset "4/m" begin
        # 4/m (C₄ₕ) = 4 ⋊ -1
        sym1 = MatrixSymmetry([
            [1 0 0; 0 1 0; 0 0 1],
            [0 -1 0; 1 0 0; 0 0 1],
            [-1 0 0; 0 -1 0; 0 0 1],
            [0 1 0; -1 0 0; 0 0 1],
        ])
        sym2 = MatrixSymmetry([
            [1 0 0; 0 1 0; 0 0 1],
            [-1 0 0; 0 -1 0; 0 0 -1],
        ])
        symp = sym1 ⋊ sym2

        @testset "type traits" begin
            @test eltype(symp) == MatrixOperation{3, Int}
            @test eltype(typeof(symp)) == MatrixOperation{3, Int}
            @test valtype(symp) == MatrixOperation{3, Int}
            @test valtype(typeof(symp)) == MatrixOperation{3, Int}
        end

        @testset "iterator" begin
            @test Base.IteratorSize(symp) == Base.HasShape{2}()
            @test size(symp) == (4,2)
            @test length(symp) == 8
            @test firstindex(symp) == 1
            @test lastindex(symp) == 8
            @test symp[2] == MatrixOperation([0 -1 0; 1 0 0; 0 0 1])
            @test symp[4:5] == MatrixOperation.([[0 1 0; -1 0 0; 0 0 1], [-1 0 0; 0 -1 0; 0 0 -1]])
            @test symp[3,2] == sym1[3] * sym2[2]

            @test_throws BoundsError symp[100]
            @test_throws BoundsError symp[-1]
            @test_throws BoundsError symp[0]

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
            @test elements(symp) == els1
        end

        @testset "equality" begin
            sym1p = MatrixSymmetry([
                [1 0 0; 0 1 0; 0 0 1],
                [0 -1 0; 1 0 0; 0 0 1],
                [-1 0 0; 0 -1 0; 0 0 1],
                [0 1 0; -1 0 0; 0 0 1]
            ])
            sym2p = MatrixSymmetry([
                [1 0 0; 0 1 0; 0 0 1],
                [-1 0 0; 0 -1 0; 0 0 -1],
            ])
            sympp = sym1p ⋊ sym2p
            @test sym1 == sym1p
            @test sym2 == sym2p
            @test symp == sympp
        end

        @testset "composition" begin
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
    end

    @testset "3m1" begin
        sym_c3 = MatrixSymmetry([
            [ 1  0;  0  1],
            [ 0 -1;  1 -1],
            [-1  1; -1  0],
        ])
        sym_m = MatrixSymmetry([
            [ 1  0;  0  1],
            [ 0 -1; -1  0]
        ])
        sym_3m1 = sym_c3 ⋊ sym_m
        @test_throws ArgumentError sym_m ⋊ sym_c3
        sym_z2 = MatrixSymmetry([ones(Int, (1,1)), -ones(Int, (1,1))])

        sym = cross(sym_3m1, sym_z2)
        @test size(sym) == (6, 2)
        @test length(sym) == 12

        @test vcat(collect(sym_3m1)...) == MatrixOperation.([
            [1 0; 0 1],
            [0 -1; 1 -1],
            [-1 1; -1 0],
            [0 -1; -1 0],
            [1 0; 1 -1],
            [-1 1; 0 1],
        ])
    end
end # @ testset "SemidirectProductSymmetry"
