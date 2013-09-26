module ComfortableMexicanSofa::Translations
  def self.pluralize i18n_key, count
    if I18n.locale == :ru
      # russian language plural rules
      form = if (count % 10 == 1) && (count % 100 != 11)
        'one'
      elsif (2..4).include?(count % 10) && !((12..14).include?(count % 100))
        'few'
      elsif [0,5,6,7,8,9].include?(count % 10) || (11..14).include?(count % 100)
        'many'
      else
        'other'
      end

      proper = I18n.t("#{i18n_key}.#{form}")
      ApplicationController.helpers.pluralize(count, proper, proper )
    else
      ApplicationController.helpers.pluralize(count, I18n.t(i18n_key))
    end
  end


end