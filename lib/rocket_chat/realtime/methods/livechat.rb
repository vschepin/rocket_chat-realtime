# frozen_string_literal: true

require 'rocket_chat/realtime/messages/method'

module RocketChat
  module Realtime
    module Methods
      # Livechat methods
      #
      # @since 0.1.2
      module Livechat
        # Get a Livechat configuration from server
        #
        # @since 0.1.2
        def livechat_get_initial_data(visitor_token)
          method = Messages::Method.new(
              'livechat:getInitialData',
              visitor_token
          )
          AsyncTask.start(method.id) do
            driver.text(method.to_json)
          end
        end

        # Register new guest on server
        # @param visitor_token [String]
        # @param name [String]
        # @param params [Hash]
        #
        # @since 0.1.2
        def livechat_register_guest(visitor_token, name, params = {})
          method = Messages::Method.new(
              'livechat:registerGuest',
              params.merge({
                               token: visitor_token,
                               name: name
                           })
          )
          AsyncTask.start(method.id) do
            driver.text(method.to_json)
          end
        end

        # Send a Livechat offline message
        # @param name [String]
        # @param email [String]
        # @param message [String]
        #
        # @since 0.1.2
        def livechat_send_message_offline(name, email, message)
          method = Messages::Method.new(
              'livechat:sendOfflineMessage',
              {
                  name: name,
                  email: email,
                  message: message
              }
          )
          AsyncTask.start(method.id) do
            driver.text(method.to_json)
          end
        end

        # Send a Livechat message
        # @param visitor_token [String]
        # @param room_id [String]
        # @param message [String]
        # @param id [String]
        #
        # @since 0.1.2
        def livechat_send_message(visitor_token, room_id, message, id = nil)
          id ||= SecureRandom.uuid
          method = Messages::Method.new(
              'sendMessageLivechat',
              {
                  rid: room_id,
                  msg: message,
                  token: visitor_token,
                  _id: id
              }
          )
          AsyncTask.start(method.id) do
            driver.text(method.to_json)
          end
        end

        # Subscribe to Livechat room messages
        #
        # @param visitor_token [String]
        # @param room_id [String]
        #
        # @since 0.1.2
        def livechat_subscribe_room_messages(visitor_token, room_id)
          subscription = Messages::Subscribe.new(
              'stream-livechat-room',
              room_id,
              {
                  useCollection: false,
                  args: [
                      {
                          token: visitor_token
                      }
                  ]
              }
          )
          AsyncTask.start(subscription.id) do
            driver.text(subscription.to_json)
          end
        end
      end
    end
  end
end
