#diet is array of item names
class Diet
  def fitness(diet)
    score = 0
    if fits_in_constraints? diet
      score = 1000
      total_cals = diet.inject(0) {|sum,item| sum + ITEMS[item] }
      # Remove 1 pt for each calorie over or under 2000
      score -= (2000 - total_cals).abs

    end
    score
  end
end

