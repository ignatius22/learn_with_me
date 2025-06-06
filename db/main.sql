-- main.sql
-- This file contains the SQL commands to create the database schema for your application.
-- It includes tables for roles, users (for authentication), students, authors,
-- courses, sections, lessons, enrollments, and reviews.
-- Updated for a Udemy-like learning platform, separating User authentication from Student profile.

-- Define the ENUM type for role names
-- You can add more roles here as needed (e.g., 'admin', 'moderator')
CREATE TYPE role_type AS ENUM ('student', 'author', 'admin');

-- 1. Create `roles` Table
CREATE TABLE roles (
    id BIGSERIAL PRIMARY KEY,
    name role_type NOT NULL UNIQUE, -- Uses the ENUM type
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 2. Create `authors` Table
CREATE TABLE authors (
    id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE, -- Author's contact email, not for login
    bio TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 3. Create `users` Table (NEW: For Devise authentication)
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE, -- Essential for Devise login
    encrypted_password VARCHAR(255) NOT NULL DEFAULT '', -- Essential for Devise

    -- Devise modules for authentication features
    reset_password_token VARCHAR(255),
    reset_password_sent_at TIMESTAMP,
    remember_created_at TIMESTAMP,

    -- Optional Devise :trackable columns (uncomment if using)
    sign_in_count INTEGER DEFAULT 0 NOT NULL,
    current_sign_in_at TIMESTAMP,
    last_sign_in_at TIMESTAMP,
    current_sign_in_ip VARCHAR(255),
    last_sign_in_ip VARCHAR(255),

    -- Optional Devise :confirmable columns (uncomment if using)
    -- confirmation_token VARCHAR(255),
    -- confirmed_at TIMESTAMP,
    -- confirmation_sent_at TIMESTAMP,
    -- unconfirmed_email VARCHAR(255),

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Add essential indexes for Devise on the users table
CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);
CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);
-- CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token); -- Uncomment if :confirmable is enabled

-- 4. Create `students` Table (CLEANED UP: now links to `users` for auth)
CREATE TABLE students (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE, -- Foreign Key to `users.id` (one-to-one relationship)
    role_id BIGINT NOT NULL, -- Foreign Key to `roles.id`
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    -- Removed all Devise-specific columns (email, encrypted_password, etc.) as they are now in `users`
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);


-- 5. Create `courses` Table
CREATE TABLE courses (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    duration_in_hours INTEGER,
    author_id BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 6. Create `sections` Table (For course content structure)
CREATE TABLE sections (
    id BIGSERIAL PRIMARY KEY,
    course_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    position INTEGER NOT NULL, -- Order of sections within a course
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 7. Create `lessons` Table (For actual course content)
CREATE TABLE lessons (
    id BIGSERIAL PRIMARY KEY,
    section_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content_type VARCHAR(255) NOT NULL, -- e.g., 'video', 'text', 'quiz'
    content_url TEXT, -- URL for video, audio, or external resource
    text_content TEXT, -- Text content for text-based lessons
    duration_in_minutes INTEGER, -- Duration for video/audio lessons
    position INTEGER NOT NULL, -- Order of lessons within a section
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 8. Create `enrollments` Table (Junction Table)
CREATE TABLE enrollments (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT NOT NULL,
    course_id BIGINT NOT NULL,
    enrollment_date TIMESTAMP NOT NULL DEFAULT NOW(),
    status VARCHAR(255) DEFAULT 'enrolled', -- e.g., 'enrolled', 'completed', 'dropped'
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (student_id, course_id) -- Ensures a student can enroll in a course only once
);

-- 9. Create `reviews` Table (For student feedback)
CREATE TABLE reviews (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT NOT NULL,
    course_id BIGINT NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5), -- Rating from 1 to 5
    comment TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (student_id, course_id) -- Ensures a student can only leave one review per course
);


-- 10. Add Foreign Key Constraints
-- These constraints establish relationships between tables and define behavior on deletion.

-- Add foreign key to students table for user_id (NEW)
ALTER TABLE students
ADD CONSTRAINT fk_students_user_id
FOREIGN KEY (user_id) REFERENCES users(id)
ON DELETE CASCADE; -- If a user account is deleted, their student profile is also deleted

-- Add foreign key to students table for role_id
ALTER TABLE students
ADD CONSTRAINT fk_students_role_id
FOREIGN KEY (role_id) REFERENCES roles(id)
ON DELETE NO ACTION; -- Prevents deleting a role if students are associated with it

-- Add foreign key to courses table for author_id
ALTER TABLE courses
ADD CONSTRAINT fk_courses_author_id
FOREIGN KEY (author_id) REFERENCES authors(id)
ON DELETE NO ACTION; -- Prevents deleting an author if courses are associated with them

-- Add foreign key to sections table for course_id
ALTER TABLE sections
ADD CONSTRAINT fk_sections_course_id
FOREIGN KEY (course_id) REFERENCES courses(id)
ON DELETE CASCADE; -- Deletes sections if the associated course is deleted

-- Add foreign key to lessons table for section_id
ALTER TABLE lessons
ADD CONSTRAINT fk_lessons_section_id
FOREIGN KEY (section_id) REFERENCES sections(id)
ON DELETE CASCADE; -- Deletes lessons if the associated section is deleted

-- Add foreign key to enrollments table for student_id
ALTER TABLE enrollments
ADD CONSTRAINT fk_enrollments_student_id
FOREIGN KEY (student_id) REFERENCES students(id)
ON DELETE CASCADE; -- Deletes enrollments if the associated student is deleted

-- Add foreign key to enrollments table for course_id
ALTER TABLE enrollments
ADD CONSTRAINT fk_enrollments_course_id
FOREIGN KEY (course_id) REFERENCES courses(id)
ON DELETE CASCADE; -- Deletes enrollments if the associated course is deleted

-- Add foreign key to reviews table for student_id
ALTER TABLE reviews
ADD CONSTRAINT fk_reviews_student_id
FOREIGN KEY (student_id) REFERENCES students(id)
ON DELETE CASCADE; -- Deletes reviews if the associated student is deleted

-- Add foreign key to reviews table for course_id
ALTER TABLE reviews
ADD CONSTRAINT fk_reviews_course_id
FOREIGN KEY (course_id) REFERENCES courses(id)
ON DELETE CASCADE; -- Deletes reviews if the associated course is deleted
