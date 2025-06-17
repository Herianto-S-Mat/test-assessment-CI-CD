package com.test.assessment.controller;

import com.test.assessment.model.ApiResponse;
import com.test.assessment.model.User;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TestDemoController {

    @GetMapping("/")
    public ResponseEntity<ApiResponse<String[]>> url() {
        String[] link = {"http://localhost:8080/test"}; // gunakan URL penuh
        ApiResponse<String[]> response = new ApiResponse<>(link, "Link to /test");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/test")
    public ResponseEntity<ApiResponse<User>> test() {
        User user = new User();
        user.setName("aflah");
        user.setPassword("123456");
        user.setEmail("aflah@universe.com");

        ApiResponse<User> response = new ApiResponse<>(user, "success");
        return ResponseEntity.ok(response);
    }
}