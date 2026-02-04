import { createBdd } from 'playwright-bdd';
import { expect } from '@playwright/test';
import fs from 'node:fs';
import path from 'node:path';

const { Given, When, Then } = createBdd();
Given('cargo la sesion desde {string}', async ({ context }, fileName) => {
  // Verificamos que el archivo exista antes de intentar cargarlo
  if (fs.existsSync(fileName)) {
    const authData = JSON.parse(fs.readFileSync(fileName, 'utf-8'));
    
    // 1. Inyectamos las cookies en el contexto actual
    if (authData.cookies) {
      await context.addCookies(authData.cookies);
    }
    
    
    console.log(`✅ Sesión cargada desde: ${fileName}`);
  } else {
    throw new Error(`❌ El archivo ${fileName} no existe. Ejecuta primero el escenario de login.`);
  }
});

When('voy directamente al dashboard protegido', async ({ page }) => {
  // Intentamos ir a la URL segura directamente
  await page.goto('https://practicetestautomation.com/practice-test-login-success/');
});

Then('deberia estar autenticado sin haber hecho login', async ({ page }) => {
  // Si las cookies funcionaron, no nos redirigirá al login
  await expect(page.getByText('Logged In Successfully')).toBeVisible();
  // Validamos que NO aparezca el botón de login
  await expect(page.getByRole('button', { name: 'Submit' })).not.toBeVisible();
});