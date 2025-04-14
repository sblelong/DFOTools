using LinearAlgebra
using Random

export MADS

function generate_search_set(x, D, δ)
    # Just generate random points, who cares
    n, p = size(D)
    y = rand(1:10, p)
    dirs = D * y
    # TODO: finsh this.
end

function generate_poll_set(x, Δ, δ)
    n = length(x)

    # Householder
    v = randn(n)
    v /= norm(v)
    H = I - 2 .* (v * v')

    B = zeros((n, 2 * n))
    # Round to the mesh, then create the positive basis
    for j in 1:n
        b = map(round, Δ / (δ * maximum(map(abs, H[:, j]))) .* H[:, j])
        B[:, j] = b
        B[:, n+j] = -1 .* b
    end

    # Generate the poll directions
    poll_set = [x .+ (δ .* B[:, j]) for j in 1:(2*n)]

    return poll_set
end

"""
    MADS(bb, x0, Δ0, D, τ; MESH_MIN)
"""
function MADS(bb::Function, x0, Δ0, D, τ; MESH_MIN=1e-17, MAX_EVALS=typemax(Int), search_mode::String="none", speculative_search_coef=2)
    # 0. Initializations
    Δ = Δ0 # Frame size parameter
    δ = Δ0 # Mesh size parameter. Useless intialization since it is recomputed at the beginning of each iteration, but left here for clarity.
    k = 0 # Iteration counter
    n_evals = 0

    x_best = x0 # Incumbent solution
    f_best = bb(x0)

    success_flag = false # Flag for speculative search
    successful_search = false

    cache = [x0] # Store all of the improved incumbent solutions, especially useful for speculative search
    history = Float64[]

    Random.seed!(2352025)

    # Stopping criteria
    while δ > MESH_MIN && n_evals < MAX_EVALS
        k += 1
        successful_search = false

        # 1. Mesh size parameter update
        δ = min(Δ, Δ^2 / Δ0)

        # 2. Search step
        if search_mode == "speculative" # Speculative search
            if success_flag
                # println("Speculative search")
                # println("Current x: ", x_best)
                # println("Cache: ", cache)
                search_point = x_best .+ speculative_search_coef .* (x_best .- cache[end-1])
                search_point_value = bb(search_point)
                push!(history, search_point_value)
                # println("Search point obj; ", search_point_value)
                n_evals += 1
                if search_point_value < f_best
                    f_best = search_point_value
                    x_best = search_point
                    push!(cache, x_best)
                    Δ *= 1 / τ
                    successful_search = true
                    success_flag = true
                end
            end
        elseif search_mode == "other" # Regular search
            search_set = generate_search_set(x_best, D, δ) # TODO: see if these are the right parameters, write that function.
            search_set_values = map(bb, search_set)
            for value in search_set_values
                push!(search_set_values, value)
            end
            n_evals += length(search_set)
            best_search_value, best_search_index = findmin(search_set_values)
            if best_search_value < f_best # The search step is a success
                f_best = best_search_value
                x_best = search_set[best_search_index]
                push!(cache, x_best)
                Δ *= 1 / τ
                successful_search = true
                success_flag = true
            end
        end

        if !successful_search # 3. Poll step
            poll_set = generate_poll_set(x_best, Δ, δ)
            poll_set_values = map(bb, poll_set)
            for value in poll_set_values
                push!(history, value)
            end
            n_evals += length(poll_set_values)
            best_poll_value, best_poll_index = findmin(poll_set_values)
            if best_poll_value < f_best
                f_best = best_poll_value
                x_best = poll_set[best_poll_index]
                push!(cache, x_best)
                Δ *= 1 / τ
                success_flag = true
            else
                Δ *= τ
            end
        end

        # End of iteration k
        if mod(k, 1) == 0
            # println(" ** Iteration $k **")
            # println("Current best value: $f_best")
            # println("Current best point: $x_best")
            # println("Mesh size paramter: $δ")
            # println("Frame size parameter: $Δ")
        end
    end
    #= println("** Optimization ended **")
    println("Final solution: ", x_best)
    println("Objective value: ", f_best)
    println("# iterations: ", k) =#

    return history
end