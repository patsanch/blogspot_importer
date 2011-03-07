require 'nokogiri'

module BlogspotImporter
  
  class Blogspot
    
    # return array of hashes
    # ex: 
    # [0 => { title   => 'title'
    #         content => 'content'
    #         tags    => [tag1, tag2, tag3]
    #       }
    # ]
    def self.import(file)
      blog = []
      puts "Parsing #{file}"

      f = File.open(file)
      doc = Nokogiri::XML(f)

      ctr = 0
      found_post = false
      tags = []
      
      doc.css("entry").each do |entry|
        entry.css("category").each do |entry_cat|
          puts "Checking category"
          if entry_cat.attr("term").match(/post/)
            found_post = true
          else
            tags << entry_cat.attr("term")
          end
        end
          
        if found_post
          puts "This entry is a blog post"
          post_title = entry.css("title").inner_text
          post_content = entry.css("content").inner_text
          post_tags = tags
          blog[ctr] = {'title' => post_title, 'content' => post_content, 'post_tags' => post_tags}
          ctr += 1
        else
          puts "This entry is not a blog post (probably template/comment)"
        end

        found_post = false
        tags = []
      end
      
      f.close
      
      return blog
    end
  
  end
  
end