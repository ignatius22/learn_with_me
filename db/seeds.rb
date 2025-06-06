# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Starting seed process..."

# Clear existing data in development environment
if Rails.env.development?
  puts "🧹 Cleaning up existing data..."
  Review.destroy_all
  Lesson.destroy_all
  Section.destroy_all
  Enrollment.destroy_all
  Student.destroy_all
  User.destroy_all
  Course.destroy_all
  Author.destroy_all
  Role.destroy_all
end

# Create Roles
puts "👥 Creating roles..."
roles = [
  { name: 'student' },
  { name: 'author' },
  { name: 'admin' }
]

roles.each do |role_attrs|
  Role.find_or_create_by!(role_attrs)
end

puts "✅ Created #{Role.count} roles"

# Create Authors
puts "✍️ Creating authors..."
authors_data = [
  {
    first_name: 'Jane',
    last_name: 'Smith',
    email: 'jane.smith@example.com',
    bio: 'Experienced software developer with 10+ years in web development. Passionate about teaching Ruby on Rails and modern web technologies.'
  },
  {
    first_name: 'John',
    last_name: 'Doe',
    email: 'john.doe@example.com',
    bio: 'Full-stack developer and educator specializing in JavaScript, React, and Node.js. Author of several programming books.'
  },
  {
    first_name: 'Sarah',
    last_name: 'Johnson',
    email: 'sarah.johnson@example.com',
    bio: 'Data scientist and machine learning expert. PhD in Computer Science with focus on AI and data analytics.'
  }
]

authors = authors_data.map do |author_attrs|
  Author.find_or_create_by!(email: author_attrs[:email]) do |author|
    author.assign_attributes(author_attrs)
  end
end

puts "✅ Created #{Author.count} authors"

# Create Courses
puts "📚 Creating courses..."
courses_data = [
  {
    title: 'Ruby on Rails Fundamentals',
    description: 'Learn the basics of Ruby on Rails framework. This comprehensive course covers MVC architecture, routing, models, views, controllers, and database operations.',
    price: 99.99,
    duration_in_hours: 20,
    author: authors[0]
  },
  {
    title: 'Advanced Rails Techniques',
    description: 'Master advanced Rails concepts including background jobs, caching, API development, and performance optimization.',
    price: 149.99,
    duration_in_hours: 35,
    author: authors[0]
  },
  {
    title: 'JavaScript for Beginners',
    description: 'Complete introduction to JavaScript programming. Learn variables, functions, DOM manipulation, and modern ES6+ features.',
    price: 79.99,
    duration_in_hours: 15,
    author: authors[1]
  },
  {
    title: 'React Development Bootcamp',
    description: 'Build modern web applications with React. Covers components, hooks, state management, and deployment.',
    price: 199.99,
    duration_in_hours: 40,
    author: authors[1]
  },
  {
    title: 'Data Science with Python',
    description: 'Introduction to data science using Python. Learn pandas, numpy, matplotlib, and basic machine learning.',
    price: 129.99,
    duration_in_hours: 30,
    author: authors[2]
  },
  {
    title: 'Machine Learning Fundamentals',
    description: 'Comprehensive introduction to machine learning algorithms and techniques. Hands-on projects included.',
    price: 179.99,
    duration_in_hours: 45,
    author: authors[2]
  }
]

courses = courses_data.map do |course_attrs|
  Course.find_or_create_by!(title: course_attrs[:title]) do |course|
    course.assign_attributes(course_attrs)
  end
end

puts "✅ Created #{Course.count} courses"

# Create Admin User
puts "👑 Creating admin user..."
admin_role = Role.find_by!(name: 'admin')

# Create admin user
admin_user = User.find_or_create_by!(email: 'admin@learnwithme.com') do |u|
  u.password = 'admin123'
  u.password_confirmation = 'admin123'
end

# Create admin student profile
Student.find_or_create_by!(user: admin_user) do |admin|
  admin.first_name = 'Admin'
  admin.last_name = 'User'
  admin.role = admin_role
end

puts "✅ Created admin user (admin@learnwithme.com / admin123)"

# Create Users and Students
puts "👤 Creating users and students..."
student_role = Role.find_by!(name: 'student')

students_data = [
  {
    email: 'alice.brown@example.com',
    password: 'password123',
    first_name: 'Alice',
    last_name: 'Brown'
  },
  {
    email: 'bob.wilson@example.com',
    password: 'password123',
    first_name: 'Bob',
    last_name: 'Wilson'
  },
  {
    email: 'carol.davis@example.com',
    password: 'password123',
    first_name: 'Carol',
    last_name: 'Davis'
  },
  {
    email: 'david.miller@example.com',
    password: 'password123',
    first_name: 'David',
    last_name: 'Miller'
  },
  {
    email: 'eva.garcia@example.com',
    password: 'password123',
    first_name: 'Eva',
    last_name: 'Garcia'
  }
]

students = students_data.map do |student_data|
  user = User.find_or_create_by!(email: student_data[:email]) do |u|
    u.password = student_data[:password]
    u.password_confirmation = student_data[:password]
  end
  
  Student.find_or_create_by!(user: user) do |student|
    student.first_name = student_data[:first_name]
    student.last_name = student_data[:last_name]
    student.role = student_role
  end
end

puts "✅ Created #{User.count} users and #{Student.count} students"

# Create Enrollments
puts "📝 Creating enrollments..."
enrollments_data = [
  # Alice enrolls in multiple courses
  { student: students[0], course: courses[0], status: 'enrolled' },
  { student: students[0], course: courses[2], status: 'completed' },
  { student: students[0], course: courses[4], status: 'enrolled' },
  
  # Bob enrolls in Rails courses
  { student: students[1], course: courses[0], status: 'completed' },
  { student: students[1], course: courses[1], status: 'enrolled' },
  
  # Carol focuses on JavaScript
  { student: students[2], course: courses[2], status: 'enrolled' },
  { student: students[2], course: courses[3], status: 'enrolled' },
  
  # David explores data science
  { student: students[3], course: courses[4], status: 'completed' },
  { student: students[3], course: courses[5], status: 'enrolled' },
  
  # Eva tries various courses
  { student: students[4], course: courses[0], status: 'enrolled' },
  { student: students[4], course: courses[3], status: 'dropped' },
  { student: students[4], course: courses[5], status: 'enrolled' }
]

enrollments_data.each do |enrollment_attrs|
  Enrollment.find_or_create_by!(
    student: enrollment_attrs[:student],
    course: enrollment_attrs[:course]
  ) do |enrollment|
    enrollment.status = enrollment_attrs[:status]
    enrollment.enrollment_date = rand(30.days).seconds.ago
  end
end

puts "✅ Created #{Enrollment.count} enrollments"

# Create Sections and Lessons
puts "📑 Creating sections and lessons..."

# Add sections to the first course (Ruby on Rails Fundamentals)
rails_course = courses[0]
rails_sections = [
  {
    title: 'Getting Started with Rails',
    position: 1,
    lessons: [
      { title: 'What is Ruby on Rails?', content_type: 'video', duration_in_minutes: 10, position: 1 },
      { title: 'Installing Rails', content_type: 'video', duration_in_minutes: 15, position: 2 },
      { title: 'Your First Rails App', content_type: 'video', duration_in_minutes: 20, position: 3 }
    ]
  },
  {
    title: 'MVC Architecture',
    position: 2,
    lessons: [
      { title: 'Understanding MVC', content_type: 'video', duration_in_minutes: 18, position: 1 },
      { title: 'Models and Databases', content_type: 'video', duration_in_minutes: 25, position: 2 },
      { title: 'Views and Templates', content_type: 'video', duration_in_minutes: 20, position: 3 },
      { title: 'Controllers and Actions', content_type: 'video', duration_in_minutes: 22, position: 4 }
    ]
  },
  {
    title: 'Building Your First Feature',
    position: 3,
    lessons: [
      { title: 'Creating Routes', content_type: 'video', duration_in_minutes: 15, position: 1 },
      { title: 'Building Forms', content_type: 'video', duration_in_minutes: 30, position: 2 },
      { title: 'Adding Validations', content_type: 'video', duration_in_minutes: 20, position: 3 }
    ]
  }
]

rails_sections.each do |section_data|
  section = Section.find_or_create_by!(course: rails_course, position: section_data[:position]) do |s|
    s.title = section_data[:title]
  end
  
  section_data[:lessons].each do |lesson_data|
    Lesson.find_or_create_by!(section: section, position: lesson_data[:position]) do |lesson|
      lesson.title = lesson_data[:title]
      lesson.content_type = lesson_data[:content_type]
      lesson.duration_in_minutes = lesson_data[:duration_in_minutes]
      
      # Add appropriate content based on type
      if lesson_data[:content_type] == 'video'
        lesson.content_url = "https://example.com/videos/#{lesson_data[:title].parameterize}.mp4"
      else
        lesson.text_content = "This is the content for #{lesson_data[:title]}. Here you will learn about the key concepts and practical applications."
      end
    end
  end
end

# Add sections to JavaScript course
js_course = courses[2]
js_sections = [
  {
    title: 'JavaScript Basics',
    position: 1,
    lessons: [
      { title: 'Variables and Data Types', content_type: 'video', duration_in_minutes: 12, position: 1 },
      { title: 'Functions and Scope', content_type: 'video', duration_in_minutes: 18, position: 2 }
    ]
  },
  {
    title: 'DOM Manipulation',
    position: 2,
    lessons: [
      { title: 'Selecting Elements', content_type: 'video', duration_in_minutes: 15, position: 1 },
      { title: 'Event Handling', content_type: 'video', duration_in_minutes: 20, position: 2 }
    ]
  }
]

js_sections.each do |section_data|
  section = Section.find_or_create_by!(course: js_course, position: section_data[:position]) do |s|
    s.title = section_data[:title]
  end
  
  section_data[:lessons].each do |lesson_data|
    Lesson.find_or_create_by!(section: section, position: lesson_data[:position]) do |lesson|
      lesson.title = lesson_data[:title]
      lesson.content_type = lesson_data[:content_type]
      lesson.duration_in_minutes = lesson_data[:duration_in_minutes]
      
      # Add appropriate content based on type
      if lesson_data[:content_type] == 'video'
        lesson.content_url = "https://example.com/videos/#{lesson_data[:title].parameterize}.mp4"
      else
        lesson.text_content = "This is the content for #{lesson_data[:title]}. Here you will learn about the key concepts and practical applications."
      end
    end
  end
end

puts "✅ Created #{Section.count} sections and #{Lesson.count} lessons"

# Create Reviews
puts "⭐ Creating reviews..."
reviews_data = [
  { student: students[0], course: courses[0], rating: 5, comment: 'Excellent course! Very well structured and easy to follow.' },
  { student: students[1], course: courses[0], rating: 4, comment: 'Great content, but could use more practical examples.' },
  { student: students[0], course: courses[2], rating: 5, comment: 'Perfect introduction to JavaScript. Highly recommended!' },
  { student: students[2], course: courses[2], rating: 4, comment: 'Good pace and clear explanations.' },
  { student: students[3], course: courses[4], rating: 5, comment: 'Amazing data science course. Learned so much!' },
  { student: students[1], course: courses[1], rating: 4, comment: 'Advanced concepts explained well.' }
]

reviews_data.each do |review_attrs|
  Review.find_or_create_by!(
    student: review_attrs[:student],
    course: review_attrs[:course]
  ) do |review|
    review.rating = review_attrs[:rating]
    review.comment = review_attrs[:comment]
  end
end

puts "✅ Created #{Review.count} reviews"

puts "🎉 Seed process completed successfully!"
puts ""
puts "📊 Summary:"
puts "   Roles: #{Role.count}"
puts "   Authors: #{Author.count}"
puts "   Courses: #{Course.count}"
puts "   Users: #{User.count}"
puts "   Students: #{Student.count}"
puts "   Enrollments: #{Enrollment.count}"
puts ""
puts "🔑 Sample login credentials:"
puts "   👑 Admin:"
puts "      Email: admin@learnwithme.com"
puts "      Password: admin123"
puts ""
puts "   👤 Student:"
puts "      Email: alice.brown@example.com"
puts "      Password: password123"
