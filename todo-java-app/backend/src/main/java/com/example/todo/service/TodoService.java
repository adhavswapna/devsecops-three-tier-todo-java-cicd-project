package com.example.todo.service;

import java.util.List;

import com.example.todo.model.Todo;

public interface TodoService {
    List<Todo> getAllTodos();
    Todo getTodoById(String id);
    Todo createTodo(Todo todo);
    Todo updateTodo(String id, Todo todo);
    void deleteTodo(String id);
}
