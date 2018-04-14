function construct( e::FundamentalMatrix,
                   𝐊₁::AbstractArray{T,2},
                   𝐑₁::AbstractArray{T,2},
                    𝐭₁::AbstractArray{T,1},
                   𝐊₂::AbstractArray{T,2},
                   𝐑₂::AbstractArray{T,2},
                     𝐭₂::AbstractArray{T,1} ) where T<:Real

    if size(𝐊₁) != (3,3) || size(𝐊₂) != (3,3) ||
       size(𝐑₁) != (3,3) || size(𝐑₂) != (3,3)
        throw(ArgumentError("Expect 3 x 3 calibration and rotation matrices."))
    end
    if length(𝐭₁) != 3 || length(𝐭₂) != 3
        throw(ArgumentError("Expect length-3 translation vectors."))
    end
    𝐅 = vec2antisym(𝐊₂*𝐑₂*(𝐭₁ .- 𝐭₂))*𝐊₂*𝐑₂/𝐑₁/𝐊₁
end

function construct( e::FundamentalMatrix,
                   𝐏₁::AbstractArray{T,2},
                   𝐏₂::AbstractArray{T,2}) where T<:Real

    if (size(𝐏₁) != (3,4)) || (size(𝐏₂) != (3,4))
        throw(ArgumentError("Expect 3 x 4 projection matrices."))
    end
    𝐜₁ = nullspace(𝐏₁)
    𝐞₂ = 𝐏₂*𝐜₁
    return 𝐅 = vec2antisym(𝐞₂)*𝐏₂*pinv(𝐏₁)
end
