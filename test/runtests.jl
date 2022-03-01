using AddInit
using Test

@testset "AddInit.jl" begin
    @add_init struct A
        a::String
        b::Int
    end

    @test A(Dict("a" => "foo", "b" => 1)) == A("foo", 1)
    @test A("""{"a":"foo", "b":1}""") == A("foo", 1)


    Base.@kwdef struct B
        a::String = "default"
        b::Int = 1
    end

    @add_init B

    @test B(Dict("a" => "foo", "b" => 1)) == B("foo", 1)

    @test B("{}") == B("default", 1)


    @add_init struct C
        a::A
        b::B
    end

    @test C(Dict("a" => Dict("a" => "foo", "b" => 1), "b" => Dict("a" => "default", "b" => 1))) == C(A("foo", 1), B("default", 1))
    @test C("""{"a":{"a":"foo", "b":1}, "b":{}}""") == C(A("foo", 1), B("default", 1))

end
