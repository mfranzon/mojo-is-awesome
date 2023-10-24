import matplotlib.pyplot as plt

py_odd_lines_list = []
py_even_lines_list = []

mj_odd_lines_list = []
mj_even_lines_list = []

with open("mandelbrot/py.perf", "r") as file:
    lines = file.readlines()
    for i, line in enumerate(lines):
        if i % 2 == 0:
            py_even_lines_list.append(float(line.strip()))
        else:
            py_odd_lines_list.append(float(line.strip()))

with open("mandelbrot/mj.perf", "r") as file:
    lines = file.readlines()
    for i, line in enumerate(lines):
        if i % 2 == 0:
            mj_even_lines_list.append(float(line.strip()))
        else:
            mj_odd_lines_list.append(float(line.strip()))

# plot
plt.figure(1)
plt.subplot(211)
plt.plot(py_odd_lines_list, label="Python")
plt.plot(mj_odd_lines_list, label="Mojo")
x = [200, 450, 960, 1980]
default_x_ticks = range(len(x))
plt.xticks(default_x_ticks, x)

plt.ylabel("ms")
plt.title("Mandelbrot Python vs. Mojo")

plt.legend()

plt.subplot(212)
plt.plot(py_even_lines_list, label="Python")
plt.plot(mj_even_lines_list, label="Mojo")

plt.xticks(default_x_ticks, x)

plt.xlabel("Size in px")
plt.ylabel("ms")
plt.title("Vectorized Mandelbrot Python vs. Mojo")
plt.tight_layout()

plt.savefig("mandelbrot/plot_time.png")