export nelder_mead

"""
    Assuming the blackbox is expensive to call, we're better off retrieving the values of the objective used to sort the simplex.

    TODO: do NOT recompute all the values of the blakcbox for each sorting procedure. Only 1 vertex is modified each time.
"""
function sort_vertices!(Y::Vector{Vector{Float64}}, obj::Function)
    obj_values = map(obj, Y)
    sorted_indices = sortperm(obj_values)
    new_Y = Y[sorted_indices]
    obj_values = obj_values[sorted_indices]

    return new_Y, obj_values
end

function shrink(Y::Vector{Vector{Float64}}, γ::Float64)
    new_Y = [Y[1] + γ .* (Y[i] .- Y[1]) for i in 1:length(Y)]
    return new_Y
end

function nelder_mead(obj::Function, Y0::Vector{Vector{Float64}}, STOP_CRIT::Function; δe::Float64=2.0, δoc::Float64=0.5, δic::Float64=-0.5, γ::Float64=0.5)
    # 0. Initializations
    Y = Y0
    k = 0
    n = length(Y) - 1

    n_reflects, n_expansions, n_outside, n_inside, n_shrinks = 0, 0, 0, 0, 0

    while STOP_CRIT(Y, k) == false
        # 1. Sort vertices of the simplex Y and collect the objective values linked
        Y, fvals = sort_vertices!(Y, obj)

        if k < 50
            println("Current simplex: $Y")
        end

        # 2. Reflect
        xc = 1 / n .* sum.(Y[1:end-1])
        xr = xc .+ (xc .- Y[end])
        fr = obj(xr)

        # 3. Switch on the reflection values
        if fvals[1] ≤ fr && fr < obj(Y[end-1])
            Y[end] = xr
            println("Reflection")
            n_reflects += 1
        elseif fr < fvals[1] # Expansion
            xe = xc .+ δe .* (xc .- Y[end])
            fe = obj(xe)
            if fe < fr
                Y[end] = xe
                println("Expansion")
                n_expansions += 1
            else
                Y[end] = xr
                println("Reflecion")
                n_reflects += 1
            end
        elseif fr ≥ fvals[end-1] && fr < fvals[end] # Outside contraction
            xoc = xc .+ δoc .* (xc .- Y[end])
            foc = obj(xoc)
            if foc < fr
                Y[end] = xoc
                println("Outer contraction")
                n_outside += 1
            else
                Y[end] = xr
                println("Reflection")
                n_reflects += 1
            end
        elseif fr ≥ fvals[end] # Inside contraction
            xic = xc .+ δic .* (xc - Y[end])
            fic = obj(xic)
            if fic < fvals[end]
                Y[end] = xic
                println("Inner contraction")
                n_inside += 1
            else
                Y = shrink(Y, γ)
                println("Shrink")
                n_shrinks += 1
            end
        else # Shrink
            Y = shrink(Y, γ)
            println("Shrink")
            n_shrinks += 1
        end

        k += 1
    end

    Y, fvals = sort_vertices!(Y, obj)
    println("### End of Nelder-Mead procedure")
    println("Total numer of iterations: $k")
    println("Best cost: $(fvals[1])")
    println("Successful reflexions: $n_reflects")
    println("Successful expansions: $n_expansions")
    println("Successful outside contractions: $n_outside")
    println("Successful inside contractions: $n_inside")
    println("Shrinks: $n_shrinks")

    return Y
end