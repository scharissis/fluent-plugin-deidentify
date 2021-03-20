require 'test_helper'
require 'fluent/test/driver/filter'
require "fluent/plugin/filter_deidentify.rb"

class DeidentifyFilterTest < Test::Unit::TestCase

  DEFAULT_TEST_CONFIG = %|
    <masker>
      paths ["secrets.email"]
      mask OOPSIE
    </masker>

    <remover>
      paths ["secrets.password"]
    </remover>

    <replacer>
      regex "/users/\d+"
      replacement "/users/{id}"
    </replacer>

    <replacer>
      regex /sensitive/i
      replacement '<sensitive>'
    </replacer>
  |

  def create_driver(conf=DEFAULT_TEST_CONFIG)
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::DeidentifyFilter).configure(conf)
  end

  def setup
    Fluent::Test.setup
  end

  sub_test_case 'configure' do
    test 'empty' do
      # assert_raise(Fluent::ConfigError) do
      #   create_driver('')
      # end
    end
    test 'default' do
      d = create_driver()
    end
  end

  sub_test_case 'emit events' do
    test 'simple records' do
      d = create_driver()
      d.run(default_tag: 'test') do
        d.feed({'log' => 'Sensitive Info'})
        d.feed({'secrets' => {'password' => 'hunter1', 'email' => 'hunt@er.com'}})
        d.feed({'secrets' => {'users' => '/users/1337'}})
      end
      assert_equal(3, d.filtered_records.size)
      assert_equal(d.filtered_records[0], {'log' => '<sensitive>'})
      assert_equal(d.filtered_records[1], {'secrets' => {'email' => 'OOPSIE'}})
      assert_equal(d.filtered_records[2], {'secrets' => {'users' => '/users/{id}'}})
    end
  end
end
