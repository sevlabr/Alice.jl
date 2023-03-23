using Test
using Alice

@testset "test inc" begin
    @test Alice.inc(-1) == 0
    @test Alice.inc(1)  == 2
    @test Alice.inc(0)  == 1
end
