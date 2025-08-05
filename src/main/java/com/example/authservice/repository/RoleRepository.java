package com.example.authservice.repository;

import com.example.authservice.entity.Role;
import com.example.authservice.util.RoleEnum;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RoleRepository extends JpaRepository<Role, Long> {
    Optional<Role> findByName(RoleEnum name);
}
