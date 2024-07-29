# import time
import time
from typing import List

Matrix = List[List[int]]


def task_1(exp: int):
    def power_function(x):
        return x ** exp

    return power_function


# The task_1 function defines an inner function power_function
# that takes a  single  argument x and returns x raised
# to the power of exp.

def task_2(*args, **kwargs):
    for i in args:
        print(i)

    for i in kwargs.items():
        print(i[1])


# go thought args and print and go thought all kwargs items
# and print them too


def helper(func):
    def wrapper(name):
        print("Hi, friend! What's your name?")
        func(name)
        print("See you soon!")

    return wrapper


@helper
def task_3(name: str):
    print(f"Hello! My name is {name}.")


# helper as decorator works the way that  helper is called instead
# of task_3 but everytime instead of func(name) in wrapper
# task three will be called there


def timer(func):
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        run_time = end - start
        print(f"Finished {func.__name__} in {run_time:.4f} secs")
        return result

    return wrapper


@timer
def task_4():
    return len([1 for _ in range(0, 10 ** 8)])


task_4()


# here, decorator is used

def task_5(matrix: Matrix) -> Matrix:
    transposed = []
    for i in range(len(matrix[0])):
        column = []
        for row in matrix:
            column.append(row[i])
        transposed.append(column)
    return transposed


# here I iterate over the columns of the original matrix, constructs new
# rows for the transposed matrix, and appends them to the result.
#  converting rows to columns and columns to rows.


def task_6(queue: str):
    pass
