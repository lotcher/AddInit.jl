# AddInit

Automatically add a constructor for building objects with Dict and JSON String to DataType

## Usage

You can use macro **@add_init** before **struct** definition. Then get a constructor initialized by JSON string or Dict. Of course, you can also use **@add_jsoninit** or **@add_dictinit** to separately add JSON or Dict constructor.

```julia
using AddInit

@add_init struct Test
    field:AbstractString
end

Test("{"field":"a"}") == Test("a")  # true
Test(Dict("field"=>"a")) == Test("a")  #true
```

It can also cooperate with Base.@kwdef use.

```julia
@Base.kwdef struct Test
    a::Int
    b::Int=2
    c::Int
end
@add_init Test

Test(Dict("a"=>1, "c"=>3)) == Test(1,2,3)   # true
```

Of course, it also applies to nested objects

```julia
@add_init struct A
    v::Int
end 
@add_init struct B
    a::A
end
 
B(Dict("a"=>Dict("v"=>1))) == B(A(1))  # true
```

## Warning

1. Do not use this macro when a single attribute type is String or Dict, which will cause ambiguity.
2. Type annotation needs to have a constructor with the same name. Abstract types are not available

