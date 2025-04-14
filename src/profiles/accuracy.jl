using Plots
using LaTeXStrings

export accuracy_profile

function accuracy_profile(data::Vector{Dict{Int,Vector{Float64}}}, algs_names::Vector{String}; d_max::Float64=5.0, return_plot::Bool=true)
    n_algs = length(data)
    n_instances = length(data[1])

    # 1. Compute optimal and initial values for all problems
    optimals = compute_optimals(data)
    sorted_optimals = [optimals[instance] for instance in 1:n_instances]
    initials = compute_initials(data)
    sorted_initials = [initials[instance] for instance in 1:n_instances]

    # 2. Compute the function values on the last eval for each (alg,instance)
    last_iterations = fill(typemax(Float64), (n_algs, n_instances))
    for alg in 1:n_algs
        for instance in 1:n_instances
            if instance in keys(data[alg])
                last_iterations[alg, instance] = data[alg][instance][end]
            end
        end
    end

    # 3. Compute the accuracy of the final solution on each (alg,instance)
    final_accuracies = fill(0.0, (n_algs, n_instances))
    for alg in 1:n_algs
        for instance in 1:n_instances
            if last_iterations[alg, instance] != typemax(Float64)
                final_accuracies[alg, instance] = (last_iterations[alg, instance] - initials[instance]) / (optimals[instance] - initials[instance])
            end
            # Nice vectorization for the case where no solvers crashed:
            # final_accuracies[alg, :] = (last_iterations[alg, :] .- sorted_initials) ./ (sorted_optimals .- sorted_initials)
        end
    end

    # 4. Compute the values of the accuracy profile function
    ds = range(0, stop=d_max, length=100)
    ap_data = fill(0.0, (n_algs, length(ds)))
    for alg in 1:n_algs
        for (i, d) in enumerate(ds)
            ap_data[alg, i] = 1 / n_instances * sum(-log10.(1 .- final_accuracies[alg, :]) .≥ d)
        end
    end

    # 5. If desired, plot the accuracy profile
    if return_plot
        p = plot(size=(700, 450))
        for alg in 1:n_algs
            plot!(ds, ap_data[alg, :], label=algs_names[alg], seriestype=:steppost, dpi=700, xtickfontsize=12, ytickfontsize=12)
        end
        xlabel!("Relative accuracy " * L"d")
        ylabel!("Portion of instances solved " * L"r_a(d)")

        return (ap_data, p)
    end

    return dp_data

end