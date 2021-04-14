using Test
using GroupTools

@testset "Permutation" begin
    @test_throws ArgumentError Permutation([1,2,2])
    @test_throws ArgumentError Permutation([1,2,4])
    @test_throws OverflowError Permutation([mod(x, 4096)+1 for x in 1:4096])
    p0 = Permutation([1,2,3,4])
    p1 = Permutation([2,3,4,1])
    p2 = Permutation([3,4,1,2])
    p3 = Permutation([4,1,2,3])

    @test p1 * p2 == p3
    @test p1 != p3
    @test p1^0 == p0
    @test p1^1 == p1
    @test p1^2 == p2
    @test p1^3 == p3

    @test p0.order == 1
    @test p1.order == 4
    @test p2.order == 2
    @test p3.order == 4

    @test inv(p0) == p0
    @test inv(p1) == p3
    @test inv(p2) == p2
    @test inv(p3) == p1

    @test p0 == Permutation([1,2,3,4])
    @test isless(p0, p1)
    @test isless(p1, p3)

    @test isidentity(p0)
    @test !isidentity(p1)
    @test !isidentity(p2)
    @test !isidentity(p3)

    @test p0(1) == 1 && p0(2) == 2 && p0(3) == 3 && p0(4) == 4
    @test p1(1) == 2 && p1(2) == 3 && p1(3) == 4 && p1(4) == 1

    @test_throws ArgumentError p1([1,2])
    @test_throws ArgumentError p1([1,2,3,4,5])
    
    v = [10, 20, 30, 40]
    @test p1(v) == [40, 10, 20, 30]  # act on column vector. (map from right to left)
    p5 = Permutation([2,1,4,3])
    @test p5(v) == [20, 10, 40, 30]
    @test p1(p5(v)) == (p1*p5)(v)
    @test p5(p1(v)) == (p5*p1)(v)

    @test_throws ArgumentError Permutation([1,2,3,4]) * Permutation([1,2,3,4,5])
    @test hash(Permutation(Int[1,2,3,4])) != hash(Int[1,2,3,4])

    @test generate_group(p1) == Set([p0, p1, p2, p3])
    @test generate_group(p2) == Set([p0, p2])
    @test generate_group(p1, p2) == Set([p0, p1, p2, p3])
end

@testset "GeneralizedPermutation" begin
    @testset "Constructors" begin
        gp1 = GeneralizedPermutation([2=>Phase(0//1), 3=>Phase(1//4), 1=>Phase(2//4), 4=>Phase(3//4)])
        gp2 = GeneralizedPermutation([2, 3, 1, 4], Phase.([0//1, 1//4, 2//4, 3//4]))
        gp3 = GeneralizedPermutation([2, 3, 1, 4], Phase.([0//1, 0//1, 0//1, 0//1]))
        gp4 = GeneralizedPermutation([2, 3, 1, 4], Phase.([0, 0, 0, 0]))
        @test gp1 == gp2
        @test gp3 == gp4
        @test gp1 != gp3 && gp2 != gp3 && gp1 != gp4 && gp2 != gp4

        @test gp1.order == 12
        @test gp3.order == 3
    end

    @testset "Matrix and vector application" begin
        gp1 = GeneralizedPermutation([2=>Phase(0//1), 3=>Phase(1//4), 1=>Phase(2//4), 4=>Phase(3//4)])
        m_gp1 = Matrix(gp1)
        @test typeof(m_gp1) == Matrix{ComplexF64}
        m = [
            0  0   -1   0;
            1  0    0   0;
            0  im   0   0;
            0  0    0 -im;
        ]
        @test isapprox(m_gp1, m)

        vec = [1E0 + 1E1im, 1E2 + 1E3im, 1E4 + 1E5im, 1E5 + 1E6im]
        @test isapprox(gp1(vec), m * vec)

        @test gp1(2, 5.0) == (3, 5.0im)
        @show typeof(gp1(1, 5.0))        
    end

    @testset "product and inverse and conjugate" begin
        gp1 = GeneralizedPermutation([2=>Phase(0//1), 3=>Phase(1//4), 1=>Phase(2//4), 4=>Phase(3//4)])
        gp2 = GeneralizedPermutation([2=>Phase(0//1), 1=>Phase(1//7), 4=>Phase(2//7), 3=>Phase(3//7)])
        m_gp1 = Matrix(gp1)
        m_gp2 = Matrix(gp2)
        m_gp3 = Matrix(gp1 * gp2)
        gp3_m = m_gp1 * m_gp2
        @test isapprox(m_gp3, gp3_m)

        gp4 = GeneralizedPermutation([4=>Phase(5//6), 1=>Phase(1//6), 3=>Phase(2//6), 2=>Phase(3//6)])
    
        @test (gp1 * gp2) * gp4 == gp1 * (gp2 * gp4)

        @test isidentity(gp1 * inv(gp1))
        @test isidentity(inv(gp1) * gp1)

        @test conj(gp1) == GeneralizedPermutation([2=>Phase(0//1), 3=>Phase(3//4), 1=>Phase(2//4), 4=>Phase(1//4)])
    end

    @testset "hash" begin
        gp1  = GeneralizedPermutation([2=>Phase(0//1), 3=>Phase(1//4), 1=>Phase(2//4), 4=>Phase(3//4)])
        gp1p = GeneralizedPermutation([2=>Phase(0//1), 3=>Phase(1//4), 1=>Phase(2//4), 4=>Phase(3//4)])
        gp2  = GeneralizedPermutation([2=>Phase(0//1), 3=>Phase(0//1), 1=>Phase(0//1), 4=>Phase(0//1)])
        gp3  = GeneralizedPermutation([1=>Phase(0//1), 2=>Phase(1//4), 3=>Phase(2//4), 4=>Phase(3//4)])
        
        @test gp1 == gp1p && hash(gp1) == hash(gp1p)
        @test gp1 != gp2 && hash(gp1) != hash(gp2)
        @test gp1 != gp3 && hash(gp1) != hash(gp3)
    end
end