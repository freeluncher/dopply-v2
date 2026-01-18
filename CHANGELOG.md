# Changelog

All notable changes to this project will be documented in this file.

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
