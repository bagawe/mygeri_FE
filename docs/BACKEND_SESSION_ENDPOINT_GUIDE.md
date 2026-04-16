# Backend Implementation Guide - Session, Voting, Agenda, Announcement

**For:** Backend Team  
**Date:** April 16, 2026  
**Priority:** 🔴 HIGH  

---

## 📋 PART 1: Session Duration Configuration (1 Month)

### Current Frontend Status: ✅ ALREADY SET
Frontend sudah configured untuk session 1 bulan (30 hari). **Tidak perlu perubahan frontend.**

### Backend Requirements:

#### 1. **Access Token Expiry**
```javascript
// Set token expiry to 1 month (frontend side)
const expiryDate = new Date();
expiryDate.setDate(expiryDate.getDate() + 30);

// OR use JWT with exp claim
const token = jwt.sign(
  { userId, role },
  process.env.JWT_SECRET,
  { expiresIn: '30d' }  // ← 30 days
);
```

#### 2. **Refresh Token Expiry**
```javascript
// Refresh token should live longer (e.g., 90 days)
const refreshToken = jwt.sign(
  { userId },
  process.env.JWT_REFRESH_SECRET,
  { expiresIn: '90d' }  // ← 90 days (longer than access token)
);
```

#### 3. **Session Management in Database (Optional)**
```sql
-- If you have sessions table
CREATE TABLE sessions (
  id INT PRIMARY KEY,
  user_id INT,
  token VARCHAR(500),
  expires_at DATETIME,  -- 30 days from login
  created_at DATETIME,
  updated_at DATETIME
);

-- Set expires_at to 30 days from now
UPDATE sessions 
SET expires_at = DATE_ADD(NOW(), INTERVAL 30 DAY)
WHERE user_id = ?;
```

#### 4. **Configuration**
```javascript
// In .env or config file
JWT_EXPIRY=30d           // Access token: 30 days
JWT_REFRESH_EXPIRY=90d   // Refresh token: 90 days
SESSION_EXPIRY=30        // Session: 30 days (in days)
```

---

## 🎯 PART 2: Voting Endpoint - Create Missing Endpoint

### Problem:
- Endpoint: `GET /api/voting/active`
- Status: **404 NOT FOUND**
- Frontend expects active voting polls list

### Solution: Create Endpoint

#### Backend Implementation (Node.js/Express Example):

```javascript
// routes/voting.js
router.get('/api/voting/active', authenticateToken, async (req, res) => {
  try {
    const votings = await VotingModel.findAll({
      where: {
        status: 'active',  // Only active votings
        isActive: true     // Not deleted
      },
      include: [
        {
          model: VotingOption,
          attributes: ['id', 'title', 'votes']
        }
      ],
      order: [['startDate', 'DESC']]
    });

    return res.json({
      success: true,
      data: votings,
      message: 'Active votings retrieved successfully'
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Error retrieving active votings',
      error: error.message
    });
  }
});

// middleware/authenticateToken.js
const authenticateToken = (req, res, next) => {
  const token = req.headers['authorization']?.split(' ')[1];
  if (!token) return res.status(401).json({ message: 'Unauthorized' });
  
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ message: 'Forbidden' });
    req.user = user;
    next();
  });
};
```

#### Expected Response Format:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Pemilihan Ketua",
      "description": "Pemilihan ketua DPC",
      "status": "active",
      "startDate": "2026-04-10T00:00:00Z",
      "endDate": "2026-04-17T23:59:59Z",
      "createdBy": 5,
      "options": [
        {
          "id": 1,
          "title": "Calon A",
          "votes": 42
        },
        {
          "id": 2,
          "title": "Calon B",
          "votes": 38
        }
      ]
    }
  ],
  "message": "Active votings retrieved successfully"
}
```

#### Testing:
```bash
# Test endpoint
curl -H "Authorization: Bearer YOUR_KADER_TOKEN" \
  http://your-backend:3030/api/voting/active

# Should return 200 with active votings list
```

---

## 🛡️ PART 3: Fix Agenda Endpoint Permissions

### Problem:
- Endpoint: `GET /api/agenda`
- Status: **403 FORBIDDEN**
- Error: "insufficient privileges"
- Current: Only admin can access
- Should: admin AND kader can access

### Solution: Update Permission Middleware

#### Current Code (WRONG):
```javascript
// middleware/checkRole.js
const checkAgendaPermission = (req, res, next) => {
  if (req.user.role !== 'admin') {  // ← WRONG! Blocks kader
    return res.status(403).json({
      success: false,
      message: 'Insufficient privileges'
    });
  }
  next();
};

// routes/agenda.js
router.get('/api/agenda', checkAgendaPermission, getAgendas);
```

#### Fixed Code (CORRECT):
```javascript
// middleware/checkRole.js
const checkAgendaPermission = (req, res, next) => {
  // ✅ Allow both admin and kader
  if (!['admin', 'kader'].includes(req.user.role)) {
    return res.status(403).json({
      success: false,
      message: 'Insufficient privileges. Only admin and kader can access.'
    });
  }
  next();
};

// routes/agenda.js
router.get('/api/agenda', checkAgendaPermission, getAgendas);
router.get('/api/agenda/:id', checkAgendaPermission, getAgendaDetail);
```

#### Implementation Steps:
1. Find permission/middleware files
2. Look for agenda endpoint protection
3. Change role check from `!== 'admin'` to `!['admin', 'kader'].includes(role)`
4. Test with kader token

#### Testing:
```bash
# Before fix:
curl -H "Authorization: Bearer KADER_TOKEN" \
  http://your-backend:3030/api/agenda
# Response: 403 Forbidden ❌

# After fix:
curl -H "Authorization: Bearer KADER_TOKEN" \
  http://your-backend:3030/api/agenda
# Response: 200 with agenda list ✅
```

---

## 🔔 PART 4: Fix Announcement Endpoint Permissions

### Problem:
- Endpoint: `GET /api/announcement`
- Status: **403 FORBIDDEN**
- Error: "insufficient privileges"
- Current: Only admin can access
- Should: admin AND kader can access

### Solution: Same as Agenda (Update Permission Middleware)

#### Current Code (WRONG):
```javascript
// middleware/checkRole.js
const checkAnnouncementPermission = (req, res, next) => {
  if (req.user.role !== 'admin') {  // ← WRONG! Blocks kader
    return res.status(403).json({
      success: false,
      message: 'Insufficient privileges'
    });
  }
  next();
};

// routes/announcement.js
router.get('/api/announcement', checkAnnouncementPermission, getAnnouncements);
```

#### Fixed Code (CORRECT):
```javascript
// middleware/checkRole.js
const checkAnnouncementPermission = (req, res, next) => {
  // ✅ Allow both admin and kader
  if (!['admin', 'kader'].includes(req.user.role)) {
    return res.status(403).json({
      success: false,
      message: 'Insufficient privileges. Only admin and kader can access.'
    });
  }
  next();
};

// routes/announcement.js
router.get('/api/announcement', checkAnnouncementPermission, getAnnouncements);
router.get('/api/announcement/:id', checkAnnouncementPermission, getAnnouncementDetail);
```

#### Implementation Steps:
1. Find permission/middleware files for announcement
2. Change role check to allow kader
3. Test with kader token

#### Testing:
```bash
# Before fix:
curl -H "Authorization: Bearer KADER_TOKEN" \
  http://your-backend:3030/api/announcement
# Response: 403 Forbidden ❌

# After fix:
curl -H "Authorization: Bearer KADER_TOKEN" \
  http://your-backend:3030/api/announcement
# Response: 200 with announcement list ✅
```

---

## 📋 Complete Checklist for Backend

### Session (1 Month):
- [ ] JWT access token set to 30 days expiry
- [ ] JWT refresh token set to 90 days expiry
- [ ] Session config in .env uses 30 days
- [ ] Test: Login and check token expiry
- [ ] Test: Refresh token works before expiry

### Voting Active Endpoint:
- [ ] Create route: `GET /api/voting/active`
- [ ] Query only active votings (status='active')
- [ ] Include voting options in response
- [ ] Add authentication middleware
- [ ] Test with Postman (should return 200 and list)
- [ ] Test with kader token
- [ ] Test response format matches expected JSON

### Agenda Permissions:
- [ ] Find permission middleware for `/api/agenda`
- [ ] Update to allow: admin, kader
- [ ] Remove block for kader role
- [ ] Test: `GET /api/agenda` with kader token (200)
- [ ] Test: `GET /api/agenda/:id` with kader token (200)
- [ ] Test: Verify agenda items returned correctly

### Announcement Permissions:
- [ ] Find permission middleware for `/api/announcement`
- [ ] Update to allow: admin, kader
- [ ] Remove block for kader role
- [ ] Test: `GET /api/announcement` with kader token (200)
- [ ] Test: `GET /api/announcement/:id` with kader token (200)
- [ ] Test: Verify announcement items returned correctly

---

## 🧪 Testing Requests

### Test Session (After Backend Deploy):
```bash
# Get kader token
curl -X POST http://your-backend:3030/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"identifier":"user@example.com","password":"password"}'

# Response will have accessToken (check JWT exp claim)
```

### Test Voting Active:
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://your-backend:3030/api/voting/active
```

### Test Agenda:
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://your-backend:3030/api/agenda
```

### Test Announcement:
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://your-backend:3030/api/announcement
```

---

## 📊 Implementation Summary

| Item | Current | Required | Action |
|------|---------|----------|--------|
| **Session Duration** | Unknown | 30 days | Configure JWT/env |
| **Voting/Active** | ❌ Missing | ✅ Create | New endpoint |
| **Agenda Role** | ❌ admin only | ✅ admin+kader | Update permission |
| **Announcement Role** | ❌ admin only | ✅ admin+kader | Update permission |

---

## ⚡ Quick Fix Summary

```javascript
// 1. Session - Update .env
JWT_EXPIRY=30d

// 2. Voting - Add endpoint
router.get('/api/voting/active', authenticateToken, getActiveVotings);

// 3. Agenda - Update permission check
if (!['admin', 'kader'].includes(req.user.role)) return 403;

// 4. Announcement - Update permission check  
if (!['admin', 'kader'].includes(req.user.role)) return 403;
```

---

**Status:** Ready for Backend Implementation  
**Frontend:** Waiting for Backend Fixes  
**Timeline:** ASAP 🔴  
