from selenium.common import TimeoutException
from selenium.webdriver.support.ui import WebDriverWait as WDW
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import *


class IncomeStatementsReportPage:
    def __init__(self, driver, delay):
        self.driver = driver
        self.delay = delay

        self.power_bi_button = "//a[@role='tab' and text()='Power BI']"
        self.revenue_report_header = "//div[contains(@title, 'REVENUE')][1]"

    def open_power_bi_report(self):
        power_bi_report_button = WDW(self.driver, self.delay).until(EC.element_to_be_clickable((By.XPATH,
                                                                                                self.power_bi_button)))
        power_bi_report_button.click()

    def switch_to_report_frame(self):
        iframe = self.driver.find_element(By.ID, "mschart")
        self.driver.switch_to.frame(iframe)

    def get_revenue_report_title(self):
        report_header = WDW(self.driver, self.delay).until(EC.element_to_be_clickable((By.XPATH,
                                                                                       self.revenue_report_header)))
        return report_header.get_attribute("title")

    def is_power_bi_tab_visible(self):
        try:
            power_bi_button = WDW(self.driver, self.delay).until(
                EC.element_to_be_clickable((By.XPATH, self.power_bi_button))
            )
            return power_bi_button.is_displayed()
        except TimeoutException:
            return False
