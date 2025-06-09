module ApplicationHelper
  def flash_color(type)
    case type.to_s
    when 'notice', 'success'
      'green'
    when 'alert', 'error'
      'red'
    when 'warning'
      'yellow'
    else
      'blue'
    end
  end
  
  def format_price(price)
    number_to_currency(price)
  end
  
  def format_duration(duration_in_hours)
    if duration_in_hours&. < 1
      "#{(duration_in_hours * 60).to_i} minutes"
    else
      "#{duration_in_hours} hours"
    end
  end
  
  def enrollment_status_badge(status)
    case status
    when 'enrolled'
      content_tag :span, status.capitalize, class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800"
    when 'completed'
      content_tag :span, status.capitalize, class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800"
    when 'dropped'
      content_tag :span, status.capitalize, class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800"
    else
      content_tag :span, status.capitalize, class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800"
    end
  end
end
