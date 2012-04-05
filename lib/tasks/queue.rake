
namespace :queue do

  task :pmc => :environment do

    # this rake task should be scheduled to run after pmc data import rake task runs
    source = Source.find_by_name("pmc")
    source.queue_all_articles

  end

  task :counter => :environment do

    # this rake task should be scheduled after counter data has been processed for the day
    source = Source.find_by_name("counter")
    source.queue_all_articles

  end

  task :biod => :environment do

    # this rake task should be scheduled after counter data has been processed for the day
    source = Source.find_by_name("biod")
    source.queue_all_articles

  end

  task :citeulike => :environment do

    # this rake task is setup to run forever
    while true
      source = Source.find_by_name("citeulike")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :crossref => :environment do

    # this rake task is setup to run forever
    while true
      source = Source.find_by_name("crossref")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :nature => :environment do

    # this rake task is setup to run forever
    while true
      source = Source.find_by_name("nature")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :mendeley => :environment do

    # this rake task is setup to run forever
    while true
      source = Source.find_by_name("mendeley")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :researchblogging => :environment do

    # this rake task is setup to run forever
    while true
      source = Source.find_by_name("researchblogging")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :wos => :environment do

    # this rake task is setup to run forever
    while true
      source = Source.find_by_name("wos")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :pubmed => :environment do

    # this rake task is setup to run forever
    while true
      source = Source.find_by_name("pubmed")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :scopus => :environment do

    # this rake task is setup to run forever
    while true
      source = Source.find_by_name("scopus")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :facebook => :environment do

    # this rake task is setup to run forever
    while true
      source = Source.find_by_name("facebook")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :twitter => :environment do

    # this rake task is setup to run forever
    while true
      source = Source.find_by_name("twitter")
      sleep_time = source.queue_articles
      sleep(sleep_time)
    end

  end

  task :twitter_new_articles => :environment do

    # this rake task is setup to run forever
    while true
      source = Source.find_by_name("twitter")
      sleep_time = source.queue_new_articles
      sleep(sleep_time)
    end

  end
end
