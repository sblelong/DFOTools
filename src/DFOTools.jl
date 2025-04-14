module DFOTools

include("profiles/performance.jl")
include("profiles/data.jl")
include("profiles/accuracy.jl")

include("algs/nelder_mead/nm.jl")
include("algs/mads/mads.jl")

include("utils/read.jl")

end # module DFOTools
