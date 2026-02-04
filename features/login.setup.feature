Feature: Persistencia de Sesión
    Scenario: 1. Login y guardar estado
        Given abro la pagina de login
        When ingreso credenciales validas "student" y "Password123"
        Then veo el dashboard de exito
        And guardo la sesion en el archivo "auth.json"