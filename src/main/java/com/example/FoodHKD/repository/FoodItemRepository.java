package com.example.FoodHKD.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.FoodHKD.model.Category; 
import com.example.FoodHKD.model.FoodItem; 

public interface FoodItemRepository extends JpaRepository<FoodItem, Integer> {
    List<FoodItem> findByNameContainingIgnoreCase(String keyword);
    List<FoodItem> findByCategory(Category category);
    List<FoodItem> findByQuantityGreaterThan(Integer quantity);
}
