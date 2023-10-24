from complex import ComplexSIMD, ComplexFloat64
from math import iota
from algorithm import vectorize
from tensor import Tensor
from time import now
from utils.index import Index


alias float_type = DType.float64
alias simd_width = 2 * simdwidthof[float_type]()

alias xn = 450
alias yn = 375
alias MAX_ITERS = 200

alias xmin = -2.25
alias xmax = 0.75
alias ymin = -1.25
alias ymax = 1.25


# Basic Mandelbrot

# Compute the number of steps to escape.
def mandelbrot_kernel(c: ComplexFloat64) -> Int:
    z = c
    for i in range(MAX_ITERS):
        z = z * z + c
        if z.squared_norm() > 4:
            return i
    return MAX_ITERS


def compute_mandelbrot(yn: Int, xn: Int) -> Tensor[float_type]:
    # create a matrix. Each element of the matrix corresponds to a pixel
    t = Tensor[float_type](yn, xn)

    dx = (xmax - xmin) / xn
    dy = (ymax - ymin) / yn

    y = ymin
    for row in range(yn):
        x = xmin
        for col in range(xn):
            t[Index(row, col)] = mandelbrot_kernel(ComplexFloat64(x, y))
            x += dx
        y += dy
    return t




# Vecotrized Mandelbrot

fn mandelbrot_kernel_SIMD[
    simd_width: Int
](c: ComplexSIMD[float_type, simd_width]) -> SIMD[float_type, simd_width]:
    """A vectorized implementation of the inner mandelbrot computation."""
    let cx = c.re
    let cy = c.im
    var x = SIMD[float_type, simd_width](0)
    var y = SIMD[float_type, simd_width](0)
    var y2 = SIMD[float_type, simd_width](0)
    var iters = SIMD[float_type, simd_width](0)

    var t: SIMD[DType.bool, simd_width] = True
    for i in range(MAX_ITERS):
        if not t.reduce_or():
            break
        y2 = y*y
        y = x.fma(y + y, cy)
        t = x.fma(x, y2) <= 4
        x = x.fma(x, cx - y2)
        iters = t.select(iters + 1, iters)
    return iters

fn compute_mandelbrot_vectorized(yn: Int, xn: Int) -> Tensor[float_type]:
    let t = Tensor[float_type](yn, xn)

    @parameter
    fn worker(row: Int):
        let dx = (xmax - xmin) / xn
        let dy = (ymax - ymin) / yn

        @parameter
        fn compute_vector[simd_width: Int](col: Int):
            """Each time we oeprate on a `simd_width` vector of pixels."""
            let cx = xmin + (col + iota[float_type, simd_width]()) * dx
            let cy = ymin + row * dy
            let c = ComplexSIMD[float_type, simd_width](cx, cy)
            t.data().simd_store[simd_width](row * xn + col, mandelbrot_kernel_SIMD[simd_width](c))

        # Vectorize the call to compute_vector where call gets a chunk of pixels.
        vectorize[simd_width, compute_vector](xn)
    return t


def main():
    let sizes = VariadicList(200, 450, 960, 1980)

    for i in range(len(sizes)):
        var xn = sizes[i]
        var yn = sizes[i]
        let eval_begin: Int = now()  # This is in nanoseconds
        let mandelbrot_set = compute_mandelbrot(xn, yn)
        let eval_end: Int = now()
        let execution_time = (eval_end - eval_begin) / 1e6
        print(execution_time)

        let eval_begin_vec: Int = now()  # This is in nanoseconds
        let mandelbrot_vectorized_set = compute_mandelbrot_vectorized(xn, yn)
        let eval_end_vec: Int = now()
        let execution_time_vec = (eval_end_vec - eval_begin_vec) / 1e6
        print(execution_time_vec)
    
