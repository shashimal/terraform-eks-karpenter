# Authentication Service

This service provides authentication and user management for the Student Management System.

## Features

- User authentication with JWT
- User registration and login
- Role-based access control (admin and staff roles)
- User profile management
- Admin user management

## Default Admin User

When the service starts for the first time, it creates a default admin user:

- Email: admin@example.com
- Password: admin123

**Important:** Change the default admin password after first login for security reasons.

## API Endpoints

### Authentication

- `POST /api/auth/register` - Register a new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/profile` - Get current user profile (requires authentication)
- `PUT /api/auth/profile` - Update user profile (requires authentication)

### User Management (Admin only)

- `GET /api/users` - Get all users
- `GET /api/users/:id` - Get a user by ID
- `POST /api/users` - Create a new user
- `PUT /api/users/:id` - Update a user
- `DELETE /api/users/:id` - Delete a user
- `PATCH /api/users/:id/toggle-status` - Enable/disable a user

## Environment Variables

- `PORT` - Port to run the service on (default: 3003)
- `MONGODB_URI` - MongoDB connection string
- `JWT_SECRET` - Secret key for JWT token generation

## Running the Service

```bash
# Install dependencies
npm install

# Start the service
npm start

# Start with nodemon for development
npm run dev

# Create admin user
npm run create-admin
```