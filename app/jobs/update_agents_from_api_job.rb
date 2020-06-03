class UpdateAgentsFromApiJob < ApplicationJob
  queue_as :import

  def perform(*args)

    puts "UpdateAgentsFromApiJob called"

    perform_update = Proc.new do |aa|
      record = aa.record
      agent = aa.agent
      agent.update_from_api
      if [Resource,ArchivalObject].include?(record.class)
        record.update_unit_data
      elsif record.is_a?(DigitalObject)
        record.digital_object_associations.each do |doa|
          doa.record.update_unit_data
        end
      end
      print '.'
    end

    id = args[0]
    if id
      puts "Updating Agent #{id} and associated unit data"
      a = Agent.find id
      a.agent_associations.each do |aa|
        perform_update.(aa)
      end
    else
      puts "Updating all Agents and associated unit data"
      AgentAssociation.find_each do |aa|
        begin
          perform_update.(aa)
        rescue Exception => e
          puts; puts e
        end
      end
      puts
    end
  end

end
