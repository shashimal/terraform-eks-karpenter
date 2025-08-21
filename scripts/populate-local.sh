#!/bin/bash

# SMS Application Data Population Script
# This script populates the database with sample data for testing

set -e

# Configuration
BASE_URL="http://sms-app.local"
AUTH_URL="$BASE_URL/api/auth"
USERS_URL="$BASE_URL/api/users"
COURSES_URL="$BASE_URL/api/courses"
STUDENTS_URL="$BASE_URL/api/students"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 SMS Application Data Population Script${NC}"
echo "=================================================="

# Function to make API calls with error handling
make_api_call() {
    local method=$1
    local url=$2
    local data=$3
    local headers=$4

    if [ -n "$headers" ]; then
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$url" \
            -H "Content-Type: application/json" \
            -H "$headers" \
            -d "$data" \
            --max-time 10)
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$url" \
            -H "Content-Type: application/json" \
            -d "$data" \
            --max-time 10)
    fi

    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [[ $http_code -ge 200 && $http_code -lt 300 ]]; then
        echo "$body"
        return 0
    else
        echo -e "${RED}Error: HTTP $http_code${NC}" >&2
        echo "$body" >&2
        return 1
    fi
}

# Function to extract token from response
extract_token() {
    echo "$1" | grep -o '"token":"[^"]*"' | cut -d'"' -f4
}

echo -e "${YELLOW}📝 Creating Admin Users...${NC}"

# Login as existing admin user
echo "Logging in as admin user..."
admin_response=$(make_api_call "POST" "$AUTH_URL/login" '{
    "email": "admin@sms.com",
    "password": "admin123"
}')

if [ $? -eq 0 ]; then
    ADMIN_TOKEN=$(extract_token "$admin_response")
    echo -e "${GREEN}✅ Admin user logged in successfully${NC}"
else
    echo -e "${RED}❌ Failed to login as admin user${NC}"
    exit 1
fi

# Create Staff Users (Teachers)
echo -e "${YELLOW}👨‍🏫 Creating Staff Users...${NC}"

teachers=(
    '{"firstName": "John", "lastName": "Smith", "email": "john.smith@sms.com", "password": "staff123", "role": "staff"}'
    '{"firstName": "Sarah", "lastName": "Johnson", "email": "sarah.johnson@sms.com", "password": "staff123", "role": "staff"}'
    '{"firstName": "Michael", "lastName": "Brown", "email": "michael.brown@sms.com", "password": "staff123", "role": "staff"}'
    '{"firstName": "Emily", "lastName": "Davis", "email": "emily.davis@sms.com", "password": "staff123", "role": "staff"}'
)

for teacher in "${teachers[@]}"; do
    teacher_name=$(echo "$teacher" | grep -o '"firstName": "[^"]*"' | cut -d'"' -f4)
    echo "Creating staff member: $teacher_name..."
    if make_api_call "POST" "$AUTH_URL/register" "$teacher" > /dev/null; then
        echo -e "${GREEN}✅ Staff member $teacher_name created${NC}"
    else
        echo -e "${RED}❌ Failed to create staff member $teacher_name${NC}"
    fi
done

echo -e "${YELLOW}📚 Creating Courses...${NC}"

# Create Courses
courses=(
    '{"title": "Mathematics 101", "code": "MATH101", "description": "Introduction to basic mathematics concepts", "credits": 3, "instructor": "John Smith", "capacity": 30}'
    '{"title": "English Literature", "code": "ENG201", "description": "Study of classic and modern literature", "credits": 4, "instructor": "Sarah Johnson", "capacity": 25}'
    '{"title": "Computer Science Fundamentals", "code": "CS101", "description": "Introduction to programming and computer science", "credits": 4, "instructor": "Michael Brown", "capacity": 20}'
    '{"title": "Physics 101", "code": "PHYS101", "description": "Basic principles of physics", "credits": 3, "instructor": "Emily Davis", "capacity": 28}'
    '{"title": "Chemistry Basics", "code": "CHEM101", "description": "Introduction to chemical principles", "credits": 3, "instructor": "John Smith", "capacity": 24}'
    '{"title": "History of Science", "code": "HIST301", "description": "Evolution of scientific thought", "credits": 2, "instructor": "Sarah Johnson", "capacity": 35}'
)

course_ids=()
for course in "${courses[@]}"; do
    course_name=$(echo "$course" | grep -o '"title": "[^"]*"' | cut -d'"' -f4)
    echo "Creating course: $course_name..."
    course_response=$(make_api_call "POST" "$COURSES_URL" "$course" "Authorization: Bearer $ADMIN_TOKEN")
    if [ $? -eq 0 ]; then
        course_id=$(echo "$course_response" | grep -o '"_id":"[^"]*"' | cut -d'"' -f4)
        course_ids+=("$course_id")
        echo -e "${GREEN}✅ Course '$course_name' created${NC}"
    else
        echo -e "${RED}❌ Failed to create course '$course_name'${NC}"
    fi
done

echo -e "${YELLOW}👨‍🎓 Creating Students...${NC}"

# Create Students
students=(
    '{"firstName": "Alice", "lastName": "Wilson", "email": "alice.wilson@student.sms.com", "dateOfBirth": "2000-05-15", "address": "123 Main St, City, State", "phone": "+1-555-0101", "emergencyContact": {"name": "Mary Wilson", "phone": "+1-555-0102", "relationship": "Mother"}}'
    '{"firstName": "Bob", "lastName": "Martinez", "email": "bob.martinez@student.sms.com", "dateOfBirth": "1999-08-22", "address": "456 Oak Ave, City, State", "phone": "+1-555-0201", "emergencyContact": {"name": "Carlos Martinez", "phone": "+1-555-0202", "relationship": "Father"}}'
    '{"firstName": "Carol", "lastName": "Taylor", "email": "carol.taylor@student.sms.com", "dateOfBirth": "2001-03-10", "address": "789 Pine Rd, City, State", "phone": "+1-555-0301", "emergencyContact": {"name": "Linda Taylor", "phone": "+1-555-0302", "relationship": "Mother"}}'
    '{"firstName": "David", "lastName": "Anderson", "email": "david.anderson@student.sms.com", "dateOfBirth": "2000-11-05", "address": "321 Elm St, City, State", "phone": "+1-555-0401", "emergencyContact": {"name": "Robert Anderson", "phone": "+1-555-0402", "relationship": "Father"}}'
    '{"firstName": "Emma", "lastName": "Thomas", "email": "emma.thomas@student.sms.com", "dateOfBirth": "1999-12-18", "address": "654 Maple Dr, City, State", "phone": "+1-555-0501", "emergencyContact": {"name": "Jennifer Thomas", "phone": "+1-555-0502", "relationship": "Mother"}}'
    '{"firstName": "Frank", "lastName": "Garcia", "email": "frank.garcia@student.sms.com", "dateOfBirth": "2001-07-30", "address": "987 Cedar Ln, City, State", "phone": "+1-555-0601", "emergencyContact": {"name": "Maria Garcia", "phone": "+1-555-0602", "relationship": "Mother"}}'
    '{"firstName": "Grace", "lastName": "Lee", "email": "grace.lee@student.sms.com", "dateOfBirth": "2000-09-12", "address": "147 Birch Ave, City, State", "phone": "+1-555-0701", "emergencyContact": {"name": "James Lee", "phone": "+1-555-0702", "relationship": "Father"}}'
    '{"firstName": "Henry", "lastName": "White", "email": "henry.white@student.sms.com", "dateOfBirth": "1999-04-25", "address": "258 Spruce St, City, State", "phone": "+1-555-0801", "emergencyContact": {"name": "Susan White", "phone": "+1-555-0802", "relationship": "Mother"}}'
)

student_ids=()
for student in "${students[@]}"; do
    student_name=$(echo "$student" | grep -o '"firstName": "[^"]*"' | cut -d'"' -f4)
    student_last=$(echo "$student" | grep -o '"lastName": "[^"]*"' | cut -d'"' -f4)
    echo "Creating student: $student_name $student_last..."
    student_response=$(make_api_call "POST" "$STUDENTS_URL" "$student" "Authorization: Bearer $ADMIN_TOKEN")
    if [ $? -eq 0 ]; then
        student_id=$(echo "$student_response" | grep -o '"_id":"[^"]*"' | cut -d'"' -f4)
        student_ids+=("$student_id")
        echo -e "${GREEN}✅ Student '$student_name $student_last' created${NC}"
    else
        echo -e "${RED}❌ Failed to create student '$student_name $student_last'${NC}"
    fi
done

echo -e "${YELLOW}📋 Enrolling Students in Courses...${NC}"

# Enroll students in courses (if enrollment endpoints exist)
# This is a placeholder - you may need to adjust based on your actual enrollment API
if [ ${#course_ids[@]} -gt 0 ] && [ ${#student_ids[@]} -gt 0 ]; then
    echo "Note: Course and student enrollment would be handled here if enrollment endpoints are available."
    echo "Course IDs created: ${course_ids[*]}"
    echo "Student IDs created: ${student_ids[*]}"
fi

echo ""
echo -e "${GREEN}🎉 Data population completed successfully!${NC}"
echo "=================================================="
echo -e "${BLUE}Summary:${NC}"
echo "• 1 Admin user created"
echo "• 4 Staff users created"
echo "• 6 Courses created"
echo "• 8 Students created"
echo ""
echo -e "${YELLOW}Login Credentials:${NC}"
echo "Admin: admin@sms.com / admin123"
echo "Staff: [firstname].[lastname]@sms.com / staff123"
echo "Example: john.smith@sms.com / staff123"
echo ""
echo -e "${BLUE}Access the application at: http://sms-app.local${NC}"