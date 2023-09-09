from benchmark import Benchmark
from sys.intrinsics import strided_load
from utils.list import VariadicList
from math import div_ceil, min
from memory import memset_zero
from memory.unsafe import DTypePointer
from random import rand, random_float64
from sys.info import simdwidthof
from time import now

def matmul_untyped(C, A, B):
    for m in range(C.rows):
        for k in range(A.cols):
            for n in range(C.cols):
                C[m, n] += A[m, k] * B[k, n]

fn matrix_getitem(self: object, i: object) raises -> object:
    return self.value[i]

fn matrix_setitem(self: object, i: object, value: object) raises -> object:
    self.value[i] = value
    return None


fn matrix_append(self: object, value: object) raises -> object:
    self.value.append(value)
    return None


fn matrix_init(rows: Int, cols: Int) raises -> object:
    let value = object([])
    return object(
        Attr("value", value), Attr("__getitem__", matrix_getitem), Attr("__setitem__", matrix_setitem), 
        Attr("rows", rows), Attr("cols", cols), Attr("append", matrix_append),
    )

def benchmark_matmul_untyped(M: Int, N: Int, K: Int):
    C = matrix_init(M, N)
    A = matrix_init(M, K)
    B = matrix_init(K, N)
    for i in range(M):
        c_row = object([])
        b_row = object([])
        a_row = object([])
        for j in range(N):
            c_row.append(0.0)
            b_row.append(random_float64(-5, 5))
            a_row.append(random_float64(-5, 5))
        C.append(c_row)
        B.append(b_row)
        A.append(a_row)

    @parameter
    fn test_fn():
        try:
            _ = matmul_untyped(C, A, B)
        except:
            pass

    let secs = Float64(Benchmark().run[test_fn]()) / 1_000_000_000
    _ = (A, B, C)
    let gflops = ((2*M*N*K)/secs) / 1e9
    return gflops


def main():
    counter = 16
    while counter <= 256:
        let toc = now()
        let gflops = benchmark_matmul_untyped(counter, counter, counter)
        let tic = now()
        counter *=2
        let time = ((tic-toc) / 1000000000)
        print(gflops)
        print(time.value)