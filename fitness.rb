#diet is array of item names
class Diet
  def fitness(diet)
    score = 0
    if constraints_ok? diet
      # Start with a base score of 1000
      score = 1000
      total_cals = diet.inject(0) {|sum,item| sum + ITEMS[item] }
      # Remove 1 pt for each calorie over or under 2000
      score -= (2000 - total_cals).abs
      # Remove 5 pts of each percentage of fatty calories over 25%
      # Remove 2 pts for each 1g of protein over or under 100
      # Remove 3 pts for each 1g of fiber over or under 20
      # Remove 50 pts for each missing portion of fruits, vegetables, milk, or meat
      # Remove 20 pts for each extra portion of fruits, vegetables, milk or meat
      # Remove 2 pts for each 1g of trans or saturated fats
    end
    score
  end
end

