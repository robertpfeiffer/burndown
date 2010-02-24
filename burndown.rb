require 'yaml'
require 'date'
require 'rubygems'
require 'scruffy'

sprint = YAML::load_file("project/current/plan.yml")
todo = YAML::load_file("project/current/todo.yml")
current_todo = 0

Dir["project/features/*.yml"].each do |file|
  story = YAML::load_file(file)
  if sprint["Features"].include? story["Titel"]
    if todo.has_key? story["Titel"] 
      current_todo += story["Zeit"]
    end
  end
end

graphdata=YAML::load_file("project/current/burndown.yml")
graphdata[Date.today]=current_todo 
File.open("project/current/burndown.yml", 'w' ) do |out|
  YAML::dump(graphdata, out)
end

last=0
chartdata = (sprint["Start"] .. sprint["Ende"]).collect do |day|
  if graphdata.has_key? day
    last =graphdata[day]
  end
  last
end

graph = Scruffy::Graph.new
graph.title = "Burn Down Chart"
graph.renderer = Scruffy::Renderers::Standard.new
puts chartdata.inspect

graph.add :line, 'TODO', chartdata

graph.render :to => "project/current/burndown.png", :as => "png", :size => [500,500]
