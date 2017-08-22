# Provides valid paths to records in your local installation of ArchivesSpace.
# Because much of the functionality in this app requires interaction with ArchivesSpace, 
#   providing these sample paths is necessary for testing that functionality.

module AspaceApiSpecHelpers

  def aspace_sample_paths
    {
      # repository 
      repository: '/repositories/2',

      # resource with subjects, linked agents and children
      # to locate a suitable candidate, run this query against your ArchivesSpace MySQL database:
      # SELECT CONCAT('/repositories/',r.repo_id,'/resources/',r.id) as resource_path FROM resource r
      #   JOIN linked_agents_rlshp lar ON lar.resource_id = r.id
      #   JOIN subject_rlshp sr ON sr.resource_id = r.id
      #   WHERE EXISTS(SELECT * FROM archival_object ao WHERE ao.root_record_id = r.id)
      #   AND r.publish = TRUE
      #   LIMIT 1
      resource: '/repositories/2/resources/23',
      
      # archival_object with subjects, linked agents and children
      # to locate a suitable candidate, run this query against your ArchivesSpace MySQL database:
      # SELECT CONCAT('/repositories/',ao.repo_id,'/archival_objects/',ao.id) as archival_object_path FROM archival_object ao
      #   JOIN linked_agents_rlshp lar ON lar.archival_object_id = ao.id
      #   JOIN subject_rlshp sr ON sr.archival_object_id = ao.id
      #   WHERE EXISTS(SELECT * FROM archival_object ao2 WHERE ao2.parent_id = ao.id)
      #   AND ao.publish = TRUE
      #   LIMIT 1
      archival_object: '/repositories/2/archival_objects/318390',

      subject: '/subjects/23',

      # an agent (person - spec expects it to be a person)
      agent: '/agents/people/23',

      digital_object: '/repositories/2/digital_objects/3566'
    }
  end

  # hash is the ArchivesSpace API response converted to a hash - this happens in each spec
  def total_descendants_in_response(hash)
    total = 0
    add_children = Proc.new do |children|
      total += children.length
      children.each { |c| add_children.call(c['children']) }
    end
    add_children.call(hash['children'])
    total
  end

end