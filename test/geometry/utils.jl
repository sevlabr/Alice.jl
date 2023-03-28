using Alice
using Test

function round_circles(circles::Dict{DTriangle, Circle}; tol=6)
    rounded_circles = Dict()
    for (t, circle) in circles
        rad = round(circle.radius, digits=tol)
        xc, yc = circle.center.x, circle.center.y
        xc, yc = round(xc, digits=tol), round(yc, digits=tol)
        rounded_circles[t] = Circle(Node(xc, yc), rad)
    end
    return rounded_circles
end

@testset "simple_delaunay" begin
    @testset "raw contents" begin
        points = [3 3; -5 -2; 3 -5; 1 -4; 2 -2; -5 4; 1 -5; -2 -3; -4 -3; 3 1]
        pts::Vector{Node} = matrix_to_nodes(points)
        dt = simple_delaunay(pts)

        ref_nodes = [
                     Node(-24.3, -28.6); Node( 23.7, -28.6); Node( 23.7,  25.4);
                     Node(-24.3,  25.4); Node( 3   ,  3   ); Node(-5   , -2   );
                     Node( 3   , -5   ); Node( 1   , -4   ); Node( 2   , -2   );
                     Node(-5   ,  4   ); Node( 1   , -5   ); Node(-2   , -3   );
                     Node(-4   , -3   ); Node( 3   ,  1   )
                    ]
        @test dt.nodes == ref_nodes

        ref_triangles = Dict(
            DTriangle((6 , 4 , 1 )) => [DTriangle(), DTriangle((13, 6, 1)), DTriangle((10, 4, 6 ))],
            DTriangle((14, 2 , 3 )) => [DTriangle(), DTriangle((14, 3, 5)), DTriangle((14, 7, 2 ))],
            DTriangle((10, 3 , 4 )) => [DTriangle(), DTriangle((10, 4, 6)), DTriangle((10, 5, 3 ))],
            DTriangle((11, 1 , 2 )) => [DTriangle(), DTriangle((11, 2, 7)), DTriangle((13, 1, 11))],

            DTriangle((9 , 8 , 7 )) => [DTriangle((11, 7 , 8)), DTriangle((14, 9 , 7 )), DTriangle((12, 8 , 9 ))],
            DTriangle((10, 4 , 6 )) => [DTriangle((6 , 4 , 1)), DTriangle((12, 10, 6 )), DTriangle((10, 3 , 4 ))],
            DTriangle((10, 5 , 3 )) => [DTriangle((14, 3 , 5)), DTriangle((10, 3 , 4 )), DTriangle((14, 5 , 10))],
            DTriangle((11, 2 , 7 )) => [DTriangle((14, 7 , 2)), DTriangle((11, 7 , 8 )), DTriangle((11, 1 , 2 ))],
            DTriangle((11, 7 , 8 )) => [DTriangle((9 , 8 , 7)), DTriangle((12, 11, 8 )), DTriangle((11, 2 , 7 ))],
            DTriangle((12, 11, 8 )) => [DTriangle((11, 7 , 8)), DTriangle((12, 8 , 9 )), DTriangle((13, 11, 12))],
            DTriangle((12, 8 , 9 )) => [DTriangle((9 , 8 , 7)), DTriangle((14, 12, 9 )), DTriangle((12, 11, 8 ))],
            DTriangle((12, 10, 6 )) => [DTriangle((10, 4 , 6)), DTriangle((13, 12, 6 )), DTriangle((14, 10, 12))],
            DTriangle((13, 6 , 1 )) => [DTriangle((6 , 4 , 1)), DTriangle((13, 1 , 11)), DTriangle((13, 12, 6 ))],
            DTriangle((13, 1 , 11)) => [DTriangle((11, 1 , 2)), DTriangle((13, 11, 12)), DTriangle((13, 6 , 1 ))],
            DTriangle((13, 11, 12)) => [DTriangle((12, 11, 8)), DTriangle((13, 12, 6 )), DTriangle((13, 1 , 11))],
            DTriangle((13, 12, 6 )) => [DTriangle((12, 10, 6)), DTriangle((13, 6 , 1 )), DTriangle((13, 11, 12))],
            DTriangle((14, 3 , 5 )) => [DTriangle((10, 5 , 3)), DTriangle((14, 5 , 10)), DTriangle((14, 2 , 3 ))],
            DTriangle((14, 5 , 10)) => [DTriangle((10, 5 , 3)), DTriangle((14, 10, 12)), DTriangle((14, 3 , 5 ))],
            DTriangle((14, 10, 12)) => [DTriangle((12, 10, 6)), DTriangle((14, 12, 9 )), DTriangle((14, 5 , 10))],
            DTriangle((14, 12, 9 )) => [DTriangle((12, 8 , 9)), DTriangle((14, 9 , 7 )), DTriangle((14, 10, 12))],
            DTriangle((14, 9 , 7 )) => [DTriangle((9 , 8 , 7)), DTriangle((14, 7 , 2 )), DTriangle((14, 12, 9 ))],
            DTriangle((14, 7 , 2 )) => [DTriangle((11, 2 , 7)), DTriangle((14, 2 , 3 )), DTriangle((14, 9 , 7 ))],
        )
        @test dt.triangles == ref_triangles

        ref_circles = Dict(
            DTriangle((6,  4 , 1 )) => Circle(Node(-33.53,  -1.6 ), 28.53),
            DTriangle((9,  8 , 7 )) => Circle(Node(  2.5 ,  -3.5 ), 1.58 ),
            DTriangle((10, 3 , 4 )) => Circle(Node( -0.3 ,  27.64), 24.10),
            DTriangle((10, 4 , 6 )) => Circle(Node(-29.84,   1.  ), 25.02),
            DTriangle((10, 5 , 3 )) => Circle(Node(  1.68,  24.98), 22.02),
            DTriangle((11, 1 , 2 )) => Circle(Node( -0.3 , -28.97), 24.00),
            DTriangle((11, 2 , 7 )) => Circle(Node(  2.  , -26.76), 21.78),
            DTriangle((11, 7 , 8 )) => Circle(Node(  2.  ,  -4.5 ), 1.12 ),
            DTriangle((12, 11, 8 )) => Circle(Node( -0.83,  -4.5 ), 1.90 ),
            DTriangle((12, 8 , 9 )) => Circle(Node( -0.07,  -2.21), 2.08 ),
            DTriangle((12, 10, 6 )) => Circle(Node( -2.33,   1.  ), 4.01 ),
            DTriangle((13, 6 , 1 )) => Circle(Node(-16.19, -14.19), 16.54),
            DTriangle((13, 1 , 11)) => Circle(Node( -8.13, -20.57), 18.05),
            DTriangle((13, 11, 12)) => Circle(Node( -3.  ,  -7.75), 4.85 ),
            DTriangle((13, 12, 6 )) => Circle(Node( -3.  ,  -1.  ), 2.24 ),
            DTriangle((14, 2 , 3 )) => Circle(Node( 30.8 ,  -1.6 ), 27.92),
            DTriangle((14, 3 , 5 )) => Circle(Node( 26.55,   2.  ), 23.57),
            DTriangle((14, 5 , 10)) => Circle(Node( -1.19,   2.  ), 4.31 ),
            DTriangle((14, 10, 12)) => Circle(Node( -1.41,   1.39), 4.43 ),
            DTriangle((14, 12, 9 )) => Circle(Node( -0.77,   0.59), 3.79 ),
            DTriangle((14, 9 , 7 )) => Circle(Node(  7.  ,  -2.  ), 5.00 ),
            DTriangle((14, 7 , 2 )) => Circle(Node( 30.22,  -2.  ), 27.39),
        )
        @test round_circles(dt.circles, tol=2) == round_circles(ref_circles, tol=2)
    end
end

@testset "Delaunay2D initialization routine" begin
    frame = [Node(0, 0), Node(4, 0), Node(4, 3), Node(0, 3)]
    dt = dtinit(frame)

    t1, t2 = DTriangle((1, 2, 4)), DTriangle((3, 4, 2))
    t0 = DTriangle()
    c = Circle(Node(2, 1.5), 2.5)

    @test dt.nodes     == frame
    @test dt.triangles == Dict(t1 => [t2, t0, t0], t2 => [t1, t0, t0])

    @test round_circles(dt.circles) == Dict(t1 => c, t2 => c)
end

@testset "fast_delaunay_condition" begin
    @testset "origin (0, 0)" begin
        c = Circle(Node(0, 0), 3)
        @test fast_delaunay_condition(c, 0.0,  0.0) == false
        @test fast_delaunay_condition(c, 1.0,  2.0) == false
        @test fast_delaunay_condition(c, 2.99, 0.0) == false

        @test fast_delaunay_condition(c, 3.01, 0.0) == true
        @test fast_delaunay_condition(c, 99.0, 0.0) == true
        @test fast_delaunay_condition(c, -1.0, 9.0) == true
        @test fast_delaunay_condition(c,  5.0, 1.0) == true
    end

    @testset "shifted origin" begin
        c = Circle(Node(1, 5), 2)
        @test fast_delaunay_condition(c, 1.0,  5.0) == false
        @test fast_delaunay_condition(c, 1.0,  4.0) == false
        @test fast_delaunay_condition(c, 1.0,  6.0) == false
        @test fast_delaunay_condition(c, 2.0,  5.0) == false
        @test fast_delaunay_condition(c, 2.0,  4.0) == false
        @test fast_delaunay_condition(c, 2.99, 5.0) == false

        @test fast_delaunay_condition(c, 3.01, 5.0) == true
        @test fast_delaunay_condition(c, 99.0, 0.0) == true
        @test fast_delaunay_condition(c, -1.0, 9.0) == true
        @test fast_delaunay_condition(c,  5.0, 1.0) == true
    end
end

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
