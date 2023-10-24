import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as colors
import time

# Constants
max_iter = 200

xmin = -2.25
xmax = 0.75
ymin = -1.25
ymax = 1.25



# Compute the number of steps to escape
def mandelbrot_kernel(c):
    z = c
    for i in range(max_iter):
        z = z * z + c
        if abs(z) > 2:
            return i
    return max_iter

def mandelbrot(xn, yn):
    # Create a matrix. Each element of the matrix corresponds to a pixel
    result = np.zeros((yn, xn), dtype=np.uint32)

    dx = (xmax - xmin) / xn
    dy = (ymax - ymin) / yn

    y = ymin
    for j in range(yn):
        x = xmin
        for i in range(xn):
            result[j, i] = mandelbrot_kernel(complex(x, y))
            x += dx
        y += dy
    return result


def mandelbrot_vectorized(xn, yn, max_iter=200):
    # Define the boundaries of the complex plane
    xmin = -2.25
    xmax = 0.75
    ymin = -1.25
    ymax = 1.25

    # Create the grid of complex numbers
    x = np.linspace(xmin, xmax, xn)
    y = np.linspace(ymin, ymax, yn)
    c = np.array([[complex(re, im) for re in x] for im in y])

    # Initialize the Mandelbrot set and iteration count array
    mandelbrot_set = np.zeros((yn, xn), dtype=np.uint32)
    iter_count = np.zeros_like(mandelbrot_set)

    # Initialize the z values with the complex grid
    z = c.copy()

    # Iterate over each point using vectorized operations
    for i in range(max_iter):
        # Update z values based on the Mandelbrot equation
        z = z**2 + c
        # Update the iteration count for points that have not escaped
        iter_count[(np.abs(z) < 2) & (mandelbrot_set == 0)] = i
        # Mark points that have escaped
        mandelbrot_set[np.abs(z) >= 2] = 1

    # Replace points that never escaped with the maximum iteration count
    iter_count[mandelbrot_set == 0] = max_iter

    return iter_count


import warnings
warnings.filterwarnings("ignore")
def main():
    sizes = [200, 450, 960, 1980]

    for size in sizes:
        xn = yn = size
        functions = [{'name':'Mandelbrot','function':mandelbrot,'args':[xn, yn]},
                 {'name':'Mandelbrot Vectorized', 'function': mandelbrot_vectorized, 'args':[xn,yn]},
                 ]
        for func in functions:
            start_time = time.time()
            mandelbrot_set = func['function'](*func['args'])
            end_time = time.time()
            execution_time = (end_time - start_time) * 1000  # Make it milliseconds
            print(f"{execution_time}")


if __name__=="__main__":
    main()