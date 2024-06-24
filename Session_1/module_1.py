from typing import List


def task_1(array: List[int], target: int) -> List[int]:
    # Initialize an empty dictionary  that saves complementing numbers
    storage = {}

    # go through all the numbers in the array and fild its complementing number
    for i in array:  # 2 3 6 7 8 9      10
        comp_num = target - i
        # check if the comp_num is already in the dictionary
        if comp_num in storage:
            # if yes, return the pair
            return [comp_num, i]
        # if no, add to disct
        storage[i] = True
    # If no pair is found, returning emply list
    return []


def task_2(number: int) -> int:
    if number < 0:
        number = number * -1
        sign = -1
    else:
        sign = 1

    mirror = 0
    while number > 0:
        a = number % 10
        number = number // 10
        mirror = mirror * 10 + a

    return mirror * sign


def task_3(array: List[int]) -> int:
    for i in range(len(array)):
        if array[i] in array[:i]:
            return array[i]

    return -1


def task_4(string: str) -> int:
    roman_to_int = {
        'I': 1,
        'V': 5,
        'X': 10,
        'L': 50,
        'C': 100,
        'D': 500,
        'M': 1000
    }

    total = 0
    n = len(string)

    for i in range(n):

        current_value = roman_to_int[string[i]]
        if i + 1 < n:
            next_value = roman_to_int[string[i + 1]]
            if current_value < next_value:
                total -= current_value
            else:
                total += current_value
        else:
            total += current_value
    return total


def task_5(array: List[int]) -> int:
    a = array[0]
    for i in array:
        if a > i:
            a = i
    return a
