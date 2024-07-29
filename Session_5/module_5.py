# from collections import Counter
import os
from pathlib import Path
# from random import choice
from random import seed, choice
from typing import List, Union

import requests
from requests import RequestException

# import requests
# from requests.exceptions import ConnectionError
# from gensim.utils import simple_preprocess


S5_PATH = Path(os.path.realpath(__file__)).parent

PATH_TO_NAMES = S5_PATH / "names.txt"
PATH_TO_SURNAMES = S5_PATH / "last_names.txt"
PATH_TO_OUTPUT = S5_PATH / "sorted_names_and_surnames.txt"
PATH_TO_TEXT = S5_PATH / "random_text.txt"
PATH_TO_STOP_WORDS = S5_PATH / "stop_words.txt"


def task_1():
    seed(1)
    # I open names file and split into lines and then lowercasing and sorting
    with open(PATH_TO_NAMES, 'r', encoding='utf-8') as names_file:
        names = names_file.read().splitlines()
        names = [name.lower() for name in names]
        names.sort()

    # reading surnames and splitting into lines
    with open(PATH_TO_SURNAMES, 'r', encoding='utf-8') as surnames_file:
        surnames = surnames_file.read().splitlines()

    # assigning random surnames to names
    sorted_names_and_surnames = [f"{name} {choice(surnames)}" for name in names]

    with open(PATH_TO_OUTPUT, 'w', encoding='utf-8') as output_file:
        for entry in sorted_names_and_surnames:
            output_file.write(f"{entry}\n")


def task_2(top_k: int):
    # reading stop words
    with open(PATH_TO_STOP_WORDS, 'r', encoding='utf-8') as stop_words_file:
        stop_words = set(stop_words_file.read().splitlines())

    # reading random_text file
    with open(PATH_TO_TEXT, 'r', encoding='utf-8') as text_file:
        text = text_file.read().lower()

    # Extract words, keeping only alphabetic tokens
    words = ''.join(char if char.isalpha() else ' ' for char in text).split()

    # removing stop words from the text
    filtered_words = [word for word in words if word not in stop_words]

    # counting how many times words appears, create empty dictionary and every time word appears
    # dictionary will rise word count by one, what way we will know how many times each work appears
    # in the file

    word_counts = {}
    for word in filtered_words:
        if word in word_counts:
            word_counts[word] += 1
        else:
            word_counts[word] = 1

    # sorting in reversing mode the tuple of words and counts and taking the top k
    sorted_word_counts = sorted(word_counts.items(), key=lambda item: item[1], reverse=True)
    top_words = sorted_word_counts[:top_k]

    return top_words


def task_3(url: str):
    try:
        response = requests.get(url)
        response.raise_for_status()
        return response
    except requests.exceptions.HTTPError as e:
        print(f"HTTP error occurred: {e}")
        raise RequestException(f"HTTP error occurred: {e}")
    except RequestException as e:
        print(f"Request exception occurred: {e}")
        raise e


def task_4(data: List[Union[int, str, float]]) -> float:
    sum1 = 0.0
    for i in data:
        try:
            # first trying to add the element to the sum directly
            sum1 += i
        except TypeError:
            try:
                # if a TypeError occurs, convert the element to float and add to the sum
                sum1 += float(i)
            except ValueError as e:
                # if conversion to float fails,then reraise the ValueError
                raise ValueError(f"Cannot convert element to float: {i}") from e
    return sum1


def task_5():
    try:
        # reading variables from input
        x, y = input("Enter two numbers separated by space: ").split()

        # converting them to float

        x = float(x)
        y = float(y)

        # dividing first

        result = x / y
        print(result)
    except ZeroDivisionError:

        #  division by zero error
        print("Can't divide by zero")
    except ValueError:
        #  invalid input
        print("Entered value is wrong")
