using Test
using GroupTools
using LinearAlgebra



@testset "SemidirectProductOperation" begin
    p = Permutation([2,3,4,1])
    m = MatrixOperation([
        cis(0) 0 0 0;
        0 cis(0.1) 0 0;
        0 0 cis(0.2) 0;
        0 0 0 cis(0.3)
    ])

    q = Permutation([1,4,2,3])
    n = MatrixOperation([
        cis(0.4) 0 0 0;
        0 cis(0.5) 0 0;
        0 0 cis(0.6) 0;
        0 0 0 cis(0.7)
    ])

    pm = SemidirectProductOperation(p, m)
    qn = SemidirectProductOperation(q, n)

    @testset "equality" begin
        p2 = Permutation([2,3,4,1])
        m2 = MatrixOperation([
            cis(0) 0 0 0;
            0 cis(0.1) 0 0;
            0 0 cis(0.2) 0;
            0 0 0 cis(0.3)
        ])
        m3 = MatrixOperation([
            cis(0) 0 0 0;
            0 cis(0.1) 0 0;
            0 0 cis(0.2) 0;
            0 0 0 cis(1)
        ])
        @test pm == SemidirectProductOperation(p2, m2)
        @test pm != SemidirectProductOperation(p2, m3)
        @test hash(pm) == hash(SemidirectProductOperation(p2, m2))
        @test hash(pm) != hash(SemidirectProductOperation(p2, m3))
    end

    @testset "Matrix" begin
        @test Matrix(pm) == Matrix(p) * Matrix(m)
        @test Matrix{ComplexF64}(pm) == Matrix{ComplexF64}(p) * Matrix{ComplexF64}(m)
        @test_throws InexactError Matrix{Float64}(pm) # m cannot be converted to real
    end

    # (PM)⁻¹ = M⁻¹ P⁻¹
    @testset "inv" begin
        ipm = inv(pm)
        iqn = inv(qn)

        @test isapprox( Matrix(ipm.rest) * Matrix(ipm.normal), inv( Matrix(pm.rest) * Matrix(pm.normal)) )
        @test isapprox( Matrix(iqn.rest) * Matrix(iqn.normal), inv( Matrix(qn.rest) * Matrix(qn.normal)) )

        x = pm * ipm
        @test isone(x.rest)
        @test isapprox(x.normal.matrix, LinearAlgebra.I)

        x = ipm * pm
        @test isone(x.rest)
        @test isapprox(x.normal.matrix, LinearAlgebra.I)

        x = qn * iqn
        @test isone(x.rest)
        @test isapprox(x.normal.matrix, LinearAlgebra.I)

        x = iqn * qn
        @test isone(x.rest)
        @test isapprox(x.normal.matrix, LinearAlgebra.I)

        pmqn = pm * qn
        @test Matrix(pmqn) == Matrix(p) * Matrix(m) * Matrix(q) * Matrix(n)
    end
end