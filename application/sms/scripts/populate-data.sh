#!/bin/bash

# Dummy Data Population Script for SMS Application
# This script populates the SMS application with sample students and courses using curl

set -e

# Configuration
STUDENT_SERVICE_URL="http://localhost:3001/api/students"
COURSE_SERVICE_URL="http://localhost:3002/api/courses"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_data() {
    echo -e "${CYAN}[DATA]${NC} $1"
}

# Function to check if services are running
check_services() {
    print_status "Checking if SMS services are running..."
    
    if ! curl -s "$STUDENT_SERVICE_URL" > /dev/null; then
        print_error "Student service is not accessible at $STUDENT_SERVICE_URL"
        print_error "Please start your services with: docker-compose up"
        exit 1
    fi
    
    if ! curl -s "$COURSE_SERVICE_URL" > /dev/null; then
        print_error "Course service is not accessible at $COURSE_SERVICE_URL"
        print_error "Please start your services with: docker-compose up"
        exit 1
    fi
    
    print_success "All services are running"
}

# Function to create a student
create_student() {
    local first_name="$1"
    local last_name="$2"
    local email="$3"
    local date_of_birth="$4"
    
    local json_data=$(cat <<EOF
{
    "firstName": "$first_name",
    "lastName": "$last_name",
    "email": "$email",
    "dateOfBirth": "$date_of_birth"
}
EOF
)
    
    local response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
        -H "Content-Type: application/json" \
        -d "$json_data" \
        "$STUDENT_SERVICE_URL")
    
    local http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    local body=$(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')
    
    if [ "$http_code" -eq 201 ] || [ "$http_code" -eq 200 ]; then
        print_success "Created student: $first_name $last_name"
        echo "$body" | grep -o '"_id":"[^"]*"' | cut -d'"' -f4
    elif [ "$http_code" -eq 400 ] && echo "$body" | grep -q "duplicate\|exists"; then
        print_warning "Student $first_name $last_name already exists"
        return 1
    else
        print_error "Failed to create student $first_name $last_name (HTTP: $http_code)"
        return 1
    fi
}

# Function to create a course
create_course() {
    local title="$1"
    local code="$2"
    local description="$3"
    local credits="$4"
    local instructor="$5"
    local start_date="$6"
    local end_date="$7"
    local capacity="$8"
    
    local json_data=$(cat <<EOF
{
    "title": "$title",
    "code": "$code",
    "description": "$description",
    "credits": $credits,
    "instructor": "$instructor",
    "startDate": "$start_date",
    "endDate": "$end_date",
    "capacity": $capacity
}
EOF
)
    
    local response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
        -H "Content-Type: application/json" \
        -d "$json_data" \
        "$COURSE_SERVICE_URL")
    
    local http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    local body=$(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')
    
    if [ "$http_code" -eq 201 ] || [ "$http_code" -eq 200 ]; then
        print_success "Created course: $title ($code)"
        echo "$body" | grep -o '"_id":"[^"]*"' | cut -d'"' -f4
    elif [ "$http_code" -eq 400 ] && echo "$body" | grep -q "duplicate\|exists"; then
        print_warning "Course $title ($code) already exists"
        return 1
    else
        print_error "Failed to create course $title (HTTP: $http_code)"
        return 1
    fi
}

# Function to enroll student in course
enroll_student_in_course() {
    local student_id="$1"
    local course_id="$2"
    local student_name="$3"
    local course_title="$4"
    
    # Add course to student
    local student_response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
        -H "Content-Type: application/json" \
        -d "{\"courseId\": \"$course_id\"}" \
        "$STUDENT_SERVICE_URL/$student_id/courses")
    
    local student_http_code=$(echo "$student_response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    
    # Enroll student in course
    local course_response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
        -H "Content-Type: application/json" \
        -d "{\"studentId\": \"$student_id\"}" \
        "$COURSE_SERVICE_URL/$course_id/enroll")
    
    local course_http_code=$(echo "$course_response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    
    if [ "$student_http_code" -eq 200 ] && [ "$course_http_code" -eq 200 ]; then
        print_success "Enrolled $student_name in $course_title"
    else
        print_warning "Failed to enroll $student_name in $course_title"
    fi
}

# Function to create all students
create_students() {
    print_status "Creating dummy students..."
    
    declare -a student_ids=()
    declare -a student_names=()
    
    # Student data array (firstName lastName email dateOfBirth)
    students=(
        "John Doe john.doe@university.edu 1998-05-15"
        "Jane Smith jane.smith@university.edu 1999-03-22"
        "Michael Johnson michael.johnson@university.edu 1997-11-08"
        "Emily Davis emily.davis@university.edu 1998-09-12"
        "David Wilson david.wilson@university.edu 1999-01-30"
        "Sarah Brown sarah.brown@university.edu 1998-07-18"
        "Robert Taylor robert.taylor@university.edu 1997-12-05"
        "Lisa Anderson lisa.anderson@university.edu 1999-04-25"
        "James Martinez james.martinez@university.edu 1998-08-14"
        "Amanda Garcia amanda.garcia@university.edu 1999-06-03"
    )
    
    for student_data in "${students[@]}"; do
        read -r first_name last_name email date_of_birth <<< "$student_data"
        
        student_id=$(create_student "$first_name" "$last_name" "$email" "$date_of_birth")
        if [ $? -eq 0 ] && [ -n "$student_id" ]; then
            student_ids+=("$student_id")
            student_names+=("$first_name $last_name")
        fi
    done
    
    # Export arrays for use in enrollment
    printf '%s\n' "${student_ids[@]}" > /tmp/student_ids.txt
    printf '%s\n' "${student_names[@]}" > /tmp/student_names.txt
}

# Function to create all courses
create_courses() {
    print_status "Creating dummy courses..."
    
    declare -a course_ids=()
    declare -a course_titles=()
    
    # Course data (title code description credits instructor startDate endDate capacity)
    courses=(
        "Introduction to Computer Science|CS101|Fundamental concepts of computer science including programming basics, algorithms, and data structures.|3|Dr. Alan Turing|2024-09-01|2024-12-15|30"
        "Data Structures and Algorithms|CS201|Advanced study of data structures, algorithm design, and complexity analysis.|4|Prof. Ada Lovelace|2024-09-01|2024-12-15|25"
        "Database Management Systems|CS301|Design and implementation of database systems, SQL, and database administration.|3|Dr. Edgar Codd|2024-09-01|2024-12-15|28"
        "Web Development|CS250|Full-stack web development using modern frameworks and technologies.|3|Prof. Tim Berners-Lee|2024-09-01|2024-12-15|35"
        "Software Engineering|CS350|Software development lifecycle, project management, and engineering practices.|4|Dr. Frederick Brooks|2024-09-01|2024-12-15|20"
        "Machine Learning|CS450|Introduction to machine learning algorithms, neural networks, and AI applications.|4|Prof. Geoffrey Hinton|2024-09-01|2024-12-15|22"
        "Computer Networks|CS320|Network protocols, architecture, and distributed systems fundamentals.|3|Dr. Vint Cerf|2024-09-01|2024-12-15|26"
        "Operating Systems|CS310|Operating system concepts, process management, memory management, and file systems.|4|Prof. Andrew Tanenbaum|2024-09-01|2024-12-15|24"
    )
    
    for course_data in "${courses[@]}"; do
        IFS='|' read -r title code description credits instructor start_date end_date capacity <<< "$course_data"
        
        course_id=$(create_course "$title" "$code" "$description" "$credits" "$instructor" "$start_date" "$end_date" "$capacity")
        if [ $? -eq 0 ] && [ -n "$course_id" ]; then
            course_ids+=("$course_id")
            course_titles+=("$title")
        fi
    done
    
    # Export arrays for use in enrollment
    printf '%s\n' "${course_ids[@]}" > /tmp/course_ids.txt
    printf '%s\n' "${course_titles[@]}" > /tmp/course_titles.txt
}

# Function to enroll students in courses
enroll_students() {
    print_status "Enrolling students in courses..."
    
    if [ ! -f /tmp/student_ids.txt ] || [ ! -f /tmp/course_ids.txt ]; then
        print_warning "Student or course data not found. Skipping enrollment."
        return
    fi
    
    # Read arrays from temp files (compatible with older bash versions)
    declare -a student_ids=()
    declare -a student_names=()
    declare -a course_ids=()
    declare -a course_titles=()
    
    while IFS= read -r line; do
        student_ids+=("$line")
    done < /tmp/student_ids.txt
    
    while IFS= read -r line; do
        student_names+=("$line")
    done < /tmp/student_names.txt
    
    while IFS= read -r line; do
        course_ids+=("$line")
    done < /tmp/course_ids.txt
    
    while IFS= read -r line; do
        course_titles+=("$line")
    done < /tmp/course_titles.txt
    
    # Enroll each student in 2-4 random courses
    for i in "${!student_ids[@]}"; do
        student_id="${student_ids[$i]}"
        student_name="${student_names[$i]}"
        
        # Generate random number of courses (2-4)
        num_courses=$((RANDOM % 3 + 2))
        
        # Create array of course indices and shuffle
        course_indices=($(seq 0 $((${#course_ids[@]} - 1))))
        for ((j=${#course_indices[@]}-1; j>0; j--)); do
            k=$((RANDOM % (j+1)))
            temp=${course_indices[j]}
            course_indices[j]=${course_indices[k]}
            course_indices[k]=$temp
        done
        
        # Enroll in first num_courses courses
        for ((j=0; j<num_courses && j<${#course_indices[@]}; j++)); do
            course_idx=${course_indices[j]}
            course_id="${course_ids[$course_idx]}"
            course_title="${course_titles[$course_idx]}"
            
            enroll_student_in_course "$student_id" "$course_id" "$student_name" "$course_title"
        done
    done
    
    # Clean up temp files
    rm -f /tmp/student_ids.txt /tmp/student_names.txt /tmp/course_ids.txt /tmp/course_titles.txt
}

# Function to display summary
display_summary() {
    print_status "=== DATA POPULATION SUMMARY ==="
    
    # Get students count
    student_count=$(curl -s "$STUDENT_SERVICE_URL" | grep -o '"_id"' | wc -l)
    print_data "Total Students: $student_count"
    
    # Get courses count
    course_count=$(curl -s "$COURSE_SERVICE_URL" | grep -o '"_id"' | wc -l)
    print_data "Total Courses: $course_count"
    
    echo ""
    print_data "Students created:"
    curl -s "$STUDENT_SERVICE_URL" | grep -o '"firstName":"[^"]*","lastName":"[^"]*","email":"[^"]*"' | \
        sed 's/"firstName":"//g; s/","lastName":"/ /g; s/","email":"/ (/g; s/"$/)/g' | \
        while read -r line; do
            echo "  • $line"
        done
    
    echo ""
    print_data "Courses created:"
    curl -s "$COURSE_SERVICE_URL" | grep -o '"title":"[^"]*","code":"[^"]*"' | \
        sed 's/"title":"//g; s/","code":"/ (/g; s/"$/)/g' | \
        while read -r line; do
            echo "  • $line"
        done
}

# Show help
show_help() {
    echo "SMS Application Dummy Data Population Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help       Show this help message"
    echo "  --students       Create only students"
    echo "  --courses        Create only courses"
    echo "  --no-enroll      Skip enrollment process"
    echo "  --summary        Show current data summary"
    echo ""
    echo "Prerequisites:"
    echo "  • SMS services must be running (docker-compose up)"
    echo "  • curl must be installed"
    echo ""
    echo "Examples:"
    echo "  $0                    # Create students, courses, and enrollments"
    echo "  $0 --students         # Create only students"
    echo "  $0 --courses          # Create only courses"
    echo "  $0 --no-enroll        # Create data but skip enrollments"
    echo "  $0 --summary          # Show current data summary"
}

# Main function
main() {
    local create_students_flag=true
    local create_courses_flag=true
    local enroll_flag=true
    local summary_only=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            --students)
                create_courses_flag=false
                enroll_flag=false
                shift
                ;;
            --courses)
                create_students_flag=false
                enroll_flag=false
                shift
                ;;
            --no-enroll)
                enroll_flag=false
                shift
                ;;
            --summary)
                summary_only=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    print_status "Starting SMS Application dummy data population..."
    
    # Check if services are running
    check_services
    
    if [ "$summary_only" = true ]; then
        display_summary
        exit 0
    fi
    
    # Create data based on flags
    if [ "$create_students_flag" = true ]; then
        create_students
    fi
    
    if [ "$create_courses_flag" = true ]; then
        create_courses
    fi
    
    if [ "$enroll_flag" = true ]; then
        enroll_students
    fi
    
    # Display summary
    display_summary
    
    print_success "Dummy data population completed successfully!"
}

# Run main function
main "$@"