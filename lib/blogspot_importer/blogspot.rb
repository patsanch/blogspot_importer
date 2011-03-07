require 'nokogiri'

module BlogspotImporter
  
  class Blogspot
    
    # return array of hashes
    # ex: 
    # [0 => { post_title              => 'title'
    #         post_content            => 'content'
    #         post_tags               => [tag1, tag2, tag3]
    #         post_published_date     => 'date'
    #         post_comments           => [
    #           {
    #             comment_author_name     => 'author'
    #             comment_author_email    => 'author email'
    #             comment_content         => 'content'
    #             comment_published_date  => 'date'
    #           },
    #           {
    #             'comment_author'          => 'author'
    #             'comment_email'           => 'email'
    #             'comment_content'         => 'content'
    #             'comment_published_date'  => 'date'
    #           }
    #         ]
    #       }
    # ]
    def self.import(file)
      blog = []
      puts "Parsing #{file}"

      f = File.open(file)
      doc = Nokogiri::XML(f)

      ctr = 0
      found_post = false
      found_comment = false
      tags = []
      lookup = {}
      post = {}
      comment = {}
      
      doc.css("entry").each do |entry|
        entry.css("category").each do |entry_cat|
          puts "Checking category"
          if entry_cat.attr("term").match(/post/)
            found_post = true
          elsif entry_cat.attr("term").match(/comment/)
            found_comment = true
          else
            tags << entry_cat.attr("term")
          end
        end
          
        if found_post
          puts "This entry is a blog post"
          post_title = entry.css("title").inner_text
          post_content = entry.css("content").inner_text
          post_tags = tags
          post_published_date = entry.css("published").inner_text
          post = { 
                    'post_title' => post_title, 
                    'post_content' => post_content, 
                    'post_tags' => post_tags, 
                    'post_published_date' => post_published_date
                  }
          blog[ctr] = post
          lookup["#{entry.css("id").inner_text}"] = ctr
          ctr += 1
        elsif found_comment
          puts "This entry is a comment"
          comment_author_name = entry.css('author').at_css('name').inner_text
          comment_author_email = entry.css('author').at_css('email').inner_text      
          comment = {
                      'comment_author_name' => comment_author_name,
                      'comment_author_email' => comment_author_email,
                      'comment_content' => entry.css('content').inner_text,
                      'comment_published_date' => entry.css('published').inner_text
                    }
          post_ctr = lookup["#{entry.xpath('thr:in-reply-to').attr('ref').value}"]       
          if blog[post_ctr]["post_comments"].class != Array
            blog[post_ctr]["post_comments"] = []
          end
          blog[post_ctr]["post_comments"] << comment
          comment = {}
        else
          puts "This entry is not needed so far"
        end

        found_post = false
        found_comment = false
        tags = []
      end
      
      f.close
      
      return blog
    end
  
  end
  
end