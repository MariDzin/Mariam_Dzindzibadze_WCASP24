from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service as ChromeService
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

# Initialize the WebDriver and set implicit wait
driver = webdriver.Chrome(service=ChromeService(ChromeDriverManager().install()))
driver.implicitly_wait(10)  # Implicit wait for 10 seconds

try:
    #  Open google
    driver.get("https://www.google.com")

    # Accept cookies
    try:
        # Explicit wait to ensure the cookie consent button is present
        consent_button = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.XPATH, "//div[text()='I agree']/ancestor::button"))
        )
        consent_button.click()
    except:
        pass

        #  Find the search box and type
    search_box = driver.find_element(By.NAME, "q")
    search_box.send_keys("Selenium")
    search_box.submit()

    #  Wait  to load
    first_result = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.XPATH, "//h3"))
    )

    #  Click the first link
    first_result.click()

    time.sleep(5)

finally:
    driver.quit()
