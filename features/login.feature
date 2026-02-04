Feature: Persistencia de Sesión:
   Scenario: 2. Login automatico
        Given cargo la sesion desde "auth.json"
        When voy directamente al dashboard protegido
        Then deberia estar autenticado sin haber hecho login