# Voting Feature - Status & Implementation Plan

## 📊 Current Status

**Feature**: Voting / E-Voting  
**Status**: ⚠️ **Backend In Development**  
**Frontend**: ✅ **RBAC Implemented** (Role-based access control ready)  
**Last Updated**: February 11, 2026

---

## 🔒 Access Control

### Role Permissions
- ✅ **Admin**: Has access (waiting for backend)
- ✅ **Kader**: Has access (waiting for backend)
- ❌ **Simpatisan**: No access

### Current Behavior

#### For SIMPATISAN Users:
When clicking Voting menu → Shows dialog:
```
┌─────────────────────────────────────┐
│ 🚧 Dalam Pengembangan               │
├─────────────────────────────────────┤
│ Fitur Voting sedang dalam           │
│ pengembangan.                       │
│                                     │
│ ╔═══════════════════════════════╗  │
│ ║ 🔒 Status Akses: DITOLAK      ║  │
│ ║ 👤 Role Anda: SIMPATISAN      ║  │
│ ╚═══════════════════════════════╝  │
│                                     │
│ Fitur ini hanya tersedia untuk      │
│ Kader dan Admin. Hubungi admin      │
│ untuk upgrade role Anda.            │
│                                     │
│               [Mengerti]            │
└─────────────────────────────────────┘
```

#### For KADER/ADMIN Users:
When clicking Voting menu → Shows dialog:
```
┌─────────────────────────────────────┐
│ 🚧 Dalam Pengembangan               │
├─────────────────────────────────────┤
│ Fitur Voting sedang dalam           │
│ pengembangan.                       │
│                                     │
│ ╔═══════════════════════════════╗  │
│ ║ ✅ Status Akses: DIIZINKAN    ║  │
│ ║ 👤 Role Anda: KADER/ADMIN     ║  │
│ ╚═══════════════════════════════╝  │
│                                     │
│ Backend sedang dalam pengembangan.  │
│ Fitur ini akan segera tersedia      │
│ untuk Anda!                         │
│                                     │
│               [Mengerti]            │
└─────────────────────────────────────┘
```

---

## 📋 Waiting for Backend

### Backend Requirements

Frontend is ready and waiting for backend documentation for:

1. **API Endpoints**
   - `GET /api/voting/polls` - List voting polls
   - `GET /api/voting/polls/:id` - Get poll details
   - `POST /api/voting/polls/:id/vote` - Submit vote
   - `GET /api/voting/results/:id` - Get voting results
   - `GET /api/voting/my-votes` - Get user's voting history

2. **Authentication & Authorization**
   - JWT token authentication required
   - Role-based access: Admin, Kader only
   - Simpatisan should get 403 Forbidden

3. **Data Models**
   ```json
   // Poll Model
   {
     "id": 1,
     "title": "Pemilihan Ketua DPC",
     "description": "Pemilihan Ketua DPC periode 2026-2031",
     "startDate": "2026-03-01T00:00:00Z",
     "endDate": "2026-03-15T23:59:59Z",
     "status": "active",
     "totalVotes": 150,
     "hasVoted": false,
     "candidates": [
       {
         "id": 1,
         "name": "Calon A",
         "photo": "/uploads/calon-a.jpg",
         "visi": "...",
         "misi": "...",
         "voteCount": 75
       }
     ]
   }
   ```

4. **Business Rules**
   - One vote per user per poll
   - Voting only during active period
   - Results visible after voting ends (or after user votes)
   - Vote cannot be changed after submission

---

## 🎯 Frontend Implementation Plan

### Phase 1: Models & Services (Ready to implement)

```dart
// lib/models/poll.dart
class Poll {
  final int id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'upcoming', 'active', 'ended'
  final int totalVotes;
  final bool hasVoted;
  final List<Candidate> candidates;
}

// lib/models/candidate.dart
class Candidate {
  final int id;
  final String name;
  final String? photo;
  final String? visi;
  final String? misi;
  final int? voteCount; // Visible after voting or poll ends
}

// lib/services/voting_service.dart
class VotingService {
  Future<List<Poll>> getPolls();
  Future<Poll> getPollById(int id);
  Future<void> submitVote(int pollId, int candidateId);
  Future<PollResult> getResults(int pollId);
  Future<List<MyVote>> getMyVotes();
}
```

### Phase 2: UI Pages (Ready to implement)

```dart
// lib/pages/voting/voting_page.dart
- List of active polls
- Filter: All, Active, Upcoming, Ended
- Poll cards with countdown timer
- Status badges

// lib/pages/voting/poll_detail_page.dart
- Poll information
- List of candidates with photos
- Vote button
- Results (if applicable)
- Confirmation dialog before voting

// lib/pages/voting/voting_result_page.dart
- Vote results visualization
- Bar chart / pie chart
- Winner announcement
- Statistics
```

### Phase 3: Navigation (Already done)

```dart
// In beranda_page.dart - Menu Voting (index 4)
else if (index == 4 && item['label'] == 'Voting') {
  // Cek role terlebih dahulu
  if (_hasAccessToFeature('Voting')) {
    // TODO: Uncomment when backend ready
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => VotingPage()),
    // );
    
    // Temporary: Show in development dialog
    _showInDevelopmentDialog('Voting');
  } else {
    _showAccessDeniedDialog('Voting');
  }
}
```

---

## 🚀 Migration Steps (When Backend is Ready)

### Step 1: Backend Developer
1. Create voting endpoints
2. Implement role-based authorization
3. Provide API documentation
4. Deploy to staging for testing

### Step 2: Frontend Developer
1. Create models (Poll, Candidate, VotingResult)
2. Create VotingService with API calls
3. Create VotingPage (list of polls)
4. Create PollDetailPage (voting interface)
5. Create VotingResultPage (results display)
6. Update beranda_page.dart navigation
7. Remove `_showInDevelopmentDialog()` call
8. Uncomment navigation to VotingPage

### Step 3: Testing
1. Test as Simpatisan → Should get 403 Forbidden
2. Test as Kader → Should see polls and can vote
3. Test as Admin → Should see polls and can vote
4. Test voting submission
5. Test results display
6. Test edge cases (voting twice, expired polls, etc.)

---

## 📝 Code Changes Required (When Backend Ready)

### Update beranda_page.dart:

```dart
// BEFORE (Current - In Development)
else if (index == 4 && item['label'] == 'Voting') {
  _showInDevelopmentDialog('Voting');
}

// AFTER (When Backend Ready)
else if (index == 4 && item['label'] == 'Voting') {
  if (_hasAccessToFeature('Voting')) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VotingPage()),
    );
  } else {
    _showAccessDeniedDialog('Voting');
  }
}
```

### Add import:
```dart
import '../voting/voting_page.dart';
```

---

## 📞 Communication with Backend Team

### Questions to Ask Backend Developer:

1. **Timeline**
   - Kapan backend voting akan selesai?
   - Ada estimasi tanggal deployment?

2. **API Documentation**
   - Apakah ada Swagger/Postman collection?
   - Format response seperti apa?
   - Error codes yang digunakan?

3. **Authentication**
   - Menggunakan Bearer token yang sama?
   - Ada permission khusus selain role?

4. **Business Logic**
   - Apakah user bisa melihat hasil sebelum vote?
   - Apakah hasil real-time atau setelah voting selesai?
   - Apakah ada verifikasi double (konfirmasi vote)?

5. **Testing**
   - Apakah ada staging environment?
   - Apakah ada test account dengan berbagai role?

---

## 🎨 UI/UX Design Notes

### Voting List Page
- Card layout untuk setiap poll
- Status badge (Upcoming, Active, Ended)
- Countdown timer untuk active polls
- Quick stats (total votes, has voted)
- Filter tabs

### Poll Detail Page
- Hero image or banner
- Poll information (title, description, period)
- Candidate cards with photos
- Vote button (primary action)
- Results button (if applicable)
- Confirmation modal before submit

### Results Page
- Visual charts (bar/pie chart)
- Winner announcement banner
- Vote percentages
- Total votes count
- Timestamp

### Design Considerations
- Gerindra red color theme
- Modern Material Design
- Smooth animations
- Loading states
- Error handling
- Empty states

---

## ✅ Current Implementation Status

- [x] RBAC logic implemented
- [x] _hasAccessToFeature() checks for Voting
- [x] _showInDevelopmentDialog() created
- [x] Different messages for allowed/denied users
- [x] Visual indicators (green=allowed, red=denied)
- [x] Documentation created
- [ ] Backend API (waiting)
- [ ] Models created (waiting for backend spec)
- [ ] Services created (waiting for backend spec)
- [ ] UI pages created (waiting for backend spec)
- [ ] Navigation enabled (waiting for backend spec)

---

**Note**: Frontend siap untuk diimplementasikan begitu backend developer menyediakan API documentation dan endpoint yang diperlukan. RBAC sudah diterapkan dan akan otomatis bekerja ketika navigasi ke VotingPage diaktifkan.

**Status**: 🟡 **Frontend Ready - Waiting for Backend**

---

**Contact Backend Team**: Kirim dokumentasi API ke team frontend untuk mulai implementasi UI.
