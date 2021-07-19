module UsersHelper
	def format_gender(gender)
		case gender
    when 'Ж'
      :female
    else
      :male
    end
	end
end
