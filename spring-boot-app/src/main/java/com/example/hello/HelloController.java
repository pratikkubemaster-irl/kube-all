package com.example.hello;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.http.ResponseEntity;
import java.util.HashMap;
import java.util.Map;

/**
 * REST Controller for handling Hello World requests
 */
@RestController
public class HelloController {

    @Value("${app.name:Hello World App}")
    private String appName;

    @Value("${app.version:1.0.0}")
    private String appVersion;

    /**
     * Simple hello endpoint
     */
    @GetMapping("/")
    public ResponseEntity<Map<String, String>> home() {
        Map<String, String> response = new HashMap<>();
        response.put("message", "Hello World! Welcome to Kubernetes");
        response.put("app", appName);
        response.put("version", appVersion);
        response.put("status", "UP");
        return ResponseEntity.ok(response);
    }

    /**
     * Hello endpoint with name parameter
     */
    @GetMapping("/hello/{name}")
    public ResponseEntity<Map<String, String>> helloName(@PathVariable String name) {
        Map<String, String> response = new HashMap<>();
        response.put("message", "Hello, " + name + "!");
        response.put("app", appName);
        response.put("version", appVersion);
        return ResponseEntity.ok(response);
    }

    /**
     * Info endpoint - returns app information
     */
    @GetMapping("/info")
    public ResponseEntity<Map<String, String>> info() {
        Map<String, String> response = new HashMap<>();
        response.put("app", appName);
        response.put("version", appVersion);
        response.put("description", "Simple Spring Boot Hello World App for Kubernetes testing");
        response.put("endpoints", "/,/hello/{name},/info,/health");
        return ResponseEntity.ok(response);
    }

    /**
     * Custom health check endpoint
     */
    @GetMapping("/health/custom")
    public ResponseEntity<Map<String, String>> customHealth() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "HEALTHY");
        response.put("app", appName);
        response.put("timestamp", String.valueOf(System.currentTimeMillis()));
        return ResponseEntity.ok(response);
    }
}
