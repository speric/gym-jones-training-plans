require 'mechanize'

module GymJonesParser
  LOGIN_PAGE = "https://www.gymjones.com/accounts/login/?next=/"
  
  class Client
    attr_accessor :email, :password
 
    def initialize(email, password)
      @email    = email
      @password = password
    end

    def parse!
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

    def urlify(string)
      string = string.gsub(/[ \-]+/i, '-') # No more than one of the separator in a row.
      string = string.gsub(/^\-|\-$/i, '') # Remove leading/trailing separator.
      string = string.downcase
      string
    end
  end
end
