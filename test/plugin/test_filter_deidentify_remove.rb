require 'test_helper'
require 'fluent/test/driver/filter'
require "fluent/plugin/filter_deidentify.rb"

class DeidentifyFilterTest_remove < Test::Unit::TestCase

  def setup
    Fluent::Test.setup
  end

  sub_test_case 'remove' do
    tests = [
      {
        'name' => 'top, no config', 
        'input' => {
          'c' => 'not-secret',
        },
        'paths' => ['d'],
        'expected' => {
          'c' => 'not-secret',
        }
      },
      {
        'name' => 'top', 
        'input' => {
          'c' => 'not-secret',
        },
        'paths' => ['c'],
        'expected' => {}
      },
      {
        'name' => 'top and nested', 
        'input' => {
          'a' => {
            'b' => 'secret',
            'c' => 'secret2',
          },
          'd' => {
            'e' => 'secret',
            'f' => 'secret2',
          }
        },
        'paths' => ['a.b', 'd'],
        'expected' => {
          'a' => {
            'c' => 'secret2',
          },
          'd' => {
            'e' => 'secret',
            'f' => 'secret2',
          }
        }
      },
    ]
    tests.each { |t|
      name = t['name']
      input = t['input']
      paths = t['paths']
      expected = t['expected']

      test name do
        r = input
        remove(r, paths)
        assert_equal(expected, r)
      end
    }
  end

end
