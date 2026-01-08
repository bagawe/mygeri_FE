# 📋 Radar Feature - Phase 1 Checklist

**Status:** ✅ APPROVED & READY TO START  
**Timeline:** 4 Weeks  
**Start Date:** Week of 13 Januari 2026  
**Target Launch:** Week of 10 Februari 2026

---

## 🎯 Phase 1 Scope

### ✅ **INCLUDED (Must Have)**

#### **Core Functionality**
- [x] Map display with OpenStreetMap
- [x] Manual location refresh button
- [x] Toggle switch ON/OFF location sharing
- [x] Role-based access (Simpatisan vs Kader)
- [x] Background auto-update every 1 hour
- [x] GPS location permissions
- [x] Tap marker to view user info

#### **UI/UX**
- [x] Basic map interface
- [x] User markers with avatars
- [x] Color-coded markers by jabatan
- [x] Bottom sheet for user details
- [x] Control panel (toggle + refresh)
- [x] Stats card (total online users)
- [x] Loading states & error messages

#### **Backend**
- [x] Database tables (user_locations, location_history)
- [x] 4 core API endpoints
- [x] Role-based filtering in queries
- [x] Rate limiting (1 update/minute)
- [x] Location history storage

#### **Security & Privacy**
- [x] Location sharing OFF by default
- [x] Explicit user opt-in
- [x] Role-based visibility
- [x] JWT authentication
- [x] Input validation

---

### ❌ **EXCLUDED (Phase 2 - After Feedback)**

#### **Advanced Features (Deferred)**
- [ ] ~~Marker clustering~~ → Phase 2
- [ ] ~~Search kader by name~~ → Phase 2
- [ ] ~~Statistics dashboard~~ → Phase 2
- [ ] ~~Dark mode support~~ → Phase 2
- [ ] ~~Location history viewer (admin web)~~ → Phase 2
- [ ] ~~Advanced animations~~ → Phase 2
- [ ] ~~Geofencing~~ → Phase 2
- [ ] ~~Distance calculations~~ → Phase 2
- [ ] ~~Route tracking~~ → Phase 2

**Why Deferred?**
- Not critical for core functionality
- Can add based on user feedback
- Reduce initial complexity
- Faster launch time
- Lower development risk

---

## 📅 Week-by-Week Plan

### **Week 1: Foundation (13-19 Jan 2026)**

#### **Backend Team**
- [ ] Create MySQL database tables
  - [ ] `user_locations` table with indexes
  - [ ] `location_history` table with auto-cleanup event
  - [ ] Test table creation & indexes
- [ ] Implement API endpoints
  - [ ] POST `/api/radar/update-location`
  - [ ] GET `/api/radar/locations` with role filtering
  - [ ] POST `/api/radar/toggle-sharing`
  - [ ] GET `/api/radar/my-status`
- [ ] Add input validation & error handling
- [ ] Setup rate limiting middleware
- [ ] Test all endpoints with Postman
- [ ] Deploy to staging server

#### **Frontend Team**
- [ ] Add dependencies to `pubspec.yaml`
  - [ ] flutter_map: ^6.1.0
  - [ ] latlong2: ^0.9.0
  - [ ] geolocator: ^10.1.0
  - [ ] permission_handler: ^11.1.0
  - [ ] workmanager: ^0.5.1
- [ ] Setup Android permissions (AndroidManifest.xml)
- [ ] Setup iOS permissions (Info.plist)
- [ ] Create file structure
  - [ ] lib/pages/radar/radar_page.dart
  - [ ] lib/services/location_service.dart
  - [ ] lib/services/radar_api_service.dart
  - [ ] lib/pages/radar/models/kader_location.dart
- [ ] Implement LocationService (GPS logic)
- [ ] Implement RadarApiService (HTTP calls)
- [ ] Build basic RadarPage UI with OpenStreetMap
- [ ] Test location permissions on real device

#### **Milestones**
- ✅ Backend API operational on staging
- ✅ Frontend map displays correctly
- ✅ Location permissions work

---

### **Week 2: Integration (20-26 Jan 2026)**

#### **Backend Team**
- [ ] Review API performance
- [ ] Add Redis caching (optional)
- [ ] Fix any bugs from testing
- [ ] Monitor database performance
- [ ] Prepare API documentation

#### **Frontend Team**
- [ ] Connect Flutter app to staging API
- [ ] Implement manual location update
  - [ ] Call POST /api/radar/update-location
  - [ ] Show success/error messages
  - [ ] Handle network errors
- [ ] Implement location fetching
  - [ ] Call GET /api/radar/locations
  - [ ] Display markers on map
  - [ ] Show user avatars
- [ ] Implement toggle switch
  - [ ] Call POST /api/radar/toggle-sharing
  - [ ] Save preference locally
  - [ ] Show current status
- [ ] Implement user info bottom sheet
  - [ ] Tap marker triggers sheet
  - [ ] Display name, jabatan, region
  - [ ] Show last update time
- [ ] Add loading states & error handling
- [ ] Test role-based filtering
  - [ ] Test as Simpatisan (see only Simpatisan)
  - [ ] Test as Kader (see Kader + Simpatisan)
  - [ ] Test as Admin (see all)

#### **Testing**
- [ ] Integration testing (Flutter + Backend)
- [ ] Real device testing (Android)
- [ ] Real device testing (iOS)
- [ ] Test with multiple users
- [ ] Test network offline/online scenarios

#### **Milestones**
- ✅ App successfully connects to backend
- ✅ Manual location update works
- ✅ Toggle switch works
- ✅ Role-based filtering confirmed
- ✅ No critical bugs

---

### **Week 3: Background Service (27 Jan - 2 Feb 2026)**

#### **Backend Team**
- [ ] Monitor API performance under load
- [ ] Optimize slow queries if needed
- [ ] Prepare for production deployment

#### **Frontend Team**
- [ ] Implement WorkManager background service
  - [ ] Create BackgroundLocationService
  - [ ] Register periodic task (1 hour interval)
  - [ ] Handle task execution
  - [ ] Call API in background
- [ ] Test background updates
  - [ ] App in background
  - [ ] App force closed
  - [ ] After device reboot
  - [ ] With/without internet
- [ ] Battery usage testing
  - [ ] Monitor battery drain
  - [ ] Optimize if needed (use coarse location)
  - [ ] Target: <5% per hour
- [ ] Implement filters
  - [ ] Filter by region (dropdown)
  - [ ] Filter by jabatan (dropdown)
  - [ ] Clear filters option
- [ ] Add color-coded markers by jabatan
  - [ ] Red: Ketua
  - [ ] Blue: Sekretaris
  - [ ] Orange: Bendahara
  - [ ] Green: Anggota/Simpatisan
- [ ] Polish UI/UX
  - [ ] Smooth animations
  - [ ] Better loading indicators
  - [ ] Improved error messages
  - [ ] Consistent spacing/padding

#### **Milestones**
- ✅ Background service works reliably
- ✅ Location updates every 1 hour
- ✅ Battery usage acceptable
- ✅ Filters work correctly
- ✅ UI polished & user-friendly

---

### **Week 4: Testing & Launch (3-9 Feb 2026)**

#### **Backend Team**
- [ ] Final security review
- [ ] Load testing
- [ ] Deploy to production
- [ ] Setup monitoring & alerts
- [ ] Prepare rollback plan

#### **Frontend Team**
- [ ] Final bug fixes from Week 3 testing
- [ ] Comprehensive testing
  - [ ] All user roles (Simpatisan, Kader, Admin)
  - [ ] All device types (Android, iOS)
  - [ ] Different screen sizes
  - [ ] Different network conditions
  - [ ] Edge cases (no GPS, no permission, etc.)
- [ ] User acceptance testing (UAT)
  - [ ] Get 5-10 real users to test
  - [ ] Collect feedback
  - [ ] Fix critical issues
- [ ] Performance optimization
  - [ ] Map load time <3 seconds
  - [ ] API calls <500ms response
  - [ ] Smooth scrolling/zooming
- [ ] Final polish
  - [ ] Fix all typos
  - [ ] Consistent styling
  - [ ] Proper error messages
- [ ] Build production APK/IPA
  - [ ] flutter build apk --release
  - [ ] flutter build ios --release
- [ ] Submit to app stores (if applicable)

#### **Documentation**
- [ ] Update user guide
- [ ] Create admin guide
- [ ] Prepare release notes

#### **Launch Preparation**
- [ ] Notify users about new feature
- [ ] Prepare support FAQ
- [ ] Setup user feedback channel
- [ ] Plan feedback collection strategy

#### **Milestones**
- ✅ All critical bugs fixed
- ✅ UAT passed
- ✅ Performance acceptable
- ✅ Production APK built
- ✅ **LAUNCHED TO PRODUCTION** 🚀

---

## 📊 Success Metrics (Week 4)

### **Adoption Metrics**
- [ ] >30% users open Radar page
- [ ] >20% users enable location sharing
- [ ] >50 active locations visible

### **Technical Metrics**
- [ ] >95% location update success rate
- [ ] >90% background task reliability
- [ ] <500ms average API response time
- [ ] <5% battery usage per hour
- [ ] Zero critical bugs

### **Quality Metrics**
- [ ] <50m average GPS accuracy
- [ ] >99% API uptime
- [ ] No data leaks or privacy violations

---

## 🎯 Post-Launch (Week 5+)

### **Feedback Collection**
- [ ] Survey users about Radar feature
- [ ] Collect feature requests
- [ ] Monitor support tickets
- [ ] Track usage analytics

### **Analysis**
- [ ] Analyze adoption rate
- [ ] Identify most used features
- [ ] Identify pain points
- [ ] Gather Phase 2 requirements

### **Phase 2 Planning**
- [ ] Review feedback with owner
- [ ] Prioritize Phase 2 features
- [ ] Estimate Phase 2 timeline
- [ ] Plan Phase 2 implementation

**Questions for Owner/Users:**
1. How useful is the Radar feature? (1-10)
2. Would you use marker clustering? (many users on map)
3. Do you need search by name feature?
4. Would dark mode be helpful?
5. What other features would you like?

---

## ⚠️ Risk Management

### **Technical Risks**

**Risk:** Background service doesn't work after force close  
**Mitigation:** Extensive testing on Week 3, fallback to manual refresh

**Risk:** Battery drain too high  
**Mitigation:** Use coarse location, 1-hour interval, monitor battery usage

**Risk:** GPS inaccurate indoors  
**Mitigation:** Show accuracy circle, filter inaccurate readings

**Risk:** API performance issues under load  
**Mitigation:** Redis caching, database optimization, load testing

### **User Adoption Risks**

**Risk:** Users don't enable location sharing (privacy concerns)  
**Mitigation:** Clear privacy messaging, OFF by default, educate users

**Risk:** Users don't understand how to use feature  
**Mitigation:** Simple UI, clear instructions, tooltips, user guide

**Risk:** Feature not useful for users  
**Mitigation:** Collect feedback early, iterate quickly, Phase 1 approach

---

## 📞 Team Communication

### **Daily Standups (15 min)**
- What did you do yesterday?
- What will you do today?
- Any blockers?

### **Weekly Sync (30 min)**
- Review progress vs checklist
- Demo completed features
- Discuss blockers
- Plan next week

### **Team Channels**
- Slack/Discord: #radar-feature
- Issues: GitHub Issues
- Code Review: Pull Requests
- Documentation: Google Docs/Notion

---

## 📝 Definition of Done

**Backend Endpoint is Done When:**
- ✅ Code reviewed & merged
- ✅ Unit tests pass
- ✅ Integration tests pass
- ✅ Postman tests documented
- ✅ Deployed to staging
- ✅ API docs updated

**Frontend Feature is Done When:**
- ✅ Code reviewed & merged
- ✅ Works on real device (Android + iOS)
- ✅ No console errors
- ✅ Error handling implemented
- ✅ Loading states added
- ✅ Meets design requirements
- ✅ User tested & approved

---

## 🎉 Launch Day Checklist

**T-1 Day (Before Launch)**
- [ ] Backend deployed to production
- [ ] Production database ready
- [ ] Frontend APK built & tested
- [ ] Monitoring setup
- [ ] Support team briefed
- [ ] Announcement prepared

**Launch Day**
- [ ] Deploy app to production
- [ ] Send announcement to users
- [ ] Monitor error logs
- [ ] Monitor API performance
- [ ] Be ready for quick fixes
- [ ] Celebrate! 🎊

**T+1 Day (After Launch)**
- [ ] Check adoption metrics
- [ ] Review error logs
- [ ] Respond to user feedback
- [ ] Fix any critical bugs
- [ ] Plan improvements

---

**Status:** ✅ READY TO START  
**Next Action:** Kickoff meeting with team  
**Last Updated:** 8 Januari 2026

---

**Let's build this! 🚀**
