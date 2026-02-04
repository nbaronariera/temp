import fs from 'fs-extra';
import lockfile from 'proper-lockfile';
import path from 'path';

const DB_PATH = path.resolve(process.cwd(), 'resources/users.json');

const wait = (ms: number) => new Promise(res => setTimeout(res, ms));

export class ResourceManager {
  
  static async acquireUser(type: string, retries = 30) {
    for (let i = 0; i < retries; i++) {
      let release: () => Promise<void>;
      try {
        release = await lockfile.lock(DB_PATH, { retries: 5 });
      } catch (e) {
        await wait(1000); continue; 
      }
      
      try {
        const users = await fs.readJson(DB_PATH);
        const index = users.findIndex((u: any) => u.type === type && !u.isBusy);
        
        if (index !== -1) {
          users[index].isBusy = true; 
          await fs.writeJson(DB_PATH, users, { spaces: 2 });
          return users[index];
        }
      } finally {
        await release(); 
      }

      console.log(`⏳ Worker esperando recurso tipo "${type}"...`);
      await wait(1000);
    }
    throw new Error(`Timeout: No hay usuarios disponibles del tipo "${type}"`);
  }

  static async releaseUser(username: string) {
    const release = await lockfile.lock(DB_PATH, { retries: 5 });
    try {
      const users = await fs.readJson(DB_PATH);
      const user = users.find((u: any) => u.username === username);
      if (user) {
        user.isBusy = false; 
        await fs.writeJson(DB_PATH, users, { spaces: 2 });
      }
    } finally {
      await release();
    }
  }
}