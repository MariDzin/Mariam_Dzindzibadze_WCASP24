from selenium import webdriver
from selenium.webdriver.chrome.options import Options as ChromeOptions
from selenium.webdriver.firefox.options import Options as FirefoxOptions


def open_google_in_chrome():
    chrome_options = ChromeOptions()
    driver = webdriver.Chrome(options=chrome_options)
    driver.get('https://www.google.com')
    print("Chrome Page Title:", driver.title)
    driver.quit()


def open_google_in_firefox():
    firefox_options = FirefoxOptions()
    driver = webdriver.Firefox(options=firefox_options)
    driver.get('https://www.google.com')
    print("Firefox Page Title:", driver.title)
    driver.quit()


if __name__ == '__main__':
    print("Opening Google in Chrome...")
    open_google_in_chrome()
    print("\nOpening Google in Firefox...")
    open_google_in_firefox()
