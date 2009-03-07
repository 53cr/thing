require 'rubygems'
require 'yaml'

$ITEMS = YAML.load(File.read('things.yml'))
$IKEYS = $ITEMS.keys

require 'fitness'

class Diet

  @@fitnesses = {}
  
  attr_accessor :items
  
  def initialize(arr)
    @items = arr
  end

  def percentage_of_calories_from_fats
    items = @items.map do |item|
      $ITEMS[item]
    end

    total_cals = items.map { |item|
      item[:calories].to_i
    }.inject { |sum,value| sum + value }

    fat_cals = items.map { |item|
      item[:calories_from_fat].to_i
    }.inject{ |sum,value| sum + value }

    return 100*(fat_cals / total_cals.to_f).round
  end
  
  def mutate
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

    #puts "OLD: #{old_fitness}; NEW #{new_fitness}"
    
    if ( evo.constraints_ok? and (new_fitness > self.fitness) )
      puts "New best [#{1000-new_fitness}]: #{evo.items.sort.join ' : '}"
      return evo
    else
      return self
    end
  end

  def constraints_ok?
    @items.size <= 10
  end

  def mutate_insert
    new_item = $IKEYS[rand($IKEYS.size)]
    Diet.new(@items.dup.push(new_item))
  end

  def mutate_delete
    new_items = @items.dup
    new_items.delete_at( rand(new_items.size) )
    Diet.new(new_items)
  end

  def mutate_swap
    new_items = @items.dup
    new_items[rand(new_items.size)] = $IKEYS[rand($IKEYS.size)]
    d = Diet.new(new_items)
    if rand(2) == 0
      d.mutate_swap
    else
      d
    end
  end

end

if __FILE__ == $0
  diet = Diet.new(["Oranges", "Oranges", "Oranges", "Oranges"])

  loop do
    diet = diet.mutate
  end

end
