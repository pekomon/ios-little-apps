//
//  ContentView.swift
//  TaskTracker
//
//  Created by Pekomon on 7.3.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var tasks: [Task] = [
        Task(title: "Do something"),
        Task(title: "Go shopping", isCompleted: true),
        Task(title: "Hello world!"),
    ]
    @State private var newTaskTitle: String = ""
    
    var body: some View {
        VStack {
            Text("Task Tracker")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom)
            
            HStack {
                TextField("New task", text: $newTaskTitle)
                    .textFieldStyle(.roundedBorder)
                Button("Add task") {
                    addTask()
                }
                .buttonStyle(.borderedProminent)
                .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            
            // List of tasks
            List {
                ForEach(tasks) { task in
                    HStack {
                        Text(task.title)
                            .strikethrough(task.isCompleted)
                        Image(systemName: task.isCompleted ? "checkmark.seal.fill" : "circlebadge")
                    }
                    .onTapGesture {tapGesture in
                        toggleTask(task)
                    }
                }
                .onDelete(perform: deleteTask)
            }
        }
        .padding()
    }
    
    private func addTask() {
        let trimmedTitle = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        let newTask = Task(title: trimmedTitle)
        tasks.append(newTask)
        newTaskTitle = ""
    }

    private func toggleTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id}) {
            tasks[index].isCompleted.toggle()
        }
    }
    
    private func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
}

#Preview {
    ContentView()
}
