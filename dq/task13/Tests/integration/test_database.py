import pytest
import allure
import yaml


with open('Configs/config_SQL_example.yaml', 'r') as f:
    sql_queries = yaml.safe_load(f)['sql_queries']


def execute_query(cursor, query):
    cursor.execute(query)
    return cursor.fetchall()


@allure.step("Executing SQL query: {description}")
def run_query(cursor, query, description):
    result = execute_query(cursor, query)
    return result


@pytest.mark.smoke
@pytest.mark.parametrize("test_case", sql_queries['smoke_tests'], ids=lambda x: x['description'])
def test_smoke_tests(db_cursor, test_case):
    query = test_case['query']
    description = test_case['description']
    with allure.step(f"Executing smoke test: {description}"):
        result = run_query(db_cursor, query, description)
        assert len(result) > 0, f"Smoke test failed: {description}"


@pytest.mark.critical
@pytest.mark.parametrize("test_case", sql_queries['critical_tests'], ids=lambda x: x['description'])
def test_critical_tests(db_cursor, test_case):
    query = test_case['query']
    description = test_case['description']
    with allure.step(f"Executing critical test: {description}"):
        result = run_query(db_cursor, query, description)
        assert result is not None, f"Critical test failed: {description}"
