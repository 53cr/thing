#diet is array of item names
class Diet
  def fitness
    sorted = @items.sort
    if !@@fitnesses[sorted]
      @@fitnesses[sorted] = self.fitness_nonmemo
    end
    @@fitnesses[sorted]
  end      
    
  def fitness_nonmemo
    score = 0
    if constraints_ok? diet
      # Start with a base score of 1000
      score = 1000
      total_cals = diet.inject(0) {|sum,item| sum + Integer($ITEMS[item][:calories]) }
      # Remove 1 pt for each calorie over or under 2000
      score -= 1 * (2000 - total_cals).abs
      # Remove 5 pts of each percentage of fatty calories over 25%
      # Remove 2 pts for each 1g of protein over or under 100
      total_protein = diet.inject(0) {|sum,item| sum + Integer($ITEMS[item][:protein]) }
      score -= 2 * (100 - total_protein).abs
      # Remove 3 pts for each 1g of fiber over or under 20
      total_fiber = diet.inject(0) {|sum,item| sum + Integer($ITEMS[item][:fiber]) }
      score -= 3 * (20 - total_fiber).abs
      # Remove 50 pts for each missing portion of fruits, vegetables, milk, or meat
      types = diet.map { |item| $ITEMS[item][:type] }.inject(Hash(0)) # NOT DONE
      # Remove 20 pts for each extra portion of fruits, vegetables, milk or meat
      # Remove 2 pts for each 1g of trans or saturated fats
    end
    score
  end
end

