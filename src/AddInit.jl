module AddInit
using JSON

export @add_init

"""
    macro add_init(type::Expr)

    Automatically add a constructor for building objects with dict and json to DataType

# Examples:
```julia
    @add_init struct Test
        field:AbstractString
    end

    Test("{"field":"a"}") == Test("a")
    Test(Dict("field"=>"a")) == Test("a")
```
"""
macro add_init(expr::Expr)
    struct_expr = expr.args[2]
    local typename = esc(
        # 可能含有继承
        typeof(struct_expr) == Symbol ? struct_expr : struct_expr.args[1],
    ) # 消除卫生宏
    quote
        $(esc(expr))

        # 添加外部构造函数，利用Dict生成对象
        @add_dictinit $typename
        @add_jsoninit $typename
    end
end

"""
    macro add_init(symbol::Symbol)

    Automatically add a construction method for building objects with dict and json 
    to the DataType, and adapt to the DataType modified by base.@kwdef

# Examples:
```julia
    @Base.kwdef struct Test
        a::Int
        b::Int=2
        c::Int
    end
    @add_init Test

    Test(Dict("a"=>1, "c"=>3)) == Test(1,2,3)
```
"""
macro add_init(symbol::Symbol)
    local typename = esc(symbol)
    quote
        if hasmethod($typename, Tuple{}, fieldnames($typename))
            # 如果有kwargs构造函数，例如使用了@kwdef
            $typename(dict::Dict) = $typename(;
                map([
                    k for k in keys(dict) if hasfield($typename, Symbol(k))
                ]) do key
                    constructor = fieldtype($typename, Symbol(key))
                    Symbol(key) =>
                        length(methods(constructor)) > 0 ?
                        constructor(dict[key]) : dict[key]
                end...
            )
        else
            # 添加外部构造函数，利用Dict生成对象
            esc(@add_dictinit $typename)
        end
        esc(@add_jsoninit $typename)
    end
end

macro add_jsoninit(typename)
    typename = esc(typename)
    :($typename(json::AbstractString) = $typename(JSON.parse(json)))
end

macro add_dictinit(typename)
    typename = esc(typename)
    quote
        $typename(dict::Dict{String,<:Any}) = $typename(
            map(fieldnames($typename)) do field
                constructor = fieldtype($typename, field)
                # 如果类型为Any或者其他抽象类型，直接返回传入值
                length(methods(constructor)) > 0 ?
                constructor(dict[String(field)]) : dict[String(field)]
            end...
        )
    end
end

end
