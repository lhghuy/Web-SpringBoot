package com.example.FoodHKD.controller.admin;

import java.security.Principal;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.example.FoodHKD.model.User;
import com.example.FoodHKD.service.UserService;


@Controller
@RequestMapping("/admin/reports")
public class ReportAdminController {
    @Autowired
    private UserService userService;

    @GetMapping
    public String getReportPage(Model model, Principal principal) {
        User loggedInUser = userService.getUserByUsername(principal.getName());

        model.addAttribute("loggedInUser", loggedInUser);
        return "reportAdmin";
    }
}
