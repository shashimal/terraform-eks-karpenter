#!/bin/bash

# SMS Application Data Population Script
# This script populates the MongoDB database with sample data for testing

set -e

# Configuration
MONGO_URI="mongodb://admin:admin123@sms-mongodb:27017/smsapp?authSource=admin"
DB_NAME="smsapp"
APP_URL="https://sms.duleendra.com"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 SMS Application Data Population Script${NC}"
echo "=================================================="

# Function to execute MongoDB commands
execute_mongo_command() {
    local command=$1
    echo "Executing: $command"
    
    # Use kubectl to execute mongo command in the cluster (using pod name for StatefulSet)
    kubectl exec -n default sms-mongodb-0 -- mongosh "$MONGO_URI" --eval "$command"
    
    if [ $? -eq 0 ]; then
        return 0
    else
        echo -e "${RED}❌ MongoDB command failed${NC}" >&2
        return 1
    fi
}

# Function to check if kubectl is available and connected to cluster
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}❌ kubectl is not installed or not in PATH${NC}"
        exit 1
    fi
    
    if ! kubectl cluster-info &> /dev/null; then
        echo -e "${RED}❌ kubectl is not connected to a cluster${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ kubectl is available and connected${NC}"
}

# Check prerequisites
check_kubectl

echo -e "${YELLOW}🗄️ Connecting to MongoDB...${NC}"

# Test MongoDB connection
if execute_mongo_command "db.adminCommand('ping')" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ MongoDB connection successful${NC}"
else
    echo -e "${RED}❌ Failed to connect to MongoDB${NC}"
    exit 1
fi

echo -e "${YELLOW}📝 Creating Admin Users...${NC}"

# Create admin user
admin_user='{
    "firstName": "Admin",
    "lastName": "User", 
    "email": "admin@sms.com",
    "password": "$2a$08$a5SDFTJOjWWRdr6i1oULEeqUiHShd81U2SJBPdEWFiySvKicMtPOu",
    "role": "admin",
    "active": true,
    "createdAt": new Date(),
    "updatedAt": new Date()
}'

execute_mongo_command "db.users.insertOne($admin_user)"
echo -e "${GREEN}✅ Admin user created (admin@sms.com / admin123)${NC}"

# Create Staff Users (Teachers)
echo -e "${YELLOW}👨‍🏫 Creating Staff Users...${NC}"

staff_users='[
    {
        "firstName": "John",
        "lastName": "Smith", 
        "email": "john.smith@sms.com",
        "password": "$2a$08$r.WN3DT2sOJ1SQK46huIK.bm56Js//Xxl3pE6DygVYtFl2f6jAjDu",
        "role": "staff",
        "active": true,
        "createdAt": new Date(),
        "updatedAt": new Date()
    },
    {
        "firstName": "Sarah",
        "lastName": "Johnson",
        "email": "sarah.johnson@sms.com", 
        "password": "$2a$08$r.WN3DT2sOJ1SQK46huIK.bm56Js//Xxl3pE6DygVYtFl2f6jAjDu",
        "role": "staff",
        "active": true,
        "createdAt": new Date(),
        "updatedAt": new Date()
    },
    {
        "firstName": "Michael",
        "lastName": "Brown",
        "email": "michael.brown@sms.com",
        "password": "$2a$08$r.WN3DT2sOJ1SQK46huIK.bm56Js//Xxl3pE6DygVYtFl2f6jAjDu", 
        "role": "staff",
        "active": true,
        "createdAt": new Date(),
        "updatedAt": new Date()
    },
    {
        "firstName": "Emily",
        "lastName": "Davis",
        "email": "emily.davis@sms.com",
        "password": "$2a$08$r.WN3DT2sOJ1SQK46huIK.bm56Js//Xxl3pE6DygVYtFl2f6jAjDu",
        "role": "staff", 
        "active": true,
        "createdAt": new Date(),
        "updatedAt": new Date()
    }
]'

execute_mongo_command "db.users.insertMany($staff_users)"
echo -e "${GREEN}✅ Staff users created${NC}"

echo -e "${YELLOW}📚 Creating Courses...${NC}"

courses='[
    {
        "title": "Mathematics 101",
        "code": "MATH101", 
        "description": "Introduction to basic mathematics concepts",
        "credits": 3,
        "instructor": "John Smith",
        "capacity": 30,
        "enrolledStudents": [],
        "isActive": true,
        "createdAt": new Date(),
        "updatedAt": new Date()
    },
    {
        "title": "English Literature",
        "code": "ENG201",
        "description": "Study of classic and modern literature", 
        "credits": 4,
        "instructor": "Sarah Johnson",
        "capacity": 25,
        "enrolledStudents": [],
        "isActive": true,
        "createdAt": new Date(),
        "updatedAt": new Date()
    },
    {
        "title": "Computer Science Fundamentals",
        "code": "CS101",
        "description": "Introduction to programming and computer science",
        "credits": 4,
        "instructor": "Michael Brown", 
        "capacity": 20,
        "enrolledStudents": [],
        "isActive": true,
        "createdAt": new Date(),
        "updatedAt": new Date()
    },
    {
        "title": "Physics 101",
        "code": "PHYS101",
        "description": "Basic principles of physics",
        "credits": 3,
        "instructor": "Emily Davis",
        "capacity": 28,
        "enrolledStudents": [],
        "isActive": true,
        "createdAt": new Date(),
        "updatedAt": new Date()
    },
    {
        "title": "Chemistry Basics", 
        "code": "CHEM101",
        "description": "Introduction to chemical principles",
        "credits": 3,
        "instructor": "John Smith",
        "capacity": 24,
        "enrolledStudents": [],
        "isActive": true,
        "createdAt": new Date(),
        "updatedAt": new Date()
    },
    {
        "title": "History of Science",
        "code": "HIST301", 
        "description": "Evolution of scientific thought",
        "credits": 2,
        "instructor": "Sarah Johnson",
        "capacity": 35,
        "enrolledStudents": [],
        "isActive": true,
        "createdAt": new Date(),
        "updatedAt": new Date()
    }
]'

execute_mongo_command "db.courses.insertMany($courses)"
echo -e "${GREEN}✅ Courses created${NC}"

echo -e "${YELLOW}👨‍🎓 Creating Students...${NC}"

students='[
    {
        "firstName": "Alice",
        "lastName": "Wilson",
        "email": "alice.wilson@student.sms.com",
        "dateOfBirth": new Date("2000-05-15"),
        "address": "123 Main St, City, State", 
        "phone": "+1-555-0101",
        "emergencyContact": {
            "name": "Mary Wilson",
            "phone": "+1-555-0102", 
            "relationship": "Mother"
        },
        "enrolledCourses": [],
        "isActive": true,
        "createdAt": new Date(),
        "updatedAt": new Date()
    },
    {
        "firstName": "Bob",
        "lastName": "Martinez", 
        "email": "bob.martinez@student.sms.com",
        "dateOfBirth": new Date("1999-08-22"),
        "address": "456 Oak Ave, City, State",
        "phone": "+1-555-0201",
        "emergencyContact": {
            "name": "Carlos Martinez",
            "phone": "+1-555-0202",
            "relationship": "Father"
        },
        "enrolledCourses": [],
        "isActive": true,
        "createdAt": new Date(),
        "updatedAt": new Date()
    },
    {
        "firstName": "Carol",
        "lastName": "Taylor",
        "email": "carol.taylor@student.sms.com",
        "dateOfBirth": new Date("2001-03-10"),
        "address": "789 Pine Rd, City, State",
        "phone": "+1-555-0301", 
        "emergencyContact": {
            "name": "Linda Taylor",
            "phone": "+1-555-0302",
            "relationship": "Mother"
        },
        "enrolledCourses": [],
        "isActive": true,
        "createdAt": new Date(),
        "updatedAt": new Date()
    },
    {
        "firstName": "David",
        "lastName": "Anderson",
        "email": "david.anderson@student.sms.com",
        "dateOfBirth": new Date("2000-11-05"),
        "address": "321 Elm St, City, State",
        "phone": "+1-555-0401",
        "emergencyContact": {
            "name": "Robert Anderson", 
            "phone": "+1-555-0402",
            "relationship": "Father"
        },
        "enrolledCourses": [],
        "isActive": true,
        "createdAt": new Date(),
        "updatedAt": new Date()
    },
    {
        "firstName": "Emma",
        "lastName": "Thomas",
        "email": "emma.thomas@student.sms.com", 
        "dateOfBirth": new Date("1999-12-18"),
        "address": "654 Maple Dr, City, State",
        "phone": "+1-555-0501",
        "emergencyContact": {
            "name": "Jennifer Thomas",
            "phone": "+1-555-0502",
            "relationship": "Mother"
        },
        "enrolledCourses": [],
        "isActive": true,
        "createdAt": new Date(),
        "updatedAt": new Date()
    },
    {
        "firstName": "Frank",
        "lastName": "Garcia",
        "email": "frank.garcia@student.sms.com",
        "dateOfBirth": new Date("2001-07-30"),
        "address": "987 Cedar Ln, City, State",
        "phone": "+1-555-0601",
        "emergencyContact": {
            "name": "Maria Garcia",
            "phone": "+1-555-0602",
            "relationship": "Mother"
        },
        "enrolledCourses": [],
        "isActive": true,
        "createdAt": new Date(),
        "updatedAt": new Date()
    },
    {
        "firstName": "Grace", 
        "lastName": "Lee",
        "email": "grace.lee@student.sms.com",
        "dateOfBirth": new Date("2000-09-12"),
        "address": "147 Birch Ave, City, State",
        "phone": "+1-555-0701",
        "emergencyContact": {
            "name": "James Lee",
            "phone": "+1-555-0702",
            "relationship": "Father"
        },
        "enrolledCourses": [],
        "isActive": true,
        "createdAt": new Date(),
        "updatedAt": new Date()
    },
    {
        "firstName": "Henry",
        "lastName": "White",
        "email": "henry.white@student.sms.com",
        "dateOfBirth": new Date("1999-04-25"),
        "address": "258 Spruce St, City, State", 
        "phone": "+1-555-0801",
        "emergencyContact": {
            "name": "Susan White",
            "phone": "+1-555-0802",
            "relationship": "Mother"
        },
        "enrolledCourses": [],
        "isActive": true,
        "createdAt": new Date(),
        "updatedAt": new Date()
    }
]'

execute_mongo_command "db.students.insertMany($students)"
echo -e "${GREEN}✅ Students created${NC}"

echo -e "${YELLOW}📋 Creating Sample Enrollments...${NC}"

# Create some sample enrollments
enrollment_commands='
// Get some course and student IDs for enrollment
var courses = db.courses.find().limit(3).toArray();
var students = db.students.find().limit(5).toArray();

// Enroll students in courses
if (courses.length > 0 && students.length > 0) {
    // Enroll first 3 students in Math course
    if (courses[0]) {
        db.courses.updateOne(
            {_id: courses[0]._id}, 
            {$push: {enrolledStudents: {$each: [students[0]._id, students[1]._id, students[2]._id]}}}
        );
        db.students.updateMany(
            {_id: {$in: [students[0]._id, students[1]._id, students[2]._id]}},
            {$push: {enrolledCourses: courses[0]._id}}
        );
    }
    
    // Enroll different students in English course  
    if (courses[1]) {
        db.courses.updateOne(
            {_id: courses[1]._id},
            {$push: {enrolledStudents: {$each: [students[1]._id, students[2]._id, students[3]._id]}}}
        );
        db.students.updateMany(
            {_id: {$in: [students[1]._id, students[2]._id, students[3]._id]}},
            {$push: {enrolledCourses: courses[1]._id}}
        );
    }
    
    // Enroll students in CS course
    if (courses[2]) {
        db.courses.updateOne(
            {_id: courses[2]._id},
            {$push: {enrolledStudents: {$each: [students[0]._id, students[3]._id, students[4]._id]}}}
        );
        db.students.updateMany(
            {_id: {$in: [students[0]._id, students[3]._id, students[4]._id]}},
            {$push: {enrolledCourses: courses[2]._id}}
        );
    }
}
'

execute_mongo_command "$enrollment_commands"
echo -e "${GREEN}✅ Sample enrollments created${NC}"

echo ""
echo -e "${GREEN}🎉 Data population completed successfully!${NC}"
echo "=================================================="
echo -e "${BLUE}Summary:${NC}"
echo "• 1 Admin user created"
echo "• 4 Staff users created" 
echo "• 6 Courses created"
echo "• 8 Students created"
echo "• Sample enrollments created"
echo ""
echo -e "${YELLOW}Login Credentials:${NC}"
echo "Admin: admin@sms.com / admin123"
echo "Staff: [firstname].[lastname]@sms.com / staff123"
echo "Example: john.smith@sms.com / staff123"
echo ""
echo -e "${BLUE}Access the application at: $APP_URL${NC}"
echo ""
echo -e "${YELLOW}Note:${NC} All passwords are hashed with bcrypt."
echo "If you need to update passwords, use your application's password reset functionality."