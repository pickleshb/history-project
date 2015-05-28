module Jekyll
  class ShowDataGenerator < Jekyll::Generator
    priority :high

    def generate(site)
      all_shows = site.collections["shows"].docs
      years = site.collections["years"].docs

      # This is here as it's needed here, I expect year.rb to be run after.
      years_by_slug = Hash.new
      for year in years
        years_by_slug[year.data["year"]] = year
      end

      shows_by_year = Hash.new
      for show, index in all_shows.each_with_index do
        path_split = show.path.split("/")
        year = path_split[path_split.length-2]
        show.data["year"] = year
        show.data["year_page"] = years_by_slug[show.data["year"]]
      end

      sorted_shows = all_shows.sort_by do | show |
        if show.data.has_key?("season_sort")
          # Sort by year, then by season_sort
          [show.data["year_page"].data["sort"], show.data["season_sort"].to_i]
        else
          # If no season_sort, assume 1000
          [show.data["year_page"].data["sort"], 1000]
        end
      end

      # sorted_shows = all_shows.sort_by do | show |
      #
      # end

      for show, index in sorted_shows.each_with_index do
        # Put show into an array as a member of the shows_byt_year hash
        # Create that array if this is the first time we've touched this year
        (shows_by_year[show.data["year"]] ||= []) << show

        # Attach some vars to shows
        show.data["index"] = index
        show.data["next"] = sorted_shows[index + 1]
        show.data["previous"] = sorted_shows[index - 1]

        if show.data["assets"]
          for asset in show.data["assets"]
            if not show.data["poster"] and asset["type"] == "poster"
              show.data["poster"] = asset
            end
          end
        end
      end

      site.data["shows"] = all_shows
      site.data["shows_by_year"] = shows_by_year

    end
  end
end

