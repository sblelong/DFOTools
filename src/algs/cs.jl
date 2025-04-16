function project_on_bounds(x, lb, ub)
    projected_x = Float64[]
    for i in 1:length(x)
        if x[i] < lb[i]
            push!(projected_x, lb[i])
        elseif x[i] > ub[i]
            push!(projected_x, ub[i])
        else
            push!(projected_x, x[i])
        end
    end
    return projected_x
end

function cs(bb, x0, lb, ub; δ0=1, ε=1e-6, MAX_EVALS=Inf, project_bounds=false)
    if !(all(lb .<= x0 .<= ub))
        if project_bounds
            x = project_on_bounds(x0, lb, ub)
        else
            error("Initial point doesn't respect bounds.")
        end
    else
        x = x0
    end

    f_best = bb(x)
    n_evals = 1

    δ = δ0

    D = [1.0 0.0 -1.0 0.0; 0.0 1.0 0.0 -1.0]

    while δ > ε && n_evals < MAX_EVALS
        successful_iteration = false
        for i in 1:4
            if n_evals < MAX_EVALS
                tentative_x = x .+ (δ .* D[:, i])
                if !(all(lb .<= tentative_x .<= ub))
                    if project_bounds
                        tentative_x = project_on_bounds(tentative_x, lb, ub)
                    else
                        continue
                    end
                end
                println(tentative_x)
                bb_eval = bb(tentative_x)
                n_evals += 1
                println(n_evals)

                if bb_eval < f_best
                    x = tentative_x
                    f_best = bb_eval
                    successful_iteration = true
                    break
                end
            end
            if !successful_iteration
                δ *= 0.5
            end
        end
    end

    return (x, f_best)
end