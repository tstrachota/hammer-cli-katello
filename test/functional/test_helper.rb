require File.join(File.dirname(__FILE__), '../test_helper')

require 'hammer_cli_foreman/testing/functional/command_assertions'
require 'hammer_cli_foreman/testing/functional/api_expectations'

include HammerCLIForeman::Testing::Functional::CommandAssertions
include HammerCLIForeman::Testing::Functional::APIExpectations
