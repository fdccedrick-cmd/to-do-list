//
//  TaskListViewModel.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation
import Combine


class TaskListViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var incompleteTasks: [Task] = []
    @Published var profile: Profile? = nil
    @Published var completedTasks: [Task] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var showError = false
    
    private let taskRepository: TaskRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
           taskRepository: TaskRepositoryProtocol = TaskRepository(),
           profileRepository: ProfileRepositoryProtocol = ProfileRepository() // ✅ default
       ) {
           self.taskRepository = taskRepository
           self.profileRepository = profileRepository
       }
    
    // MARK: - Task Filtering
    
    var todayTasks: [Task] {
        let today = Calendar.current.startOfDay(for: Date())
        return incompleteTasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return Calendar.current.isDate(dueDate, inSameDayAs: today)
        }
    }
    
    var upcomingTasks: [Task] {
        let today = Calendar.current.startOfDay(for: Date())
        return incompleteTasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate > today
        }
    }
    
    var overdueTasks: [Task] {
        let today = Calendar.current.startOfDay(for: Date())
        return incompleteTasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate < today
        }
    }
    
    

    // MARK: - Fetch Tasks
    
    
    @MainActor
    func fetchTasks(for userId: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let allTasks = try await taskRepository.fetchTasks(for: userId)
            tasks = allTasks
            incompleteTasks = allTasks.filter { !$0.isCompleted }
            completedTasks = allTasks.filter { $0.isCompleted }
        } catch {
            errorMessage = "Failed to load tasks: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    @MainActor
        func loadDashboard(for userId: UUID) async {
            isLoading = true
            errorMessage = nil

            // ✅ fetch profile + tasks concurrently
            async let profileFetch = fetchProfile(for: userId)
            async let tasksFetch = fetchTasks(for: userId)
            _ = await (profileFetch, tasksFetch)

            isLoading = false
        }
    @MainActor
       private func fetchProfile(for userId: UUID) async {
           do {
               // ✅ goes through repository → service → supabase
               profile = try await profileRepository.fetchProfile(for: userId)
           } catch {
               // silently fails — profile shows fallback in UI
               print("Failed to fetch profile: \(error.localizedDescription)")
           }
       }
    @MainActor
    func refreshTasks(for userId: UUID) async {
        await fetchTasks(for: userId)
    }
    
    // MARK: - Create Task
    
    @MainActor
    func createTask(
        userId: UUID,
        title: String,
        description: String = "",
        priority: TaskPriority = .medium,
        categoryId: UUID? = nil,
        dueDate: Date? = nil,
        dueTime: String? = nil
    ) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newTask = try await taskRepository.createTask(
                userId: userId,
                title: title,
                description: description,
                priority: priority,
                categoryId: categoryId,
                dueDate: dueDate,
                dueTime: dueTime
            )
            
            tasks.append(newTask)
            if !newTask.isCompleted {
                incompleteTasks.append(newTask)
            }
        } catch {
            errorMessage = "Failed to create task: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    // MARK: - Update Task
    
    @MainActor
    func toggleTaskCompletion(_ task: Task) async {
        do {
            let updatedTask = try await taskRepository.toggleTaskCompletion(task)
            
            // Update in local arrays
            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                tasks[index] = updatedTask
            }
            
            if updatedTask.isCompleted {
                // Move from incomplete to completed
                incompleteTasks.removeAll { $0.id == task.id }
                completedTasks.insert(updatedTask, at: 0)
            } else {
                // Move from completed to incomplete
                completedTasks.removeAll { $0.id == task.id }
                incompleteTasks.append(updatedTask)
            }
        } catch {
            errorMessage = "Failed to update task: \(error.localizedDescription)"
            showError = true
        }
    }
    
    @MainActor
    func updateTask(_ task: Task) async {
        do {
            let updatedTask = try await taskRepository.updateTask(task)
            
            // Update in local arrays
            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                tasks[index] = updatedTask
            }
            
            if let index = incompleteTasks.firstIndex(where: { $0.id == task.id }) {
                incompleteTasks[index] = updatedTask
            }
            
            if let index = completedTasks.firstIndex(where: { $0.id == task.id }) {
                completedTasks[index] = updatedTask
            }
        } catch {
            errorMessage = "Failed to update task: \(error.localizedDescription)"
            showError = true
        }
    }
    
    // MARK: - Delete Task
    
    @MainActor
    func deleteTask(_ task: Task) async {
        do {
            try await taskRepository.deleteTask(task)
            
            // Remove from local arrays
            tasks.removeAll { $0.id == task.id }
            incompleteTasks.removeAll { $0.id == task.id }
            completedTasks.removeAll { $0.id == task.id }
        } catch {
            errorMessage = "Failed to delete task: \(error.localizedDescription)"
            showError = true
        }
    }
}
