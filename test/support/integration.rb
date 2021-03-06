require_relative 'simulated_user'
require_relative 'simulated_check_in_user'

module Support
  module Integration
    def sign_in_as(user_type)
      visit login_path
      select user_type, :from => 'System type'
      fill_in 'Password', :with => 'temp123'
      click_button 'Log in'
    end

    def press_okay_in_dialog
      handle_js_confirm
    end

    def press_cancel_in_dialog
      handle_js_confirm(false)
    end

    def handle_js_confirm(accept=true)
      page.evaluate_script "window.original_confirm_function = window.confirm"
      page.evaluate_script "window.confirm = function(msg) { return #{!!accept}; }"
    ensure
      page.evaluate_script "window.confirm = window.original_confirm_function"
    end

    def admin_navigation
      find("#tabnav")
    end

    def admin_current_tab_is?(tab_name)
      admin_navigation.find(:xpath, "//li[@class='current']").text == tab_name
    end

    def page_header_text
      find('h1').text
    end

    def sign_out
      visit logout_path
    end

    def assert_css(css, options={})
      assert has_css?(css, options),
        "CSS #{css.inspect} with options #{options.inspect} does not exist"
    end

    def assert_current_path(expected_path)
      assert_equal expected_path, current_path
    end

    def assert_errors(*error_list)
      within "#errorExplanation" do
        error_list.each do |error_message|
          assert_content error_message
        end
      end
    end

    def assert_field(label, options={})
      assert has_field?(label, options),
        "Field #{label.inspect} with options #{options.inspect} does not exist"
    end

    def assert_no_field(label, options={})
      assert has_no_field?(label, options),
        "Field #{label.inspect} with options #{options.inspect} exists"
    end

    def assert_field_value(field, value)
      assert_equal value, find_field(field).value
    end

    def assert_flash(message)
      assert has_css?('#flash', :text => message),
        "Flash #{message.inspect} does not exist in the page"
    end

    def assert_link(text)
      assert has_link?(text), "Link #{text} does not exist in the page"
    end

    def assert_no_link(text)
      assert has_no_link?(text), "Link #{text} exists in the page"
    end

    def assert_link_to(url, options={})
      assert_css "a[href='%s']" % url, options
    end

    def assert_content(content)
      assert has_content?(content), "Content #{content.inspect} does not exist"
    end

    def assert_no_content(content)
      assert has_no_content?(content), "Content #{content.inspect} exist"
    end

    def assert_title(title)
      within('title') do
        assert has_content?(title), "Title #{title.inspect} does not exist"
      end
    end

    def click_link_within(scope, text)
      within(scope) { click_link(text) }
    end

    def simulated_user(type)
      case type
      when "Check in"
        Support::SimulatedCheckInUser.new(self)
      else
        raise ArgumentError.new("Unsupported simulated user type")
      end
    end

    def select_printer(printer_name = 'printer')
      within("#printer-dropdown") do
        first('a').click
        click_link printer_name
        page.wont_have_css '#printer-dropdown.open'
      end
    end

    def ss
      screenshot_and_open_image
    end
  end
end
