import os
import sys
import yaml
from selenium import webdriver
from webdriver_manager.chrome import ChromeDriverManager
import pytest
from Pages import IncomeStatementReportPage
import subprocess
import shutil
import psycopg2


def get_selenium_config(config_name):
    module_dir = os.path.dirname(os.path.abspath(sys.modules[__name__].__file__))
    parent_dir = os.path.dirname(module_dir)
    with open(os.path.join(parent_dir, 'Configs', config_name), 'r') as stream:
        config = yaml.safe_load(stream)
    return config['global']


@pytest.fixture(scope="function")
def open_income_statements_report_webpage():
    report_uri = get_selenium_config('config_selenium.yaml')['report_uri']
    delay = get_selenium_config('config_selenium.yaml')['delay']
    driver = webdriver.Chrome(ChromeDriverManager().install())
    driver.set_window_size(1024, 600)
    driver.maximize_window()
    driver.get(report_uri)

    income_report = IncomeStatementReportPage(driver, delay)
    income_report.open_power_bi_report()
    yield income_report
    driver.close()


@pytest.fixture(scope='session')
def db_connection():
    """Fixture to create a database connection."""
    conn = psycopg2.connect(
        database="dwh_hw_db",
        user='postgres',
        password='Nickkoala19',
        port='5432'
    )
    yield conn
    conn.close()


@pytest.fixture(scope='session')
def db_cursor(db_connection):
    """Fixture to create a database cursor."""
    cursor = db_connection.cursor()
    yield cursor
    cursor.close()


def pytest_sessionfinish(session, exitstatus):
    """Generate Allure report after test session is finished."""
    # Check if the Allure command is available
    allure_command = shutil.which("allure")
    if allure_command is None:
        print("\nAllure command not found")
        return

    alluredir = None
    for i, arg in enumerate(sys.argv):
        if arg.startswith('--alluredir'):
            if '=' in arg:
                alluredir = arg.split('=')[1]
            else:
                if len(sys.argv) > i + 1:
                    alluredir = sys.argv[i + 1]
            break
    if alluredir is None:
        alluredir = './reports'

    # Set the output directory
    if '-m' in sys.argv:
        marker_index = sys.argv.index('-m') + 1
        marker = sys.argv[marker_index]
        output_dir = f'./allure-report/{marker}'
    else:
        output_dir = './allure-report/full_suite'

    # Ensure the output directory exists
    os.makedirs(output_dir, exist_ok=True)

    # Generate the Allure report
    try:
        subprocess.run([
            allure_command,
            "generate",
            alluredir,
            "-o",
            output_dir,
            "--clean"
        ], check=True)
        print(f"\nAllure report successfully generated at {output_dir}")
    except subprocess.CalledProcessError as e:
        print(f"\nError generating Allure report: {e}")
