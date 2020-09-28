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
        end

        @testset "integer" begin
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
            @test u1^(-1) == u1 * u1
            @test inv(u1) == u1 * u1

            @test isidentity(u1^3)
        end

        @testset "complex" begin
            u1 = MatrixOperation([cis(2π/3) 0; 0 1])
            @test isapprox(inv(u1), MatrixOperation([cis(-2π/3) 0; 0 1]))
        end
    end
end
