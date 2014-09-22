require 'mechanize'

module GymJonesParser
  LOGIN_PAGE = "https://www.gymjones.com/accounts/login/?next=/"
  
  class Client
    attr_accessor :email, :password
 
    def initialize(email, password)
      @email    = email
      @password = password
    end

    def parse_training_plans!
      start = Time.now.to_i
      signin!
      training_plans.each do |plan, data|
        puts "Starting #{plan}"
        training_page = mechanize_agent.get("#{data[:url]}")
        paragraphs = training_page.search("//p").to_a
        paragraphs.delete_at(0); paragraphs.pop
        plan_text = paragraphs.map(&:text).join("")

        1.upto(data[:days]) do |day|
          puts "\tDay #{day} of #{data[:days]}"
          wod_page = mechanize_agent.get("#{data[:url]}/day/#{day}")
          plan_text << "DAY #{day}"
          plan_text << wod_page.search("div[class='workout-contents']").text
          plan_text << "\n"
        end
        File.open("#{urlify(plan)}.txt", "w"){ |log| log.puts plan_text }
        puts "Finished #{plan}"
        sleep(4)
      end
      puts "Finished all plans in #{Time.now.to_i - start} seconds."
    end

    def parse_knowledge!
      `mkdir knowledge`
      start = Time.now.to_i
      signin!
      knowledge_articles.each do |title, url|
        nice_title = urlify(title) 
        puts "Starting #{title}"
        page = mechanize_agent.get("#{url}")
        article = page.search(".body")
        images = article.search("img").map { |img| "https://gymjones.com/#{img.attributes["src"].value}" }
        
        article_text = "#{title}\n"
        article_text << article.text
        `mkdir knowledge/#{nice_title}`
         
        images.each { |img| `cd knowledge/#{nice_title} && wget #{img}` }
        
        File.open("knowledge/#{nice_title}/#{nice_title}.txt", "w"){ |log| log.puts article_text }
        puts "Finished #{title}"
        
        sleep(3)
      end
      puts "Finished all articles in #{Time.now.to_i - start} seconds."
    end

    def signin!
      signin_page          = mechanize_agent.get(LOGIN_PAGE)
      signin_form          = signin_page.forms[1]
      signin_form.username = email
      signin_form.password = password
      mechanize_agent.submit(signin_form)
    end

    def mechanize_agent
      @mechanize_agent ||= new_mechanize_agent
    end

    def new_mechanize_agent
      mechanize_agent = Mechanize.new
      mechanize_agent.user_agent_alias       = 'Windows Mozilla'
      mechanize_agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      mechanize_agent
    end

    def training_plans
      {
        "300 Cast and Stunt Crew Month 1" => { days: 28, url: "http://www.gymjones.com/training/plan/300-cast-and-stunt-crew-month-one/"},
        "300 Cast and Stunt Crew Month 2" => { days: 28, url: "http://www.gymjones.com/training/plan/300-cast-and-stunt-crew-month-two/"},
        "300 Cast and Stunt Crew Month 3" => { days: 28, url: "http://www.gymjones.com/training/plan/300-cast-and-stunt-crew-month-three/"},
        "300 Rise of an Empire Daxos"     => { days: 35, url: "http://www.gymjones.com/training/plan/300-rise-of-an-empire-daxos/"},
        "Man Of Steel Prep Phase"         => { days: 42, url: "http://www.gymjones.com/training/plan/man-of-steel-prep-phase/"},
        "Man Of Steel Mass Gain"          => { days: 56, url: "http://www.gymjones.com/training/plan/man-of-steel-mass-gain/"},
        "Man of Steel Leaning Phase"      => { days: 42, url: "http://www.gymjones.com/training/plan/man-of-steel-leaning-phase/"},
        "Foundation Basic"                => { days: 28, url: "http://www.gymjones.com/training/plan/basic-foundation/"},
        "Foundation General Three Month"  => { days: 83, url: "http://www.gymjones.com/training/plan/three-month-foundation/"},
        "Foundation High Level"           => { days: 84, url: "http://www.gymjones.com/training/plan/high-level-foundation/"},
        "Foundation High Level 2"         => { days: 28, url: "http://www.gymjones.com/training/plan/foundation-high-level-ii/"},
        "Foundation Rowing Specific"      => { days: 28, url: "http://www.gymjones.com/training/plan/foundation-rowing-specific/"},
        "Marathon Basic"                  => { days: 84, url: "http://www.gymjones.com/training/plan/marathon-base-program/"},
        "Mass Gain"                       => { days: 28, url: "http://www.gymjones.com/training/plan/mass-gain/"},
        "Mass Gain 2"                     => { days: 28, url: "http://www.gymjones.com/training/plan/mass-gain-2/"},
        "Mass Gain Sport Performance"     => { days: 48, url: "http://www.gymjones.com/training/plan/hypertrophy-speed/"},
        "MMA Mass Gain"                   => { days: 28, url: "http://www.gymjones.com/training/plan/mma-mass-gain/"},
        "MMA Power Endurance"             => { days: 28, url: "http://www.gymjones.com/training/plan/mma-explosive-power-endurance/"},
        "MMA Strength"                    => { days: 33, url: "http://www.gymjones.com/training/plan/jiu-jitsu-mma-strength/"},
        "No Gear"                         => { days: 28, url: "http://www.gymjones.com/training/plan/no-gear/"},
        "No Gear II"                      => { days: 28, url: "http://www.gymjones.com/training/plan/no-gear-ii/"},
        "Operator Fitness"                => { days: 28, url: "http://www.gymjones.com/training/plan/operator-fitness/"},
        "Operator Fitness II"             => { days: 28, url: "http://www.gymjones.com/training/plan/operator-fitness-ii/"},
        "Operator Fitness III"            => { days: 28, url: "http://www.gymjones.com/training/plan/operator-fitness-iii/"},
        "Operator Fitness IV"             => { days: 28, url: "http://www.gymjones.com/training/plan/operator-fitness-iv-strength/"},
        "Operator Fitness V"              => { days: 28, url: "http://www.gymjones.com/training/plan/operator-fitness-v-power/"},
        "Power Phase"                     => { days: 28, url: "http://www.gymjones.com/training/plan/power-phase/"},
        "Repo Men"                        => { days: 28, url: "http://www.gymjones.com/training/plan/repo-men/"},
        "Strength Phase"                  => { days: 28, url: "http://www.gymjones.com/training/plan/strength-phase/"},
        "Strength Phase II"               => { days: 28, url: "http://www.gymjones.com/training/plan/strength-phase-ii/"},
        "Structural Work"                 => { days: 28, url: "http://www.gymjones.com/training/plan/structural-work/"},
      }
    end

    def knowledge_articles
      {
        "300 Rise of an Empire Introduction"      => "http://www.gymjones.com/knowledge/article/300-rise-empire-introduction/",
        "300 Rise of an Empire Introduction 2"    => "http://www.gymjones.com/knowledge/article/300-roae-training-plan-2/",
        "300 Rise of an Empire Radical Change"    => "http://www.gymjones.com/knowledge/article/300-rise-empire-radical-change/",
        "300 Rise of an Empire Gallery #1"        => "http://www.gymjones.com/knowledge/article/300-rise-empire-gallery-1/",
        "300 Rise of an Empire Gallery #2"        => "http://www.gymjones.com/knowledge/article/300-rise-empire-gallery-2/",
        "Man Of Steel Preparation"                => "http://www.gymjones.com/knowledge/article/man-steel-conditioning/",
        "Man Of Steel Preparation Diet"           => "http://www.gymjones.com/knowledge/article/mos-phase-1-diet/",
        "Man Of Steel Mass Gain"                  => "http://www.gymjones.com/knowledge/article/man-steel-mass-gain/",
        "Man Of Steel Mass Gain Diet"             => "http://www.gymjones.com/knowledge/article/man-steel-mass-gain-diet/",
        "Man Of Steel Leaning Phase"              => "http://www.gymjones.com/knowledge/article/man-steel-leaning-phase/",
        "Man Of Steel Leaning Phase Diet"         => "http://www.gymjones.com/knowledge/article/man-steel-leaning-phase-diet/",
        "Man Of Steel Training Gallery 1"         => "http://www.gymjones.com/knowledge/article/man-steel-training-pictures/",
        "Disclaimer"                              => "http://www.gymjones.com/knowledge/article/disclaimer/",
        "Respect"                                 => "http://www.gymjones.com/knowledge/article/respect/",
        "Philosophy"                              => "http://www.gymjones.com/knowledge/article/philosophy/",
        "Important"                               => "http://www.gymjones.com/knowledge/article/important/",
        "Private"                                 => "http://www.gymjones.com/knowledge/article/private/",
        "Clarity"                                 => "http://www.gymjones.com/knowledge/article/clarity-2/",
        "Why"                                     => "http://www.gymjones.com/knowledge/article/why-2/",
        "Attitude"                                => "http://www.gymjones.com/knowledge/article/attitude-2/",
        "Definitions"                             => "http://www.gymjones.com/knowledge/article/definitions/",
        "Named Workouts"                          => "http://www.gymjones.com/knowledge/article/named-workouts/",
        "Training Plan Introduction"              => "http://www.gymjones.com/knowledge/article/training-plan-introduction/",
        "Engine, Tank, Power"                     => "http://www.gymjones.com/knowledge/article/engine-tank-power/",
        "Strength For Endurance (Part 1)"         => "http://www.gymjones.com/knowledge/article/strength-for-endurance-part-1/",
        "Strength for Endurance (Part 2)"         => "http://www.gymjones.com/knowledge/article/strength-for-endurance-part-2/",
        "Strength for Endurance (Part 3)"         => "http://www.gymjones.com/knowledge/article/strength-endurance-part-3/",
        "Somatotypes"                             => "http://www.gymjones.com/knowledge/article/somatotypes/",
        "Lip Service"                             => "http://www.gymjones.com/knowledge/article/lip-service/",
        "Twitching"                               => "http://www.gymjones.com/knowledge/article/twitching/",
        "Contrast Showers"                        => "http://www.gymjones.com/knowledge/article/contrast-showers/",
        "Eat For An Objective"                    => "http://www.gymjones.com/knowledge/article/eat-for-an-objective/",
        "Post-Workout Recovery Eating"            => "http://www.gymjones.com/knowledge/article/post-workout-recovery-eating/",
        "Diet Intuition Part One"                 => "http://www.gymjones.com/knowledge/article/diet-intuition-part-one/",
        "Diet Intuition Part Two"                 => "http://www.gymjones.com/knowledge/article/diet-intuition-part-two/",
        "Protein (1)"                             => "http://www.gymjones.com/knowledge/article/protein-1/",
        "Burn It"                                 => "http://www.gymjones.com/knowledge/article/burn-it/",
        "Diet Bullshit"                           => "http://www.gymjones.com/knowledge/article/diet-bullshit/",
        "Green Drink"                             => "http://www.gymjones.com/knowledge/article/green-drink/",
        "Energy Bars"                             => "http://www.gymjones.com/knowledge/article/energy-bars/",
        "Alcohol"                                 => "http://www.gymjones.com/knowledge/article/alcohol/",
        "Hydrate Or Die? Hardly."                 => "http://www.gymjones.com/knowledge/article/hydrate-or-die-hardly/",
        "Hydrate Or Die? Part II"                 => "http://www.gymjones.com/knowledge/article/hydrate-or-die-part-ii/",
        "Ultra"                                   => "http://www.gymjones.com/knowledge/article/ultra/",
        "Muscle Cramps"                           => "http://www.gymjones.com/knowledge/article/muscle-cramps/",
        "Endurance V.2"                           => "http://www.gymjones.com/knowledge/article/endurance-v2/",
        "30/30 Intervals Explained"               => "http://www.gymjones.com/knowledge/article/3030-intervals-explained/",
        "TNSTAAFL 2012"                           => "http://www.gymjones.com/knowledge/article/tnstaafl-2012/",
        "TNSTAAFL"                                => "http://www.gymjones.com/knowledge/article/tnstaafl/",
        "Assault"                                 => "http://www.gymjones.com/knowledge/article/assault/",
        "Remake Remodel"                          => "http://www.gymjones.com/knowledge/article/remake-remodel-2/",
        "Inner Conflict"                          => "http://www.gymjones.com/knowledge/article/inner-conflict-2/",
        "Have Fun, Good Luck"                     => "http://www.gymjones.com/knowledge/article/have-fun-good-luck-2/",
        "Paying For Time"                         => "http://www.gymjones.com/knowledge/article/paying-for-time/",
        "Giving Up"                               => "http://www.gymjones.com/knowledge/article/giving-up/",
        "Coach or Trainer?"                       => "http://www.gymjones.com/knowledge/article/coach-or-trainer/",
        "Eat to Recover"                          => "http://www.gymjones.com/knowledge/article/eat-to-recover/",
        "Self-Imposed Limitations and Self Image" => "http://www.gymjones.com/knowledge/article/self-imposed-limitations-and-self-image/",
        "Stay Cool"                               => "http://www.gymjones.com/knowledge/article/stay-cool/",
        "300"                                     => "http://www.gymjones.com/knowledge/article/300/",
        "Relative Strength"                       => "http://www.gymjones.com/knowledge/article/relative-strength-2/",
        "11/25/70"                                => "http://www.gymjones.com/knowledge/article/112570-2/",
        "Testimonials"                            => "http://www.gymjones.com/knowledge/article/testimonials/",
        "Quality"                                 => "http://www.gymjones.com/knowledge/article/quality-2/",
        "Testimonial 300"                         => "http://www.gymjones.com/knowledge/article/testimonial-300/",
        "Will and Suffering"                      => "http://www.gymjones.com/knowledge/article/will-and-suffering-2/",
        "Failure"                                 => "http://www.gymjones.com/knowledge/article/failure-3/",
        "Talent"                                  => "http://www.gymjones.com/knowledge/article/talent-2/",
        "Hard Work"                               => "http://www.gymjones.com/knowledge/article/hard-work-2/",
        "Should I?"                               => "http://www.gymjones.com/knowledge/article/should-i-2/",
        "Self Delusion"                           => "http://www.gymjones.com/knowledge/article/self-delusion/",
        "Walk It"                                 => "http://www.gymjones.com/knowledge/article/walk-it/",
        "Uncompromising"                          => "http://www.gymjones.com/knowledge/article/uncompromising/",
        "Naturally"                               => "http://www.gymjones.com/knowledge/article/naturally/",
        "Snapshot"                                => "http://www.gymjones.com/knowledge/article/snapshot/",
        "Death By Exercise"                       => "http://www.gymjones.com/knowledge/article/death-by-exercise/",
        "Human And Weak"                          => "http://www.gymjones.com/knowledge/article/human-and-weak/",
        "New Year 2010"                           => "http://www.gymjones.com/knowledge/article/new-year-2010/",
        "Fighters Only"                           => "http://www.gymjones.com/knowledge/article/fighters-only/",
        "Scratch And Sniff"                       => "http://www.gymjones.com/knowledge/article/scratch-and-sniff/",
        "Breathing Ladders"                       => "http://www.gymjones.com/knowledge/article/breathing-ladders/",
        "Repo Men Feed"                           => "http://www.gymjones.com/knowledge/article/repo-men-feed/",
        "Work Tolerance"                          => "http://www.gymjones.com/knowledge/article/work-tolerance/",
        "IWT Variants"                            => "http://www.gymjones.com/knowledge/article/iwt-variants/",
        "300 Opinions"                            => "http://www.gymjones.com/knowledge/article/300-opinions/",
        "Failure 2"                               => "http://www.gymjones.com/knowledge/article/failure-2-2/",
        "2007 Year-end Wrap-up"                   => "http://www.gymjones.com/knowledge/article/2007-year-end-wrap-up/",
        "The Old School (part one)"               => "http://www.gymjones.com/knowledge/article/the-old-school-part-one-2/",
        "The Old School (part two)"               => "http://www.gymjones.com/knowledge/article/the-old-school-part-two-2/",
        "The Old School (part three)"             => "http://www.gymjones.com/knowledge/article/the-old-school-part-three-2/",
        "Foundation Week 1995"                    => "http://www.gymjones.com/knowledge/article/foundation-week-1995/",
        "Recommended Reading"                     => "http://www.gymjones.com/knowledge/article/recommended-reading/",
      }
    end

    def urlify(string)
      string = string.gsub(/[ \-]+/i, '-') # No more than one of the separator in a row.
      string = string.gsub(/^\-|\-$/i, '') # Remove leading/trailing separator.
      string = string.downcase
      string
    end
  end
end
