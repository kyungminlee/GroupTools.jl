using Test
using GroupTools

@testset "symmetryoperation" begin
    iden = IdentityOperation()

    @testset "IdentityOperation" begin
        @test iden * iden == iden
        n=0;  @test iden^n == iden
        n=4;  @test iden^n == iden
        n=-3; @test iden^n == iden
        @test inv(iden) == iden
        @test isidentity(iden)

        @test apply_operation(iden, [3,2]) == [3,2]
        @test iden([3,2]) == [3,2]
    end
end
