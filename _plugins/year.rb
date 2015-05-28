module Jekyll
  class YearDataGenerator < Jekyll::Generator
    priority :low  # Should be one of the last to execute

    def generate(site)
      years = site.collections["years"].docs
      committees = site.collections["committees"].docs

      sorted_years = years.sort_by do | year |
        year.data["sort"]
      end

      years_by_decade = Hash.new

      for year, index in sorted_years.each_with_index
        year_slug = year.basename_without_ext
        (years_by_decade[year.data["decade"]] ||= []) << year

        year.data["committee"] = site.data["committees_by_year"][year_slug]
        year.data["next"] = sorted_years[index + 1]
        year.data["previous"] = sorted_years[index - 1]
        year.data["shows"] = site.data["shows_by_year"][year_slug]
      end

      # Create a copy of years_by_decade but with the lists reversed
      years_by_decade_reversed = Hash.new
      for key, value in years_by_decade.each_pair
        years_by_decade_reversed[key] = value.reverse
      end

      site.data["years_by_decade"] = years_by_decade
      site.data["years_by_decade_reversed"] = years_by_decade_reversed

    end
  end
end

