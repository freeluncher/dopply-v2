# Changelog

All notable changes to this project will be documented in this file.


## [1.2.1] - 2026-01-19

### Critical Fixes
- **Realtime Stability**: Fixed `InvalidJWTToken` crash by implementing auto-reconnect logic when Auth Token refreshes.
- **Android 12+ Support**: Fixed "Device Not Found" error by explicitly requesting Runtime Permissions (`BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT`, `LOCATION`).
- **Data Sync**: Fixed BLE data parsing issues where the app expected a different format than the ESP32. Now synced to parse raw integer data.

### Enhancements
- **Live BPM Preview**:
  - Users can now see their Heart Rate immediately upon connection (Preview Mode) without needing to start a recording session.
  - Recording only saves data to history/graph when the "Start Recording" button is explicitly pressed.
- **Admin Security**: Added missing RLS Policy (`Admins view all notifications`) ensuring Admins can verify sent broadcasts in the Notification Tab.

## [1.2.0] - 2026-01-19

### Added
- **Admin Console V2**:
  - **Notification Center**: Fully functional panel to send notifications and **Broadcast** messages to all users.
  - **User Management**: Integrated CRUD (Edit Name/Role, Soft Delete, and **Hard Delete/Block Login** via Edge Functions).
  - **Secure Deletion**: Implemented `delete-user` Edge Function to safely remove users from Authentication and Database.
- **Push Notifications System**:
  - Full end-to-end integration with Firebase Cloud Messaging (FCM) and Supabase Edge Functions.
  - **Broadcast Support**: Send system-wide announcements with one click.
  - **Android 8.0+ Fix**: Added Notification Channel Metadata to ensure delivery in background/terminated states.
- **Database Optimization**:
  - Improved Schema Relationships for Notifications (Fixed FK errors).
  - Optimized RLS policies for Admin access.

### Fixed
- **Notification UI**: Resolved `RenderFlex overflow` in Admin dropdown for long user emails.
- **Data Integrity**: Corrected database relationships for `notifications` table (now properly linked to `profiles`).
- **Assets**: Updated Splash Screen with transparent logo variant (`logo-dopply-transparent.png`).

### Changed
- **Performance**: Reduced build size by optimizing unused assets and imports.


### Added
- **UI/UX Improvements**:
  - Implemented "Soft & Organic" design language with dynamic background blobs and softer shadows.
  - Enhanced visual feedback for Bluetooth connection and Heartrate visualization (`PulseAnimation`).
  - Improved Empty States and Error Widgets for better user guidance.
- **Realtime Updates**:
  - Implemented client-side Realtime Listener for Monitoring Permissions. Patients now see status changes instantly without refreshing.
- **Backend**:
  - Added Supabase Edge Function (`supabase/functions/push-notification`) to handle FCM Push Notifications.

### Fixed
- **Critical Crash**: Fixed `PulseAnimation` crash (`Multiple tickers created`) when BPM changes or animation restarts.
- **Build Optimization**: Resolved Gradle warnings (`obsolete options`, `incremental caches`) for smoother Android builds.

## [1.1.0] - 2026-01-19


### Added
- **Admin Panel Enhancements**:
  - New **Overview Tab** displaying system statistics (Total Users, Patients, Records).
  - New **Users Tab** with search functionality to manage doctors and patients.
  - Improved structure with TabBar navigation.
- **Search & Sort**:
  - Added search bar to **Doctor's Patient List**.
  - Added search (by note/classification) and sort (by Date/BPM) to **Records List**.
- **Centralized Error Handling**:
  - Global error listener in Dashboard.
  - Unified failure mapping for Network, Server, and Bluetooth errors.
- **Branding**:
  - Updated App Icon to new "Dopply" logo.
  - Updated Splash Screen branding.
- **Auto-Update**:
  - Integrated GitHub Releases OTA system using `ota_update`.
