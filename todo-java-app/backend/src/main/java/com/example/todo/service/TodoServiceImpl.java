package com.example.todo.service;

import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Service;

import com.example.todo.model.Todo;

@Service
public class TodoServiceImpl implements TodoService {

    private List<Todo> todos = new ArrayList<>();

    @Override
    public List<Todo> getAllTodos() {
        return todos;
    }

    @Override
    public Todo getTodoById(String id) {
        // Implement logic to retrieve a Todo by id
        return todos.stream()
                .filter(todo -> todo.getId().equals(id))
                .findFirst()
                .orElse(null);
    }

    @Override
    public Todo createTodo(Todo todo) {
        todos.add(todo);
        return todo;
    }

    @Override
    public Todo updateTodo(String id, Todo todo) {
        for (int i = 0; i < todos.size(); i++) {
            if (todos.get(i).getId().equals(id)) {
                todos.set(i, todo);
                return todo;
            }
        }
        return null;
    }

    @Override
    public void deleteTodo(String id) {
        todos.removeIf(todo -> todo.getId().equals(id));
    }
}
