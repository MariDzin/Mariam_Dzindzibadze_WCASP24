from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service as ChromeService
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException  # Correct import
import time

# Initialize the WebDriver and set implicit wait
driver = webdriver.Chrome(service=ChromeService(ChromeDriverManager().install()))
driver.implicitly_wait(10)  # Implicit wait for 10 seconds

try:
    #  Open google
    driver.get("https://www.google.com")

    #  cookie consent
    try:

        consent_button = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.XPATH, "//div[text()='I agree']/ancestor::button"))
        )
        consent_button.click()
    except TimeoutException:
        print("Cookie consent button not found within the timeout period.")
    except NoSuchElementException:
        print("Cookie consent button element could not be found on the page.")

    #   type 'Selenium'
    search_box = driver.find_element(By.NAME, "q")
    search_box.send_keys("Selenium")
    search_box.submit()

    #  Wait  results and chose 1st one
    try:
        first_result = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.XPATH, "//h3"))
        )
        first_result.click()
    except TimeoutException:
        print("Search results took too long to load.")
    except NoSuchElementException:
        print("First search result not found on the page.")

    time.sleep(5)  # Wait for the page to load

finally:
    driver.quit()
