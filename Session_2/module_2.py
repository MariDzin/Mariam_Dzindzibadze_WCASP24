from typing import Any, Dict, List, Tuple


def task_1(data_1: Dict[str, int], data_2: Dict[str, int]):
    combined_dict = data_1.copy()

    for key, value in data_2.items():
        if key in combined_dict:
            combined_dict[key] += value
        else:
            combined_dict[key] = value

    return combined_dict


# first I created dictionary1 copy then with for loop if key is in the
# dictionary then value will be  increased, if not in
# the dictionary I  add key and value

def task_2():
    result = {i: i ** 2 for i in range(1, 16)}
    return result


# returning result where for each i(key) value will be I in square
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


# here  function considers all possible combinations of letters
# associated with each key.

def task_4(data: Dict[str, int]):
    if not data:
        return []

    sorted_items = sorted(data.items(), key=lambda item: item[1], reverse=True)
    highest_keys = [item[0] for item in sorted_items[:3]]

    return highest_keys


# in this task I sorted data and  from sorted I chose first 3 or if nothing
# in the data then  empty list will be returned

def task_5(data: List[Tuple[Any, Any]]) -> Dict[str, List[int]]:
    result = {}
    for key, value in data:
        if key in result:
            result[key].append(value)
        else:
            result[key] = [value]
    return result


# here I created dictionary result, then go thought key value, and if
# key is in result then values will  append for the same key and if it is
# not seen in the dictionary then I just add key and value in the dictionary


def task_6(data: List[Any]):
    seen = set()
    result = []
    for item in data:
        if item not in seen:
            seen.add(item)
            result.append(item)
    return result


# If an element is not in seen then the first time it appears
# I add it to both the seen set and the result list.
# This way each  element appears only once in the result list, as set it not saving
# duplicates


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

    len_haystack = len(haystack)
    len_needle = len(needle)

    for i in range(len_haystack - len_needle + 1):
        if haystack[i:i + len_needle] == needle:
            return i

    return -1

# here the idea is go thought  the haystack string and check substrings of
# length equal to the needle. # If we find a match, then returning the
# starting index of the match and  If no match, return -1.
