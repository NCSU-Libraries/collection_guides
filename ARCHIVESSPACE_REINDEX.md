# Important: Before re-building ArchivesSpace index

If you need to do a full re-index in ArchivesSpace (which requires deleteting the old index first) you MUST disable cron tasks for Collection Guides FIRST. If the hourly update task runs while the ArchivesSpace Solr index is still being populated, Collections Guides will be deleted unexpectedly and other strange errors can occur.
