module ModuleOperators
using StaticArrays, LinearAlgebra
using MultipleViewGeometry.ModuleMathAliases, MultipleViewGeometry.ModuleTypes
export 𝑛, ∂𝑛, smallest_eigenpair,vec2antisym
export hom, hom⁻¹, ∂hom⁻¹
include("operators.jl")
end
