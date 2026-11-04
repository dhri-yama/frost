import { readFileSync } from "node:fs";
import { join } from "node:path";

// The version comes from the app's VERSION file (one level up), read at build time, so rebuild the site after a release.
const raw = (() => {
  try {
    return readFileSync(join(process.cwd(), "..", "VERSION"), "utf8").trim();
  } catch {
    return "";
  }
})();

export const version = raw || "latest";
export const repoUrl = "https://github.com/dhri-yama/frost";
export const releasesUrl = `${repoUrl}/releases`;
export const downloadUrl = raw
  ? `${repoUrl}/releases/download/v${raw}/Frost-${raw}.dmg`
  : `${repoUrl}/releases/latest`;
export const brewCommand = "brew tap dhri-yama/tap && brew trust dhri-yama/tap && brew install --cask frost";

/** Prefixes a /public path with the sub-path the site is served from, if any (plain <img> tags do not get it automatically). */
export function asset(path: string): string {
  return `${process.env.NEXT_PUBLIC_BASE_PATH ?? ""}${path}`;
}
