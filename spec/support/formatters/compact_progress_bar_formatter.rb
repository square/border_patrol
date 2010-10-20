# Originally by Nicholas A. Evans. See LICENSE.txt at
# http://gist.github.com/275257
#
# Note: includes modifications from the original to use '=' for the progress
# bar mark and keep the cursor from hopping all around during the animation.
#
# This version is compatible with RSpec 1.2.9 and ProgressBar 0.9.0.

require 'spec/runner/formatter/base_text_formatter'
require 'progressbar'

module Spec
  module Runner
    module Formatter
      class CompactProgressBarFormatter < BaseTextFormatter
        # Threshold for slow specs, in seconds.
        # Anything that takes longer than this will be printed out
        THRESHOLD = 1.0 unless defined?(THRESHOLD)

        attr_reader :total, :current

        def start(example_count)
          @current     = 0
          @total       = example_count
          @error_state = :all_passing
          @pbar        = ProgressBar.new("#{example_count} examples", example_count, output)
          @pbar.instance_variable_set("@bar_mark", "=")
        end

        def example_started(example)
          super
          @start_time = Time.now
        end

        def example_passed(example)
          print_warning_if_slow(example_group.description,
                                example.description,
                                Time.now - @start_time)
          increment
        end

        def example_pending(example, message, deprecated_pending_location=nil)
          immediately_dump_pending(example.description, message, pending_caller)
          mark_error_state_pending
          increment
        end

        def example_failed(example, counter, failure)
          immediately_dump_failure(counter, failure)
          mark_error_state_failed
          increment
        end

        def start_dump
          with_color do
            @pbar.finish
          end
          output.flush
        end

        def dump_failure(*args)
          # no-op; we summarized failures as we were running
        end

        def method_missing(sym, *args)
          # ignore
        end

        # Adapted from BaseTextFormatter#dump_failure
        def immediately_dump_failure(counter, failure)
          erase_current_line
          output.print "#{counter.to_s}) "
          output.puts colorize_failure("#{failure.header}\n#{failure.exception.message}", failure)
          output.puts format_backtrace(failure.exception.backtrace)
          output.puts
        end

        # Adapted from BaseTextFormatter#dump_pending
        def immediately_dump_pending(desc, msg, called_from)
          erase_current_line
          output.puts yellow("PENDING SPEC:") + " #{desc} (#{msg})"
          output.puts "  Called from #{called_from}" if called_from
        end

        def increment
          with_color do
            @current += 1
            # Since we're constantly erasing the line, make sure the progress is
            # printed even when the bar hasn't changed
            @pbar.instance_variable_set("@previous", 0)
            @pbar.instance_variable_set("@title", "  #{current}/#{total}")
            @pbar.inc
          end
          output.flush
        end

        ERROR_STATE_COLORS = {
          :all_passing  => "\e[32m", # green
          :some_pending => "\e[33m", # yellow
          :some_failed  => "\e[31m", # red
        } unless defined?(ERROR_STATE_COLORS)

        def with_color
          output.print "\e[?25l" + ERROR_STATE_COLORS[@error_state] if colour?
          yield
          output.print "\e[0m\e[?25h" if colour?
        end

        def mark_error_state_failed
          @error_state = :some_failed
        end

        def mark_error_state_pending
          @error_state = :some_pending unless @error_state == :some_failed
        end

        def erase_current_line
          output.print "\e[K"
        end

        def print_warning_if_slow(group, example, elapsed)
          if elapsed > THRESHOLD
            erase_current_line
            output.print yellow("SLOW SPEC: #{sprintf("%.4f", elapsed)} ")
            output.print " #{group} #{example}"
            output.puts
          end
        end

      end
    end
  end
end
