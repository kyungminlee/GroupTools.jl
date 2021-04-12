using Test
using GroupTools

using Combinatorics
using LinearAlgebra

@testset "Group" begin
    @testset "Exceptions" begin
        @test_throws ArgumentError FiniteGroup([1 1; 1 2])
        @test_throws ArgumentError FiniteGroup([1 2 3; 2 1 1; 3 1 1])
        @test_throws ArgumentError FiniteGroup([2 3; 3 2])

        # Right Bol Loop 8.1.4.0 of order 8
        # http://ericmoorhouse.org/pub/bol/htmlfiles8/8_1_4_0.html
        @test_throws ArgumentError FiniteGroup([
            1 2 3 4 5 6 7 8;
            2 8 6 1 7 3 5 4;
            3 7 8 6 1 4 2 5;
            4 1 7 8 6 5 3 2;
            5 6 1 7 8 2 4 3;
            6 3 4 5 2 8 1 7;
            7 5 2 3 4 1 8 6;
            8 4 5 2 3 7 6 1;
        ])
    end

    @testset "iterator" begin
        G = FiniteGroup([
            1 2 3 4 5 6;
            2 3 1 6 4 5;
            3 1 2 5 6 4;
            4 5 6 1 2 3;
            5 6 4 3 1 2;
            6 4 5 2 3 1;
        ])
        @test eltype(G) == Int
        @test eltype(typeof(G)) == Int
        @test valtype(G) == Int
        @test valtype(typeof(G)) == Int
        @test length(G) == 6
        @test keys(G) == 1:6
        @test collect(G) == [1,2,3,4,5,6]
        @test G[3] == 3
        @test_throws BoundsError G[10]
        @test G[2:end] == 2:6
        @test G[:] == 1:6
        @test first(G) == 1
        @test last(G) == 6
        @test firstindex(G) == 1
        @test lastindex(G) == 6
    end

    @testset "FiniteGroup-Abelian" begin
        @test_throws ArgumentError FiniteGroup([1 1 1; 1 1 1])
        @test_throws ArgumentError FiniteGroup([1 1 1; 1 1 1; 1 1 1])

        # Example: Z₃
        mtab = [
            1 2 3;
            2 3 1;
            3 1 2;
        ]
        group = FiniteGroup(mtab)

        @test group_order(group) == 3
        @test group_order(group, 1) == 1
        @test group_order(group, 2) == 3
        @test group_order(group, 3) == 3
        @test group_order(group, [1,2,3]) == [1,3,3]
        @test period_length(group, 1) == 1
        @test period_length(group, 2) == 3
        @test period_length(group, 3) == 3
        @test period_length(group, [1,2,3]) == [1,3,3]
        @test isabelian(group)
        @test group_multiplication_table(group) == mtab
        @test element(group, 2) == 2
        @test element(group, 1:2) == 1:2
        @test elements(group) == 1:3
        @test element_name(group, 2) == "2"
        @test element_name(group, 1:2) == ["1", "2"]
        @test element_names(group) == ["1", "2", "3"]
        @test_throws BoundsError element(group, 5)
        @test_throws BoundsError element_name(group, 5)

        gp = group_product(group)
        for i in 1:3, j in 1:3
            @test group_product(group, i, j) == mtab[i, j]
            @test gp(i, j) == mtab[i, j]
        end
        @test gp(2, BitSet([1,2])) == BitSet([2,3])
        @test gp(BitSet([1,2]), 2) == BitSet([2,3])
        @test gp(BitSet([1,2]), BitSet([1,2])) == BitSet([1,2,3])

        @test group_product(group, 2, BitSet([1,2])) == BitSet([2,3])
        @test group_product(group, BitSet([1,2]), 2) == BitSet([2,3])
        @test group_product(group, BitSet([1,2]), BitSet([1,2])) == BitSet([1,2,3])

        @test gp(2, BitSet([1,2])) == BitSet([2,3])
        @test gp(BitSet([1,2]), 2) == BitSet([2,3])
        @test gp(BitSet([1,2]), BitSet([1,2])) == BitSet([1,2,3])

        @test group_inverse(group, 1) == 1
        @test group_inverse(group, 2) == 3
        @test group_inverse(group, 3) == 2
        @test group_inverse(group, [1,2]) == [1,3]

        ginv = group_inverse(group)
        @test ginv(1) == 1
        @test ginv(2) == 3
        @test ginv(3) == 2
        @test ginv([1,2]) == [1,3]

        @test generate_subgroup(group, 1) == BitSet([1])
        @test generate_subgroup(group, 2) == BitSet([1,2,3])
        @test generate_subgroup(group, [1,2]) == BitSet([1,2,3])

        @test issubgroup(Set([1]), group)
        @test !issubgroup(Set([1,2]), group)
        @test minimal_generating_set(group) == [2]

        @test generate_multiplication_table([[1 0; 0 1], [1 0; 0 -1]]) == [1 2; 2 1]
        @test_throws ArgumentError generate_multiplication_table([[1 0; 0 1], [1 0; 0 1]]) # duplicate
        @test_throws KeyError generate_multiplication_table([[1 0; 0 1], [0 -1; 1 -1]]) # not closed

        @test ishomomorphic(1:3, group; product=gp)
        @test !ishomomorphic(1:2, group; product=gp)
    end

    @testset "FiniteGroup-Nonabelian" begin
        # C3v, 1=I, 2=C3, 4=σᵥₐ (non-abelian)
        group = FiniteGroup([
            1 2 3 4 5 6;
            2 3 1 6 4 5;
            3 1 2 5 6 4;
            4 5 6 1 2 3;
            5 6 4 3 1 2;
            6 4 5 2 3 1;
        ])

        @testset "generators" begin
            generators = minimal_generating_set(group)
            @test generators == [2, 4]
            @test generate_subgroup(group, generators) == BitSet(1:6) # completely generates
        end

        @testset "conjugacy classes" begin
            @test group.conjugacy_classes == [[1], [2,3], [4,5,6]]
            @test issubgroup(Set([1]), group)
            @test !issubgroup(Set([2,3]), group)

            @test issubgroup(Set([1,2,3]), group)
            @test isnormalsubgroup(Set([1,2,3]), group)
            @test issubgroup(Set([1,4]), group)
            @test !isnormalsubgroup(Set([1,4]), group)

            @test issubgroup([1], group)
            @test !issubgroup([2,3], group)

            @test issubgroup([1,2,3], group)
            @test isnormalsubgroup([1,2,3], group)
            @test issubgroup([1,4], group)
            @test !isnormalsubgroup([1,4], group)
        end

        @testset "group isomorphism" begin
            ϕ = [1, 3, 4, 5, 2, 6] # group isomorphism
            mtab1 = group_multiplication_table(group)
            mtab2 = zeros(Int, (6,6))
            for x in 1:6, y in 1:6
                # ϕ(x)⋅ϕ(y) = ϕ(x⋅y)
                mtab2[ϕ[x], ϕ[y]] = ϕ[mtab1[x,y]]
            end
            group2 = FiniteGroup(mtab2)

            # ϕ: group  →  group2
            #       x   ↦  ϕ(x)
            ϕ2 = group_isomorphism(group, group2)
            mtab3 = zeros(Int, (6,6))
            for x in 1:6, y in 1:6
                # ϕ(x)⋅ϕ(y) = ϕ(x⋅y)
                mtab3[ϕ2[x], ϕ2[y]] = ϕ2[mtab1[x,y]]
            end
            @test !isnothing(group_isomorphism(group2, FiniteGroup(mtab3)))  # ϕ and ϕ2 are equivalent

            for ϕ in permutations(2:6)
                ϕ = vcat([1], ϕ)
                mtab1 = group_multiplication_table(group)
                mtab2 = zeros(Int, (6,6))
                for x in 1:6, y in 1:6
                    # ϕ(x)⋅ϕ(y) = ϕ(x⋅y)
                    mtab2[ϕ[x], ϕ[y]] = ϕ[mtab1[x,y]]
                end
                group2 = FiniteGroup(mtab2)
                @test !isnothing(group_isomorphism(group, group2))
            end
        end
    end

    # @testset "minimal_generating_set" begin
    #     for i in 1:32
    #         psym = PointSymmetryDatabase.get(i)
    #         group = psym.group
    #         mgs = minimal_generating_set(group)
    #         @test length(mgs) <= length(psym.generators)
    #         @test generate_subgroup(group, mgs) == BitSet(1:group_order(group))
    #     end
    # end

    @testset "group isomorphism" begin
        # 4
        group1 = FiniteGroup([
            1 2 3 4;
            2 1 4 3;
            3 4 2 1;
            4 3 1 2;
        ])
        @test group1 == FiniteGroup([
            1 2 3 4;
            2 1 4 3;
            3 4 2 1;
            4 3 1 2;
        ])
        group1p= FiniteGroup([
            1 2 3 4;
            2 3 4 1;
            3 4 1 2;
            4 1 2 3;
        ])
        @test !isnothing(group_isomorphism(group1, group1p))
        @test group1 != group1p
        # 2/m
        group2 = FiniteGroup([
            1 2 3 4;
            2 1 4 3;
            3 4 1 2;
            4 3 2 1;
        ])
        @test isnothing(group_isomorphism(group1, group2))
        @test group1 != group2
        @test ishomomorphic(1:4, group1; product=group_product(group1))
        @test !ishomomorphic(1:4, group1; product=group_product(group1p))
        @test !ishomomorphic(1:4, group1; product=group_product(group2))

        let # generate elements of group C₄ with a generator C₄
            m = [0 -1; 1 0]
            element_list = collect(generate_group_elements([m]))
            @test element_list == [[1 0; 0 1], [-1 0; 0 -1], [0 -1; 1 0], [0 1; -1 0]]
            group_generated = FiniteGroup(generate_multiplication_table(element_list))
            @test !isnothing(group_isomorphism(group_generated, group1))
        end
        let
            ∘(x,y) = mod(x+y, 4)
            els = generate_group_elements([1]; product=(∘))
            @test els == [0,2,1,3]
            g = FiniteGroup(generate_multiplication_table(els; product=∘))
            @test !isnothing(group_isomorphism(group1, g))
        end

        @test_throws OverflowError generate_group_elements([1]; product=(+))
    end # @testset "group isomorphism"

    @testset "group isomorphism 2" begin
        # D2h
        group1 = FiniteGroup([
            1 2 3 4 5 6 7 8;
            2 1 4 3 6 5 8 7;
            3 4 1 2 7 8 5 6;
            4 3 2 1 8 7 6 5;
            5 6 7 8 1 2 3 4;
            6 5 8 7 2 1 4 3;
            7 8 5 6 3 4 1 2;
            8 7 6 5 4 3 2 1;
        ])
        group2 = FiniteGroup([
            1 2 3 4 5 6 7 8;
            2 1 4 3 6 5 8 7;
            3 4 2 1 7 8 6 5;
            4 3 1 2 8 7 5 6;
            5 6 7 8 1 2 3 4;
            6 5 8 7 2 1 4 3;
            7 8 6 5 3 4 2 1;
            8 7 5 6 4 3 1 2;
        ])
        @test isnothing(group_isomorphism(group1, group2))
    end

    # @testset "group isomorphism 3" begin
    #     tsym1 = TranslationSymmetry([3 0; 0 3])
    #     tsym2 = TranslationSymmetry([3 1; 0 3])
    #     @test isnothing(group_isomorphism(tsym1.group, tsym2.group))
    # end

    # TODO
    # Are there two non-isomorphic groups with
    # - Same conjugacy classes
    # - Same period lengths
end
