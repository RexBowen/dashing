MONTH = 60 * 60 * 24 * 30
Sources = ['Yahoo', 'Google', 'Blog Traffic', 'Direct Traffic', 'Other'] 
Source_Counts = Hash.new({ value: 0 })

UniqueSite = 'Unique Site Visits '
UniqueApp = 'Unique App Visits '

$current = 0
$current_start = 0
$previous_start = 0

$current_web_visits = 8000
$current_app_visits = 6000
$previous_web_visits = 1
$previous_app_visits = 1

def set_times
  $current = Time.now
  $current_start = $current - MONTH
  $previous_start = $current_start - MONTH
end

def push_web
  send_event('current_site_visit', { current: $current_web_visits })
  send_event('previous_site_visit', { current: $previous_web_visits })
  change = ($current_web_visits.to_f / $previous_web_visits - 1) * 100
  send_event('site_difference', { text: '' + change.round(2).to_s + '%' })
end

def get_web
  $previous_web_visits = $current_web_visits
  $current_web_visits = $previous_web_visits + 50 + rand(200)
end

def get_sources
  Sources.each { |s| Source_Counts[s] = { label: s, value: rand(100) } }    
end

def push_web_titles
  today = $current.strftime("%b%d")
  previous = $current_start.strftime("%b%d")
  before = $previous_start.strftime("%b%d")
  send_event('current_site_visit', { title: UniqueSite + today + ' to ' + previous })
  send_event('previous_site_visit', { title: UniqueSite + previous + ' to ' + before })
end

def push_sources
  send_event('visitor_source', { items: Source_Counts.values })
end

set_times
push_web
get_sources
push_sources
push_web_titles

SCHEDULER.every '4s' do
  # check if date has changed
  temp = Time.now
  if temp.day != $current.day
    set_times
    push_web_titles
  end
  # get latest from analytics
  get_web
  get_sources
  #

  # push to widget
  push_web
  push_sources
  #do app
  #
  #do sources
end


