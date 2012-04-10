module ApplicationHelper

  def flash_messages
    flash_messages = flash.collect { |type,message| [bootstrap_message_class(type),message] }
    logger.info flash.inspect
    render 'shared/flash_messages', :flash => flash_messages
  end

  def resource_error_messages
    flash_messages = resource.errors.full_messages.map { |msg| ['error', msg] }
    render 'shared/flash_messages', :flash => flash_messages
  end

  def bootstrap_message_class(type)
    case type
      when :alert
        'error'
      when :error
        'error'
      when :notice
        'info'
      when :success
        'success'
      else
        type.to_s
    end
  end
end
