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
      item['calories']
    }.inject(&:+)
    fat_cals = items.map { |item|
      item['calories_from_fat']
    }.inject(&:+)

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

    if ( evo.constraints_ok? and (new_fitness > self.fitness) )
      puts "New best: "
      return evo
    else
      return self
    end
  end

  def constraints_ok?
    @items.size <= 10
  end
  
  private
  def mutate_insert
    new_item = $IKEYS[rand($IKEYS.size)]
    Diet.new(@items.push(new_item))
  end

  def mutate_delete
    new_items = @items
    new_items.delete_at( rand(new_items.size) )
    Diet.new(new_items)
  end

  def mutate_swap
    new_items = @items
    new_items[rand(new_items.size)] = $IKEYS[rand($IKEYS.size)]
    Diet.new(@items)
  end

end

if __FILE__ == $0
  diet = Diet.new(["Oranges", "Oranges", "Oranges", "Oranges"])
  puts diet.mutate.items
end
