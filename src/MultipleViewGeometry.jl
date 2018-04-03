__precompile__()
module MultipleViewGeometry

using Compat



# Types exported from `types.jl`
export HomogeneousPoint, ProjectiveEntity, FundamentalMatrix, ProjectionMatrix
export CameraModel, Pinhole, CanonicalLens
export EstimationAlgorithm, DirectLinearTransform, Taubin, FundamentalNumericalScheme
export CostFunction, ApproximateMaximumLikelihood, AML
export HomogeneousCoordinates
export CoordinateSystemTransformation, CanonicalToHartley, HartleyToCanonical
export CovarianceMatrices

# Aliases exported from math_aliases.jl
export ⊗, ∑, √

# Functions exported from `operators.jl`.
export 𝑛, smallest_eigenpair,vec2antisym

# Functions exported from `hartley_transformation.jl`.
export hartley_normalization, hartley_transformation

# Functions exported from `transform.jl`.
export transform

# Functions exported from `moments_fundamentalmatrix.jl`
export moments

# Functions exported from `estimate_twoview.jl`
export estimate

# Functions exported from `construct_fundamentalmatrix.jl`
export construct

# Functions exported from `construct_projectionmatrix.jl`
export construct

# Functions exported from `project.jl`
export project

# Functions exported from `rotations.jl`
export rotx, roty, rotz, rotxyz, rodrigues2matrix

# Functions exported from `cost_functions.jl`
export cost, X

include("math_aliases/ModuleMathAliases.jl")
include("types/ModuleTypes.jl")
include("operators/ModuleOperators.jl")
include("rotation/ModuleRotation.jl")
include("data_normalization/ModuleDataNormalization.jl")
include("transform/ModuleTransform.jl")
include("projection/ModuleProjection.jl")
include("carriers/ModuleCarriers.jl")
include("moments/ModuleMoments.jl")
include("cost_function/ModuleCostFunction.jl")
include("estimate/ModuleEstimation.jl")
include("construct/ModuleConstruct.jl")


using .ModuleMathAliases
using .ModuleTypes
using .ModuleOperators
using .ModuleRotation
using .ModuleDataNormalization
using .ModuleTransform
using .ModuleProjection
using .ModuleCarriers
using .ModuleEstimation
using .ModuleMoments
using .ModuleCostFunction
using .ModuleConstruct


# package code goes here

end # module
