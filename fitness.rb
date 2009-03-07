#diet is array of item names
class Diet
  def fitness
    sorted = @items.sort
    @@fitnesses[sorted] ||= self.fitness_nonmemo
  end

  def fitness_nonmemo
    diet = self.items
    score = 0
    if constraints_ok?
      # Start with a base score of 1000
      score = 1000

      # Remove 1 pt for each calorie over or under 2000
      total_cals = diet.inject(0) {|sum,item| sum + Integer($ITEMS[item][:calories]) }
      score -= 1 * (2000 - total_cals).abs

      # Remove 5 pts of each percentage of fatty calories over 25%
      total_fat_over_25 = self.percentage_of_calories_from_fats() - 25
      score -= 5 * ( total_fat_over_25 > 0 ? total_fat_over_25 : 0 ) # only care about OVER

      # Remove 2 pts for each 1g of protein over or under 100
      total_protein = diet.inject(0) {|sum,item| sum + Integer($ITEMS[item][:protein]) }
      score -= 2 * (100 - total_protein).abs

      # Remove 3 pts for each 1g of fiber over or under 20
      total_fiber = diet.inject(0) {|sum,item| sum + Integer($ITEMS[item][:fiber]) }
      score -= 3 * (20 - total_fiber).abs

      # Remove 50 pts for each missing portion of fruits, vegetables, milk, or meat
      # Remove 20 pts for each extra portion of fruits, vegetables, milk or meat
      types = diet.map { |item| $ITEMS[item][:type] }
      type_totals = Hash.new(0)
      type_totals["fruit and vegetable"] = types.find_all {|type| type == "fruit and vegetable"}.size
      type_totals["milk"] = types.find_all {|type| type == "milk"}.size
      type_totals["meat"] = types.find_all {|type| type == "meat"}.size

      milk_diff = (2 - type_totals["milk"]).abs
      if type_totals["milk"] > 2
        score -= 20 * milk_diff
      elsif type_totals["milk"] < 2
        score -= 50 * milk_diff
      end

      fruveg_diff = (6 - type_totals["fruit and vegetable"]).abs
      if type_totals["fruit and vegetable"] > 6
        score -= 20 * fruveg_diff
      elsif type_totals["fruit and vegetable"] < 6
        score -= 50 * fruveg_diff
      end

      meat_diff = (2 - type_totals["meat"]).abs
      if type_totals["meat"] > 2
        score -= 20 * meat_diff
      elsif type_totals["meat"] < 2
        score -= 50 * meat_diff
      end

      # Remove 2 pts for each 1g of trans or saturated fats
      score -= 2 * diet.inject(0) {|sum,item| sum + Integer($ITEMS[item][:saturated_fat]) } # Add trans fat
    end
    score
  end
end

