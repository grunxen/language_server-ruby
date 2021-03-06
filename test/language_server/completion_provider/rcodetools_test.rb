require 'test_helper'

module LanguageServer
  module CompletionProvider
    class RcodetoolsTest < Minitest::Test
      def setup
        @uri = "file:///foo.rb"
      end

      def teardown
        FileStore.clear
      end

      def test_array
        FileStore[@uri] = <<~EOS
          [].l
        EOS

        provider = Rcodetools.new(@uri, 0, 4)

        candidates = [
          Candidate.new(method_name: "last",   description: "Array#last"),
          Candidate.new(method_name: "lazy",   description: "Enumerable#lazy"),
          Candidate.new(method_name: "length", description: "Array#length")
        ]

        assert { provider.call == candidates }
      end

      def test_no_candidates
        FileStore[@uri] = <<~EOS
          [].not_exists
        EOS

        provider = Rcodetools.new(@uri, 0, 13)

        assert { provider.call == [] }
      end

      def test_syntax_error
        FileStore[@uri] = <<~EOS
          class Foo
          [].l
        EOS

        provider = Rcodetools.new(@uri, 1, 4)

        assert { provider.call == [] }
      end

      def test_runtime_error
        FileStore[@uri] = <<~EOS
          require "not_exists"
          [].l
        EOS

        provider = Rcodetools.new(@uri, 1, 4)

        assert { provider.call == [] }
      end
    end
  end
end
