import pytest
import subprocess
import shutil
import psycopg2
import sys


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
        print("\nAllure command not found. Please ensure that Allure is installed and added to your PATH.")
        return

    # Determine the allure results directory from the command line args
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
        alluredir = './reports'  # Default directory

    # Set the output directory
    if '-m' in sys.argv:
        marker_index = sys.argv.index('-m') + 1
        marker = sys.argv[marker_index]
        output_dir = f'./allure-report/{marker}'
    else:
        output_dir = './allure-report/full_suite'

    # Ensure the output directory exists
    subprocess.run(['mkdir', '-p', output_dir], shell=True)

    # Generate the Allure report
    try:
        subprocess.run([
            "allure",
            "generate",
            alluredir,
            "-o",
            output_dir,
            "--clean",
            "--report-dir", output_dir,
            "--single-file"
        ], check=True)
        print(f"\nAllure report successfully generated at {output_dir}")
    except subprocess.CalledProcessError as e:
        print(f"\nError generating Allure report: {e}")
