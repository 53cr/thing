#diet is array of item names
def fitness(diet)
  score = 0
  if fits_in_constraints? diet
    total_cals = diet.inject(0) {|sum,item| sum + ITEMS[item]
  end
  score
end
def fits_in_constraints?(diet)

end
