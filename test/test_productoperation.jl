using Test
using LinearAlgebra
using GroupTools

@testset "direct-product" begin

    @testset "construction" begin
        u0 = MatrixOperation([1.0 0.0; 0.0 1.0])
        u1 = MatrixOperation{ComplexF64}([0.0 1.0; 1.0 0.0])
        @test isa(u0 ×ˢ u1, DirectProductOperation)
        @test isa(directproduct(u0, u1), DirectProductOperation)
        @test u0 ×ˢ u1 == directproduct(u0, u1)
        @test isa(u1 * (-1), MatrixOperation)
        @test isa(u1 * 1, MatrixOperation)
        @test isa(u1 * cis(π/4), MatrixOperation)
        @test_throws InexactError u0 * cis(π/4)
        u1 * 0.5
    end

    @testset "directproduct-array" begin
        u0 = MatrixOperation([1.0 0.0; 0.0 1.0])
        u1 = MatrixOperation([cospi(1/3) sinpi(1/3); -sinpi(1/3) cospi(1/3)])
        f0 = Phase(0//1)
        f1 = Phase(1//3)
        @test directproduct([u0, u1], [f0, f1]) == [ u0 ×ˢ f0 u0 ×ˢ f1; u1 ×ˢ f0 u1 ×ˢ f1]
        @test [u0, u1] ×ˢ [f0, f1] == [ u0 ×ˢ f0 u0 ×ˢ f1; u1 ×ˢ f0 u1 ×ˢ f1]
    end

    @testset "equality" begin
        u0 = MatrixOperation([1 0; 0 1])
        u1 = MatrixOperation([0 1; 1 0])
        p = u0 ×ˢ u1
        p2 = MatrixOperation([1 0; 0 1]) ×ˢ MatrixOperation([0 1; 1 0])
        p3 = MatrixOperation([0 1; 1 0]) ×ˢ MatrixOperation([1 0; 0 1])
        @test p == p2
        @test p != p3
        p2p = MatrixOperation([1 0; 0 1]) ×ˢ MatrixOperation([0 1; 1 0])
        @test p2 == p2p
        @test p2 !== p2p
        @test hash(p2) == hash(p2p)
    end

    @testset "iterator" begin
        p2 = MatrixOperation([1 0; 0 1]) ×ˢ MatrixOperation([0 1; 1 0])
        p2c = collect(p2)
        @test length(p2c) == 1
        @test size(p2c) == ()
        @test Base.IteratorSize(p2c) == Base.HasShape{0}()
        @test p2c[1] == p2
        @test p2c[1] === p2  # exactly that object
    end

    @testset "times" begin
        u1 = MatrixOperation([cospi(1/3) sinpi(1/3); -sinpi(1/3) cospi(1/3)])
        u2 = MatrixOperation(exp(0.25*pi*im))
        p = u1 ×ˢ u2
        @test p*p*p == p^3
        p3 = MatrixOperation([-1.0 0.0; 0.0 -1.0]) ×ˢ MatrixOperation(exp(0.75*pi*im))
        @test isapprox(p*p*p, p3)

        u3 = MatrixOperation([0 1 0; 0 0 1; 1 0 0])
        u4 = IdentityOperation()
        @test (u1 ×ˢ u2) ×ˢ u3 == u1 ×ˢ (u2 ×ˢ u3)
        @test u1 ×ˢ u2 ×ˢ u3 ×ˢ u4 == u1 ×ˢ (u2 ×ˢ u3) ×ˢ u4 == (u1 ×ˢ u2) ×ˢ (u3 ×ˢ u4)

        @test directproduct(directproduct(directproduct(u1, u2), u3), u4) == 
              directproduct(directproduct(u1, u2), directproduct(u3, u4)) ==
              directproduct(directproduct(u1, directproduct(u2, u3)), u4)
    end

    @testset "isidentity" begin
        u0 = MatrixOperation([1 0; 0 1])
        u1 = MatrixOperation([0 1; 1 0])
        p = u0 ×ˢ u1
        @test !isidentity(p)
        @test isidentity(p*p)
        @test isidentity(p^2)
        @test isidentity(p^-2)
        @test !isidentity(p^3)
        @test !isidentity(p^-3)
        @test isidentity(u0 ×ˢ u0)
    end

    @testset "one and isone" begin
        u0 = MatrixOperation([1 0; 0 1])
        u1 = MatrixOperation([0 1; 1 0])
        f1 = Phase(1//2)
        p = u0 ×ˢ f1
        @test !isone(p)
        @test isone(p*p)
        @test isone(p^2)
        @test isone(p^-2)
        @test !isone(p^3)
        @test !isone(p^-3)
        @test isone(one(p))
    end
end

# @testset "product" begin
#     r0 = ProductOperation()

#     t = TranslationOperation([2, 4])
#     p = PointOperation([0 -1; 1 -1])

#     rt = ProductOperation(t)
#     rp = ProductOperation{Int}(p)

#     @test r0 * t == rt
#     @test t * r0 == rt

#     tp = t * p
#     pt = p * t

#     tpc = canonize(tp)
#     ptc = canonize(pt)

#     @test tp^3 == t * p * t * p * t * p
#     @test tpc.factors[1] == ptc.factors[1]
#     @test isa(tpc.factors[1], PointOperation) && isa(tpc.factors[2], TranslationOperation)
#     @test isa(ptc.factors[1], PointOperation) && isa(ptc.factors[2], TranslationOperation)
#     @test apply_operation(tp, [5,0]) == apply_operation(tpc, [5,0])
#     @test apply_operation(pt, [5,0]) == apply_operation(ptc, [5,0])
#     @test tp([5,0]) == tpc([5,0])
#     @test pt([5,0]) == ptc([5,0])

#     @test tp^0 == ProductOperation()
#     @test tp^1 == tp
#     @test tp^2 == t * p * t * p
#     @test tp^(-2) == inv(p) * inv(t) * inv(p) * inv(t)

#     n = 0
#     @test tp^n == ProductOperation()
#     n = 1
#     @test tp^n == tp
#     n = 2
#     @test tp^n == t * p * t * p
#     n = -2
#     @test tp^n == inv(p) * inv(t) * inv(p) * inv(t)


#     @test canonize(tp^3 * inv(tp^3)) == IdentityOperation()
#     @test iscanonical(pt)
#     @test !iscanonical(tp)
#     @test iscanonical(tpc)
#     @test iscanonical(ptc)

#     pp = ProductOperation(p, p)
#     @test pp != p * p
#     @test canonize(pp) == p*p

#     @test domaintype(pp) == Int
#     @test dimension(pp) == 2
# end
