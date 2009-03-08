require 'rubygems'
require 'yaml'

$ITEMS = YAML.load(File.read('things.yml'))
$IKEYS = $ITEMS.keys
$COSTS = YAML.load(File.read('costs.yml'))

require 'fitness'

class Diet

  @@fitnesses = {}
  @@best = 0
  attr_accessor :items

  def initialize(arr)
    @items = arr
    @stale = 0
  end

  def seed
    size = rand(9)+1
    @items = []
    size.times do
      @items << $IKEYS[rand($IKEYS.size)]
    end
    @stale = 0
  end

  def mutate
    seed if @stale == 1000

    case rand(10)
    when 0 then
      meth = :mutate_insert
    when 1 then
      meth = :mutate_delete
    else
      meth = :mutate_swap
    end
    evo = self.send(meth)

    new_fitness = evo.fitness
    old_fitness = self.fitness

    @stale += 1 if new_fitness == old_fitness

    if ( evo.constraints_ok? and (new_fitness > self.fitness) and cost < 15.0)
      @stale = 0
      if new_fitness > @@best
        @@best = new_fitness
      puts "\n\n"+"-" *30 + "\n" +
           "New best [#{1000-new_fitness}]:\n" +
            evo.to_s
      end
      return evo
    else
      return self
    end
  end

  def constraints_ok?
    @items.unique.size <= 10
  end

  def mutate_insert
    new_item = $IKEYS[rand($IKEYS.size)]
    d = Diet.new(@items.dup.push(new_item))
    (rand(2) == 0) ? d.mutate_insert : d
  end

  def mutate_delete
    if @items.size == 1
      return self
    end
    new_items = @items.dup
    new_items.delete_at( rand(new_items.size) )
    d = Diet.new(new_items)
    if d.items.size == 1
      return d
    end
    (rand(2) == 0) ? d.mutate_delete : d
  end

  def mutate_swap
    new_items = @items.dup
    new_items[rand(new_items.size)] = $IKEYS[rand($IKEYS.size)]
    d = Diet.new(new_items)
    (rand(2) == 0) ? d.mutate_swap : d
  end

  def nutritional_values
    values = Hash.new(0)
    items.map do |key,value|
      [:vitamin_a,
       :sodium,
       :vitamin_c,
       :calories,
       :total_carbs,
       :calcium,
       :calories_from_fat,
       :fiber,
       :iron,
       :total_fat,
       :sugars,
       :size,
       :saturated_fat,
       :protein,
       :cholesterol].each do |name|
         values[name] += $ITEMS[key][name].to_i
      end
    end
    output = []
    values.each do |key,value|
      output << "#{key}: ".ljust(25,'.') +" #{value}".rjust(8)
    end
    output
  end
  def cost
    hash = Hash.new(0)
    items.map { |value| hash[value]+=1}
    cost = 0
    hash.each do |key,value|
      cost += ($COSTS[key]||1 )* value
    end
    cost
  end
  def ingredients
    hash = Hash.new(0)
    items.map { |value| hash[value]+=1}
    hash.map { |key,value| "#{value} x #{key}" }
  end
  def to_s
    output = []
    output << '-'*35
    output << "\n"
    output << 'Cost:'
    output << "$%.2f" % cost
    output << "\n"
    output << 'Nutritional Values:'
    output += ingredients
    output << "\n"
    output << 'Nutritional Values:'
    output += nutritional_values
    output.join("\n")
  end
end

if __FILE__ == $0
  diet = Diet.new(['Oranges', 'Oranges', 'Oranges', 'Oranges'])
  loop do
    diet = diet.mutate
  end
end
