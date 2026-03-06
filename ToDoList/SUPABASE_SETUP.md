//
//  README.md
//  ToDoList Supabase Setup
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

# Supabase Setup Guide

## Prerequisites

1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Run the provided SQL schema in your Supabase SQL Editor
3. Install the Supabase Swift package

## Installation

### Add Supabase Swift Package

1. In Xcode, go to **File > Add Package Dependencies**
2. Enter the URL: `https://github.com/supabase/supabase-swift`
3. Select "Up to Next Major Version" with version `2.0.0`
4. Click "Add Package"

### Configure Supabase Credentials

1. Go to your Supabase project dashboard
2. Navigate to **Settings > API**
3. Copy your:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **Anon/Public Key**

4. Update the credentials in `SupabaseConfig.swift`:

```swift
enum SupabaseConfig {
    static let supabaseURL = "YOUR_PROJECT_URL"
    static let supabaseAnonKey = "YOUR_ANON_KEY"
}
```

5. Also update in `SupabaseManager.swift`:

```swift
guard let supabaseURL = URL(string: "YOUR_PROJECT_URL") else {
    fatalError("Invalid Supabase URL")
}

let supabaseKey = "YOUR_ANON_KEY"
```

## Database Schema

Run the SQL schema provided by the user in your Supabase SQL Editor to create:

- `profiles` table
- `categories` table
- `tasks` table
- `tags` table
- `task_tags` junction table
- `subtasks` table
- `task_attachments` table
- `reminders` table

Plus all necessary indexes and Row Level Security policies.

## Architecture Overview

### Models
- `Profile.swift` - User profile data
- `Category.swift` - Task categories
- `Task.swift` - Main task model with priority enum
- `Tag.swift` - Task tags
- `Subtask.swift` - Task subtasks/checklist items
- `TaskAttachment.swift` - File attachments
- `Reminder.swift` - Task reminders
- `TaskTag.swift` - Junction table model

### Services
- `SupabaseManager.swift` - Singleton Supabase client manager
- `AuthService.swift` - Authentication and user management
- `TaskService.swift` - Business logic for tasks, subtasks, tags
- `CategoryService.swift` - Category management
- `TodoService.swift` - Simple todo operations (legacy)

### Repositories
- `TaskRepository.swift` - Task CRUD operations
- `CategoryRepository.swift` - Category CRUD operations
- `TagRepository.swift` - Tag CRUD operations
- `SubtaskRepository.swift` - Subtask CRUD operations
- `TodoRepository.swift` - Simple todo operations (legacy)

### Utilities
- `NetworkMonitor.swift` - Network connectivity monitoring
- `SupabaseConfig.swift` - Centralized configuration

## Usage Examples

### Authentication

```swift
let authService = AuthService()

// Sign up
try await authService.signUp(
    email: "user@example.com",
    password: "password123",
    displayName: "John Doe"
)

// Sign in
try await authService.signIn(
    email: "user@example.com",
    password: "password123"
)

// Sign out
try await authService.signOut()
```

### Tasks

```swift
let taskService = TaskService()

// Create task
let task = try await taskService.createTask(
    userId: userId,
    title: "Complete project",
    description: "Finish the todo app",
    priority: .high,
    dueDate: Date()
)

// Get all tasks
let tasks = try await taskService.getTasks(userId: userId)

// Toggle completion
let updatedTask = try await taskService.toggleTaskCompletion(id: taskId)

// Delete task
try await taskService.deleteTask(id: taskId)
```

### Categories

```swift
let categoryService = CategoryService()

// Create category
let category = try await categoryService.createCategory(
    userId: userId,
    name: "Work",
    icon: "briefcase",
    colorHex: "#3B82F6"
)

// Get categories
let categories = try await categoryService.getCategories(userId: userId)
```

## Next Steps

1. ✅ Install Supabase Swift package
2. ✅ Configure credentials in `SupabaseConfig.swift`
3. ✅ Run database schema in Supabase
4. 🔲 Update ViewModels to use new services
5. 🔲 Create authentication views (Login/Signup)
6. 🔲 Test the implementation

## Notes

- Row Level Security (RLS) is enabled on tasks and categories
- Users can only access their own data
- Default categories can be viewed by all users
- All timestamps use `timestamptz` for timezone support
