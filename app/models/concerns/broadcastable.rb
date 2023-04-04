require 'broadcaster'

module Broadcastable
  extend ActiveSupport::Concern
  
  included do
  end
  
  module ClassMethods
  
    #
    # Called from within the model that
    # needs to broadcast updates via 
    # a websocket. By default, all actions
    # will be broadcast AFTER they have been
    # performed - i.e
    #
    # * after_create
    # * after_update
    # * after_destroy
    #
    # If you wish to exclude any of these, 
    # then use with the :except or :only
    # options when called. for example,
    # to only broadcast the creation of 
    # a record, call
    #
    #    broadcastable only: :create
    #
    #
    def broadcastable(options = {})
      
      # We'll need these again later
      # cattr_accessor :broadcastable_options
      # self.broadcastable_options = options
      
      actions = broadcastable_actions(options)
      create_callbacks_for_actions(actions, options)
      
    end
    
    
    #
    # Figure out which actions we should be
    # adding the filters for. Users have the
    # option of excluding actions via the 
    # 'only' or 'except' options
    #
    def broadcastable_actions(options)
  
      actions = [:create, :update, :destroy]
      exclude = []
      
      if options[:except]
      
        exclude = Array(options[:except])
      
      elsif options[:only]
  
        exclude = Array.new(actions)
           only = Array(options[:only])
        exclude.delete_if { |x| only.include?(x) }
        
      end
      
      actions - exclude
      
    end
    
    
    
    #
    # When we know which actions we are
    # broadcasting, we need to add the
    # rails callbacks to perform the
    # broadcast. This method dynamically
    # creates these callbacks according to
    # the user settings
    #
    def create_callbacks_for_actions(actions, options)
        actions.each do |action|
          Broadcastable.send("broadcast_#{action}".to_sym, options)
        end 
      #   filter = "after_#{a.to_s}"
      #   filter_method = self.method(filter.to_sym)
      #   filter_action = "broadcast_#{a}".to_sym
      #   filter_method.call(filter_action)
      # end
    end
  
  end #/ ClassMethods
  
  
  
  
    
  attr_accessor :broadcastable_channel
  
  
  #
  # When a model is assigned as broadcastable,
  # the type of channel can be specified. For
  # this, there are 3 options
  #
  # * global
  # * parent
  # * resources
  # * resource
  #
  # The global option sends all messages to the
  # global channel, which is listened to by all
  # users.
  #
  # The parent channel sends all messages to a
  # parent resource channel. For this option,
  # the :parent option must also be specified
  #
  # The resources channel specifies a general
  # channel for that resource type. For example,
  # if used in the Alert model, the channel will
  # be /alerts
  #
  # The resource channel is specific to the current
  # resource. Similar to above, if used in the Alert
  # model, the resulting channel will be /alerts/i
  # where i is the resource identifier
  #
  # Alternatively, the user can override the
  # broadcastable_channel method to ignore these
  # options entirely, and specify their own channel
  #
  def self.broadcastable_channel(channel = :global)

    if channel.is_a?(Symbol)
      
      if channel != :global
        raise 'Invalid channel specified. A channel must be the symbol :global or a hash of properties'
      else
        return '/topics/installation'
      end

    elsif !channel.is_a?(Hash)
      raise 'Invalid channel specified. A channel must be the symbol :global or a hash of properties'
    else
      channel_type = channel[:type] || :global
      channel_type = [:merchant, :member, :global, :client, :user].include?(channel_type) ? channel_type : :global

        # resource_id = channel_resource_id(channel, channel_type)
      resource_type = channel_type == :global ? 'installation' : channel_type.to_s.downcase.pluralize

      channel_url = "/topics/#{resource_type}"
      # channel_url << "/#{resource_id}" if resource_id

      channel_url
    end
  end
  
  
  protected
  
  ###############################
  #                             #
  #     BROADCAST ACTIONS       #
  #                             #
  # The following actions are   #
  # responsible for performing  #
  # the actual broadcast. These #
  # are the methods assigned to #
  # the after filters           #
  #                             #
  ###############################
  
  def self.broadcast(action, message, options)
    broadcaster = Broadcaster.new
    channels = options[:channels]

    if channels.length == 0
      broadcaster.broadcast(:global, message)
    else
      channels.each do |channel|
        broadcaster.broadcast(self.broadcastable_channel(channel), message, self.broadcast_headers(channel))
      end
    end
  end
  
  def self.broadcast_update(options)
    self.broadcast(:update, self.broadcast_message(:update, options), options)
  end
  
  def self.broadcast_create(options)
    self.broadcast(:create, self.broadcast_message(:create, options), options)
  end
  
  def self.broadcast_destroy(options)
    self.broadcast(:destroy, self.broadcast_message(:destroy, options), options)
  end
  
  def self.broadcast_message(action, options)
    {
      action: action,
      resource_type: options[:message].class.name,
      resource: options[:message]
    }
  end
  
  
  private

  def self.broadcast_headers(channel)
    channel_type = channel[:type] || :global
    channel_type = [:merchant, :member, :global, :client, :user].include?(channel_type) ? channel_type : :global
             key = channel_type == :global ? nil : "#{channel_type.to_s.downcase.singularize}_id"

         headers = {}

    if key
      headers[key] = channel_resource_id(channel, channel_type).to_s
    end

    headers
  end

  def self.channel_resource_id(channel, resource_type)
    return nil if resource_type == :global

       resource = channel[resource_type]
    resource_id = nil

    if !resource
      raise "Invalid channel specified. The '#{resource_type}' option must be supplied for a #{resource_type.to_s} channel"
    end

    if resource.is_a?(Integer)
      # We've been given an ID, so just return this
      return resource

    elsif resource.is_a?(Proc)
      # We've been given a proc object. Lets run this
      # and see what we get back
      obj = self.instance_exec(&resource)

      if obj.is_a?(Integer)
        # This just return an ID so we'll return this
        return obj
      elsif obj.respond_to?(:id)
        # The returned object contains an ID so return that
        return obj.id
      else
        # Not what we expected. Just raise an exception
        raise "Invalid channel proc specified. The proc for a channel must return an ID or an object with an ID"
      end

    elsif resource.is_a?(Symbol) || resource.is_a?(String)

      if self.respond_to?(resource.to_sym)
        # Fetch the object
        obj = self.send(resource.to_sym)
      
        if obj.is_a?(Integer)
          # This just return an ID so we'll return this
          return obj
        elsif obj.respond_to?(:id)
          # The returned object contains an ID so return that
          return obj.id
        else
          # Not what we expected. Just raise an exception
          raise "Invalid channel method specified. The method for a channel must return an ID or an object with an ID"
        end
      else
        raise 'The method specified does not exist'
      end

    elsif resource.respond_to?(:id)

      resource.id

    else

      raise "Invalid #{resource_type.to_s} specified for channel. Must be an ID, a proc, or a method name"

    end
  end
  
end