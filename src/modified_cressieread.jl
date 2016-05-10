function evaluate{T<:AbstractFloat}(dist::ModifiedCressieRead, a::AbstractVector{T}, b::AbstractVector{T})
    α  =  dist.α
    ϑ   = dist.ϑ
    u₀  = 1+ϑ
    cr  = CressieRead(α)
    ϕ₀  = evaluate(cr, [u₀])
    ϕ¹₀ = gradient(cr, u₀)
    ϕ²₀ = hessian(cr, u₀)
    onet = one(T)
    aexp = (onet+α)
    const aa = onet/(α*aexp)
    const ua = onet/α
    const pa = onet/aexp
    r = zero(T)
    
    if length(a) != length(b)
        throw(DimensionMismatch("first array has length $(length(a)) which does not match the length of the second, $(length(b))."))
    end
    
    for i = eachindex(a, b)
        @inbounds ai = a[i]
        @inbounds bi = b[i]
        @inbounds ui = ai/bi
        if ui>=u₀
      		r += (ϕ₀ + ϕ¹₀*(ui-u₀) + .5*ϕ²₀*(ui-u₀)^2)*bi
        elseif ui > 0 && ui < u₀
            r += ( (ui^(1+α)-1)*aa-ua*ui+ua )*bi
        elseif ui==0
            r += pa*bi
        else
            r = +Inf
            break
        end
    end
    return r
end

function evaluate{T<:AbstractFloat}(dist::ModifiedCressieRead, a::AbstractVector{T})
    α  =  dist.α
    ϑ   = dist.ϑ
    u₀  = 1+ϑ
    cr  = CressieRead(α)
    ϕ₀  = evaluate(cr, [u₀])
    ϕ¹₀ = gradient(cr, u₀)
    ϕ²₀ = hessian(cr, u₀)
    onet = one(T)
    aexp = (onet+α)
    const aa = onet/(α*aexp)
    const ua = onet/α
    const pa = onet/aexp
    r = zero(T)
    @inbounds for i = eachindex(a)
        ui = a[i]
        if ui>=u₀
      		r += ϕ₀ + ϕ¹₀*(ui-u₀) + .5*ϕ²₀*(ui-u₀)^2
        elseif ui > 0 && ui < u₀
            r += (ui^(1+α)-1)*aa-ua*ui+ua
        elseif ui==0
            r += pa
        else
            r = +Inf
            break
        end
    end
    return r
end


function gradient{T<:AbstractFloat}(dist::ModifiedCressieRead, a::T)
    α    = dist.α
    ϑ    = dist.ϑ
    u₀   = 1+ϑ
    cr   = CressieRead(α)
    ϕ¹₀  = gradient(cr, u₀)
    ϕ²₀  = hessian(cr, u₀)
    onet = one(T)
    r    = zero(T)
    if a>=u₀
        u =  ϕ¹₀ + ϕ²₀*(a-u₀)
    else
        u = gradient(cr, a)
    end
end

function gradient{T<:AbstractFloat}(dist::ModifiedCressieRead, a::T, b::T)
    α    = dist.α
    ϑ    = dist.ϑ
    u₀   = 1+ϑ
    cr   = CressieRead(α)
    ϕ¹₀  = gradient(cr, u₀)
    ϕ²₀  = hessian(cr, u₀)
    ui   = a/b
    if ui>u₀
        u = (ϕ¹₀ + ϕ²₀*(u-u₀))*b
    else
        u = gradient(cr, a, b)
    end
end

function hessian{T<:AbstractFloat}(dist::ModifiedCressieRead, a::T)
    α    = dist.α
    ϑ    = dist.ϑ
    u₀   = 1+ϑ
    cr   = CressieRead(α)
    ϕ²₀  = hessian(cr, u₀)
    if a>=u₀
        return ϕ²₀
    else
        hessian(cr, a)
    end
end

function hessian{T<:AbstractFloat}(dist::ModifiedCressieRead, a::T, b::T)
    α    = dist.α
    ϑ    = dist.ϑ
    u₀   = 1+ϑ
    cr   = CressieRead(α)
    ϕ²₀  = hessian(cr, u₀)
    ui   = a/b
    onet = one(T)
    aexp = (onet+α)
    if ui>0
        u = a^aexp
    elseif ui==0
        if α>1
            u = zero(T)
        else
            u = +Inf
        end
    else
        return +Inf
    end
end
