export performance_profile, compute_optimals

using Plots
using LaTeXStrings

"""
    performance_profile(data::Vector{Vector{Vector{<:Real}}}, algs_names::Vector{String})

This function plots a performance profile for a given set of `n_algs` algorithms on a given set of `n_instances` instances, as defined in [Moré, Wild 2009](https://epubs.siam.org/doi/abs/10.1137/080724083?download=true&journalCode=sjope8).

In the current implementation, the best objective value is assumed to be the best value found by any algorithm in the batch.
TODO: implement a variant that allows the user to give known optimal values for some of/all the instances.

# Arguments
- `data::Vector{Vector{Vector{<:Real}}}`: a vector of `n_algs` 3D arrays, each containing the results of one algorithm on each instance. The dimensions of each array give: 
    - First dimension: the index of the instance.
    - Second dimension: the evaluation #.
    - Third dimension: the value of the objective function.
- `algs_names::Vector{String}`: a vector of `n_algs` strings with the names of the algorithms.

# Returns
- `p::Plots.Plot`: a plot with the performance profile.
"""
function performance_profile(data::Vector{Dict{Int,Vector{Float64}}}, algs_names::Vector{String}; τ::Real=1e-2, α_max::Float64=5.0, return_plot::Bool=true)
    n_algs = length(data)
    n_instances = length(data[1])

    # 1. Compute optimal values for all problems
    optimals = compute_optimals(data)

    # 2. Compute the N_a^p values for each algorithm a on each problem p.
    # Assume N_a^p = ∞ if alg a never τ-solved problem p.
    smallest_solved_iterations = fill(typemax(Float64), (n_algs, n_instances))

    for alg in 1:n_algs
        for instance in 1:n_instances
            f0 = data[alg][instance][1]
            instance_opt = optimals[instance]
            a_has_solved_p = data[alg][instance] .≤ instance_opt + τ * (f0 - instance_opt)
            if any(a_has_solved_p .== 1)
                smallest_solved_iterations[alg, instance] = findfirst(a_has_solved_p .== 1)
            end
        end
    end

    # 3. Compute the performance ratios r_a^p.
    # As per described in the book, assume T_{a,p}=0 if N_a^p=∞.
    performance_ratios = fill(typemax(Float64), (n_algs, n_instances))

    # To improve performance (which sounds like a joke looking at those nested loops but ey, it's getting late), pre-compute the mins used in each calculation.
    best_iteration_solved = Dict{Int,Float64}()
    for instance in 1:n_instances
        best_iteration_solved[instance] = minimum(smallest_solved_iterations[:, instance])
    end

    for alg in 1:n_algs
        for instance in 1:n_instances
            if smallest_solved_iterations[alg, instance] == typemax(Float64)
                performance_ratios[alg, instance] = typemax(Float64)
            else
                performance_ratios[alg, instance] = smallest_solved_iterations[alg, instance] / best_iteration_solved[instance]
            end
        end
    end

    return smallest_solved_iterations

    # 4. Compute the values of the performance profile function
    αs = range(1, stop=α_max, length=100)
    ρ = fill(0.0, (n_algs, length(αs)))
    for alg in 1:n_algs
        for (i, α) in enumerate(αs)
            ρ[alg, i] = 1 / n_instances * sum(performance_ratios[alg, :] .≤ α)
        end
    end

    # 5. If desired, plot the performance profile
    if return_plot
        p = plot(size=(900, 450))
        for alg in 1:n_algs
            plot!(αs, ρ[alg, :], label=algs_names[alg], seriestype=:steppost, dpi=700, xtickfontsize=12, ytickfontsize=12)
        end
        xlabel!("Ratio of function evaluations " * L"\alpha")
        ylabel!("Portion of " * L"\tau" * "-solved instances " * L"\rho_a(\alpha)")
        # title!("Performance Profile on a set of $n_instances problems")
    end

    if return_plot
        return (ρ, p)
    else
        return ρ
    end

end

function compute_optimals(data::Vector{Dict{Int,Vector{Float64}}})::Dict{Int,Float64}
    n_algs = length(data)
    n_instances = length(data[1])

    optimals = Dict{Int,Float64}()

    for instance in 1:n_instances
        algs_optimals = [minimum(data[alg][instance]) for alg in 1:n_algs]
        optimals[instance] = minimum(algs_optimals)
    end

    return optimals
end