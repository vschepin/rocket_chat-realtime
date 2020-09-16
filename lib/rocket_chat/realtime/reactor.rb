# frozen_string_literal: true

require 'singleton'
require 'forwardable'

require 'nio'

module RocketChat
  module Realtime
    # The scheduler manager
    #
    # @since 0.1.0
    class Reactor
      class << self
        extend Forwardable

        # @since 0.1.0
        delegate %w[
          selector
          register
          deregister
          registered?
          clients
          run
          stop
          stopped?
          reset
        ] => :instance
      end

      include Singleton

      # @since 0.1.0
      attr_reader :selector, :clients

      # Initialize Reactor
      #
      # @since 0.1.0
      def initialize
        @selector = NIO::Selector.new
        @clients = Set.new
        reset
      end

      # The client is registered
      #
      # @param client [Rocket::Realtime::Client]
      #
      # @return [Boolean]
      #
      # @since 0.1.0
      def registered?(client)
        @clients.include?(client)
      end

      # Register Client
      #
      # @param client [RocketChat::Realtime::Client]
      #
      # @since 0.1.0
      def register(client)
        return if registered?(client)

        @clients.add(client)
        monitor = selector.register(client.connector.socket, :rw)
        monitor.value = client
      end

      # Deregister Client
      #
      # @param client [RocketChat::Realtime::Client]
      #
      # @since 0.1.0
      def deregister(client)
        return unless registered?(client)

        @clients.delete(client)
        selector.deregister(client.connector.socket)
      end

      # Reset reactor state
      #
      # @since 0.1.0
      def reset
        # TODO: Clear clients and registered monitor
        @stopped = false
      end

      # Stop reactor
      #
      # @since 0.1.0
      def stop
        @stopped = true
      end

      # @return [Boolean] the reactor is stopped
      #
      # @since 0.1.0
      def stopped?
        @stopped == true
      end

      # Wait I/O ready for read or write
      #
      # @since 0.1.0
      def run
        @stopped = false
        until stopped?
          selector.select(1) do |monitor|
            monitor.value.process(monitor)
          end
          Thread.pass
        end
      end
    end
  end
end
