import pytest
import yaml


def get_numbers_data(config_name):
    with open(config_name, 'r') as stream:
        config = yaml.safe_load(stream)
    return config['cases']


def add_numbers(a, b, c):
    try:
        return a + b + c
    except TypeError:
        raise TypeError('Please check the parameters. All of them must be numeric')


@pytest.mark.smoke
@pytest.mark.parametrize(
    "case",
    get_numbers_data('config.yaml'),
    ids=lambda case: case['case_name']
)
def test_add_numbers(case):
    a, b, c = case['input']
    expected = case['expected']
    result = add_numbers(a, b, c)
    assert result == expected


@pytest.mark.critical
def test_add_invalid_types():
    a, b, c = 'a', 2, 1
    with pytest.raises(TypeError) as exc_info:
        add_numbers(a, b, c)
    assert 'Please check the parameters. All of them must be numeric' in str(exc_info.value)
