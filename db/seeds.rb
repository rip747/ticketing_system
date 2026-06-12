# Create Departments
dept_it = Department.find_or_create_by!(name: "IT Support") do |d|
  d.description = "Handles all technical issues including hardware, software, and network problems."
end

dept_hr = Department.find_or_create_by!(name: "Human Resources") do |d|
  d.description = "Manages employee relations, payroll, benefits, and recruitment inquiries."
end

dept_finance = Department.find_or_create_by!(name: "Finance") do |d|
  d.description = "Handles billing, invoicing, payments, and financial inquiries."
end

dept_ops = Department.find_or_create_by!(name: "Operations") do |d|
  d.description = "Manages day-to-day operational issues and facility management."
end

# Create Categories
categories = [
  { name: "Hardware Issue", department: dept_it },
  { name: "Software Issue", department: dept_it },
  { name: "Network Problem", department: dept_it },
  { name: "Email Problem", department: dept_it },
  { name: "Payroll Inquiry", department: dept_hr },
  { name: "Leave Request", department: dept_hr },
  { name: "Recruitment", department: dept_hr },
  { name: "Billing Question", department: dept_finance },
  { name: "Invoice Request", department: dept_finance },
  { name: "Refund Request", department: dept_finance },
  { name: "Facility Issue", department: dept_ops },
  { name: "General Inquiry", department: dept_ops }
]

categories.each do |cat|
  Category.find_or_create_by!(name: cat[:name], department: cat[:department])
end

# Create Admin User
admin = User.find_or_create_by!(email: "admin@helpdesk.com") do |u|
  u.name = "System Admin"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = "admin"
  u.department = dept_it
end

# Create Agents
agent1 = User.find_or_create_by!(email: "sarah@helpdesk.com") do |u|
  u.name = "Sarah Johnson"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = "agent"
  u.department = dept_it
end

agent2 = User.find_or_create_by!(email: "mike@helpdesk.com") do |u|
  u.name = "Mike Chen"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = "agent"
  u.department = dept_hr
end

agent3 = User.find_or_create_by!(email: "emma@helpdesk.com") do |u|
  u.name = "Emma Wilson"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = "agent"
  u.department = dept_finance
end

# Create Customers
customers = [
  { name: "John Doe", email: "john@example.com", department: dept_it },
  { name: "Jane Smith", email: "jane@example.com", department: dept_hr },
  { name: "Bob Johnson", email: "bob@example.com", department: dept_ops },
  { name: "Alice Brown", email: "alice@example.com", department: dept_finance },
  { name: "Charlie Davis", email: "charlie@example.com", department: dept_it }
]

customer_records = customers.map do |c|
  User.find_or_create_by!(email: c[:email]) do |u|
    u.name = c[:name]
    u.password = "password123"
    u.password_confirmation = "password123"
    u.role = "customer"
    u.department = c[:department]
  end
end

# Create Sample Tickets
tickets_data = [
  { subject: "Cannot connect to company VPN", description: "Since this morning, I've been unable to connect to the company VPN. I've tried restarting my computer but the issue persists.", user: customer_records[0], department: dept_it, category: dept_it.categories.find_by(name: "Network Problem"), priority: "high", status: "open" },
  { subject: "Laptop screen flickering", description: "My laptop screen has started flickering intermittently. It's becoming difficult to work.", user: customer_records[1], department: dept_it, category: dept_it.categories.find_by(name: "Hardware Issue"), priority: "medium", status: "open" },
  { subject: "Payroll discrepancy for June", description: "I noticed my June paycheck is missing the overtime hours I worked. Please investigate.", user: customer_records[2], department: dept_hr, category: dept_hr.categories.find_by(name: "Payroll Inquiry"), priority: "high", status: "pending" },
  { subject: "Email not sending attachments", description: "My Outlook client is not allowing me to send emails with attachments larger than 2MB.", user: customer_records[3], department: dept_it, category: dept_it.categories.find_by(name: "Email Problem"), priority: "medium", status: "open" },
  { subject: "Request for new software license", description: "I need a license for Adobe Creative Cloud for the design team. Please process the purchase.", user: customer_records[4], department: dept_finance, category: dept_finance.categories.find_by(name: "Invoice Request"), priority: "low", status: "resolved" },
  { subject: "Office printer not working", description: "The printer on the 3rd floor is showing a paper jam error even though there's no jam.", user: customer_records[0], department: dept_ops, category: dept_ops.categories.find_by(name: "Facility Issue"), priority: "medium", status: "open" },
  { subject: "Annual leave request for July", description: "I would like to request annual leave from July 15-22. Please approve.", user: customer_records[1], department: dept_hr, category: dept_hr.categories.find_by(name: "Leave Request"), priority: "low", status: "pending" },
  { subject: "Refund for duplicate invoice", description: "Invoice #INV-2024-089 was charged twice to our account. Need a refund for the duplicate.", user: customer_records[2], department: dept_finance, category: dept_finance.categories.find_by(name: "Refund Request"), priority: "urgent", status: "open" }
]

tickets_data.each do |t|
  Ticket.find_or_create_by!(subject: t[:subject]) do |tk|
    tk.description = t[:description]
    tk.user = t[:user]
    tk.department = t[:department]
    tk.category = t[:category]
    tk.priority = t[:priority]
    tk.status = t[:status]
    tk.assigned_user = t[:status] == "resolved" ? agent1 : nil
    tk.closed_at = t[:status] == "resolved" ? Time.current : nil
  end
end

# Add comments to some tickets
ticket1 = Ticket.find_by(subject: "Cannot connect to company VPN")
if ticket1 && ticket1.comments.empty?
  ticket1.comments.create!(body: "I've checked the VPN server status and it seems to be running fine. Can you try connecting with a different network?", user: agent1)
  ticket1.comments.create!(body: "I tried with my home network and mobile hotspot, neither works. Could there be an issue with my account?", user: customer_records[0])
end

ticket2 = Ticket.find_by(subject: "Payroll discrepancy for June")
if ticket2 && ticket2.comments.empty?
  ticket2.comments.create!(body: "Thank you for reporting this. We're looking into the June payroll records and will get back to you within 48 hours.", user: agent2)
end

puts "Seed data created successfully!"
puts "  #{Department.count} departments"
puts "  #{Category.count} categories"
puts "  #{User.count} users"
puts "  #{Ticket.count} tickets"
puts "  #{Comment.count} comments"
puts ""
puts "Login credentials:"
puts "  Admin:  admin@helpdesk.com / password123"
puts "  Agent:  sarah@helpdesk.com / password123"
puts "  Agent:  mike@helpdesk.com / password123"
puts "  Agent:  emma@helpdesk.com / password123"
puts "  Customer: john@example.com / password123"
