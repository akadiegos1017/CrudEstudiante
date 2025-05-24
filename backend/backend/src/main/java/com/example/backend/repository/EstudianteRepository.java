package com.example.backend.repository;

import com.example.backend.model.Estudiante;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EstudianteRepository extends JpaRepository<Estudiante, Integer> {
    // Aquí puedes añadir consultas personalizadas si lo necesitas
}
