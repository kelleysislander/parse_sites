#Aircraft - Electric - Helis (FS/W)
#curl http://www.rcgroups.com/aircraft-electric-helis-fs-w-44/ | grep -i thread_title_ | grep 'ikon\|IKON\|Ikon\|flybarless\|FBL'
#curl http://www.helifreak.com/forumdisplay.php?f=51/ | grep -i thread_title_ | grep 'ikon\|IKON\|Ikon\|flybarless\|FBL'

# curl http://www.helifreak.com/forumdisplay.php?f=51/ | grep -i thread_title_ | awk '{print tolower($0)}' | grep 'ikon\|flybarless\|FBL\|msh\|brain' > ~/Helis/heli_files/helifreak.txt

# To run this script from the CL:
# /Volumes/MainHD/Users/billy/Helis/heli_files/parse_sites.sh http://www.helifreak.com/forumdisplay.php?f=51
# /Volumes/MainHD/Users/billy/Helis/heli_files/parse_sites.sh http://www.rcgroups.com/aircraft-electric-helis-fs-w-44/

root = `pwd`.chop!
require 'rubygems'
require 'active_record'
require 'yaml'
require "#{root}/thread_num.rb"

class ParseSites

  def initialize( url )

    currloc = `pwd`.chop!

    tmp = url.split("/")
    @@base_url = "#{tmp[0]}//#{tmp[2]}/"

    #puts "%%%%%%%% @@base_url: #{@@base_url}" # %%%%%%%% base_url: http://www.helifreak.com/
    #puts "*********** inside url: #{url}" # *********** inside url: http://www.helifreak.com/forumdisplay.php?f=51

    dbconfig = YAML::load(File.open('database.yml'))['parse_sites']

    ActiveRecord::Base.establish_connection( dbconfig )

    if @@base_url.include?("helifreak")

      #puts "helifreak"

      if File.exist?( "#{currloc}/helifreak_parse.txt" )

        #puts "helifreak file exists, process the file here"
        if File.size( "#{currloc}/helifreak_parse.txt" )
          #puts "File size > 0"
          result = File.open( "#{currloc}/helifreak_parse.txt" )

          process_file( result, "Helifreak" )

        end

      end

    else

      #puts "rcgroups"

      if File.exist?( "#{currloc}/rcgroups_parse.txt" )
        #puts "rcgroups file exists, process the file here"

        #puts "helifreak file exists, process the file here"
        if File.size( "#{currloc}/rcgroups_parse.txt" )
          #puts "File size > 0"
          result = File.open( "#{currloc}/rcgroups_parse.txt" )

          process_file( result, "RCGroups" )

          # <a href="showthread.php?s=4270b5c1acc6e5d7d1b659df39b07b42&amp;t=568685" id="thread_title_568685">ar7200bx 7-ch dsmx flybarless control system beast x</a>
          # <a href="showthread.php?s=4270b5c1acc6e5d7d1b659df39b07b42&amp;t=569997" id="thread_title_569997">bnib spektrum ar7200bx flybarless rx</a>

        end
      end
    end

  end

  def process_file( result, source )

    result.each_line do |line|
      line.strip!
      puts line
      #link = line.split('"')[1]
      thread_num = line[ line.index("thread_title") + 13, 6 ]
      puts "thread_num: #{thread_num}"

      # if thread_num not on the DB then proceed
      if check_noton_thread_nums( thread_num )

        link = @@base_url + line.split('"')[1]

        # remove the long "s=4270b5c1acc6e5d7d1b659df39b07b42&amp;" stuff
        str1 = line[0, line.index("s=")]
        # insert base_url: http://www.helifreak.com/ in the right spot right before the "showthread.php" part
        str1.insert( 9, @@base_url )
        # add the "t=569997" part to the end
        str2 = line[line.index("t="), 8]
        #puts "****** str2: #{str2}"
        # extract the link text ie ">ar7200bx 7-ch dsmx flybarless control system beast x</a>"
        link_text = line[ line.index(">") - 1, line.length - line.index(">") + 1 ]
        # put it all together

        puts "str1: #{str1}"
        puts "str2: #{str2}"
        puts "link_text: #{link_text}"

        full_link = str1 + str2 + link_text

        #puts full_link

        # WORKS: `echo "mary had a little lamb" | mail -s 'The CL cmd to send this email was: date | mail -s test bill@semaphoremobile.com' kelleysislander@gmail.com`
        # WORKS: `echo "mary had a little lamb" | mail -s "New #{source} Listing" kelleysislander@gmail.com`

      text = link_text[2, link_text.index("<")-2 ]
      ThreadNum.create!( :thread_num => thread_num, :thread_source => source, :link_text => link_text[2, link_text.index("<")-2 ], :created_at => DateTime.now )

      `echo "#{full_link}" | mail -s "New #{source} Listing" kelleysislander@gmail.com`

      end
    end

  end

  def check_noton_thread_nums( thread_num )
    return false if ThreadNum.where( :thread_num => thread_num ).first
    return true
  end

end

url = ARGV[0]   # ie. http://www.rcgroups.com/aircraft-electric-helis-fs-w-44/
# instantiate the class and run the job.  The "initialize()" method has the job logic
ad = ParseSites.new( url )

# called this way:
# ruby parse_sites.rb http://www.rcgroups.com/aircraft-electric-helis-fs-w-44/
# ruby parse_sites.rb http://www.helifreak.com/forumdisplay.php?f=51

# http://www.helifreak.com/forumdisplay.php?f=51

# <a href="showthread.php?s=ae178ee31c6ba7994925bea6d1105c07&amp;t=2011840" id="thread_title_2011840">trex 450 pro fbl with dx6i and extras</a>

=begin

CREATE DATABASE parse_sites CHARACTER SET utf8 COLLATE utf8_general_ci;


# NOTE: This method was not getting helifreak's correct url - helifreak was preventing that but cURL works

  def initialize( url )

    tmp = url.split("/")
    base_url = "#{tmp[0]}//#{tmp[2]}/"

    puts "%%%%%%%% base_url: #{base_url}"

    puts "*********** inside url: #{url}"

    url = URI.parse( url )
    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    #puts res.body
    puts res.body.lines.count

    result = res.body
    result.lines.each do |line|

      #puts "******** line: #{line}"

      if line.include?("thread_title")
        #if line.downcase.include?("ikon")
        if line.downcase.match( /ikon|fbl|flybarless|brain|3gx/)

          #link = line.split('"')[1]
          #link = base_url + line.split('"')[1]

          puts line

          #puts "*********link: #{link}"

          thread_num = line[ line.index("thread_title") + 13, 6 ]
          puts "************** thread_num: #{thread_num}"
          # insert the thread_num into the DB if it does not already exist.  If it is new then send the email
          # echo "mary had a little lamb" | mail -s 'The CL cmd to send this email was: date | mail -s test bill@semaphoremobile.com' bill@semaphoremobile.com

        end
      end
    end
  end
=end
