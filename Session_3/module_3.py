# import time
import time
from typing import List

Matrix = List[List[int]]


def task_1(exp: int):
    return lambda x: x ** exp





def task_2(*args, **kwargs):
    for i in args:
        print(i)

    for i in kwargs.items():
        print(i[1])


def helper(func):
    def wrapper(name):
        print("Hi, friend! What's your name?")
        func(name)
        print("See you soon!")

    return wrapper


@helper
def task_3(name: str):
    print(f"Hello! My name is {name}.")


def timer(func):
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        run_time=end-start
        print(f"Finished {func.__name__} in {run_time:.4f} secs")
        return result

    return wrapper

@timer
def task_4():
    return len([1 for _ in range(0, 10 ** 8)])

task_4()

def task_5(matrix: Matrix) -> Matrix:
    transposed = []
    for i in range(len(matrix[0])):
        column = []
        for row in matrix:
            column.append(row[i])
        transposed.append(column)
    return transposed


def task_6(queue: str):
    pass
