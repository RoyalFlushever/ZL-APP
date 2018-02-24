module ApplicationHelper
	def bootstrap_class_for(flash_type)
    case flash_type
      when "success"
        "alert-success"
      when "error"
        "alert-danger"
      when "alert"
        "alert-warning"
      when "notice"
        "alert-info"
      when "yellow"
        "alert-yellow"
      else
        flash_type.to_s
      end
  end
end
