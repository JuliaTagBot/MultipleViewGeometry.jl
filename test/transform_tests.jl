using MultipleViewGeometry, Test
using StaticArrays, LinearAlgebra

# Tests for a set of two-dimensional Cartesian points represented by homogeneous
# coordinates.
ℳ = map(Point2D,
        [(-10.0, -10.0),
         (-10.0,  10.0),
         ( 10.0, -10.0),
         ( 10.0,  10.0)])

ℳʹ, 𝐓 = transform(HomogeneousCoordinates(),CanonicalToHartley(),ℳ)
@test ℳʹ == map(Point2D,
                                        [(-1.0,-1.0),
                                         (-1.0, 1.0),
                                         (1.0, -1.0),
                                         (1.0,  1.0)])

Λ =  [MMatrix{3,3}(Matrix(Diagonal([1.0,1.0,0.0]))) for i = 1:length(ℳ)]
Λʹ = transform(CovarianceMatrices(), CanonicalToHartley(), Λ , 𝐓)
for 𝚲 ∈ Λ
    @test 𝚲 == Matrix(Diagonal([1.0, 1.0, 0.0]))
end

for 𝚲 ∈ Λʹ
    @test 𝚲 ≈ Matrix(Diagonal([1.0, 1.0, 0.0])/100)
end

# Tests for a set of three-dimensional Cartesian points represented by homogeneous
# coordinates.
ℳ = map(Point3D,
           [(-10.0, -10.0, -10.0),
            (-10.0, -10.0,  10.0),
            (-10.0,  10.0, -10.0),
            (-10.0,  10.0,  10.0),
            ( 10.0, -10.0, -10.0),
            ( 10.0, -10.0,  10.0),
            ( 10.0,  10.0, -10.0),
            ( 10.0,  10.0,  10.0)])

ℳʹ, 𝐓 = transform(HomogeneousCoordinates(),CanonicalToHartley(),ℳ)
@test ℳʹ == map(Point3D,
                                         [(-1.0,-1.0, -1.0),
                                          (-1.0,-1.0,  1.0),
                                          (-1.0, 1.0, -1.0),
                                          (-1.0, 1.0,  1.0),
                                          (1.0, -1.0, -1.0),
                                          (1.0, -1.0,  1.0),
                                          (1.0,  1.0, -1.0),
                                          (1.0,  1.0,  1.0)])
@test 𝐓 == [0.1 0.0 0.0 -0.0;
            0.0 0.1 0.0 -0.0;
            0.0 0.0 0.1 -0.0;
            0.0 0.0 0.0 1.0]

Λ = [MMatrix{4,4}(Matrix(Diagonal([1.0, 1.0, 1.0, 0.0]))) for i = 1:length(ℳ)]
Λʹ = transform(CovarianceMatrices(), CanonicalToHartley(), Λ , 𝐓)
for 𝚲 ∈ Λ
    @test 𝚲 == Matrix(Diagonal([1.0, 1.0, 1.0, 0.0]))
end
for 𝚲 ∈ Λʹ
    @test 𝚲 ≈ Matrix(Diagonal([1.0, 1.0, 1.0, 0.0])/100)
end
