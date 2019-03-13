function moments(entity::HomographyMatrix, 𝒟::Tuple{AbstractArray, Vararg{AbstractArray}})
    # ʹ : CTRL + SHIFT + 02b9
    ℳ, ℳʹ = collect(𝒟)
    N = length(ℳ)
    if (N != length(ℳʹ))
           throw(ArgumentError("There should be an equal number of points for each view."))
    end
    𝐀 =  @SMatrix zeros(9,9)
    for n = 1:N
        𝐦  = hom(ℳ[n])
        𝐦ʹ = hom(ℳʹ[n])
        𝐔 = -𝐦 ⊗ vec2antisym(𝐦ʹ)
        𝐀 = 𝐀 + 𝐔*𝐔'
    end
    𝐀/N
end
