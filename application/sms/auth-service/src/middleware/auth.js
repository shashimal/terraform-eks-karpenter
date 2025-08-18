const { verifyToken } = require('../config/jwt');

// Authentication middleware
const authenticate = (req, res, next) => {
    try {
        // Get token from header
        const authHeader = req.header('Authorization');
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({ message: 'Authentication required' });
        }

        const token = authHeader.replace('Bearer ', '');

        // Verify token
        const decoded = verifyToken(token);

        // Add user info to request
        req.user = decoded;

        next();
    } catch (error) {
        res.status(401).json({ message: 'Authentication failed' });
    }
};

// Admin authorization middleware
const authorizeAdmin = (req, res, next) => {
    if (req.user.role !== 'admin') {
        return res.status(403).json({ message: 'Access denied. Admin privileges required.' });
    }
    next();
};

module.exports = {
    authenticate,
    authorizeAdmin
};