import { defineConfig, devices } from 'playwright';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'list',
  use: {
    baseURL: 'http://localhost:53124',
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'Mobile',
      use: { ...devices['iPhone 14'] },
    },
    {
      name: 'Tablet',
      use: { ...devices['iPad Pro 11'] },
    },
  ],
  webServer: {
    command: 'node scripts/dev-server.mjs',
    url: 'http://localhost:53124',
    reuseExistingServer: !process.env.CI,
  },
});
