
from typing import Any, Dict, List, Tuple


def task_1(data_1: Dict[str, int], data_2: Dict[str, int]):
    combined_dict = data_1.copy()

    for key, value in data_2.items():
        if key in combined_dict:
            combined_dict[key] += value
        else:
            combined_dict[key] = value

    return combined_dict


def task_2():
    result = {i: i ** 2 for i in range(1, 16)}
    return result


def task_3(data: Dict[Any, List[str]]):
    def generate_combinations(key, current_combination):
        if not key:
            combinations.append(current_combination)
            return

        current_key = key[0]
        for letter in data[current_key]:
            generate_combinations(key[1:], current_combination + letter)

    keys = list(data.keys())
    combinations = []
    generate_combinations(keys, "")
    return combinations


def task_4(data: Dict[str, int]):
    if not data:
        return []

    sorted_items = sorted(data.items(), key=lambda item: item[1], reverse=True)
    highest_keys = [item[0] for item in sorted_items[:3]]

    return highest_keys


def task_5(data: List[Tuple[Any, Any]]) -> Dict[str, List[int]]:
    result = {}
    for key, value in data:
        if key in result:
            result[key].append(value)
        else:
            result[key] = [value]
    return result


def task_6(data: List[Any]):
    diction = {}
    result = []
    for i in data:
        if i not in diction:
            diction[i] = 7  # random value does not matter
            result.append(i)
    return result


def task_7(words: [List[str]]) -> str:
    min_size = min([len(x) for x in words])  # find min size string
    result = ""
    for i in range(min_size):
        same = True  # True if all equal at i else false
        for s in words:
            if s[i] != words[0][i]:
                same = False
        if same:
            result += words[0][i]
        else:
            break
    return result


def task_8(haystack: str, needle: str) -> int:
    if needle == "":
        return 0

    index = haystack.find(needle)

    return index
