package com.example.backend.services;

import com.example.backend.model.Estudiante;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class EstudianteService {

    private final List<Estudiante> estudiantes = new ArrayList<>();

    public List<Estudiante> getAll() {
        return estudiantes;
    }

    public Optional<Estudiante> getById(Long id) {
        return estudiantes.stream().filter(e -> e.getId() == id).findFirst();
    }

    public void add(Estudiante e) {
        estudiantes.add(e);
    }

    public boolean update(Estudiante modificado) {
        Optional<Estudiante> opt = getById(Long.valueOf(modificado.getId()));
        if (opt.isPresent()) {
            Estudiante original = opt.get();
            original.setNombre(modificado.getNombre());
            original.setApellido(modificado.getApellido());
            original.setDocumento(modificado.getDocumento());
            original.setEmail(modificado.getEmail());
            return true;
        }
        return false;
    }

    public boolean delete(Long id) {
        return estudiantes.removeIf(e -> e.getId() == id);
    }
}
