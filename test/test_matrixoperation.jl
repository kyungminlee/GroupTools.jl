using Test
using GroupTools

@testset "MatrixOperation" begin
    @test_throws DimensionMismatch MatrixOperation{2, Int}([1 2 3; 4 5 6])
    @test_throws DimensionMismatch MatrixOperation{2, Int}([1 2 3; 4 5 6; 7 8 9])    
    @test_throws DimensionMismatch MatrixOperation{Int}([1 2 3; 4 5 6])
    @test_throws DimensionMismatch MatrixOperation([1 2 3; 4 5 6])
    @test_throws DomainError MatrixOperation{1, Int}(0)
    @test_throws DomainError MatrixOperation{Int}(0)
    @test_throws DomainError MatrixOperation(0)

    @test_throws InexactError MatrixOperation{2, Int}([0.1 0.2; 0.3 0.4])
    @test_throws InexactError MatrixOperation{Int}([0.1 0.2; 0.3 0.4])
    
    m = MatrixOperation([0 1; 1 0])
    i = MatrixOperation([1 0; 0 1])
    @test one(m) == MatrixOperation([1 0; 0 1])
    @test one(MatrixOperation{2, Int}) == MatrixOperation([1 0; 0 1])
    @test isone(MatrixOperation([1 0; 0 1]))
    @test isidentity(MatrixOperation([1 0; 0 1]))
    
    m2 = MatrixOperation([0 1; 1 0])
    @test hash(m) == hash(m2)
    @test hash(m) != hash(i)

    let isy = MatrixOperation([0 -1; 1 0]) 
        @test inv(isy) == MatrixOperation(-isy.matrix)
        @test conj(isy) == isy
        @test transpose(isy) == MatrixOperation(-isy.matrix)
        @test adjoint(isy) == MatrixOperation(-isy.matrix)
    end
    let sy = MatrixOperation([0 -im; im 0])
        @test inv(sy) == sy
        @test conj(sy) == MatrixOperation(-sy.matrix)
        @test transpose(sy) == MatrixOperation(-sy.matrix)
        @test adjoint(sy) == sy
    end
    let x = MatrixOperation([1.0 2.0; 3.0 4.0]),
        y = MatrixOperation([10.0 100.0; 1000.0 10000.0])
        @test x * y == MatrixOperation(x.matrix * y.matrix)
        @test x * 2.3 == MatrixOperation(x.matrix * 2.3)
        @test 2.3 * x == MatrixOperation(2.3 * x.matrix)
        @test x^3 == MatrixOperation(x.matrix^3)
        @test x([1.0; 10.0]) == [1.0 2.0; 3.0 4.0] * [1.0; 10.0]
    end
end