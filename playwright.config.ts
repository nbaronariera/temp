// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';
import { defineBddConfig } from 'playwright-bdd';

// Configuración de BDD: Define dónde están los .feature y los steps
const testDir = defineBddConfig({
  features: 'features/*.feature',
  steps: ['steps/*.steps.ts', 'fixtures/authFixture.ts']
});

export default defineConfig({
  testDir, 
  reporter: 'html',
  fullyParallel: true, 
  workers: '50%',     
  use: {
    headless: true,
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'setup',
      testMatch: /.*\.setup\.feature\.spec\.(js|ts)/,
    },
    {
      name: 'chromium',
      dependencies: ['setup'],
      use: { 
        ...devices['Desktop Chrome'], 
        executablePath: process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH || undefined,
        launchOptions: {
          args: [
            '--disable-extensions',           // No carga extensiones 
            '--disable-component-update',     // No busca actualizaciones de componentes internos
            '--disable-background-networking',// Bloquea peticiones de "llamada a casa" de Google
            '--disable-default-apps',         // No carga Gmail/Docs/Drive apps por defecto
            '--disable-sync',                 // No intenta sincronizar datos
            '--mute-audio',                   // No procesa audio 
            '--no-first-run',                 // Salta el wizard de bienvenida
            '--disable-gpu',                  // En Linux/Docker, emular GPU por software es lento. Mejor apagarla.
            '--disable-software-rasterizer',  // Evita renderizado complejo por software
            '--disable-gl-drawing-for-tests', // Optimización específica de tests
            '--no-sandbox',                   // Obligatorio en Docker. Elimina la capa de seguridad extra 
            '--disable-dev-shm-usage',        // Usa /tmp en lugar de /dev/shm. Evita que el navegador crashee por falta de memoria compartida.
            '--disable-background-timer-throttling', // Evita que los scripts se pausen si la pestaña no es visible
            '--disable-backgrounding-occluded-windows',
            '--disable-renderer-backgrounding',
            '--disable-breakpad',             // Desactiva el reporte de errores (crash reporting) a Google
          ]
        }
      },
      testIgnore: /.*\.setup\.feature\.spec\.(js|ts)/,
      
    },
  ],
});