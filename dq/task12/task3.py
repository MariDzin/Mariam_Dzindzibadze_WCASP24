import logging

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from webdriver_manager.chrome import ChromeDriverManager

# Initialize the WebDriver
driver = webdriver.Chrome(service=ChromeService(ChromeDriverManager().install()))
try:
    # Open the demo page
    driver.get("https://phptravels.com/demo/")
    wait = WebDriverWait(driver, 10)

    # Example for Class Name
    first_name_by_class = wait.until(EC.presence_of_element_located((By.CLASS_NAME, "first_name")))
    logging.info(f"Located 'First Name' by class name: {first_name_by_class}")

    # Example for ID

    try:
        example_id_1 = (
            wait.until(EC.presence_of_element_located((By.ID, "address"))))
        logging.info(f"Located element by ID: {example_id_1}")
    except TimeoutException:
        logging.error("Element with ID 'address' could not be found within the timeout period.")

    # Example for Name
    email_field_by_name = (
        wait.until(EC.presence_of_element_located((By.NAME, "email"))))
    logging.info(f"Located 'Email' field by name: {email_field_by_name}")

    # Example for CSS Selector
    first_name_by_css = (
        wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "input.first_name"))))
    logging.info(f"Located 'First Name' by CSS selector: {first_name_by_css}")

    # Example for XPath
    business_name_by_xpath = (
        wait.until(EC.presence_of_element_located((By.XPATH, "//input[@name='business_name']"))))
    logging.info(f"Located 'Business Name' by XPath: {business_name_by_xpath}")

    # Take a screenshot of the page
    driver.save_screenshot("screenshot.png")
    logging.info("Screenshot saved successfully.")

finally:
    # Close the browser
    driver.quit()
