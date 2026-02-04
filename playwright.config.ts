// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';
import { defineBddConfig } from 'playwright-bdd';

// Configuración de BDD: Define dónde están los .feature y los steps
const testDir = defineBddConfig({
  features: 'features/*.feature',
  steps: 'steps/*.steps.ts',
});

export default defineConfig({
  testDir, 
  reporter: 'html',
  use: {
    headless: true,
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'setup',
      testMatch: /.*\.setup\.spec.ts/, 
    },
    {
      name: 'chromium',
      dependencies: ['setup'],
      use: { ...devices['Desktop Chrome'], 
        launchOptions: {
          args: [
            '--no-sandbox',
            '--disable-dev-shm-usage',
            '--disable-gpu',
            
            '--disable-extensions',
            '--disable-background-networking',
            
            '--ignore-certificate-errors' 
          ]
        }
      },
      testIgnore: /.*\.setup\.spec\.ts/,
      
    },
  ],
});