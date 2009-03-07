require 'rubygems'
require 'yaml'

ITEMS = YAML.load(File.read('things.yml'))
IKEYS = ITEMS.keys

class Diet

  attr_accessor :items
  
  def initialize(arr)
    @items = arr
  end
  
  def fitness
    return 1
  end

  def mutate
    case rand(10)
    when 0:
      meth = :mutate_insert
    when 1:
      meth = :mutate_delete
    else
      meth = :mutate_swap
    end
    evo = self.send(meth)

    current_fitness = self.fitness
    new_fitness     = evo.fitness

    return (new_fitness > current_fitness) ? evo : this
  end

  private
  def mutate_insert
    new_item = IKEYS[rand(IKEYS.size)]
    Diet.new(@items.push(new_item))
  end

  def mutate_delete
    new_items = @items
    new_items.delete_at( rand(new_items.size) )
    Diet.new(new_items)
  end

  def mutate_swap
    new_items = @items
    new_items[rand(new_items.size)] = IKEYS[rand(IKEYS.size)]
    Diet.new(@items)
  end

end

if __FILE__ == $0
  diet = Diet.new(["Oranges", "Oranges", "Oranges", "Oranges"])
  puts diet.mutate.items
end
