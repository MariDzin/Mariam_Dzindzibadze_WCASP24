def test_check_power_bi_tab_visible(open_income_statements_report_webpage):
    report_page = open_income_statements_report_webpage
    assert report_page.is_power_bi_tab_visible(), "Power BI tab is not displayed."


def test_check_revenue_report_title(open_income_statements_report_webpage):
    report_page = open_income_statements_report_webpage
    report_page.switch_to_report_frame()
    report_title = report_page.get_revenue_report_title()
    assert report_title == 'REVENUE (in billions)', "Revenue report title is incorrect."


def test_01_open_decomposition_tree_visualization(open_income_statements_report_webpage):
    report_page = open_income_statements_report_webpage
    report_page.switch_to_report_frame()
    report_title = report_page.get_revenue_report_title()
    assert report_title == 'REVENUE (in billions)'
