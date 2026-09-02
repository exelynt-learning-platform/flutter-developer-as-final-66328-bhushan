# Employee Management App

A Flutter app for managing employees. Built as part of a Flutter assessment.

## Features

- Firebase Authentication (Email/Password + Google Sign-In)
- Employee list with search and filter
- Add, edit, delete employees
- Search employee by ID
- Country list from API
- Light and dark theme
- Caches employee data locally using SharedPreferences

## Tech Stack

- Flutter + Dart
- Riverpod (state management)
- Dio (networking)
- Firebase Auth
- SharedPreferences
- Mockito (unit testing)

## API

Using mockapi.io:
- `GET /country` - list of countries
- `GET /employee` - all employees
- `GET /employee/:id` - single employee
- `POST /employee` - create employee
- `PUT /employee/:id` - update employee
- `DELETE /employee/:id` - delete employee

## Setup

1. Run `flutter pub get`
2. Setup Firebase project and run `flutterfire configure`
3. This will generate `android/app/google-services.json` (not committed to git — contains API keys)
4. Add SHA-1 fingerprint to Firebase for Google Sign-In
5. Run `flutter run`

## Folder Structure

```
lib/
  framwork/          # data layer
    data/            # enums
    providers/       # network, local, state providers
    repository/      # models and API calls
    utils/           # constants and theme
  ui/
    auth_screen/     # login, register, forgot password
    employee_screen/ # list, detail, add/edit, search
    country_screen/  # countries from API
    helper/          # reusable widgets
    splash_screen/
```

## Running Tests

```
flutter test test/unit/
flutter test test/widget/
```
