package com.example.FoodHKD.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import com.example.FoodHKD.model.TableDetail;
import com.example.FoodHKD.model.TableEntity;
import com.example.FoodHKD.model.User;
import com.example.FoodHKD.repository.TableDetailRepository;
import com.example.FoodHKD.repository.UserRepository;

import jakarta.transaction.Transactional;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private TableDetailRepository tableDetailRepository;
    @Autowired
    private BCryptPasswordEncoder passwordEncoder;
    @Autowired
    private JwtService jwtService;

    @Override
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    @Override
    public User getUserById(Integer id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    @Override
    public User getUserByUsername(String username) {
        // return userRepository.findByUsername(username)
        //         .orElseThrow(() -> new RuntimeException("Username not found"));
        return userRepository.findByUsername(username).orElse(null);

    }

    @Override
    public User createUser(User user) {
        user.setPasswordHash(passwordEncoder.encode(user.getPasswordHash()));
        return userRepository.save(user);
    }

    @Override
    public User updateUser(Integer id, User updatedUser) {
        User existingUser = getUserById(id); 

        existingUser.setUsername(updatedUser.getUsername());
        existingUser.setFullName(updatedUser.getFullName());
        existingUser.setRole(updatedUser.getRole());
        if (updatedUser.getPasswordHash() != null && !updatedUser.getPasswordHash().isEmpty()) {
            existingUser.setPasswordHash(passwordEncoder.encode(updatedUser.getPasswordHash()));
        }

        return userRepository.save(existingUser);
    }

    @Override
    @Transactional
    public void deleteUser(Integer id) {
        User user = userRepository.findById(id).orElse(null);
        if (user != null) {
            if (user.getOrders() != null) {
                user.getOrders().forEach(order -> order.setCreatedBy(null));
            }

            if (user.getInvoices() != null) {
                user.getInvoices().forEach(invoice -> invoice.setIssuedBy(null));
            }

            if (user.getInventoryLogs() != null) {
                user.getInventoryLogs().forEach(log -> log.setCreatedBy(null));
            }

            if (user.getTableEntities() != null) {
                for (TableEntity table : user.getTableEntities()) {
                    table.setEmployee(null);
                    table.setStatus("Trong");

                    if (table.getOrders() != null) {
                        for (TableDetail detail : table.getTableDetails()) {
                            tableDetailRepository.delete(detail);
                        }
                    }
                }
            }

            userRepository.delete(user);
        }
    }

    @Override
    public String loginGetToken(String username, String password) {
        User user = getUserByUsername(username);
        if (user == null || !passwordEncoder.matches(password, user.getPasswordHash())) {
            throw new RuntimeException("Invalid username or password");
        }
        UserDetails userDetails = new org.springframework.security.core.userdetails.User(
                user.getUsername(),
                user.getPasswordHash(),
                java.util.Collections
                        .singletonList(new org.springframework.security.core.authority.SimpleGrantedAuthority(
                                user.getRole())));
        return jwtService.generateToken(userDetails);
    }

}
