# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RocketChat::Realtime::Client do
  let(:options) do
    {
      server: 'wss://example.com'
    }
  end
  let(:client) { described_class.new(options) }

  describe '#endpoint' do
    subject { client.endpoint }

    it { is_expected.to eq('wss://example.com/websocket') }
  end

  describe '#connector' do
    subject { client.connector }

    it { is_expected.to be_a(RocketChat::Realtime::Connector) }
  end

  describe '#adapter' do
    subject { client.adapter }

    it { is_expected.to be_a(RocketChat::Realtime::Adapter) }
  end

  describe '#driver' do
    subject { client.driver }

    it { is_expected.to be_a(WebSocket::Driver::Client) }
  end

  describe '#connect' do
    subject(:connect) { client.connect }

    it { expect { connect }.to change(RocketChat::Realtime::Reactor.clients, :count).by(1) }
  end

  describe '#disconnect' do
    subject(:disconnect) { client.disconnect }

    before { client.connect }

    it { expect { disconnect }.to change { RocketChat::Realtime::Reactor.registered?(client) }.to(false) }
  end

  describe '#process' do
    subject(:process) { client.process(monitor) }

    let(:addr) { '127.0.0.1' }

    # TODO: Fix IO::EAGAINWaitReadable error
    let(:server) { TCPServer.new(addr, 0) }
    let(:port) { server.local_address.ip_port }
    let(:socket) { TCPSocket.new(addr, port) }

    let(:selector) { NIO::Selector.new }
    let(:monitor) { selector.register(socket, :rw) }

    before { server }

    after do
      server.close
      socket.close
      selector.close
    end

    it { expect { process }.not_to raise_error }
  end
end
