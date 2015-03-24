module Google
  module Calendar
    include Google::Client
    
    def create_calendar_event( obj )
      event = {
        'summary' => obj.name,
        'description' => obj.description,
        'location' => obj.location,
        
        'start' => {
          'dateTime' => obj.start_date
        },
        'end' => {
          'dateTime' => obj.end_date || obj.start_date + 2.hours
        },
        
        'source' => {
          'title' => 'inschrijven',
          'url' => "https://members.stickyutrecht.nl/activities/#{obj.id}"
        }
      }
      
      result = client.execute(:api_method => service.events.insert,
                              :parameters => {'calendarId' => 'primary'},
                              :body => JSON.dump(event),
                              :headers => {'Content-Type' => 'application/json'})
                        
      return result.data.id
    end
    
    def update_calendar_event( obj )
      if obj.name_changed?
      
      end
      
      if obj.description_changed? 
        
      end
      
      if obj.location_changed? 
        
      end
      
      if obj.start_date_changed? 
        
      end
      
      if obj.end_date_changed?
      
      end      
      
      return false
    end
  end
  
  module Client
    def client
    
    end
end

ActiveRecord::Base.send(:include, Google)