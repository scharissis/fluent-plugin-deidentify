require 'test_helper'
require 'fluent/test/driver/filter'
require "fluent/plugin/filter_deidentify.rb"

class DeidentifyFilterTest_replace < Test::Unit::TestCase

  def setup
    Fluent::Test.setup
  end

  sub_test_case 'replace' do
    tests = [
      {
        'name' => 'simple path', 
        'input' => {
          'path' => '/a/path',
        },
        'regex' => /\/a\/path/,
        'replacement' => '<redacted_path>',
        'expected' => {
          'path' => '<redacted_path>',
        }
      },
      {
        'name' => 'simple path with int', 
        'input' => {
          'users' => '/users/42',
        },
        'regex' => /\/users\/\d+/,
        'replacement' => '/users/{id}',
        'expected' => {
          'users' => '/users/{id}',
        }
      },
      {
        'name' => 'simple path - as a string', 
        'input' => {
          'path' => '/secrets/42',
        },
        #'regex' => "/secrets/\\d+",
        'regex' => '/secrets/\d+',
        'replacement' => '/secrets/{id}',
        'expected' => {
          'path' => '/secrets/{id}',
        }
      },
      {
        'name' => 'simple array', 
        'input' => {
          'paths' => ['/a/path', '/b/path'],
        },
        'regex' => /\/a\/path/,
        'replacement' => '<redacted_path>',
        'expected' => {
          'paths' => ['/a/path', '/b/path'],
        }
      },
      { # "(/employees/.{2})(.+)(.{3}/groups/showall)" => "/employees/{employeeId}/groups/showall",
        'name' => 'example 1', 
        'input' => { 'event' => {
          'basepath' => '/employees/99ab123/groups/showall',
        }},
        'regex' => /(\/employees\/.{2})(.+)(.{3}\/groups\/showall)/,
        'replacement' => '/employees/{employeeId}/groups/showall',
        'expected' => { 'event' => {
          'basepath' => '/employees/{employeeId}/groups/showall',
        }}
      },
      { # "(/employees/.{2})(.+)(.{3}/groups/showall)" => "/employees/{employeeId}/groups/showall",
        'name' => 'example 1 - string', 
        'input' => { 'event' => {
          'basepath' => '/employees/99ab123/groups/showall',
        }},
        'regex' => "(\/employees\/.{2})(.+)(.{3}\/groups\/showall)",
        'replacement' => '/employees/{employeeId}/groups/showall',
        'expected' => { 'event' => {
          'basepath' => '/employees/{employeeId}/groups/showall',
        }}
      },
    ]
    tests.each { |t|
      name = t['name']
      input = t['input']
      regex = t['regex']
      replacement = t['replacement']
      expected = t['expected']
      
      test name do
        r = input
        replace(r, regex, replacement)
        assert_equal(expected, r)
      end
    }
  end

end
