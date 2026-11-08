package model;

import java.io.Serializable;

public class Usuario implements Serializable {
    private final int id;
    private final String nome;
    private final String email;
    private final int idPlano;

    public Usuario(int id, String nome, String email, int idPlano) {
        this.id = id;
        this.nome = nome;
        this.email = email;
        this.idPlano = idPlano;
    }

    public int getId() { return id; }
    public String getNome() { return nome; }
    public String getEmail() { return email; }
    public int getIdPlano() { return idPlano; }
}
