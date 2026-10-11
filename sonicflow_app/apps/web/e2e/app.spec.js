import { test, expect } from '@playwright/test';

test.describe('SonicFlow Web App', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/sonicflow_app/apps/web/');
    await page.waitForSelector('#app');
  });

  test('loads the app shell', async ({ page }) => {
    await expect(page.locator('#app')).toBeVisible();
  });

  test('renders the sidebar with mode selection', async ({ page }) => {
    const sidebar = page.locator('[data-testid="sidebar"]');
    await expect(sidebar).toBeVisible();
  });

  test('displays the player controls', async ({ page }) => {
    const player = page.locator('[data-testid="player"]');
    await expect(player).toBeVisible();
  });

  test('mode card click triggers state update', async ({ page }) => {
    const focusCard = page.locator('[data-testid="mode-focus"]');
    await focusCard.click();
    await expect(page.locator('[data-testid="active-mode"]')).toHaveText(/focus/i);
  });

  test('library view renders curated sessions', async ({ page }) => {
    const libraryButton = page.locator('[data-testid="library-toggle"]');
    await libraryButton.click();
    const libraryGrid = page.locator('[data-testid="library-grid"]');
    await expect(libraryGrid).toBeVisible();
  });
});
