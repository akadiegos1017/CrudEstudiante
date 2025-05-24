package com.example.backend.controller;

import com.example.backend.model.Estudiante;
import com.example.backend.services.EstudianteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/estudiantes")
@CrossOrigin(origins = "*")  // Permite que Flutter consuma la API desde cualquier origen
public class EstudianteController {

    @Autowired
    private EstudianteService estudianteService;

    @GetMapping
    public List<Estudiante> obtenerTodos() {
        return estudianteService.getAll();
    }

    @PostMapping
    public void agregar(@RequestBody Estudiante e) {
        estudianteService.add(e);
    }

    @PutMapping("/{id}")
    public void modificar(@PathVariable Long id, @RequestBody Estudiante e) {
        e.setId(id.intValue());
        estudianteService.update(e);
    }

    @DeleteMapping("/{id}")
    public void eliminar(@PathVariable Long id) {
        estudianteService.delete(id);
    }
}
