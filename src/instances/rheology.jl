strain = [0.0137, 0.0274, 0.0434, 0.0866, 0.137, 0.274, 0.434, 0.866, 1.37, 2.74, 4.34, 5.46, 6.88]
viscosity = [3220, 2190, 1640, 1050, 766, 490, 348, 223, 163, 104, 76.7, 68.1, 58.2]
N = length(strain)

function ε(i, x)
    η0, λ, β = x
    return abs(η0 * (1 + λ^2 * strain[i]^2)^((β - 1) / 2) - viscosity[i])
end

rh1(x) = sum([ε(i, x) for i in 1:N])
rh2(x) = sum([ε(i, x)^2 for i in 1:N])

function rh3(x)
    if all(0 .≤ x .≤ 20)
        return rh1(x .* [520, 14, 0.038])
    else
        return typemax(Float64)
    end
end

function rh4(x)
    if all(0 .≤ x .≤ 20)
        return rh2(x .* [520, 14, 0.038])
    else
        return typemax(Float64)
    end
end