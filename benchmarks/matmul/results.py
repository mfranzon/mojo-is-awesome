import matplotlib.pyplot as plt

# Define two empty lists to store the values
py_odd_lines_list = []
py_even_lines_list = []

mj_odd_lines_list = []
mj_even_lines_list = []

# Read the first file
with open("matmul/py.perf", "r") as file:
    lines = file.readlines()
    for i, line in enumerate(lines):
        if i % 2 == 0:  # Even lines
            py_even_lines_list.append(float(line.strip()))
        else:  # Odd lines
            py_odd_lines_list.append(float(line.strip()))

# Read the second file
with open("matmul/mj.perf", "r") as file:
    lines = file.readlines()
    for i, line in enumerate(lines):
        if i % 2 == 0:  # Even lines
            mj_even_lines_list.append(float(line.strip()))
        else:  # Odd lines
            mj_odd_lines_list.append(float(line.strip()))

# Create a plot
plt.figure(1)
plt.subplot(211)
plt.plot(py_odd_lines_list, label="Python")
plt.plot(mj_odd_lines_list, label="Mojo")
x = [16, 32, 64, 128, 256]
default_x_ticks = range(len(x))
plt.xticks(default_x_ticks, x)

plt.ylabel("sec")
plt.title("Matrix multiplication Python vs. Mojo")

plt.legend()

plt.subplot(212)
plt.plot(py_even_lines_list, label="Python")
plt.plot(mj_even_lines_list, label="Mojo")

plt.xticks(default_x_ticks, x)

plt.xlabel("Input")
plt.ylabel("GFLOP/s")


# Show the plot
plt.savefig("matmul/plot_time_gflops.png")
