module ApplicationHelper
  def basic_date(date)
    date.blank? ? nil : date.strftime('%B %-d, %Y')
  end

  def basic_datetime(date)
    date.blank? ? nil : date.year != Date.today.year ? date.strftime('%B %-d, %Y at %l:%M %P') : date.strftime('%B %-d at %l:%M %P')
  end

  def basic_datetime_eastern(date)
    date.blank? ? nil : date.year != Date.today.year ? date.in_time_zone('Eastern Time (US & Canada)').strftime('%B %-d, %Y at %l:%M %P') : date.in_time_zone('Eastern Time (US & Canada)').strftime('%B %-d at %l:%M %P')
  end

  def comment_alert_time(date)
    if date.day == Date.today.day
      "at #{date.strftime('%l:%M %P')}"
    else
      "on #{date.strftime('%B %-d at %l:%M %P')}"
    end
  end

  def active_class(link_path)
    current_page?(link_path) ? 'active' : ""
  end

  def display_current_term
    html = '<span>'.html_safe
    if @current_term.present?
      html << 'You are viewing sections outside the current term, which is '
      html << link_to_unless(@term == @current_term, term_in_words(@current_term), "/sections?term=#{@current_term}").html_safe
    else
      html << 'No current term selected.'
    end
    html << '</span>'.html_safe
    html unless @current_term.to_i == @term.to_i
  end

  def term_in_words(term)
    year = term.to_s[0..3]
    term = term.to_s[4..5]
    case term
    when '10'
      "Spring #{year}"
    when '40'
      "Summer #{year}"
    when '70'
      "Fall #{year}"
    end
  end
end
