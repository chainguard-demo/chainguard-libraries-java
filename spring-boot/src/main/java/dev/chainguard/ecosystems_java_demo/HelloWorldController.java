package dev.chainguard.ecosystems_java_demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/")
public class HelloWorldController {

    @GetMapping
    public String sayHello() {
        return "Hello, Chainguard Libraries!";
    }
}
