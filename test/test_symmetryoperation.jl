using Test
using LinearAlgebra
using GroupTools

@testset "symmetryoperation" begin
    iden = IdentityOperation()

    @testset "IdentityOperation" begin
        @test iden == IdentityOperation()
        @test isapprox(iden, IdentityOperation())
        @test iden * iden == iden
        n=0;  @test iden^n == iden
        n=4;  @test iden^n == iden
        n=-3; @test iden^n == iden
        @test inv(iden) == iden
        @test isidentity(iden)

        @test apply_operation(iden, [3,2]) == [3,2]
        @test iden([3,2]) == [3,2]

        col = collect(iden)
        @test length(col) == 1
        @test size(col) == ()
        @test eltype(iden) == typeof(iden)
    end

    @testset "MatrixOperation" begin
        @testset "Constructor" begin
            u0 = MatrixOperation([1 0; 0 1])
            u1 = MatrixOperation{2, Int}([1 0; 0 1])
            u2 = MatrixOperation{Int}([1 0; 0 1])
            @test u0 == u1
            @test u1 == u2

            v0 = MatrixOperation([0.0 1.0; 1.0 0.0])
            v1 = MatrixOperation{2, Float64}([0 1; 1 0])
            v2 = MatrixOperation{Float64}([0 1; 1 0])
            @test v0 == v1
            @test v1 == v2

            col = collect(u0)
            @test length(u0) == 1
            @test size(u0) == ()
            @test eltype(u0) == typeof(u0)

            @test typeof(one(v1)) == MatrixOperation{2, Float64}
            @test one(v1) == MatrixOperation([1.0 0.0; 0.0 1.0])
            @test isone(one(v1))
            @test !isone(v1)
           
            @test typeof(one(MatrixOperation{2, Float64})) == MatrixOperation{2, Float64}
            @test one(MatrixOperation{2, Float64}) == MatrixOperation([1.0 0.0; 0.0 1.0])
        end

        @testset "integer" begin
            i0 = IdentityOperation()
            u0 = MatrixOperation([1 0; 0 1])
            u1 = MatrixOperation([0 -1; 1 -1]) # C3 rotation
            @test isidentity(u0)
            @test !isidentity(u1)
            @test inv(u0) == u0

            @test u0 * u1 == u1
            @test u1 * u0 == u1
            @test u1 * u1 != u0
            @test u1 * u1 * u1 == u0
            @test u1^2 == u1 * u1
            let n = -1  # Julia statically converts negative literals to inv and positive
                @test u1^n == u1 * u1
                n = -2
                @test u1^n == u1
            end
            @test inv(u1) == u1 * u1

            @test u1 * i0 == u1
            @test i0 * u1 == u1

            @test isidentity(u1^3)

            @test u1 * 2 == MatrixOperation([0 -2; 2 -2])
            @test 2 * u1 == MatrixOperation([0 -2; 2 -2])
        end

        @testset "complex" begin
            u1 = MatrixOperation([cis(2π/3) 0; 0 cis(2π/3)])
            @test isapprox(inv(u1), MatrixOperation([cis(-2π/3) 0; 0 cis(-2π/3)]))
            @test isapprox(u1, MatrixOperation{2, ComplexF64}(cis(2π/3)))

            u = MatrixOperation(cis(2π/3))
            @test isapprox(inv(u), MatrixOperation{ComplexF64}(cis(-2π/3)))
            @test isapprox(inv(u), MatrixOperation{1, ComplexF64}(cis(-2π/3)))

            u = MatrixOperation([1 im; 0 im])
            @test conj(u) == MatrixOperation([1 -im; 0 -im])
            @test transpose(u) == MatrixOperation([1 0; im im])
            @test adjoint(u) == MatrixOperation([1 0; -im -im])

            @test u * 2 == MatrixOperation([2 2im; 0 2im])
            @test 2 * u == MatrixOperation([2 2im; 0 2im])
            @test_throws InexactError u * 1.5
            @test_throws InexactError 1.5 * u
        end
    end
end
