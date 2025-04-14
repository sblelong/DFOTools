using Random

function lhs(l, u, p)
    n = length(l)

    Π = [randperm(p) for _ in 1:n]

    x = Vector{Float64}[]
    for i in 1:n
        xi = Float64[]
        for j in 1:p
            rij = rand()
            xij = l[i] + (Π[i][j] - rij) / p * (u[i] - l[i])
            push!(xi, xij)
        end
        push!(x, xi)
    end
    return transpose(hcat(x...))
end