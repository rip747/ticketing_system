require "json"

data = JSON.parse(File.read("coverage/.resultset.json"))

# Merge coverage from all result sets
merged = {}
data.each do |_name, info|
  info["coverage"].each do |file_path, cov|
    next unless cov && cov["lines"]
    merged[file_path] ||= cov["lines"].dup
    cov["lines"].each_with_index do |c, i|
      next unless c.is_a?(Integer)
      merged[file_path][i] = c if c > (merged[file_path][i].is_a?(Integer) ? merged[file_path][i] : 0)
    end
  end
end

total = 0
uncovered_total = 0

puts "=== Uncovered Lines ==="
merged.each do |file_path, lines|
  next unless file_path.include?("/app/")
  uncovered = []
  lines.each_with_index do |c, i|
    next unless c.is_a?(Integer)
    total += 1
    uncovered << (i + 1) if c == 0
  end
  if uncovered.any?
    uncovered_total += uncovered.size
    short = file_path.sub("/workspaces/ticketing_system/", "")
    puts "#{short}: lines #{uncovered.join(", ")}"
  end
end

puts "---"
pct = ((total - uncovered_total).to_f / total * 100).round(2)
puts "Total lines: #{total}, Uncovered: #{uncovered_total}, Coverage: #{pct}%"
