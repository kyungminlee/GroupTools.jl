using Test
using GroupTools

@testset "Phase" begin
    @test Phase(0) == Phase(1)
    @test Phase(0) == Phase(1//1)
    @test typeof(Phase(0)) != typeof(Phase(1//1))
    
    p1 = Phase(3//7)
    p2 = Phase(0.3)
    let arr = [p1, p2]
        @test eltype(arr) == Phase{Float64}
        @test arr[1] == Phase(3/7)
    end
    p3 = Phase(1//7)

    @test p1 * p1 == Phase(6//7)
    @test p1 * p1 * p1 == Phase(2//7)
    @test p1 / p3 == Phase(2//7)
    @test p1^4 == Phase(12//7) == Phase(5//7)
    @test inv(p1) == Phase(-3//7) == Phase(4//7)

    @test isapprox(real(p1), cos(2π*3/7))
    @test isapprox(imag(p1), sin(2π*3/7))
    @test isapprox(angle(p1), angle(cis(2π*3/7)))
    @test isapprox(angle(p1*p1), angle(cis(-2π*1/7)))

    @test typeof(convert(ComplexF64, p1)) == ComplexF64
    @test isapprox(convert(ComplexF64, p1), cis(2π*3/7))
    @test isapprox(convert(ComplexF64, p1*p1), cis(-2π*1/7))
    @test_throws InexactError convert(Float64, p1)
    @test_throws InexactError convert(Int, p1)
    @test_throws InexactError convert(Complex{Int}, p1)

    p4 = Phase(1//2)
    @test typeof(convert(Int, p4)) == Int
    @test typeof(convert(Complex{Int}, p4)) == Complex{Int}
    @test typeof(convert(Float64, p4)) == Float64
    @test convert(Int, p4) == -1
    @test convert(Complex{Int}, p4) ==  -1 + 0im
    @test isapprox(convert(Float64, p4), -1.0)


    p0 = Phase(0)
    @test convert(Int, p0) == 1
    @test convert(Complex{Int}, p0) == 1 + 0im
    @test convert(Float64, p0) == 1.0
    @test convert(ComplexF64, p0) == 1.0 + 0.0im

end