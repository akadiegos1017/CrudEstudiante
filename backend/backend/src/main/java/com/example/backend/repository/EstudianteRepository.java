package com.example.backend.repository;

import com.example.backend.model.Estudiante;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Repository
public class EstudianteRepository {

    private final List<Estudiante> estudiantes = new ArrayList<>();
    private int nextId = 1;

    public List<Estudiante> findAll() {
        return new ArrayList<>(estudiantes);
    }

    public Optional<Estudiante> findById(int id) {
        return estudiantes.stream().filter(e -> e.getId() == id).findFirst();
    }

    public Estudiante save(Estudiante estudiante) {
        if (estudiante.getId() == 0) {
            estudiante.setId(nextId++);
            estudiantes.add(estudiante);
        } else {
            eliminarPorId(estudiante.getId());
            estudiantes.add(estudiante);
        }
        return estudiante;
    }

    public void eliminarPorId(int id) {
        estudiantes.removeIf(e -> e.getId() == id);
    }
}
