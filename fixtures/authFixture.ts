import { test as base } from 'playwright-bdd';
import { ResourceManager } from '../lib/resourceManager';

type AuthSession = {
  user: any; 
  switchTo: (role: string) => Promise<void>;
};

export const test = base.extend<{ authSession: AuthSession }>({
  
  authSession: async ({ page }, use) => {
    let currentUser: any = null;

    const sessionController: AuthSession = {
      user: null,
      switchTo: async (role: string) => {
        if (currentUser?.type === role) return;
        if (currentUser) await ResourceManager.releaseUser(currentUser.username);

        currentUser = await ResourceManager.acquireUser(role);
        
        await page.goto('https://practicetestautomation.com/practice-test-login/');
        await page.getByLabel('Username').fill(currentUser.username);
        await page.getByLabel('Password').fill(currentUser.password);
        await page.getByRole('button', { name: 'Submit' }).click();
        
        sessionController.user = currentUser;
      }
    };

    // Entregamos el control al Test
    await use(sessionController);

    // --- TEARDOWN AUTOMÁTICO ---
    // Esto se ejecuta SIEMPRE, pase o falle el test
    if (currentUser) {
      console.log(`🔓 Liberando recurso: ${currentUser.username}`);
      await ResourceManager.releaseUser(currentUser.username);
    }
  },
});

export { expect } from '@playwright/test';