using Plots

export data_profile

function data_profile(data::Vector{Dict{Int,Vector{Float64}}}, dimensions::Dict{Int,Int}, algs_names::Vector{String}; τ::Real=1e-2, k_max::Float64=30.0, return_plot::Bool=true)
    n_algs = length(data)
    n_instances = length(data[1])

    # Pre-treatment: sort instances dimensions so the computations can be vectorized later
    sorted_dimensions = [dimensions[instance] for instance in 1:n_instances]

    # Compute the N_a^p again. TODO: fix this, don't reuse the same code.

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

    # 3. Compute the data profile function
    ks = range(0, stop=k_max, length=100)
    dp_data = fill(0.0, (n_algs, length(ks)))

    for alg in 1:n_algs
        for (i, k) in enumerate(ks)
            # If algorithm a hasn't τ-solved instance p, this mask will be used to make the vectorized comparison easier.
            solved_problems_mask = smallest_solved_iterations[alg, :] .≠ typemax(Float64)
            dp_data[alg, i] = 1 / n_instances * sum(smallest_solved_iterations[alg, :][solved_problems_mask] .≤ k * (sorted_dimensions[solved_problems_mask] .+ 1))
        end
    end

    if return_plot
        p = plot(size=(900, 450))
        for alg in 1:n_algs
            plot!(ks, dp_data[alg, :], label=algs_names[alg], seriestype=:steppost, dpi=700, xtickfontsize=12, ytickfontsize=12)
        end
        xlabel!("Groups of " * L"(n_p+1)" * " evaluations " * L"k")
        ylabel!("Portion of " * L"\tau" * "-solved instances " * L"d_a(k)")
        # title!("Data profiles, τ=$τ")
        return (dp_data, p)
    end
    return dp_data
end