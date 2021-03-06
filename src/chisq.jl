################################################################################
## Chi squared
################################################################################

#=---------------
Evaluate
---------------=#
function evaluate{T<:AbstractFloat}(dist::ChiSquared, a::T, b::T)
    return (a-b)^2/(2*b)
end

function evaluate{T<:AbstractFloat}(dist::ChiSquared, a::AbstractVector{T})
    r = zero(T)
    @simd for i in eachindex(a)
        @inbounds r += (a[i] - 1.0)^2/2.0
    end
    return r
end

function evaluate{T<:AbstractFloat}(dist::ChiSquared, a::AbstractVector{T}, b::AbstractVector{T})
    if length(a) != length(b)
        throw(DimensionMismatch("first array has length $(length(a)) which does not match the length of the second, $(length(b))."))
    end
    r = zero(T)
    @simd for i in eachindex(a, b)
        @inbounds r += (a[i]-b[i])^2/(2*b[i])
    end
    return r
end

#=---------------
gradient
---------------=#
function gradient{T<:AbstractFloat}(dist::ChiSquared, a::T, b::T)
    return (a/b) - 1.0
end

function gradient{T<:AbstractFloat}(dist::ChiSquared, a::T)
    return a - 1.0
end

function gradient!{T<:AbstractFloat}(u::Vector{T}, dist::ChiSquared, a::AbstractVector{T}, b::AbstractVector{T})
    if length(a) != length(b)
        throw(DimensionMismatch("first array has length $(length(a)) which does not match the length of the second, $(length(b))."))
    end
    @simd for i = eachindex(a, b)
        ai = a[i]
        bi = b[i]
        @inbounds u[i] = (ai/bi)-1.0
    end
    u
end

function gradient!{T<:AbstractFloat}(u::Vector{T}, dist::ChiSquared, a::AbstractVector{T})
    @simd for i = eachindex(a)
        @inbounds u[i] = a[i]-1.0
    end
    u
end

#=---------------
hessian
---------------=#
function hessian{T<:AbstractFloat}(dist::ChiSquared, a::T, b::T)
    return 1/b
end

function hessian{T<:AbstractFloat}(dist::ChiSquared, a::T)
    return 1.0
end


function hessian!{T<:AbstractFloat}(u::Vector{T}, dist::ChiSquared, a::AbstractVector{T}, b::AbstractVector{T})
    if length(a) != length(b)
        throw(DimensionMismatch("first array has length $(length(a)) which does not match the length of the second, $(length(b))."))
    end
    @simd for i = eachindex(a)
         @inbounds u[i] = 1/b[i]
    end
    u
end

function hessian!{T<:AbstractFloat}(u::Vector{T}, dist::ChiSquared, a::AbstractVector{T})
    @simd for i = eachindex(a)
        @inbounds u[i] = 1.0
    end
    u
end
