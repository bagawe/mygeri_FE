# Session Duration & Endpoint Issues - Complete Analysis

**Date:** April 16, 2026  
**Status:** ✅ ANALYZED  

---

## 📋 PART 1: Session Duration (FRONTEND - ✅ ALREADY SET)

### Current Status:
✅ **Session Duration: 1 MONTH (30 days)**

**Where it's configured:**
- `lib/services/storage_service.dart` - `setSessionExpiry()` method
- `lib/services/auth_service.dart` - Calls `setSessionExpiry()` after login

**Code:**
```dart
// In auth_service.dart (line 167)
await _storage.setSessionExpiry();
print('✅ Session expiry set (30 days)');

// In storage_service.dart (line 276)
Future<void> setSessionExpiry() async {
  final expiryDate = DateTime.now().add(const Duration(days: 30));
  // Save to storage
}
```

### How it works:
1. User login → Session set to 30 days from now
2. On splash screen → Session extended to 30 days (on each app open)
3. On logout → Session cleared

### Session Validation:
- `isSessionValid()` - Checks if expiry > now
- `extendSessionExpiry()` - Extends to 30 days again

**No changes needed on frontend - already working! ✅**

---

## 📋 PART 2: Backend Requirements (FOR BACKEND TEAM)

### Issue 1: Voting Endpoint - 404 NOT FOUND

**Problem:**
- Endpoint: `GET /api/voting/active`
- Status: **🔴 NOT FOUND (404)**
- Error: "endpoint not found"

**What Frontend Expects:**
```
GET /api/voting/active
```

**Response Format Expected:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Pemilihan Ketua",
      "description": "...",
      "status": "active",
      "startDate": "2026-04-10",
      "endDate": "2026-04-17",
      "options": [...]
    }
  ]
}
```

**Backend Action Required:**
```
❌ Current: Endpoint not implemented
✅ Required: Create GET /api/voting/active endpoint

Details:
- Method: GET
- Route: /api/voting/active
- Auth: Required (Bearer token)
- Role: kader, admin
- Purpose: Get list of active/ongoing voting polls
- Return: Array of voting polls in status 'active'
```

---

### Issue 2: Agenda Endpoint - 403 FORBIDDEN (Permission)

**Problem:**
- Endpoint: `GET /api/agenda`
- Status: **🟠 FORBIDDEN (403)**
- Error: "insufficient privileges"
- Role: kader (should have access but doesn't)

**What Frontend Expects:**
- Role `kader` should access agenda endpoint
- Currently getting 403 = permission denied

**Backend Action Required:**
```
❌ Current: Role "kader" not permitted to /api/agenda
✅ Required: Add "kader" role to permission check

Details:
- Route: /api/agenda
- Methods: GET (list), GET /:id (detail)
- Add permission for: kader, admin
- Remove restriction that blocks kader

Check in backend code:
- Permission middleware
- Route guards
- Role-based access control (RBAC)
- Add "kader" to allowed roles for agenda
```

**Possible Backend Code Issue:**
```javascript
// WRONG (current):
if (user.role !== 'admin') {
  return res.status(403).json({ message: 'Forbidden' });
}

// CORRECT (should be):
if (!['admin', 'kader'].includes(user.role)) {
  return res.status(403).json({ message: 'Forbidden' });
}
```

---

### Issue 3: My Gerindra (Announcement) - 403 FORBIDDEN (Permission)

**Problem:**
- Endpoint: `GET /api/announcement`
- Status: **🟠 FORBIDDEN (403)**
- Error: "insufficient privileges"
- Role: kader (should have access but doesn't)

**What Frontend Expects:**
- Role `kader` should access announcement endpoint
- Currently getting 403 = permission denied

**Backend Action Required:**
```
❌ Current: Role "kader" not permitted to /api/announcement
✅ Required: Add "kader" role to permission check

Details:
- Route: /api/announcement
- Methods: GET (list), GET /:id (detail)
- Add permission for: kader, admin
- Remove restriction that blocks kader

Same fix as Agenda endpoint above
```

---

## 📋 SUMMARY TABLE

| Feature | Endpoint | Status | Error | Frontend Role | Backend Action |
|---------|----------|--------|-------|---------------|-----------------|
| **Voting** | `GET /api/voting/active` | ❌ 404 | Not Found | kader | Create endpoint |
| **Agenda** | `GET /api/agenda` | 🟠 403 | Forbidden | kader | Fix permissions |
| **My Gerindra** | `GET /api/announcement` | 🟠 403 | Forbidden | kader | Fix permissions |

---

## 🔍 Frontend Logging (For Debugging)

When you see these errors in Flutter console:

```
❌ Error: Endpoint not found (404)
   → Voting endpoint missing in backend

❌ Error: Insufficient privileges (403)  
   → Role "kader" not permitted in permission check
```

---

## 📝 Backend Implementation Checklist

### FOR BACKEND TEAM:

#### [ ] Voting Active Endpoint
- [ ] Create route: `GET /api/voting/active`
- [ ] Query polls with status = 'active'
- [ ] Return array of active voting polls
- [ ] Test with Postman: `GET http://backend-ip:3030/api/voting/active`
- [ ] Verify response format matches expected JSON
- [ ] Test with kader token (should return 200)

#### [ ] Fix Agenda Permissions
- [ ] Check permission middleware for `/api/agenda`
- [ ] Add 'kader' role to allowed roles
- [ ] Test: `GET /api/agenda` with kader token (should return 200)
- [ ] Test: List returns agenda items
- [ ] Test: Detail endpoint `/api/agenda/:id` works

#### [ ] Fix Announcement Permissions
- [ ] Check permission middleware for `/api/announcement`
- [ ] Add 'kader' role to allowed roles
- [ ] Test: `GET /api/announcement` with kader token (should return 200)
- [ ] Test: List returns announcement items
- [ ] Test: Detail endpoint `/api/announcement/:id` works

#### [ ] Testing Commands:
```bash
# Test voting active endpoint
curl -H "Authorization: Bearer YOUR_KADER_TOKEN" \
  http://your-backend:3030/api/voting/active

# Test agenda endpoint
curl -H "Authorization: Bearer YOUR_KADER_TOKEN" \
  http://your-backend:3030/api/agenda

# Test announcement endpoint
curl -H "Authorization: Bearer YOUR_KADER_TOKEN" \
  http://your-backend:3030/api/announcement
```

---

## 🎯 Frontend - No Changes Needed

**Good News:** Frontend is already correctly implemented!

```dart
// voting_service.dart - Already requests correct endpoint
final response = await _apiService.get('/api/voting/active', requiresAuth: true);

// agenda_service.dart - Already requests correct endpoint
final response = await _apiService.get('/api/agenda', requiresAuth: true);

// announcement_service.dart - Already requests correct endpoint
final response = await _apiService.get('/api/announcement', requiresAuth: true);
```

Frontend is waiting for backend to:
1. ✅ Create voting/active endpoint
2. ✅ Fix permission for agenda
3. ✅ Fix permission for announcement

---

## 📊 Current Status

| Component | Status | Notes |
|-----------|--------|-------|
| **Session (30 days)** | ✅ DONE | Frontend already set to 1 month |
| **Voting Endpoint** | ❌ MISSING | Backend needs to create `/api/voting/active` |
| **Agenda Permission** | 🟠 BLOCKED | Backend needs to add "kader" role |
| **Announcement Permission** | 🟠 BLOCKED | Backend needs to add "kader" role |

---

## 📢 Next Steps

### Backend Team:
1. Create voting/active endpoint
2. Fix permission for agenda (add kader)
3. Fix permission for announcement (add kader)
4. Test all 3 endpoints with kader token
5. Notify frontend when ready

### Frontend Team:
- Wait for backend fixes
- No code changes needed
- Test after backend deployment

---

## 📞 Technical Contact Points

**For Backend Team:**
- Check: Permission middleware/guards
- Check: Route definitions
- Check: Role-based access control (RBAC)
- Add: "kader" to allowed roles for protected endpoints
- Create: Missing voting/active endpoint

**Testing Endpoint:**
- Backend: http://103.127.96.136:3030
- Kader token: [Get from login response]

---

**Status:** Awaiting Backend Deployment 🔄  
**Priority:** High 🔴  
**Timeline:** ASAP  
