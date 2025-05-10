# Freezed Model Compatibility Guide

This guide provides an overview of how to work with Freezed models in the repository layer of the Workvibe application.

## Overview

The application uses [Freezed](https://pub.dev/packages/freezed) to generate immutable data models with built-in:
- Serialization/deserialization
- Copy methods
- Equality comparisons
- Pattern matching

To ensure seamless integration between Freezed models and Supabase database operations, we've implemented a comprehensive adapter system.

## Key Components

1. **ModelAdapter**: Utility class for converting between Supabase (snake_case) and Freezed (camelCase) formats
2. **FreezedModelAdapterMixin**: Mixin to add to repositories for simplified model conversion
3. **SupabaseRepository**: Base repository implementation with integrated adapter support

## Using Freezed Models in Repositories

Our `SupabaseRepository` class automatically handles the conversion between Supabase data and Freezed models. When implementing a repository for a Freezed model, follow these steps:

### 1. Define Your Freezed Model

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    DateTime? lastLogin,
    @Default(false) bool isActive,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

### 2. Implement Repository Interface

```dart
abstract class IUserRepository extends IRepository<User> {
  Future<User?> getUserByEmail(String email);
  // Additional user-specific methods
}
```

### 3. Create Repository Implementation

```dart
class UserRepository extends SupabaseRepository<User> implements IUserRepository {
  @override
  String get tableName => 'users';

  @override
  User fromJson(Map<String, dynamic> json) => User.fromJson(json);

  @override
  Map<String, dynamic> toJson(User entity) => entity.toJson();

  @override
  String getIdFromEntity(User entity) => entity.id;

  // Implementation of additional user-specific methods
}
```

## Field Name Conversion

The adapter automatically handles conversion between:
- **snake_case** (Supabase/database): `user_id`, `created_at`
- **camelCase** (Dart/Freezed): `userId`, `createdAt`

## Type Conversions

The adapter automatically handles these type conversions:
- **DateTime objects** ↔ ISO 8601 date strings
- **Lists of objects** ↔ Lists of JSON maps
- **Nested objects** ↔ Nested JSON maps

## Using Model Updates with Freezed

When updating a model, use the generated `copyWith` method to create a new instance:

```dart
// Get the current user
final user = await userRepository.getById('user-123');

// Create updated user with new properties
final updatedUser = user.copyWith(
  name: 'New Name',
  isActive: true,
);

// Save changes to the database
await userRepository.update(updatedUser);
```

## Testing with Freezed Models

For testing repositories with Freezed models, create test fixtures and mock implementations:

```dart
// Create a test fixture
final testUser = User(
  id: 'test-1',
  name: 'Test User',
  email: 'test@example.com',
  isActive: true,
  lastLogin: DateTime.now(),
);

// Repository will handle proper serialization/deserialization
final result = await userRepository.create(testUser);
```

## Debugging Conversion Issues

If you encounter issues with field conversion:

1. Check for mismatched names between database columns and model fields
2. Verify custom JSON serializers if using `@JsonKey` annotations
3. Check for unsupported types in your model (use basic types or implement custom converters)

## Best Practices

1. Always use the repository layer for database operations, never direct Supabase client calls
2. Keep models immutable; use `copyWith` for updates
3. Include validation in repository implementations 
4. Document custom field mappings with `@JsonKey` annotations
5. Use nullable types (`String?`) for optional fields 