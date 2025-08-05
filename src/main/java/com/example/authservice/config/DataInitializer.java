package com.example.authservice.config;

import com.example.authservice.entity.Role;
import com.example.authservice.repository.RoleRepository;
import com.example.authservice.util.RoleEnum;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component
public class DataInitializer implements CommandLineRunner {

    private static final Logger logger = LoggerFactory.getLogger(DataInitializer.class);
    
    private final RoleRepository roleRepository;
    
    public DataInitializer(RoleRepository roleRepository) {
        this.roleRepository = roleRepository;
    }

    @Override
    public void run(String... args) throws Exception {
        // Initialize roles if they don't exist
        if (roleRepository.findByName(RoleEnum.USER).isEmpty()) {
            Role userRole = new Role();
            userRole.setName(RoleEnum.USER);
            roleRepository.save(userRole);
            logger.info("Created USER role");
        }

        if (roleRepository.findByName(RoleEnum.ADMIN).isEmpty()) {
            Role adminRole = new Role();
            adminRole.setName(RoleEnum.ADMIN);
            roleRepository.save(adminRole);
            logger.info("Created ADMIN role");
        }
    }
}
