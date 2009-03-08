require 'rubygems'
require 'yaml'

$ITEMS = YAML.load(File.read('things.yml'))
$IKEYS = $ITEMS.keys
$COSTS = YAML.load(File.read('costs.yml'))

adjustments = {}
adjustments['1/2 Pita Bread'] = 1*5
adjustments['Banana'] = 7*5
adjustments['Broccoli'] = 1*5
adjustments['Chicken Bread'] = 4*5
adjustments['Corn Flakes'] = 36*5
adjustments['Egg'] = 4*5
adjustments['Enriched Soya Drink'] = 4*5
adjustments['Green Pepper'] = 1*5
adjustments['Kamut, Pasta'] = 26*5
adjustments['Kiwi'] = 2*5
adjustments['Nuts'] = 4*5
adjustments['Orange Juice'] =13*5
adjustments['Regular Pasta, Cooked'] = 1*5
adjustments['Rye Bread'] = 1*5
adjustments['Tomato'] = 20*5

adjustments.each do |k,v|
   # Figure out increase
  $COSTS[k] = 1.0 if !$COSTS[k]
  $COSTS[k] += adjustments[k] * 0.001
end

require 'fitness'
NUM_BEST = 5
class Diet

  @@fitnesses = {}
  @@best = 0
  @@bests = []
  attr_accessor :items

  def self.bests
    @@bests
  end

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

    if ( evo.constraints_ok? and (new_fitness > self.fitness))
      @stale = 0
      if new_fitness > @@best
        @@best = new_fitness
        puts "\n\n"+"-" *30 + "\n" +
          "New best [#{1000-new_fitness}]:\n" +
          evo.to_s
        @@bests << evo
      end
      reduce_bests
      return evo
    else
      return self
    end
  end

  def reduce_bests
    if @@bests.size > NUM_BEST
      @@bests = @@bests.sort {|a,b| b.fitness <=> a.fitness }[0...NUM_BEST]
    end
  end

  def constraints_ok?
    @items.uniq.size <= 10 && cost <= 15.00
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
      cost += ($COSTS[key]||1.0 ) * value
    end
    cost
  end
  def ingredients
    hash = Hash.new(0)
    items.map { |value| hash[value]+=1}
    hash.map { |key,value| "#{value} x #{key}".ljust(30) + "#{"$%.2f"%($COSTS[key] || 1)}" }
  end
  def to_s
    output = []
    output << '-'*35
    output << "\n"
    output << 'Cost:'
    output << "$%.2f" % cost
    output << "\n"
    output << 'Ingerients Values:'
    output += ingredients
#    output << "Bests: #{@@bests.size}"
#    output << "\n"
#    output << 'Nutritional Values:'
#    output += nutritional_values
    output.join("\n")
  end
end

if __FILE__ == $0
  diet = Diet.new(['Oranges', 'Oranges', 'Oranges', 'Oranges'])
  Kernel.trap("INT") do
    puts "PRINTING BESTS STATISTICS:"
    print =*35
    bests = Diet.bests
    totals = Hash.new(0)
    puts bests

    bests.each do |best|
      best.items.each do |item|
        totals[item] += best.items.count(item)
      end
    end
    totals.each { |k,v| puts "#{v} x #{k}"}
    exit
  end
  loop do
    diet = diet.mutate
  end


end
