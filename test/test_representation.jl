using Test
using GroupTools

@testset "FiniteGroupRepresentation" begin
    # C₃ (or Z₃)
    group_z3 = FiniteGroup([
        1 2 3;
        2 3 1;
        3 1 2
    ])
    rep0 = FiniteGroupRepresentation(group_z3, [1.0, 1.0, 1.0])
    rep1 = FiniteGroupRepresentation(group_z3, [1.0, cis(2π/3), cis(4π/3)])
    rep2 = FiniteGroupRepresentation(group_z3, [1.0, cis(4π/3), cis(2π/3)])
    # We can construct rep3 even though it is not irreducible
    rep3 = FiniteGroupRepresentation(
        group_z3,
        [[1 0; 0 1] for θ in [0, 2π/3, 4π/3]]
    )
    rep4 = FiniteGroupRepresentation(
        group_z3,
        [[cos(θ) sin(θ); -sin(θ) cos(θ)] for θ in [0, 2π/3, 4π/3]]
    )
    @test_throws ArgumentError FiniteGroupRepresentation(group_z3, [1.0, 0.5, 1.0])
    @test_throws ArgumentError FiniteGroupRepresentation(group_z3, [1.0, cis(2π/3), cis(2π/3)])
    @test_throws ArgumentError FiniteGroupRepresentation(
        group_z3,
        [[cos(θ) sin(θ); sin(θ) cos(θ)] for θ in [0, 2π/3, 4π/3]]
    )

    @test dimension(rep0) == 1
    @test dimension(rep1) == 1
    @test dimension(rep2) == 1
    @test dimension(rep3) == 2

    @test ismonomial(rep0)
    @test ismonomial(rep1)
    @test ismonomial(rep2)
    @test ismonomial(rep3)
    @test !ismonomial(rep4)            

    @test [x[1] for x in get_irrep_iterator(rep0, 1)] == [1, 2, 3]
    @test [x[1] for x in get_irrep_iterator(rep3, 1)] == [1, 2, 3]
    @test [x[1] for x in get_irrep_iterator(rep3, 2)] == [1, 2, 3]

    @test [x[2] for x in get_irrep_iterator(rep0, 1)] ≈ [1.0, 1.0, 1.0]
    @test [x[2] for x in get_irrep_iterator(rep1, 1)] ≈ [1.0, cis(2π/3), cis(4π/3)]
    @test [x[2] for x in get_irrep_iterator(rep2, 1)] ≈ [1.0, cis(4π/3), cis(2π/3)]
    @test [x[2] for x in get_irrep_iterator(rep4, 1)] ≈ [1.0, cos(2π/3), cos(2π/3)]
    @test [x[2] for x in get_irrep_iterator(rep4, 2)] ≈ [1.0, cos(2π/3), cos(2π/3)]

    @test_throws BoundsError collect(get_irrep_iterator(rep0, 2))
end

@testset "Irrep" begin
    # C₃ (or Z₃)
    op1 = MatrixOperation{Float64}([
        1 0 0;
        0 1 0;
        0 0 1])
    op2 = MatrixOperation{Float64}([
        cos(2π/3) -sin(2π/3) 0;
        sin(2π/3)  cos(2π/3) 0;
                0          0 1])
    op3 = op2^2
    symmetry_c3 = MatrixSymmetry([op1, op2, op3])
    rep0 = SymmetryRepresentation(symmetry_c3, [1.0, 1.0, 1.0])
    rep1 = SymmetryRepresentation(symmetry_c3, [1.0, cis(2π/3), cis(4π/3)])
    rep2 = SymmetryRepresentation(symmetry_c3, [1.0, cis(4π/3), cis(2π/3)])
    # We can construct rep3 even though it is not irreducible
    rep3 = SymmetryRepresentation(
        symmetry_c3,
        [[1 0; 0 1] for θ in [0, 2π/3, 4π/3]]
    )
    rep4 = SymmetryRepresentation(
        symmetry_c3,
        [[cos(θ) sin(θ); -sin(θ) cos(θ)] for θ in [0, 2π/3, 4π/3]]
    )
    @test_throws ArgumentError SymmetryRepresentation(symmetry_c3, [1.0, 0.5, 1.0])
    @test_throws ArgumentError SymmetryRepresentation(symmetry_c3, [1.0, cis(2π/3), cis(2π/3)])
    @test_throws ArgumentError SymmetryRepresentation(
        symmetry_c3,
        [[cos(θ) sin(θ); sin(θ) cos(θ)] for θ in [0, 2π/3, 4π/3]]
    )

    @test dimension(rep0) == 1
    @test dimension(rep1) == 1
    @test dimension(rep2) == 1
    @test dimension(rep3) == 2

    @test ismonomial(rep0)
    @test ismonomial(rep1)
    @test ismonomial(rep2)
    @test ismonomial(rep3)
    @test !ismonomial(rep4)            

    # @test [x[1] for x in get_irrep_iterator(rep0, 1)] == [1, 2, 3]
    # @test [x[1] for x in get_irrep_iterator(rep3, 1)] == [1, 2, 3]
    # @test [x[1] for x in get_irrep_iterator(rep3, 2)] == [1, 2, 3]

    @test [x[2] for x in get_irrep_iterator(rep0, 1)] ≈ [1.0, 1.0, 1.0]
    @test [x[2] for x in get_irrep_iterator(rep1, 1)] ≈ [1.0, cis(2π/3), cis(4π/3)]
    @test [x[2] for x in get_irrep_iterator(rep2, 1)] ≈ [1.0, cis(4π/3), cis(2π/3)]
    @test [x[2] for x in get_irrep_iterator(rep4, 1)] ≈ [1.0, cos(2π/3), cos(2π/3)]
    @test [x[2] for x in get_irrep_iterator(rep4, 2)] ≈ [1.0, cos(2π/3), cos(2π/3)]

    @test_throws BoundsError collect(get_irrep_iterator(rep0, 2))
end