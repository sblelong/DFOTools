using Random

function g(z)
    if z[1] * z[5] + z[2] * z[6] + z[3] * z[4] > z[1] * z[6] + z[2] * z[4] + z[3] * z[5]
        return 0
    else
        return 1
    end
end

function monte_carlo(g, θ, r)
    θ1, θ2 = θ
    a = sin(0.5 * θ1)
    c = -a + sin(0.5 * θ1 + θ2)
    b = 1 - cos(0.5 * θ1)
    d = b + cos(0.5 * θ1 + θ2)

    if 0.75 - c - c^2 < 0
        return typemax(Float64)
    end

    h = d - sqrt(0.75 - c - c^2)

    k = 0
    i = 1

    Random.seed!(2352025)

    while i < r
        x = 0.5 * rand()
        y = rand()

        if y > h
            if 2 * (1 - h) * x + y < 1
                x = 0.5 - x
                y = 1 + h - y
            end
            k += g([0, c, x, 1, d, y]) * g([c, 0.5, x, d, h, y])
        else
            if y > 2 * h * x
                x = 0.5 - x
                y = h - y
            end
            k += g([0.5, a, x, h, b, y]) * g([a, 0, x, b, 0, y])
        end
        # println(i)
        i += 1
    end
    println("Final i: $i")
    return -0.5 * (1 + k / r)

end