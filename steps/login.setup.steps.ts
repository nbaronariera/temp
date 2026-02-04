import { createBdd } from 'playwright-bdd';
import fs from 'node:fs';
import path from 'node:path';
import { test, expect } from '../fixtures/authFixture';

const { Given, When, Then } = createBdd(test);

// --- Pasos del Escenario 1 (Generar) ---

Given('abro la pagina de login', async ({ page }) => {
  await page.goto('https://practicetestautomation.com/practice-test-login/');
});

When('ingreso credenciales validas {string} y {string}', async ({ page }, user, pass) => {
  await page.getByLabel('Username').fill(user);
  await page.getByLabel('Password').fill(pass);
  await page.getByRole('button', { name: 'Submit' }).click();
});

Then('veo el dashboard de exito', async ({ page }) => {
  await expect(page).toHaveURL(/logged-in-successfully/);
  await expect(page.getByText('Logged In Successfully')).toBeVisible();
});

Then('guardo la sesion en el archivo {string}', async ({ page }, fileName) => {
  await page.context().storageState({ path: fileName });
  console.log(`✅ Estado guardado en: ${fileName}`);
});

Given('soy un usuario con rol {string}', async ({ authSession }, role) => {
  await authSession.switchTo(role);
});

Then('debería ver el dashboard seguro', async ({ page }) => {
  await expect(page).toHaveURL(/logged-in-successfully/);
});