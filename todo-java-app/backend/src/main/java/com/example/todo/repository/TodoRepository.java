package com.example.todo.repository;

import org.springframework.data.mongodb.repository.MongoRepository;

import com.example.todo.model.Todo;

public interface TodoRepository extends MongoRepository<Todo, String> {
}
