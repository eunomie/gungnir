require_relative 'git'

class Gungnir
  def initialize repo
    @repo = repo
  end

  def create content
    @repo.write(content.to_yaml, format(content["id"]), "add a todo")
  end

  def all
    result = []
    oids = @repo.get_all
    oids.each do |obj|
      result.push YAML.load obj
    end
    result.sort { |a, b| b["time"] <=> a["time"] }
  end

  def mark_as_done id
    obj = @repo.get(format(id))
    return if obj == nil
    item = YAML.load obj
    item["done"] = true
    @repo.write(item.to_yaml, format(id), "mark as done")
  end

  def delete id
    @repo.delete(format(id), "delete a todo")
  end

  private
  def format id
    "items/#{id}"
  end
end
