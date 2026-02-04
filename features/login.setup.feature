Feature: Persistencia de Sesión
    Scenario: 1. Login y guardar estado
        Given abro la pagina de login
        When ingreso credenciales validas "student" y "Password123"
        Then veo el dashboard de exito
        And guardo la sesion en el archivo "auth.json"

    Scenario: Gestión administrativa 1
        Given soy un usuario con rol "admin"
        Then debería ver el dashboard seguro

    Scenario: Auditoría de seguridad 2
        Given soy un usuario con rol "admin"
        Then debería ver el dashboard seguro

    Scenario: Auditoría de seguridad 3
        Given soy un usuario con rol "admin"
        Then debería ver el dashboard seguro

    Scenario: Auditoría de seguridad 4
        Given soy un usuario con rol "admin"
        Then debería ver el dashboard seguro