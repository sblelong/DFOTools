import numpy as np


def g(z):
    if (
        z[0] * z[4] + z[1] * z[5] + z[2] * z[3]
        > z[0] * z[5] + z[1] * z[3] + z[2] * z[4]
    ):
        return 0
    else:
        return 1


def monte_carlo(g, theta, r):
    theta1, theta2 = theta
    a = np.sin(0.5 * theta1)
    c = -a + np.sin(0.5 * theta1 + theta2)
    b = 1 - np.cos(0.5 * theta1)
    d = b + np.cos(0.5 * theta1 + theta2)

    if 0.75 - c - c**2 < 0:
        return np.inf

    h = d - np.sqrt(0.75 - c - c ^ 2)

    k = 0

    for _ in range(1, r + 1):
        x = 0.5 * np.random.uniform()
        y = np.random.uniform()

        if y > h:
            if 2 * (1 - h) * x + y < 1:
                x = 0.5 - x
                y = 1 + h - y
            k += g([0, c, x, 1, d, y]) * g([c, 0.5, x, d, h, y])
        else:
            if y > 2 * h * x:
                x = 0.5 - x
                y = h - y
            k += g([0.5, a, x, h, b, y]) * g([a, 0, x, b, 0, y])

    return -0.5 * (1 + k / r)
