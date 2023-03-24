using Alice
using Test

@testset "isinside for Triangle and Node" begin
    @testset "clockwise" begin
        t = Triangle([Node(-1, 0), Node(0, 1), Node(2, 0)])

        @test isinside(t, 10.0, 10.0) == false
        @test isinside(t, -1.0,  1.0) == false
        @test isinside(t, -1.0, -1.0) == false
        @test isinside(t,  2.0, -0.1) == false
        @test isinside(t,  0.0,  2.0) == false

        @test isinside(t,  0.1, 0.3) == true
        @test isinside(t,  1.0, 0.4) == true
        @test isinside(t,  0.0, 0.9) == true
        @test isinside(t, -0.7, 0.1) == true
        @test isinside(t, -1.0, 0.0) == true # vertex
        @test isinside(t,  0.0, 1.0) == true # vertex
    end

    @testset "counter clockwise" begin
        t = Triangle([Node(-1, 0), Node(2, 0), Node(0, 1)])

        @test isinside(t,  5.0,  3.0) == false
        @test isinside(t, -1.0,  1.0) == false
        @test isinside(t, -1.0, -1.0) == false
        @test isinside(t,  2.0, -0.1) == false
        @test isinside(t,  0.0,  2.0) == false

        @test isinside(t,  0.1, 0.3) == true
        @test isinside(t,  1.0, 0.4) == true
        @test isinside(t,  0.0, 0.9) == true
        @test isinside(t, -0.7, 0.1) == true
        @test isinside(t, -1.0, 0.0) == true # vertex
        @test isinside(t,  0.0, 1.0) == true # vertex
    end
end

@testset "robust_delaunay_condition" begin
    @testset "equilateral" begin
        @testset "clockwise" begin
            t = Triangle([Node(0, 0), Node(2.5, 2.5 * sqrt(3)), Node(5, 0)])

            @test robust_delaunay_condition(t, 1.0,  1.0) == false
            @test robust_delaunay_condition(t, 3.0,  3.0) == false
            @test robust_delaunay_condition(t, 2.5,  1.0) == false
            @test robust_delaunay_condition(t, 2.0, -1.0) == false
            @test robust_delaunay_condition(t, 4.0,  1.0) == false
            @test robust_delaunay_condition(t, 1.0,  3.0) == false
            @test robust_delaunay_condition(t, 1.0,  2.0) == false
            @test robust_delaunay_condition(t, 0.0,  2.0) == false
            @test robust_delaunay_condition(t, 5.0,  2.0) == false
            @test robust_delaunay_condition(t, 2.0,  1.0) == false
            @test robust_delaunay_condition(t, 1.0, -1.0) == false # on the edge

            @test robust_delaunay_condition(t,  5.0, -1.0) == true
            @test robust_delaunay_condition(t,  5.0,  5.0) == true
            @test robust_delaunay_condition(t,  0.0,  4.0) == true
            @test robust_delaunay_condition(t,  0.0, -1.0) == true
            @test robust_delaunay_condition(t, -1.0, -1.0) == true
            @test robust_delaunay_condition(t,  6.0,  2.0) == true
            @test robust_delaunay_condition(t,  2.5,  5.0) == true
            @test robust_delaunay_condition(t, -2.0,  4.0) == true
            @test robust_delaunay_condition(t,  0.0,  0.0) == true # vertex
            @test robust_delaunay_condition(t,  0.0,  5.0) == true # vertex
            @test robust_delaunay_condition(t, 100.0, 100.0) == true
        end

        @testset "counter clockwise" begin
            t = Triangle([Node(0, 0), Node(5, 0), Node(2.5, 2.5 * sqrt(3))])

            @test robust_delaunay_condition(t, 1.0,  1.0) == false
            @test robust_delaunay_condition(t, 3.0,  3.0) == false
            @test robust_delaunay_condition(t, 2.5,  1.0) == false
            @test robust_delaunay_condition(t, 2.0, -1.0) == false
            @test robust_delaunay_condition(t, 4.0,  1.0) == false
            @test robust_delaunay_condition(t, 1.0,  3.0) == false
            @test robust_delaunay_condition(t, 1.0,  2.0) == false
            @test robust_delaunay_condition(t, 0.0,  2.0) == false
            @test robust_delaunay_condition(t, 5.0,  2.0) == false
            @test robust_delaunay_condition(t, 2.0,  1.0) == false
            @test robust_delaunay_condition(t, 1.0, -1.0) == false # on the edge

            @test robust_delaunay_condition(t,  5.0, -1.0) == true
            @test robust_delaunay_condition(t,  5.0,  5.0) == true
            @test robust_delaunay_condition(t,  0.0,  4.0) == true
            @test robust_delaunay_condition(t,  0.0, -1.0) == true
            @test robust_delaunay_condition(t, -1.0, -1.0) == true
            @test robust_delaunay_condition(t,  6.0,  2.0) == true
            @test robust_delaunay_condition(t,  2.5,  5.0) == true
            @test robust_delaunay_condition(t, -2.0,  4.0) == true
            @test robust_delaunay_condition(t,  0.0,  0.0) == true # vertex
            @test robust_delaunay_condition(t,  0.0,  5.0) == true # vertex
            @test robust_delaunay_condition(t, 100.0, 100.0) == true
        end
    end

    @testset "right" begin
        t = Triangle([Node(4, 0), Node(0, 0), Node(0, 3)])

        @test robust_delaunay_condition(t, 1.0,  1.0) == false
        @test robust_delaunay_condition(t, 1.0,  3.0) == false
        @test robust_delaunay_condition(t, 0.1,  2.0) == false
        @test robust_delaunay_condition(t, 0.1,  3.0) == false
        @test robust_delaunay_condition(t, 2.0, -0.5) == false

        @test robust_delaunay_condition(t,  2.0, -1.0) == true # on the edge
        @test robust_delaunay_condition(t,  2.0,  4.0) == true # on the edge
        @test robust_delaunay_condition(t,  4.0,  0.0) == true # vertex
        @test robust_delaunay_condition(t,  0.0,  3.0) == true # vertex
        @test robust_delaunay_condition(t,  4.0,  3.0) == true
        @test robust_delaunay_condition(t,  5.0,  4.0) == true
        @test robust_delaunay_condition(t, -1.0, -1.0) == true
        @test robust_delaunay_condition(t, -1.0,  2.0) == true
        @test robust_delaunay_condition(t,  1.0,  4.0) == true
        @test robust_delaunay_condition(t,  4.0, -1.0) == true
        @test robust_delaunay_condition(t, -100.0, -100.0) == true
    end

    @testset "blunt angle" begin
        @testset "clockwise" begin
            t = Triangle([Node(4, 0), Node(3, 0), Node(0, 3)])

            @test robust_delaunay_condition(t, 5.0, 4.0) == false
            @test robust_delaunay_condition(t, 2.0, 4.0) == false
            @test robust_delaunay_condition(t, 2.0, 1.0) == false

            @test robust_delaunay_condition(t, -1.0, 5.0) == true
            @test robust_delaunay_condition(t,  5.0, 8.0) == true
        end

        @testset "counter clockwise" begin
            t = Triangle([Node(4, 0), Node(0, 3), Node(3, 0)])

            @test robust_delaunay_condition(t, 5.0, 4.0) == false
            @test robust_delaunay_condition(t, 2.0, 4.0) == false
            @test robust_delaunay_condition(t, 2.0, 1.0) == false

            @test robust_delaunay_condition(t, -1.0, 5.0) == true
            @test robust_delaunay_condition(t,  5.0, 8.0) == true
        end
    end
end

@testset "isinside for angle and Node" begin
    @testset "sharp angle" begin
        @testset "clockwise" begin
            a, b, c = Node(0, 0), Node(3, 1), Node(3, 0)

            @test isinside(a, b, c, Node(4, 1)) == true
            @test isinside(a, b, c, Node(2, 1)) == false
        end

        @testset "counter clockwise" begin
            a, b, c = Node(0, 0), Node(3, 0), Node(3, 1)

            @test isinside(a, b, c, Node(4, 1)) == true
            @test isinside(a, b, c, Node(2, 1)) == false
        end
    end

    @testset "blunt angle" begin
        @testset "more than 180 deg works with the opposite angle" begin
            a, b, c = Node(0, 0), Node(-3, -1), Node(1, 0)

            @test isinside(a, b, c, Node(0, -1)) == true
            @test isinside(a, b, c, Node(2,  1)) == false
        end

        @testset "less than 180 deg" begin
            a, b, c = Node(0, 0), Node(-1, 1), Node(1, 0)

            @test isinside(a, b, c, Node(-1, 2)) == true
            @test isinside(a, b, c, Node( 2, 1)) == true

            @test isinside(a, b, c, Node(-2,  1)) == false
            @test isinside(a, b, c, Node(-2,  0)) == false
            @test isinside(a, b, c, Node(-1, -1)) == false
        end
    end

    @testset "right angle, gives weird results because of 0 division" begin
        a, b, c = Node(0, 0), Node(1, 0), Node(0, 1)

        # (works only if c -> b, b -> c, so c should be above)
        @test isinside(a, b, c, Node(1, 1)) == true

        @test isinside(a, b, c, Node( 2, -1)) == false
        @test isinside(a, b, c, Node(-1, -1)) == false
        @test isinside(a, b, c, Node(-1,  1)) == false
    end
end

@testset "simple_delaunay_condition, equilateral Triangle, clockwise vertices" begin
    tequilateral = Triangle([Node(0, 0), Node(5, 5 * sqrt(3)), Node(10, 0)])

    @test simple_delaunay_condition(tequilateral, 3.0,  1.0) == false
    @test simple_delaunay_condition(tequilateral, 3.0, -1.0) == false
    @test simple_delaunay_condition(tequilateral, 8.0, -2.0) == false
    @test simple_delaunay_condition(tequilateral, 9.0,  0.0) == false

    @test simple_delaunay_condition(tequilateral, 2.0, -4.0  ) == true
    @test simple_delaunay_condition(tequilateral, 9.0, -100.0) == true
    @test simple_delaunay_condition(tequilateral, 3.5, -5.0  ) == true
end

@testset "simple_delaunay_condition, right Triangle, clockwise vertices" begin
    tright = Triangle([Node(4, 0), Node(0, 0), Node(0, 3)])

    @test simple_delaunay_condition(tright, 3.0, 2.0) == false
    @test simple_delaunay_condition(tright, 4.0, 2.0) == false
    @test simple_delaunay_condition(tright, 1.0, 3.0) == false

    @test simple_delaunay_condition(tright, 4.0, 3.0) == true # lies exactly on the circle
    @test simple_delaunay_condition(tright, 4.0, 4.0) == true
    @test simple_delaunay_condition(tright, 1.0, 4.0) == true

    # outside (x2, y2) angle but still works:
    @test simple_delaunay_condition(tright,  2.0, -0.5) == false
    @test simple_delaunay_condition(tright,  0.5,  0.5) == false
    @test simple_delaunay_condition(tright, -0.1,  1.5) == false

    @test simple_delaunay_condition(tright,  2.0, -2.0) == true
    @test simple_delaunay_condition(tright, -1.0,  2.0) == true
    @test simple_delaunay_condition(tright, -1.0, -1.0) == true
    @test simple_delaunay_condition(tright, -1.0,  0.0) == true
    @test simple_delaunay_condition(tright,  0.0, -1.0) == true
end
