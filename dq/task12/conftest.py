import pytest
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

@pytest.fixture(scope='session')
def driver():
    """
    Fixture to initialize and quit the Selenium WebDriver for Chrome.
    Uses automatic driver management provided by Selenium.
    """
    options = Options()
    options.add_argument('--headless')  # Run in headless mode
    options.add_argument('--disable-gpu')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')

    # Initialize the WebDriver using Selenium Manager (automatic driver management)
    driver = webdriver.Chrome(options=options)
    yield driver
    driver.quit()
