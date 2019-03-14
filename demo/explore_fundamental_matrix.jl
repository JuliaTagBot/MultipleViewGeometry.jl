using Makie
using MultipleViewGeometry, Test, Random
using MultipleViewGeometry.ModuleCostFunction
using MultipleViewGeometry.ModuleTypes
using MultipleViewGeometry.ModuleConstraints
using MultipleViewGeometry.ModuleConstruct
using MultipleViewGeometry.ModuleDraw
using MultipleViewGeometry.ModuleMove
using LinearAlgebra
using StaticArrays
using GeometryTypes
using Test

𝒳 = [Point3D(x,y,rand(50:100)) for x = -100:5:100 for y = -100:5:100]
𝒳 = 𝒳[1:50:end]
X = reshape(reinterpret(Float64,𝒳),(3,length(𝒳)))

# Specify the coordinate systems of the world, the camera frame and the picture
# plane.
world_basis = (Vec(1.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(0.0, 0.0, 1.0))
camera_basis = (Point(0.0, 0.0, 0.0), Vec(-1.0, 0.0, 0.0), Vec(0.0, -1.0, 0.0), Vec(0.0, 0.0, 1.0))
picture_basis = (Point(0.0, 0.0), Vec(-1.0, 0.0), Vec(0.0, -1.0))

# The focal length for both cameras is one.
f = 1
image_width = 640 / 10
image_height = 480 / 10

camera₁ = Pinhole(image_width, image_height, f, camera_basis..., picture_basis...)
camera₂ = Pinhole(image_width, image_height, f, camera_basis..., picture_basis...)

# Rotate and translate camera one.
𝐑₁ = Matrix{Float64}(I,3,3)
𝐭₁ = [-50.0, -2.0, 0.0]
relocate!(camera₁, 𝐑₁, 𝐭₁)

# Rotate and translate camera two.
𝐑₂ = Matrix{Float64}(I,3,3)
𝐭₂ = [50.0, 2.0, 0.0]
relocate!(camera₂, 𝐑₂, 𝐭₂)


scale = 20.0f0
x = Vec3f0(0); baselen = 0.2f0 * scale ; dirlen = 1f0 * scale
# create an array of differently colored boxes in the direction of the 3 axes
rectangles = [
    (HyperRectangle(Vec3f0(x), Vec3f0(dirlen, baselen, baselen)), RGBAf0(1,0,0,1)),
    (HyperRectangle(Vec3f0(x), Vec3f0(baselen, dirlen, baselen)), RGBAf0(0,1,0,1)),
    (HyperRectangle(Vec3f0(x), Vec3f0(baselen, baselen, dirlen)), RGBAf0(0,0,1,1))
]
meshes = map(GLNormalMesh, rectangles)


scene = mesh(merge(meshes))
scatter!(scene, X[1,:],X[2,:], X[3,:], markersize = 3, color = :red)
draw!(camera₁, scene)
draw!(camera₂, scene)



𝐑₁′, 𝐭₁′ = ascertain_pose(camera₁, world_basis... )
𝐊₁′ = obtain_intrinsics(camera₁, CartesianSystem())
𝐑₂′, 𝐭₂′ = ascertain_pose(camera₂, world_basis... )
𝐊₂′ = obtain_intrinsics(camera₂, CartesianSystem())

# Camera projection matrices.
𝐏₁ = construct(ProjectionMatrix(),𝐊₁′,𝐑₁′,𝐭₁′)
𝐏₂ = construct(ProjectionMatrix(),𝐊₂′,𝐑₂′,𝐭₂′)


# Set of corresponding points.
ℳ = project(camera₁,𝐏₁,𝒳)
ℳʹ = project(camera₂,𝐏₂,𝒳)

# Estimate of the fundamental matrix and the true fundamental matrix.
𝐅 = estimate(FundamentalMatrix(), DirectLinearTransform(), (ℳ, ℳʹ))

#𝐅ₜ = construct(FundamentalMatrix(), 𝐏₁, 𝐏₂)
𝐅ₜ = construct(FundamentalMatrix(), 𝐊₁′,𝐑₁′,-𝐭₁′,𝐊₂′,𝐑₂′,-𝐭₂′)

# Ensure the estimated and true matrix have the same scale and sign.
𝐅 = 𝐅 / norm(𝐅)
𝐅 = 𝐅 / sign(𝐅[3,1])
𝐅ₜ = 𝐅ₜ / norm(𝐅ₜ)
𝐅ₜ = 𝐅ₜ / sign(𝐅ₜ[3,1])

@test 𝐅 ≈ 𝐅ₜ

# Check that the fundamental matrix satisfies the corresponding point equation.
npts = length(ℳ)
residual = zeros(Float64,npts,1)
for correspondence in zip(1:length(ℳ),ℳ, ℳʹ)
    i, m , mʹ = correspondence
    𝐦  = hom(m)
    𝐦ʹ = hom(mʹ)
    residual[i] = (𝐦ʹ'*𝐅*𝐦)
end

@test isapprox(sum(residual), 0.0; atol = 1e-7)


# Test the Fundamental Numerical Scheme on the Fundamental matrix problem.
Λ₁ =  [SMatrix{3,3}(Matrix(Diagonal([1.0,1.0,0.0]))) for i = 1:length(ℳ)]
Λ₂ =  [SMatrix{3,3}(Matrix(Diagonal([1.0,1.0,0.0]))) for i = 1:length(ℳ)]
𝐅₀ = estimate(FundamentalMatrix(),DirectLinearTransform(),  (ℳ, ℳʹ))
𝐅 = estimate(FundamentalMatrix(),
              FundamentalNumericalScheme(vec(𝐅₀), 5, 1e-10),
               (Λ₁,Λ₂), (ℳ, ℳʹ))


# Ensure the estimated and true matrix have the same scale and sign.
𝐅 = 𝐅 / norm(𝐅)
𝐅 = 𝐅 / sign(𝐅[3,1])

@test 𝐅 ≈ 𝐅ₜ

# Test the Bundle Adjustment estimator on the Fundamental matrix problem.
𝐅, lsqFit = estimate(FundamentalMatrix(),
                      BundleAdjustment(vec(𝐅₀), 5, 1e-10),
                        (ℳ, ℳʹ))
𝐅 = 𝐅 / norm(𝐅)
𝐅 = 𝐅 / sign(𝐅[3,1])
@test 𝐅 ≈ 𝐅ₜ
