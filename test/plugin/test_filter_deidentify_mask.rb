require 'test_helper'
require 'fluent/test/driver/filter'
require "fluent/plugin/filter_deidentify.rb"

class DeidentifyFilterTest_mask < Test::Unit::TestCase

  def setup
    Fluent::Test.setup
  end

  sub_test_case 'mask' do
    tests = [
      {
        'name' => 'top, no config', 
        'input' => {
          'c' => 'not-secret',
        },
        'paths' => ['a'],
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
        'expected' => {
          'c' => DEFAULT_MASK,
        }
      },
      {
        'name' => 'custom mask', 
        'input' => {
          'c' => 'not-secret',
        },
        'paths' => ['c'],
        'mask' => 'OHLOOKABIRDIE!',
        'expected' => {
          'c' => 'OHLOOKABIRDIE!',
        }
      },
      {
        'name' => 'top and nested', 
        'input' => {
          'a' => {
            'b' => 'secret',
          },
          'c' => 'also-secret',
        },
        'paths' => ['a.b', 'c'],
        'expected' => {
          'a' => {
            'b' => DEFAULT_MASK,
          },
          'c' => DEFAULT_MASK,
        }
      },
      {
        'name' => 'quadruple nest!?', 
        'input' => {
          'a' => {
            'b' => {
              'c' => {
                'd' => 'secret',
              },
            },
          },
          'c' => 'not-secret',
        },
        'paths' => ['a.b.c.d'],
        'expected' => {
          'a' => {
            'b' => {
              'c' => {
                'd' => DEFAULT_MASK,
              },
            },
          },
          'c' => 'not-secret',
        }
      },
      {
        'name' => 'dont mask non-string', 
        'input' => {
          'c' => 'not-secret',
          'stuff' => {'d' => 'secret'},
        },
        'paths' => ['stuff'],
        'expected' => {
          'c' => 'not-secret',
          'stuff' => {'d' => 'secret'},
        }
      },
      {
        'name' => 'jsonp', 
        'input' => {
          'c' => 'not-secret',
          'sub' => {
            'path' => 'super-secret'
          },
        },
        'paths' => ['c', 'sub.path'],
        'expected' => {
          'c' => DEFAULT_MASK,
          'sub' => {
            'path' => DEFAULT_MASK
          },
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
        mask = t['mask'] ? t['mask'] : DEFAULT_MASK
        mask(r, paths, mask)
        assert_equal(expected, r)
      end
    }
  end

end
